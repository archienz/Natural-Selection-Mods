/*
 *	Respawns all players in one team in a wave
 *
 *	Note:		Time till spawn = 5 seconds +2 seconds for each dead player
 *
 *	Commands:	None
 *
 *	Cvars:		None
 *    
 *	Requires:	AMXX 1.0
 *
 *	Author:		Cheesy Peteza
 *	Updated By:	Violent_KoRn / qizmo
 *	Date:		25-June-2004
 *	Email:		cheesy@yoclan.com
 *	irc:		#yo-clan (QuakeNet)
 *	fixdate :	12 - Dec -2004
 *	version:	2.1
 */


#include <amxmodx>
#include <engine>
#include <fakemeta>
#include <ns>

#define SYSNAME 		"Cheesy's Respawn System"	//respawn system name

#define SPAWN_DELAY			1.0	// Per player in seconds
#define MAX_MULTIPLIER		6	// Maximum multiplier * SPAWN_DELAY (2*8+5=21 max spawn time)
#define HUD_CHANNEL			1	// 1-4 Used for the time to spawn info text. May clash with other plugins.
#define MARINE1				1
#define MARINE2				3
#define FREE_LOOK			3
#define DEAD_RESPAWNABLE	3

enum
{
	PLAYERCLASS_NONE = 0,
	PLAYERCLASS_ALIVE_MARINE,
	PLAYERCLASS_ALIVE_JETPACK,
	PLAYERCLASS_ALIVE_HEAVY,
	PLAYERCLASS_ALIVE_LEVEL1,
	PLAYERCLASS_ALIVE_LEVEL2,
	PLAYERCLASS_ALIVE_LEVEL3,
	PLAYERCLASS_ALIVE_LEVEL4,
	PLAYERCLASS_ALIVE_LEVEL5,
	PLAYERCLASS_ALIVE_DIGESTING,
	PLAYERCLASS_ALIVE_GESTATING,
	PLAYERCLASS_DEAD_MARINE,
	PLAYERCLASS_DEAD_ALIEN,
	PLAYERCLASS_COMMANDER,
	PLAYERCLASS_REINFORCING,
	PLAYERCLASS_SPECTATOR,
	PLAYERCLASS_REINFORCINGCOMPLETE		//never used
}

enum 
{
	PLAYMODE_UNDEFINED = 0,
	PLAYMODE_READYROOM,
	PLAYMODE_PLAYING,
	PLAYMODE_AWAITINGREINFORCEMENT,	// Player is dead and waiting in line to get back in
	PLAYMODE_REINFORCING,		// Player is in the process of coming back into the game
	PLAYMODE_OBSERVER
}

new g_maxplayers
new Float:g_qstarttime[3], Float:g_spawntime[3]
new bool:g_spawning[3], bool:g_spawning2[3]
new g_ScoreInfo[33][7]
new g_msgScoreInfo, g_msgHudText2
new Float:g_lasttimenotify


public plugin_init() {

	if ( ns_is_combat() ) {
	
		register_plugin("CRS (ON)", "2.1", "Cheesy Peteza/VK/qizmo")
		register_cvar("cheesysrespawn_version", "2.1", FCVAR_SERVER)
	
		g_maxplayers = get_maxplayers()
		g_msgScoreInfo = get_user_msgid("ScoreInfo")
		g_msgHudText2 = get_user_msgid("HudText2")

		register_event("ResetHUD", "playerSpawned", "b")
		register_message(get_user_msgid("ScoreInfo"), "editScoreInfo")
		register_message(g_msgHudText2, "editHudText2")
		register_message(get_user_msgid("SayText"), "editSayText")

		set_task(0.25, "checkStatus",_,_,_,"b")
	} else {
	
		register_plugin("CRS (OFF)", "2.1", "Cheesy Peteza/VK/qizmo")
		register_cvar("cheesysrespawn_version", "2.1", FCVAR_SERVER)
	
	}
}

