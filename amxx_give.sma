/*
AMXx Give 2.2
By: ReK_

Enable the "give" console command on any mod, without enabling sv_cheats.
You can now specify which player to give the item.

Fun module required

CVARs:
- amx_give_enable 0/1 - 1 = Enabled, 0 = Disabled

Usage:
Use amx_giveself to give it to yourself.
Type "amx_giveto name x" into the console, replacing name with the recipient's name and x with item_x, weapon_x, team_x or ammo_x
These commands are only availiable to users with the "s" flag, ie admin level g.
*/

#include <amxmodx>
#include <amxmisc>
#include <fun>

public plugin_init()
{
	register_plugin("AMXx Give", "2.0", "ReK_")
	register_cvar("amx_give_enable", "1")
	register_concmd("amx_giveto", "give", ADMIN_LEVEL_G, "- Give a player an item")
	register_concmd("amx_giveself", "giveself", ADMIN_LEVEL_G, "- Give yourself an item")
}

public plugin_modules()
{
	require_module("fun")
}

public give(id)
{
	new rname[32], gname[32], item[32], uid

	read_argv(1, rname, 31)
	read_argv(2, item, 31)
	strtolower(item)

	if(get_cvar_num("amx_give_enable")==1)
	{
		if(!equal(item,"item_",5) && !equal(item,"weapon_",7) && !equal(item,"ammo_",5) && !equal(item,"team_",5))
		{
			client_print(id,print_console,"[AMXx Give] Item names must begin with item_, weapon_, team_ or ammo_")
			return PLUGIN_CONTINUE
		}
		else
		{
			uid = cmd_target(id, rname, 4)
			get_user_name(id, gname, 31)
			client_print(uid, print_chat, "[AMXx Give] %s has given you %s", gname, item)
			give_item(uid,item)
			return PLUGIN_HANDLED
		}
	}
	else if(get_cvar_num("amx_give_enable")==0)
		client_print(id,print_console,"[AMXx Give] This plugin is disabled. Set amx_give_enable to 1 to re-enable.")

	return PLUGIN_CONTINUE
}

public giveself(id)
{
	new item[32]

	read_argv(1, item, 31)
	strtolower(item)

	if(get_cvar_num("amx_give_enable")==1)
	{
		if(!equal(item,"item_",5) && !equal(item,"weapon_",7) && !equal(item,"ammo_",5) && !equal(item,"team_",5))
		{
			client_print(id,print_console,"[AMXx Give] Item names must begin with item_, weapon_, team_ or ammo_")
			return PLUGIN_CONTINUE
		}
		else
		{
			give_item(id,item)
			return PLUGIN_HANDLED
		}
	}
	else if(get_cvar_num("amx_give_enable")==0)
		client_print(id,print_console,"[AMXx Give] This plugin is disabled. Set amx_give_enable to 1 to re-enable.")

	return PLUGIN_CONTINUE
}
