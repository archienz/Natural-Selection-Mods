// resupply hook: kein ammo spawn BUT value change ns_set_reserve

/*
* Plugin: Gnome Builder
*
* Features:
*	-> gnome model
*	-> speed, armor, health changes
*	-> double speed build/weld (-attack)
*	-> crazy knockback on hit
*	-> not allowed to pick/get HA/JP/heavy weapons
*	-> uses resized weapons
*	-> commander can gnome and ungnome people
*	-> cant move further than defined Commchair radius
*	-> gnome self-welding (look at feet and weld)
*	-> gnome cant go commander (only if only alive player he can)
*
* Author:
*	-> White Panther, Zamma
*
* Modeler:
*	-> Depot (ds^Depot)
*
* Tester:
*	-> Depot (ds^Depot), White Panther
*
* Credits:
*	-> -mE-		-	for teleport effect
*	-> esuna	-	for the pick model
*
* Usage:
*	COMMANDS:
*		- amx_gnome <on / off OR 1 / 0>		-> turns Gnome on and off
*		- amx_gnome_make <name>			-> specified player becomes gnome, no name = random player
*		- amx_ungnome				-> all Gnomes become normal players
*	CHAT:
*		- in chat say "/gnomeme" or "/gnome me" to become a gnome
*		- in chat say "/ungnomeme" or "/ungnome me" to become normal marine (only if the only player)
*		- if commander: say "/gnome <username>", player with username becomes gnome
*			say "/ungnome", player who is gnome will become normal marine
*	
*	CVARS:
*		- mp_gnome_damage_amplifier	-> damage multiplier for gnome weapons (default 3.0)
*		- mp_gnome_damage_pick_only	-> define if only pick gets damage multiplier (default on)
*		- mp_gnome_auto			-> defines if gnome if automatically created on countdown (default off)
*
* v0.3.3:
*	- initial release
*
* v0.4.2:
*	- fixed:
*		- possiblity of regaining normal speed after death
*		- "/ungnome" needed a name
*		- double weld/build working correctly (its double now not only a bit faster)
*		- new random gnome could have ha/jp/heavy weapons
*		- camera view is adjusted to gnome height
*		- getting resuply while being digested
*		- gnome could respawn with hmg/gl/shotty in combat
*	- added:
*		- welding people is now at double speed/damage too
*		- gnome cannot get out of commchair radius (you can increase with new Commchairs)
*		- gnome self-welding
*
* v0.5.1:
*	- fixed:
*		- acidrocket and spit have not done knockback
*		- parasite / spike / spore did knockback
*		- gnomes pick does more damage (default twice)
*		- med packs are now only picked up if needed
*		- when gnomed in ns games lmg is not dropped anymore
*	- added:
*		- gnome can only go Commander if he is the only player or the only marine alive
*			(if a marine spawns and gnome is not the only alive marine after 10 secs, he gets ejected)
*		- player can gnome/ungnome himself:
*			- in combat he can gnome anytime if there is no other gnome (but not ungnome, would be too unfair though)
*			- in ns he can gnome and ungnome if he is the only player
*		- a define to choose if only pick should make extra damage
*		- when gnome gets ungnomed, he will receive his old equipment (in ns only if not died)
*		- cvar for amplified damage and if only pick is allowed to use it
*			- "mp_gnome_damage_amplifier" (default 3.0) and "mp_gnome_damage_pick_only" (default on)
*
* v0.5.6b:
*	- fixed:
*		- gnome could respawn with hmg/gl/shotty in combat (again)
*		- when carrieng heavy weapon and got gnomed, no primary weapon existed
*		- when gnome got jetpack (with another plugin or cheats) his model changed to normal marine with jetpack
*	- added:
*		- cvar to enabled auto gnome or not (on round start and when gnome leaves)
*			- "mp_gnome_auto" (default off)
*		- support for MvM
*		- u can now disable and enable the plug (amx_gnome 1/0) (old amx_gnome is now amx_gnome_make)
*		- with the define "GNOME_MODEL_COLOR" you can specify the gnome color in normal ns and co maps (look a bit more down)
*	- changed:
*		- auto gnome disabled for default
*		- now there is only 1 model instead of 2 (or 3)
*
* v0.6.3b: (compatability for ExtraLevels2 Rework 0.7.8b or higher)
*	- fixed:
*		- gnome could do instant kill (when did welder-kill and attacked this enemy again (after respawn) without attacking/welding others)
*		- aliens could get resupply upgrade (it was not working on them though but could spam medpacks everywhere)
*		- main CC was seen as build even if destroyed, therefore gnome still had a range ( due to NS, it was only on the main CC )
*		- minor runtime errors (due to tasks)
*		- resupply now works on 32 players
*		- spit and acidrocket could do a pull instead of a knockback
*		- in MvM: when blue gnome exists, the red gnome wont work correctly
*		- gnome can be on alien team (only due to other plugins possible)
*		- player could lose upgrades after he gnomed in combat (armor powerups, motion tracking, ...)
*		- gnome could not do extra damage versus buildings
*		- gnome could get knockback when damaged by doors, water, ...
*	- added:
*		- ExtraLevels2 Rework compatability (+)
*	- changed:
*		- it is now a bit easier for gnome to weld self
*		- way of setting fov
*		- gnome does not have a CC-range in co maps anymore
*		- code improvements
*
* v0.6.4:
*	- added:
*		- define for NS 3.03 (marine armor has increased)
*	- changes:
*		- moved from pev/set_pev to entity_get/entity_set
*
* v0.6.6:
*	- fixed:
*		- runtime error when someone gnomed
*	- changed:
*		- code improvements
*
* v0.6.8:
*	- changed:
*		- way of checking if MvM combat is running
*		- fakemeta module not needed anymore
*		- fun module not needed anymore
*
* v0.7:
*	- fixed:
*		- exploit where player could get resupply for free when using any version of extralevels
*	- changed:
*		- server_frame is hooked with ent and support other plugins that uses the same system (speed improvement thx OneEyed)
*		- rewrote check if gnomoe is in CC range to improve speed
*
* v0.7.3:
*	- fixed:
*		- player was not able to gnome on NS classic
*		- bug where commander could only use the gnome command once
*		- when commander ungnomed someone wrong name was shown
*		- gnome could go commander even when not allowed (when he is not the only alive player in team)
*	- changed:
*		- adjusted jump height to his size (3 defines added for each coord)
*
* v0.7.4b:
*	- fixed:
*		- Gnome could not do any damage (since Amx Mod X 1.5x)
*
* v0.7.5:
*	- fixed:
*		- Gnome could not do any damage (finally done)
*		- only when using extralevels2 rework:
*			- gnome armor upgrade has not been reset
*
* v0.7.5b:
*	- fixed:
*		- fixed runtime error on NS maps since amx mod X 1.6
*
* v0.7.6:
*	- fixed:
*		- commander saw gnome with low health even if he had full
*		- pointing at gnome now displays correct health and armor percentage (before, gnome was always seen as damaged)
*		- gnome was able to ungnome even when more players have been in his team
*	- added:
*		- with amx_gnome_make and following a name will now gnome that specified player
*
* v0.7.7a: (01/15/06)
*	- fixed:
*		- due to NS 3.1:
*			- player saw Pick even when changing weapon
*			- going to readyroom will now correctly reset gnome
*		- gnome could lose his upgrades on CO
*		- runtime errors
*/

#include <amxmodx>
#include <amxmisc>
#include <engine>
#include <fun>
#include <ns>

// set this to 0 if lower than 3.0.3
#define NS_303 1

