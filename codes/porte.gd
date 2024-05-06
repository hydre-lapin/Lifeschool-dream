extends StaticBody2D

# Chargement du sprite de la porte
var door_closed_sprite = load("res://art/porte1.png")
var door_open_sprite = load("res://art/porte2.png")

# Création du sprite de la porte
var sprite = Sprite2D.new()

func _ready():
	# Ajout du sprite à la porte
	sprite.texture = door_closed_sprite
	add_child(sprite)

	# Ajout d'une zone de collision à la porte
	var collision_shape = CollisionShape2D.new()
	var rectangle_shape = RectangleShape2D.new()
	rectangle_shape.extents = sprite.texture.get_size() / 2
	collision_shape.shape = rectangle_shape
	add_child(collision_shape)

	# Assurez-vous que la zone de collision est active
	collision_shape.disabled = false

	# Ajoutez cette porte au groupe "doors"
	add_to_group("doors")

func open():
	var collision_shape = get_node("CollisionShape2D")
	var area2d = get_node("Area2D")
	sprite.texture = door_open_sprite  # Change l'apparence de la porte

	# Désactivez le CollisionShape2D
	collision_shape.disabled = true

	# Désactivez également le CollisionShape2D qui est enfant de Area2D
	var area2d_collision_shape = get_node("Area2D/CollisionShape2D")
	area2d_collision_shape.disabled = true
	
	# Désactivez le StaticBody2D
	self.collision_layer = 0
	self.collision_mask = 0
	
	# Désactivez Area2D
	area2d.collision_mask = 0
	area2d.collision_layer = 0

	await get_tree().process_frame  # Attend la prochaine mise à jour de la physique


func fermer():
	var collision_shape = get_node("CollisionShape2D")
	var area2d = get_node("Area2D")
	sprite.texture = door_closed_sprite  # Change l'apparence de la porte

	# Désactivez le CollisionShape2D
	collision_shape.disabled = false

	# Désactivez également le CollisionShape2D qui est enfant de Area2D
	var area2d_collision_shape = get_node("Area2D/CollisionShape2D")
	area2d_collision_shape.disabled = false
	
	# Désactivez le StaticBody2D
	self.collision_layer = 1
	self.collision_mask = 1
	
	# Désactivez Area2D
	area2d.collision_mask = 1
	area2d.collision_layer = 1

	await get_tree().process_frame  # Attend la prochaine mise à jour de la physique
