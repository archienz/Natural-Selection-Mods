#include <amxmodx>
#include <engine>
#include <ns>

public plugin_init()
{
	register_plugin("Disable MT and SoF", "1.0", "x5 and Peachy")
	if (ns_is_combat())
	{
		register_impulse(33, "disableWallhack")
		register_impulse(112, "disableWallhack")
	}
}

public disableWallhack(id)
{
	client_print(id, print_chat, "Motion Tracking and Scent of Fear are Disabled.")
	return PLUGIN_HANDLED
}