#define GNOME_HEALTH		80.0	// gnome health
#define GNOME_ARMOR		50.0	// gnome armor
#define GNOME_SPEED		170	// gnome speed
#define GNOME_FOV		100.0	// gnome field of view (angle)
#define GNOME_RANGE		4000.0	// how far a gnome can get from Commchair
#define GNOME_DMG_AMPLIFIER	4.0	// specify how much damage (comparing to normal) shall be done
					// (eg: 1.0 = normal damage , 1.5 = 50% more damage , 2.0 = 100% more damge)
#define GNOME_DMG_PICK_ONLY	0	// set to 0 to give other gnome weapons amplified damage too
#define GNOME_MODEL_COLOR	0	// set the gnome color in normal ns and co maps (0 = green / 1 = blue / 2 = red)

#define GNOME_JUMP_ADJUST_X	1.3	// Jump X coord will be decreased by factor 1.2 ( results in approximately 50%)
#define GNOME_JUMP_ADJUST_Y	1.3	// Jump Y coord will be decreased by factor 1.2 ( results in approximately 50%)
#define GNOME_JUMP_ADJUST_Z	1.3	// Jump Z coord will be decreased by factor 1.2 ( results in approximately 50%)

#define PUSH_ANGLE		45	// x,y from - to + , z from 0 to +
#define BOOST_START		1000	// min boost for random
#define BOOST_END		3000	// max boost for random

#define	MARINE			0
#define	MARINE2			1
#define	NOTEAM			2

// ExtraLevels2 Rework compatibilities
new reinforced_ap[33]		// each players current "ExtraLevel2 Rework" ap upgrade
new gnome_ap_adds		// how much ap a gnome gets for each "ExtraLevel2 Rework" ap upgrade
new marine_armor_up, heavy_armor_up

new Float:gnome_view[3] = {0.0, 0.0, 7.0}		// camera height standing
new Float:gnome_view_duck[3] = {0.0, 0.0, 8.0}		// camera height ducking
new Float:gnome_ap_upgrade_value

new gnome_id[3], Float:gnome_build_time[3], Float:gnome_range_orig[3][3], gnome_items[3][32], gnome_item_xtra[3], gnome_died[3], gnome_mask[3]
new old_ent_id[3], old_toucher[3], old_toucher_id[3], Float:attacker_vec[3][3]
new allow_comm_gnome[3], Float:gnome_weap_bas_damage[3][4]
new gnome_jumped[3]

new Float:ent_old_status[3], Float:ent_new_status[3], Float:ent_stat_change[3]
new Float:ent_old_hp[3], Float:ent_new_hp[3], Float:ent_hp_change[3]
new Float:ent_old_ap[3], Float:ent_new_ap[3], Float:ent_ap_change[3]

new running_combat, is_mvm_combat, mvm_allinone_loaded, xtralvl2_rewo_loaded, override, GNOMErunning = 1
new teleport_event, max_player_num, max_entities
new resupply[33], fix_gnome_status[33]
new player_team[33] = {NOTEAM,...}
new Float:tried_comm_time[33]
new player_to_gnome

new plugin_author[] = "White Panther/Zamma/Depot"
new plugin_version[] = "0.7.7"

/* Init and forwards */
public plugin_init( )
{
	register_plugin("Gnome Builder", plugin_version, plugin_author)
	register_cvar("gnome_version", plugin_version, FCVAR_SERVER)
	register_event("Countdown", "eCountdown", "ab")
	register_event("Damage", "eDamage", "b", "2!0")
	register_event("DeathMsg", "eDeath", "a")
	register_event("CurWeapon", "eChange_weapon", "b")
	register_event("TeamInfo", "eTeamChanges", "ab")
	
	register_concmd("amx_gnome", "gnome_onoff", ADMIN_LEVEL_B, "on/off OR 1/0 to turn Gnome on and off")
	register_concmd("amx_gnome_make", "amx_gnome_make", ADMIN_LEVEL_B, "<name> : specified player becomes gnome, no name = random player")
	register_concmd("amx_ungnome", "amx_ungnome", ADMIN_LEVEL_B, "all Gnomes become normal players")
	register_clcmd("say", "handle_say")
	register_clcmd("say_team", "handle_say")
	
	register_message(get_user_msgid("StatusValue"), "editStatusValue")
	register_message(get_user_msgid("HudText2"), "editHudText2")
	
	max_player_num = get_maxplayers()
	max_entities = get_global_int(GL_maxEntities)
	running_combat = ns_is_combat()
	teleport_event = precache_event(1, "events/Teleport.sc")
	
	new name[32], version[32], author[32], filename[32], status[32]
	for ( new i = 0; i < get_pluginsnum(); i++ )
	{
		get_plugin(i, filename, 31, name, 31, version, 31, author, 31, status, 31)
		if ( equal(filename, "mvm_allinone.amxx") )
		{
			if ( equal(status, "running") || equal(status, "debug") )
				mvm_allinone_loaded = 1
		}else if ( equal(filename, "extralevels2_rework.amxx") )
		{
			if ( equal(status, "running") || equal(status, "debug") )
				xtralvl2_rewo_loaded = 1
		}
	}
	
	new ccid = -1, count 
	while ( ( ccid = find_ent_by_class(ccid, "team_command") ) > 0 )
		count++ 
	
	if ( count > 1 && running_combat )
		is_mvm_combat = 1
	
	new num_str[5]
	format(num_str, 4, "%f", GNOME_DMG_AMPLIFIER)
	register_cvar("mp_gnome_damage_amplifier", num_str)
	format(num_str, 4, "%i", GNOME_DMG_PICK_ONLY)
	register_cvar("mp_gnome_damage_pick_only", num_str)
	register_cvar("mp_gnome_auto", "0")
	
	allow_comm_gnome[0] = 1
	allow_comm_gnome[1] = 1
	gnome_ap_upgrade_value = ( GNOME_ARMOR * 8 / 10 )
	
	new fakeEnt = find_ent_by_class(-1, "ServerFrameFake")
	if ( fakeEnt <= 0 )
	{
		fakeEnt = create_entity("info_target")
		entity_set_string(fakeEnt, EV_SZ_classname, "ServerFrameFake")
		entity_set_float(fakeEnt, EV_FL_nextthink, halflife_time() + 0.01)
	}
	register_think("ServerFrameFake", "server_frame_fake")
}

public editStatusValue( dummy , dummy2 , receiver )
{
	if ( !is_user_connected(receiver) )
		return PLUGIN_CONTINUE
	
	new gnome_num = player_team[receiver]
	if ( get_msg_arg_int(1) == 1 )
	{
		new arg2 = get_msg_arg_int(2)
		if ( arg2 == gnome_id[gnome_num] )
			fix_gnome_status[receiver] = 1
		else if ( arg2 >= -1 )
			fix_gnome_status[receiver] = 0
	}else if ( fix_gnome_status[receiver] )
	{
		if ( get_msg_arg_int(1) == 2 )
		{
			new hp_percentage = floatround( 100.0 / GNOME_HEALTH * entity_get_float(gnome_id[gnome_num], EV_FL_health) )
			set_msg_arg_int(2, ARG_SHORT, hp_percentage)
		}else if ( get_msg_arg_int(1) == 3 )
		{
			new Float:max_ap = gnome_ap_upgrade_value * check_armor_upgrade(gnome_id[gnome_num]) + GNOME_ARMOR		// 80% of GNOME_ARMOR * amount of armor upgrades + standard armor
			new ap_percentage = floatround( 100.0 / max_ap * entity_get_float(gnome_id[gnome_num], EV_FL_armorvalue) )
			set_msg_arg_int(2, ARG_SHORT, ap_percentage)
		}
	}
	
	return PLUGIN_CONTINUE
}

