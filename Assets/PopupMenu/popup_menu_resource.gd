extends Resource
class_name SoilInteractionLabels

const CANCEL = 0
const TILL = 1
const GRASS = 2
const ROCK = 3
const DIRT = 4
const PLANT = 5
const EXTRA1 = 6
const EXTRA2 = 7

var label = {
	0: "Cancel",
	1: "Till",
	2: "Grass",
	3: "Rock",
	4: "Dirt",
	5: "Plant",
	6: "Extra1",
	7: "Extra2",
}

func get_label_array():
	var label_array = [
		label[CANCEL],
		label[TILL],
		label[GRASS],
		label[ROCK],
		label[DIRT],
		label[PLANT],
		label[EXTRA1],
		label[EXTRA2],
	]
	return label_array
