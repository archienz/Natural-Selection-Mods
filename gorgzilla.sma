/*
 Copyright (C) 2005  Joel R. (OneEyed)
 
 This program is free software; you can redistribute it and/or
 modify it under the terms of the GNU General Public License
 as published by the Free Software Foundation; either version 2
 of the License, or (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 *
 *  Comments: 
 *  When activated, starts a raffling session, to become GorgZilla. When time is up, it randomly
 *  chooses, who gets to be GorgZilla.  Then it begins the spawning event. After GorgZilla has spawned,
 *  the match begins. Marines must damage the hive, to get the GorgZilla's shield down, in order to kill him.
 *  After the hive runs out of lives, GorgZilla's shield will stay down forever.  If GorgZilla kills the amount
 *  needed, GorgZilla wins.  Marines win by killing GorgZilla, if helpers get a kill, GorgZilla's kills will not 
 *  change.
 *
 *	Note:	The plugin automatically disables itself in classic NS mode and in Marine vs Marine mode.
 *				
 *	Commands:	
 * 		amx_gorgzilla 	  		- (Activates GorgZilla Raffle) Default Access = RCON
 *		amx_gorgzilla_vote 		- (Activates a Vote, for enabling GorgZilla Raffle.) Default Access = SLAY
 *
 *	CVARs:
 *		==Dont Change==
 *		zilla_GorgZilla			- (0 = OFF , 1 = ON - Can also be used to disable other plugins if this is running.) 
 *	
 *		==Change BEFORE starting Raffle/Vote==
 *		zilla_hp 		  		- (GorgZilla's Starting HP)
 * 		zilla_hivehp	  		- (Hive Starting HP - NOTE: MUST BE 2000 MORE THAN ACTUAL VALUE.)
 *  	zilla_hivelives   		- (Hive Lives - Brings down shield this many times before permanently.)
 *		zilla_helpers	  		- (Max GorgZilla helpers will be created if eaten.)
 *		zilla_shielddelay 		- (Seconds between hive lives when shield is down.)
 *		zilla_raffletime  		- (GorgZilla Raffle Time, time given to enter raffle.)
 *		zilla_votetime			- (GorgZilla Voting Time, time given to vote.)
 
 *		==RealTime Changeable==
 *		zilla_helperhp			- (Starting Helper HP) 
 * 		zilla_kills		  		- (GorgZilla kills needed to win.) 
 *
 *	Requires:	AMXX 1.60 with NS module 
 *
 *	Author:		OneEyed
 *	Date:		07-11-2005
 *	Email:		oneeyed@stx.rr.com
 *	irc:		#zT (gamesurge.net) 
 *
 * 	Tested :
 *	GorgZilla plugin was tested on a win32 machine.  Linux untested.
 * 
 *  Credits: 
 *    Superelf     		   - for the idea of uber alien. Almost 1 year ago
 *    CheesyPeteza 		   - for his impulse handler.
 *    zeroTolerance server - for helping test it on live server. ip: 209.75.97.8:27015
 *   
 *  Thanks to:
 *	  LastOutlaw		   - for helping test some stuff
 * 	  ccnncc99 			   - for helping test some stuff
 */

#define ADMIN_ACCESS_START ADMIN_RCON		//Default Access needed to enable GorgZilla Raffle.
#define ADMIN_ACCESS_VOTE ADMIN_SLAY	//Default Access needed to enable GorgZilla Vote.
#define HUD_CHANNEL 6

////////////////////////////////////////////////////////////////////////////////
//-------DO NOT EDIT BELOW HERE-------////-------DO NOT EDIT BELOW HERE-------//
//-------DO NOT EDIT BELOW HERE-------////-------DO NOT EDIT BELOW HERE-------//
////////////////////////////////////////////////////////////////////////////////

#include <amxmodx>
#include <amxmisc>
#include <engine>     
#include <fakemeta>
#include <ns>

//Impulse Message Delay (CheesyPeteza's Impulse Handler)
#define MESSAGE_DELAY 	4

//Change these if you plan on using different models (smallGorgZilla is Helper)
new smallGorgZilla[] = "models/player/alien3/smallGorgZilla.mdl"
new gorgzilla[] = "models/player/alien3/GorgZilla.mdl"

//Comments below are to help understand the code better.. For CODERS only
new cc, hive, oldlimit, oldconcede, maxplayers, shielddown, kills, fire, smoke
new choose = 0			//GorgZilla ID stored here
new gorgOn = 0			//GorgZilla enabled variable
new counter = 1			//Used for starting the spawning events (setup function)
new timer = 0			//Seconds timer, to count how long round takes (roundtime function)
new once = 1			//Once flag, to run certain stuff only 1 time
new voteCount			//Vote Timer, uses zilla_votetime cvar
new voting = 0			//Voting flag (0 = not voting , 1 = voting)

new gorgzilla_hp			//Starting GorgZilla HP
new max_helpers				//Max Helpers allowed
new hive_hp					//Starting Hive HP
new zilla_raffle_time		//Raffle Time
new shield_down_delay		//Shield Down Delay
new hive_lives				//Starting Hive Lives

