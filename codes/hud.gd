extends CanvasLayer

@onready var perso = get_node("/root/main/player")
@onready var check_button = $pause_menu/fullscreen
signal start_game
var check_fullscreen_pressed
var on_menu_start = true
var name_jeu = "LIFESCHOOL DREAM"
var nom_arme_achetee = ""

func show_message(text):
	$titre.text = text
	$titre.show()
	$titre_timer.start()

func show_game_over():
	show_message("GAME OVER")
	await $titre_timer.timeout
	$titre.text = name_jeu
	await get_tree().create_timer(1.0).timeout
	$titre.show()
	$start_button.show()
	

func _on_start_button_pressed():
	$start_button.hide()
	start_game.emit()
	on_menu_start = false


func _on_titre_timer_timeout():
	if $titre.text != name_jeu:
		$titre.hide()

func update_life(current_life, life_total):
	current_life = max(current_life, 0)
	$barre_de_vie_player.value = (100 * current_life / life_total)


func _ready():
	# Cachez le menu au démarrage du jeu.
	$pause_menu.hide()
	var check_fullscreen_pressed = check_button.pressed
	$barre_de_vie_player.hide()
	$boss_vie.hide()
	$marchand.hide()
	$inventaire.hide()
	$fin_menu.hide()

func _unhandled_input(event):
	if event.is_action_pressed("menu"):
		# Affichez ou cachez le menu lorsque l'action "menu" est déclenchée.
		if $pause_menu.visible:
			$pause_menu.hide()
			perso.show()
			$barre_de_vie_player.show()
		else:
			affiche_menu()
	if event.is_action_pressed("inventaire"):
		# Affichez ou cachez l'inventaire lorsque l'action "inventaire" est déclenchée.
		if $inventaire.visible:
			$inventaire.hide()
			perso.show()
			$barre_de_vie_player.show()
		else:
			affiche_inventaire()


func affiche_commerce():
	# Affichez ou cachez le marchand lorsque l'action "marchand" est déclenchée.
	if $marchand.visible:
			$marchand.hide()
			perso.show()
			$barre_de_vie_player.show()
	else:
		affiche_marchand()

func _on_quit_button_pressed():
	get_tree().quit()

func affiche_menu():
	$barre_de_vie_player.hide()
	$pause_menu.show()
	perso.hide()
	$infos_affichages.hide()
	$infos_touches.hide()

func affiche_inventaire():
	$barre_de_vie_player.hide()
	$inventaire.show()
	perso.hide()
	$infos_affichages.hide()
	$infos_touches.hide()

func affiche_marchand():
	$barre_de_vie_player.hide()
	$marchand.show()
	perso.hide()

func _on_music_volum_value_changed(value):
	var music_bus_index = AudioServer.get_bus_index("Music")
	var volume_db = -15 + value * 30
	AudioServer.set_bus_volume_db(music_bus_index, volume_db)

func _on_master_volum_value_changed(value):
	var music_bus_index = AudioServer.get_bus_index("Master")
	var volume_db = -15 + value * 30
	AudioServer.set_bus_volume_db(music_bus_index, volume_db)

func _on_game_volum_value_changed(value):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("animation_music"), -15 + value * 30)


func _on_mute_game_pressed():
	var music_bus_index = AudioServer.get_bus_index("animation_music")
	var volume_db = -80
	AudioServer.set_bus_volume_db(music_bus_index, volume_db)


func _on_mute_music_pressed():
	var music_bus_index = AudioServer.get_bus_index("Music")
	var volume_db = -80
	AudioServer.set_bus_volume_db(music_bus_index, volume_db)


func _on_mute_master_pressed():
	var music_bus_index = AudioServer.get_bus_index("animation_music")
	var volume_db = -80
	AudioServer.set_bus_volume_db(music_bus_index, volume_db)


func _on_check_button_pressed():
	if !check_fullscreen_pressed:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		check_fullscreen_pressed = true
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		check_fullscreen_pressed = false


func _on_resume_button_pressed():
	$pause_menu.hide()
	if !on_menu_start :
		perso.show()
		$barre_de_vie_player.show()

func degats_info_inventaire(degats_arme, ressources_actu, nom_arme):
	$inventaire/degats.text = "DEGATS : " + str(degats_arme)
	$inventaire/ressources.text = "RESSOURCES : " + str(ressources_actu)
	$inventaire/nom_arme.text = str(nom_arme)
	$marchand/ressources.text = "RESSOURCES : " + str(ressources_actu)

func choix_marchandises(dico, choix1, choix2, choix3):
	$marchand/achat_button1.text = str(dico[choix1][1])
	$marchand/achat_button2.text = str(dico[choix2][1])
	$marchand/achat_button3.text = str(dico[choix3][1])
	$marchand/achat1.text = str(choix1) + "\nDEGATS : " + str(dico[choix1][0])
	$marchand/achat2.text = str(choix2) + "\nDEGATS : " + str(dico[choix2][0])
	$marchand/achat3.text = str(choix3) + "\nDEGATS : " + str(dico[choix3][0])


func _on_achat_button_1_pressed():
	nom_arme_achetee = ""
	for ele in $marchand/achat1.text:
		if ele != "\n":
			nom_arme_achetee = nom_arme_achetee + ele
		else:
			break
	get_node("/root/main/player").changer_arme(nom_arme_achetee,$marchand/achat_button1.text,$marchand/achat_button1)


func _on_achat_button_2_pressed():
	nom_arme_achetee = ""
	for ele in $marchand/achat2.text:
		if ele != "\n":
			nom_arme_achetee = nom_arme_achetee + ele
		else:
			break
	get_node("/root/main/player").changer_arme(nom_arme_achetee,$marchand/achat_button2.text,$marchand/achat_button2)


func _on_achat_button_3_pressed():
	nom_arme_achetee = ""
	for ele in $marchand/achat3.text:
		if ele != "\n":
			nom_arme_achetee = nom_arme_achetee + ele
		else:
			break
	get_node("/root/main/player").changer_arme(nom_arme_achetee,$marchand/achat_button3.text,$marchand/achat_button3)


func _on_quit_button_marchand_pressed():
	$marchand.hide()
	perso.show()
	$barre_de_vie_player.show()