public checkStatus() {
	new numinqueue[3]

	for (new id = 1; id <= g_maxplayers; id++) {		// Stop people spawning and count how many there is in the queue

		if ( is_user_alive(id) )
			continue

		new team = pev(id, pev_team)

		if ( g_spawning[team] || (team == 6) || (team == 0) )
			continue

		++numinqueue[team]
	}

	for (new team = 1; team <= 2; ++team) {
		if (numinqueue[team] > 0) {
			numinqueue[team] = clamp(numinqueue[team], 1, MAX_MULTIPLIER)
			if (g_qstarttime[team] == 0.0)
				g_qstarttime[team] = get_gametime()

			new Float:spawndelay = ( numinqueue[team] -1 ) * SPAWN_DELAY + 5.0

			g_spawntime[team] = (g_qstarttime[team] + spawndelay) - get_gametime() + 2.5
									// Have to add 2.5 to the end here otherwise as soon as a player
									// died he'd spawn straight away, and waves wouldn't happen
			if ( g_spawntime[team] <= 5.0 )		// Takes 5 seconds for NS to spawn a player after
				spawnPlayers(team)		// setting their class to REINFORCING
		}
	}

	if ( get_gametime() - g_lasttimenotify >= 0.75) {	// Show time till spawn message once every 1/2 second
		g_lasttimenotify = get_gametime()
		displaySpawnTime(numinqueue)
	}

	return PLUGIN_HANDLED
}


spawnPlayers(team) {
	g_spawning[team] = true		// Stop checking for dead players were in the middle of spawning people
	/*set_task(5.0, "teamSpawnedReset", 24338+team)*/	// Just incase for some reason we don't detect people spawning, this
							// is a backup that kicks in after 5 seconds if the team doesn't spawn.
	for (new id = 1; id <= g_maxplayers; id++) {
		if (!is_user_connected(id) || pev(id, pev_team) != team || is_user_alive(id)) continue

		if ( pev(id, pev_deadflag) > 0 ) {	// OBSERVER is what we set them to
			set_pev(id, pev_playerclass, PLAYMODE_REINFORCING)	// so they don't spawn.

			// Update the scoreboard with "Reinforcing".
			emessage_begin(MSG_ALL, g_msgScoreInfo)
			ewrite_byte ( id )
			ewrite_short ( g_ScoreInfo[id][0] )
			ewrite_short ( g_ScoreInfo[id][1] )
			ewrite_short ( g_ScoreInfo[id][2] )
			ewrite_byte ( PLAYERCLASS_REINFORCING )
			ewrite_short ( g_ScoreInfo[id][4] )
			ewrite_short ( g_ScoreInfo[id][5] )
			ewrite_string ("")
			emessage_end()				

			emessage_begin(MSG_ONE, g_msgHudText2,_,id)
			ewrite_string("ReinforcingMessage")
			ewrite_byte(1)
			emessage_end()			
		}
	}
}

public playerSpawned(id) { 	// For detecting when a team has actually spawned after being set to REINFORCING class.
	if (g_ScoreInfo[id][5] == 0) return PLUGIN_HANDLED	// They just came from the ready room, ignore them.
	new model[64]
	pev(id, pev_model, model, 63)
	if ( !equal("models/player.mdl", model) )
		return PLUGIN_CONTINUE			// Fix for a possible exploit

	new team = pev(id, pev_team)
							// Only set_task once, but give people time to spawn too
	if (!g_spawning[team] || g_spawning2[team]) return PLUGIN_HANDLED
	g_spawning2[team] = true

	set_task(0.2, "teamSpawnedReset", team)			// Give people time to spawn
	remove_task(24338+team)		// Disable the backup system
	return PLUGIN_CONTINUE
}

public teamSpawnedReset(team) {
	if (team > 24338) team -= 24338	// For the backup system

	g_qstarttime[team] = 0.0
	g_spawning[team] = false	// Enable checking for dead players again, the spawning is over.
	g_spawning2[team] = false

}

