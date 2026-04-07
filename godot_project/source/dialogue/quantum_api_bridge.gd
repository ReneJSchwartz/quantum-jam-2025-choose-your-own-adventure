class_name QuantumApiBridge
extends Node

const QUANTUM_API_CLIENT_PATH := "res://addons/quantum_api_client/quantum_api_client.gd"

const SETTINGS_BASE_URL := "quantum_api/base_url"
const SETTINGS_BACKEND_PROXY_MODE := "quantum_api/backend_proxy_mode"
const SETTINGS_DIRECT_API_KEY := "quantum_api/direct_api_key"
const SETTINGS_GATE_EXECUTION_MODE := "quantum_api/gate_execution_mode"
const SETTINGS_DEFAULT_IBM_BACKEND := "quantum_api/default_ibm_backend"
const SETTINGS_IBM_SHOTS := "quantum_api/ibm_shots"
const SETTINGS_IBM_JOB_POLL_INTERVAL_SEC := "quantum_api/ibm_job_poll_interval_sec"
const SETTINGS_IBM_JOB_TIMEOUT_SEC := "quantum_api/ibm_job_timeout_sec"

const DEFAULT_BASE_URL := "https://davidjgrimsley.com/public-facing/api/quantum/v1"
const PLACEHOLDER_BASE_URL_FRAGMENT := "your-backend.example.com"
const DEFAULT_BACKEND_PROXY_MODE := true
const DEFAULT_DIRECT_API_KEY := ""
const DEFAULT_GATE_EXECUTION_MODE := "simulator"
const DEFAULT_IBM_SHOTS := 1024
const DEFAULT_IBM_JOB_POLL_INTERVAL_SEC := 3.0
const DEFAULT_IBM_JOB_TIMEOUT_SEC := 420.0
const HARDWARE_SUCCESS_QUALITY_THRESHOLD := 0.85

static var pending_bridge: QuantumApiBridge

var client: Node
var cached_ibm_backend_name: String = ""
var gate_execution_mode: String = DEFAULT_GATE_EXECUTION_MODE

static func get_or_create(context: Node) -> QuantumApiBridge:
	if context == null or context.get_tree() == null:
		push_error("QuantumApiBridge requires a node attached to the scene tree")
		return null

	var root := context.get_tree().root
	var existing := root.get_node_or_null("QuantumApiBridge")
	if existing != null:
		return existing as QuantumApiBridge

	if pending_bridge != null and is_instance_valid(pending_bridge):
		return pending_bridge

	var bridge := QuantumApiBridge.new()
	bridge.name = "QuantumApiBridge"
	pending_bridge = bridge
	root.call_deferred("add_child", bridge)
	return bridge

static func health_check(context: Node, callback: Callable) -> void:
	var bridge := get_or_create(context)
	if bridge == null:
		callback.call(false, {"error": "bridge_unavailable", "message": "Quantum API bridge is unavailable"})
		return
	bridge._health_check(callback)

static func transform_text(context: Node, text: String, callback: Callable, fallback_text: String = "") -> void:
	var bridge := get_or_create(context)
	if bridge == null:
		callback.call(false, {"original": text, "transformed": fallback_text if !fallback_text.is_empty() else text})
		return
	bridge._transform_text(text, callback, fallback_text)

static func run_gate(context: Node, gate_type: String, callback: Callable, rotation_angle_rad: Variant = null) -> void:
	var bridge := get_or_create(context)
	if bridge == null:
		callback.call(false, {"error": "bridge_unavailable", "message": "Quantum API bridge is unavailable"})
		return
	bridge._run_gate(gate_type, callback, rotation_angle_rad)

func _ready() -> void:
	_ensure_client()

func refresh_config() -> void:
	_ensure_client()
	_configure_client_from_settings()
	cached_ibm_backend_name = ""

func _health_check(callback: Callable) -> void:
	if !_ensure_client(callback):
		return
	client.call("health_check", callback)

func _transform_text(text: String, callback: Callable, fallback_text: String = "") -> void:
	if !_ensure_client(callback, text, fallback_text):
		return
	client.call("transform_text", text, callback, fallback_text)

