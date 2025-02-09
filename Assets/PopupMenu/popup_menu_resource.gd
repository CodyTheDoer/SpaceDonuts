extends Resource
class_name SoilInteractionLabels

const CANCEL = 0
const TILL = 1
const GRASS = 2
const ROCK = 3
const DIRT = 4
const PLANT = 5

var label = {
	0: "Cancel",
	1: "Till",
	2: "Grass",
	3: "Rock",
	4: "Dirt",
	5: "Plant",
}

func get_label_array():
	var label_array = [
		label[CANCEL],
		label[TILL],
		label[GRASS],
		label[ROCK],
		label[DIRT],
		label[PLANT]
	]
	return label_array