new yes[33]					//Voted yes
new no[33]					//Voted no
new ahelpers[33]			//Helper Flag (1 = helper , 0 = not helper)
new teamswitch[33]			//Helper Flag (to help switch teams)
new chance[33]				//Raffle Flag (1 = entered raffle , 0 = not entered)
new valid[33]				//Valid Flag (all IDs who entered raffle stored in here)
new aname[33]				//For printing name
new hudmsg[256]				//hudmessages saved in here.
new catchphrase[64]			//catchphrase saved here
new Float:precaution = 2000.0	//precaution (LEAVE UNCHANGED)
new Float:lasttime				
new Float:g_lastmessage[33]		
new Float:hivelife				//Hive HP updated on this variable
new Float:gorgHealth			//Actual gorgzilla hp updated on this variable

new distress[] = "misc/distressbeacon.wav"
new siren[] = "ambience/siren.wav"


public plugin_precache()
{
	if(ns_is_combat() && !is_mvm())
	{
		precache_sound(distress)
		precache_sound(siren)
		precache_model(gorgzilla)
		precache_model(smallGorgZilla)
		fire = precache_model("sprites/shockwave.spr")
		smoke = precache_model("sprites/steam1.spr") 
	}
}
public plugin_init()
{
		
	if(ns_is_combat() && !is_mvm())
		register_plugin("GorgZilla (Activated)", "1.03", "OneEyed")
		
	if(is_mvm() || !ns_is_combat())
		register_plugin("GorgZilla (Deactivated)", "1.03", "OneEyed")
		
	if(ns_is_combat() && !is_mvm())
	{ 
		//Client Enter Raffle Commands
		register_clcmd("GorgZilla", "roll")
		register_clcmd("say GorgZilla", "roll")
		register_clcmd("say_team GorgZilla", "roll")
		
		//Start GorgZilla Raffle
		register_clcmd("amx_gorgzilla","zillaCmd")
		//Start GorgZilla Vote
		register_clcmd("amx_gorgzilla_vote","zillaVote",ADMIN_ACCESS_VOTE,"Starts a vote for a round of GorgZilla")
		
		//Our menuid is called "   " thats 3 spaces
		//This method lets you create a better looking menu with hudmessage.
		register_menucmd(register_menuid("gVote"),1023,"voteMenu")
		
		//GorgZilla cvars
		register_cvar("zilla_GorgZilla","0",FCVAR_SERVER) //0 = disabled, 1 = enabled (used for plugins to check if its activated)
		register_cvar("zilla_votetime","25")
		register_cvar("zilla_hp","15000")
		register_cvar("zilla_kills","40")
		register_cvar("zilla_hivehp","18000") //2000 more than actual value. (eg. 18000 = 16000hp)
		register_cvar("zilla_hivelives","3")
		register_cvar("zilla_raffletime","25")
		register_cvar("zilla_shielddelay","20")
		register_cvar("zilla_helpers","3")
		register_cvar("zilla_helperhp","1500")
		
		maxplayers = get_maxplayers()
		oldlimit = get_cvar_num("mp_limitteams")		//To reset server default values.
		oldconcede = get_cvar_num("mp_autoconcede") 	//To reset server default values.
		register_impulse(118,"upgradeblock")//next hive
		register_impulse(126,"upgradeblock")//next hive2
		register_impulse(101,"upgradeblock")//carapace
		register_impulse(102,"upgradeblock")//regen
		register_impulse(103,"upgradeblock")//redemp
		register_impulse(108,"upgradeblock")//celerity
		register_impulse(107,"upgradeblock")//adren
		register_impulse(109,"upgradeblock")//silence
		register_impulse(110,"upgradeblock")//cloaking
		register_impulse(111,"upgradeblock")//focus
		register_impulse(112,"upgradeblock")//scent of fear
		register_impulse(113,"upgradeblock")//skulk
		register_impulse(116,"upgradeblock")//fade
		register_impulse(115,"upgradeblock")//lerk
		register_impulse(114,"upgradeblock")//gorge
		if(!gorgOn)
			set_cvar_num("zilla_GorgZilla",0)	//Turn off automatically on startup.
		for(new a=0;a<=maxplayers;a++) {
			chance[a] = 0
		}
	}
}
public client_connect(id)
{
	if(!ns_is_combat() || is_mvm())
		return PLUGIN_HANDLED
	chance[id] = 0
	teamswitch[id] = 0
	ahelpers[id] = 0
	yes[id] = 0
	no[id] = 0
	return PLUGIN_HANDLED
}
public client_disconnect(id)
{
	if(!ns_is_combat() || is_mvm())
		return PLUGIN_HANDLED
	teamswitch[id] = 0
	chance[id] = 0
	ahelpers[id] = 0
	yes[id] = 0
	no[id] = 0
	return PLUGIN_HANDLED
}

public roll(id)
{
	if(!gorgOn) {
		client_print(id, print_chat, "[GorgZilla] Raffle is not activated at this time.")
		return PLUGIN_HANDLED
	}
	if(choose != 0) {
		client_print(id,print_chat,"[GorgZilla] A winner has been chosen already.")
		return PLUGIN_HANDLED
	}
	if(chance[id] != 1) {
		get_user_name(id,aname,32)
		client_print(0, print_chat, "[GorgZilla] %s has entered the raffle.",aname)
		chance[id] = 1
	}
	else 
		client_print(id,print_chat, "[GorgZilla] You already entered the raffle.")
	return PLUGIN_HANDLED
}

