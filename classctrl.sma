/*
 *	Limits the amount of different classes in combat.
 *
 *	Note: 		Shouldn't be any exploits...(*shouldn't* :/)
 *
 *	Commands:	None
 *
 *	Cvars:		amx_classctrl		Whether or not limit classes (0(off) or 1(on))
 *			cctrl_maxgorges		How many gorges max
 *			cctrl_maxlerks		How many lerks max
 *			cctrl_maxfades		How many fades max
 *			cctrl_maxoni		How many oni max
 *			cctrl_maxjp		How many jetpackers max
 *			cctrl_maxha		How many heavies max
 *			cctrl_maxgl		How many gee ells max
 *			cctrl_maxhmg		How many hmgs max
 *
 *	Author:		Darkns
 *	Grenade launcher and hmg control added by Depot
 *
 */

#include <amxmodx>
#include <engine>
#include <fakemeta>
#include <ns>

#define CHECK_DELAY	0.5
#define IMPULSE_GORGE	114
#define IMPULSE_LERK	115
#define IMPULSE_FADE	116
#define IMPULSE_ONOS	117
#define IMPULSE_JP	39
#define IMPULSE_HA	38
#define IMPULSE_GL	66
#define IMPULSE_HMG	65

new g_maxplrs, g_gorges[3], g_lerks[3], g_fades[3], g_oni[3]

public plugin_modules()
{
	require_module("engine")
	require_module("fakemeta")
	require_module("ns")
}

public plugin_init()
{
	if (ns_is_combat())
	{
		register_plugin("ClassCTRL (ON)", "1.3", "Darkns")
		
		register_cvar("amx_classctrl", "1")
		register_cvar("cctrl_maxgorges", "2")
		register_cvar("cctrl_maxlerks", "2")
		register_cvar("cctrl_maxfades", "2")
		register_cvar("cctrl_maxoni", "2")
		register_cvar("cctrl_maxjp", "2")
		register_cvar("cctrl_maxha", "2")
		register_cvar("cctrl_maxgl", "2")
		register_cvar("cctrl_maxhmg", "2")
		register_impulse(IMPULSE_GORGE,"gorgehook")
		register_impulse(IMPULSE_LERK,"lerkhook")
		register_impulse(IMPULSE_FADE,"fadehook")
		register_impulse(IMPULSE_ONOS,"onoshook")
		register_impulse(IMPULSE_JP,"jphook")
		register_impulse(IMPULSE_HA,"hahook")
		register_impulse(IMPULSE_GL,"glhook")
		register_impulse(IMPULSE_HMG,"hmghook")
		g_maxplrs = get_maxplayers()
	}
	else
		register_plugin("ClassCTRL (OFF)", "1.3", "Darkns")
	
	return
}

public gorgehook(id)
{
	if (!get_cvar_num("amx_classctrl"))
		return PLUGIN_CONTINUE
	if (is_user_bot(id))
		return PLUGIN_CONTINUE
	new count
	for(new i = 1; i <= g_maxplrs; i++)
	{
	if ( is_user_connected(i) )
		{
		if ((ns_get_class(i) == CLASS_GORGE) && (pev(id, pev_team) == pev(i, pev_team)))
			count++
		}
	}
	count += g_gorges[pev(id, pev_team)]
	if (count >= get_cvar_num("cctrl_maxgorges"))
	{
		ns_popup(id, "Your team already has enough gorges")
		return PLUGIN_HANDLED
	}
	else
	{
		g_gorges[pev(id, pev_team)]++
		new parm[1]
		parm[0] = id
		set_task(CHECK_DELAY, "checkgorge",_,parm,1)
	}
	return PLUGIN_CONTINUE
}

public checkgorge(parm[1])
{
	new id = parm[0]
	if (ns_get_class(id) == CLASS_GESTATE)
		set_task(CHECK_DELAY, "checkgorge",_,parm,1)
	else
		g_gorges[pev(id, pev_team)]--
}


public lerkhook(id)
{
	if (!get_cvar_num("amx_classctrl"))
		return PLUGIN_CONTINUE
	if (is_user_bot(id))
		return PLUGIN_CONTINUE
	new count
	for(new i = 1; i <= g_maxplrs; i++)
	{
	if ( is_user_connected(i) )
		{
		if ((ns_get_class(i) == CLASS_LERK) && (pev(id, pev_team) == pev(i, pev_team)))
			count++
		}
	}
	count += g_lerks[pev(id, pev_team)]
	if (count >= get_cvar_num("cctrl_maxlerks"))
	{
		ns_popup(id, "Your team already has enough lerks")
		return PLUGIN_HANDLED
	}
	else
	{
		g_lerks[pev(id, pev_team)]++
		new parm[1]
		parm[0] = id
		set_task(CHECK_DELAY, "checklerk",_,parm,1)
	}
	return PLUGIN_CONTINUE
}

public checklerk(parm[1])
{
	new id = parm[0]
	if (ns_get_class(id) == CLASS_GESTATE)
		set_task(CHECK_DELAY, "checklerk",_,parm,1)
	else
		g_lerks[pev(id, pev_team)]--
}

