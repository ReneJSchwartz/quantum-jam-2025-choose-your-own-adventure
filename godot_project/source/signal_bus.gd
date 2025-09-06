extends Node
## Signal bus (pub/sub) that does not specify signals beforehand, and instead
## they are generated at runtime. Can be used alongside other more
## reliable signal buses. Usage of parameters is optional and not checked.
## Can of course be extended also with specified signals.

func pub(signal_name: String, data = null):
	if has_signal(signal_name): 
		emit_signal(signal_name, data)

func sub(signal_name: String, action: Callable):
	if not has_signal(signal_name): 
		add_user_signal(signal_name)
	connect(signal_name, action)
