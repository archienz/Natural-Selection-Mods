//  WhichBot Admin compatable with v.94g of whichbot.
//  Gives admins power over the bots without giving them rcon.
//  Original work done by Brewski[LH] I just updated and added to it.
//    -SilverSquirrl www.2frag4fun.com 70.84.129.151
//
//  Commands:
//	amx_wb_add			- adds a bot, turns of balance
//	amx_wb_remove			- Removes a bot, turns off balance
//	amx_wb_balance <on/off>		- Turns on/off auto balance
//	amx_wb_boost			- Gives alien team xp/res
//	amx_wb_evolve <alienclass>	- forces bots to go a certain lifeform once they get the level.



#include <amxmodx>
#include <amxmisc>

public plugin_init() 
{ 
	register_plugin("WhichBot Admin","2.7","SilverSqurril") 
	register_clcmd("amx_wb_add","wbAdd",ADMIN_KICK,"<adds bots>")
	register_clcmd("amx_wb_remove","wbRem",ADMIN_KICK,"<removes bots>")
	register_clcmd("amx_wb_balance","wbbalance",ADMIN_KICK,"<Balance 0/1 (off/on)>")
	register_clcmd("amx_wb_evolve","wbevolve",ADMIN_KICK,"<class (gorge,lerk,fade,onos,off)>")
	register_clcmd("amx_wb_boost","wbboost",ADMIN_KICK,"<boost bots lvl>")
} 

public wbAdd(id,level,cid) {			//add a new bot, automatically turns off Balance
	if (!cmd_access(id,level,cid,1))
return PLUGIN_HANDLED
	server_cmd("wb balance off")
	server_cmd("wb add")
	client_print(0,print_chat,"New Bot Added")
	return PLUGIN_HANDLED
}

public wbRem(id,level,cid) {			//remove a bot, automatically turns off Balance
	if (!cmd_access(id,level,cid,1))
		return PLUGIN_HANDLED
	server_cmd("wb balance off")
	server_cmd("wb remove")
	client_print(0,print_chat,"Bot Removed")
	return PLUGIN_HANDLED
}

public wbboost(id,level,cid) {			//increase alien xp/level
	if (!cmd_access(id,level,cid,1))
		return PLUGIN_HANDLED
	server_cmd("wb boost 5")
	client_print(0,print_chat,"Warning: Bots Increased 1 or more levels.")
	return PLUGIN_HANDLED
}


public wbbalance(id,level,cid) {		//Enable or disable teambalance 
	if (!cmd_access(id,level,cid,2))
		return PLUGIN_HANDLED

	new balance[4]
	read_argv(1,balance,3)
	
	if (equal(balance,"1") || equal(balance,"on")) {
		server_cmd("wb balance on")
		client_print(0,print_chat,"Whichbot Balance On")
	}
	else {
		server_cmd("wb balance off")
		client_print(0,print_chat,"Whichbot Balance Off")
	}
	
	return PLUGIN_HANDLED
}

public wbevolve(id,level,cid) {			//Set bot Class Type
	if (!cmd_access(id,level,cid,2))
		return PLUGIN_HANDLED

	new class[8]
	read_argv(1,class,7)
	
	if (equal(class,"gorge")) {
		server_cmd("wb evolve gorge")
		client_print(0,print_chat,"Gorge Just Wanna Have Fun")
		return PLUGIN_HANDLED
	}
	if (equal(class,"lerk")) {
		server_cmd("wb evolve lerk")
		client_print(0,print_chat,"Invasion Of The Flying Rats!!!")
		return PLUGIN_HANDLED
	}
	if (equal(class,"fade")) {
		server_cmd("wb evolve fade")
		client_print(0,print_chat,"We are the fade, resistence is Futile...")
		return PLUGIN_HANDLED
	}
	if (equal(class,"onos")) {
		server_cmd("wb evolve onos")
		client_print(0,print_chat,"I'm Big, You know it, Now Die!!!")
		return PLUGIN_HANDLED
	}
	else {
		server_cmd("wb evolve off")
		client_print(0,print_chat,"I love Freedom of Choice")
		return PLUGIN_HANDLED
	}
	
	return PLUGIN_HANDLED
}