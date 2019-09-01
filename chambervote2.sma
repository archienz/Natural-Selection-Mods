/*       Chamber Vote plugin by Seraph      
		 Redone, Renewed, and Fixed by OneEyed 
*/

#include <amxmodx>
#include <ns>
#include <engine>
#include <fakemeta>

//Set color of Menu
#define R 255
#define G 200
#define B 100
//Set Voting Time
#define VOTE_TIME 25

// DO NOT EDIT BELOW HERE //---// DO NOT EDIT BELOW HERE //
// DO NOT EDIT BELOW HERE //---// DO NOT EDIT BELOW HERE //
#define MSG_DELAY 4.0
#define HUD_CHANNEL 6	

new g_DCA, g_MCA, g_SCA
new g_voteCount[3]
new needThird = 0
new voted[33], once, startTwo
new g_voteTime = VOTE_TIME
new Float:lastmessage[33]
new hive[5], hivehp[5], markhive[5]
new bool:disable = false
new g_sound[] = "common/wpn_hudon.wav"

public plugin_precache()
	precache_sound(g_sound)
	
public plugin_init()
{	
	register_plugin("Chamber Vote 2","2.1","Seraph (renewed by OneEyed)")
	//format( g_badMsg, 63, g_cUA )
	if ( !ns_is_combat() && !is_mvm()) {
		register_impulse( 92, "buildDC" )
		register_impulse( 93, "buildSC" )
		register_impulse( 94, "buildMC" )
		register_menucmd(register_menuid("allChamb"),MENU_KEY_1|MENU_KEY_2|MENU_KEY_3,"chamberCount")
		register_menucmd(register_menuid("twoChamb"),MENU_KEY_1|MENU_KEY_2,"chamberCount")
		register_event("Countdown", "gameStart", "ac")
		register_event("GameStatus", "EndofRound", "ab", "1=2" )
		
	}
}
public checkHives()
{
	new hiveCount = ns_get_build("team_hive", 1)
	new dahive
	if(hiveCount == 0) {
		for(new x=1;x<=ns_get_build("team_hive",0,0);x++) {
			dahive = ns_get_build("team_hive",0,x)
			ns_set_hive_trait(dahive,0)
		}
		disable = true
		g_DCA = 1
		g_MCA = 1
		g_SCA = 1
	}
	if(disable) {
		openChambers()
		remove_task(1234567)
	}
	return PLUGIN_HANDLED
}

public buildDC(id) {
	if ( !g_DCA ) {
		if ( (get_gametime() - lastmessage[id]) > MSG_DELAY) {
			ns_popup(id, "This chamber is unavailable")
			lastmessage[id] = get_gametime()
		}
		return PLUGIN_HANDLED
	}
	return PLUGIN_CONTINUE
}

public buildSC(id) {
	if ( !g_SCA ) {
		if ( (get_gametime() - lastmessage[id]) > MSG_DELAY) {
			ns_popup(id, "This chamber is unavailable")
			lastmessage[id] = get_gametime()
		}
		return PLUGIN_HANDLED
	}
	return PLUGIN_CONTINUE
}

public buildMC(id) {
	if ( !g_MCA ) {
		if ( (get_gametime() - lastmessage[id]) > MSG_DELAY) {
			ns_popup(id, "This chamber is unavailable")
			lastmessage[id] = get_gametime()
		}
		return PLUGIN_HANDLED
	}
	return PLUGIN_CONTINUE
}

public gameStart(id) {
	new Float:cdTime = get_cvar_float("mp_countdowntime") * 35
	g_voteCount = { 0, 0, 0 }
	needThird = 0
	g_DCA = 0
	g_MCA = 0
	g_SCA = 0
	once = 0
	startTwo = 0
	disable = false
	g_voteTime = VOTE_TIME
	for(new i=1;i<=3;i++)
		markhive[i] = 0
	for(new x=1;x<=get_maxplayers();x++)
		voted[x] = 0
	set_task( cdTime, "chamberVote" )
	set_task(2.0,"checkHives",1234567,"",_,"b")
}

public EndofRound()
{
	remove_task(12345)
	remove_task(99889988)
	remove_task(420420)
	remove_task(1234567)
}

public chamberVote(id) {
	if( disable ) return PLUGIN_HANDLED
	new hiveCount = ns_get_build("team_hive", 1)
	
	if(hiveCount == 1) {
		for ( new i = 1; i <= get_maxplayers(); i++) 
			if ( pev(i, pev_team) == 2 && !voted[i] && is_user_connected(i)) 
				show_menu( i, ((1<<0)|(1<<1)|(1<<2)), " ", g_voteTime, "allChamb") 
		if(once == 0) {
			g_voteCount = { 0, 0, 0 }
			set_task(1.0,"chamberVote",12345,"",_,"a",g_voteTime+1)
			set_task(1.0,"checkVotes",99889988,"",_,"a",g_voteTime)
			once = 1
			return PLUGIN_HANDLED
		}
	}
	return PLUGIN_HANDLED
}

