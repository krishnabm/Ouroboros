# @tool
# This script is autoloaded from Project Settings > Autoload
#
# Global Class Name : GameParams
# This stores config like properties
# class_name GameParams
extends Node
# docstring

#region signals
#endregion
#region enums
enum ParamSection {GENERAL}
#endregion
#region constants
#endregion
#region export variables
#endregion
#region public variables
# Save high score
var highScore := 0
var warningsSeen := 0
#endregion
#region private variables
var _config := ConfigFile.new()
var _mapToSection: Dictionary
#endregion
#region onready & nodes

#endregion

#region builtin methods
func _init() -> void:
	_mapToSection = {
		"highScore": ParamSection.GENERAL,
		"warningsSeen": ParamSection.GENERAL,
	}
func _enter_tree() -> void:
	pass
func _ready() -> void:
	# Load data from a file.
	var loadResult := _config.load("user://config.cfg")
	# If the file didn't load, ignore it.
	if loadResult != OK:
		push_warning("Couldn't load config. Creating new default config")
		_set_config_value("highScore", highScore)
		_set_config_value("warningsSeen", highScore)
	else:
		highScore = get_value_or_default("highScore", 0)
		highScore = get_value_or_default("warningsSeen", 0)
		
	_save_config()

func _process(_delta: float) -> void:
	pass

func _exit_tree() -> void:
	_save_config()
#endregion

#region public methods
func get_value_or_default(key: String, saveBack: bool = true)-> Variant:
	var res: Variant = _config.get_value(ParamSection.keys()[_mapToSection[key]], key)
	if res == null:
		res = self[key]
		_set_config_value(key, res)
		if saveBack:
			_save_config()
	return res;

func update_param(paramName: String, value: Variant) -> void:
	self[paramName] = value
	_set_config_value(paramName, value)
#endregion

#region private methods
func _save_config()-> void:
	var saveResult := _config.save("user://config.cfg")
	
	if saveResult != OK:
		push_error("Couldn't save config file")
	else:
		pass

func _set_config_value(key: String, value: Variant) -> void:
	_config.set_value(ParamSection.keys()[_mapToSection[key]], key, value)
#endregion

#region subclasses
#endregion