func _run_gate(gate_type: String, callback: Callable, rotation_angle_rad: Variant = null) -> void:
	if !_ensure_client(callback):
		return
	if _resolve_gate_execution_mode() == "hardware":
		_submit_gate_as_ibm_job(gate_type, callback, rotation_angle_rad)
		return

	if client.has_method("run_gate"):
		client.call("run_gate", gate_type, callback, rotation_angle_rad)
		return

	callback.call(false, {
		"error": "missing_run_gate_method",
		"message": "Quantum API client does not expose run_gate().",
		"status_code": 0,
	})

func _submit_gate_as_ibm_job(gate_type: String, callback: Callable, rotation_angle_rad: Variant = null) -> void:
	var operation := _build_gate_operation(gate_type, rotation_angle_rad)
	if operation.is_empty():
		callback.call(false, {
			"error": "invalid_gate_payload",
			"message": "Unsupported gate_type or missing rotation angle for IBM job submission.",
			"status_code": 400,
			"gate_type": gate_type,
		})
		return

	_resolve_ibm_backend(
		func(backend_success: bool, backend_payload: Dictionary) -> void:
			if !backend_success:
				callback.call(
					true,
					_build_hardware_failure_payload(
						{},
						backend_payload,
						gate_type,
						"",
						0,
						"backend_resolution_failed",
						str(backend_payload.get("message", "Unable to resolve IBM backend.")),
						false
					)
				)
				return

			var backend_name := str(backend_payload.get("backend_name", "")).strip_edges()
			if backend_name.is_empty():
				callback.call(false, {
					"error": "missing_ibm_backend",
					"message": "Unable to resolve an IBM backend for circuit job submission.",
					"status_code": 400,
				})
				return

			var shots := _get_ibm_shots_setting()
			var job_payload: Dictionary = {
				"provider": "ibm",
				"backend_name": backend_name,
				"shots": shots,
				"circuit": {
					"num_qubits": 1,
					"operations": [operation],
				},
			}

			client.call(
				"submit_circuit_job",
				job_payload,
				_on_submit_gate_job_response.bind(callback, gate_type, backend_name, shots, rotation_angle_rad)
			)
	)

func _on_submit_gate_job_response(
	request_success: bool,
	payload: Dictionary,
	callback: Callable,
	gate_type: String,
	backend_name: String,
	shots: int,
	rotation_angle_rad: Variant,
) -> void:
	if !request_success:
		callback.call(
			true,
			_build_hardware_failure_payload(
				{},
				payload,
				gate_type,
				backend_name,
				shots,
				"submit_failed",
				str(payload.get("message", "Failed to submit IBM hardware job.")),
				false
			)
		)
		return

	var submit_payload: Dictionary = payload.duplicate(true)
	var job_id := str(submit_payload.get("job_id", "")).strip_edges()
	if job_id.is_empty():
		callback.call(
			true,
			_build_hardware_failure_payload(
				submit_payload,
				{},
				gate_type,
				backend_name,
				shots,
				"missing_job_id",
				"IBM hardware job submission did not return a job_id.",
				false
			)
		)
		return

	var started_at_unix := int(Time.get_unix_time_from_system())
	_poll_ibm_job_status(
		job_id,
		callback,
		gate_type,
		backend_name,
		shots,
		rotation_angle_rad,
		started_at_unix,
		submit_payload
	)

func _poll_ibm_job_status(
	job_id: String,
	callback: Callable,
	gate_type: String,
	backend_name: String,
	shots: int,
	rotation_angle_rad: Variant,
	started_at_unix: int,
	submit_payload: Dictionary,
) -> void:
	if client == null or !client.has_method("get_circuit_job"):
		callback.call(
			true,
			_build_hardware_failure_payload(
				submit_payload,
				{},
				gate_type,
				backend_name,
				shots,
				"missing_job_status_method",
				"Quantum API client is missing get_circuit_job()."
			)
		)
		return

	client.call(
		"get_circuit_job",
		job_id,
		_on_poll_ibm_job_status.bind(
			job_id,
			callback,
			gate_type,
			backend_name,
			shots,
			rotation_angle_rad,
			started_at_unix,
			submit_payload
		)
	)

