/*
* This plugin is allows you to run Marine vs Marine without any problems
* - Players and buildings are now Blue vs Red (new models)
* - MvM in classic
*
* Author:
*	-> White Panther
*
* Credits:
*	Sandstorm			-	rip from his ava for scoreboard fix
*	CheesyPeteza			-	his Respawn System
*	DarK_SouL			-	his fix of CheesyPeteza	Respawn System and winning message change
*	Zamma & White Panther		-	mvmmodels plugin
*	mahnsawce			-	rip off from MvM Auto Glow plugin and his weld fix
*	CorDorMick			-	testing
*	-mE-				-	idea for code performance
*	Depot				-	his assistance in getting bugs fixed
*	OneEyed + theqizmo		-	helping with MvM crashes (back to old code) + speed performance
*	9 iI IN C IH G IL O C IK	-	his v_ color models
*
* Usage:
*	- say "/votemvm"	->	to start a vote to play current map in MvM mode ( if config available )
*	- amx_mvm_convert	->	to change to this map and run it in MvM mode
*	- amx_mvm_auto		->	turns autoassign on or off
*
* Info:
*	- Converter config files are expected to be in amxmodx/configs/mvm_configs/
*	- each file must be named <Map-Name>.cfg ( without .bsp )
*
* v1.0:
*	- initial release
*
* v1.1.3:
*	- fixed prob where models were precached on all combat maps instead of only on mvm combat (mahnsawce)
*	- fixed bug where players respawned and model has not been changed
*	- error with unknown players should be fixed
*
* v1.2.3:
*	- fixed:
*		- possible error
*		- error with unknown players
*		- plugin was not running on maps where CC was on team 2 instead of 3
*	- added:
*		- ability to autoassign players (default off) (amx_mvm_auto 1/0)
*	- changes:
*		- moved from ns2amx to engine + fakemeta + ns
*
* v1.2.9c:
*	- fixed:
*		- bug where red teams scoreboard was green while players where reinforcing
*		- players could have default (green) model until they died or got JP/HA
*		- red players could spectate through eyes of blue players when dead
*		- another default model bug
*		- changed the way of getting command chairs and armorys to improve speed (thx -mE-)
*	- added:
*		- respawn display added
*	- changed:
*		- the new temp command chair (red team) will get all pevs from the original copied
*		- the way of getting the players team (not pev anymore)
*		- code improvements (+)
*
* v1.3:
*	- fixed:
*		- again another default model bug (:P)
*		- red CC has now correct animation
*	- changed:
*		- code improvements
*
* v1.3.2b:
*	- fixed:
*		- dublicated red CC (during initialization and ingame)
*		- runtime error
*	- changed:
*		- moved from pev/set_pev to entity_get/entity_set
*
* v1.3.3:
*	- fixed:
*		- crash on some maps
*	- changed:
*		- code cleaning
*
* v1.4:
*	- fixed:
*		- crash bug on maps (notice that on some maps team bases have been switched,
*			this is a crash prevention due to bad maps)
*	- changed:
*		- check for precaching models
*
* v1.5:
*	- fixed:
*		- crash bug on maps (now seems to be completely fixed)
*			( PS: switching team bases has been removed )
*
* v1.5.3:
*	- fixed:
*		- another crash on bad made maps ( 2nd cc was not set to 3 but to 2 )
*		- possible bug where cc could be switched
*	- changed:
*		- removed unneeded code
*
* v1.5.4:
*	- fixed:
*		- horrible bug where cc was removed on all non MvM maps ( sry )
*
* v1.6:
*	- fixed:
*		- all crash bugs
*	- changed:
*		- reversed to 1.2.3 method ( thx "OneEyed" and "theqizmo" )
*		- code improvements
*
* v1.6.2:
*	- fixed:
*		- possible bug where blue could not see red teams normal chat (dont think it has ever happened but bug was there)
*	- changed:
*		- minor speed improvement
*		- code improvements
*
* v1.6.3:
*	- fixed:
*		- problem where red team did not spawn ( accidently stopped an inportant timer, sry )
*
* v1.6.4:
*	- fixed:
*		- minor runtime error (very rare and not harmful )
*	- changed:
*		- server_frame is hooked with ent and support other plugins that uses the same system (speed improvement thx OneEyed)
*
* v1.6.5:
*	- fixed:
*		- client_spawn blocked other plugins to call that function (thx KCE)
*
* v1.7:
*	- fixed:
*		- NS 3.1 support
*	- changed:
*		- removed about 50% of code due to NS 3.1
*
* v1.7.1:
*	- fixed:
*		- minor runtime error
*
* v1.7.3:
*	- fixed:
*		- compatibility with hybrid maps
*	- changed:
*		- new MvM map detection results in much smaller code
*
* v2.0.3:
*	- added:
*		- support for classic MvM ( ns_mvm_ maps )
*	- changed:
*		- entity_get/set_xxx replaced with pev/set_pev ( performance )
*		- minor code tweaks
* v2.1.0:
*	- fixed:
*		- player could get wrong model on round start
*		- improved classic support:
*			- electrified Structures have correct color
*			- correct elec spark color
*			- commander gets notified when upgrades have finished
*	- added:
*		- Converter to change MvA to MvM on the fly ( map restart needed )
*		- support for colored view models
*		- Helper support
*		- team names can be changed via defines
*	- changed:
*		- NS 3.2 merge
*/

#include <amxmodx>
#include <amxmisc>
#include <engine>
#include <fakemeta>
#include <ns>

// change these names to your desire
#define TEAM_READYROOM		"#undefinedteam"
#define TEAM1_NAME		"Blue"
#define TEAM2_NAME		"Yellow"
#define TEAM3_NAME		"Green"
#define TEAM4_NAME		"Red"
#define TEAM_SPECTATOR		"#spectatorteam"

// Change this to 1 if you want to use the new v_ models
#define V_MODELS_AVAILABLE	0

//////////////////// DO NOT MODIFY BELOW ////////////////////

#define	NOTEAM			0
#define	MARINE			1
#define	MARINE2			3

enum {
	ENTITY_MARINE = 0,
	ENTITY_HEAVY,
	ENTITY_CC,
	ENTITY_ARMORY,
	