public editHudText2( dummy , dummy2 , receiver )
{	// Check if player got "ReadyRoomMessage" to determine if player switched to readyroom
	if ( !is_user_connected(receiver) )
		return PLUGIN_CONTINUE
	
	new szMessage[21]
	get_msg_arg_string(1, szMessage, 20)
	
	if ( equal(szMessage, "ReadyRoomMessage") )
	{
		new gnome_num = player_team[receiver]
		if ( receiver == gnome_id[gnome_num] )
		{
			free_gnome(receiver, gnome_num, 1)
			set_task(0.1, "eCountdown", 654321 + receiver)
		}
		player_team[receiver] = NOTEAM
		reinforced_ap[receiver] = 0
	}
	
	return PLUGIN_CONTINUE
}

public client_impulse( id , impulse )
{
	if ( running_combat )
	{
		if ( CLASS_MARINE <= ns_get_class(id) <= CLASS_COMMANDER )
		{
			// Resupply
			if ( impulse == 31 )
			{
				if ( is_user_alive(id) )
				{
					if ( !resupply[id] )
					{
						if ( check_points_spend_or_level(id) )
						{
							ns_set_points(id, ns_get_points(id) + 1)
							resupply[id] = 1
							resupply_player(id, 1)
							new Userid[1]
							Userid[0] = id
							set_task(3.0, "resupply_timer", 2000 + id, Userid, 1, "b")
						}
					}
				}
				return PLUGIN_HANDLED
			}
			
			if ( GNOMErunning )
			{
				if ( id == gnome_id[0] || id == gnome_id[1] )
				{
					// HA, JP, Welder, Shotgun, HMG, GL
					if ( impulse == 38 || impulse == 39 || impulse == 62 || impulse == 64 || impulse == 65 || impulse == 66 )
						return PLUGIN_HANDLED
				}
			}
		}
	}
	return PLUGIN_CONTINUE
}

public client_connect( id )
{
	if ( running_combat )
	{
		resupply[id] = 0
		remove_task(2000 + id)
	}
}

public client_disconnect( id )
{
	// stop resupply task
	if ( running_combat )
	{
		resupply[id] = 0
		remove_task(2000 + id)
	}
	
	if ( GNOMErunning )
	{
		new gnome_num = player_team[id]
		
		if ( id == gnome_id[gnome_num] )
		{
			free_gnome(id, gnome_num)
			set_task(0.1, "eCountdown", 654321 + id)
		}
	}
}

public client_changeclass( id , newclass , oldclass )
{
	if ( is_user_connected(id) )
	{
		if ( running_combat )
		{
			if ( newclass == CLASS_UNKNOWN || newclass == CLASS_NOTEAM )
			{	// Unknown or Noteam
				resupply[id] = 0
				remove_task(2000+id)
			}else if ( newclass == CLASS_DEAD )		// Dead
				remove_task(2000+id)
		}
		if ( GNOMErunning )
		{
			new gnome_num = player_team[id]
			if ( id == gnome_id[gnome_num] )
			{
				if ( newclass == CLASS_UNKNOWN || newclass == CLASS_NOTEAM )
				{	// Unknown or Noteam
					free_gnome(id, gnome_num, 1)
					set_task(0.1, "eCountdown", 654321 + id)
				}else if ( newclass == CLASS_DEAD )
				{	// Dead
					gnome_died[gnome_num] = 1
				}else if ( newclass == CLASS_JETPACK )
				{
					set_gnome_model(id,gnome_num)
					entity_set_int(id, EV_INT_body, 1)
				}
			}
		}
	}
}

public client_changeteam( id , newteam , oldteam )
{
	if ( GNOMErunning )
	{
		if ( newteam < 1 || newteam > 4 )
		{
			new gnome_num = player_team[id]
			if ( id == gnome_id[gnome_num] )
			{
				free_gnome(id, gnome_num, 1)
				set_task(0.1, "eCountdown", 654321 + id)
			}
			player_team[id] = NOTEAM
			reinforced_ap[id] = 0
		}
	}
}

public plugin_precache( )
{
	precache_model("models/gnome/gnomeall.mdl")
	precache_model("models/p_welder_gnome.mdl")
	precache_model("models/p_pick.mdl")
	precache_model("models/v_pick.mdl")
	precache_model("models/p_hg_gnome.mdl")
	precache_model("models/p_mg_gnome.mdl")
}

public pfn_touch( ptr , ptd )
{
	if ( GNOMErunning )
	{
		if ( ptd )
		{
			if ( is_valid_ent(ptr) && ptr > 32 )
			{
				new toucher_is_gnome = -1
				if ( ptd == gnome_id[0] )
					toucher_is_gnome = 0
				else if ( ptd == gnome_id[1] )
					toucher_is_gnome = 1
				
				if ( toucher_is_gnome != -1 )
				{
					new ent_classname[33]
					entity_get_string(ptr, EV_SZ_classname, ent_classname, 32)
					if ( equal(ent_classname, "weapon_heavymachinegun") || equal(ent_classname, "weapon_grenadegun") ||
						equal(ent_classname, "weapon_shotgun") || //equal(ent_classname, "weapon_machinegun") ||
						equal(ent_classname, "weapon_mine") || equal(ent_classname, "item_heavyarmor") ||
						equal(ent_classname, "item_jetpack") || (equal(ent_classname, "item_health") && entity_get_float(ptd, EV_FL_health) >= entity_get_float(ptd, EV_FL_max_health) ) )
						return PLUGIN_HANDLED
					
					// get projectile player got hit by (Spit or Acidrocket)
					if ( equal(ent_classname, "spitgunspit") || equal(ent_classname, "weapon_acidrocket") ){
						old_toucher[toucher_is_gnome] = ptr
						old_toucher_id[toucher_is_gnome] = entity_get_edict(ptr, EV_ENT_owner)
						entity_get_vector(ptr, EV_VEC_velocity, attacker_vec[toucher_is_gnome])
					}
				}
			}
		}
	}
	
	return PLUGIN_CONTINUE
}

public client_spawn( id )
{
	if ( resupply[id] )
	{
		if ( is_user_alive(id) )
		{
			new Userid[1]
			Userid[0] = id
			remove_task(2000+id)
			set_task(3.0, "resupply_timer", 2000 + id, Userid, 1, "b")
		}
	}
	if ( GNOMErunning )
	{
		new gnome_num = player_team[id]
		if ( !running_combat )
		{
			if ( gnome_id[gnome_num] )
			{
				if ( !check_if_allowed(gnome_num, 1) )
					set_task(10.0, "eject_gnome", 4000 + gnome_num)
			}
		}
		if ( id == gnome_id[gnome_num] )
		{
			if ( is_user_alive(id) )
			{
				set_gnome_abilities2(id)
				set_task(0.1, "gnome_ability_timer", 3000 + gnome_num)
				set_task(0.1, "xtra_gnome_abilities", 3000 + 32 + gnome_num)
			}
		}
	}
}

