/* Amx Mod X script.
*
* Author: Sandstorm
*	  White Panther ( continuing support )
* This file is provided as is (no warranties). 
*
* This plugin gives lerk players the hidden spike attack.
*
* Cvars:
* lerkspike_enabled "1"	- Enables or Disables plugin
* lerkspike_default "5"	- Default weapon slot, 0 will default to off
* lerkspike_classic "1"	- Enables in classic mode
* lerkspike_combat "1"	- Enables in combat mode
*
* Userinfo:
* spike "5"		- User preference for weapon slot, 0 is off	
*
* Modules (AMX Mod X): 
* Engine, NS
*
* v1.1:
*	- Used CORRECT include file
* v1.2:
*	- Spike now appears in Slot1, like in 2.x
* v1.3:
*	- Using msgedit instead
* v1.4:
*	- Switched to AMX Mod X
*	- Added default slot cvar
*	- Added classic/combat cvars
*	- Added support for userinfo slot preference
* v1.4a:
*	- Ported to AMX Mod X v1.60 by Depot
* v1.5:
*	- Check included by Depot to prevent lerk respawning as skulk from having lerkspike (thanks White Panther)
*	- Same check prevents marines from receiving setinfo msg. Code improvements by White Panther.
* v1.6:
*	- plugin now works with latest NS and Amx Mod X ( v1.71 or above only )
*	- fixed bug where custom settings could bug weapons
*	- code improvements / clean up
*/

#include <amxmodx>
#include <engine>
#include <ns>

/*
This is a list of each slot and their allowed positions for Spikes:
slot 0:
	0
slot 1:
	2, 7, 8, 9
slot 2:
	0, 6, 8, 9
slot 3:
	0, 2, 3, 9
slot 4:
	2, 3, 4, 5, 6, 7, 8, 9
*/

#define MAXSLOTS		5

new sma_name[] =	"Lerk Spike"
new sma_short[] =	"LERKSPIKE"
new sma_version[] =	"1.6"
new sma_author[] =	"Sandstorm / White Panther"
new cvar_enabled[] =	"lerkspike_enabled"
new cvar_version[] =	"lerkspike_version"
new cvar_default[] =	"lerkspike_default"
new cvar_classic[] =	"lerkspike_classic"
new cvar_combat[] =	"lerkspike_combat"
new cvar_tournament[] =	"mp_tournamentmode"
new userinfo_slot[] =	"spike"
new wpn_spikes[] =	"weapon_spikegun"
new msg_help[] = 	"[%s] Press %d to select your spike shooter."
new msg_setinfo[] = 	"[%s] Next time, use ^"setinfo spike <slot>^" before connecting to set your slot preference."

new CVAR_mp_tournamentmode, CVAR_lerkspike_enabled, CVAR_lerkspike_default, CVAR_lerkspike_classic, CVAR_lerkspike_combat
new is_combat

// WeaponInfo message
enum
{
	wName = 1,	// string
	wAmmoType,	// byte
	wAmmoMax,	// byte
	wUnknown,	// byte, always -1
	wDamage,	// byte
	wSlot,		// byte
	wSlotPos,	// byte
	wId,		// byte
	wFlags		// byte
}

new player_slot[33], player_custom[33], player_helped[33]

public plugin_init( )
{ 
	register_plugin(sma_name, sma_version, sma_author)
	register_cvar(cvar_version, sma_version, FCVAR_SERVER)
	CVAR_lerkspike_enabled = register_cvar(cvar_enabled, "1")
	CVAR_lerkspike_default = register_cvar(cvar_default, "5")
	CVAR_lerkspike_classic = register_cvar(cvar_classic, "1")
	CVAR_lerkspike_combat = register_cvar(cvar_combat, "1")
	CVAR_mp_tournamentmode = get_cvar_pointer(cvar_tournament)
	is_combat = ns_is_combat()
	if ( is_enabled() )
	{
		register_event("WeapPickup", "spawn_lerk", "b", "1=6")
		register_message(get_user_msgid("WeaponList"), "WeaponList_msg")
	}
}

// Player has connected
public client_connect( id )
{
	if ( !is_enabled() )
		return PLUGIN_CONTINUE
	
	new str_slot[3]
	player_helped[id] = 0
	get_user_info(id, userinfo_slot, str_slot, 2)
	if ( !str_slot[0] )
	{
		player_slot[id] = clamp(get_pcvar_num(CVAR_lerkspike_default), 1, MAXSLOTS)
		player_custom[id] = 0
	}else
	{
		player_slot[id] = clamp(str_to_num(str_slot), 1, MAXSLOTS)
		player_custom[id] = 1
	}
	
	return PLUGIN_CONTINUE
}

// A player has spawned as a lerk
public spawn_lerk( id )
{
	if ( ns_get_class(id) == CLASS_LERK )
	{
		if ( is_enabled() )
		{
			ns_give_item(id, wpn_spikes)
			if ( !player_helped[id] )
				help_player(id)
		}
	}
}

// Moves the spike attack to the proper weapon slot
public WeaponList_msg( msgid , dest , id )
{
	new weaponname[64]
	get_msg_arg_string(wName, weaponname, 63)
	if ( equal(weaponname, wpn_spikes) )
	{
		set_msg_arg_int(wSlot, ARG_BYTE, player_slot[id] - 1)
		new pos
		switch ( player_slot[id] )
		{
			case 1:
				pos = 0
			case 2:
				pos = 7
			case 3:
				pos = 0
			case 4:
				pos = 0
			case 5:
				pos = 2
		}
		set_msg_arg_int(wSlotPos, ARG_BYTE, pos)
	}
	return PLUGIN_CONTINUE
}

// Return if plugin is enabled
is_enabled( )
{
	if ( get_pcvar_num(CVAR_mp_tournamentmode) )
		return 0

	if ( !get_pcvar_num(CVAR_lerkspike_enabled) )
		return 0

	if ( !get_pcvar_num(CVAR_lerkspike_combat) && is_combat )
		return 0

	if ( !get_pcvar_num(CVAR_lerkspike_classic) && !is_combat )
		return 0

	return 1
}

// Help the player
help_player( id )
{
	player_helped[id] = 1
	client_print(id, print_chat, msg_help, sma_short, player_slot[id])
	if ( !player_custom[id] )
		client_print(id, print_chat, msg_setinfo, sma_short)
}