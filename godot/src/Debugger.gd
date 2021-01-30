extends Control
class_name Debugger
var loglist

enum MODES { PLAY = 0, DEBUG }
var mode = MODES.PLAY
var fast_forward = 1.0
var logTimer

enum CAT { MAP = 0, FILE, BATTLE, DEBUG }
const category = { CAT.MAP: "Map", CAT.FILE: "File", CAT.BATTLE: "Battle", CAT.DEBUG: "Debug" }

func _ready():
	verbosity = LEVELS.ERROR
	loglist = $LogList#get_node("/root/DebugMode/Debugger/LogList")
	template = $LogList/LogTemplate
	# Filter buttons
	for f in category.values():
		var btn = $LogList/Filter/FilterButton.duplicate()
		btn.visible = true
		btn.text = f
		$LogList/Filter.add_child(btn)
	# Message log timer
	logTimer = Timer.new()
	logTimer.set_wait_time(0.1)
	logTimer.connect("timeout", self, "_on_timer_timeout") 
	add_child(logTimer)
	logTimer.start()

func _input(event):
	if event.is_action_pressed("ui_debug_mode"):
		toggleDebug()
	if mode == MODES.DEBUG:
		if event.is_action_pressed("ui_speed_up"):
			var sp = speed + 1
			if sp >= len(SPEEDS): sp = len(SPEEDS) - 1
			changeSpeed(sp)
			pass
		elif event.is_action_pressed("ui_speed_down"):
			var sp = speed - 1
			if sp < 0: sp = 0
			changeSpeed(sp)
		elif event is InputEventMouseButton and event.doubleclick:
			#if event.button_index == BUTTON_LEFT:
			var posn = get_viewport().get_mouse_position()
			posn *= Vector2(100.0, 100.0)# / getScreenSize()
			verboseMessage(CAT.DEBUG, "Clicked (%.1f%%, %.1f%%)" % [posn.x, posn.y])

func toggleDebug():
	mode += 1
	mode = mode % MODES.size()
	
	match mode:
		MODES.PLAY:
			debugSettings(false, false, LEVELS.MESSAGE)
			speed_menu_open = false
			drawSpeedMenu()
		MODES.DEBUG:
			debugSettings(true, true, LEVELS.VERBOSE)
			requestReload()

func debugSettings(viewLog : bool, debugMovement : bool, v):
	visible = viewLog
	verbosity = v
	var alpha =  int(debugMovement) * 0.5
	#Game.sceneNode.walkmap.modulate = Color(1,1,1, alpha)
	debugMessage(CAT.DEBUG, "Set verbosity to %s and ff to %s" % [verbosity, fast_forward])

func getFF():
	return fast_forward

# ===== Errors ==========================================================

var error = null
var debugLog = []
var verbosity
enum LEVELS { UNRECOVERABLE, ERROR, WARNING, MESSAGE, VERBOSE }
const PREFIX = { LEVELS.UNRECOVERABLE: "!!! ERROR !!! ", LEVELS.ERROR: " !! ERROR !!  ",
	LEVELS.WARNING: " ! warning !  ", LEVELS.MESSAGE: "              ",
	LEVELS.VERBOSE: "              "}
func unrecoverableError(cat, s):
	error = s
	logMessage(cat, s, LEVELS.ERROR)
func reportError(cat, s):
	logMessage(cat, s, LEVELS.ERROR)
func reportWarning(cat, s):
	logMessage(cat, s, LEVELS.WARNING)
func debugMessage(cat, s):
	logMessage(cat, s, LEVELS.MESSAGE)
func verboseMessage(cat, s):
	logMessage(cat, s, LEVELS.VERBOSE)

func logMessage(cat, s, level = LEVELS.MESSAGE):
	debugLog.push_back(LogData.new(cat, s, level))
	requestReload()
	#if level <= LEVELS.WARNING:
	#	print(Util.pad(category[cat], ' ', 8, false) + PREFIX[level] + s)
	print(category[cat] + "\t" + PREFIX[level] + s)

func allGood():
	return true#Util.isnull(error)

# ===== Message Log =====================================================

var isDirty = false # In order not to overwhelm the system, we refresh on a timer
# when the log has new information, and not every time a new message is logged.
func requestReload():
	isDirty = true

func _on_timer_timeout():
	reload()
	isDirty = false

var template
enum TEMPLATE { DATE = 0, LEVEL, CAT, TEXT }
var LOG_SIZE = 30
var currCat = 0
func reload():
	if mode == MODES.DEBUG and visible:
		# First child is the invisible template; clear everything else and then start copying it
		while loglist.get_child_count() > 1:
			loglist.remove_child(loglist.get_child(1))
		var i = debugLog.size() - 1
		var count = 0
		while count < LOG_SIZE and i >= 0:
			var l = debugLog[i]
			if showingCat(l.category) and l.level <= verbosity:
				var t = template.duplicate()
				labelCell(t, TEMPLATE.TEXT, l.message)
				labelCell(t, TEMPLATE.DATE, Util.getStringTime(l.date))
				labelCell(t, TEMPLATE.LEVEL, PREFIX[l.level])
				labelCell(t, TEMPLATE.CAT, category[l.category])
				t.visible = true
				loglist.add_child(t)
				count += 1
			i -= 1
		get_parent().emit_signal("draw")
	isDirty = false

func showingCat(c):
	var btn = $LogList/Filter.get_children()[c + 1]
	return btn.pressed

func labelCell(t, posn, data):
	var lbl = t.get_child(posn)
	lbl.text = str(data)
	if data == PREFIX[LEVELS.UNRECOVERABLE]:
		lbl.set("custom_colors/font_color", "#ff0000")
	if data == PREFIX[LEVELS.ERROR]:
		lbl.set("custom_colors/font_color", "#dd5500")
	if data == PREFIX[LEVELS.WARNING]:
		lbl.set("custom_colors/font_color", "#ffbe00")
	#lbl.rect_position.y = 0
	#lbl.margin_top = 0

class LogData:
	extends Node
	var date : Dictionary
	var level : int
	var category : int
	var message : String
	func _init(cat, s, l):
		date = OS.get_time()
		level = l
		category = cat
		message = s

# ===== Button Events ===================================================

func _on_FilterButton_toggled(_button_pressed):
	requestReload()

var speed_menu_open = false
enum SPEEDS { SLOW = 0, NORMAL, FAST, SUPER }
const ffspeed = [ 0.2, 1.0, 5.0, 20.0 ]
var speed = SPEEDS.NORMAL
func _on_SpeedButton_pressed():
	speed_menu_open = !speed_menu_open
	drawSpeedMenu()

func drawSpeedMenu():
	pass
	#for s in SPEEDS.values():
	#	var btn = $Buttons/Speed.get_child(s+2)
	#	btn.visible = speed_menu_open

func _on_SpeedSlow_pressed():
	changeSpeed(SPEEDS.SLOW)

func _on_Speedx1_pressed():
	changeSpeed(SPEEDS.NORMAL)

func _on_Speedx5_pressed():
	changeSpeed(SPEEDS.FAST)

func _on_Speedx20_pressed():
	changeSpeed(SPEEDS.SUPER)

func changeSpeed(sp):
	speed = sp
	fast_forward = ffspeed[sp]
	$Buttons/Speed/SpeedLabel.text = "Speed: x" + str(fast_forward)
	speed_menu_open = false
	drawSpeedMenu()