public zillaCmd(id)
{
	if ( !(get_user_flags(id) & ADMIN_ACCESS_START) ) {
		client_print(id,print_chat,"[GorgZilla] Only Admins with RCON access can enable GorgZilla.")
		return PLUGIN_HANDLED
	}
	if(!gorgOn || !voting)
		begin()
	return PLUGIN_HANDLED
}

public zillaVote(id,level,cid) 
{
	if(gorgOn || !ns_is_combat() || is_mvm() || voting)
		return PLUGIN_HANDLED
	if ( !(get_user_flags(id) & ADMIN_ACCESS_VOTE) ) {
		client_print(id,print_chat,"[GorgZilla] Only Admins with access can start a GorgZilla vote.")
		return PLUGIN_HANDLED
	}
	voting = 1
	//new voteDisplay[64]
	voteCount = get_cvar_num("zilla_votetime")
	//format(voteDisplay,63, "Do a round of GorgZilla?^n^t1. Yes^n^t2. No")
	for(new x=1;x<=maxplayers;x++) {
		if(is_user_connected(x))
			//show_menu(index,keys,const menu[], time = -1, title[] = "");
			show_menu(x,((1<<0)|(1<<1))," ",voteCount, "gVote")
	}
	set_hudmessage(200, 100, 200, -1.05, 0.30, 1, 1.0, float(get_cvar_num("zilla_votetime")+5), 0.1, 0.1, HUD_CHANNEL)
	set_task(1.0,"checkVote",5000,"",_,"a",voteCount)
	return PLUGIN_HANDLED
}

public voteMenu(id,key) 
	if(is_user_connected(id))
		switch(key) {
			case 0: yes[id] = 1
			case 1: no[id] = 1
		}

public checkVote()
{
	
	voteCount--
	new countYes = 0
	new countNo = 0
	for(new x=1;x<=maxplayers;x++)
		if(is_user_connected(x)) {
			if(yes[x] == 1)
				++countYes
			if(no[x] == 1)
				++countNo	
		}
	
	if(voteCount > 0)
		show_hudmessage(0,"^tPlay GorgZilla this round? ^n^tVote Time Left: %i seconds^n^t^t1. Yes (%i votes)^n^t^t2. No (%i votes) ",voteCount,countYes,countNo)
	if(voteCount == 0) {
		if(countYes > countNo) {
			set_task(4.0,"begin",1000)
			show_hudmessage(0,"^tGorgZilla Vote Results: (Yes) wins^n^t^tYes (%i votes)^n^t^tNo (%i votes) ",countYes,countNo)
		}
		else if(countNo > countYes)
			show_hudmessage(0,"^tGorgZilla Vote Results: (No) wins^n^t^tYes (%i votes)^n^t^tNo (%i votes)",countYes,countNo)
		else if(countYes == countNo)
			show_hudmessage(0,"^n^tGorgZilla Vote Results: (Tied) Nothing Happens^n^t^tYes (%i votes)^n^t^tNo (%i votes) ",countYes,countNo)
		
		for(new x=1;x<=maxplayers;x++)
			if(yes[x] == 1 || no[x] == 1) {
				yes[x] = 0
				no[x] = 0
			}
		voting = 0
	}
	return PLUGIN_HANDLED
}

public begin()
{
	if(choose != 0 || !ns_is_combat() || is_mvm()) {
		return PLUGIN_HANDLED
	}
	
	if(!gorgOn) {
		
		gorgzilla_hp = get_cvar_num("zilla_hp")
		max_helpers = get_cvar_num("zilla_helpers")
		hive_hp = get_cvar_num("zilla_hivehp")
		zilla_raffle_time = get_cvar_num("zilla_raffletime")
		shield_down_delay = get_cvar_num("zilla_shielddelay")
		hive_lives = get_cvar_num("zilla_hivelives")
		set_cvar_num("zilla_GorgZilla",1)
		timer = 0
		set_hudmessage(200, 100, 200, -1.0, 0.60, 1, 1.0, float(zilla_raffle_time + 1), 0.1, 0.1, HUD_CHANNEL)
	}
	gorgOn = 1
	
	show_hudmessage(0,"Type GorgZilla , to enter raffle for chance at being GorgZilla!! ^n%i seconds left to enter.",zilla_raffle_time)
	if(zilla_raffle_time <= 0) {
		new x = 0
		for(new i=1;i<maxplayers;i++) {
			if(chance[i] == 1) {
				++x				//Count ID's who entered raffle
				valid[x] = i	//Adds all who typed gorgzilla and counts them
			}
		}
		
		if(x == 0) {
			show_hudmessage(0,"No one voted, deactivating GorgZilla round.")
			cleanup()
			gorgOn = 0
			return PLUGIN_HANDLED
		}

		//Check make sure server doesnt get chosen (for listenservers)
		while(choose == 0)
			choose = valid[random_num(1,x)]
		// Here we change their teams as soon as drawing has been chosen.
		if(pev(choose,pev_team) != 2 && is_user_connected(choose))
		{
			client_cmd(choose,"readyroom")
			client_cmd(choose,"readyroom")
			set_task(2.0,"changeToAlien",choose+600)
		}
		setup(choose)	// Run setup method
		return PLUGIN_HANDLED
	}
	zilla_raffle_time--
	set_task(1.0,"begin",2222)
	return PLUGIN_HANDLED
}