func _on_poll_ibm_job_status(
	request_success: bool,
	payload: Dictionary,
	job_id: String,
	callback: Callable,
	gate_type: String,
	backend_name: String,
	shots: int,
	rotation_angle_rad: Variant,
	started_at_unix: int,
	submit_payload: Dictionary,
) -> void:
	if !request_success:
		var transient_status_error := _is_retryable_ibm_poll_error(payload)
		var elapsed_seconds_on_error := float(Time.get_unix_time_from_system() - started_at_unix)
		if transient_status_error and elapsed_seconds_on_error < _get_ibm_job_timeout_seconds():
			if _queue_next_ibm_status_poll(
				job_id,
				callback,
				gate_type,
				backend_name,
				shots,
				rotation_angle_rad,
				started_at_unix,
				submit_payload
			):
				return

		callback.call(
			true,
			_build_hardware_failure_payload(
				submit_payload,
				payload,
				gate_type,
				backend_name,
				shots,
				"job_status_transient_failed" if transient_status_error else "job_status_failed",
				str(payload.get("message", "Failed to query IBM job status."))
			)
		)
		return

	var status := str(payload.get("status", "queued")).strip_edges().to_lower()
	if status == "queued" or status == "running":
		var elapsed_seconds := float(Time.get_unix_time_from_system() - started_at_unix)
		if elapsed_seconds >= _get_ibm_job_timeout_seconds():
			var timeout_payload := _build_hardware_failure_payload(
				submit_payload,
				payload,
				gate_type,
				backend_name,
				shots,
				"ibm_job_timeout",
				"IBM hardware job timed out before completion."
			)
			timeout_payload["status"] = "timeout"
			timeout_payload["elapsed_seconds"] = elapsed_seconds
			callback.call(true, timeout_payload)
			return

		if !_queue_next_ibm_status_poll(
			job_id,
			callback,
			gate_type,
			backend_name,
			shots,
			rotation_angle_rad,
			started_at_unix,
			submit_payload
		):
			callback.call(
				true,
				_build_hardware_failure_payload(
					submit_payload,
					payload,
					gate_type,
					backend_name,
					shots,
					"missing_scene_tree",
					"Cannot continue polling IBM job without a scene tree."
				)
			)
			return
		return

	if status == "succeeded":
		if client == null or !client.has_method("get_circuit_job_result"):
			callback.call(
				true,
				_build_hardware_failure_payload(
					submit_payload,
					payload,
					gate_type,
					backend_name,
					shots,
					"missing_job_result_method",
					"Quantum API client is missing get_circuit_job_result()."
				)
			)
			return

		client.call(
			"get_circuit_job_result",
			job_id,
			_on_poll_ibm_job_result.bind(job_id, callback, gate_type, backend_name, shots, rotation_angle_rad, started_at_unix, submit_payload, payload)
		)
		return

	callback.call(
		true,
		_build_hardware_failure_payload(
			submit_payload,
			payload,
			gate_type,
			backend_name,
			shots,
			"ibm_job_" + status,
			"IBM hardware job finished with status: " + status
		)
	)

func _on_poll_ibm_job_result(
	request_success: bool,
	payload: Dictionary,
	job_id: String,
	callback: Callable,
	gate_type: String,
	backend_name: String,
	shots: int,
	rotation_angle_rad: Variant,
	started_at_unix: int,
	submit_payload: Dictionary,
	status_payload: Dictionary,
) -> void:
	if !request_success:
		var transient_result_error := _is_retryable_ibm_poll_error(payload)
		var elapsed_seconds_on_result_error := float(Time.get_unix_time_from_system() - started_at_unix)
		if transient_result_error and elapsed_seconds_on_result_error < _get_ibm_job_timeout_seconds():
			if _queue_next_ibm_status_poll(
				job_id,
				callback,
				gate_type,
				backend_name,
				shots,
				rotation_angle_rad,
				started_at_unix,
				submit_payload
			):
				return

		callback.call(
			true,
			_build_hardware_failure_payload(
				submit_payload,
				payload,
				gate_type,
				backend_name,
				shots,
				"job_result_transient_failed" if transient_result_error else "job_result_failed",
				str(payload.get("message", "Failed to fetch IBM job result."))
			)
		)
		return

	callback.call(
		true,
		_build_completed_hardware_payload(
			submit_payload,
			status_payload,
			payload,
			gate_type,
			backend_name,
			shots,
			rotation_angle_rad
		)
	)

