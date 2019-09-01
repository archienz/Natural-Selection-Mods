/*
* This plugin will assign various models to designated players.
* 
* "amx_changemodel jonny player/alien1/alien1.mdl" will change player "johnny" to alien1 (skulk)
* note: do not use models/ infront (eg: models/player/alien1/alien1.mdl)
*
*Author: Depot
*Ripped from White Panther's testmodel plugin for The Gnome Project.
*
*	VERSION:	0.2 released 12.26/04 (true port to v1.00)
*	FIXES:		Server crash error, making it optional to use the extention ".mdl" Thanks White Panther!
*/

#include <amxmodx>
#include <amxmisc>
#include <ns>

public plugin_init(){  
	register_plugin("Change Model","0.2","White Panther / Depot")
	register_concmd("amx_changemodel","changemodel",ADMIN_LEVEL_H,"<target> <model> / change target model")
}

public changemodel(id,level,cid){
	if ( !cmd_access(id,level,cid,2) )
		return PLUGIN_HANDLED
	
	new arg[32], arg2[65]
	read_argv(1,arg,32)
	read_argv(2,arg2,64)
	
	new target_player = cmd_target(id, arg, 4)
	if ( !target_player )
		return PLUGIN_HANDLED
	
	new model[81]
	if ( containi(arg2,".mdl") != -1 )
 		format(model,80,"models/%s",arg2)
	else
	 	format(model,80,"models/%s.mdl",arg2)

	if ( file_exists(model) )
	 	ns_set_player_model(target_player, model)
	else
	 	client_print(id,print_chat,"Model not found")
	
	return PLUGIN_HANDLED
}

public plugin_precache(){
	// put here all models u want to use
	// use the following command:
	// precache_model("models/mymodel.mdl")

}

	
