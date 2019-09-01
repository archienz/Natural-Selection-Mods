/*
 *  Comments: 
 *		Everyone can dump resources into the hive, by aiming at it and hitting "use" key.
 *		When the Alien Rebirth quota is met, the hive will be ready, to respawn everyone,
 *		when most aliens are dead.  You may keep dumping resources to Hive, for gorges.
 *		Gorges can retrieve the left over resources from Resource Towers, only after the
 *		Alien Rebirth quota has been met.  When the gorge dies and regorges, they may
 *		again retrieve more leftover resources.
 *
 *	Note: 	This plugin is balanced for "serious" gameplay.
 *	
 *	CVARs:
 *		rebirth_gorge_res 		(default: 5)	- Resource Limit for Gorge, (for each life).
 *		rebirth_res_per_alien 	(default: 4)	- How much res per alien needed for Alien Rebirth.
 *		rebirth_percent 		(default: 80.0)	- Percent of dead players needed for hive to activate Alien Rebirth.
 *
 *  Version : 	1.02b
 *	Requires:	AMXX 1.60 with NS module 
 *	Gametype: 	NS Classic 
 *
 *	Author:		OneEyed
 *	Date:		01-23-2006
 *	Email:		joelruiz2@gmail.com
 *	IRC:		#modns (gamesurge.net) 
 *
 * 	Tested :
 *		WIN32 Tested and Approved! LINUX untested.
 * 
 *  Credits: 
 * 	  WhitePanther 		   - For figuring out instant respawn.
 *    CheesyPeteza 		   - For some of his genius snippets.
 *    vittu 			   - For helping me test.
 *	  nf.crew l DeAtH07    - Live testing on his server
 *   
 * Change Log:
 * v1.01b
 * - Fixed ServerFrameFake breaking other plugins
 * v1.02b (Current Version)
 * - Fixed all bugs, works like a charm.
 */

#include <amxmodx>
#include <engine>
#include <fakemeta>
#include <ns>


//--------------------------------------------------------------------------------------------------------
//---------------------DO NOT EDIT BEOW ------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------

new g_AlienRes				//Alien Hive Resources
new g_msgScoreInfo			//Scoreboard info
new g_hives					//Hive count when player was spawned (to fix weapons)
new g_rebirth_res			//Res per Alien needed for Alien Rebirth
new g_gorge[33]				//Our individual gorge res limit
new bool:g_rebirthing[33]	//Set to player who is being respawned from death
new bool:g_rebirth = false	//Set when hive is doing rebirth
new bool:g_ready = false	//Set when hive met Alien Rebirth resource quota
new Float:g_lastmessage[33]	//Message delay checker

new maxplayers				//Static Max total players server allows
new combat					//Static ns_is_combat() result
#define TITLE "Alien Rebirth"
#define VERSION "1.02b"
#define AUTHOR "OneEyed"

#define HELP1 "-----Everyone can dump resources into the hive, by aiming at it and hitting ^"use^" key."
#define HELP2 "-----Gorges can retrieve the left over resources from Resource Towers, only after the"
#define HELP3 "-----Alien Rebirth quota has been met.  When the gorge dies and regorges, they may"
#define HELP4 "-----again retrieve more leftover resources."

new g_rebirth_sound[] = "hud/alien_myhive.wav"	//played when Hive Rebirths everyone.
//--------------------------------------------------------------------------------------------------------
public plugin_init() {
	
	register_plugin(TITLE, VERSION, AUTHOR)
	
	combat = ns_is_combat()
	if(combat)
		return PLUGIN_HANDLED
		
	engfunc( EngFunc_PrecacheSound, g_rebirth_sound)	//Hack to precache whenever u want
	
	if(!cvar_exists(TITLE))
		register_cvar("Alien_Rebirth",VERSION,FCVAR_SERVER)
	if(!cvar_exists("rebirth_gorge_res"))
		register_cvar("rebirth_gorge_res","5")
	if(!cvar_exists("rebirth_res_per_alien"))
		register_cvar("rebirth_res_per_alien","4")
	if(!cvar_exists("rebirth_percent"))
		register_cvar("rebirth_percent","80.0")
	
	register_event("Countdown", "gameStart", "ac")
	register_event("ResetHUD","ResetHUD","b")
	register_clcmd("say","handle_say")

	maxplayers = get_maxplayers()
	g_msgScoreInfo = get_user_msgid("ScoreInfo")
	
	
	//------------------------------------------------------------
	//-------Modns.org Official Plugin ServerFrameFake------------
	new fakeEnt = find_ent_by_class(-1, "ServerFrameFake")
	if ( fakeEnt <= 0 )
	{
		fakeEnt = create_entity("info_target")
		entity_set_string(fakeEnt, EV_SZ_classname, "ServerFrameFake")
		entity_set_float(fakeEnt, EV_FL_nextthink, halflife_time() + 0.01)
	}
	register_think("ServerFrameFake", "server_frame_fake")
	//------------------------------------------------------------
	
	//Rebirth loop to take care of resources
	new ent = create_entity("info_target")
	entity_set_string(ent, EV_SZ_classname, "Rebirth")
	register_think("Rebirth","Rebirth")
	entity_set_float(ent,EV_FL_nextthink,halflife_time() + 1.0)
	return PLUGIN_HANDLED
}

