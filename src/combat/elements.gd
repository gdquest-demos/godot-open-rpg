class_name Elements extends RefCounted

#enum Types { NONE, BUG, BREAK, SEEK, VOID, STATIC, CONTROL, GUARD, EXCEPTION }
enum Types { NONE, BUG, BREAK, SEEK }

## Elements may have an advantage against others (attack power, chance-to-hit, etc.). These
## relationships are stored in the following dictionary.
## Dictionary values are the elements against which the dictionary key is strong. The weak elements
## are stored as a list. An empty list indicates that the element has no advantage against others.
const ADVANTAGES: = {
	Types.NONE: [],
	Types.BUG: [Types.BREAK],
	Types.BREAK: [Types.NONE, Types.SEEK],
	Types.SEEK: [Types.BUG],
}
