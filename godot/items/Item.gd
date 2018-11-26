extends Resource
class_name Item

enum ItemCategory { CONSUMABLE, MATERIAL, KEY, EQUIPMENT }

export var name : String
# menu description
export var description : String
# key items are used typically as flags or one time use items in RPGs
# if an item is a key item, the inventory will detect and only allow possession
# of one of that type of item.
export var is_key : bool = false
# sell value of the item
export(int, 0, 999) var msrp