public client_PreThink( id )
{
	if ( GNOMErunning )
	{
		new gnome_num = player_team[id]
		if ( id == gnome_id[gnome_num] )
		{
			if ( is_user_alive(id) )
			{
				new button = entity_get_int(id, EV_INT_button)
				if ( !running_combat )
				{
					if ( button & IN_USE )
					{
						new aim_at_id, dummy
						get_user_aiming(gnome_id[gnome_num], aim_at_id, dummy, 150)
						if ( is_valid_ent(aim_at_id) )
						{
							new ent_classname[33]
							entity_get_string(aim_at_id, EV_SZ_classname, ent_classname, 32)
							if ( equal(ent_classname, "team_command") )
							{
								if ( !check_if_allowed(gnome_num, 1) )
								{
									entity_set_int(id, EV_INT_button, entity_get_int(id, EV_INT_button) & ~IN_USE)
									if ( get_gametime() - tried_comm_time[id] > 2.0 )
									{
										client_print(id, print_chat, "[GNOME] You cannot be the Commander (right now)")
										tried_comm_time[id] = get_gametime()
									}
								}
							}
						}
					}
				}
				if ( button & IN_JUMP )
				{
					if ( !(entity_get_int(id, EV_INT_flags) & FL_ONGROUND) && !gnome_jumped[gnome_num] )
					{
						gnome_jumped[gnome_num] = 1
						new Float:jump_vec[3]
						entity_get_vector(id, EV_VEC_velocity, jump_vec)
						jump_vec[0] /= GNOME_JUMP_ADJUST_X
						jump_vec[1] /= GNOME_JUMP_ADJUST_Y
						jump_vec[2] /= GNOME_JUMP_ADJUST_Z
						entity_set_vector(id, EV_VEC_velocity, jump_vec)
					}
				}else if ( entity_get_int(id, EV_INT_flags) & FL_ONGROUND )
					gnome_jumped[gnome_num] = 0
			}
		}
	}
}

public server_frame_fake( fakeent_id )
{
	if ( GNOMErunning )
	{
		new a
		new Float:gnome_cur_hp, Float:max_ap, Float:gnome_status, Float:cur_orig[3], Float:cur_angle[3]
		new nearest_cc, aim_at_id, dummy, mode, aim_at_ap_upgrade
		new selfwelding, in_built
		new Float:max_hp, Float:max_allowed_hp, Float:max_allowed_ap
		
		// this is executed before the rest to prevent a bug
		for ( a = 0; a < is_mvm_combat + 1; a++ )
		{
			if ( gnome_id[a] )
			{
				// set view postion
				if ( ( entity_get_int(gnome_id[a], EV_INT_button) & IN_DUCK ) )
					entity_set_vector(gnome_id[a], EV_VEC_view_ofs, gnome_view_duck)
				else
					entity_set_vector(gnome_id[a], EV_VEC_view_ofs, gnome_view)
			}
		}
		for ( a = 0; a < is_mvm_combat + 1; a++ )
		{
			if ( gnome_id[a] )
			{
				if ( is_user_alive(gnome_id[a]) )
				{
					// check current health and max_health
					entity_set_float(gnome_id[a], EV_FL_max_health, GNOME_HEALTH)
					
					gnome_cur_hp = entity_get_float(gnome_id[a], EV_FL_health)
					if ( gnome_cur_hp > GNOME_HEALTH )
						entity_set_float(gnome_id[a], EV_FL_health, GNOME_HEALTH)
					
					// check current armor
					max_ap = gnome_ap_upgrade_value * check_armor_upgrade(gnome_id[a]) + GNOME_ARMOR		// 80% of GNOME_ARMOR * amount of armor upgrades + standard armor
					// ExtraLevels2 Rework extra armor (gnome only 60% of default)
					max_ap += reinforced_ap[gnome_id[a]] * gnome_ap_adds
					if ( entity_get_float(gnome_id[a], EV_FL_armorvalue) > max_ap )
						entity_set_float(gnome_id[a], EV_FL_armorvalue, max_ap)
					
					// set gnome status (Health ring)
					gnome_status = 1000.0 / entity_get_float(gnome_id[a], EV_FL_max_health) * gnome_cur_hp
					entity_set_float(gnome_id[a],EV_FL_fuser2, gnome_status)
					
					if ( !running_combat && entity_get_int(gnome_id[a], EV_INT_iuser3) != 2 )	// iuser3 => 2 => commander
					{	// check if gnome is in Commchair range
						entity_get_vector(gnome_id[a], EV_VEC_origin, cur_orig)
						nearest_cc = gnome_in_cc_range(gnome_id[a])
						if ( nearest_cc )
						{
							// gnome not in Commchair range so check if last position was the same as current, if not teleport gnome there
							if ( !is_same_vec(cur_orig, gnome_range_orig[a]) )
								entity_set_origin(gnome_id[a], gnome_range_orig[a])
							// gnome got teleported back and still not in Commchair range, so take him to nearest Commchair
							else
							{
								entity_get_vector(nearest_cc, EV_VEC_origin, cur_orig)
								cur_orig[2] += 40
								entity_set_origin(gnome_id[a], cur_orig)
							}
						}else if ( entity_get_int(gnome_id[a], EV_INT_flags) & FL_ONGROUND )
						{
							gnome_range_orig[a][0] = cur_orig[0]
							gnome_range_orig[a][1] = cur_orig[1]
							gnome_range_orig[a][2] = cur_orig[2]
						}
					}
					
					// get the building/player gnome is looking at
					get_user_aiming(gnome_id[a], aim_at_id, dummy, 100)
					
					// check for self-welding
					selfwelding = 0
					entity_get_vector(gnome_id[a], EV_VEC_angles, cur_angle)
					if ( cur_angle[0] < -26.0 && !is_valid_ent(aim_at_id) )
					{
						selfwelding = 1
						aim_at_id = gnome_id[a]
					}
					
					if ( is_valid_ent(aim_at_id) || selfwelding )
					{
						in_built = ns_get_mask(aim_at_id, 4)
						
						// check what is ent and if same team
						if ( entity_get_int(gnome_id[a], EV_INT_button) & IN_USE && in_built && entity_get_int(gnome_id[a], EV_INT_team) == entity_get_int(aim_at_id, EV_INT_team) )
						{
							mode = 1
						}else if ( entity_get_int(gnome_id[a], EV_INT_button) & IN_ATTACK && get_user_weapon(gnome_id[a], dummy, dummy) == 18 )
						{
							if ( selfwelding )
								selfwelding = 2
							else if ( is_user_connected(aim_at_id) || selfwelding )
								mode = 3
							else
								mode = 2
						}else
							continue
						
						// gnome is welding self
						if ( selfwelding == 2 )
						{
							if ( get_gametime() - gnome_build_time[a] > 0.7 )
							{
								ent_ap_change[a] = entity_get_float(gnome_id[a], EV_FL_armorvalue) + 5.0
								if ( ent_ap_change[a] > max_ap )
									ent_ap_change[a] = max_ap
								
								entity_set_float(gnome_id[a], EV_FL_armorvalue, ent_ap_change[a])
								
								gnome_build_time[a] = get_gametime()
							}
							continue
						}
						
						// if we looking at a new entity reset everything
						if ( old_ent_id[a] != aim_at_id )
						{
							ent_new_status[a] = 0.0
							ent_old_status[a] = 0.0
							ent_new_hp[a] = 0.0
							ent_old_hp[a] = 0.0
							gnome_build_time[a] = 0.0
						}
						
						// get max health to prevent giving more health than max is allowed
						max_hp = entity_get_float(aim_at_id, EV_FL_max_health)
						// get current build status
						ent_new_status[a] = entity_get_float(aim_at_id, EV_FL_fuser1)
						// get current hp status
						ent_new_hp[a] = entity_get_float(aim_at_id, EV_FL_health)
						if ( get_gametime() - gnome_build_time[a] > 0.5 )
						{
							// building structure
							if ( mode == 1 )
							{
								if ( ent_new_status[a] != 1000.0 && ent_old_status[a] > 0.0 && ent_new_status[a] > ent_old_status[a] )
								{
									ent_stat_change[a] = ent_new_status[a] * 2 - ent_old_status[a]		// get the difference between old and new build status
									
									// dont finish the building with double speed
									if ( ent_stat_change[a] >= 1000.0 )
										ent_stat_change[a] = 999.0
									
									entity_set_float(aim_at_id, EV_FL_fuser1, ent_stat_change[a])		// set new build status
									ent_old_status[a] = ent_stat_change[a]
									
									ent_hp_change[a] = ent_new_hp[a] * 2 - ent_old_hp[a]		// get the difference between old and new build hp
									
									// dont give more hp than allowed
									if ( ent_hp_change[a] > max_hp )
										ent_hp_change[a] = max_hp - 1.0
									
									entity_set_float(aim_at_id, EV_FL_health, ent_hp_change[a])		// set new build hp
									ent_old_hp[a] = ent_hp_change[a]
								}else
								{
									ent_old_status[a] = ent_new_status[a]
									ent_old_hp[a] = ent_new_hp[a]
								}
							// welding structure
							}else if ( mode == 2 )
							{
								if ( ent_new_hp[a] != max_hp && ent_new_hp[a] > ent_old_hp[a] && ent_old_hp[a] > 0.0 )
								{
									ent_hp_change[a] = ent_new_hp[a] * 2 - ent_old_hp[a]
									
									// check for unfinished structures
									if ( in_built )
									{
										// dont give more hp than allowed
										max_allowed_hp = max_hp / 1000.0 * ent_new_status[a]
										if ( ent_hp_change[a] > max_allowed_hp )
											ent_hp_change[a] = max_allowed_hp
									}else if ( ent_hp_change[a] > max_hp )
										ent_hp_change[a] = max_hp - 1.0
									
									entity_set_float(aim_at_id, EV_FL_health, ent_hp_change[a])
									ent_old_hp[a] = ent_hp_change[a]
								}else
									ent_old_hp[a] = ent_new_hp[a]
							// welding teammate
							}else if (mode == 3 )
							{
								ent_new_ap[a] = entity_get_float(aim_at_id, EV_FL_armorvalue)
								if ( ent_new_ap[a] > ent_old_ap[a] && ent_old_ap[a] > 0.0 )
								{
									aim_at_ap_upgrade = check_armor_upgrade(aim_at_id)
									ent_ap_change[a] = ent_new_ap[a] * 2 - ent_old_ap[a]
									
									if ( ns_get_class(aim_at_id) == CLASS_HEAVY )
									{
										if ( aim_at_ap_upgrade == 3 )
											max_allowed_ap = 290.0
										else if ( aim_at_ap_upgrade == 2 )
											max_allowed_ap = 260.0
										else if ( aim_at_ap_upgrade == 1 )
											max_allowed_ap = 230.0
										else
											max_allowed_ap = 200.0
										max_allowed_ap += reinforced_ap[aim_at_id] * heavy_armor_up
									}else
									{
										if ( aim_at_ap_upgrade == 3 )
											max_allowed_ap = 90.0
										else if ( aim_at_ap_upgrade == 2 )
											max_allowed_ap = 70.0
										else if ( aim_at_ap_upgrade == 1 )
											max_allowed_ap = 50.0
										else
											max_allowed_ap = 30.0
										
#if defined NS_303 == 0
										max_allowed_ap -= 5.0
#endif
										
										max_allowed_ap += reinforced_ap[aim_at_id] * marine_armor_up
									}
									
									if ( ent_ap_change[a] > max_allowed_ap )
										ent_ap_change[a] = max_allowed_ap
									
									entity_set_float(aim_at_id, EV_FL_armorvalue, ent_ap_change[a])
									ent_old_ap[a] = ent_ap_change[a]
								}else
									ent_old_ap[a] = ent_new_ap[a]
							}
							gnome_build_time[a] = get_gametime()
						}
						old_ent_id[a] = aim_at_id
					}
				}
			}
		}
	}
	entity_set_float(fakeent_id, EV_FL_nextthink, halflife_time() + 0.01)
}