public setup(id)
{
	if(ns_is_combat() && !is_mvm()) { 
		cc = ns_get_build("team_command",1,1)	// Grab cc to kill if won by gorgzilla.
		hive = ns_get_build("team_hive",1,1)	// Grab hive to have fixed damage, with events.
		
		set_hudmessage(200, 100, 200, -1.0, 0.60, 0, 1.0, 600.0, 0.1, 0.1, HUD_CHANNEL)
		if(counter == 0) {						// Final counter phase (needed at top)
			set_task(0.1,"display",id,"",_,"b")	// This runs most of the display hudmessages, and a bit of events
			return PLUGIN_HANDLED
		}
		if(counter == 1 ) //default counter
		{
			get_user_name(id,aname,32)
			if(once == 1) {
				new num = random_num(1,4)
				
				switch(num)
				{
					case 1: format(catchphrase, 63, "and will rise to victory!")
					case 2: format(catchphrase, 63, "and will doom the humans of their fate!")
					case 3: format(catchphrase, 63, "and plans to win with easy.")
					case 4: format(catchphrase, 63, "and fills with hunger for blood.")
				}
			}
			once = 0
			show_hudmessage(0,"The Alien Hive is giving birth to GorgZilla!!^n %s begins mutating, %s",aname,catchphrase)
			set_pev(id,pev_takedamage,0.0)	 //Make hive, cc, and gorgzilla person invincible
			set_pev(hive,pev_takedamage,0.0) //For duration of mutation, and longer
			set_pev(cc,pev_takedamage,0.0)	 
			set_pev(cc,pev_rendermode,2)	//make cc invisible so gorgzilla doesn't want to attack it.
			set_pev(cc,pev_renderamt,0)		//make cc invisible so gorgzilla doesn't want to attack it.
			
			
			
			new concede = maxplayers + 5
			server_cmd("mp_limitteams %i",maxplayers)	// Changed our limitteams to have huge imbalanced team
			server_cmd("mp_autoconcede %i",concede)		// This is so round won't end with huge team.
	
			switch(pev(choose,pev_team))
			{
				case 2:
				{
					if(timer == 1) { // helps to add a delay 
						counter = 10 // helps to add a delay 
						runSetup(id,1.0)
						return PLUGIN_HANDLED
					}
					set_lights("re")	//Sets lights to be blinking (looks awesome with screenshake)
					ns_set_exp(choose,500000.0) //give our GorgZilla xp
					for (new i=1;i<=maxplayers;i++) {
						if(is_user_connected(i)) {
							client_cmd(i, "play %s", siren) // Half-life siren.wav
							ns_set_exp(i,500000.0)
						}
						if(is_user_connected(i) && is_user_alive(i)) {
							new gmsgShake = get_user_msgid("ScreenShake") 
							message_begin(MSG_ONE, gmsgShake, {0,0,0}, i)
							write_short(255<< 14) //ammount 
							write_short(10 << 14) //lasts this long 
							write_short(255<< 14) //frequency 
							message_end()
						}
					}
					runSetup(id,5.0) //delay of 5 seconds
					timer = 1
					return PLUGIN_HANDLED
				}	
				case 1: //make sure GorgZilla gets to team 2
				{
					client_cmd(id,"readyroom")
					client_cmd(id,"readyroom")
					set_task(2.0,"changeToAlien",id+600)
					runSetup(id,3.0)
				}
				case 0: //make sure GorgZilla gets to team 2
				{
					set_task(2.0,"changeToAlien",id+600)
					runSetup(id,3.0)
				}
			}
		}
		if(counter >= 10)
		{
			switch(ns_get_class(id))
			{
				case 1:
				{
					set_lights("b")				 // Dim lights for scary feeling
					client_cmd(id,"impulse 117") // Mutate GorgZilla to Onos
				}
				case 5:	
				{
					for(new i=1;i<=maxplayers;i++)	//Stop siren sound here
						client_cmd(i,"stopsound")	//Siren sound doesn't stop on its own =/
					timer = 0					// shield_down_delay timer
					once = 1					// shield_down_delay once
					counter = 0					// send counter to final phase
					spawnGorg(id)				// spawn our GorgZilla (from onos)
					set_lights("#OFF") 				// Set lights to normal
					set_pev(hive,pev_takedamage,1.0)	//Enable hive damage
		
				}
			}
			runSetup(id,1.0)	// Run again to hit final phase
		}
	}
	return PLUGIN_HANDLED
}
public runSetup(id, Float:num)	// custom set_task for setup method
	set_task(num,"setup",id)
	
