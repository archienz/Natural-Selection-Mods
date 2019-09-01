/************************************************
	Weapon Switching for Combat
	Author: Rabid Baboon
	Version: 2.0
	Mod: Natural Selection
	Requires: AMX mod X v1.71
	Modules: NS and Engine
	Description:
		Allows a marine to switch between primary weapons in combat once
		they have bought the weapon by reselecting it in the upgrade menu.
		
		Three modes:
		Mode 0:
			Weapon swithing is off.
		Mode 1: default
			Weapon switch takes place at respawn.
		Mode 2: 
			Weapon switch takes place instantly.
				
	Commands:
		sv_wsmode <0/1/2> (Default:1)
			0 - Weapon switching is off
			1 - Normal mode, weapon switching takes place at spawn
			2 - Insta mode, weapon is given right away, with ammo saved to prevent an exploit
			
	Changelog:
		v2.0
			Three modes added. See above for details
			Added more code comments and cleaned it up some.
************************************************/
#include <amxmodx>
#include <ns>
#include <engine>

#define WSMODE "1" //Change this to change the default switching mode

/***	Don't change anything below here. Unless you know what you are doing. :) ***/

// constants
#define SG 0
#define HMG 1
#define GL  2
new const WEAPON_NAMES[3][] = {"weapon_shotgun", "weapon_heavymachinegun", "weapon_grenadegun"};
new const WEAPON_TEXT[3][] = {"SG", "HMG", "GL"};

// global vars
new g_CurrentWeapon[33]; //players current weapon
new bool:g_HasWeapon[33][3]; //players weapon list
new g_ClipAmount[33][3]; //players amount of ammo in their clip
new g_ReserveAmount[33][3]; //players amount of ammo in reserve

