/**********************
*     BOB_SLAYER      *
**********************/

/*
 * 1.2 (by skulk_on_dope alias Morpheus)
 *     - Updated to use ns and engine module
 *     - made comm protection optional
 * 1.1 - Updated for NS 3.0
 *     - Stopped alien votes showing
 * 1.0 - Initial plugin
 */

#include <amxmodx>
#include <ns>
#include <engine>

#define ACCESS_PROTECT ADMIN_BAN //comment this line to disable protection
#define NOTICE_EJECT //comment to stop noticing who is ejecting

public plugin_init() {
	register_plugin("Protect comm","1.2","BOB_SLAYER")
	
	register_impulse(6, "checkcomm")
}

#if defined ACCESS_PROTECT
public findcomm() {
	for(new a=1; a <= get_maxplayers(); a++) {
		if(!is_user_connected(a))
			continue
		if(ns_get_class(a) == CLASS_COMMANDER)
			return a
	}
	return 0
}
#endif

public checkcomm(id) {
	if(entity_get_int(id, EV_INT_team) == 1) {
#if defined ACCESS_PROTECT
		new comm = findcomm()
		if (get_user_flags(comm)&ACCESS_PROTECT) {
			client_print(id, print_chat, "Commander is admin, cannot be ejected.")
			return PLUGIN_HANDLED
		}
#endif
#if defined NOTICE_EJECT
		new name[32]
		get_user_name(id,name,32)
		client_print(0, print_chat, "%s has voted to eject commander.", name);
#endif
	}
	return PLUGIN_CONTINUE
}
