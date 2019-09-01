/************************************************
	More Mines and Nades for Combat
	Author: Rabid Baboon
	Version: 3.1
	Mod: Natural Selection
	Requires: AMX mod X v1.7a
	Modules: NS and Engine
	Description:
		Allows a marine to have as many mines and nades as the server allows

	Commandes:
		sv_maxmines(Default: 4) - change the max number of mines a player can have
		sv_maxnades(Default: 4) - change the max number of nades a player can have
		
	Changelog:
		v3.1
			*FIXED* A small bug related to getting mines or nades but dieing
			before the check completed
		v3.0
			*FIXED* Not spawing with proper number of mines or nades
			Added more nades
			New server command - sv_maxnades
		v2.0
			Nearly a complete rewrite.			
		v1.2
			*FIXED* Five mines when you first get mines bug.
		v1.1
			Reset mine info on team change
			
	Specail Thanks:
		Sandstorm - doing by events idea
		IHQ-Reima - found bug related to getting mines or nades but dieing
			    before the check completed
************************************************/
#include <amxmodx>
#include <ns>
#include <engine>

// constants
#define MAX_MINES "4" //change this to change the default max number of mines
#define MAX_NADES "4" //change this to change the default max number of nades

/***	Don't change anything below here. Unless you know what you are doing. :) ***/

#define MINES 0
#define NADES 1
new const WEAPON_NAMES[2][] = {"weapon_mine", "weapon_grenade"};

//globals
new bool:g_PlayerHasMinesNades[33][2];

//cvar pointers
new g_MaxMines;
new g_MaxNades;
/***********************************************/
public plugin_init()
{
	if(ns_is_combat())
	{
		register_plugin("More Mines and Nades", "v3.1", "Rabid Baboon");
		register_impulse(61, "GotMines"); //mines
		register_impulse(37, "GotNades"); //nades
		
		//server command
		g_MaxMines = register_cvar("sv_maxmines", MAX_MINES, FCVAR_SERVER);
		g_MaxNades = register_cvar("sv_maxnades", MAX_NADES, FCVAR_SERVER);
	}
	else
	{
		register_plugin("More Mines and Nades Disabled", "v3.1", "Rabid Baboon");
	}
}
/************************************************
	client_changeteam(index, newteam, oldteam)
		Resets players data on team change
************************************************/
public client_changeteam(playerID, newteam, oldteam)
{
	g_PlayerHasMinesNades[playerID][MINES] = false;
	g_PlayerHasMinesNades[playerID][NADES] = false;
}
/************************************************
	client_spawn(playerID)
		Sets the players clip size on spawn
************************************************/
public	client_spawn(playerID)
{
	GotMines(playerID);
	GotNades(playerID);
	SetClip(playerID);	
}
/************************************************
	GotMines(playerID)
		See if the player really did get mines
************************************************/
public GotMines(playerID)
{
	if(g_PlayerHasMinesNades[playerID][MINES] == false)
	{	
		new params[2];
		params[0] = playerID;
		params[1] = MINES;
		
		set_task(0.5, "CheckWeapons", 0, params, 2);
	}
}
/************************************************
	GotMines(playerID)
		See if the player really did get nades
************************************************/
public GotNades(playerID)
{
	if(g_PlayerHasMinesNades[playerID][NADES] == false)
	{
		new params[2];
		params[0] = playerID;
		params[1] = NADES;
		
		set_task(0.5, "CheckWeapons", 0, params, 2);
	}
}
/************************************************
	CheckWeapons(params[], id)
		Sets the players mine or nade status
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
				g_PlayerHasMinesNades[playerID][weapon] = true;
				SetClip(playerID);
			}
		}
		case NADES:
		{
			if(ns_has_weapon(playerID, WEAPON_GRENADE))
			{
				g_PlayerHasMinesNades[playerID][weapon] = true;
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
	if(g_PlayerHasMinesNades[playerID][MINES])
	{
		weaponID = GetWeaponID(playerID, WEAPON_NAMES[MINES]);
		if(weaponID != 0)
		{
			ns_set_weap_clip(weaponID, get_pcvar_num(g_MaxMines));
		}
	}
	
	if(g_PlayerHasMinesNades[playerID][NADES])
	{
		weaponID = GetWeaponID(playerID, WEAPON_NAMES[NADES]);
		if(weaponID != 0)
		{
			ns_set_weap_clip(weaponID, get_pcvar_num(g_MaxNades));
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
