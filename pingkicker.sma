//////////////////////////////////////////
//High Ping Kicker                      //
//By Sp4rt4n                            //
//Created February 21, 2005             //
//This code may not be used or copied   //
//without Sp4rt4n's personal permission.//
//////////////////////////////////////////

//No modules are required.
//This plugin checks a players ping every 10 seconds.
//If the players ping is higher than the set amount 3 times, they will be kicked.
//To force the server to check pings, you must have an access level of ADMIN_RCON.
//That command is amx_ping.
//To change the max ping, you must use ping_max <ping>.

#include <amxmodx>

new ping_max
new ping_check = 10
new ping_times = 3

new numtests[30]

public plugin_init() {
	register_plugin("High-Ping-Kicker","1.4","Sp4rt4n")
	register_concmd("amx_ping","checkPing", ADMIN_LEVEL_A, "Forces the server to check the ping.") 
	register_cvar("ping_max", "220")
	set_task(10.0,"checkPing");
	return PLUGIN_CONTINUE
}

public client_disconnect(id) {
	remove_task(id)
	return PLUGIN_CONTINUE
}

public checkPing(param[]) {
	new id = param[0]
	if ((get_user_flags(id) & ADMIN_IMMUNITY) || (get_user_flags(id) & ADMIN_RESERVATION)) {
		remove_task(id)
		client_print(id, print_chat, "[HPK] Ping checking disabled because of immunity..")
		return PLUGIN_CONTINUE
	}
	new ping, l
	get_user_ping(id, ping, l)
	if (ping < ping_max)
		++numtests[id]
	else
	if (numtests[id] > 0) --numtests[id]
	if (numtests[id] > ping_times)
		kickPlayer(id)
	return PLUGIN_CONTINUE
}

kickPlayer(id) {
	new name[32]
	get_user_name(id, name, 31)
	new uID = get_user_userid(id)
	server_cmd("banid 1 #%d", uID)
	client_cmd(id, "echo ^"[HPK] Your ping is too high.^"; disconnect")
	client_print(0, print_chat, "[HPK] %s was kicked because of high ping.", name)
	return PLUGIN_CONTINUE
} 

public showWarn(param[]) {
	client_print(param[0], print_chat, "[HPK] Players with ping higher than %dms will be kicked.", ping_max)
	set_task(float(ping_check), "checkping", param[0], param, 1, "b")
	return PLUGIN_CONTINUE
}