	ENTITY_RESOURCETOWER,
	ENTITY_ARMSLAB,
	ENTITY_PROTOLAB,
	ENTITY_OBSERVATORY,
	ENTITY_TURRETFACTORY,
	ENTITY_SENTRY,
	ENTITY_PHASEGATE,
	ENTITY_IP,
	ENTITY_SIEGE,
	
	ENTITY_END_OF_LIST
}

new mvm_models[ENTITY_END_OF_LIST][] =
{
	"models/player/soldier/soldier_color.mdl",
	"models/player/heavy/heavy_color.mdl",
	"models/b_commandstation_color.mdl",
	"models/b_armory_color.mdl",
	
	"models/b_resourcetower_color.mdl",
	"models/b_armslab_color.mdl",
	"models/b_prototypelab_color.mdl",
	"models/b_observatory_color.mdl",
	"models/b_turretfactory_color.mdl",
	"models/b_sentry_color.mdl",
	"models/b_phasegate_color.mdl",
	"models/b_infportal_color.mdl",
	"models/b_siege_color.mdl"
}

#if V_MODELS_AVAILABLE == 1
enum {
	V_KNIFE = 0,
	V_PISTOL,
	V_LIGHTMACHINEGUN,
	V_SHOTGUN,
	V_HEAVYMACHINEGUN,
	V_WELDER,
	V_MINE,
	V_GRENADEGUN,
	V_GRENADE,
	
	V_MODEL_END_OF_LIST
}

new mvm_v_models_light[V_MODEL_END_OF_LIST][] =
{
	"models/v_kn_color.mdl",
	"models/v_hg_color.mdl",
	"models/v_mg_color.mdl",
	"models/v_sg_color.mdl",
	"models/v_hmg_color.mdl",
	"models/v_welder_color.mdl",
	"models/v_mine_color.mdl",
	"models/v_gg_color.mdl",
	"models/v_gr_color.mdl"
}

new mvm_v_models_heavy[V_MODEL_END_OF_LIST][] =
{
	"models/v_kn_hv_color.mdl",
	"models/v_hg_hv_color.mdl",
	"models/v_mg_hv_color.mdl",
	"models/v_sg_hv_color.mdl",
	"models/v_hmg_hv_color.mdl",
	"models/v_welder_hv_color.mdl",
	"models/v_mine_hv_color.mdl",
	"models/v_gg_hv_color.mdl",
	"models/v_gr_hv_color.mdl"
}
#endif

new entity_name[3][] =
{
	"team_command",
	"team_armory",
	"resourcetower"
}

enum {
	tNone,
	tAttacker,
	tDefender,
	tMarine2,
	tAlien2,
	tObserver
}

enum {
	UPGRADE_ARMOR = 0,
	UPGRADE_WEAPON,
	UPGRADE_CATALYST,
	UPGRADE_MOTION,
	UPGRADE_PHASE,
	UPGRADE_GRENADE,
	UPGRADE_ADVARMORY,
	UPGRADE_JETPACK,
	UPGRADE_HEAVY,
	UPGRADE_ADVTF,
	UPGRADE_ELECTRIFY,
	
	UPGRADE_END_OF_LIST
}

new plugin_author[] = "White Panther"
new plugin_version[] = "2.1.0"

#define MAXTEAMS	6

#define MARINE2_RED	200.0
#define MARINE2_GREEN	0.0
#define MARINE2_BLUE	0.0

new teamnames[MAXTEAMS][] =
{
	TEAM_READYROOM,
	TEAM1_NAME,
	TEAM2_NAME,
	TEAM3_NAME,
	TEAM4_NAME,
	TEAM_SPECTATOR
}

new g_maxplayers
new g_msgHudText2, g_msgScoreInfo, g_msgPlayHUDNot
new player_team[33]

#if V_MODELS_AVAILABLE == 1
new curweapon[33]
#endif

new is_mvm_game, is_combat_running, AJrunning
new is_helper_running

new KV_ent_list[200], KV_ent_counter
new KV_cc_count[3]

new hive_found, temp_hive_id
new upgrade_building[128]
new upgrade_building_mode[128]
new buildings_to_upgrade
new g_emitsound_ID

// Converter
new CONVERTER_RUNNING
new spawnpoint_team2_set, armory_team1_set, armory_team2_set
new spawnpoint_num_team1, spawnpoint_num_team2
new spawnpoint_orig_num_team1, spawnpoint_orig_num_team2
new spawnpoint_choice_num_team1, spawnpoint_choice_num_team2
new CC_data_num
new spawnpoint_origin_team1[32][20], spawnpoint_origin_team2[32][20]
new CC_origin_angles[5][20]
new Armory_origin_team1[20], Armory_origin_team2[20]

new CC_keyvalue_id, ARMORY_keyvalue_id
new cc_team2_id, armory_team2_id
new GAME_INFO_found

// Converter vote
new Float:last_vote = -60.0
new voters, vote_option[2], player_voted[33]

// color for electrified buildings RGB
new Float:Marine2_redercolor[3] = {MARINE2_RED, MARINE2_GREEN, MARINE2_BLUE}
new SFP_id
new max_entities