public fadehook(id)
{
	if (!get_cvar_num("amx_classctrl"))
		return PLUGIN_CONTINUE
	if (is_user_bot(id))
		return PLUGIN_CONTINUE
	new count
	for(new i = 1; i <= g_maxplrs; i++)
	{
	if ( is_user_connected(i) )
		{
		if ((ns_get_class(i) == CLASS_FADE) && (pev(id, pev_team) == pev(i, pev_team)))
			count++
		}
	}
	count += g_fades[pev(id, pev_team)]
	if (count >= get_cvar_num("cctrl_maxfades"))
	{
		ns_popup(id, "Your team already has enough fades")
		return PLUGIN_HANDLED
	}
	else
	{
		g_fades[pev(id, pev_team)]++
		new parm[1]
		parm[0] = id
		set_task(CHECK_DELAY, "checkfade",_,parm,1)
	}
	return PLUGIN_CONTINUE
}

public checkfade(parm[1])
{
	new id = parm[0]
	if (ns_get_class(id) == CLASS_GESTATE)
		set_task(CHECK_DELAY, "checkfade",_,parm,1)
	else
		g_fades[pev(id, pev_team)]--
}

public onoshook(id)
{
	if (!get_cvar_num("amx_classctrl"))
		return PLUGIN_CONTINUE
	if (is_user_bot(id))
		return PLUGIN_CONTINUE
	new count
	for(new i = 1; i <= g_maxplrs; i++)
	{
	if ( is_user_connected(i) )
		{
		if ((ns_get_class(i) == CLASS_ONOS) && (pev(id, pev_team) == pev(i, pev_team)))
			count++
		}
	}
	count += g_oni[pev(id, pev_team)]
	if (count >= get_cvar_num("cctrl_maxoni"))
	{
		ns_popup(id, "Your team already has enough oni")
		return PLUGIN_HANDLED
	}
	else
	{
		g_oni[pev(id, pev_team)]++
		new parm[1]
		parm[0] = id
		set_task(CHECK_DELAY, "checkonos",_,parm,1)
	}
	return PLUGIN_CONTINUE
}

public checkonos(parm[1])
{
	new id = parm[0]
	if (ns_get_class(id) == CLASS_GESTATE)
		set_task(CHECK_DELAY, "checkonos",_,parm,1)
	else
		g_oni[pev(id, pev_team)]--
}

public jphook(id)
{
	if (!get_cvar_num("amx_classctrl"))
		return PLUGIN_CONTINUE
	if (is_user_bot(id))
		return PLUGIN_CONTINUE
	new count
	for(new i = 1; i <= g_maxplrs; i++)
	{
	if ( is_user_connected(i) )
		{
		if ((ns_get_class(i) == CLASS_JETPACK) && (pev(id, pev_team) == pev(i, pev_team)))
			count++
		}
	}
	if (count >= get_cvar_num("cctrl_maxjp"))
	{
		ns_popup(id, "Your team already has enough jetpackers")
		return PLUGIN_HANDLED
	}
	return PLUGIN_CONTINUE
}

public hahook(id)
{
	if (!get_cvar_num("amx_classctrl"))
		return PLUGIN_CONTINUE
	if (is_user_bot(id))
		return PLUGIN_CONTINUE
	new count
	for(new i = 1; i <= g_maxplrs; i++)
	{
	if ( is_user_connected(i) )
		{
		if ((ns_get_class(i) == CLASS_HEAVY) && (pev(id, pev_team) == pev(i, pev_team)))
			count++
		}
	}
	if (count >= get_cvar_num("cctrl_maxha"))
	{
		ns_popup(id, "Your team already has enough heavies")
		return PLUGIN_HANDLED
	}
	return PLUGIN_CONTINUE
}

public glhook(id)
{
	if (!get_cvar_num("amx_classctrl"))
		return PLUGIN_CONTINUE
	if (is_user_bot(id))
		return PLUGIN_CONTINUE
	new count
	for(new i = 1; i <= g_maxplrs; i++)
	{
	if ( is_user_connected(i) )
		{
		new weap_list[32], weap_num
		get_user_weapons(i,weap_list,weap_num)
		for(new j = 0; j < weap_num; j++)
		{
			if ( weap_list[j] == WEAPON_GRENADE_GUN )
			{
				if ( pev(id, pev_team) == pev(i, pev_team) )
					count++
				break
			}
		}
	}
	}
	if (count >= get_cvar_num("cctrl_maxgl"))
	{
		ns_popup(id, "Your team already has enough grenade launchers")
		return PLUGIN_HANDLED
	}
	return PLUGIN_CONTINUE
}

public hmghook(id)
{
	if (!get_cvar_num("amx_classctrl"))
		return PLUGIN_CONTINUE
	if (is_user_bot(id))
		return PLUGIN_CONTINUE
	new count
	for(new i = 1; i <= g_maxplrs; i++)
	{
	if ( is_user_connected(i) )
		{
		new weap_list[32], weap_num
		get_user_weapons(i,weap_list,weap_num)
		for(new j = 0; j < weap_num; j++)
		{
			if ( weap_list[j] == WEAPON_HMG )
			{
				if ( pev(id, pev_team) == pev(i, pev_team) )
					count++
				break
			}
		}
	}
	}
	if (count >= get_cvar_num("cctrl_maxhmg"))
	{
		ns_popup(id, "Your team already has enough hmgs")
		return PLUGIN_HANDLED
	}
	return PLUGIN_CONTINUE
}