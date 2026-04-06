class_name QuantumApiBridge
extends Node

const QUANTUM_API_CLIENT_PATH := "res://addons/quantum_api_client/quantum_api_client.gd"

const SETTINGS_BASE_URL := "quantum_api/base_url"
const SETTINGS_BACKEND_PROXY_MODE := "quantum_api/backend_proxy_mode"
const SETTINGS_DIRECT_API_KEY := "quantum_api/direct_api_key"

const DEFAULT_BASE_URL := "https://davidjgrimsley.com/public-facing/api/quantum/v1"
const PLACEHOLDER_BASE_URL_FRAGMENT := "your-backend.example.com"
const DEFAULT_BACKEND_PROXY_MODE := true
const DEFAULT_DIRECT_API_KEY := ""

static var pending_bridge: QuantumApiBridge

var client: Node

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
	client.call("run_gate", gate_type, callback, rotation_angle_rad)

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
		" backend_proxy_mode=", bool(snapshot.get("backend_proxy_mode", DEFAULT_BACKEND_PROXY_MODE)),
		" api_key_present=", bool(snapshot.get("api_key_present", false))
	)
