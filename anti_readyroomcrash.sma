/*
* This plugin prevents crashes after a round ended and everyone is sent to readyroom
* Instead of just putting everyone into readyroom it put people in groups of 8 players
* into readyroom (size of group can be changed)
* Also it removes all placed structures in groups (default = group of 32 structures)
*
* Author:
*	-> White Panther
*
* v0.1:
*	- initial release
*
* v0.3:
*	- added:
*		- now it removes buildings too
*
* v0.4:
*	- changed:
*		- code improvements
*		- players starting to switch teams after 3.5 secconds
*
* v0.5:
*	- changed:
*		- initial time for putting everyone to readyroom is now dynamic (depends on defines)
*		- code improvements
*
* v0.6:
*	- fixed:
*		- error with removing entites on 2nd round
*		- player was put multiple times to readyroom
*	- added:
*		- marine items are now removed too (eg: HA, shotgun, ...)
*	- changed:
*		- RTs are now ignored for removing (should fix problems)
*
* v0.7:
*	- fixed:
*		- possible error with putting players to readyroom after round started
*		- possible error with removing entitys so on new round ents could be deleted
*
* v0.8:
*	- added:
*		- player joining can now be limited depending on time
*
* v0.9:
*	- fixed:
*		- bug where plugin would stop working ( thanks -mE- )
*		- possible bug with removing entities after new round
*	- changed:
*		- code to loop through entities ( thanks -mE- )
*		- entity remover for combat (in case server is using buildings in combat)
*
* v1.0:
*	- fixed:
*		- entity remover for combat will not remove armories anymore (buggy)
*		- players should now be put to readyroom correctly
*
* v1.1b:
*	- fixed:
*		- wierd runtime error
*		- possible runtime error
*/

#include <amxmodx>
#include <engine>
#include <ns>

#define INIT_PLAYERS		10	// minimum amount of players needed to activate this plugin
#define TIME_INTERVAL		0.2	// time till next group of player is put into readyroom
#define PLAYERS_TO_MOVE		8	// size of group that is put to readyroom each interval

// this is not dynamic, so do not change if you do not know what you are doing
#define ENTITIES_TO_KILL	32	// size of entity-group that is removed each interval

#define JOINING_TIME		2.0	// amount of time needs to pass before next player wave can join a team
#define MAX_PLAYERS_JOIN	4	// amount of players that are allowed to join every JOINING_TIME

new plugin_author[] = "White Panther"
new plugin_version[] = "1.1b"

new max_players, player_counter, players_moved
new max_entities, ent_to_remove, combat_running
new Float:roundend_time
new entity_destroyer
new round_started

new Float:joining_time
new joining_num

public plugin_init( )
{
	register_plugin("Anti RR crash", plugin_version, plugin_author)
	register_cvar("anti_rrcrash", plugin_version, FCVAR_SERVER)
	set_cvar_string("anti_rrcrash", plugin_version)
	
	register_event("GameStatus", "eRoundend", "ab", "1=2" )
	register_event("Countdown", "eCountdown", "ab")
	
	register_clcmd("jointeamone", "hookteamjoin")
	register_clcmd("jointeamtwo", "hookteamjoin")
	register_clcmd("jointeamthree", "hookteamjoin")
	register_clcmd("jointeamfour", "hookteamjoin")
	register_clcmd("autoassign", "hookteamjoin")
	
	max_players = get_maxplayers()
	max_entities = get_global_int(GL_maxEntities)
	combat_running = ns_is_combat()
}

public eRoundend( )
{
	if ( !round_started )
		return
	
	new players_num = get_playersnum()
	joining_num = 0
	joining_time = get_gametime() - JOINING_TIME
	round_started = 0
	roundend_time = get_gametime()
	if ( !players_moved && players_num >= INIT_PLAYERS )
		set_task(5.9 - ( ( floatround(float(players_num) / float(PLAYERS_TO_MOVE), floatround_ceil) - 1 ) * TIME_INTERVAL ), "readyroom_players", 100)
	
	if ( !ent_to_remove )
	{
		ent_to_remove = max_players + 1
		entity_destroyer = create_destroyer()
		kill_entities()
	}
	set_task(6.0, "backup_timer", 300)
}

public eCountdown( )
{
	round_started = 1
	
	players_moved = 0
	player_counter = 0
	
	ent_to_remove = 0
}

public hookteamjoin( id )
{
	if ( !is_user_connected(id) )
		return PLUGIN_CONTINUE
	
	if ( !entity_get_int(id, EV_INT_team) )
		return PLUGIN_CONTINUE
	
	if ( get_gametime() - joining_time > JOINING_TIME )
		joining_num = 0
	
	if ( joining_num < MAX_PLAYERS_JOIN )
	{
		++joining_num
		if ( joining_num == 1 )
			joining_time = get_gametime()
	}else
		return PLUGIN_HANDLED
	
	return PLUGIN_CONTINUE
}

public readyroom_players( )
{
	for ( new id = players_moved + 1; id <= max_players; ++id )
	{
		if ( is_user_connected(id) )
		{
			player_counter++
			client_cmd(id, "impulse 5")
		}
		
		if ( player_counter % PLAYERS_TO_MOVE == 0 )
			break
		
		players_moved++
	}
	if ( players_moved == max_players )
	{
		players_moved = 0
		player_counter = 0
	}else if ( get_gametime() - roundend_time <= 7.0 )
		set_task(TIME_INTERVAL, "readyroom_players", 100)
}

public kill_entities( )
{
	if ( !is_valid_ent(entity_destroyer) )	// NS already did its reset
		return
	
	for ( new entity_counter; ent_to_remove <= max_entities; ++ent_to_remove )
	{
		if ( !is_valid_ent(ent_to_remove) )
			continue
		
		new iuser3 = entity_get_int(ent_to_remove, EV_INT_iuser3)
		// check for Marine + Alien buildings except Commandchair + Hive + RTs
		if ( ( iuser3 == 15 && entity_get_edict(ent_to_remove, EV_ENT_owner) == 0 )
			|| 24 <= iuser3 <= 34
			|| iuser3 == 37
			|| 41 <= iuser3 <= 45
			|| 47 <= iuser3 <= 49
			|| iuser3 == 57 )
		{
			// skip armories in combat ( will bug map )
			if ( combat_running &&
				( iuser3 == 25 ||  iuser3 == 26 ) )
				continue
			
			entity_counter++
			fake_touch(entity_destroyer, ent_to_remove)
			remove_entity(ent_to_remove)
		}else
			continue
		
		if ( entity_counter == ENTITIES_TO_KILL  )
			break
	}
	
	if ( get_gametime() - roundend_time <= 7.0
		|| ent_to_remove != max_entities )
		set_task(0.3, "kill_entities", 200)
	else
	{
		ent_to_remove = 0
		remove_entity(entity_destroyer)
	}
}

public backup_timer( )
{
	remove_task(100)
	remove_task(200)
}

create_destroyer( )
{
	new destroyer = create_entity("trigger_hurt")
	DispatchKeyValue(destroyer, "classname", "trigger_hurt")
	DispatchKeyValue(destroyer, "dmg", "19999")
	DispatchKeyValue(destroyer, "damagetype", "0")
	DispatchKeyValue(destroyer, "origin", "8192 8192 8192")
	DispatchSpawn(destroyer)
	entity_set_string(destroyer, EV_SZ_classname, "trigger_hurt")
	
	return destroyer
}