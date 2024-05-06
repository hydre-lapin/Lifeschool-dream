extends Node

@export var mob_scene_path: String = "res://scenes/mob.tscn"
@export var boss_scene_path: String = "res://scenes/boss.tscn"
@export var marchand_scene_path: String = "res://scenes/marchand.tscn"
@onready var fond_start = get_node("/root/main/HUD/fond_menu")
@onready var hud = get_node("/root/main/HUD")
@onready var barre_vie = get_node("/root/main/HUD/barre_de_vie_player")

var mob_scene: PackedScene
var boss_scene: PackedScene
var marchand_scene : PackedScene
var mob_start = 0
var mob_restant = 0
var salles_instance
var start_position
var mob_max_par_salle
var salle_en_cours
var compte_salle

func _ready():
	mob_scene = load(mob_scene_path)
	boss_scene = load(boss_scene_path)
	marchand_scene = load(marchand_scene_path)
	mob_start = 3
	mob_max_par_salle = mob_start
	salle_en_cours = "salle2"
	compte_salle = 2
	spawn_marchand()

func game_over():
	$music.stop()
	$attaque_de_boss.stop()
	$game_over.play()
	$HUD.show_game_over()
	$player.hide()
	$HUD/fin_menu.hide()
	fond_start.show()
	barre_vie.hide()
	$HUD/boss_vie.hide()

func new_game():
	$HUD/fin_menu.show()
	$HUD/fin_menu.hide()
	$music.play()
	for mob in get_tree().get_nodes_in_group("mobs"):
		mob.queue_free()
	for boss in get_tree().get_nodes_in_group("boss"):
		boss.queue_free()
	for spell in get_tree().get_nodes_in_group("spells"):
		spell.queue_free()
	for door in get_tree().get_nodes_in_group("doors"):
		door.fermer()
	mob_start = mob_max_par_salle
	mob_restant = mob_start
	$player.start($start_position.position)
	$start_timer.start()
	$HUD.show_message("GET READY!!!!!")
	$player.life = $player.life_total
	$HUD.update_life($player.life,$player.life_total)
	$mob_timer.start()
	$HUD/infos_touches.hide()
	$HUD/infos_affichages.hide()
	$HUD/fond_menu.hide()
	barre_vie.show()
	$HUD/boss_vie.hide()
	open_doors("salle1")
	salle_en_cours = "salle2"
	compte_salle = 2
	spawn_marchand()
	$player.nom_arme = "epee classique"
	$player.degats = 1
	$player.ressources = 0
	get_node("/root/main/HUD").degats_info_inventaire($player.degats,$player.ressources,$player.nom_arme)
	var keys = $player.infos_armes.keys()
	var selected_keys = []
	for i in range(3):
		var random_index = randi() % keys.size()
		var key = keys[random_index]
		selected_keys.append(key)
		keys.remove_at(random_index)
	selected_keys.sort()
	get_node("/root/main/HUD").choix_marchandises($player.infos_armes, selected_keys[0],selected_keys[1],selected_keys[2])
	marchand_boutton()
	for i in range(4):
		total_mobs_created[i] = 0

func marchand_boutton():
	if !$HUD/marchand/achat_button1.visible:
		$player.changer_arme("null","null",$HUD/marchand/achat_button1)
	if !$HUD/marchand/achat_button2.visible:
		$player.changer_arme("null","null",$HUD/marchand/achat_button2)
	if !$HUD/marchand/achat_button3.visible:
		$player.changer_arme("null","null",$HUD/marchand/achat_button3)

func _on_start_timer_timeout():
	$mob_timer.start()
	var boss = boss_scene.instantiate()
	# Choisissez un point de spawn aléatoire parmi les enfants de "MobSpawns"
	var boss_spawn_location = get_node("salle_boss/spawn_boss")
	boss.global_position = boss_spawn_location.global_position
	add_child(boss)

# Ajoutez une nouvelle variable pour suivre le nombre total de mobs créés
var total_mobs_created = [0, 0, 0, 0]

func _on_mob_timer_timeout():
	if mob_scene == null:
		return
	# Itérer sur chaque salle
	for i in range(2, 6):
		var salle = get_node("salle" + str(i))
		if salle != null:
			var mob_spawns = salle.get_node("MobSpawns")
			if mob_spawns != null:
				# Compter le nombre de mobs existants dans la salle
				var existing_mobs = salle.get_tree().get_nodes_in_group("mobs").size()
				# Calculer combien de nouveaux mobs doivent être créés
				var new_mobs_to_create = mob_max_par_salle - existing_mobs
				# Créer des mobs jusqu'à atteindre le maximum par salle
				while new_mobs_to_create > 0 and total_mobs_created[i-2] < mob_max_par_salle:
					var mob = mob_scene.instantiate()
					# Choisissez un point de spawn aléatoire parmi les enfants de "MobSpawns"
					var mob_spawn_location = mob_spawns.get_child(randi() % mob_spawns.get_child_count())
					mob.global_position = mob_spawn_location.global_position
					add_child(mob)
					# Décrémentez le compteur de mobs
					new_mobs_to_create -= 1
					total_mobs_created[i-2] += 1





func mob_defeated():
	var salle_name = salle_en_cours
	mob_restant -= 1
	$player.ressources += int(randf_range(20, 100))
	get_node("/root/main/HUD").degats_info_inventaire($player.degats,$player.ressources,$player.nom_arme)
	if mob_restant <= 0:
		$HUD.show_message("Vous avez vaincu tous les mobs !")
		# Si on est à la salle5 et qu'il n'y a plus de mob alors $HUD/boss_vie.show()
		if salle_name == "salle5":
			$HUD/boss_vie.show()
			$music.stop()
			$attaque_de_boss.play()
		# Ouvrir les portes de la salle actuelle
		open_doors(salle_name)
		var mobs = get_tree().get_nodes_in_group("mobs")
		mob_restant = mob_start
		compte_salle += 1
		salle_en_cours = "salle" + str(compte_salle)
		


func boss_defeated():
	$attaque_de_boss.stop()
	$HUD.show_message("Vous avez vaincu le boss !")
	$HUD/boss_vie.hide()
	$victoire.play()
	$HUD/fin_menu.show()

func open_doors(salle_name):
	#regen de la vie
	$player.life+=1
	$HUD.update_life($player.life,$player.life_total)
	$ouverturePorte.play()
	# Obtenez la salle spécifiée
	var salle = get_node(salle_name)
	if salle != null:
		# Itérer sur chaque porte dans la salle
		for door in salle.get_node("door_sorties").get_children():
			if door.is_in_group("doors"):
				door.open()  # Ouvre la porte

func spawn_marchand():
	var marchand_pos = get_node("salle_marchand/marchand_position")
	var marchand = marchand_scene.instantiate()
	marchand.global_position = marchand_pos.global_position
	print(marchand.global_position)
	add_child(marchand)
	
	
