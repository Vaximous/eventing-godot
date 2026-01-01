extends Node

##In an actual instance, this would be apart of an addon that once initialized will add itself to a database of some kind to register itself to the game (or server)
func _ready() -> void:
	Util.register_event("onActivate",on_activate)

func on_activate(target : Variant, output : Callable)->void:
	output.call(target)