public display() // Run every 0.1 seconds
{	
	new korigin[3]
	get_user_origin(choose, korigin)	//Save GorgZilla origin at all time (for final effect)
	
	// keep track of kills, hive HP, GorgZilla HP
	kills = get_user_frags(choose)
	// hivelife always 2000 above actual value, as precaution of death.
	hivelife = entity_get_float(hive, EV_FL_health) - precaution
	gorgHealth = entity_get_float(choose, EV_FL_health)

	//Run marines win event.
	if(!is_user_alive(choose) || !is_user_connected(choose) || pev(choose,pev_team) != 2 && shielddown != 4) 
		shielddown = 3
		
	// Run aliens win event
	if((get_cvar_num("zilla_kills")-kills) <= 0 && shielddown != 3)	
		shielddown = 4

	// Shield events
	if(hivelife >= (hive_hp-precaution) && hive_lives >= 0 && shielddown != 3 && shielddown != 4)	// Run shield up event.
		shielddown = 0
	else if(hivelife <= 0 && hive_lives > 1 && shielddown != 3 && shielddown != 4)		// Run shield down event.
		shielddown = 1
	else if(hivelife <= 0 && hive_lives <= 1 && shielddown != 3 && shielddown != 4)		// Run shield permanently down event.
		shielddown = 2
	
	switch(shielddown)	// Hudmessages of each event.
	{
		case 0:
		{
			glow(choose,0,250,0,1)
			set_lights("#OFF") 
			set_pev(hive,pev_takedamage,1.0)
			set_pev(choose,pev_takedamage,0.0)
			set_hudmessage(200, 100, 200, -1.10, 0.75, 0, 1.0, 400.0, 0.1, 0.1, HUD_CHANNEL)
			format(hudmsg, 255, "      Weaken Hive to remove GorgZilla's Defenses! ^n      Hive HP: %i  -  Hive Lives: %i^n      GorgZilla HP: %i  -  GorgZilla's Kills Left: %i^n      Max Helpers: %i",floatround(hivelife), hive_lives,floatround(gorgHealth), get_cvar_num("zilla_kills")-kills,get_cvar_num("zilla_helpers"))
		}
		case 1:
		{
			glow(choose,250,0,0,1)
			set_pev(hive,pev_takedamage,0.0)
			set_pev(choose,pev_takedamage,1.0)

			set_hudmessage(250, 0, 0, -1.10, 0.75, 0, 1.0, 400.0, 0.1, 0.1, HUD_CHANNEL)
			format(hudmsg, 255, "      Hive has been weakened! ^n      GorgZilla is now vulnerable for %i seconds!!! ^n      GorgZilla HP: %i  -  GorgZilla's Kills Left: %i^n      Max Helpers: %i",shield_down_delay, floatround(gorgHealth), get_cvar_num("zilla_kills")-kills,get_cvar_num("zilla_helpers"))	
		}
		case 2:
		{
			glow(choose,250,0,0,1)
			set_pev(hive,pev_takedamage,0.0)
			set_pev(choose,pev_takedamage,1.0)
			set_hudmessage(250, 0, 0, -1.10, 0.75, 0, 1.0, 400.0, 0.1, 0.1, HUD_CHANNEL)
			format(hudmsg, 255, "      Hive Permanently Weakened! Kill GorgZilla!! ^n      GorgZilla HP: %i  -  GorgZilla Kills Left: %i^n      Max Helpers: %i",floatround(gorgHealth), get_cvar_num("zilla_kills")-kills,get_cvar_num("zilla_helpers"))	
		}
		case 3:
		{
			flameWave(korigin, choose)
			set_task(1.0,"marineWin",3000,"",_,"a",12) 
			remove_task(choose+420)
			remove_task(choose)	
			ns_set_player_model(choose)
			set_pev(hive,pev_takedamage,1.0) 
			fakedamage(hive,"GorgZilla",99999.0,1)
			cleanup()
		}
		case 4:
		{
			for(new c=1;c<=maxplayers;c++)
				if(pev(c,pev_team) == 1) {
					get_user_origin(c, korigin)
					boom(korigin, c)
					fakedamage(c,aname,99999.0,1)
				}
			set_task(1.0,"alienWin",3000,"",_,"a",12)
			remove_task(choose+420)
			remove_task(choose)
			ns_set_player_model(choose)
			set_pev(cc,pev_takedamage,1.0) 	
			fakedamage(cc,"Marines",99999.0,1)
			cleanup()
		}
	}
	displayHudmsg()
	return PLUGIN_HANDLED
}

public displayHudmsg()
	show_hudmessage(0,"%s",hudmsg)

//Need this, to override any plugins using set_hudmessage or show hudmsg
public marineWin() {
	set_hudmessage(20, 20, 250, -1.0, 0.60, 1, 1.0, 14.0, 0.1, 0.1, HUD_CHANNEL)
	format(hudmsg, 255, "GorgZilla has been slayed! Congratulations Marines! ^nCompleted Time = %i seconds", timer)
	displayHudmsg()
}
//Need this, to override any plugins using set_hudmessage or show hudmsg
public alienWin() {
	set_hudmessage(250, 20, 20, -1.0, 0.60, 1, 1.0, 14.0, 0.1, 0.1, HUD_CHANNEL)
	format(hudmsg, 255, "Marines have been eaten! Congratulations GorgZilla! ^nCompleted Time = %i seconds",timer)
	displayHudmsg()		
}