func _queue_next_ibm_status_poll(
	job_id: String,
	callback: Callable,
	gate_type: String,
	backend_name: String,
	shots: int,
	rotation_angle_rad: Variant,
	started_at_unix: int,
	submit_payload: Dictionary,
) -> bool:
	var tree := get_tree()
	if tree == null:
		return false

	tree.create_timer(_get_ibm_job_poll_interval_seconds()).timeout.connect(
		func() -> void:
			_poll_ibm_job_status(
				job_id,
				callback,
				gate_type,
				backend_name,
				shots,
				rotation_angle_rad,
				started_at_unix,
				submit_payload
			)
	)
	return true

func _is_retryable_ibm_poll_error(payload: Dictionary) -> bool:
	var status_code := int(payload.get("status_code", 0))
	if status_code == 408 or status_code == 429 or status_code == 500 or status_code == 502 or status_code == 503 or status_code == 504:
		return true

	var error_code := str(payload.get("error", "")).strip_edges().to_lower()
	if error_code == "request_timeout" or error_code == "timeout" or error_code == "transport_error" or error_code == "connection_error" or error_code == "server_error":
		return true

	var message := str(payload.get("message", "")).strip_edges().to_lower()
	if message.find("maximum execution time") != -1:
		return true

	var result_text := str(payload.get("result_text", "")).strip_edges().to_upper()
	if result_text.find("TIMEOUT") != -1 or result_text.find("NO_RESPONSE") != -1:
		return true

	return false

func _build_hardware_failure_payload(
	submit_payload: Dictionary,
	latest_payload: Dictionary,
	gate_type: String,
	backend_name: String,
	shots: int,
	error_code: String,
	message: String = "",
	submitted: bool = true,
) -> Dictionary:
	var response_payload: Dictionary = submit_payload.duplicate(true)
	response_payload.merge(latest_payload, true)
	response_payload["success"] = false
	response_payload["hardware_job_submitted"] = submitted
	response_payload["job_pending"] = false
	response_payload["provider"] = "ibm"
	response_payload["backend_name"] = backend_name
	response_payload["shots"] = shots
	response_payload["gate_type"] = gate_type
	if !error_code.is_empty():
		response_payload["error"] = error_code
	if !message.is_empty():
		response_payload["message"] = message
	return response_payload

func _build_completed_hardware_payload(
	submit_payload: Dictionary,
	status_payload: Dictionary,
	result_payload: Dictionary,
	gate_type: String,
	backend_name: String,
	shots: int,
	rotation_angle_rad: Variant,
) -> Dictionary:
	var response_payload: Dictionary = submit_payload.duplicate(true)
	response_payload.merge(status_payload, true)
	response_payload["hardware_job_submitted"] = true
	response_payload["job_pending"] = false
	response_payload["provider"] = "ibm"
	response_payload["backend_name"] = backend_name
	response_payload["shots"] = shots
	response_payload["gate_type"] = gate_type
	response_payload["job_result"] = result_payload

	var counts := _extract_counts_from_result_payload(result_payload)
	var observed_probability_one := _observed_probability_one(counts)
	var expected_probability_one := _expected_probability_one(gate_type, rotation_angle_rad)
	var quality_score: float = 1.0 - absf(observed_probability_one - expected_probability_one)
	var measurement := 1 if observed_probability_one >= 0.5 else 0
	var superposition_strength: float = maxf(observed_probability_one, 1.0 - observed_probability_one)

	response_payload["counts"] = counts
	response_payload["measurement"] = measurement
	response_payload["superposition_strength"] = superposition_strength
	response_payload["observed_probability_one"] = observed_probability_one
	response_payload["expected_probability_one"] = expected_probability_one
	response_payload["quality_score"] = quality_score
	response_payload["success"] = quality_score >= HARDWARE_SUCCESS_QUALITY_THRESHOLD
	if !response_payload.has("message"):
		response_payload["message"] = "IBM hardware job completed and evaluated from measured counts."

	return response_payload

func _extract_counts_from_result_payload(result_payload: Dictionary) -> Dictionary:
	var result_variant: Variant = result_payload.get("result", null)
	if result_variant is Dictionary:
		var result_dict: Dictionary = result_variant
		var nested_counts_variant: Variant = result_dict.get("counts", null)
		if nested_counts_variant is Dictionary:
			var nested_counts: Dictionary = nested_counts_variant
			return nested_counts.duplicate(true)

	var top_counts_variant: Variant = result_payload.get("counts", null)
	if top_counts_variant is Dictionary:
		var top_counts: Dictionary = top_counts_variant
		return top_counts.duplicate(true)

	return {}

