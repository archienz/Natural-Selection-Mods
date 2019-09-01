/***************************************************************************
 *  amx_ejl_console.sma
 *   version 1.1         Date: 1/3/2002
 *   Author: Eric Lidman     ejlmozart@hotmail.com
 *   Alias: Ludwig van       Upgrade: http://lidmanmusic.com/cs/plugins.html
 *          
 *  A conversion to AMX the adminmod console plugin with a few added features.
 *   Its useful if a player or admin's console is stuck and wont come up.
 *   An admin can bring the player's console up with amx_console <player>
 *   A player can bring his own console up by saying in the chat "console me"
 *   so saying "`"  -- no quotes. In addition, the plugin has an auto-
 *   response to help the player is he is complaining his console doesnt 
 *   work help himself.
 *
 ***************************************************************************/

#include <amxmodx>

public admin_console(id) {

	if (!(get_user_flags(id)&ADMIN_MAP)){
		client_print(id,print_console,"[AMXX] You have no access to that command")
		return PLUGIN_HANDLED
	}
	if (read_argc() < 2){
		client_print(id,print_console,"[AMXX] Usage: amx_console < part of nick >")
		return PLUGIN_HANDLED
	}
	new arg[32]
	read_argv(1,arg,32)
	new player = find_player("b",arg)
	new targetname[32]
	if (player){
		get_user_name(player,targetname,32)
		client_print(id, print_console, "Activating console for %s.", targetname)
		client_cmd(player, "bind ` toggleconsole")
		client_cmd(player, "bind ~ toggleconsole")
		client_cmd(player, "console 1")
		client_cmd(player, "toggleconsole")
		client_cmd(player,"echo ^"Hello, %s!  This is the console!^"", targetname)	
		client_cmd(player,"echo ^"Use the ~ key (just left of 1) to toggle this on and off.^"")
		client_cmd(player,"echo ^"You can type commands here to do many things.^"")
		client_cmd(player,"echo ^"You'll need to add -console to your shortcut for starting the game to make this permanent.^"")
	} else {
		client_print(id,print_console,"Unrecognized user name: %s",arg)
	}
	new name[32]
	get_user_name(id,name,32)
	client_print(0,print_chat,"[AMXX] Admin:    %s  has activated the console of  %s",name,targetname)
	return PLUGIN_HANDLED
}

public HandleSay(id) {

	new Data[192]
	read_args(Data,192)
	remove_quotes(Data)

	if ( (equal(Data, "console me")) || (equal(Data, "`")) ) {
		new User[32]
		get_user_name(id,User,32)
		client_cmd(id, "bind ` toggleconsole")
		client_cmd(id, "bind ~ toggleconsole")
		client_cmd(id, "console 1")
		client_cmd(id, "toggleconsole")
		client_cmd(id,"echo ^"Hello, %s!  This is the console!^"", User)	
		client_cmd(id,"echo ^"Use the ~ key (just left of 1) to toggle this on and off.^"")
		client_cmd(id,"echo ^"You can type commands here to do many things.^"")
		client_cmd(id,"echo ^"You'll need to add -console to your shortcut for starting the game to make this permanent.^"")
	}
	else if( (contain(Data,"console") != -1) && ( (contain(Data,"my") != -1) || (contain(Data,"work") != -1) ) ){
		new sid[1]
		sid[0] = id
		set_task(1.0,"console_resp",0,sid,1)
	}
	return PLUGIN_CONTINUE
}

public console_resp(id[]){
	client_print(id[0],print_chat,"[AMXX]  If your console will not come up, say: `     ..... or say: console me")
	return PLUGIN_CONTINUE
}

public plugin_init() {
	register_plugin("Console Plugin","0.8","EJL")
	register_clcmd("amx_console","admin_console",ADMIN_MAP,"amx_console <target> : Enable the console and bind the standard key to it for <target>.")
	register_clcmd("say", "HandleSay", ADMIN_USER, "Say: console me  or `  to bring up your own console in the event that it is locked.")		
	return PLUGIN_CONTINUE
}



