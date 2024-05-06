extends Camera2D

# Le nœud du personnage à suivre
@export var tilemap : TileMap
var character

func _ready():
	# Obtenez une référence au nœud du personnage
	character = get_tree().get_nodes_in_group("player")[0]
	var MapRect = tilemap.get_used_rect()
	var tileSize = tilemap.cell_quadrant_size
	var worldSizeInPixel = MapRect.size * tileSize

func _process(delta):
	if character != null:
		# Interpolez la position de la caméra pour une transition plus fluide
		var target_position = character.global_position
		self.global_position = self.global_position.lerp(target_position, 0.1)
