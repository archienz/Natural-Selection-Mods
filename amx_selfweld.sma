/* 
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
*
* AMXX Self Weld enables a player to weld themselves by looking down
* Copyright © 2006  KCE
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
* Title : AMXX SELF WELD
* 
* Author : KCE
* 
* Special Thanks & Credit :
*		Gnome Builder by White Panther, Zamma - Basically the whole self weld code is 
*												straight from their plugin except with
*												modifications
*		Metamod SelfWeld by [WHO]Them & Peachy - Reinforced armor check
*
* Version : 1.5
* 
* Cvars (name/default value/description) : 
* 		amx_selfweld (1) - Enable/Disable
* 		selfweld_amt (5) - How much armor to weld per "selfweld_rate"
* 		selfweld_rate (0.4) - How many seconds it takes to weld "selfweld_amt"
*		selfweld_splash (1)	- Enable/Disable splash welding - if welding teamate, you get armor also 
*									(Thanks sandstorm, for idea ; )
*		selfweld_selfonly (1) -	Set to 1 to disable players from welding buildings and himself at the same time
*		selfweld_angle (-27.0) - Angle required to selfweld, negative means look down, positive means look up
*									If set to 0.0, then player just has to look straight.
*									DEFAULT VALUE RECOMMENDED!
*		selfweld_welderlvl (-1) - Set to value greater than -1 to give welder at that level. -1 disables it
*
*		For example:	At the default settings, the player would have to hold down the mouse 
*						button for 0.4 seconds to weld himself 5 more armor.
*
* History :
*		v1.0	- 	Initial Release
*		v1.0.1	-	Fixed array out of bounds problem
*		v1.1	-	Some small tweaks
*				-	Shortened usage/info messages
*				-	Added cvar to control rate
*		v1.1.1	-	Updated for NS v3.0.3 (Armor was increased)
*		v1.2	-	Added splash welding and cvar (Thanks sandstorm, for idea ; )
*					Player cannot weld himself and buildings at the same time unless cvar is set
*					Using prethink instead of using server_frame
*					Reset variables on connect and disconnect
*					SelfWeld angle can now be adjusted with cvar
*					Planned to add in sound but I'll do that in another update...
*		v1.3	-	Added automatic welder
*				-	Removed help/usage
*				-	Removed plugin_modules (not needed)
*				-	Fakemeta not needed
*				-	Rearranged code
*				-	Replaced client_connect with client_putinserver
*				-	MvM check now done by map name if it contains "mvm"
*		v1.4	-	Changed MvM Check
*				-	Added support for reinforced armor (code adapted from Metamod Selfweld updated by Peachy)
*				-	Fixed possible exploit
*		v1.5	-	Helper support added
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
#include <ns>

#if HELPER == 1                                                                 // make sure we only include the helper if we actually want to use it! server ops may not have this file and therefor do not wish to include it, although it doesn't harm if the Helper is disabled
  #include <helper>
#else
  #define help_add set_localinfo                                                // hax hax, this will allow us to use help_add although we did not include the helper
#endif                                                                          // it will replace all help_adds with set_localinfos. this doesn't do any harm as the forwards aren't called anyway
                                                                                // this way is recommended as it requires the least work

#define kWelderRange 90

new g_mvm
new Float:used_welder[33]
new old_ent_id[33]
new Float:ent_ap_change[33]
new Float:g_MaxArmor[33]

public plugin_init()
{  
	register_plugin("AMXX Self Weld", "1.5", "KCE")
	
	register_cvar("amx_selfweld", "1")
	register_cvar("selfweld_amt", "5")
	register_cvar("selfweld_rate", "0.4")
	register_cvar("selfweld_splash", "1")	
	register_cvar("selfweld_selfonly", "1")	
	register_cvar("selfweld_angle", "-27.0")
	register_cvar("selfweld_welderlvl", "-1")

	register_event("ResetHUD", "client_spawned", "b")
	
	new ccid = get_maxplayers() + 1
	new count 
	while ( ( ccid = find_ent_by_class(ccid,"team_command") ) > 0)
		count++ 
	
	if ( count > 1 && ns_is_combat() )
		g_mvm = 1
	else
		g_mvm = 0
}

public client_putinserver(id)
{
	used_welder[id] = 0.0
	old_ent_id[id] = 0
	ent_ap_change[id] = 0.0
	g_MaxArmor[id] = 0.0
}

public client_disconnect(id)
{
	used_welder[id] = 0.0
	old_ent_id[id] = 0
	ent_ap_change[id] = 0.0
	g_MaxArmor[id] = 0.0
}

public client_changeteam ( id, newteam, oldteam )
{
	used_welder[id] = 0.0
	old_ent_id[id] = 0
	ent_ap_change[id] = 0.0
	g_MaxArmor[id] = 0.0
}

public client_spawned(id)
{
	new welderlvl = get_cvar_num( "selfweld_welderlvl" )
	
	if( (welderlvl > -1) && ((floatround(floatsqroot(ns_get_exp(id) / 25 + 2.21) - 1)) > welderlvl) )
	{
		ns_give_item( id, "weapon_welder" )
	}
}

public client_PreThink(id)
{
	if ( !get_cvar_num("amx_selfweld") || (entity_get_int(id,EV_INT_team) != 1 && !g_mvm) )
		return PLUGIN_CONTINUE

	new iuser4 = entity_get_int( id, EV_INT_iuser4 )
	
	if( (iuser4 & MASK_ARMOR3) && (g_MaxArmor[id] >= ((iuser4 & MASK_HEAVYARMOR) ? 290 : 90)) )
	{
		if ((entity_get_float( id, EV_FL_armorvalue ) > ((iuser4 & MASK_HEAVYARMOR) ? 290 : 90)) && (entity_get_float( id, EV_FL_armorvalue ) > g_MaxArmor[id])) 
			g_MaxArmor[id] = entity_get_float( id, EV_FL_armorvalue )
	}
	else
	{
		if (iuser4 & MASK_HEAVYARMOR)
		{
			if (iuser4 & MASK_ARMOR1)
			{
				if (iuser4 & MASK_ARMOR2)
				{
					if (iuser4 & MASK_ARMOR3)
						g_MaxArmor[id] = 290.0;
					else
						g_MaxArmor[id] = 260.0;
				}
				else
					g_MaxArmor[id] = 230.0;
			}
			else g_MaxArmor[id] = 200.0;
		}
		else
		{
			if (iuser4 & MASK_ARMOR1)
			{
				if (iuser4 & MASK_ARMOR2)
				{
					if (iuser4 & MASK_ARMOR3)
						g_MaxArmor[id] = 90.0;
					else
						g_MaxArmor[id] = 70.0;
				}
				else
					g_MaxArmor[id] = 50.0;
			}
			else g_MaxArmor[id] = 30.0;
		}
	}
		
	new aim_at_id, dummy, mode
	get_user_aiming(id, aim_at_id, dummy, kWelderRange)
	
	new selfwelding
	
	new Float:cur_angle[3]
	entity_get_vector(id,EV_VEC_angles,cur_angle)

	if(get_cvar_num("selfweld_selfonly"))
	{
		if ( (cur_angle[0] <= get_cvar_float("selfweld_angle")) && !is_valid_ent(aim_at_id) )
		{
			selfwelding = 1
			aim_at_id = id
		}
	}
	else	//allow structures at the same time
	{
		if (cur_angle[0] <= get_cvar_float("selfweld_angle"))
		{
			selfwelding = 1
			aim_at_id = id
		}			
	}

	if ( !is_valid_ent(aim_at_id) && !selfwelding )
		return PLUGIN_CONTINUE
	
	if ( (entity_get_int(id, EV_INT_button) & IN_ATTACK) && (get_user_weapon(id,dummy,dummy) == WEAPON_WELDER) )
	{
		if (selfwelding)
		{
			selfwelding = 2	//welding self
		}
		else if(get_cvar_num("selfweld_splash"))	//if splash is on
		{
			if ( (is_user_connected(aim_at_id) || selfwelding) && (entity_get_int(id,EV_INT_team) == entity_get_int(aim_at_id,EV_INT_team)))
				mode = 3		//welding teamate
		}
	}
	else
	{
		return PLUGIN_CONTINUE
	}
	
	// welding self
	if ( selfwelding == 2 )
	{
		if ( get_gametime() - used_welder[id] > get_cvar_float("selfweld_rate") )
		{
			ent_ap_change[id] = entity_get_float(id, EV_FL_armorvalue) + get_cvar_float("selfweld_amt")	
			
			if ( ent_ap_change[id] >= g_MaxArmor[id] )
				ent_ap_change[id] = g_MaxArmor[id]
			
			entity_set_float(id, EV_FL_armorvalue, ent_ap_change[id])
			
			used_welder[id] = get_gametime()								
		}
		
		return PLUGIN_CONTINUE	//looking at self so just return now
	}
	
	// if we looking at a new entity reset everything
	if ( old_ent_id[id] != aim_at_id )
		used_welder[id] = 0.0
		
	if(mode == 3)	//if welding teamate, then weld himself
	{
		if ( get_gametime() - used_welder[id] > get_cvar_float("selfweld_rate") )
		{
			ent_ap_change[id] = entity_get_float(id, EV_FL_armorvalue) + get_cvar_float("selfweld_amt")	
			
			if ( ent_ap_change[id] > g_MaxArmor[id] )	
				ent_ap_change[id] = g_MaxArmor[id]
			
			entity_set_float(id, EV_FL_armorvalue, ent_ap_change[id])
			
			used_welder[id] = get_gametime()								
		}						
	}
	
	old_ent_id[id] = aim_at_id
	
	return PLUGIN_CONTINUE
}

#if HELPER == 1
public client_help(id)
{
	help_add("Information","This plugin allows marines to weld themselves")
	help_add("Usage","Look down to weld yourself")
	help_add("Commands","None")
}

public client_advertise(id)	return PLUGIN_CONTINUE
#endif