//////////////////// Plugin Init + Forwards ////////////////////
public plugin_init( )
{
	register_cvar("mvmallinone_version", plugin_version, FCVAR_SERVER)
	set_cvar_string("mvmallinone_version", plugin_version)
	
	register_concmd("amx_mvm_convert", "amx_mvm_convert", ADMIN_RCON, "<mapname> ; to change to this map and run it in MvM mode")
	register_clcmd("say /votemvm", "amx_mvm_handle_say")
	register_menucmd(register_menuid("Start this map in MvM mode ?") , (1<<0) | (1<<1) | (1<<9), "count_votes")
	
	g_maxplayers = get_maxplayers()
	
	if ( !is_mvm_game )
	{
		register_plugin("MvM_allinone (off)", plugin_version, plugin_author)
		
		// due to the vote system this plugin may not be paused
		//pause("ad")
		
		return
	}
	
	register_plugin("MvM_allinone", plugin_version, plugin_author)
	
	new i
	for ( i = 0; i <= ENTITY_ARMORY; ++i )
	{
		engfunc(EngFunc_PrecacheModel, mvm_models[i])
	}
	
#if V_MODELS_AVAILABLE == 1
	for ( i = 0; i < V_MODEL_END_OF_LIST; ++i )
	{
		engfunc(EngFunc_PrecacheModel, mvm_v_models_light[i])
		engfunc(EngFunc_PrecacheModel, mvm_v_models_heavy[i])
	}
	
	register_event("CurWeapon", "event_ChangeWeapon", "b")
#endif
	
	register_event("Countdown", "event_Countdown", "ab")
	register_event("ResetHUD", "event_ResetHUD", "b")
	register_event("TeamInfo", "event_TeamChanges", "ab")
	register_event("TeamNames", "event_Fix_teams", "ab")
	
	g_msgHudText2 = get_user_msgid("HudText2")
	g_msgScoreInfo = get_user_msgid("ScoreInfo")
	
	register_message(g_msgScoreInfo, "editScoreInfo")
	register_message(g_msgHudText2, "editHudText2")
	
	register_concmd("amx_mvm_auto", "amx_mvm_auto", ADMIN_LEVEL_E, "<on/off> or <1/0> turns autoassign on or off")
	register_clcmd("jointeamtwo", "jointeamtwo_fix")
	
	if ( !is_combat_running )
	{
		for ( i = ENTITY_RESOURCETOWER; i < ENTITY_END_OF_LIST; ++i )
		{
			engfunc(EngFunc_PrecacheModel, mvm_models[i])
		}
		
		register_message(SVC_TEMPENTITY, "editSVC_TEMPENTITY")
		register_forward(FM_EmitSound, "FM_EmitSound_hook")
		register_forward(FM_StartFrame, "FM_StartFramePost_hook", 1)
		
		max_entities = get_global_int(GL_maxEntities)
		g_msgPlayHUDNot = get_user_msgid("PlayHUDNot")
		register_message(g_msgPlayHUDNot, "editPlayHUDNot")
		set_task(0.1, "check_upgrade_timer", 100, _, _, "b")
	}
	
	// clean up ( crash prevention )
	for ( new classname[64], entid = g_maxplayers + 1; entid <= get_global_int(GL_maxEntities); ++entid )
	{
		if ( !is_valid_ent(entid) )
			continue
		
		pev(entid, pev_classname, classname, 63)
		if ( equal(classname, "defensechamber")
			|| equal(classname, "movementchamber")
			|| equal(classname, "sensorychamber")
			|| equal(classname, "offensechamber") )
		{
			remove_entity(entid)
		}
	}
}

public plugin_precache( )
{
	new mapname[64]
	get_mapname(mapname,63)
	is_combat_running = ns_is_combat()
	
	if ( containi(mapname, "mvm") != -1 )
	{
		is_mvm_game = 1
		
		return
	}
	
	//////////////////// CONVERTER ////////////////////
	if ( vaultdata_exists("nsmvm_convert")
		&& !is_mvm_game
		&& get_vaultdata("nsmvm_convert") == 1 )
	{
		new configpath[60], filename[128]
		get_configsdir(configpath,60)
		formatex(filename, 127, "%s/mvm_configs/%s.cfg", configpath, mapname)		// Name of file to parse
		if ( file_exists(filename) )
		{
			load_configs(filename)
			
			new str[10]
			get_vaultdata("nsmvm_convert", str, 9)
			CONVERTER_RUNNING = str_to_num(str)
			is_mvm_game = 1
		}
	}
	
	set_vaultdata("nsmvm_convert", "0")
	////////////////////////////////////////////////////////////
}

public plugin_cfg( )
{
	if ( !is_mvm_game )
		return
	
	if ( !hive_found
		&& !is_combat_running
		&& is_mvm_game )
	{
		temp_hive_id = create_entity("team_hive")
		DispatchKeyValue(temp_hive_id, "origin", "0 0 0")
		DispatchKeyValue(temp_hive_id, "maxspawndistance", "2000")
		DispatchKeyValue(temp_hive_id, "teamchoice", "2")
		DispatchKeyValue(temp_hive_id, "angles", "0 0 0")
		DispatchSpawn(temp_hive_id)
	}
	
	if ( CONVERTER_RUNNING )
	{
		if ( cc_team2_id )
		{
			dllfunc(DLLFunc_Spawn, cc_team2_id)
		}
		
		if ( armory_team2_id )
		{
			dllfunc(DLLFunc_Spawn, armory_team2_id)
		}
		
		if ( !GAME_INFO_found )
		{
			new game_info_temp = create_entity("info_gameplay")
			DispatchKeyValue(game_info_temp, "origin", "0 0 0")
			DispatchKeyValue(game_info_temp, "teamone", "1")
			DispatchKeyValue(game_info_temp, "teamtwo", "1")
			dllfunc(DLLFunc_Spawn, game_info_temp)
		}
	}
	
	is_helper_running = is_plugin_loaded("Helper")
}

