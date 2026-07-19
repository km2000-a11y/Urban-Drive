extends CanvasLayer

var is_paused:=false
var volume:=80
var main_menu_path:="res://Scenes/mode_select.tscn"


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	hide()
	update_volume_label()
	apply_volume()

	
func toggle_pause():
	is_paused=!is_paused
	get_tree().paused=is_paused
	visible=is_paused
	
func _on_resume_btn_pressed() -> void:
	toggle_pause()
	

func _on_retry_btn_pressed() -> void:
	get_tree().paused=false
	get_tree().reload_current_scene()
	
func _on_quit_btn_pressed() -> void:
	get_tree().paused=false
	get_tree().change_scene_to_file(main_menu_path)

func _on_vol_up_btn_pressed() -> void:
	volume=clamp(volume+5,0,100)
	update_volume_label()
	apply_volume()
	
func _on_vol_down_btn_pressed() -> void:
	volume=clamp(volume-5,0,100)
	update_volume_label()
	apply_volume()
	
func update_volume_label():
	$Control/Panel/VolumeLabel.text="Volume: %d%%"%volume
	
func apply_volume():
	var linear=float(volume)/100.0
	AudioServer.set_bus_volume_db(0, linear_to_db(linear))