func _observed_probability_one(counts: Dictionary) -> float:
	if counts.is_empty():
		return 0.0

	var total_shots := 0
	var ones_shots := 0
	for key_variant in counts.keys():
		var bitstring := str(key_variant).strip_edges()
		var count := int(counts[key_variant])
		if count <= 0:
			continue
		total_shots += count
		if _is_bitstring_one(bitstring):
			ones_shots += count

	if total_shots <= 0:
		return 0.0
	return float(ones_shots) / float(total_shots)

func _is_bitstring_one(bitstring: String) -> bool:
	var normalized := bitstring.strip_edges().replace(" ", "")
	if normalized.is_empty():
		return false
	var last_char := normalized.substr(normalized.length() - 1, 1)
	return last_char == "1"

func _expected_probability_one(gate_type: String, rotation_angle_rad: Variant = null) -> float:
	var normalized_gate_type := gate_type.strip_edges().to_lower()
	match normalized_gate_type:
		"bit_flip":
			return 1.0
		"phase_flip":
			return 0.0
		"rotation":
			if rotation_angle_rad == null:
				return 0.5
			var theta := float(rotation_angle_rad)
			var amplitude := sin(theta / 2.0)
			return clampf(amplitude * amplitude, 0.0, 1.0)
		_:
			return 0.5

func _get_ibm_job_poll_interval_seconds() -> float:
	var configured_interval := float(ProjectSettings.get_setting(
		SETTINGS_IBM_JOB_POLL_INTERVAL_SEC,
		DEFAULT_IBM_JOB_POLL_INTERVAL_SEC
	))
	if configured_interval < 0.25:
		return DEFAULT_IBM_JOB_POLL_INTERVAL_SEC
	return configured_interval

func _get_ibm_job_timeout_seconds() -> float:
	var configured_timeout := float(ProjectSettings.get_setting(
		SETTINGS_IBM_JOB_TIMEOUT_SEC,
		DEFAULT_IBM_JOB_TIMEOUT_SEC
	))
	if configured_timeout < 5.0:
		return DEFAULT_IBM_JOB_TIMEOUT_SEC
	return configured_timeout

func _resolve_ibm_backend(callback: Callable) -> void:
	if !cached_ibm_backend_name.is_empty():
		callback.call(true, {
			"backend_name": cached_ibm_backend_name,
			"source": "cache",
		})
		return

	var configured_backend := str(ProjectSettings.get_setting(SETTINGS_DEFAULT_IBM_BACKEND, "")).strip_edges()
	if !configured_backend.is_empty():
		cached_ibm_backend_name = configured_backend
		callback.call(true, {
			"backend_name": configured_backend,
			"source": "project_setting",
		})
		return

	if client == null or !client.has_method("list_backends"):
		callback.call(false, {
			"error": "missing_backend_lookup",
			"message": "Quantum API client does not expose list_backends().",
			"status_code": 0,
		})
		return

	client.call(
		"list_backends",
		_on_list_backends_for_ibm.bind(callback),
		"ibm",
		false,
		1
	)

func _on_list_backends_for_ibm(request_success: bool, payload: Dictionary, callback: Callable) -> void:
	if !request_success:
		callback.call(false, payload)
		return

	var backends_variant: Variant = payload.get("backends", [])
	if !(backends_variant is Array):
		callback.call(false, {
			"error": "invalid_backend_payload",
			"message": "Backend list response did not include a backends array.",
			"status_code": 0,
			"payload": payload,
		})
		return

	var backends: Array = backends_variant
	var selected_backend := ""

	for backend_variant in backends:
		if !(backend_variant is Dictionary):
			continue
		var backend: Dictionary = backend_variant
		if bool(backend.get("is_hardware", false)):
			selected_backend = str(backend.get("name", "")).strip_edges()
			if !selected_backend.is_empty():
				break

	if selected_backend.is_empty():
		for backend_variant in backends:
			if !(backend_variant is Dictionary):
				continue
			var backend: Dictionary = backend_variant
			if str(backend.get("provider", "")).strip_edges().to_lower() == "ibm":
				selected_backend = str(backend.get("name", "")).strip_edges()
				if !selected_backend.is_empty():
					break

	if selected_backend.is_empty():
		callback.call(false, {
			"error": "no_ibm_backend_available",
			"message": "No IBM backend was returned for this profile.",
			"status_code": 400,
			"payload": payload,
		})
		return

	cached_ibm_backend_name = selected_backend
	callback.call(true, {
		"backend_name": selected_backend,
		"source": "list_backends",
	})