//cvar pointers
new g_WSMode;
/***********************************************/
public plugin_init()
{
	if(ns_is_combat())
	{
		register_plugin("Weapon Switching", "v2.0", "Rabid Baboon");
		register_impulse(64, "Shotgun");
		register_impulse(65, "HeavyMachinegun");
		register_impulse(66, "GrenadeLauncher");
		
		//server command
		g_WSMode = register_cvar("sv_wsmode", WSMODE, FCVAR_SERVER);
	}
	else
	{
		register_plugin("Weapon Switching Disabled", "v2.0", "Rabid Baboon");
	}
		
	return PLUGIN_HANDLED
}
/************************************************
	client_spawn(playerID)
		On player spawn give player his current weapon
************************************************/
public client_spawn(playerID)
{
	if(get_pcvar_num(g_WSMode) == 0)
	{
		return;
	}
	
	//shotgun
	g_ClipAmount[playerID][SG] = 8;
	g_ReserveAmount[playerID][SG] = 16;
	//hmg	
	g_ClipAmount[playerID][HMG] = 125;
	g_ReserveAmount[playerID][HMG] = 250;
	//gl	
	g_ClipAmount[playerID][GL] = 4;
	g_ReserveAmount[playerID][GL] = 8;
	
	switch(g_CurrentWeapon[playerID])
	{
		case SG:
			ns_give_item(playerID, WEAPON_NAMES[SG]);
		case HMG:
			ns_give_item(playerID, WEAPON_NAMES[HMG]);
		case GL:
			ns_give_item(playerID, WEAPON_NAMES[GL]);
	}	
}
/************************************************
	client_changeteam(id, newteam, oldteam)
		Whwen a player changes team reset all their weapon data
************************************************/
public client_changeteam(playerID, newteam, oldteam)
{
	//shotgun
	g_HasWeapon[playerID][SG] = false;
	//g_ClipAmount[id][SG] = 8;
	//g_ReserveAmount[id][SG] = 16;
	//hmg	
	g_HasWeapon[playerID][HMG] = false;
	//g_ClipAmount[id][HMG] = 125;
	//g_ReserveAmount[id][HMG] = 250;
	//gl
	g_HasWeapon[playerID][GL] = false;
	//g_ClipAmount[id][GL] = 4;
	//g_ReserveAmount[id][GL] = 8;
	//current weapon
	g_CurrentWeapon[playerID] = -1;
}
/************************************************
	Shotgun(playerID)
		Catches the sg upgrade impulse
************************************************/
public Shotgun(playerID)
{	
	WeaponGive(playerID, SG);		
}
/************************************************
	HeavyMachinegun(playerID)
		Catches the hmg upgrade impulse
************************************************/
public HeavyMachinegun(playerID)
{
	WeaponGive(playerID, HMG);
}
/************************************************
	GrenadeLauncher(playerID)
		Catches the gl upgrade impulse
************************************************/
public GrenadeLauncher(playerID)
{
	WeaponGive(playerID, GL);
}
/************************************************
	WeaponGive(playerID, weapon)
		Takes care of weapon giving
************************************************/
public WeaponGive(playerID, weapon)
{
	if(g_HasWeapon[playerID][weapon] == false)
	{
		new params[2];
		params[0] = playerID;
		params[1] = weapon;
		set_task(0.5, "CheckWeapons", 0, params, 2);
	}
	else
	{
		switch(get_pcvar_num(g_WSMode))
		{
			case 1:
			{
				g_CurrentWeapon[playerID] = weapon;
				client_print(playerID, print_chat, "You will spawn with a %s", WEAPON_TEXT[weapon]);			
			}
			case 2:
			{
				SaveCurrentWeaponAmmo(playerID);
				ns_give_item(playerID, WEAPON_NAMES[weapon]);
				g_CurrentWeapon[playerID] = weapon;
				SetNewWeaponAmmoCount(playerID);
			}			
		}
	}
}
/************************************************
	CheckWeapons(params[], id)
		Checks to make sure the player got the weapon
************************************************/
public CheckWeapons(params[], id)
{
	new playerID = params[0];
	new weapon = params[1];
	
	switch(weapon)
	{
		case SG:
		{	
			if(ns_has_weapon(playerID, WEAPON_SHOTGUN))
			{
				g_HasWeapon[playerID][SG] = true;
				g_CurrentWeapon[playerID] = SG;
			}
		}
		case HMG:
		{
			if(ns_has_weapon(playerID, WEAPON_HMG))
			{
				g_HasWeapon[playerID][HMG] = true;
				g_CurrentWeapon[playerID] = HMG;
			}
		}
		case GL:
		{
			if(ns_has_weapon(playerID, WEAPON_GRENADE_GUN))
			{
				g_HasWeapon[playerID][GL] = true;
				g_CurrentWeapon[playerID] = GL;
			}
		}
	}
}
/************************************************
	SaveCurrentWeaponAmmo(playerID)
		Saves the players current weapon clip and reserve ammo amount
************************************************/
public SaveCurrentWeaponAmmo(playerID)
{
	new weaponID;
	switch(g_CurrentWeapon[playerID])
	{
		case SG:
		{
			weaponID = GetWeaponID(playerID, WEAPON_NAMES[SG])
			if(weaponID != 0)
			{
				g_ClipAmount[playerID][SG] = ns_get_weap_clip(weaponID);
				g_ReserveAmount[playerID][SG] = ns_get_weap_reserve(playerID, WEAPON_SHOTGUN);
			}
		}
		case HMG:
		{
			weaponID = GetWeaponID(playerID, WEAPON_NAMES[HMG])
			if(weaponID != 0)
			{
				g_ClipAmount[playerID][HMG] = ns_get_weap_clip(weaponID);
				g_ReserveAmount[playerID][HMG] = ns_get_weap_reserve(playerID, WEAPON_HMG);
			}
		}
		case GL:
		{
			weaponID = GetWeaponID(playerID, WEAPON_NAMES[GL])
			if(weaponID != 0)
			{
				g_ClipAmount[playerID][GL] = ns_get_weap_clip(weaponID);
				g_ReserveAmount[playerID][GL] = ns_get_weap_reserve(playerID, WEAPON_GRENADE_GUN);
			}
		}
	}
}
/************************************************
	SetNewWeaponAmmoCount(playerID)
		Sets the players new current weapon clip and reserve ammo amount
************************************************/
public SetNewWeaponAmmoCount(playerID)
{
	new weaponID;
	switch(g_CurrentWeapon[playerID])
	{
		case SG:
		{
			weaponID = GetWeaponID(playerID, WEAPON_NAMES[SG])
			if(weaponID != 0)
			{
				ns_set_weap_clip(weaponID, g_ClipAmount[playerID][SG]);				
				ns_set_weap_reserve(playerID, WEAPON_SHOTGUN, g_ReserveAmount[playerID][SG]);
			}
		}
		case HMG:
		{
			weaponID = GetWeaponID(playerID, WEAPON_NAMES[HMG])
			if(weaponID != 0)
			{
				ns_set_weap_clip(weaponID, g_ClipAmount[playerID][HMG]);				
				ns_set_weap_reserve(playerID, WEAPON_HMG, g_ReserveAmount[playerID][HMG]);
			}
		}
		case GL:
		{
			weaponID = GetWeaponID(playerID, WEAPON_NAMES[GL])
			if(weaponID != 0)
			{
				ns_set_weap_clip(weaponID, g_ClipAmount[playerID][GL]);				
				ns_set_weap_reserve(playerID, WEAPON_GRENADE_GUN, g_ReserveAmount[playerID][GL]);				
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