public pfn_keyvalue( entid )
{
	if ( !is_combat_running
		&& !is_mvm_game )
		return PLUGIN_CONTINUE
	
	new classname[32], key[32], value[32]
	copy_keyvalue(classname, 31, key, 31, value, 31)
	
	if ( !is_combat_running )
	{
		if ( equal(classname, "team_hive") )
		{
			temp_hive_id = entid
			hive_found = 1
			
			return PLUGIN_CONTINUE
		}else if  ( equal(classname, "defensechamber")
			|| equal(classname, "movementchamber")
			|| equal(classname, "sensorychamber")
			|| equal(classname, "offensechamber")
			|| equal(classname, "alienresourcetower") )
			return PLUGIN_CONTINUE
	}
	
	if ( CONVERTER_RUNNING )
	{
		if ( equal(classname, "info_gameplay") )
		{
			GAME_INFO_found = 1
			if ( equal(key, "teamone") )
				DispatchKeyValue(entid, "teamone", "1")
			else if ( equal(key, "teamtwo") )
			{
				DispatchKeyValue(entid, "teamtwo", "1")
				
				return PLUGIN_HANDLED
			}
		}else if ( equal(classname, "info_team_start") )
		{
			if ( equal(key, "origin") )
			{
				if ( spawnpoint_orig_num_team1 < spawnpoint_num_team1 )
				{
					DispatchKeyValue(entid, "origin", spawnpoint_origin_team1[spawnpoint_orig_num_team1])
					++spawnpoint_orig_num_team1
				}else if ( spawnpoint_orig_num_team2 < spawnpoint_num_team2 )
				{
					DispatchKeyValue(entid, "origin", spawnpoint_origin_team2[spawnpoint_orig_num_team2])
					++spawnpoint_orig_num_team2
				}
				
				return PLUGIN_HANDLED
			}
			if ( equal(key, "teamchoice") )
			{
				if ( spawnpoint_choice_num_team1 < spawnpoint_num_team1 )
				{
					DispatchKeyValue(entid, "teamchoice", "1")
					++spawnpoint_choice_num_team1
					
					return PLUGIN_HANDLED
				}else if ( spawnpoint_choice_num_team2 < spawnpoint_num_team2 )
				{
					DispatchKeyValue(entid, "teamchoice", "3")
					++spawnpoint_choice_num_team2
					
					return PLUGIN_HANDLED
				}
			}
		}else if ( equal(classname, "team_command") )
		{
			CC_keyvalue_id = entid
		}else if ( equal(classname, "team_armory") )
		{
			ARMORY_keyvalue_id = entid
		}else if ( equal(classname, "info_join_team")
			&& equal(key, "teamchoice")
			&& equal(value, "2") )
		{
			DispatchKeyValue(entid, "teamchoice", "3")
			
			return PLUGIN_HANDLED
		}
	}
	
	if ( equal(key, "teamchoice")
		&& equal(value, "2") )
	{
		if ( is_mvm_game )
		{
			DispatchKeyValue(entid, "teamchoice", "3")
			
			return PLUGIN_HANDLED
			
		}else
		{
			KV_ent_list[KV_ent_counter] = entid
			++KV_ent_counter
		}
	}
	
	if ( is_mvm_game == 0 )
	{
		if ( equal(classname, "team_command")
			&& equal(key, "teamchoice") )
		{
			if ( str_to_num(value) == 1 )
				++KV_cc_count[1]
			else if ( str_to_num(value) > 1 )
				++KV_cc_count[2]
		}
		
		if ( KV_cc_count[1]
			&& KV_cc_count[2] )
		{
			for ( new i = 0; i < KV_ent_counter; ++i )
				DispatchKeyValue(KV_ent_list[i], "teamchoice", "3")
			
			is_mvm_game = 1
		}
	}
	
	if ( CONVERTER_RUNNING )
	{
		if ( spawnpoint_orig_num_team1
			&& spawnpoint_orig_num_team2
			&& CC_keyvalue_id )
		{
			DispatchKeyValue(CC_keyvalue_id, "origin", CC_origin_angles[0])
			DispatchKeyValue(CC_keyvalue_id, "angles", CC_origin_angles[1])
			CC_keyvalue_id = 0
		}
		
		if ( !cc_team2_id )
		{
			cc_team2_id = create_entity("team_command")
			DispatchKeyValue(cc_team2_id, "origin", CC_origin_angles[2])
			DispatchKeyValue(cc_team2_id, "angles", CC_origin_angles[3])
			DispatchKeyValue(cc_team2_id, "teamchoice", "3")
			DispatchKeyValue(cc_team2_id, "spawnflags", "1")
		}
		
		if ( is_combat_running )
		{
			if ( ARMORY_keyvalue_id 
				&& strlen(Armory_origin_team1) )
			{
				DispatchKeyValue(ARMORY_keyvalue_id, "origin", Armory_origin_team1)
				ARMORY_keyvalue_id = 0
			}
			
			if ( !armory_team2_id )
			{
				armory_team2_id = create_entity("team_armory")
				DispatchKeyValue(armory_team2_id, "origin", Armory_origin_team2)
				DispatchKeyValue(armory_team2_id, "angles", "0 0 0")
				DispatchKeyValue(armory_team2_id, "teamchoice", "3")
				DispatchKeyValue(armory_team2_id, "spawnflags", "1")
			}
		}
	}
	
	return PLUGIN_CONTINUE
}

public client_connect( id )
{
	if ( !is_mvm_game )
		return
	
	player_team[id] = NOTEAM
	remove_task(5000+id)
}

public client_disconnect( id )
{
	if ( !is_mvm_game )
		return
	
	player_team[id] = NOTEAM
	remove_task(5000+id)
}

public client_changeteam( id , newteam , oldteam )
{
	if ( !is_mvm_game )
		return
	
	remove_task(5000 + id)
	if ( 1 <= newteam <= 4 )
		modelchange(id)
	else
		player_team[id] = NOTEAM
}

public client_changeclass( id , newclass , oldclass )
{
	if ( !is_mvm_game )
		return
	
	if ( !is_user_connected(id) )
		return
	
	if ( newclass != 11 && newclass != 12 )
	{
		modelchange(id)
		
#if V_MODELS_AVAILABLE == 1
		// HA is doing something like a little reset, so set v_ model later
		set_task(0.5, "colourWeapon_timer", 300 + id)
#endif
	}
}

public client_spawn( id )
{
	if ( !is_mvm_game )
		return PLUGIN_CONTINUE
	
	new model[64]
	pev(id, pev_model, model, 63)
	if ( !equal("models/player.mdl", model) )
		return PLUGIN_CONTINUE			// Fix for a possible exploit
	
	modelchange(id)		// set new model
	
#if V_MODELS_AVAILABLE == 1
	// HA is not given at spawn but with a little delay
	set_task(0.5, "colourWeapon_timer", 300 + id)
#endif
	
	return PLUGIN_CONTINUE
}

public client_built( idPlayer , idStructure , type , impulse )
{
	if ( !is_mvm_game )
		return
	
	new model_index = -1
	switch ( impulse )
	{
		case 40:
		{
			model_index = ENTITY_IP
		}
		case 41:
		{
			model_index = ENTITY_RESOURCETOWER
		}
		case 43:
		{
			model_index = ENTITY_TURRETFACTORY
		}
		case 45:
		{
			model_index = ENTITY_ARMSLAB
		}
		case 46:
		{
			model_index = ENTITY_PROTOLAB
		}
		case 48:
		{
			model_index = ENTITY_ARMORY
		}
		case 51:
		{
			model_index = ENTITY_OBSERVATORY
		}
		case 55:
		{
			model_index = ENTITY_PHASEGATE
		}
		case 56:
		{
			model_index = ENTITY_SENTRY
		}
		case 57:
		{
			model_index = ENTITY_SIEGE
		}
		case 58:
		{
			model_index = ENTITY_CC
		}
	}
	
	if ( model_index != -1 )
		blue_red_model_change(idStructure, model_index)
}

