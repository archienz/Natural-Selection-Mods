/************************************************
Mines for levels
Author: semaja2.net (http://semaja2.net)
Version: 1.2
Mod: Natural Selection
Requires: AMX mod X v1.76a
Modules: NS and Engine
Description:
Allows a marine to have as many mines as their level permits, 
possible to change how many mines per level with the division define.

Cvars:
mine_minesbylvl		(Default: 1) - disable or enable the plugin in game
mine_minmines 		(Default: 1) - Minimum mines someone can have
mine_maxmines 		(Default: 5) - Maximum mines someone can have
mine_lvldivision 	(Default: 2) - How much levels are divided to work out how many mines to give

Commands:
mine_setclip semaja2.net 999 ; Sets client "Semaja2.net" mine clip to have 999 mines

Changelog:
v1.0
Inital Release
v1.1
Changed lvl_division into a cvar
Added max mines cvar
Added min mines cvar
v1.2
Changed lvl_division to float
Added command mine_setclip
Added variables in helper

Specail Thanks:
Rabid Baboon - for the orginal code
White Panther - for his help during my noobish moments
************************************************/
/***	Don't change anything below here. Unless you know what you are doing. :) ***/
#define TITLE "Mines for levels"
#define VERSION "1.2"
#define AUTHOR "semaja2"

/*
INT (1)
0 - Do use default helper output
1 - Use the "Helper" plugin! (recommended)
*/
#define HELPER 1

#include <amxmodx>
#include <amxmisc>
#include <ns>
#include <engine>

#if HELPER == 1                                                                 // make sure we only include the helper if we actually want to use it! server ops may not have this file and therefor do not wish to include it, although it doesn't harm if the Helper is disabled
#include <helper>
#else
#define help_add set_localinfo                                                // hax hax, this will allow us to use help_add although we did not include the helper
#endif                                                                          // it will replace all help_adds with set_localinfos. this doesn't do any harm as the forwards aren't called anyway
// this way is recommended as it requires the least work


/***	Don't change anything below here. Unless you know what you are doing. :) ***/
#define MINES 0
#define WEAPON_NAME_MINE "weapon_mine"


//globals
new bool:g_PlayerHasMines[33][2];
/***********************************************/
public plugin_init()
{
	register_plugin(TITLE, VERSION, AUTHOR);
	if(ns_is_combat())
	{
		
		//Catches the impulse for mines
		register_impulse(61, "GotMines"); //mines
		register_concmd("mine_setclip","force_clip",ADMIN_LEVEL_B,"<authid, nick, @all, @team, or #userid> <clip size>") 
		
		//Controls if the plugin should even work
		register_cvar("mine_minesbylvl", "1")
		//Maximum mines someone can have
		register_cvar("mine_maxmines", "5")
		//Minimum mines someone can have
		register_cvar("mine_minmines", "1")
		//Level Division
		register_cvar("mine_lvldivision", "2")
	}
	else
	{
		//Pauses the plugin when not needed
		pause("ad")
	}
}
/************************************************
client_changeteam(index, newteam, oldteam)
Resets players data on team change
************************************************/
public client_changeteam(playerID, newteam, oldteam)
{
	g_PlayerHasMines[playerID][MINES] = false;
}
/************************************************
client_spawn(playerID)
Sets the players clip size on spawn
************************************************/
public	client_spawn(playerID)
{
	GotMines(playerID);
	SetClip(playerID);	
}
/************************************************
GotMines(playerID)
See if the player really did get mines
************************************************/
public GotMines(playerID)
{
	if(g_PlayerHasMines[playerID][MINES] == false)
	{	
		new params[2];
		params[0] = playerID;
		params[1] = MINES;
		
		set_task(0.5, "CheckWeapons", 0, params, 2);
	}
}
/************************************************
CheckWeapons(params[], id)
Sets the players mine status
************************************************/
public CheckWeapons(params[], id)
{
	new playerID = params[0];
	new weapon = params[1];
	
	switch(weapon)
	{
		case MINES:
		{
			if(ns_has_weapon(playerID, WEAPON_MINE))
			{
				g_PlayerHasMines[playerID][weapon] = true;
				SetClip(playerID);
			}
		}
	}
}
/************************************************
SetClip(playerID)
Sets the players clip size
************************************************/
public SetClip(playerID)
{
	new weaponID;
	new Float:LVL_DIVISION;
	if(g_PlayerHasMines[playerID][MINES])
	{
		if ( get_cvar_num( "mine_minesbylvl" ) == 1 ) {
			weaponID = GetWeaponID(playerID, WEAPON_NAME_MINE);
			if(weaponID != 0)
			{
				LVL_DIVISION = get_cvar_float("mine_lvldivision")
				//server_print("lvldivis %f / lvl %i / mines to add %f",  LVL_DIVISION ,  get_level_by_exp(playerID) ,   (get_level_by_exp(playerID) / LVL_DIVISION ))
				if ((get_level_by_exp(playerID) / LVL_DIVISION ) >= get_cvar_num( "mine_maxmines" ))
					ns_set_weap_clip(weaponID, get_cvar_num( "mine_maxmines" ))
				else if ((get_level_by_exp(playerID) / LVL_DIVISION ) <= get_cvar_num( "mine_minmines" ))
					ns_set_weap_clip(weaponID, get_cvar_num( "mine_minmines" ))
				else
					ns_set_weap_clip(weaponID, floatround(get_level_by_exp(playerID) / LVL_DIVISION ))
			}
		}
	}
}
/************************************************
GetWeaponID(playerID, weaponName[])
Gets the weapon id for a players specific weapon
************************************************/
stock GetWeaponID(playerID, weaponName[])
{
	new weaponID = find_ent_by_owner(-1, weaponName, playerID);
	return weaponID;
}
/************************************************
get_level_by_exp(id)
Gets the players level by working from XP
************************************************/
stock Float:get_level_by_exp(id)
{
	return  floatsqroot(ns_get_exp(id) / 25 + 2.21) - 1
}

/************************************************
force_Clip(id,level,cid)
Sets the players clip size
************************************************/
public force_clip(id,level,cid) {
	if ( !cmd_access(id,level,cid,3) ) 
		return PLUGIN_HANDLED 
	new arg1[32],arg2[8]
	read_argv(1,arg1,31) 
	read_argv(2,arg2,7) 
	new clipsize = str_to_num(arg2) 
	new playerID = cmd_target(id,arg1,6) 
	if (!playerID) 
		return PLUGIN_HANDLED
	if(g_PlayerHasMines[playerID][MINES])
	{
		new weaponID = GetWeaponID(playerID, WEAPON_NAME_MINE);
		if(weaponID != 0)
		{
			ns_set_weap_clip(weaponID, clipsize)
		}
	}
	return PLUGIN_HANDLED
}

#if HELPER == 1
/************************************************
client_help( id )
Public Help System
************************************************/
public client_help( id )
{
	new info [200]
	formatex( info, 199, "Player recieves mines depending on how many levels they have ^nCurrent level divsion: %f ^nMinimum mines: %i ^nMaximum mines: %i", get_cvar_float("mine_lvldivision"), get_cvar_num("mine_minmines"), get_cvar_num( "mine_maxmines") );
	help_add("Information", info)
}

public client_advertise(id)	return PLUGIN_CONTINUE
#endif