/* Gnome */
public gnome_onoff( id , level , cid )
{
	gnome_view[2] -= 1.0
	if ( gnome_view[2] < 2.0 )
		gnome_view[2] = 11.0
	if ( !cmd_access(id, level, cid, 2) )
		return PLUGIN_HANDLED
	
	new onoff[5]
	read_argv(1, onoff, 4)
	if ( equal(onoff, "on") || equal(onoff, "1") )
	{
		if ( GNOMErunning == 1 )
		{
			console_print(id, "Gnome already enabled")
		}else
		{
			GNOMErunning = 1
			console_print(id, "Gnome enabled")
		}
	}
	else if ( equal(onoff, "off") || equal(onoff, "0") )
	{
		if ( GNOMErunning == 0 )
		{
			console_print(id, "Gnome already disabled")
		}else
		{
			GNOMErunning = 0
			if ( gnome_id[0] )
				free_gnome(gnome_id[0], 0)
			if ( gnome_id[1] )
				free_gnome(gnome_id[1], 1)
			console_print(id, "Gnome disabled")
		}
	}
	return PLUGIN_HANDLED
}

public amx_gnome_make( id , level , cid )
{
	if ( !cmd_access (id, level, cid, 1) )
		return PLUGIN_HANDLED
	
	if ( GNOMErunning )
	{
		if ( read_argc() )
		{
			new name[32]
			read_argv(1, name, 31)
			
			player_to_gnome = find_player("bl", name)
			if ( player_to_gnome )
			{
				if ( player_to_gnome != find_player("blj", name) )
				{
					console_print(id, "%L", id, "MORE_CL_MATCHT")
					return PLUGIN_HANDLED
				}
			}else if ( ( player_to_gnome = find_player("c", name) ) == 0 && name[0] == '#' && name[1] )
				player_to_gnome = find_player("k", str_to_num(name[1]))
			
			if ( !is_user_connected(player_to_gnome) )
				player_to_gnome = 0
		}
		override = 1
		eCountdown()
	}
	
	return PLUGIN_HANDLED
}

public amx_ungnome( id , level , cid )
{
	if ( !cmd_access (id, level, cid, 1) )
		return PLUGIN_HANDLED
	
	if ( GNOMErunning )
	{
		if ( gnome_id[0] )
			free_gnome(gnome_id[0], 0)
		if ( gnome_id[1] )
			free_gnome(gnome_id[1], 1)
	}
	
	return PLUGIN_HANDLED
}
	
public eCountdown( )
{
	new marines[2][32], marine_num[2]
	marine_num[0] = -1
	marine_num[1] = -1
	
	new i
	new gnome_num
	for ( i = 1; i <= max_player_num; i++ )
	{
		if ( is_user_connected(i) )
		{
			gnome_num = player_team[i]
			if ( 0 <= gnome_num <= 1 )
			{
				marine_num[gnome_num]++
				marines[gnome_num][marine_num[gnome_num]] = i
			}
		}
	}
	
	for ( i = 0; i < is_mvm_combat + 1; i++ )
	{
		if ( !gnome_id[i] )
		{
			if ( ( marine_num[i] > 0 && get_cvar_num("auto_gnome") ) || ( override && marine_num[i] != -1 ) )
			{
				if ( player_to_gnome && player_team[player_to_gnome] == i )
				{
					make_gnome(player_to_gnome, i)
					player_to_gnome = 0
				}else
					make_gnome(marines[i][random(marine_num[i] + 1)], i)
			}
		}else
			set_gnome_model(gnome_id[i], player_team[gnome_id[i]])
	}
	
	override = 0
	
	return PLUGIN_HANDLED
}