public FM_EmitSound_hook( id )
{
	if ( id == g_emitsound_ID )
		return FMRES_SUPERCEDE
	
	return FMRES_IGNORED
}

public FM_StartFramePost_hook( )
{
	for ( SFP_id = g_maxplayers + 1; SFP_id <= max_entities; ++SFP_id )
	{
		if ( !pev_valid(SFP_id) )
			continue
		
		if ( !(pev(SFP_id, pev_iuser4) & MASK_ELECTRICITY) )
			continue
		
		set_pev(SFP_id, pev_rendercolor, Marine2_redercolor)
	}
}

//////////////////// MvM_allinone ////////////////////

public amx_mvm_convert( id , level , cid )
{
	if ( !cmd_access(id, level, cid, 1) )
		return PLUGIN_HANDLED
	
	new mapname[32]
	new map_len = read_argv(1, mapname, 31)
	if ( strlen(mapname) > 0 )
	{
		if ( !is_map_valid(mapname) )
		{
			console_print(id, "[AMXX] %L", id, "MAP_NOT_FOUND")
			
			return PLUGIN_HANDLED
		}else
		{
			log_amx("MvM_allinone >> Mapchange in progress, %s will be converted", mapname)
			
			set_vaultdata("nsmvm_convert", "1")
			set_task(5.0, "chMap", 0, mapname, map_len + 1)
		}
	}
	
	return PLUGIN_HANDLED
}

public chMap( map[] )
{
	server_cmd("changelevel %s", map)
}

public amx_mvm_handle_say( id )
{
	if ( is_mvm_game )
		return PLUGIN_HANDLED
	
	new configpath[60], filename[128], mapname[64]
	get_mapname(mapname,63)
	get_configsdir(configpath,60)
	formatex(filename, 127, "%s/mvm_configs/%s.cfg", configpath, mapname)		// Name of file to parse
	if ( file_exists(filename) )
	{
		if ( get_gametime() - last_vote > 60.0 )
		{
			new keys = (1<<0) | (1<<1) | (1<<9)
			new menu_body[128]
			copy(menu_body, 127, "Start this map in MvM mode ? (map will be restarted if successful)^n^n1. Yes^n2. No")
			for ( new player = 1; player <= g_maxplayers; ++player )
			{
				if ( !is_user_connected(player) )
					continue
				
				show_menu(player, keys, menu_body)
			}
			
			last_vote = get_gametime()
			set_task(15.0, "check_votes", 400)
		}else
			client_print(id, print_chat, "MvM_allinone >> You need to wait longer before you can vote again for MvM mode")
	}else
		client_print(id, print_chat, "MvM_allinone >> No MvM config found for map ^"%s^"", mapname)
	
	return PLUGIN_HANDLED
}

public count_votes( id , key )
{
	if ( key >= 9
		|| player_voted[id] )
		return PLUGIN_HANDLED
	
	vote_option[key] += 1
	voters += 1
	player_voted[id] = key + 1
	
	return PLUGIN_HANDLED
}

public check_votes( )
{
	for ( new id = 1; id <= g_maxplayers; ++id )
	{
		if ( is_user_connected(id) )
			client_cmd(id, "slot10")
		
		player_voted[id] = 0
	}
	
	new winner
	if ( vote_option[0] > vote_option[1] )
		winner = 0
	else
		winner = 1
	
	new cur_players = get_playersnum()
	if ( cur_players )
	{
		new players_needed = floatround( 0.5 * float( cur_players ) ,floatround_ceil)
		client_print(0, print_chat, "MvM_allinone >> Vote results: (voters %i) / (yes %i) (no %i) / (need to win %i)", voters, vote_option[0], vote_option[1], players_needed)
		if ( winner == 0
			&& vote_option[0] >= players_needed )
		{
			client_print(0, print_chat, "MvM_allinone >> This map will now be played in MvM mode in 5 seconds")
			
			set_vaultdata("nsmvm_convert", "1")
			new mapname[64]
			get_mapname(mapname,63)
			
			log_amx("Mvm_allinone >> Mapchange in progress via vote, %s will be converted on load", mapname)
			
			set_task(5.0, "chMap", 0, mapname, strlen(mapname))
		}else if ( winner == 1 )
			client_print(0, print_chat, "MvM_allinone >> This map will stay MvA")
	}
	
	voters = 0
	vote_option[0] = 0
	vote_option[1] = 0
}

public event_Countdown( )
{
	if ( get_cvar_num("mp_ctgactive") != 1 )
		cc_armory_RT_model_change(ENTITY_CC)
	
	cc_armory_RT_model_change(ENTITY_ARMORY)
	
	if ( !is_combat_running )
		cc_armory_RT_model_change(ENTITY_RESOURCETOWER)
	
	if ( is_valid_ent(temp_hive_id) )
		remove_entity(temp_hive_id)
	
	new ent = -1
	while ( ( ent = find_ent_by_class(ent, "team_hive") ) > 0 )
		remove_entity(ent)
	
	for ( new id = 1; id <= g_maxplayers; ++id )
	{
		if ( is_user_connected(id) )
			modelchange(id)
	}
	
	return PLUGIN_HANDLED
}

#if V_MODELS_AVAILABLE == 1
public event_ChangeWeapon( id )
{
	if ( read_data(1) != 6 )	// 6 = change to weapon, 4 = change from weapon
		return PLUGIN_CONTINUE
	
	curweapon[id] = read_data(2)
	
	colourWeapon(id)
	
	return PLUGIN_CONTINUE
}
#endif

public event_ResetHUD( id )
{
	new team = pev(id, pev_team)
	
	if ( AJrunning
		&& ( team < 1 || team > 4 ) )
		client_cmd(id, "autoassign")
}