public roundtime() // Runs every second
{
	///////////////////////////////////////////////////////
	//          Alien Helper Code --BEGINS HERE--    	 //
	///////////////////////////////////////////////////////
	if(max_helpers > 0) {
		for(new s=1;s<=maxplayers;s++) {
			if(!is_user_connected(s)) continue
			
			new currentHelpers = 0
			for(new aa=1;aa<=maxplayers;aa++) 
				if(ahelpers[aa] == 1) 
					++currentHelpers
			
			if(ns_get_mask(s,MASK_DIGESTING) && (currentHelpers <= max_helpers) && ahelpers[s] == 0) {
					ahelpers[s] = 1
					teamswitch[s] = 1
					client_print(s,print_chat,"[GorgZilla] You will become a GorgZilla helper when you die.")
			}
			if(ahelpers[s] == 1) {
				if(!is_user_alive(s))
				{
					if(pev(s,pev_team) == 1 && teamswitch[s] == 1) {
						client_cmd(s,"readyroom")
						client_cmd(s,"readyroom")
						set_task(2.0,"changeToAlien",s+600)
					}
					if(pev(s,pev_team) == 2 && teamswitch[s] == 2) {
						ns_set_player_model(s)
						client_cmd(s,"readyroom")
						client_cmd(s,"readyroom")
						set_task(2.0,"changeToMarine",s+600)
						ahelpers[s] = 0
						teamswitch[s] = 0
					}
				}
				if(is_user_alive(s) && pev(s,pev_team) == 2 && teamswitch[s] == 1)
				{
					switch(ns_get_class(s)) {
						case 1: {
							ns_set_exp(s,500000.0)
							entity_set_float(s, EV_FL_health, float(4000))	//set health, if not they die to easy
							client_cmd(s,"impulse 117")
						}
						case 5: {
							entity_set_float(s, EV_FL_health, float(4000))	//set health, if not they die to easy
							teamswitch[s] = 2
							spawnHelper(s)
							client_print(s,print_chat,"[GorgZilla] You will help GorgZilla until you die.")
						}
						case 10: entity_set_float(s, EV_FL_health, float(3000)) //resets every second (used for blood)
					}
				}
			}
		}
	}
	///////////////////////////////////////////////////////
	//          Alien Helper Code --ENDS HERE--          //
	///////////////////////////////////////////////////////
	
	timer = timer + 1	
	
	// Run team switch check every second
	// (incase someone decides they don't want to be marine =P )
	for (new i=1;i<=maxplayers;i++) {
		if(is_user_connected(i) && is_user_alive(i)) {
			ns_set_exp(i,500000.0)
			if(i != (choose) && pev(i,pev_team) != 1 && ahelpers[i] == 0) {
				switch(pev(i,pev_team))
				{
					case 2: 
					{
						client_cmd(i,"readyroom")
						client_cmd(i,"readyroom")
						set_task(2.0,"changeToMarine",i+600)
					}	
					case 0: 
						set_task(2.0,"changeToMarine",i+600)
				}
				
			}
		}
	}
	if(is_user_alive(choose))
	{
		switch(shielddown)
		{
			case 1: //Shield down but will be back up
			{
				if(shield_down_delay >= get_cvar_num("zilla_shielddelay")) {
					set_lights("f")
					for (new i=1;i<=maxplayers;i++) {
						if(is_user_connected(i)) {
							client_cmd(i, "play %s", distress)
							new gmsgShake = get_user_msgid("ScreenShake") 
							message_begin(MSG_ONE, gmsgShake, {0,0,0}, i)
							write_short(255<< 14 ) //ammount
							write_short(10 << 14) //lasts this long
							write_short(255<< 14) //frequency
							message_end()
						}
	    			}
				}
				shield_down_delay = shield_down_delay -1
				if(shield_down_delay == 0) {
					set_lights("#OFF") 
					if(hive_lives > 0)
						entity_set_float(hive, EV_FL_health, float(hive_hp))
					hive_lives = hive_lives - 1 
					shield_down_delay = get_cvar_num("zilla_shielddelay")
				}
			}
			case 2:	//Shield down permanently
			{
				if ((get_gametime() - lasttime) > 5 && (get_gametime() - lasttime) < 8) {
					set_lights("#OFF") 
				}
				for (new i=1;i<=maxplayers;i++) {
					if(is_user_connected(i) && once == 1) {
						client_cmd(i, "play %s", distress)
						set_lights("f")
						lasttime = get_gametime()
						if(is_user_connected(i) && is_user_alive(i)) {
							new gmsgShake = get_user_msgid("ScreenShake") 
							message_begin(MSG_ONE, gmsgShake, {0,0,0}, i)
							write_short(255<< 14 ) //ammount
							write_short(10 << 14) //lasts this long
							write_short(255<< 14) //frequency
							message_end()
						}
						once = 0
					}
	    		}
			}
		}		
	}
	return PLUGIN_HANDLED
}