public chamberCount(id,key) {
	if( disable ) return PLUGIN_HANDLED
	voted[id] = 1
	++g_voteCount[key]
	if ( !get_cvar_num("amx_show_activity") ) return PLUGIN_HANDLED

	new name[32]
	switch( get_cvar_num("amx_show_activity") ) {
		case 1: format( name, 31, "Player" )
		case 2: get_user_name(id, name, 31)
	}

	for ( new i = 1; i <= get_maxplayers(); i++ ) {
		if ( pev(i, pev_team) == 2 && is_user_connected(i) ) {
			client_print(i, print_chat, "%s voted for option #%d", name, key + 1)
		}
	}
	return PLUGIN_HANDLED
}

public checkVotes() {
	if( disable ) return PLUGIN_HANDLED
	
	new hiveCount
	for(new x=1;x<=3;x++)
		if(markhive[x] > 1)
			hiveCount++
	new result
	g_voteTime -= 1
	if(hiveCount == 0 && g_voteTime >= 0 && startTwo == 0) {
		for(new i=1;i<=get_maxplayers();i++) 
			if(pev(i,pev_team) == 2 && is_user_connected(i)) { 
				set_hudmessage(R, G, B, -1.05, 0.30, 0, 1.0, float(VOTE_TIME+5), 0.1, 0.1, HUD_CHANNEL)
				show_hudmessage(i,"        Choose first chamber (%i seconds):^n        1. Defense Chamber (%i votes)^n        2. Movement Chamber (%i votes)^n        3. Sensory Chamber (%i votes) ",g_voteTime,g_voteCount[0],g_voteCount[1],g_voteCount[2])
			}
	}
	else if((hiveCount == 1 && g_voteTime >= 0) || startTwo == 1) {
		if(g_DCA == 1) {
			for(new i=1;i<=get_maxplayers();i++) 
				if(pev(i,pev_team) == 2 && is_user_connected(i)) { 
					set_hudmessage(R, G, B, -1.05, 0.30, 0, 1.0, float(VOTE_TIME+5), 0.1, 0.1, HUD_CHANNEL)
					show_hudmessage(i,"        Choose second chamber (%i seconds):^n        1. Movement Chamber (%i votes)^n        2. Sensory Chamber (%i votes) ",g_voteTime,g_voteCount[0],g_voteCount[1])
				}
		}
		if(g_MCA == 1) {
			for(new i=1;i<=get_maxplayers();i++) 
				if(pev(i,pev_team) == 2 && is_user_connected(i)) { 
					set_hudmessage(R, G, B, -1.05, 0.30, 0, 1.0, float(VOTE_TIME+5), 0.1, 0.1, HUD_CHANNEL)
					show_hudmessage(i,"        Choose second chamber (%i seconds):^n        1. Defense Chamber (%i votes)^n        2. Sensory Chamber (%i votes) ",g_voteTime,g_voteCount[0],g_voteCount[1])
				}
		}
		if(g_SCA == 1) {
			for(new i=1;i<=get_maxplayers();i++) 
				if(pev(i,pev_team) == 2 && is_user_connected(i)) { 
					set_hudmessage(R, G, B, -1.05, 0.30, 0, 1.0, float(VOTE_TIME+5), 0.1, 0.1, HUD_CHANNEL)
					show_hudmessage(i,"        Choose second chamber (%i seconds):^n        1. Defense Chamber (%i votes)^n        2. Movement Chamber (%i votes) ",g_voteTime,g_voteCount[0],g_voteCount[1])
				}
		}
	}
	if ( hiveCount == 0  && g_voteTime == 0 && startTwo == 0) {
		/* Checks which one is bigger */
		if ( g_voteCount[0] > g_voteCount[1] ) {
			if ( g_voteCount[0] > g_voteCount[2] || g_voteCount[0] == g_voteCount[2] ) { result = 1; } 
			else { result = 3; }
		} else if ( g_voteCount[0] < g_voteCount[1] ) {
			if ( g_voteCount[1] > g_voteCount[2] || g_voteCount[1] == g_voteCount[2] ) { result = 2; } 
			else { result = 3; }
		} else if ( g_voteCount[0] > g_voteCount[2] ) {
			if ( g_voteCount[0] > g_voteCount[1] || g_voteCount[0] == g_voteCount[1] ) { result = 1; } 
			else { result = 2; }
		} else if ( g_voteCount[0] < g_voteCount[2] ) {
			if ( g_voteCount[2] > g_voteCount[1] || g_voteCount[2] == g_voteCount[1] ) { result = 3; } 
			else { result = 2; }
		} else { result = 1; }
		/* ...				*/

		new szFirstChamber[32]
		for(new x=1;x<=3;x++) {
			markhive[x] = ns_get_build("team_hive",1,x)
		}
		switch(result) {
			  case 1: {
				g_DCA = 1
				format( szFirstChamber, 31, "Defense" )
				ns_set_hive_trait(markhive[1],92)
			} case 2: {
				g_MCA = 1
				format( szFirstChamber, 31, "Movement" )
				ns_set_hive_trait(markhive[1],94)
			} case 3: {
				g_SCA = 1
				format( szFirstChamber, 31, "Sensory" )
				ns_set_hive_trait(markhive[1],93)
			}		
		}
		for ( new i = 1; i <= get_maxplayers(); i++ ) 
			if ( pev(i, pev_team) == 2 ) {
				client_cmd(i, "spk sound/%s", g_sound)
				show_hudmessage(i,"            The first chamber will be a %s chamber", szFirstChamber )
				client_print(i, print_chat, "The first chamber will be a %s chamber", szFirstChamber )	
			}
		g_voteTime = VOTE_TIME
		findNextHive()
		return PLUGIN_HANDLED

	} else if(hiveCount == 1 && g_voteTime == 0 && markhive[1] > 0) {
		result = 0
		if ( g_voteCount[0] > g_voteCount[1] || g_voteCount[0] == g_voteCount[1] ) {
			result = 1
		} else {
			result = 2
		}
		
		for(new x=1;x<=hiveCount;x++) {
			markhive[x] = ns_get_build("team_hive",1,x)
		}
		new szSecondChamber[32]
		if ( (g_DCA && result == 1) || (g_SCA && result == 2)) {
			g_MCA = 1
			ns_set_hive_trait(markhive[2],94)
			format( szSecondChamber, 31, "Movement" )
		}
		else if ( (g_DCA && result == 2) || (g_MCA && result == 2)) {
			g_SCA = 1
			ns_set_hive_trait(markhive[2],93)
			format( szSecondChamber, 31, "Sensory" )
		}
		else if (( g_MCA && result == 1) || (g_SCA && result == 1) ) {
			g_DCA = 1
			ns_set_hive_trait(markhive[2],92)
			format( szSecondChamber, 31, "Defense" )
		} 

		for ( new j = 1; j <= get_maxplayers(); j++ ) {
			if ( pev(j, pev_team) == 2 && is_user_connected(j)) {
				client_cmd(j, "spk sound/%s", g_sound)
				show_hudmessage(j,"            The second chamber will be a %s chamber", szSecondChamber )
				client_print(j, print_chat, "The second chamber will be a %s chamber", szSecondChamber )
			}
		}
		g_voteTime = VOTE_TIME
		needThird = 1
		findNextHive()
		return PLUGIN_HANDLED
	}

	return PLUGIN_HANDLED
}