public event_TeamChanges( )
{
	new teamname[32], id = read_data(1)
	read_data(2,teamname, 31)
	if ( equal(teamname, "marine1team") )
		player_team[id] = MARINE
	else if ( equal(teamname, "marine2team") )
		player_team[id] = MARINE2
}

public event_Fix_teams( id )
{
	message_begin(MSG_ONE, get_user_msgid("TeamNames"), {0, 0, 0}, id)
	write_byte(MAXTEAMS)
	for( new i = 0; i < MAXTEAMS; ++i )
		write_string(teamnames[i])
	message_end()
}

public editScoreInfo( )
{
	new arg7 = get_msg_arg_int(8)
	if ( arg7 == tMarine2
		|| arg7 == tDefender )
		set_msg_arg_int(8, ARG_SHORT, tAlien2)
}

public editHudText2( dummy , dummy2 , receiver )
{	// Change "The Marine Team ..." to "The Blue/Red ..."
	if ( !is_user_connected(receiver) )
		return PLUGIN_CONTINUE
	
	new szMessage[64]
	get_msg_arg_string(1, szMessage, 63)
	
	new szMsg[64]
	if ( equal(szMessage, "TeamOneWon") )
	{
		formatex(szMsg, 63, "The %s Team Won The Game!", TEAM1_NAME)
		set_msg_arg_string(1, szMsg)
	}else if ( equal(szMessage, "TeamTwoWon") )
	{
  		formatex(szMsg, 63, "The %s Team Won The Game!", TEAM4_NAME)
		set_msg_arg_string(1, szMsg)
	}else if ( equal(szMessage, "GameDraw") )
	{
  		copy(szMsg, 10, "Tie Game!")
		set_msg_arg_string(1, szMsg)
	}
	
	return PLUGIN_CONTINUE
}

public amx_mvm_auto( id , level , cid )
{
	if ( !cmd_access(id, level, cid, 2) )
		return PLUGIN_HANDLED
	
	new onoff[5]
	read_argv(1, onoff, 4)
	if ( equal(onoff, "on")
		|| equal(onoff, "1") )
	{
		if ( AJrunning == 1 )
		{
			console_print(id, "MvM Autoassign already enabled")
		}else
		{
			AJrunning = 1
			console_print(id, "MvM Autoassign enabled")
			autoassign_players()
		}
		return PLUGIN_HANDLED
	}
	if ( equal(onoff, "off")
		|| equal(onoff, "0") )
	{
		if ( AJrunning == 0 )
		{
			console_print(id, "MvM Autoassign already disabled")
		}else
		{
			AJrunning = 0
			console_print(id, "MvM Autoassign disabled")
		}
		return PLUGIN_HANDLED
	}
	return PLUGIN_HANDLED
}

public jointeamtwo_fix( id )
{
	if ( player_team[id] == NOTEAM )
		client_cmd(id, "jointeamthree")
}

public editPlayHUDNot( dummy , dummy2 , receiver )
{
	if ( get_msg_arg_int(1) != 1 )	// 1 = build notification
		return
	
	if ( ns_get_class(receiver) != CLASS_COMMANDER )
		return
	
	if ( pev(receiver, pev_team) != MARINE2 )
		return
	
	new param[4] = {-1, -1, 0, 0}
	param[0] = pev(receiver, pev_team)
	switch ( get_msg_arg_int(2) )	// type of build notification
	{
		case 20..22:	// armslab: armor
		{
			param[1] = UPGRADE_ARMOR
		}
		case 23..25:	// armslab: weapon
		{
			param[1] = UPGRADE_WEAPON
		}
		case 26:	// TF: avanced TF
		{
			param[1] = UPGRADE_ADVTF
		}
		case 28:	// protolab: jetpack
		{
			param[1] = UPGRADE_JETPACK
		}
		case 29:	// protolab: heavy
		{
			param[1] = UPGRADE_HEAVY
		}
		case 33:	// obs: motion track
		{
			param[1] = UPGRADE_MOTION
		}
		case 34:	// obs: phase
		{
			param[1] = UPGRADE_PHASE
		}
		case 36:	// TF + RT: electrify
		{
			param[1] = UPGRADE_ELECTRIFY
		}
		case 37:	// armory: hand grenade
		{
			param[1] = UPGRADE_GRENADE
		}
		case 47:	// armslab: catalyst
		{
			param[1] = UPGRADE_CATALYST
		}
		case 49:	// armory: advanced armory
		{
			param[1] = UPGRADE_ADVARMORY
		}
		
	}
	
	param[2] = _:get_msg_arg_float(3)
	param[3] = _:get_msg_arg_float(4)
	if ( param[1] != -1 )
	{
		++buildings_to_upgrade
		set_task(0.1, "find_ent_playhud_timer", 1000 + buildings_to_upgrade * floatround(Float:param[2]), param, 4)
	}
}

public editSVC_TEMPENTITY( dummy , dummy2 , receiver )
{
	if ( get_msg_arg_int(1) != TE_BEAMENTPOINT )
		return
	
	new id = get_msg_arg_int(2)
	if ( !is_user_connected(id) )
		return
	
	if ( player_team[id] != MARINE2 )
		return
	
	// args 12-14 = R G B
	set_msg_arg_int(12, ARG_BYTE, floatround(Marine2_redercolor[0]))
	set_msg_arg_int(13, ARG_BYTE, floatround(Marine2_redercolor[1]))
	set_msg_arg_int(14, ARG_BYTE, floatround(Marine2_redercolor[2]))
}

//////////////////// Additional Functions ////////////////////
cc_armory_RT_model_change( entity_index )
{
	new cc_armory_RT_id = -1
	new Float:MinBox[3]
	new Float:MaxBox[3]
	new Float:orig[3]
	while ( ( cc_armory_RT_id = find_ent_by_class(cc_armory_RT_id, entity_name[entity_index - 2]) ) > 0 )
	{
		pev(cc_armory_RT_id, pev_origin, orig)
		pev(cc_armory_RT_id, pev_mins, MinBox)
		pev(cc_armory_RT_id, pev_maxs, MaxBox)
		
		entity_set_model(cc_armory_RT_id, mvm_models[entity_index])
		if( pev(cc_armory_RT_id, pev_team) == MARINE2 )
			set_pev(cc_armory_RT_id, pev_skin, 1)
		
		set_pev(cc_armory_RT_id, pev_mins, MinBox)
		set_pev(cc_armory_RT_id, pev_maxs, MaxBox)
		entity_set_origin(cc_armory_RT_id, orig)
		set_pev(cc_armory_RT_id, pev_solid, SOLID_BBOX)
	}
}