public cleanup()
{
	set_lights("#OFF") 
	gorgOn = 0
	set_pev(hive,pev_takedamage,1.0)
	set_pev(cc,pev_takedamage,1.0)
	set_pev(cc,pev_rendermode,0)
	shielddown = 0
	counter = 1
	once = 1
	choose = 0
	kills = 0
	format(aname, 32, "")
	for(new i=0;i<=maxplayers;i++) {
		ns_set_player_model(i)
		chance[i] = 0
		valid[i] = 0
		ahelpers[i] = 0
		teamswitch[i] = 0
	}
	set_cvar_num("zilla_GorgZilla",0)
	set_cvar_num("mp_limitteams",oldlimit)
	set_cvar_num("mp_autoconcede",oldconcede)
}
public spawnHelper(id)
{
	if ( pev(id,pev_team) == 2 )
	{
		glow(id,255,170,0,1)
		set_pev(id,pev_iuser3,5)
		ns_set_mask(id,MASK_SIGHTED,1)
		ns_set_mask(id,MASK_DETECTED,1)
		ns_set_mask(id,MASK_CARAPACE,1)
		ns_set_mask(id,MASK_REGENERATION,1)
		ns_set_mask(id,MASK_ADRENALINE,1)
		ns_set_mask(id,MASK_FOCUS,1)
		ns_set_mask(id,MASK_SCENTOFFEAR,1)
		ns_set_mask(id,MASK_DEFENSE3,1)
		ns_set_mask(id,MASK_MOVEMENT3,1)
		ns_set_mask(id,MASK_SENSORY3,1)
		ns_set_mask(id,MASK_PRIMALSCREAM,1)

		set_pev(id,pev_fuser2,1000.0)
		set_pev(id,pev_fuser3,1000.0)	
		ns_set_player_model(id,smallGorgZilla)
		
		entity_set_float(id, EV_FL_armorvalue, float(700))
		entity_set_float(id, EV_FL_health, float(get_cvar_num("zilla_helperhp")))
		
		new Float:origin[3]
		entity_get_vector(id, EV_VEC_origin, origin)
		origin[2] = origin[2] + 14
		
		entity_set_origin(id, origin)
	}
}
public spawnGorg(id)
{
	if ( pev(id,pev_team) == 2 )
	{
		client_print(id,print_chat,"[GorgZilla] Eat Marines, to create an alien helper!")
		client_print(id,print_chat,"[GorgZilla] Eat Marines, to create an alien helper!")
		set_pev(id,pev_iuser3,5)
		ns_set_mask(id,MASK_SIGHTED,1)
		ns_set_mask(id,MASK_DETECTED,1)
		ns_set_mask(id,MASK_CARAPACE,1)
		ns_set_mask(id,MASK_REGENERATION,1)
		ns_set_mask(id,MASK_ADRENALINE,1)
		ns_set_mask(id,MASK_FOCUS,1)
		ns_set_mask(id,MASK_SCENTOFFEAR,1)
		ns_set_mask(id,MASK_DEFENSE3,1)
		ns_set_mask(id,MASK_MOVEMENT3,1)
		ns_set_mask(id,MASK_SENSORY3,1)
		//set_mask(id,MASK_ALIEN_MOVEMENT,1)
		ns_set_mask(id,MASK_PRIMALSCREAM,1)

		
		set_pev(id,pev_fuser2,1000.0)
		set_pev(id,pev_fuser3,1000.0)	//energy
		ns_set_player_model(id,gorgzilla)
		
		//entity_set_size(id,Float:{-500.0,-500.0,0.0},Float:{500.0,500.0,500.0})
		entity_set_float(id, EV_FL_armorvalue, float(gorgzilla_hp))
		entity_set_float(id, EV_FL_health, float(gorgzilla_hp))
		
		new Float:origin[3]
		entity_get_vector(id, EV_VEC_origin, origin)
		origin[2] = origin[2] + 14
		
		entity_set_origin(id, origin)
		entity_set_float(hive, EV_FL_health, float(hive_hp))
		set_task(1.0,"roundtime",id+420,"",_,"b")
	}
}
public boom(myorig[3], id) {
  	/*//Explosion2 
    message_begin( MSG_BROADCAST,SVC_TEMPENTITY) 
    write_byte( 12 ) 
    write_coord(myorig[0]) 
    write_coord(myorig[1]) 
    write_coord(myorig[2])
    write_byte( 50 ) // byte (scale in 0.1's) 188 
    write_byte( 10 ) // byte (framerate) 
    message_end() */

    //TE_Explosion 
    message_begin( MSG_BROADCAST,SVC_TEMPENTITY,myorig) 
    write_byte( 3 ) 
    write_coord(myorig[0]) 
    write_coord(myorig[1]) 
    write_coord(myorig[2])
    write_short( fire ) 
    write_byte( 70 ) // byte (scale in 0.1's) 188 
    write_byte( 10 ) // byte (framerate) 
    write_byte( 0 ) // byte flags 
    message_end() 

     //Smoke 
    message_begin( MSG_BROADCAST,SVC_TEMPENTITY,myorig) 
    write_byte( 5 ) // 5
    write_coord(myorig[0]) 
    write_coord(myorig[1]) 
    write_coord(myorig[2]) 
    write_short( smoke )
    write_byte( 50 )  // 2
    write_byte( 10 )  // 10
    message_end()
    
    //TE_KILLPLAYERATTACHMENTS
    message_begin(MSG_BROADCAST,SVC_TEMPENTITY,{0,0,0},id)
    write_byte( 125 ) // will expire all TENTS attached to a player.
    write_byte( id ) // byte (entity index of player)
    message_end()	
    return PLUGIN_HANDLED
}

