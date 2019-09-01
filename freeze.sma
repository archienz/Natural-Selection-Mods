/*
Plugin Name: Freeze 'em
Author: Kensai

Description
===========
When a player is frozen, he is unable to move, until the admin unfreezes him.

Commands
========
amx_freeze <target> - Freezes the target player.
amx_unfreeze <target> - Unfreezes the target player.

Changelog
=========
v1.2 - Made the target, get switched to their knife.
v1.1 - Cleaned code a bit.
v1.0 - First Version.
*/
#include <amxmodx>
#include <amxmisc>
#include <fun>
#include <cstrike>

new bool:frozen[33]

public plugin_init() 
{
	register_plugin("Freeze 'em", "1.2", "Kensai")
	register_concmd("amx_freeze", "freeze", ADMIN_KICK, "<target> - Freezes the target player.")
	register_concmd("amx_unfreeze", "unfreeze", ADMIN_KICK, "<target> - Unfreezes the frozen player.")
	register_event("CurWeapon", "effect", "be")
}

public client_connect(id)
{
	frozen[id] = false
}

public client_disconnect(id)
{
	frozen[id] = false
}

public freeze(id, level, cid)
{
	if(!cmd_access(id, level, cid, 2))
		return 1
		
	new arg[32]
	read_argv(1, arg, 31)
	
	new tar = cmd_target(id, arg, 2)
	
	if(!tar)
		return 1
		
	if(frozen[tar] == true)
	{
		client_print(id, print_console, "[AMXX] That user is already frozen!")
		return 1
	}
	
	frozen[tar] = true
	client_print(tar, print_chat, "[AMXX] You have been frozen!")
	set_user_maxspeed(id, 0.0)
	set_user_rendering(id, kRenderFxGlowShell, 0, 0, 180, kRenderTransAlpha, 150)
	effect(tar)
	
	return 1
}

public unfreeze(id, level, cid)
{
	if(!cmd_access(id, level, cid, 2))
		return 1
		
	new arg[32]
	read_argv(1, arg, 31)
	
	new tar = cmd_target(id, arg, 2)
	
	if(!tar)
		return 1
		
	if(frozen[tar] == false)
	{
		client_print(id, print_console, "[AMXX] That user is already unfrozen!")
		return 1
	}
	
	frozen[tar] = false
	client_print(tar, print_chat, "[AMXX] You have been unfrozen!")
	set_user_maxspeed(id, 320.0)
	set_user_rendering(id, kRenderFxGlowShell, 0, 0, 0, kRenderTransAlpha, 255)
	
	return 1
}

public effect(id)
{
	if(frozen[id])
	{
		client_cmd(id, "weapon_knife")
		return 1
	}
	return 1
}