modelchange( id )
{
	// if no teamname but in a team check in 0.1 secs again else stop and set model
	if ( !player_team[id] )
	{
		set_task(0.1, "modelchange_timer", 200 + id)
		
		return
	}
	
	if( ns_get_class(id) == CLASS_HEAVY )
		ns_set_player_model(id, mvm_models[ENTITY_HEAVY])
	else
		ns_set_player_model(id, mvm_models[ENTITY_MARINE])
	
	if ( player_team[id] == MARINE2 )
		set_pev(id, pev_skin, 1)
	else
		set_pev(id, pev_skin, 0)
}

#if V_MODELS_AVAILABLE == 1
colourWeapon( id )
{
	new model_index
	switch( curweapon[id] )
	{
		case WEAPON_KNIFE:
			model_index = V_KNIFE
		case WEAPON_PISTOL:
			model_index = V_PISTOL
		case WEAPON_LMG:
			model_index = V_LIGHTMACHINEGUN
		case WEAPON_SHOTGUN:
			model_index = V_SHOTGUN
		case WEAPON_HMG:
			model_index = V_HEAVYMACHINEGUN
		case WEAPON_WELDER:
			model_index = V_WELDER
		case WEAPON_MINE:
			model_index = V_MINE
		case WEAPON_GRENADE_GUN:
			model_index = V_GRENADEGUN
		case WEAPON_GRENADE:
			model_index = V_GRENADE
		default:
			return
	}
	
	if ( ns_get_class(id) == CLASS_HEAVY )
		set_pev(id, pev_viewmodel2, mvm_v_models_heavy[model_index])
	else
		set_pev(id, pev_viewmodel2, mvm_v_models_light[model_index])
}
#endif

autoassign_players( )
{
	for ( new id = 1; id <= g_maxplayers; ++id )
	{
		if ( !is_user_connected(id) )
			continue
		
		if ( !pev(id, pev_team) )
			client_cmd(id, "autoassign")
	}
}

find_ent_playhud( check_team , classname[] , mode , Float:xcoord , Float:ycoord )
{
	new entid = -1, Float:fuser1_value
	new Float:origin[3]
	while ( ( entid = find_ent_by_class(entid, classname) ) > 0 )
	{
		if ( pev(entid, pev_team) != check_team )
			continue
		
		pev(entid, pev_fuser1, fuser1_value)
		if ( fuser1_value <= 2000.0
			|| fuser1_value >= 2100.0 )
			continue
		
		pev(entid, pev_origin, origin)
		if ( origin[0] != xcoord
			|| origin[1] != ycoord )
			continue
		
		upgrade_building[buildings_to_upgrade - 1] = entid
		upgrade_building_mode[buildings_to_upgrade - 1] = mode
		
		break
	}
}

respawn_building( source )
{
	new iuser3
	new Float:fuser2, Float:health
	
	iuser3 = pev(source, pev_iuser3)
	pev(source, pev_fuser2, fuser2)
	pev(source, pev_health, health)
	
	g_emitsound_ID = source
	
	DispatchKeyValue(source, "teamchoice", "3")
	DispatchKeyValue(source, "spawnflags", "1")
	DispatchSpawn(source)
	
	set_pev(source, pev_fuser2, fuser2)
	set_pev(source, pev_health, health)
	ns_set_mask(source, MASK_BUILDABLE, 0)
	
	set_pev(source, pev_sequence, 2)
	
	if ( iuser3 == 27 )
		blue_red_model_change(source, ENTITY_ARMSLAB)
	else
		blue_red_model_change(source, ENTITY_OBSERVATORY)
	
	g_emitsound_ID = 0
}

public check_elec_color( )
{
	new Float:redercolor[3] = {200.0, 0.0, 0.0}
	for ( new id = g_maxplayers + 1; id <= get_global_int(GL_maxEntities); ++id )
	{
		if ( !pev_valid(id) )
			continue
		
		if ( !(pev(id, pev_iuser4) & MASK_ELECTRICITY) )
			continue
		
		set_pev(id, pev_rendercolor, redercolor)
	}
}

play_upgrade_sound( comm_id , Float:origin[3] )
{
	if ( comm_id == -1 )
		return
	
	message_begin(MSG_ONE, g_msgPlayHUDNot, {0, 0, 0}, comm_id)
	write_byte(0)		// 0 = sound notification
	write_byte(10)		// HUD_SOUND_MARINE_RESEARCHCOMPLETE
	write_coord(floatround(origin[0]))
	write_coord(floatround(origin[1]))
	message_end()
	
}

find_commander_team2( )
{
	for ( new id = 1; id <= g_maxplayers; ++id )
	{
		if ( !is_user_connected(id) )
			continue
		
		if ( player_team[id] != MARINE2 )
			continue
		
		if ( ns_get_class(id) != CLASS_COMMANDER )
			continue
		
		return id
	}
	
	return -1
}

blue_red_model_change( idStructure , model_index )
{
	new Float:MinBox[3]
	new Float:MaxBox[3]
	new Float:orig[3]
	
	pev(idStructure, pev_origin, orig)
	pev(idStructure, pev_mins, MinBox)
	pev(idStructure, pev_maxs, MaxBox)
	
	entity_set_model(idStructure, mvm_models[model_index])
	if ( pev(idStructure, pev_team) == MARINE2 )
		set_pev(idStructure, pev_skin, 1)
	
	set_pev(idStructure, pev_mins, MinBox)
	set_pev(idStructure, pev_maxs, MaxBox)
	entity_set_origin(idStructure, orig)
	set_pev(idStructure, pev_solid, SOLID_BBOX)
}