public eDamage( id )
{
	if ( GNOMErunning )
	{
		new attacker_weapon_id = entity_get_edict(id, EV_ENT_dmg_inflictor)
		new gnome_num = player_team[id]
		
		if ( is_valid_ent(attacker_weapon_id) || ( attacker_weapon_id == old_toucher[gnome_num] && attacker_weapon_id ) )
		{
			new attacker, temp_toucher = -1
			if ( attacker_weapon_id == old_toucher[gnome_num] )
			{
				attacker = old_toucher_id[gnome_num]
				temp_toucher = old_toucher[gnome_num]
				
				// reset touchers for next hit
				old_toucher_id[gnome_num] = 0
				old_toucher[gnome_num] = 0
			}else
			{
				attacker = entity_get_edict(attacker_weapon_id, EV_ENT_owner)
				
				new attacker_weapon[51]
				entity_get_string(attacker_weapon_id, EV_SZ_classname, attacker_weapon, 50)
				
				// no knockback from parasite, spore and spikes
				if ( equal(attacker_weapon, "weapon_parasite") || equal(attacker_weapon, "sporegunprojectile") || equal(attacker_weapon, "weapon_spikegun") )
					return
			}
			if ( !is_mvm_combat )
			{
				// gnome got dmg
				if ( id == gnome_id[0] || id == gnome_id[1] )
				{
					if ( entity_get_float(id, EV_FL_health) >= 1.0 )
					{
						if ( attacker_weapon_id == temp_toucher )
							knockback_gnome(id, attacker, gnome_num, 1)
						else if ( is_user_connected(attacker) )
							knockback_gnome(id, attacker, gnome_num)
					}
				}
			}
		}
	}
}

public eDeath( )
{
	new victim = read_data(2)
	if ( is_user_connected(victim) )
	{
		if ( victim == old_ent_id[0] )
			old_ent_id[0] = 0
		else if ( victim == old_ent_id[1] )
			old_ent_id[1] = 0
	}
}

public eChange_weapon( id )
{
	if ( GNOMErunning )
	{
		if ( id == gnome_id[0] || id == gnome_id[1] )
		{
			if ( read_data(1) == 6 )
			{	// 6 = change to weapon, 4 = change from weapon
				new wpn_id = read_data(2)
				if ( wpn_id == 18 )
				{
					entity_set_string(id, EV_SZ_weaponmodel, "models/p_welder_gnome.mdl")
				}else if ( wpn_id == 13 )
				{
					entity_set_string(id, EV_SZ_viewmodel, "models/v_pick.mdl")
					entity_set_string(id, EV_SZ_weaponmodel, "models/p_pick.mdl")
				}else if ( wpn_id == 14 )
				{
					entity_set_string(id, EV_SZ_weaponmodel, "models/p_hg_gnome.mdl")
				}else if ( wpn_id == 15 )
				{
					entity_set_string(id, EV_SZ_weaponmodel, "models/p_mg_gnome.mdl")
				}
			}
		}
	}
}

public eTeamChanges( )
{
	new teamname[32], id = read_data(1)
	read_data(2, teamname, 31)
	if ( equal(teamname, "marine1team") )
		player_team[id] = MARINE
	else if ( equal(teamname, "marine2team") )
		player_team[id] = MARINE2
}

public handle_say( id )
{
	if ( GNOMErunning )
	{
		new gnome_num = player_team[id]
		
		if ( gnome_num != 2 )
		{
			new Speech[65]
			read_args(Speech, 64)
			remove_quotes(Speech)
			if ( ns_get_class(id) == CLASS_COMMANDER )
			{	// commander
				if ( equal(Speech, "/gnome", 6) )
				{
					if ( allow_comm_gnome[gnome_num] )
					{
						replace(Speech, 64, "/gnome ", "")
						
						new target_id = cmd_target(id, Speech, 0)
					 	if ( !target_id || target_id == id )
					 		return PLUGIN_HANDLED
					 	
					 	if ( entity_get_int(target_id, EV_INT_team) == entity_get_int(id, EV_INT_team) )
					 	{
					 		if ( gnome_id[gnome_num] )
					 			free_gnome(gnome_id[gnome_num], gnome_num)
					 		
					 		make_gnome(target_id, gnome_num)
					 		allow_comm_gnome[gnome_num] = 0
					 		
					 		new user_name[33]
							get_user_name(target_id, user_name, 32)
							client_print(id, print_chat, "[GNOME] %s has been turned into the Gnome", user_name)
					 		
					 		set_task(30.0, "change_comm_gnome", 4000 + 32 + gnome_num)
					 	}
					}
				 	return PLUGIN_HANDLED
				}else if ( equal(Speech, "/ungnome", 8) )
				{
					if ( gnome_id[gnome_num] && entity_get_int(gnome_id[gnome_num], EV_INT_team) == entity_get_int(id, EV_INT_team) )
					{
						new user_name[33]
						get_user_name(gnome_id[gnome_num], user_name, 32)
						client_print(id, print_chat, "[GNOME] %s has been ungnomed", user_name)
						free_gnome(gnome_id[gnome_num], gnome_num)
					}
					return PLUGIN_HANDLED
				}
				
			}else
			{
				if ( equal(Speech, "/gnome me") || equal(Speech, "/gnomeme") )
				{
					if ( !gnome_id[gnome_num] )
						make_gnome(id, gnome_num)
					else
						client_print(id, print_chat, "[GNOME] You cannot gnome, there is already a Gnome")
					return PLUGIN_HANDLED
				}else if ( equal(Speech, "/ungnome me") || equal(Speech, "/ungnomeme") )
				{
					if ( id == gnome_id[gnome_num] )
					{
						if ( check_if_allowed(gnome_num) )
							free_gnome(id, gnome_num)
					}else
						client_print(id, print_chat, "[GNOME] You cannot ungnome, you are not the Gnome")
					return PLUGIN_HANDLED
				}
			}
		}
	}
	return PLUGIN_CONTINUE
}

/* additional functions */
make_gnome( id , gnome_number )
{
	gnome_id[gnome_number] = id
	gnome_mask[gnome_number] = entity_get_int(id, EV_INT_iuser4)
	
	// set new field of view
	ns_set_fov(id, GNOME_FOV)
	
	get_items(id, gnome_number)
	set_gnome_abilities(id, gnome_number)
	set_gnome_abilities2(id)
	set_task(0.1, "xtra_gnome_abilities", 3000 + 32 + gnome_number + 32)
	
	// updade extralevels2 rework
	if ( xtralvl2_rewo_loaded )
		gnomeid_to_el2rework(id, gnome_number, 1)
}

free_gnome( id , gnome_number , no_team = 0 )
{
	gnome_id[gnome_number] = 0
	
	// reset field of view
	ns_set_fov(id, 0.0)
	remove_task(3000 + gnome_number)		// gnome_ability_timer
	remove_task(3032 + gnome_number)		// xtra_gnome_abilities
	remove_task(3064 + gnome_number)		// xtra_gnome_abilities (same as other but only started when gnome is made)
	remove_task(4000 + gnome_number)		// eject_gnome
	
	ns_set_speedchange(id, 0)
	ns_set_player_model(id)
	if ( entity_get_float(id, EV_FL_health) >= GNOME_HEALTH )
		entity_set_float(id, EV_FL_health, 100.0)
	entity_set_float(id, EV_FL_max_health, 100.0)
	
	new armor_level = check_armor_upgrade(id)
	if ( entity_get_float(id, EV_FL_armorvalue) >= ( gnome_ap_upgrade_value * armor_level + GNOME_ARMOR ) )
#if defined NS_303 == 0
		entity_set_float(id, EV_FL_armorvalue, 25.0 + armor_level * 20.0)
#else
		entity_set_float(id, EV_FL_armorvalue, 30.0 + armor_level * 20.0)
#endif
	
	// updade extralevels2 rework
	if ( xtralvl2_rewo_loaded )
		gnomeid_to_el2rework(id, gnome_number, 0)
	
	if ( !no_team )
	{
		regive_items(id, gnome_number)
		
		// set the players model to correct color
		if ( mvm_allinone_loaded && is_mvm_combat )
		{
			if ( gnome_number == 0 )
			{
				if( ns_get_class(id) == CLASS_HEAVY )
					ns_set_player_model(id, "models/marinevsmarine/heavyblue.mdl")
				else
					ns_set_player_model(id, "models/marinevsmarine/soldierb.mdl")
			}else if ( gnome_number == 1 )
			{
				if( ns_get_class(id) == CLASS_HEAVY )
					ns_set_player_model(id, "models/marinevsmarine/heavyred.mdl")
				else
					ns_set_player_model(id, "models/marinevsmarine/soldierred.mdl")
			}
		}
	}
}

