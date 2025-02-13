extends Resource
class_name SoilInteractionLabels

const CANCEL = 0
const TILL = 1
const GRASS = 2
const ROCK = 3
const DIRT = 4
const FLOWERS = 5
const EXTRA1 = 6
const EXTRA2 = 7

var label = {
	0: "CANCEL",
	1: "TILL",
	2: "GRASS",
	3: "ROCK",
	4: "DIRT",
	5: "FLOWERS",
	6: "EXTRA1",
	7: "EXTRA2",
}

func get_label_array():
	var label_array = [
		label[CANCEL],
		label[TILL],
		label[GRASS],
		label[ROCK],
		label[DIRT],
		label[FLOWERS],
		label[EXTRA1],
		label[EXTRA2],
	]
	return label_array