//////////////////// CONVERTER ////////////////////
load_configs( filename[] )
{
	new file = fopen(filename, "r")
	
	if ( !file )
	{
		log_amx("MvM_allinone >> Unable to read from ns_map file ^"%s^"", filename)
		
		return
	}
	
	new line_buffer[256]
	while ( fgets(file, line_buffer, 127) )
	{
		if ( ( line_buffer[0] == '^n' )						// empty line
			|| ( line_buffer[0] == 10 && line_buffer[1] == '^n' )		// empty line
			|| ( line_buffer[0] == '/' && line_buffer[1] == '/' )		// comment
			|| ( line_buffer[0] == '#' ) )					// another comment
			continue
		
		if ( equal(line_buffer, "armory1") )
		{
			armory_team1_set = 1
		}else if ( equal(line_buffer, "armory2") )
		{
			armory_team2_set = 1
		}else if ( equal(line_buffer, "spawnpoints2") )
		{
			spawnpoint_team2_set = 1
		}else
		{
			if ( CC_data_num < 4 )
			{
				copy(CC_origin_angles[CC_data_num], 19, line_buffer)
				++CC_data_num
			}else if ( armory_team1_set )
			{
				copy(Armory_origin_team1, 19, line_buffer)
				armory_team1_set = 0
			}else if ( armory_team2_set )
			{
				copy(Armory_origin_team2, 19, line_buffer)
				armory_team2_set = 0
			}else if ( spawnpoint_num_team1 < 32 && !spawnpoint_team2_set )
			{
				copy(spawnpoint_origin_team1[spawnpoint_num_team1], 19, line_buffer)
				++spawnpoint_num_team1
			}else if ( spawnpoint_num_team2 < 32 )
			{
				copy(spawnpoint_origin_team2[spawnpoint_num_team2], 19, line_buffer)
				++spawnpoint_num_team2
			}
		}
	}
}
////////////////////////////////////////////////////////////


//////////////////// Timer Functions ////////////////////
public check_upgrade_timer( )
{
	new Float:fuser1_value
	new reducer
	for ( new i = 0; i < buildings_to_upgrade; ++i )
	{
		if ( !upgrade_building[i] )
			continue
		
		if ( !pev_valid(upgrade_building[i]) )
		{
			upgrade_building[i] = 0
			++reducer
			
			continue
		}
		
		pev(upgrade_building[i], pev_fuser1, fuser1_value)
		
		// upgrade has been canceled, reset data
		if ( fuser1_value == 2000.0 )
		{
			upgrade_building[i] = 0
			++reducer
			
			continue
		}
		
		if ( fuser1_value != 0.0 )
			continue
		
		new comm_id = find_commander_team2()
		new Float:origin[3]
		pev(upgrade_building[i], pev_origin, origin)
		
		if ( UPGRADE_WEAPON <= upgrade_building_mode[i] <= UPGRADE_MOTION )
		{
			respawn_building(upgrade_building[i])
		}
		
		play_upgrade_sound(comm_id, origin)
		
		upgrade_building[i] = 0
		++reducer
	}
	
	if ( reducer )
	{
		new j
		for ( new i = 0; i < buildings_to_upgrade; ++i )
		{
			if ( upgrade_building[i] )
				continue
			
			for ( j = i + 1; j < buildings_to_upgrade; ++j )
			{
				if ( upgrade_building[j] )
					break
			}
			
			if ( j >= buildings_to_upgrade )
				continue
			
			upgrade_building[i] = upgrade_building[j]
			upgrade_building[j] = 0
		}
		
		buildings_to_upgrade -= reducer
	}
}

public modelchange_timer( timerid_id )
{
	new id = timerid_id - 200
	if ( !is_user_connected(id) )
		return
	
	new teamname[32]
	get_user_team(id, teamname, 31)
	if ( equal(teamname, "marine1team") )
		player_team[id] = MARINE
	else if ( equal(teamname, "marine2team") )
		player_team[id] = MARINE2
	
	modelchange(id)
}

#if V_MODELS_AVAILABLE == 1
public colourWeapon_timer( timerid_id )
{
	new id = timerid_id - 300
	if ( !is_user_connected(id) )
		return
	
	// this timer was called for HAs only, so ignore other
	if ( ns_get_class(id) == CLASS_HEAVY )
		colourWeapon(id)
}
#endif

public find_ent_playhud_timer( param[] )
{
	switch ( param[1] )
	{
		case UPGRADE_ARMOR, UPGRADE_WEAPON, UPGRADE_CATALYST:
		{
			find_ent_playhud(param[0], "team_armslab", param[1], Float:param[2], Float:param[3])
		}
		case UPGRADE_MOTION, UPGRADE_PHASE:
		{
			find_ent_playhud(param[0], "team_observatory", param[1], Float:param[2], Float:param[3])
		}
		case UPGRADE_GRENADE, UPGRADE_ADVARMORY:
		{
			find_ent_playhud(param[0], "team_armory", param[1], Float:param[2], Float:param[3])
		}
		case UPGRADE_JETPACK, UPGRADE_HEAVY:
		{
			find_ent_playhud(param[0], "team_prototypelab", param[1], Float:param[2], Float:param[3])
		}
		case UPGRADE_ADVTF:
		{
			find_ent_playhud(param[0], "team_turretfactory", param[1], Float:param[2], Float:param[3])
		}
		case UPGRADE_ELECTRIFY:
		{
			find_ent_playhud(param[0], "team_turretfactory", param[1], Float:param[2], Float:param[3])
			find_ent_playhud(param[0], "resourcetower", param[1], Float:param[2], Float:param[3])
		}
	}
}

//////////////////// These functions are called by other plugins to get/set variables ////////////////////

public client_help( id )
{
	help_add("Information", "Allows play maps in Marine vs Marine mode")
	help_add("Usage", "Type in chat: (only in MvA mode)^n/votemvm -> To open a vote to play current map in MvM mode^n           -> (only if a config exists)")
}

public client_advertise( id )
{
	if ( !is_mvm_game )
		return PLUGIN_HANDLED
	
	return PLUGIN_CONTINUE
}

stock bool:help_add( caption[] , content[] )
{
	if ( is_helper_running == -1 )
		return false
	
	new func = get_func_id("help_add", is_helper_running)
	if ( func == -1 )
		return false
	
	if ( callfunc_begin_i(func, is_helper_running) != 1)
		return false
	
	callfunc_push_str(caption)
	callfunc_push_str(content)
	return callfunc_end() ? true : false
}