set_gnome_abilities( id , gnome_number )
{
	entity_set_float(id, EV_FL_max_health, GNOME_HEALTH)		// set max health
	
	// drop good weapons and give LMG
	regive_items(id, gnome_number, {16,17,20}, 3, {15,18}, 2)
}

set_gnome_abilities2( id )
{
	// remove HA and JP
	if ( entity_get_int(id, EV_INT_iuser4) & MASK_HEAVYARMOR )
	{
		entity_set_int(id, EV_INT_iuser3, 1)	// normal marine
		entity_set_int(id, EV_INT_iuser4, entity_get_int(id, EV_INT_iuser4) & ~MASK_HEAVYARMOR )
	}
	if ( entity_get_int(id, EV_INT_iuser4) & MASK_JETPACK ){
		entity_set_int(id, EV_INT_iuser3, 1)	// normal marine
		entity_set_int(id, EV_INT_iuser4, entity_get_int(id, EV_INT_iuser4) & ~MASK_JETPACK )
	}
}

set_gnome_model( id , gnome_number )
{
	ns_set_player_model(id, "models/gnome/gnomeall.mdl")
	if ( is_mvm_combat )
		entity_set_int(id, EV_INT_skin, gnome_number + 1)
	else
		entity_set_int(id, EV_INT_skin, GNOME_MODEL_COLOR)
}

knockback_gnome( id , attacker , gnome_number , projectile = 0 )
{
	new Float:attacker_ang[3]
	new booster = random_num(BOOST_START, BOOST_END)
	if ( !projectile )
		velocity_by_aim(attacker, 1, attacker_vec[gnome_number])
	
	vector_to_angle(attacker_vec[gnome_number], attacker_ang)
	
	attacker_ang[0] += random_num(-PUSH_ANGLE, PUSH_ANGLE)
	attacker_ang[1] += random_num(-PUSH_ANGLE, PUSH_ANGLE)
	attacker_ang[2] += random_num(0, PUSH_ANGLE)
	
	angle_vector(attacker_ang, 1, attacker_vec[gnome_number])
	
	attacker_vec[gnome_number][0] *= booster
	attacker_vec[gnome_number][1] *= booster
	attacker_vec[gnome_number][2] *= booster
	
	set_user_velocity(id, attacker_vec[gnome_number])
}

gnome_in_cc_range( id , bring_to_cc = 0 )
{
	new ccid = -1
	new closest_cc
	new Float:closest_cc_range, Float:cc_range
	new found_correct, in_built
	while( ( ccid = find_ent_by_class(ccid, "team_command") ) > 0 )
	{
		if ( !(entity_get_int(ccid, EV_INT_effects) & 128) )
		{
			in_built = ns_get_mask(ccid, 4)
			if ( !in_built && entity_get_int(id, EV_INT_team) == entity_get_int(ccid, EV_INT_team) )
			{
				found_correct = 1
				cc_range = entity_range(ccid, id)
				if( cc_range <= GNOME_RANGE )
					return 0
				
				if ( bring_to_cc )
				{
					if ( closest_cc_range > cc_range )
					{
						closest_cc = ccid
						closest_cc_range = cc_range
					}
				}
			}
		}
	}
	
	if ( !found_correct )	// no CC found, so he is free
		return 0
	
	return closest_cc
}

check_if_allowed( gnome_number , check_for_comm = 0 )
{	// check if gnome is allowed to go commander
	new marine_num, marine_alive_num
	new gnome_team = player_team[gnome_id[gnome_number]]
	
	for ( new a = 1; a <= max_player_num; a++ )
	{
		if ( is_user_connected(a) )
		{
			if ( player_team[a] == gnome_team )
			{
				marine_num++
				if ( is_user_alive(a) )
					marine_alive_num++
			}
		}
	}
	
	// check if gnome is the only alive player, allow to be comm
	if ( check_for_comm )
		if ( marine_alive_num < 2 )
			return 1
	
	// check if gnome is the only player
	if ( marine_num < 2 )
		return 1
	
	return 0
}

resupply_player( id , init )
{
	if ( !ns_get_mask(id, MASK_DIGESTING) )
	{
		new Float:max_health = entity_get_float(id, EV_FL_max_health)
		new Float:cur_health = entity_get_float(id, EV_FL_health)
		if ( cur_health < max_health ){
			ns_give_item(id, "item_health")
			if ( cur_health > max_health )
				entity_set_float(id, EV_FL_health, max_health)
			
			teleport_effect(id)
		}else if ( init )
		{
			ns_give_item(id, "item_genericammo")
			teleport_effect(id)
		}else
		{
			new ammo_reserve, dummy
			new weap_id = get_user_weapon(id, dummy, ammo_reserve)
			if ( weap_id == 14 )
			{	// Pistol
				if ( ammo_reserve < 12 )
				{
					ns_give_item(id, "item_genericammo")
					teleport_effect(id)
				}
			}else if ( weap_id == 15 )
			{	// LMG
				if ( ammo_reserve < 100 )
				{
					ns_give_item(id, "item_genericammo")
					teleport_effect(id)
				}
			}else if ( weap_id == 16 )
			{	// Shotgun
				if ( ammo_reserve < 16 )
				{
					ns_give_item(id, "item_genericammo")
					teleport_effect(id)
				}
			}else if ( weap_id == 17 )
			{	// HMG
				if ( ammo_reserve < 100 )
				{
					ns_give_item(id, "item_genericammo")
					teleport_effect(id)
				}
			}else if ( weap_id == 20 )
			{	// GL
				if ( ammo_reserve < 12 )
				{
					ns_give_item(id, "item_genericammo")
					teleport_effect(id)
				}
			}
		}
	}
}

check_points_spend_or_level( id , level_check = 0 )
{
	new cur_xp = floatround(ns_get_exp(id))
	new cur_point_spend = ns_get_points(id)
	new temp_xp, xp_to_next_lvl = 100, player_level = 1
	while ( cur_xp > ( temp_xp + xp_to_next_lvl ) )
	{
		temp_xp += xp_to_next_lvl
		xp_to_next_lvl += 50
		player_level++
	}
	
	if ( level_check )
		return ( player_level - 1 )
	if ( player_level <= 10 )
	{
		if ( player_level - cur_point_spend > 1 )
			return 1
	}else if ( cur_point_spend < 9 )
		return 1
	
	return 0
}