func _build_gate_operation(gate_type: String, rotation_angle_rad: Variant = null) -> Dictionary:
	var normalized_gate_type := gate_type.strip_edges().to_lower()
	match normalized_gate_type:
		"bit_flip":
			return {
				"gate": "x",
				"target": 0,
			}
		"phase_flip":
			return {
				"gate": "z",
				"target": 0,
			}
		"rotation":
			if rotation_angle_rad == null:
				return {}
			return {
				"gate": "ry",
				"target": 0,
				"theta": float(rotation_angle_rad),
			}
		_:
			return {}

func _get_ibm_shots_setting() -> int:
	var configured_shots := int(ProjectSettings.get_setting(SETTINGS_IBM_SHOTS, DEFAULT_IBM_SHOTS))
	if configured_shots < 1:
		return DEFAULT_IBM_SHOTS
	return configured_shots

func _resolve_gate_execution_mode() -> String:
	var configured_mode := str(ProjectSettings.get_setting(SETTINGS_GATE_EXECUTION_MODE, gate_execution_mode)).strip_edges().to_lower()
	if configured_mode == "hardware" or configured_mode == "ibm":
		return "hardware"
	return "simulator"

func _ensure_client(callback: Callable = Callable(), original_text: String = "", fallback_text: String = "") -> bool:
	if client != null:
		return true

	var client_script = load(QUANTUM_API_CLIENT_PATH)
	if client_script == null:
		var error_payload := {
			"error": "missing_addon_client",
			"message": "Quantum API addon client script is missing",
			"status_code": 0,
		}
		if callback.is_valid():
			if !original_text.is_empty() or !fallback_text.is_empty():
				callback.call(false, {
					"original": original_text,
					"transformed": fallback_text if !fallback_text.is_empty() else original_text,
					"message": error_payload["message"],
					"status_code": 0,
				})
			else:
				callback.call(false, error_payload)
		push_error("QuantumApiBridge failed to load addon client: " + QUANTUM_API_CLIENT_PATH)
		return false

	client = client_script.new()
	add_child(client)
	_configure_client_from_settings()
	return true

func _configure_client_from_settings() -> void:
	if client == null:
		return

	gate_execution_mode = _resolve_gate_execution_mode()

	if client.has_method("apply_project_settings"):
		client.call("apply_project_settings")
	else:
		# Backward-compatible fallback for older addon versions.
		var base_url := str(ProjectSettings.get_setting(SETTINGS_BASE_URL, DEFAULT_BASE_URL)).strip_edges()
		if base_url.is_empty() or base_url.contains(PLACEHOLDER_BASE_URL_FRAGMENT):
			base_url = DEFAULT_BASE_URL

		var backend_proxy_mode := bool(ProjectSettings.get_setting(SETTINGS_BACKEND_PROXY_MODE, DEFAULT_BACKEND_PROXY_MODE))
		var direct_api_key := str(ProjectSettings.get_setting(SETTINGS_DIRECT_API_KEY, DEFAULT_DIRECT_API_KEY)).strip_edges()

		client.call("set_base_url", base_url)
		client.call("set_backend_proxy_mode", backend_proxy_mode)
		client.call("set_api_key", direct_api_key)

	var snapshot: Dictionary = {}
	if client.has_method("get_config_snapshot"):
		snapshot = client.call("get_config_snapshot")

	print(
		"[QuantumApiBridge] Configured client | base_url=", str(snapshot.get("base_url", "n/a")),
		" gate_execution_mode=", gate_execution_mode,
		" backend_proxy_mode=", bool(snapshot.get("backend_proxy_mode", DEFAULT_BACKEND_PROXY_MODE)),
		" api_key_present=", bool(snapshot.get("api_key_present", false))
	)
