extends CharacterBody2D


@onready var player = get_node("/root/main/player")

func _physics_process(delta):
	# Utilisez la constante SPEED du noeud player
	var speed = player.SPEED
	# Déplacez le sort
	velocity = velocity.normalized() * speed
	position += velocity * delta

func _ready():
	# Ajoutez cette instance de spell au groupe "spells"
	add_to_group("spells")

func _on_visible_on_screen_enabler_2d_screen_exited():
	queue_free()


func _on_area_2d_area_entered(area):
	if area.is_in_group("player"):
		queue_free()  # Faites disparaître le sort s'il touche le joueur
	if area.is_in_group("mobs"):
		area.take_damage(1)
		queue_free()  # Faites disparaître le sort s'il touche le joueur
	if area.is_in_group("boss"):
		area.take_damage(1)
		queue_free()  # Faites disparaître le sort s'il touche le joueur



func _on_area_2d_body_entered(body):
	if body.is_in_group("walls"):  # Supposons que vos murs sont dans le groupe "walls"
		queue_free()  # Supprime le sort s'il touche un mur
	if body.is_in_group("player"):
		queue_free()  # Faites disparaître le sort s'il touche le joueur
		if player.visible:
			player.emit_signal("hit")
