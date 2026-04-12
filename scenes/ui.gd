extends CanvasLayer

@onready var curtain_master = $Curtains

@onready var left_body = $Curtains/LBody
@onready var left_edge = $Curtains/LEdge
@onready var right_body = $Curtains/RBody
@onready var right_edge = $Curtains/REdge

var start_position_y: float = -1080.0 
var end_position_y: float = 0.0       

func _ready():
	self.layer = 100 
	_reset_curtains()

func transition_to_scene(scene_path: String):
	await drop_curtain_choppy()
	await close_curtains_choppy()
	get_tree().change_scene_to_file(scene_path)
	
	await get_tree().create_timer(2.0).timeout
	
	await open_curtains_choppy()
	await raise_curtain_choppy()

func drop_curtain_choppy():
	var total_time: float = 1.5
	var steps: int = 15 
	var delay = total_time / float(steps)
	for i in range(1, steps + 1):
		curtain_master.position.y = lerp(start_position_y, end_position_y, float(i) / steps)
		await get_tree().create_timer(delay).timeout

func close_curtains_choppy():
	var total_time: float = 3.0
	var steps: int = 50 
	var delay = total_time / float(steps)
	var move_dist: float = 795.0
	
	var lb_s = left_body.position.x
	var le_s = left_edge.position.x
	var rb_s = right_body.position.x
	var re_s = right_edge.position.x
	
	for i in range(1, steps + 1):
		var p = float(i) / steps
		left_body.position.x = lerp(lb_s, lb_s + move_dist, p)
		left_edge.position.x = lerp(le_s, le_s + move_dist, p)
		right_body.position.x = lerp(rb_s, rb_s - move_dist, p)
		right_edge.position.x = lerp(re_s, re_s - move_dist, p)
		await get_tree().create_timer(delay).timeout

func open_curtains_choppy():
	var total_time: float = 3.0
	var steps: int = 50 
	var delay = total_time / float(steps)
	var move_dist: float = 795.0
	
	var lb_s = left_body.position.x
	var le_s = left_edge.position.x
	var rb_s = right_body.position.x
	var re_s = right_edge.position.x
	
	for i in range(1, steps + 1):
		var p = float(i) / steps
		left_body.position.x = lerp(lb_s, lb_s - move_dist, p)
		left_edge.position.x = lerp(le_s, le_s - move_dist, p)
		right_body.position.x = lerp(rb_s, rb_s + move_dist, p)
		right_edge.position.x = lerp(re_s, re_s + move_dist, p)
		await get_tree().create_timer(delay).timeout

func raise_curtain_choppy():
	var total_time: float = 1.5
	var steps: int = 15 
	var delay = total_time / float(steps)
	for i in range(1, steps + 1):
		curtain_master.position.y = lerp(end_position_y, start_position_y, float(i) / steps)
		await get_tree().create_timer(delay).timeout

func _reset_curtains():
	curtain_master.position.y = start_position_y
	left_body.position.x = -795.0
	left_edge.position.x = 0.0
	right_body.position.x = 795.0
	right_edge.position.x = 0.0
