 /*
Team Select - V.1.2.5 - Zamma

Credits: Zamma
	Depot (for testing)
	mE (for different calling system)
	Golden-Death (for using his plug for menu help)

cvar:
	mp_teamselector_mode 0 	->	only running on ported maps ( cs_ / de_ / ctf_ / dod_ )
	mp_teamselector_mode 1	->	running on all maps
*/

#include <amxmodx>
#include <fakemeta>
#include <ns>

#define	autoassign_time	20.5

new plugin_author[] = "Zamma/White Panther"
new plugin_version[] = "1.3"
new teamselctor_running
new max_players
new allow_to_join = 1

public plugin_init(){
	register_cvar("mp_teamselector_mode","0")
	register_logevent("game_status_check",1)
	max_players = get_maxplayers()
	
	if ( get_cvar_num("mp_teamselector_mode") )
		teamselctor_running = 1
	
	if ( teamselctor_running ){
		register_plugin("Team Selector",plugin_version,plugin_author)
		register_menucmd(register_menuid("Team Selector Menu:"),1023,"actionMenu")
	}else
		register_plugin("Team Selector (off)",plugin_version,plugin_author)
}

public plugin_precache(){
	new mapname[51]
	get_mapname(mapname,50)
	if ( equali(mapname[3],"cs_",3) || equali(mapname[3],"de_",3) || equali(mapname[3],"tfc_",4) || equali(mapname[3],"dod_",4) )
		teamselctor_running = 1
}

public client_changeteam(id,newteam,oldteam){
	if ( newteam == 0 ){
		if ( teamselctor_running )
			set_task(0.5,"showmenu",100+id)
		
		set_task(autoassign_time,"forceteam",200+id)
	}else{
		if ( teamselctor_running ){
			remove_task(100+id)
			client_cmd(id, "slot10")
		}
		
		remove_task(200+id)
	}
}

public client_changeclass(id,newclass,oldclass){
	if ( is_user_connected(id) ){
		if ( pev(id,pev_team) == 0 ){
			if ( newclass == CLASS_NOTEAM ){
				if ( teamselctor_running )
					set_task(0.5,"showmenu",100+id)
				
				set_task(autoassign_time,"forceteam",200+id)
			}
		}
	}
}

public client_putinserver(id){
	if ( teamselctor_running )
		set_task(0.5,"showmenu",100+id)
	
	set_task(autoassign_time,"forceteam",200+id)
}

public actionMenu(id,key){
	switch ( key ){
		case 0:{
			client_cmd(id, "jointeamone")
		}
		case 1:{
			client_cmd(id, "jointeamtwo")
		}
		case 2:{
			client_cmd(id, "spectate")
		}
		case 3:{
			client_cmd(id, "autoassign")
			client_cmd(id, "slot10")
		}
		case 9:{
			if ( (get_user_flags(id)&ADMIN_BAN) )
				return PLUGIN_HANDLED
		}
	}
	
	set_task(0.1,"check_if_joined_team",300+id)
	
	return PLUGIN_HANDLED
}

public showmenu(timerid_id){
	new id = timerid_id - 100
	if ( is_user_connected(id) ){
		if ( !( 1 <= pev(id,pev_team) <= 4) ){
			new menuBody[512]
			new len = format(menuBody,511,"Team Selector Menu:^n^n")
			len += format(menuBody[len],511-len,"^n1. Join Marines / Blue MvM^n^n2. Join Aliens / Red MvM^n^n3. Spectate The Match^n^n4. Auto assign%s", (get_user_flags(id)&ADMIN_BAN) ? "^n^n0. Exit This Menu" : "")
			show_menu(id,((1<<0)|(1<<1)|(1<<2)|(1<<3)|(1<<9)),menuBody)
		}
	}
	
	return PLUGIN_HANDLED
}

public forceteam(timerid_id){
	new id = timerid_id - 200
	if ( allow_to_join ){
		if ( is_user_connected(id) ){
			if ( !(get_user_flags(id)&ADMIN_BAN) ){
				client_cmd(id, "autoassign")
				if ( teamselctor_running )
					client_cmd(id, "slot10")
			}
		}
	}else
		set_task(1.0,"forceteam",timerid_id)
}

public check_if_joined_team(timerid_id){
	new id = timerid_id - 300
	if ( is_user_connected(id) ){
		if ( pev(id,pev_team) == 0 && pev(id, pev_playerclass) != 5 )	// 5 = spectator
			showmenu(100+id)
		
		remove_task(100+id)
		//remove_task(200+id)
	}
}

public game_status_check(){
	new szArg1[32]
	read_logargv(0,szArg1,31)
	if ( equal(szArg1,"Game reset complete.") ){
		allow_to_join = 1
		for ( new id = 1; id <= max_players; id++ )
			client_changeclass(id,CLASS_NOTEAM,1)
	}else if ( contain(szArg1,"has lost") != -1 ){
		allow_to_join = 0
		for ( new id = 1; id <= max_players; id++ )
			remove_task(200+id)
	}
}