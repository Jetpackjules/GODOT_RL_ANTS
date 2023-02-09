@tool
extends Node2D

@export var centered: bool : get = centered_get, set = centered_set
# export var axis_snap: bool : get = axis_snap_get, set = axis_snap_set

@export var num_sides = 3 : get = num_sides_get, set = num_sides_set # (int, 3, 100)
@export var size: float = 64 : get = size_get, set = size_set
@export var polygon_color: Color = Color(36.0/256.0,138.0/256.0,199.0/256.0) : get = polygon_color_get, set = polygon_color_set
@export var polygon_texture: Texture2D : get = polygon_texture_get, set = polygon_texture_set

@export var border_size: float = 4 : get = border_size_get, set = border_size_set
@export var border_color: Color = Color(0,0,0) : get = border_color_get, set = border_color_set

@export var polygon_rotation : get = polygon_rotation_get, set = polygon_rotation_set # (float, -360, 360)

# Configure a collision shape if the parent is a CollisionObject2D.
# e.g. CharacterBody2D, RigidyBody2D, Area2D, or StaticBody2D
@export var collision_shape: bool = true : get = parent_collision_shape_get, set = parent_collision_shape_set

var DEBUG_NONE = -9999
var DEBUG_INFO = 0
var DEBUG_VERBOSE = 1

var LOG_LEVEL = DEBUG_NONE

func vlog(arg1, arg2 = "", arg3 = ""):
	if LOG_LEVEL >= DEBUG_VERBOSE:
		print(arg1,arg2,arg3)

func dlog(arg1, arg2 = "", arg3 = ""):
	if LOG_LEVEL >= DEBUG_INFO:
		print(arg1,arg2,arg3)

func poly_offset():
	if !centered:
		return Vector2(size/2 + border_size, size/2 + border_size)
	return Vector2(0,0)

func poly_pts(p_size):
	p_size /= 2
	var th = 2*PI/num_sides
	var pts = PackedVector2Array()
	var unchecked = poly_offset()
	vlog("unchecked: ", unchecked)
	for i in range(num_sides):
		pts.append(unchecked + polar2cartesian(p_size, deg_to_rad(-90+polygon_rotation) + i*th))
	return pts

func draw_poly(p_size, p_color, p_texture):
	var pts = poly_pts(p_size)

	var uvs = PackedVector2Array()    
	if p_texture:
		var ts = polygon_texture.get_size()
		vlog(" ts: ", ts)
		for pt in pts:
			uvs.append((pt - poly_offset() + Vector2(p_size, p_size)) / ts)

	vlog("pts: ", pts)
	vlog("uvs: ", uvs)
	draw_colored_polygon(pts, p_color, uvs, p_texture, polygon_texture, true)
	
func _notification(what):
	if what == NOTIFICATION_DRAW:
		if border_size > 0:
			draw_poly(size + border_size, border_color, null)
		draw_poly(size, polygon_color, polygon_texture)
	if what == NOTIFICATION_READY:
		vlog("enter tree")
		if !collision_shape || Engine.is_editor_hint():
			vlog("editor mode: Not adding collision")
			return
			
		var p = get_parent();
		if p == null:
			vlog("no parent")
			return
		
		if p is CollisionObject2D:
			vlog("parent is CollisionObject2D")
			var shape = ConvexPolygonShape2D.new()
			shape.points = poly_pts(size + border_size)
			vlog("shape.points = ", shape.points)
			var col = CollisionShape2D.new()
			col.shape = shape
			p.call_deferred("add_child", col)


func parent_collision_shape_set(p_val):
	collision_shape = p_val

func parent_collision_shape_get():
	return collision_shape

func polygon_texture_set(texture):
	polygon_texture = texture
	update()

func polygon_texture_get():
	return polygon_texture

func centered_set(val):
	centered = val
	update()

func centered_get():
	return centered

func border_color_set(color):
	border_color = color
	update()

func border_color_get():
	return border_color

func polygon_color_set(color):
	polygon_color = color
	update()

func polygon_color_get():
	return polygon_color

func polygon_rotation_set(rot):
	polygon_rotation = rot
	update()

func polygon_rotation_get():
	return polygon_rotation

func border_size_set(size):
	border_size = size
	update()

func border_size_get():
	return border_size

func num_sides_set(sides):
	num_sides = sides
	update()

func num_sides_get():
	return num_sides

func size_set(s):
	size = s
	update()

func size_get():
	return size

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