//--------------------------------------------------------------------------------------------------------
public handle_say(id) {
	new said[192]
	read_args(said,192)
	remove_quotes(said)
	if( (containi(said, "rebirth") != -1) )
		rebirth_help(id)
	
	return PLUGIN_CONTINUE
}
//--------------------------------------------------------------------------------------------------------
rebirth_help(id) {
	client_print(id,print_chat,"NOTICE: Press ~ to open console, and read Alien Rebirth Help text.")
	console_print(id,"==============Alien Rebirth v%s=======================",VERSION)
	console_print(id,HELP1)
	console_print(id,HELP2)
	console_print(id,HELP3)
	console_print(id,HELP4)
	console_print(id,"===============================By: %s=========",AUTHOR)
}	
//--------------------------------------------------------------------------------------------------------
public ResetHUD(id) { //Reset our flags
	if((!is_user_alive(id) && pev(id,pev_team) == 2 && g_rebirthing[id]) || pev(id,pev_iuser3) == 8)
		g_rebirthing[id] = false
	if(g_gorge[id] >= 5) //Allow dead gorge player to re-get resources when gorged again
		g_gorge[id] = 0
}
//--------------------------------------------------------------------------------------------------------
public client_disconnect(id) { // Clear player flags when they leave
	if(!combat) {
		g_rebirthing[id] = false
		g_gorge[id] = 0	
		g_lastmessage[id] = 0.0
	}
}
//--------------------------------------------------------------------------------------------------------
public gameStart(id) {	//Make sure we start fresh every new round.
	for(new x=1;x<=maxplayers;x++) {
		g_rebirthing[id] = false
		g_lastmessage[id] = 0.0
	}
	g_rebirth = false
	g_ready = false
	g_AlienRes = 0
	g_hives = 0	
}
//--------------------------------------------------------------------------------------------------------
public server_frame_fake(fakeEnt) {
	//Count all aliens, and all dead aliens to get % of dead
	new Float:deadcount, Float:totalcount
	for(new x=1;x<=maxplayers;x++) {
		if(pev(x,pev_team) == 2) {
			if(!is_user_alive(x))
				deadcount++
			totalcount++
		}
	}
	if(totalcount < 2)
		g_rebirth_res = get_cvar_num("rebirth_res_per_alien") * 1
	else
		g_rebirth_res = floatround(get_cvar_num("rebirth_res_per_alien") * totalcount)
	//Respawn players when our % was met, and play sound on hive/res tower
	
	if( (deadcount / totalcount) >= (get_cvar_float("rebirth_percent")/100.0) ) {
		if(!g_rebirth && g_ready) {
			for(new x=1;x<=ns_get_build("alienresourcetower",1,0);x++)
				emit_sound(ns_get_build("alienresourcetower",1,x), CHAN_AUTO, g_rebirth_sound, 1.0, ATTN_NORM, 0, PITCH_HIGH)
			for(new x=1;x<=ns_get_build("team_hive",1,0);x++)
				emit_sound(ns_get_build("team_hive",1,x), CHAN_AUTO, g_rebirth_sound, 1.0, ATTN_NORM, 0, PITCH_HIGH)
				
			for(new x=1;x<=maxplayers;x++)
				if(is_user_connected(x) && pev(x,pev_team) == 2)
					if(!is_user_alive(x))
						entity_set_int(x, EV_INT_playerclass, 5) // spectate
					///else
					//	set_task(2.9,"checkAlive",x,"",_,"a",0)
			set_task(3.0,"now") //Give it time to respawn, like distress beacon
			g_rebirth = true
		}
	}
	
	//Hack to fix weapons for new hives if the rebirthed hadn't died/gestated yet.
	if(g_hives < ns_get_build("team_hive",1,0)) {
		for(new x=1;x<=maxplayers;x++)
			if(pev(x,pev_iuser3) == 3 && is_user_alive(x) && g_rebirthing[x]) {
				g_hives = ns_get_build("team_hive",1,0) //reset g_hives and give weapons to player
				giveWeaps(x, g_hives)
			}
	}
	
	//Make sure we take our rebirth resources when available
	if(g_AlienRes >= g_rebirth_res && !g_ready) {
		
		for(new x=1;x<=maxplayers;x++)
			if(pev(x,pev_team) == 2)
			{
				if ((get_gametime() - g_lastmessage[x]) > 3) {
					ns_popup(x,"Alien Rebirth (Activated)")
					g_lastmessage[x] = get_gametime()
								
				}
				client_print(x,print_center,"Alien Rebirth (Ready)")
			}
				
		g_ready = true
		g_AlienRes = g_AlienRes - g_rebirth_res
	}
	
	//Here we go again!
	entity_set_float(fakeEnt, EV_FL_nextthink, halflife_time() + 0.01)
	return PLUGIN_HANDLED
}
public checkAlive(ent) {
	
}
//--------------------------------------------------------------------------------------------------------
public Rebirth(ent) {
	new entity, part, team
	for(new x=1;x<=maxplayers;x++) {
		
		team = pev(x,pev_team)
		
		if(!is_user_connected(x) || !is_user_alive(x) || team == 1) continue
		
		get_user_aiming(x, entity, part, 300)
		
		if( pev(entity,pev_iuser3) == 17 ) {	// Aiming at hive
			if ( (entity_get_int(x, EV_INT_button) & IN_USE) ) {	//Aiming and hitting "use" key
				if(ns_get_res(x) > 0) {
					g_AlienRes++				// All aliens depositing res to hive
					ns_set_res(x,ns_get_res(x)-1)
					
					//Display this when players add resources
					if(!g_ready) 
						client_print(x,print_center,"Hive Resources (%i) +1^nAlien Rebirth (%i needed)",g_AlienRes,g_rebirth_res)
					else 
						client_print(x,print_center,"Hive Resources (%i) +1^nAlien Rebirth (Ready)",g_AlienRes)
					continue
				}
			}
			
			//Display this when player is just looking at hive
			if(!g_ready)
				client_print(x,print_center,"Hive Resources (%i)^nAlien Rebirth (%i needed)",g_AlienRes,g_rebirth_res)
			else
				client_print(x,print_center,"Hive Resources (%i)^nAlien Rebirth (Ready)",g_AlienRes)
		}
		
		if( pev(entity,pev_iuser3) == 46 && pev(entity,pev_fuser1) == 1000) { //Aiming at fully built RES tower
			if(pev(x,pev_iuser3) == 4)
				//Gorge looking at tower
				client_print(x,print_center,"Hive Resources (%i)^nYour Resource Limit (%i left)",g_AlienRes,(get_cvar_num("rebirth_gorge_res")-g_gorge[x]))
			else {
				//Other aliens aiming at res tower
				if(!g_ready) 
					client_print(x,print_center,"Hive Resources (%i)^nAlien Rebirth (%i needed)",g_AlienRes,g_rebirth_res)
				else 
					client_print(x,print_center,"Hive Resources (%i)^nAlien Rebirth (Ready)",g_AlienRes)
			}
			
			if ( (entity_get_int(x, EV_INT_button) & IN_USE) ) {
				if(pev(x,pev_iuser3) == 4) { // Gorge Receiving Res //if rebirth isnt ready, let gorge add res
				
					if(g_AlienRes >= 1 ) {
						if(g_ready && g_gorge[x] < get_cvar_num("rebirth_gorge_res")) {
							g_gorge[x]++
							g_AlienRes--
							ns_set_res(x,ns_get_res(x)+1)
							//Display this to gorge who's taking out resources
							client_print(x,print_center,"Hive Resources (%i) -1^nYour Resource Limit (%i left)",g_AlienRes,(get_cvar_num("rebirth_gorge_res")-g_gorge[x]))
						}
						
						else if(g_gorge[x] >= get_cvar_num("rebirth_gorge_res")) {
							if ((get_gametime() - g_lastmessage[x]) > 3) {
					
								ns_popup(x,"Your limit will be reset when you die!")
								g_lastmessage[x] = get_gametime()
								
							}
							//GOrge trying to take out resources but can't
							client_print(x,print_center,"Hive Resources (%i)^nYour Resource Limit (%i left)",g_AlienRes,(get_cvar_num("rebirth_gorge_res")-g_gorge[x]))
						}
						
						else if(!g_ready) {
							if ((get_gametime() - g_lastmessage[x]) > 3) {
								
								ns_popup(x,"Must fill the Alien Rebirth quota before extracting your resources!")
								g_lastmessage[x] = get_gametime()
								
							}
						}
					}
					else {
						if ((get_gametime() - g_lastmessage[x]) > 3) {
							ns_popup(x,"There are no resources in the hive!")
							g_lastmessage[x] = get_gametime()	
						}
					}
				}	
			}
		}
	}
	
	//Here we go again!
	entity_set_float(ent,EV_FL_nextthink,halflife_time() + 0.8)
	return PLUGIN_HANDLED
}
//--------------------------------------------------------------------------------------------------------
public now() { //Respawn all aliens
	for ( new id = 1; id <= maxplayers; id++ ) {
		
		new team = pev(id,pev_team)
		new connected = is_user_connected(id)
		new alive = is_user_alive(id)
		
		if ( team != 2 || !connected) continue
		if (!alive) {
			
			entity_set_int(id, EV_INT_iuser1, 0)	//remove their spectate flag
			entity_set_int(id, EV_INT_iuser2, 0)	//when set to spectate someone(you recieve their values) remove it
			entity_set_int(id, EV_INT_playerclass, 2) //playing
			
			entity_set_float(id, EV_FL_fuser2,1000.0) //set life bar (hp meter on aliens)
			entity_set_float(id, EV_FL_fuser3,1000.0) //set energy to full
			entity_set_int(id, EV_INT_iuser3, 3) // skulk
			entity_set_float(id, EV_FL_health, 70.0)	//skulk start hp
			entity_set_float(id, EV_FL_max_health, 70.0)	//skulk max hp
			entity_set_float(id, EV_FL_armorvalue, 10.0)	// skulk start armor

			new frags = floatround(entity_get_float(id, EV_FL_frags))
			
			//Reset our scoreboard info
			message_begin(MSG_ALL, g_msgScoreInfo)
			write_byte(id)
			write_short(ns_get_score(id) + frags + get_level(id))
			write_short(frags)
			write_short(ns_get_deaths(id))
			write_byte(4)  // class
			write_short(0) // ICON status
			write_short(2) // team
			message_end()
			
			dllfunc(DLLFunc_Spawn,id)	//Respawn Dead PLayers instantly.
			
			set_task(0.1,"later",id)	//we give weapons 0.1 seconds later (cause NS said so)
		}
		else { // Respawn all alive players to hive
			dllfunc(DLLFunc_Spawn,id)
		}
	}
}
//--------------------------------------------------------------------------------------------------------
public later(id) { //Fix flags and give weapons

	g_hives = ns_get_build("team_hive",1,0)
	giveWeaps(id, g_hives)
	
	g_rebirthing[id] = true
	
	if(g_ready || g_rebirth) {
		g_ready = false
		g_rebirth = false
	}
}
//--------------------------------------------------------------------------------------------------------
giveWeaps(id, hives) { //give weaps (check if they have it before we give it)

	if(pev(id,pev_iuser3) != 3) return PLUGIN_HANDLED	//return if not skulk
	
	if(!ns_has_weapon(id,WEAPON_BITE))
		ns_give_item(id, "weapon_bitegun")
	if(!ns_has_weapon(id,WEAPON_PARASITE))
		ns_give_item(id, "weapon_parasite")
		
	switch(hives) {
		case 2: //2 hive weaps
		{
			if(!ns_has_weapon(id,WEAPON_LEAP))
				ns_give_item(id, "weapon_leap")
		}
		case 3: //3 hive weaps
		{
			if(!ns_has_weapon(id,WEAPON_LEAP))
				ns_give_item(id, "weapon_leap")
			if(!ns_has_weapon(id,WEAPON_DIVINEWIND))
				ns_give_item(id, "weapon_divinewind")
		}
	}
	return PLUGIN_HANDLED
}
//--------------------------------------------------------------------------------------------------------
stock get_level(index) //get player level
	return floatround(floatsqroot(ns_get_exp(index) / 25 + 2.21) - 1)
//--------------------------------------------------------------------------------------------------------