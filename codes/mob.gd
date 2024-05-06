extends CharacterBody2D

# Vitesse du sort
@export var spell_speed: int = 300

# Référence vers la scène du sort
@export var spell_scene: PackedScene

# Vitesse de lancement des sorts (en secondes)
@export var spell_cast_rate: float = 1.5

# Temps restant avant le prochain lancement de sort
var spell_cast_timer: float = 0.5

@export var life = 2
var life_total_mob = life
var salle_en_cours

func _ready():
	# Chargez la scène du sort
	spell_scene = load("res://scenes/spell.tscn")
	add_to_group("mobs")

func _process(delta):
	# Diminuez le timer de lancement de sort
	spell_cast_timer -= delta

	# Si le timer atteint zéro, lancez un sort
	if spell_cast_timer <= 0:
		cast_spell()
		spell_cast_timer = spell_cast_rate

func cast_spell():
	# Instanciez le sort
	var spell = spell_scene.instantiate()

	# Définissez la position du sort sur la position du mob
	spell.position = position

	# Ajoutez le sort à la scène
	get_parent().add_child(spell)

	# Lancez le sort vers le joueur
	var player = get_node("/root/main/player")
	var direction = (player.position - position).normalized()
	spell.velocity = direction * spell_speed

func take_damage(amount):
	life -= amount
	life = max(life, 0)
	life_total_mob = max(life_total_mob, 1)
	$barre_de_vie_mobs.value = (100 * life / life_total_mob)
	if life == 0:
		get_node("/root/main").mob_defeated()
		queue_free()  # Détruit le mob
