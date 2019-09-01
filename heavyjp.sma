/* 
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
*
* Heavy Jetpack enables a player have a jetpack and be heavy at the same time
* Copyright © 2005  KCE
* 
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public License
* as published by the Free Software Foundation; either version 2
* of the License, or (at your option) any later version.
* 
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.
* 
* You should have received a copy of the GNU General Public License
* along with this program; if not, write to the Free Software
* Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
* 
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
*
* Title : Heavy Jetpack
* 
* Author : KCE
* 
* Special Thanks & Credit :
*		JetpackHeavy by xeph - Generation and fuelfactor calculation
*		Jetpack Heavy Armor by Rabid Baboon - Jetpack Heavy armor code
*		Gnome by White Panther, Zamma - Teleport effect
*
* Version : 1.3
* 
* Cvars (name/default value/description) : 
* 		hj_fuelfactor (10.0) - How much additional fuel to consume in addition to 
*								normal fuel consumpiton rate as a heavy jetpacker 
*		(consume/generate factor of JH, default 10.0 (JH flight time is 3.0~3.5 seconds))
*		
* 		hj_generator (1.0) - How much fuel to generate as a heavy jetpacker
*							addional fuel generating rate based on fuelfactor
*		It will add (hj_fuelfactor * hj_generator) to the normal fuel generation rate
*		(default 1.0, minimum 0.0.)
*
*		hj_armor3 (1)	- Whether level 3 armor required to be hevy jetpacker
*
* Cmds : 
*		None
*
* History :
*		v1.0	- 	Initial Release
*		v1.1	-	In CO, when player goes to RR their variables are reset
*				-	Changed method of giving jp/ha
*		v1.2	-	Fixed for ns_mvm
*		v1.3	-	Added suport for Helper
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*/

/*
INT (1)
0 - Do use default helper output
1 - Use the "Helper" plugin! (recommended)
*/
#define HELPER 1

#include <amxmodx>
#include <engine>
#include <fakemeta>
#include <ns>

#if HELPER == 1                                                                 // make sure we only include the helper if we actually want to use it! server ops may not have this file and therefor do not wish to include it, although it doesn't harm if the Helper is disabled
  #include <helper>
#else
  #define help_add set_localinfo                                                // hax hax, this will allow us to use help_add although we did not include the helper
#endif                                                                          // it will replace all help_adds with set_localinfos. this doesn't do any harm as the forwards aren't called anyway
                                                                                // this way is recommended as it requires the least work

#define HEAVY 0
#define JP 1

#define kMarineArmorUpgrade 60
#define kMarineBaseArmor 25
#define kMarineBaseHeavyArmor 200
#define kMarineHeavyArmorUpgrade 90

new g_Players[33][2]
new teleport_event

public plugin_init()
{
	register_plugin("Heavy Jetpack", "1.3", "KCE")
	register_cvar("hj_fuelfactor","10")
	register_cvar("hj_generator","1.0")
	register_cvar("hj_armor3","1")
	
	teleport_event = precache_event(1,"events/Teleport.sc")
		
	register_touch("item_jetpack","player","JetPackTouch") 
	register_touch("item_heavyarmor","player","HeavyTouch")

	if(ns_is_combat())
		set_task(0.5, "GiveItems", 1563, _,_, "b")
}

public client_connect(id)
{
	g_Players[id][HEAVY] = 0
	g_Players[id][JP] = 0
}

public client_disconnect(id)
{
	g_Players[id][HEAVY] = 0
	g_Players[id][JP] = 0	
}

public client_changeclass(id,newclass,oldclass)
{
	if(newclass == CLASS_NOTEAM)
	{
		g_Players[id][HEAVY] = 0
		g_Players[id][JP] = 0	
	}
	
	if(newclass == CLASS_HEAVY)
		g_Players[id][HEAVY] = 1

	if(newclass == CLASS_JETPACK)
		g_Players[id][JP] = 1	
}

public client_changeteam(id,newteam,oldteam)
{
	g_Players[id][HEAVY] = 0
	g_Players[id][JP] = 0	
}

