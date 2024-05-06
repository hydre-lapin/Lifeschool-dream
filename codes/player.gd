extends CharacterBody2D


signal hit
const SPEED = 300.0
var ATTACK_RANGE = 150
var degats = 1
var ressources = 0
var nom_arme = "epee classique"
var infos_armes = {
"epee inhabituelle" : [1.25,225],
"epee rare" : [1.5,300],
"epee epique" : [1.75,350],
"epee legendaire" : [2,500],
"epee absolu" : [2.5,750]}

@onready var hud = get_node("/root/main/HUD")
@onready var main = get_node("/root/main")
@onready var menu = get_node("/root/main/HUD/pause_menu")
@onready var inventaire = get_node("/root/main/HUD/inventaire")
@onready var marchand = get_node("/root/main/HUD/marchand")
@onready var fin = get_node("/root/main/HUD/fin_menu")
@onready var affichage_start = get_node("/root/main/HUD/titre")
# Get the gravity from the project settings to be synced with RigidBody nodes.
var screen_size
var life
var life_total
var cooldown_effect = false

func _ready():
	screen_size = get_viewport_rect().size
	hide()
	life = 10
	life_total = life
	add_to_group("player")
	get_node("/root/main/HUD").degats_info_inventaire(degats,ressources,nom_arme)
	var keys = infos_armes.keys()
	var selected_keys = []
	for i in range(3):
		var random_index = randi() % keys.size()
		var key = keys[random_index]
		selected_keys.append(key)
		keys.remove_at(random_index)
	selected_keys.sort()
	get_node("/root/main/HUD").choix_marchandises(infos_armes, selected_keys[0],selected_keys[1],selected_keys[2])

func _physics_process(delta):

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction_x = Input.get_axis("move_left", "move_right")
	if direction_x:
		velocity.x = direction_x * SPEED
		if velocity.x != 0:
			$AnimatedSprite2D.animation = "walk"
			$AnimatedSprite2D.flip_h = velocity.x <0
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	var direction_y = Input.get_axis("move_up", "move_down")
	if direction_y:
		velocity.y = direction_y * SPEED
		if velocity.y != 0:
			$AnimatedSprite2D.animation = "up"
	else:
		velocity.y = move_toward(velocity.y,0,SPEED)

	move_and_slide()
	
	if Input.is_action_just_pressed("attack") and !cooldown_effect and !menu.visible and !inventaire.visible and !marchand.visible and !fin.visible:
	# Infligez des dégâts aux mobs
		damage_mobs()
		#bruit d'épée
		$coup.play()
		$cooldown_attack.start()
		cooldown_effect = true
		$cooldown_player.show()
		
	var commerce = get_tree().get_nodes_in_group("marchand")
	if Input.is_action_just_pressed("marchand"):
		if commerce.size() > 0:
			var distance_to_marchand = position.distance_to(commerce[0].global_position)
			if distance_to_marchand < ATTACK_RANGE:
				get_node("/root/main/HUD").affiche_commerce()


func damage_mobs():
	# Obtenez tous les mobs dans la scène
	var mobs = get_tree().get_nodes_in_group("mobs")
	var boss = get_tree().get_nodes_in_group("boss")
	for mob in mobs:
		# Vérifiez si le mob est à portée de l'attaque
		var distance_to_mob = position.distance_to(mob.position)
		if distance_to_mob < ATTACK_RANGE:
			# Infligez des dégâts au mob
			mob.take_damage(degats)
	for b in boss:
		# Vérifiez si le boss est à portée de l'attaque
		var distance_to_boss = position.distance_to(b.position)
		if distance_to_boss < ATTACK_RANGE:
			# Infligez des dégâts au boss
			b.take_damage(degats)

func start(pos):
	position = pos
	$CollisionShape2D.disabled = false
	show()


func _on_hit():
	if life != 0 and (!menu.visible or !inventaire.visible):
		life -=1
		hud.update_life(life,life_total)
	if life == 0 and !affichage_start.visible:
		main.game_over()


func _on_area_2d_body_entered(body):
	if body.is_in_group("spells"):
		if life > 0 :
			emit_signal("hit")


func _on_cooldown_attack_timeout():
	cooldown_effect = false
	$cooldown_player.hide()

func changer_arme(arme,prix,bouton):
	if int(prix) > ressources:
		get_node("/root/main/HUD").show_message("Vous ne pouvez pas acheter")
		return
	nom_arme = arme
	degats = float(infos_armes[arme][0])
	ressources -= int(prix)
	get_node("/root/main/HUD").degats_info_inventaire(degats,ressources,nom_arme)
	bouton.hide()