public findNextHive() {
	if( disable ) return PLUGIN_HANDLED
	new hiveCount = ns_get_build("team_hive",1)
	new hives = ns_get_build("team_hive",0,0)
	for(new x=1;x<=hives;x++) {
		hive[x] = ns_get_build("team_hive",0,x)
		hivehp[x] = floatround(entity_get_float(hive[x], EV_FL_health))
		if((hiveCount == 2 && needThird == 0) || ( hiveCount == 1 && hivehp[x] < 5000 && ns_get_hive_trait(hive[x]) == HIVETRAIT_NONE ) && startTwo != 1) {
			startTwo = 1
			g_voteCount = { 0, 0, 0 }
			for ( new i = 1; i <= get_maxplayers(); i++) 
				if ( pev(i, pev_team) == 2 ) 
					show_menu( i, MENU_KEY_1|MENU_KEY_2, " ", g_voteTime, "twoChamb" ) 	
			set_task(1.0,"checkVotes",99889988,"",_,"a",g_voteTime)
			return PLUGIN_HANDLED
		}
	}
	
	if(hiveCount == 3) {
		openChambers()
		return PLUGIN_HANDLED
	}
	set_task(1.0,"findNextHive",420420)
	return PLUGIN_HANDLED
}

public openChambers() {
	g_DCA = 1
	g_MCA = 1
	g_SCA = 1

	set_hudmessage(R, G, B, -1.05, 0.30, 0, 1.0, float(VOTE_TIME+1), 0.1, 0.1, HUD_CHANNEL)

	for ( new i = 1; i <= get_maxplayers(); i++ ) {
		if ( pev(i, pev_team) == 2 && is_user_connected(i)) {
			if( disable ) {
				client_cmd(i, "spk sound/%s", g_sound)
				show_hudmessage( i, "        All hives died.  All Chambers unlocked." )
			}
			else {
				client_cmd(i, "spk sound/%s", g_sound)
				show_hudmessage( i, "        All chambers are currently available" )
			}
		}
	}
}

public is_mvm() {
	new checkcc = ns_get_build("team_command",0, 0)
	if(checkcc > 1)
		return 1
	return 0
}