public give_jp(id)
{
	new Float:origin[3]
	pev(id,pev_origin,origin)
	emit_sound(id,CHAN_ITEM,"misc/phasein.wav",1.0,ATTN_NORM,0,PITCH_NORM)
	playback_event(0,id,teleport_event,0.0,origin,Float:{0.0,0.0,0.0},0.0,0.0,0,0,0,0)
	ns_set_mask(id, MASK_JETPACK, 1)		//give jetpack
	emit_sound(id, CHAN_STATIC, "items/pickup_jetpack.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM ) 	//play sound
}

public give_ha(id)
{
	new Float:origin[3]
	pev(id,pev_origin,origin)
	emit_sound(id,CHAN_ITEM,"misc/phasein.wav",1.0,ATTN_NORM,0,PITCH_NORM)
	playback_event(0,id,teleport_event,0.0,origin,Float:{0.0,0.0,0.0},0.0,0.0,0,0,0,0)
	ns_set_mask(id, MASK_HEAVYARMOR, 1)		//give ha
	set_pev(id,pev_armorvalue,float( (30 * check_armor_upgrade(id) )  + kMarineBaseHeavyArmor ))	//fix armor
	emit_sound(id, CHAN_STATIC, "items/pickup_heavy.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM ) 	//play sound	
}

public GiveItems()
{
	for(new id=1; id<get_maxplayers(); id++)
	{
		if(is_user_connected(id))
		{
			new hasArmor3 = ns_get_mask(id, MASK_ARMOR3)
			if(g_Players[id][JP] == 1 && g_Players[id][HEAVY] == 1) 
			{
				if(get_cvar_num("hj_armor3"))
				{
					if(hasArmor3)
					{
						if(ns_get_mask(id,MASK_HEAVYARMOR) && !ns_get_mask(id,MASK_JETPACK))
						{
							give_jp(id)
						}
						else if(!ns_get_mask(id,MASK_HEAVYARMOR) && ns_get_mask(id,MASK_JETPACK))
						{
							give_ha(id)
						}
					}
				}
				else
				{
					if(ns_get_mask(id,MASK_HEAVYARMOR) && !ns_get_mask(id,MASK_JETPACK))
					{
						give_jp(id)
					}
					else if(!ns_get_mask(id,MASK_HEAVYARMOR) && ns_get_mask(id,MASK_JETPACK))
					{
						give_ha(id)
					}			
				}
			}
		}
	}
		
	return PLUGIN_HANDLED
}

public HeavyTouch(ptr,ptd)
{
	if(pev(ptd,pev_team) == 1 || pev(ptd,pev_team) == 3)	//if marine
	{
		new ptd_classname[32]
		entity_get_string(ptd,EV_SZ_classname,ptd_classname,31)
		if (equal(ptd_classname,"player"))	//if player
		{
			new class = ns_get_class(ptd)
			if(class == CLASS_JETPACK)
			{
				if(get_cvar_num("hj_armor3"))
				{
					if(ns_get_mask(ptd,MASK_ARMOR3) && !ns_get_mask(ptd,MASK_HEAVYARMOR))
					{
						give_ha(ptd)
						remove_entity(ptr)
					}
				}
				else
				{
					if(!ns_get_mask(ptd,MASK_HEAVYARMOR))				
					{
						give_ha(ptd)
						remove_entity(ptr)
					}
				}
			}
		}
	}
}

public JetPackTouch(ptr,ptd)
{
	if(pev(ptd,pev_team) == 1 || pev(ptd,pev_team) == 3)	//if marine
	{
		new ptd_classname[32]
		entity_get_string(ptd,EV_SZ_classname,ptd_classname,31)
		if (equal(ptd_classname,"player"))	//if player
		{
			new class = ns_get_class(ptd)
			if(class == CLASS_HEAVY)
			{
				if(get_cvar_num("hj_armor3"))
				{
					if(ns_get_mask(ptd,MASK_ARMOR3) && !ns_get_mask(ptd,MASK_JETPACK))
					{			
						give_jp(ptd)
						remove_entity(ptr)
					}
				}
				else
				{
					if(!ns_get_mask(ptd,MASK_JETPACK))
					{
						give_jp(ptd)
						remove_entity(ptr)
					}
				}
			}
		}
	}
}

public server_frame()
{
	for ( new id = 1; id <= get_maxplayers(); id++ )
	{
		if ( pev(id,pev_team) == 1 || pev(id,pev_team) == 3 )
		{
			if ( is_user_connected(id) )
			{
				if ( is_user_alive(id) )
				{
					if ( ns_get_mask(id,MASK_HEAVYARMOR) && ns_get_mask(id,MASK_JETPACK) && (pev(id, pev_button) & IN_JUMP) )
					{
						entity_set_float(id,EV_FL_fuser3,floatmax(entity_get_float(id,EV_FL_fuser3)-get_cvar_float("hj_fuelfactor"),0.0))
					}
					else if ( ns_get_mask(id,MASK_HEAVYARMOR) && ns_get_mask(id,MASK_JETPACK) && (get_cvar_float("hj_generator") >= 0.1) )
					{
						entity_set_float(id,EV_FL_fuser3,floatmin(entity_get_float(id,EV_FL_fuser3)+(get_cvar_float("hj_fuelfactor")*get_cvar_float("hj_generator")),1000.0))					
					}
				}
			}
		}
	}

	return PLUGIN_CONTINUE
}

public check_armor_upgrade(id)
{
	if ( ns_get_mask(id,MASK_ARMOR1) )
	{
		if ( ns_get_mask(id,MASK_ARMOR2) )
		{
			if ( ns_get_mask(id,MASK_ARMOR3) )
			{
				return 3
			}
			else
			{
				return 2
			}
		}
		else
		{
			return 1
		}
	}
	return 0
}

stock Float:floatmax(Float:val1,Float:val2)
{
	if (val1 > val2)
		return val1
	else if(val2 > val1)
		return val2

	return val1
}

stock Float:floatmin(Float:val1,Float:val2)
{
	if (val1 < val2)
		return val1
	else if(val2 < val1)
		return val2
	
	return val1
}

#if HELPER == 1
public client_help(id)
{
	help_add("Information","This plugin allows marines to be both JP and HA")
	help_add("Usage","Get Armor 3 + JP + HA. There is no specific order in which to get upgrades")
	help_add("Commands","None")
}

public client_advertise(id)	return PLUGIN_CONTINUE
#endif