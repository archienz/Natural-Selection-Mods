/* 
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
*
* NS Parachute enables a player to float down using a parachute
* Copyright © 2006  KRoTaL (ported by KCE)
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
* Title : NS Parachute
* 
* Author : KRoTaL (ported by KCE)
* 
* Special Thanks & Credit :
*		Original - Amx Parachute - KRoTaL
*		http://djeyl.net/forum/index.php?showtopic=41790
*
* Version : 1.0.2
* 
* Cvars (name/default value/description) : 
*		"amx_parachute"		"1"		Enable/Disable
*		"parachute_cost"	"1"		if cost is 0 then everyone can use it, else the cost of the parachute
*		"parachute_marines"	"0"		If this is on, only rines can use parachute
*
* Cmds : 
* 		Hold down +use button (e) to deploy parachute
* 		Type "/buyparachute" in chat or team chat to see usage
*
* History :
*		1.0		-	Initial Release
*		1.0.1	-	Superlift compatible ( player being lifted cannot use parachute )
*				-	Added cvar for marines only
*		1.0.2	-	Added variable ENABLED for usage modes
*
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*/

#include <amxmodx>
#include <amxmisc>
#include <engine>
#include <ns>

new ENABLED = 3
//1 for combat only
//2 for ns only
//3 for combat/ns

//sequences in mdl file, do not edit
#define SEQ_DEPLOY		0
#define SEQ_IDLE		1
#define SEQ_DETACH		2

new para_ent[33]
new para_upg[33]

new g_mvm

public plugin_init()
{
	register_plugin("NS Parachute", "1.0.2", "KRoTaL (ported by KCE)")

	register_cvar( "amx_parachute", "1" )
	
	if( ENABLED == 1 )
	{
		if( !ns_is_combat() )
			set_cvar_num( "amx_parachute", 0 )
	}
	else if( ENABLED == 2 )
	{
		if( ns_is_combat() )
			set_cvar_num( "amx_parachute", 0 )		
	}
	
	register_cvar( "parachute_cost", "0" )		
	register_cvar( "parachute_marines", "1" )	
	
	register_clcmd( "say /buyparachute", "buy_parachute" )	
	register_clcmd( "say_team /buyparachute", "buy_parachute" )	
	
	register_event("ResetHUD", "resethud_event", "be")
	register_event("DeathMsg", "death_event", "a")

	new ccid = -1, count 
	while ( ( ccid = find_ent_by_class(ccid,"team_command") ) > 0)
		count++ 
	
	if ( count > 1 && ns_is_combat() )
		g_mvm = 1
}

public plugin_precache()
{
	precache_model("models/parachute.mdl")
}

public client_connect(id)
{
	if(para_ent[id] > 0)
	{
		remove_entity(para_ent[id])
		para_ent[id] = 0		
	}
	
	para_upg[id] = 0
	
	return PLUGIN_CONTINUE	
}

public client_disconnect(id)
{
	if(para_ent[id] > 0)
	{
		remove_entity(para_ent[id])
		para_ent[id] = 0		
	}
	
	para_upg[id] = 0
	
	return PLUGIN_CONTINUE	
}

public resethud_event(id)
{
	if(para_ent[id] > 0)
	{
		remove_entity(para_ent[id])
		para_ent[id] = 0		
	}
	
	if( get_cvar_num("parachute_marines") )
	{
		if( !g_mvm )
		{
			if( entity_get_int( id, EV_INT_team ) != 1 )
			{
				return PLUGIN_CONTINUE
			}
		}
	}	
	
	set_task( 1.5, "show_info" , id )
	
	return PLUGIN_CONTINUE
}

public show_info(id)
{	
	if( get_cvar_num("parachute_cost") == 0 )
		client_print( id, print_chat, "[Parachute] Hold down your use key while falling" )
	else
		client_print( id, print_chat, "[Parachute] To buy a parachute, type /buyparachute" )
}

public death_event()
{
	new id = read_data(2)

	if(para_ent[id] > 0)
	{
		remove_entity(para_ent[id])
		para_ent[id] = 0
	}
	
	return PLUGIN_CONTINUE
}

public buy_parachute(id)
{
	if( !get_cvar_num("amx_parachute") )
	{
		client_print( id, print_chat, "[Parachute] Parachutes have been disabled" )
		return PLUGIN_HANDLED		
	}

	if( get_cvar_num("parachute_marines") )
	{
		if( !g_mvm )
		{
			if( entity_get_int( id, EV_INT_team ) != 1 )
			{
				client_print( id, print_chat, "[Parachute] Parachutes are only for Marines" )
				return PLUGIN_HANDLED					
			}
		}
	}
	
	if( get_cvar_num("parachute_cost") == 0 )
	{
		client_print( id, print_chat, "[Parachute] Hold down your use key while falling" )
		return PLUGIN_HANDLED		
	}

	if( (ns_get_level(id) - ns_get_points(id)) < get_cvar_num("parachute_cost") )
	{
		client_print( id, print_chat, "[Parachute] You have insufficient points" )
		return PLUGIN_HANDLED		
	}
	
	client_print( id, print_chat, "[Parachute] Hold down your use key while falling" )
	para_upg[id] = 1
	
	return PLUGIN_HANDLED			
}