public flameWave(myorig[3], id) {
    message_begin(MSG_ALL,SVC_TEMPENTITY,myorig) 
    write_byte( 21 ) 
    write_coord(myorig[0]) 
    write_coord(myorig[1]) 
    write_coord(myorig[2] + 16) 
    write_coord(myorig[0]) 
    write_coord(myorig[1]) 
    write_coord(myorig[2] + 500) 
    write_short( fire )
    write_byte( 0 ) // startframe 
    write_byte( 0 ) // framerate 
    write_byte( 15 ) // life 2
    write_byte( 50 ) // width 16 
    write_byte( 10 ) // noise 
    write_byte( 255 ) // r 
    write_byte( 0 ) // g 
    write_byte( 0 ) // b 
    write_byte( 255 ) //brightness 
    write_byte( 1 / 10 ) // speed 
    message_end() 
    
    message_begin(MSG_ALL,SVC_TEMPENTITY,myorig) 
    write_byte( 21 ) 
    write_coord(myorig[0]) 
    write_coord(myorig[1]) 
    write_coord(myorig[2] + 16) 
    write_coord(myorig[0]) 
    write_coord(myorig[1]) 
    write_coord(myorig[2] + 500) 
    write_short( fire )
    write_byte( 0 ) // startframe 
    write_byte( 0 ) // framerate 
    write_byte( 10 ) // life 2
    write_byte( 70 ) // width 16 
    write_byte( 10 ) // noise 
    write_byte( 255 ) // r 
    write_byte( 50 ) // g 
    write_byte( 0 ) // b 
    write_byte( 200 ) //brightness 
    write_byte( 1 / 9 ) // speed 
    message_end() 
    
    message_begin(MSG_ALL,SVC_TEMPENTITY,myorig)
    write_byte( 21 )
    write_coord(myorig[0])
    write_coord(myorig[1])
    write_coord(myorig[2] + 16) 
    write_coord(myorig[0]) 
    write_coord(myorig[1]) 
    write_coord(myorig[2] + 500) 
    write_short( fire )
    write_byte( 0 ) // startframe 
    write_byte( 0 ) // framerate 
    write_byte( 10 ) // life 2
    write_byte( 90 ) // width 16 
    write_byte( 10 ) // noise 
    write_byte( 255 ) // r 
    write_byte( 100 ) // g 
    write_byte( 0 ) // b 
    write_byte( 200 ) //brightness 
    write_byte( 1 / 8 ) // speed 
    message_end() 
    
    //Explosion2 
    message_begin( MSG_BROADCAST,SVC_TEMPENTITY) 
    write_byte( 12 ) 
    write_coord(myorig[0]) 
    write_coord(myorig[1]) 
    write_coord(myorig[2])
    write_byte( 80 ) // byte (scale in 0.1's) 188 
    write_byte( 10 ) // byte (framerate) 
    message_end() 

    //TE_Explosion 
    message_begin( MSG_BROADCAST,SVC_TEMPENTITY,myorig) 
    write_byte( 3 ) 
    write_coord(myorig[0]) 
    write_coord(myorig[1]) 
    write_coord(myorig[2])
    write_short( fire ) 
    write_byte( 65 ) // byte (scale in 0.1's) 188 
    write_byte( 10 ) // byte (framerate) 
    write_byte( 0 ) // byte flags 
    message_end() 

    //TE_KILLPLAYERATTACHMENTS
    message_begin(MSG_BROADCAST,SVC_TEMPENTITY,{0,0,0},id)
    write_byte( 125 ) // will expire all TENTS attached to a player.
    write_byte( id ) // byte (entity index of player)
    message_end()

    //Smoke 
    message_begin( MSG_BROADCAST,SVC_TEMPENTITY,myorig) 
    write_byte( 5 ) // 5
    write_coord(myorig[0]) 
    write_coord(myorig[1]) 
    write_coord(myorig[2]) 
    write_short( smoke )
    write_byte( 50 )  // 2
    write_byte( 10 )  // 10
    message_end()
    
    return PLUGIN_HANDLED
}

//CheesyPeteza's impulse handler (best in the biz)
public upgradeblock(id)	//Message for blocked impulses.
{
	if (gorgOn == 0)
		return PLUGIN_CONTINUE
	if ((get_gametime() - g_lastmessage[id]) > MESSAGE_DELAY) {
		ns_popup(id, "DO NOT UPGRADE THAT.")
		g_lastmessage[id] = get_gametime()
	}
	set_pev(id, pev_impulse, 0)
	return PLUGIN_HANDLED
}

public is_mvm() {
	new checkcc = ns_get_build("team_command",0, 0)
	if(checkcc > 1)
		return 1
	return 0
}
public glow(id, r, g, b, on)
{
	if(on == 1) {
		set_rendering(id, kRenderFxGlowShell, r, g, b, kRenderNormal, 255)
		set_pev(id,pev_renderamt,2.0)
	}
	else
	{
		set_rendering(id, kRenderFxNone, r, g, b,  kRenderNormal, 255)
		set_pev(id,pev_renderamt,2.0)
	}
}
public changeToAlien(id)
	client_cmd(id-600,"jointeamtwo")

public changeToMarine(id)
	client_cmd(id-600,"jointeamone")