public displaySpawnTime(numinqueue[]) {		// Display time to spawn info to dead players.
	for (new id = 1; id <= g_maxplayers; id++) {
		if ( pev(id, pev_deadflag) != DEAD_RESPAWNABLE ) continue

		new team = pev(id, pev_team)

		if( team == 6 || team == 0 )
			continue

		new deadtime[7]
		formatex(deadtime, 6, " + %.0f", SPAWN_DELAY)
		new calctext[128] = "5"

		for (new i; i < ( numinqueue[team] -1 ); ++i)
			add(calctext, 127, deadtime)	// calctext = "5 + 2 + 2 + 2 + 2" 

		new hudtext[256]
		if ( g_spawning[team] ) 
			if (pev(id, pev_playerclass) == PLAYMODE_REINFORCING) {
				format(hudtext, 255, "%s^n^nTime till spawn: Spawning^n(%.0f seconds per dead player) [max %d secs]", 
				SYSNAME, SPAWN_DELAY, floatround((MAX_MULTIPLIER-1)*SPAWN_DELAY+5.0))
			} else {
				format(hudtext, 255, "%s^n^nTime till spawn: Waiting for next wave^n(%.0f seconds per dead player) [max %d secs]",
				SYSNAME, SPAWN_DELAY, floatround((MAX_MULTIPLIER-1)*SPAWN_DELAY+5.0))
			}
		else
			format(hudtext, 255, "%s^n^nTime till spawn: %0.f^n(%.0f seconds per dead player) [max %d secs]^n%s", 
				SYSNAME, floatsub(g_spawntime[team], 2.0), SPAWN_DELAY, floatround((MAX_MULTIPLIER-1)*SPAWN_DELAY+5.0), calctext)

		new is_marine = (team == MARINE1 || team == MARINE2)
		set_hudmessage(is_marine ? 0 : 160, is_marine ? 75 : 100, is_marine ? 100 : 0, 0.1, 0.1, 0, 0.0, 60.0, 0.0, 0.0, HUD_CHANNEL)
		show_hudmessage(id, hudtext)
	}
}

public editScoreInfo(msg_id, msg_dest, msg_entity) {	// Replace Scoreboard "Reinforcing" with "DEAD" we will send "Reinforcing" ourselves.
	new id = read_data(1)
	for (new i; i<6; ++i) 
		g_ScoreInfo[id][i] = read_data(i+2)

}

public editHudText2(msg_id, msg_dest, msg_entity) {		// Change "You are Spawning..." to "You are in a queue for reinforcing..."
	new text[64]
	get_msg_arg_string(1, text, 63)	

	if (!equal(text, "ReinforcingMessage") || !is_user_connected(msg_entity)) return PLUGIN_CONTINUE

	if (!g_spawning[pev(msg_entity, pev_team)])
		set_msg_arg_string(1, "ReinforcementMessage")

	return PLUGIN_CONTINUE
}

public server_frame() {		// Because we changed the players class they can view both teams in spectator mode. Here we fix that.
	for (new id=1; id <= g_maxplayers; id++) {
		if ( !is_user_connected(id) )	continue
		if ( pev(id, pev_deadflag) != DEAD_RESPAWNABLE ) continue
		new viewingid = pev(id, pev_iuser2)
		if (viewingid == 0) continue
		if ( pev(viewingid, pev_team) == pev(id, pev_team) ) continue
		if ( pev(id, pev_team) == 0 ) continue	// Ignore Spectators

		new team[32], players[32], num
		get_user_team(id, team, 31)
		get_players(players, num, "ae", team)

		if (num) {
			set_pev(id, pev_iuser2, players[random_num(0,num-1)])	// Make them look at someone on their team.
		} else {
			set_pev(id, pev_iuser1, FREE_LOOK)			// Nobody to look at, look at the wall.
			set_pev(id, pev_iuser2, 0)
		}
	}
}

public editSayText(msg_id, msg_dest, msg_entity) {	// Need to manually block team chat messages from going to the other team due to player class changes
	new text[256]
	get_msg_arg_string(2, text, 255)		

	if (contain(text, "(TEAM)") != -1) {
		new fromid = get_msg_arg_int(1)
		new toid = msg_entity

		if ( pev(fromid, pev_team) != pev(toid, pev_team) )
			return PLUGIN_HANDLED
	}
	return PLUGIN_CONTINUE
}