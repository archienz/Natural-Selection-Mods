/* Combat Time Extender
* This plugin is meant to ask the players towards the end of the game if they would 
* like to extend game play time (to get more levels or something)
*
* Cvars
* extend_prop This is the percent of people you want to say yes before extending time (default 75)
* extend_time This is the amount of time (in minutes) that you want the map to extend every time (default 10)
*
* Commands
* amx_extend This is the console command any admin (with vote privaleges) can execute, to prematurely start extend combat time vote.
*
* Original was made by Newbster (http://forums.alliedmods.net/showthread.php?p=96909)
* 
* Changelog
* version 1.2.3
* - now using a task to set normalCombatTime
* version 1.2.2
* - added plugin_cfg to set normalCombatTime
* version 1.2.1
* - now using Countdown event instead of plugin_end to reset combattime
* version 1.2
* - do some checks before display votemenu
* - check if a vote is in process
* - added hud warning msg
* version 1.1
* - amx_canclevote compatible
* version 1.0
* - initial release
*/

#include <amxmodx>
#include <amxmisc>
#include <ns>

#define PLUGIN_NAME "Combat Extender"
#define PLUGIN_VERSION "1.2.3"
#define PLUGIN_AUTHOR "skulk_on_dope original from Newbster"

#define mKEYS MENU_KEY_1|MENU_KEY_2

#define MINUTES_BEFORE_END 3
#define HUD_CHANNEL -1			// comment this line if u do not want a hud msg

new Float:g_RoundStarted, normalCombatTime, mVotes[3]

public plugin_init() {
	register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR)
	register_cvar("amx_combatexternder", PLUGIN_VERSION, FCVAR_SERVER)
	register_cvar("extend_time", "15")
	register_cvar("extend_prop", "75")
	
	register_clcmd("amx_extend", "CMD_Extend", ADMIN_VOTE, " - start vote extend (Combat only)")
	
	if(ns_is_combat()) {
		register_menucmd(register_menuid("VoteExtend"), mKEYS, "PressedVoteExtend")
		register_event("Countdown", "Event_GameStarted", "ab")
		register_event("GameStatus", "Event_RoundEnd", "ab", "1=2")
		set_task(5.0, "Task_cfg")
	}
}

public Task_cfg() {
	normalCombatTime = get_cvar_num("mp_combattime")
}

public Event_GameStarted() {
	set_task(30.0, "Task_checktime", 1, _, _, "b", 1)
	g_RoundStarted = get_gametime()
}

public Event_RoundEnd() {
	set_cvar_num("mp_combattime", normalCombatTime)
	remove_task(1)
}

public Task_checktime() {
	new combattime = get_cvar_num("mp_combattime")
	if(combattime == 0) {
		return PLUGIN_HANDLED
	} else if((get_gametime() - g_RoundStarted) >= (combattime * 60 - MINUTES_BEFORE_END * 60) && get_cvar_float("amx_last_voting") <= get_gametime()) {
#if defined HUD_CHANNEL
		set_hudmessage(200, 100, 0, -1.0, -1.0, 0, 6.0, 2.0, 0.0, 0.0, HUD_CHANNEL)
		show_hudmessage(0, "a vote will start in a sec")
#endif
		set_task(1.5, "startVote")
	}
	
	return PLUGIN_HANDLED
}

public startVote() {
	new Float:votetime = get_cvar_float("amx_vote_time")
	set_cvar_float("amx_last_voting", get_gametime() + votetime)
	client_print(0, print_chat, "[Combat Extender] Vote Started")
	for(new i=1; i <= get_maxplayers(); i++) {
		if(is_user_connected(i) && !is_user_bot(i) && !is_user_hltv(i))
			show_menu(i, mKEYS, "Extend Combattime ?^n^n1. Yes^n2. No^n", floatround(votetime - 0.5), "VoteExtend")
	}
	
	set_task(votetime, "display_results", 99889988)
}

public PressedVoteExtend(id, key) {
	switch (key) {
		case 0: { // 1
			mVotes[1]++
		}
		case 1: { // 2
			mVotes[0]++
		}
	}
	
	if(get_cvar_num("amx_vote_answers")) {
		new vName[33]
		get_user_name(id, vName, 32)
		client_print(0, print_chat, "[Combat Extender] %s voted %s", vName, (key == 0) ? "Yes" : "No")
	}
}

public display_results() {
	new votesNeeded = floatround(get_cvar_float("extend_prop") / 100 * get_playersnum())
	new extendTime = get_cvar_num("extend_time")
	client_print(0, print_chat, "[Combat Extender] Extend Combat Time %d minutes? (Needed %d): %i Yes || %i No", extendTime, votesNeeded, mVotes[1], mVotes[0])
	
	if(mVotes[1] >= votesNeeded) {
		set_cvar_num("mp_combattime", (get_cvar_num("mp_combattime") + extendTime))
		client_print(0, print_chat, "[Combat Extender] Combat Time extended to %d", get_cvar_num("mp_combattime"))
	} else {
		if(task_exists(1))
			remove_task(1)
	}
	mVotes[0] = 0
	mVotes[1] = 0
	
	return PLUGIN_CONTINUE
} 

public CMD_Extend(id, level, cid) {
	if(!cmd_access(id, level, cid, 0))
		return PLUGIN_HANDLED
	
	if(!ns_is_combat()) {
		client_print(id, print_console, "[Combat Extender] Combat only")
		return PLUGIN_HANDLED
	}
	
	if(get_cvar_float("amx_last_voting") > get_gametime()) {
		client_print(id, print_console, "[Combat Extender] there is already one vote running, pls wait until it^'s finished")
		return PLUGIN_HANDLED
	}
	
	new aName[33]
	get_user_name(id, aName, 32)
	
	switch(get_cvar_num("amx_show_activity")) {
		case 1: client_print(0, print_chat, "[Combat Extender] Admin: started Vote")
		case 2: client_print(0, print_chat, "[Combat Extender] Admin %s: started Vote", aName)
	}
	
	log_amx("%s started extend vote", aName)
	
	
#if defined HUD_CHANNEL
	set_hudmessage(200, 100, 0, -1.0, -1.0, 0, 6.0, 2.0, 0.0, 0.0, HUD_CHANNEL)
	show_hudmessage(0, "a vote will start in a sec")
#endif
	set_task(1.5, "startVote")
	
	return PLUGIN_HANDLED
}
