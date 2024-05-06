extends CharacterBody2D

@onready var vie_du_boss = get_node("/root/main/HUD/boss_vie/barre_de_vie_boss")
@onready var etiquette_nom = get_node("/root/main/HUD/boss_vie/nom_du_boss")

# Vitesse du sort
@export var spell1_speed: int = 300
@export var spell2_speed: int = 200
@export var spell3_speed: int = 100

# Référence vers la scène du sort
@export var spell_scene: PackedScene

# Vitesse de lancement des sorts (en secondes)
@export var spell1_cast_rate: float = 1.5
@export var spell2_cast_rate: float = 10
@export var spell3_cast_rate: float = 22

# Temps restant avant le prochain lancement de sort
var spell1_cast_timer: float = 1
var spell2_cast_timer: float = 10
var spell3_cast_timer: float = 22

@export var life = 20
var life_total_boss = life
var nom_du_boss = "Le Maître des Érudits"

func _ready():
	# Chargez la scène du sort
	spell_scene = load("res://scenes/spell.tscn")
	add_to_group("boss")
	etiquette_nom.text = nom_du_boss
	$attaque.hide()

func _process(delta):
	# Diminuez le timer de lancement de sort
	spell1_cast_timer -= delta
	spell2_cast_timer -= delta
	spell3_cast_timer -= delta
	
	if spell2_cast_timer <= 1.5:
		$attaque.show()
		$attaque/WarningBossZone.show()
	if spell3_cast_timer <= 1.5:
		$attaque.show()
		$attaque/WarningBossWall.show()
	# Si le timer atteint zéro, lancez un sort
	if spell1_cast_timer <= 0:
		cast_spell1()
		spell1_cast_timer = spell1_cast_rate
	if spell2_cast_timer <= 0:
		cast_spell2()
		spell2_cast_timer = spell2_cast_rate
		$attaque/WarningBossZone.hide()
	if spell3_cast_timer <= 0:
		cast_spell3()
		spell3_cast_timer = spell3_cast_rate
		$attaque/WarningBossWall.hide()

func cast_spell1():
	# Instanciez le sort
	var spell = spell_scene.instantiate()

	# Définissez la position du sort sur la position du mob
	spell.position = position

	# Ajoutez le sort à la scène
	get_parent().add_child(spell)

	# Lancez le sort vers le joueur
	var player = get_node("/root/main/player")
	var direction = (player.position - position).normalized()
	spell.velocity = direction * spell1_speed

func cast_spell2():
	for i in range(8):
		# Instanciez le sort
		var spell = spell_scene.instantiate()

		# Définissez la position du sort sur la position du mob
		spell.position = position

		# Ajoutez le sort à la scène
		get_parent().add_child(spell)

		# Lancez le sort dans une direction spécifique
		var angle = i * 45.0
		var direction = Vector2(cos(angle), sin(angle))
		spell.velocity = direction * spell2_speed


func cast_spell3():
	var player = get_node("/root/main/player")
	var direction_to_player = (player.position - position).normalized()
	var perpendicular = Vector2(-direction_to_player.y, direction_to_player.x)  # Vecteur perpendiculaire à la direction vers le joueur
	for i in range(8):
		# Instanciez le sort
		var spell = spell_scene.instantiate()

		# Définissez la position du sort sur la position du mob
		spell.position = position + perpendicular * (i - 4) * 50  # Décalez légèrement la position de chaque sort

		# Ajoutez le sort à la scène
		get_parent().add_child(spell)

		# Lancez le sort vers le joueur
		spell.velocity = direction_to_player * spell1_speed


func take_damage(amount):
	life -= amount
	life = max(life, 0)
	life_total_boss = max(life_total_boss, 1)
	vie_du_boss.value = (100 * life / life_total_boss)
	if life <= 0:
		get_node("/root/main").boss_defeated()
		queue_free()  # Détruit le mob
