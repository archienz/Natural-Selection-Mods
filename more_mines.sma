/************************************************
	More Mines/Grenades for Combat
	Author: Rabid Baboon - Modified by SilverSquirrl www.2frag4fun.com
	Version: 1.1b
	Mod: Natural Selection
	Requires: AMX mod X v1.0 
	Description:
		Allows a marine to have as many mines/grenades as the server allows
	Changelog:
		v1.1
			Reset mine info on team change
		v1.1b	
			Modifications by SilverSquirrl
			Added Grenade Support.
			Added Cvar for Max_Mines/Max_Grenades
			Added a printed counter so players know how many mines/grenades they have left.
			Stopped plugin from trying to give you mines/grenades when you are dead.
			
	CVARs:
		Max_Mines <#>		- max number of Mines per life
		Max_Grenades <#>	- Max number of Grenades per life
************************************************/
#include <amxmodx>
#include <ns>
#include <engine>

// constants
#define GOT_MINES 0
#define MINE_COUNT 1
#define GOT_GRENADES 0
#define GRENADE_COUNT 1

//globals
new g_playerM[33][5]
new g_playerG[33][5]
/***********************************************/
public plugin_init() 
{
		register_plugin("More Mines", "v1.1b", "Rabid Baboon/SS")
		if (ns_is_combat())
	{
		register_impulse(61, "GotMines")
		register_impulse(37, "GotGrenades")
		register_cvar("Max_Mines","2", FCVAR_SERVER)
		register_cvar("Max_Grenades","2", FCVAR_SERVER)
		set_task(0.5, "Givemines", 6573, _,_, "b")
	}
}
/***********************************************/
public Givemines()
{
	for(new id=0; id < 33; id++)
	{
		new minesleft, grenadesleft

		if((g_playerM[id][GOT_MINES] == 1) && (g_playerM[id][MINE_COUNT] < get_cvar_num("Max_Mines")))
		{
			if(!ns_has_weapon(id, NSWeapon:WEAPON_MINE) && !(ns_get_class(id) == CLASS_DEAD))
			{
				minesleft = (get_cvar_num("Max_Mines") - (g_playerM[id] [MINE_COUNT]))
				client_print(id, print_chat, "%d Mines Remaining", minesleft)
				ns_give_item(id, "weapon_mine")
				g_playerM[id][MINE_COUNT]++
			}
		}

		if((g_playerG[id][GOT_GRENADES] == 1) && (g_playerG[id][GRENADE_COUNT] < get_cvar_num("Max_Grenades")))
		{
			if(!ns_has_weapon(id, NSWeapon:WEAPON_GRENADE) && !(ns_get_class(id) == CLASS_DEAD))
			{
				grenadesleft = (get_cvar_num("Max_Grenades") - (g_playerG[id] [GRENADE_COUNT]))
				client_print(id, print_chat, "%d Grenades Remaining", grenadesleft)
				ns_give_item(id, "weapon_grenade")
				g_playerG[id][GRENADE_COUNT]++
			}
		}
	}
}
/***********************************************/
public GotMines(id)
{
	g_playerM[id][GOT_MINES] = 1
}
/***********************************************/
public GotGrenades(id)
{
	g_playerG[id][GOT_GRENADES] = 1
}
/***********************************************/
public client_spawn(id)
{
	g_playerM[id][MINE_COUNT] = 1
	g_playerG[id][GRENADE_COUNT] = 1
}
/***********************************************/
public client_changeteam(id, newteam, oldteam)
{
	g_playerM[id][GOT_MINES] = 0
	g_playerM[id][MINE_COUNT] = 1
	g_playerG[id][GOT_GRENADES] = 0
	g_playerG[id][GRENADE_COUNT] = 1	
}