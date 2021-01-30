extends Node

static func fillProps(folder, tab):
	var file = File.new()
	var dict
	var path = folder + tab + ".csv"
	if file.open(path, file.READ) == OK:
		#Game.debugMessage(Game.CAT.FILE, "Found file " + tab)
		dict = Data.parseCSV(path, file)
	else:
		null#Game.reportError(Game.CAT.FILE, "Error reading file %s" % path)
	file.close()
	return dict

static func filter(d, prop, value, multi, asDict):
	var res = {} # Only one of these two will be returned
	var arr = [] # Unless multi is false, in which case neither will be
	for row in d.values():
		var matches = true
		for i in range(0, len(prop)):
			if Util.isnull(row[prop[i]]) and Util.isnull(value[i]):
				pass # Two nulls are equal
			elif row[prop[i]] != value[i]:
				matches = false
		if (matches):
			if (!multi): return row
			res[row.ID] = row
			arr.append(row)
	if (asDict): return res.values()
	else: return arr

static func parseCSV(path, file):
	var props = []
	var defaults = []
	file.seek(0)
	var list = {}
	var line_count = 0
	while !file.eof_reached():
		var line = file.get_csv_line()
		line_count += 1 # Human-readable, so first line is 1
		if len(props) == 0: # First (header) row
			props = line
		elif len(defaults) == 0 and line[0] == "DEFAULT":
			defaults = line
		elif len(line) >= len(props):
			var dict = {}
			for i in range(0, props.size()):
				if len(defaults) > 0 and Util.isnull(line[i]):
					dict[props[i]] = defaults[i]
				else:
					dict[props[i]] = line[i]
				pass
			list[list.size()] = dict
		elif len(line) == 1 and len(line[0]) == 0:
			pass#Game.reportError(Game.CAT.FILE, "Line %s of %s could not be read" % [line_count, path])
	return list

static func saveCSV(folder, fdata, filename, arr):
	#Game.debugMessage(Game.CAT.SAVE, "Saving file: %s" % [fdata + filename])
	var file = File.new()
	var count = 0
	if file.open(folder + fdata + filename, file.WRITE) == OK:
		var dataRow : PoolStringArray = []
		for i in range(arr.size()):
			var cell = arr[i]
			dataRow.push_back(cell)
		file.store_line(dataRow.join(","))
	file.close()
	#Game.verboseMessage(Game.CAT.SAVE, "Wrote %s lines" % [count])


static func getImage(folder, file, ext):
	var img = Image.new()
	var fname = folder + file + ext
	var f = File.new()
	if f.open(fname, f.READ) == OK:
		img.load(fname)
	else:
		pass#Game.reportError(Game.CAT.FILE, "Error reading image file " + fname)
	f.close()
	return img

# https://godotengine.org/qa/30210/how-do-load-resource-works
static func getTexture(folder, file, ext):
	var img = Data.getImage(folder, file, ext)
	var tex = ImageTexture.new()
	tex.create_from_image(img)
	return tex

static func getFont(folder, file, ext):
	var fname = folder + file + ext
	var font = DynamicFont.new()
	# Report error
	var f = File.new()
	if f.open(fname, f.READ) == OK:
		font.font_data = load(fname)
	else:
		pass#Game.reportWarning(Game.CAT.FILE, "Error reading font file " + fname)
	return font

# https://github.com/godotengine/godot/issues/17748
static func getAudio(folder, file, ext):
	var fname = folder + file + ext
	var stream = AudioStreamOGGVorbis.new()
	var afile = File.new()
	if afile.open(fname, File.READ) == OK:
		var bytes = afile.get_buffer(afile.get_len())
		stream.data = bytes
	else:
		pass#Game.reportWarning(Game.CAT.FILE, "Error reading sound file " + fname)
	afile.close()
	return stream

# http://godotengine.org/qa/5175/how-to-get-all-the-files-inside-a-folder
func getFileList(path):
	var list = []
	var dir = Directory.new()
	if dir.dir_exists(path):
		dir.open(path)
		dir.list_dir_begin()
		while true:
			var file = dir.get_next()
			if file == "":
				break
			elif not file.begins_with(".") and not file.begins_with("_") and dir.current_is_dir():
				list.append(file)
		dir.list_dir_end()
	return list

func getFileAccessTime(fname):
	var file = File.new()
	file.open(fname, file.READ)
	return file.get_modified_time(fname)
