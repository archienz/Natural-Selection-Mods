#include <amxmodx>
#include <amxmisc>
#include <engine>

public plugin_init() {
  register_plugin("Invisibilty",AMXX_VERSION_STR,"Disturbed, and Terminal")
  register_concmd("amx_invis","invis",ADMIN_LEVEL_C,"<name|steamid> <on|off> - sets invisibility on or off on user")
}

public invisOnOff(playerID,invisOn,adminID) {
	new name[64];
	get_user_name(playerID,name,63);
	
	if(invisOn==1){
		if(get_entity_visibility(playerID)) {
			console_print(adminID,"Client %s already has invisibility on.",name);
			return PLUGIN_HANDLED
		}
		console_print(adminID,"Invisibility enabled on client %s.",name);
		set_entity_visibility(playerID, 0);
	}  
	if(invisOn==0){
		if(!get_entity_visibility(playerID)) {
		console_print(adminID,"Client %s already has invisibility off.",name);
		return PLUGIN_HANDLED
		}
		console_print(adminID,"Invisibility disabled on client %s.",name);
		set_entity_visibility(playerID, 1);
	}
	return PLUGIN_HANDLED
}

public invis(id,level,cid) {
	if(!cmd_access(id,level,cid,0)) {
		console_print(id,"You do not have access to that command.");
		return PLUGIN_HANDLED
	}
	
	if(access(id,ADMIN_IMMUNITY)&&id!=cid){
		console_print(id,"Client Has Immunity.");
		return PLUGIN_HANDLED
	}
	
	new arg1[256], arg2[256];
	read_argv(1,arg1,255);
	read_argv(2,arg2,255);
	
	new player = cmd_target(id,arg1,2);
	
	if (equal(arg2,"on")) {
		invisOnOff(player,1,id)
	}
	
	if (equal(arg2,"off")) {
		invisOnOff(player,0,id);
	}
	
	return PLUGIN_HANDLED
}