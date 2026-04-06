extends Node
## Signal bus (pub/sub) that does not specify signals beforehand, and instead
## they are generated at runtime. Can be used alongside other more
## reliable signal buses. Usage of parameters is optional and not checked.
## Can of course be extended also with specified signals.

static var instance: SignalBus

func _ready() -> void:
	var this_is_autoload_bus := str(get_path()) == "/root/SignalBus"

	if this_is_autoload_bus:
		instance = self
		print("[SignalBus] Registered autoload bus instance at: ", get_path())
	elif instance == null:
		instance = self
		print("[SignalBus] Registered fallback bus instance at: ", get_path())
	elif instance != self:
		print("[SignalBus] Secondary bus instance detected at: ", get_path(), " | keeping primary at: ", instance.get_path())
	else:
		print("[SignalBus] Reusing primary bus instance at: ", get_path())

func pub(signal_name: String, data = null):
	if has_signal(signal_name):
		var subscribers := get_signal_connection_list(signal_name).size()
		print("[SignalBus] Publishing '", signal_name, "' on ", get_path(), " | subscribers=", subscribers)
		emit_signal(signal_name, data)
	else:
		print("[SignalBus] Publish skipped, signal not found: '", signal_name, "' on ", get_path())

func sub(signal_name: String, action: Callable):
	if not has_signal(signal_name):
		add_user_signal(signal_name)
		print("[SignalBus] Created runtime signal '", signal_name, "' on ", get_path())

	if is_connected(signal_name, action):
		print("[SignalBus] Subscription already exists for '", signal_name, "' on ", get_path())
		return

	connect(signal_name, action)
	print("[SignalBus] Subscribed callable to '", signal_name, "' on ", get_path(), " | subscribers=", get_signal_connection_list(signal_name).size())