teleport_effect( id )
{
	new Float:origin[3]
	entity_get_vector(id, EV_VEC_origin, origin)
	emit_sound(id, CHAN_ITEM, "misc/phasein.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
	playback_event(0, id, teleport_event, 0.0, origin, Float:{0.0, 0.0, 0.0}, 0.0, 0.0, 0, 0, 0, 0)
}

get_items( id , gnome_number )
{
	gnome_died[gnome_number] = 0
	new weapon_num
	get_user_weapons(id, gnome_items[gnome_number], weapon_num)
	
	new class = ns_get_class(id)
	if ( class == CLASS_HEAVY )
		gnome_item_xtra[gnome_number] = 1
	else if ( class == CLASS_JETPACK )
		gnome_item_xtra[gnome_number] = 2
}

regive_items( id , gnome_number , bad_weapons[] = "" , bad_num = 0 , good_weapons[] = "" , good_num = 0 )
{
	// if ns and gnome died dont allow to regive him old equipment
	if ( !bad_num && !good_num && !running_combat && gnome_died[gnome_number] )
		return
	
	new weapon_list[32], weapon_num
	get_user_weapons(id, weapon_list, weapon_num)
	strip_user_weapons(id)
	
	new i, j
	new weapon_name[33]
	// regive weapons without the bad ones
	if ( bad_num )
	{
		new found
		for ( i = 0; i < weapon_num; i++ )
		{
			found = 0
			for ( j = 0; j < bad_num; j++ )
			{
				if ( weapon_list[i] == bad_weapons[j] )
				{
					bad_weapons[j] = bad_weapons[bad_num - 1]
					bad_num--
					found = 1
					continue
				}
			}
			if ( !found )
			{
				get_weaponname(weapon_list[i], weapon_name, 32)
				ns_give_item(id, weapon_name)
			}
		}
	}
	// and optionally give extra weapons
	if ( good_num )
	{
		for ( i = 0; i < good_num; i++ )
		{
			get_weaponname(good_weapons[i], weapon_name, 32)
			ns_give_item(id, weapon_name)
		}
	// regive all gnome weapons and items
	}else if ( !bad_num && !good_num )
	{
		new gnome_num = player_team[id]
		for ( i = 0; i < strlen(gnome_items[gnome_num]); i++ )
		{
			get_weaponname(gnome_items[gnome_num][i], weapon_name, 32)
			ns_give_item(id, weapon_name)
		}
		new iuser4 = entity_get_int(id, EV_INT_iuser4)
		if ( gnome_item_xtra[gnome_num] == 1 )
		{
			if ( !( iuser4 & MASK_HEAVYARMOR ) )
				entity_set_int(id ,EV_INT_iuser4, iuser4 + MASK_HEAVYARMOR)
			ns_give_item(id, "item_heavyarmor")
		}else if ( gnome_item_xtra[gnome_num] == 2 )
		{
			if ( !( iuser4 & MASK_JETPACK ) )
				entity_set_int(id ,EV_INT_iuser4, iuser4 + MASK_JETPACK)
			ns_give_item(id, "item_jetpack")
		}
		for ( i = 0; i < 32; i++ )
			gnome_items[gnome_num][i] = 0
		
		gnome_item_xtra[gnome_num] = 0
	}
}

check_armor_upgrade( id )
{
	if ( ns_get_mask(id, 64) )
	{
		if ( ns_get_mask(id, 128) )
		{
			if ( ns_get_mask(id, 256) )
				return 3
			return 2
		}
		return 1
	}
	return 0
}

gnome_weapon_damge( id , gnome_number )
{
	new Float:damge_aplify = get_cvar_float("mp_gnome_damage_amplifier"), pick_only = get_cvar_num("mp_gnome_damage_pick_only")
	new ent_classname[33]
	new weap_mode
	for ( new ent_id = max_player_num + 1; ent_id <= max_entities; ent_id++ )
	{
		if ( is_valid_ent(ent_id) )
		{
			entity_get_string(ent_id, EV_SZ_classname, ent_classname, 32)
			if ( entity_get_edict(ent_id, EV_ENT_owner) == id )
			{
				weap_mode = -1
				if ( equal(ent_classname, "weapon_knife") )
				{
					weap_mode = 0
				}else if ( !pick_only )
				{
					if ( equal(ent_classname, "weapon_machinegun") )
						weap_mode = 1
					else if ( equal(ent_classname, "weapon_pistol") )
						weap_mode = 2
					else if ( equal(ent_classname, "weapon_welder") )
						weap_mode = 3
				}
				if ( weap_mode != -1 )
				{
					gnome_weap_bas_damage[gnome_number][weap_mode] = ns_get_weap_dmg(ent_id)
					ns_set_weap_dmg(ent_id, gnome_weap_bas_damage[gnome_number][weap_mode] * damge_aplify)
				}
			}
		}
	}
}

stock is_same_vec( Float:vec1[3] , Float:vec2[3] )
{
	if ( vec1[0] == vec2[0] && vec1[1] == vec2[1] && vec1[2] == vec2[2] )
		return 1
	
	return 0
}

/* Timer Functions */
public gnome_ability_timer( timerid_gnomenum )
{
	new id = gnome_id[timerid_gnomenum-3000]
	if ( is_user_connected(id) )
		set_gnome_abilities(id, timerid_gnomenum - 3000)
}

public xtra_gnome_abilities( timerid_gnomenum )
{
	new id, check_mask_set, gnome_num
	if ( timerid_gnomenum - 3032 > 2 )
	{	// special check
		check_mask_set = 1
		gnome_num = timerid_gnomenum - 3064
	}else
		gnome_num = timerid_gnomenum - 3032
	
	id = gnome_id[gnome_num]
	
	set_gnome_model(id, gnome_num)
	
	if ( is_user_connected(id) )
	{
		ns_set_speedchange(id, - 206 + GNOME_SPEED )	// set speed: - default = 0 -> + GNOME_SPEED = GNOME_SPEED
		gnome_weapon_damge(id, gnome_num)	// set the gnomes weapon damage
		if ( check_mask_set )
			entity_set_int(id, EV_INT_iuser4, gnome_mask[timerid_gnomenum - 3064] & ~MASK_HEAVYARMOR & ~MASK_JETPACK)	// give rest but not heavy or jetpack
	}
}

public resupply_timer( userid[] )
{
	new id = userid[0]
	if ( is_user_connected(id) )
		if ( is_user_alive(id) )
			resupply_player(id, 0)
}

public change_comm_gnome( timerid_gnomenum )
{
	new gnomenum = gnome_id[timerid_gnomenum-4032]
	allow_comm_gnome[gnomenum] = 1
}

public eject_gnome( timerid_gnomenum )
{
	new gnome_num = timerid_gnomenum - 4000
	new id = gnome_id[gnome_num]
	if ( is_user_connected(id) )
		if ( ns_get_class(id) == CLASS_COMMANDER )
			if ( !check_if_allowed(gnome_num, 1) )
				client_cmd(id, "stopcommandermode")
}

/* This function is called by ExtraLevels2 Rework to update the reinforced armor status */
public gnome_ap_info( id , new_reinforce_status , armor_update_value_ma , armor_update_value_ha , &base_ap , &max_ap )
{
	reinforced_ap[id] = new_reinforce_status
	marine_armor_up = armor_update_value_ma
	heavy_armor_up = armor_update_value_ha
	// ExtraLevels2 Rework extra armor (gnome only 60% of default)
	gnome_ap_adds = marine_armor_up * 6 / 10
	
	base_ap = floatround( gnome_ap_upgrade_value * 3 + GNOME_ARMOR)
	max_ap = floatround( gnome_ap_upgrade_value * 3 + GNOME_ARMOR + gnome_ap_adds * new_reinforce_status )
}

gnomeid_to_el2rework( id , gnome_number , set )
{
	new check = callfunc_begin("who_is_gnome", "extralevels2_rework.amxx")
	
	if ( check == 0 )
		log_amx("Runtime error")
	else if ( check == -1 )
		log_amx("Plugin ^"extralevels2_rework.amxx^" not found")
	else if ( check == -2 )
		log_amx("Function ^"who_is_gnome^" not found")
	else
	{
		callfunc_push_int(id)
		callfunc_push_int(gnome_number)
		callfunc_push_int(set)
		callfunc_push_int(- 206 + GNOME_SPEED)
		callfunc_end()
	}
}