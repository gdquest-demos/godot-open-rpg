extends CanvasLayer

onready var shop_menu = $ShopMenu


func _ready():
	shop_menu.connect('closed', self, 'remove_child', [shop_menu])
	remove_child(shop_menu)


func initialize(player):
	$PlayerGUI.initialize(player.get_health_node(), player.get_purse())
	$PauseMenu.initialize(player)


func _on_Level_loaded(level):
	var tree = get_tree()
	for seller in tree.get_nodes_in_group('seller'):
		seller.connect('shop_open_requested', self, 'shop_open')

	var monsters = tree.get_nodes_in_group('monster')
	var spawners = tree.get_nodes_in_group('monster_spawner')
	$LifebarsBuilder.initialize(monsters, spawners)


func shop_open(seller_shop, buyer):
	add_child(shop_menu)
	shop_menu.open(seller_shop, buyer)
