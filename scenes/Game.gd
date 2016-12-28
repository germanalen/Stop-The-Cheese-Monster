extends Spatial



var monster = null
var player_controller = null

onready var ground = get_node("Ground")

var gaming = false

onready var play_button = get_node("Hud/PlayButton")

onready var game_over_hud = get_node("Hud/GameOverHud")
onready var win_hud = get_node("Hud/WinHud")

func _ready():
	set_process(true)
	set_process_input(true)
	
	add_player_controller()

func _input(event):
	if event.is_action_pressed("pause") and gaming:
		get_tree().set_pause(!get_tree().is_paused())

func _process(delta):
	ground.set_player_z(player_controller.get_player_pos().z)
	
	if gaming:
		if abs(monster.get_translation().z - player_controller.get_player_pos().z) < 150:
			player_controller.set_forward_speed(player_monster_game_speed)
		if !player_controller.player_alive():
			game_over_hud.set_hidden(false)
			gaming = false
		if !monster.alive():
			win_hud.set_hidden(false)
			gaming = false


const player_monster_game_speed = 200

func add_player_controller():
	player_controller = load("res://scenes/player/PlayerController.tscn").instance()
	player_controller.set_forward_speed(1500)
	player_controller.set_pause_mode(Node.PAUSE_MODE_STOP)
	add_child(player_controller)

func add_monster():
	monster = load("res://scenes/monster/Monster.tscn").instance()
	monster.set_translation(player_controller.get_translation() + Vector3(0,0,-3500))
	monster.player_controller_node_path = "../PlayerController"
	monster.walking_speed = player_monster_game_speed
	monster.set_pause_mode(Node.PAUSE_MODE_STOP)
	add_child(monster)


func _on_PlayButton_pressed():
	play_button.set_hidden(true)
	add_monster()
	gaming = true


func _on_ReloadButton_pressed():
	get_tree().reload_current_scene()