public client_PreThink(id)
{
	if(!is_user_alive(id) || !get_cvar_num("amx_parachute") || ( ( get_cvar_num("parachute_cost") > 0 ) && ( para_upg[id] == 0 )) || is_lifted(id) )
	{
		if( para_ent[id] > 0 )
		{
			remove_entity(para_ent[id])
			para_ent[id] = 0
		}
	
		return PLUGIN_CONTINUE
	}
	
	if( get_cvar_num("parachute_marines") )
	{
		if( !g_mvm )
		{
			if( entity_get_int( id, EV_INT_team ) != 1 )
			{
				if( para_ent[id] > 0 )
				{
					remove_entity(para_ent[id])
					para_ent[id] = 0
				}
			
				return PLUGIN_CONTINUE			
			}
		}
	}

	new Float:pOrigin[3]
	entity_get_vector( id, EV_VEC_origin, pOrigin )													
	
	//if pressing use and not on ground
	if(get_user_button(id) & IN_USE)
	{
		if(!(get_entity_flags(id) & FL_ONGROUND))
		{
			new Float:velocity[3]
			entity_get_vector(id, EV_VEC_velocity, velocity)	
			
			if(velocity[2] < 0)
			{
				//if they do not have parachute and is falling
				if(para_ent[id] == 0) 
				{
					para_ent[id] = create_entity("info_target")
					if(para_ent[id] > 0)
					{
						entity_set_origin(para_ent[id], pOrigin )
						
						entity_set_float(para_ent[id], EV_FL_framerate, 1.0 ) 		//play deploy 1 and a half times faster

						entity_set_float(para_ent[id], EV_FL_frame, 0.0)												
						entity_set_int(para_ent[id], EV_INT_sequence, SEQ_DEPLOY)
						
						entity_set_model(para_ent[id], "models/parachute.mdl")
					}
				}
				
				//if they do have a parachute then set their velocity and animation sequence
				if(para_ent[id] > 0)
				{
					entity_set_origin(para_ent[id], pOrigin )
				
					//for slower fallspeed don't decrease so much
					//for faster fallspeed decrease more
					
					velocity[2] = (velocity[2] + 40.0 < -100) ? velocity[2] + 40.0 : -100.0
					
					entity_set_vector(id, EV_VEC_velocity, velocity)
				
					if( entity_get_int(para_ent[id], EV_INT_sequence) != SEQ_DETACH )
					{
						//after it finishes the deploy sequence
						if( entity_get_float(para_ent[id], EV_FL_frame) < 0.0 || entity_get_float(para_ent[id], EV_FL_frame) > 254.0 )
						{
							entity_set_float(para_ent[id], EV_FL_frame, 0.0)											
							entity_set_int(para_ent[id], EV_INT_sequence, SEQ_IDLE)
						}
					}
				}
			}
		}
	}
	else if( !( get_entity_flags(id) & FL_ONGROUND ) )	//let go of use in mid air
	{
		if( para_ent[id] > 0 )
		{
			remove_entity(para_ent[id])
			para_ent[id] = 0
		}
	}

	//if they have parachute and are on the ground
	if( (para_ent[id] > 0 ) && ( get_entity_flags(id) & FL_ONGROUND ) )
	{
		if( entity_get_int(para_ent[id], EV_INT_sequence) != SEQ_DETACH )
		{
			entity_set_float(para_ent[id], EV_FL_frame, 0.0)								
			entity_set_int(para_ent[id], EV_INT_sequence, SEQ_DETACH)		
		}
		
		//if it reached the end of the animation, then remove it
		if( entity_get_float(para_ent[id], EV_FL_frame) < 0.0 || entity_get_float(para_ent[id], EV_FL_frame) > 254.0 )
		{
			remove_entity(para_ent[id])
			para_ent[id] = 0
		}
	}		
	
	return PLUGIN_CONTINUE
}

stock bool:is_lifted(id)
{
	new dummy

	if((entity_get_int( id, EV_INT_solid ) == SOLID_NOT) && (get_user_weapon( id, dummy, dummy) == WEAPON_KNIFE))
		return true

	return false
}

stock ns_get_level(id)
{
	return floatround(floatsqroot(ns_get_exp(id) / 25 + 2.21) - 1) 
}