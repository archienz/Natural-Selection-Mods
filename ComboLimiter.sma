/* 
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
*
* Combo Limiter limits upgrades in various ways
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
* Title : Combo Limiter
* 
* Author : KCE
* 
* Special Thanks & Credit :
*		CombalanceXX 1.3 by Joe "Lord Skitch" Jackson - Time blocking
*		Blocker 1.3 by -j00- Clan - Proportion blocking
*		ClassCTRL 1.3 by Darkness - Other checks and misc.
*		Combat Limiter 1.1b by ZeroX4 - Other checks and misc.
*
* Version : 1.7
* 
* Cvars (name/default value/description) : 
*		amx_combolimiter (1) - Enable/Disable limiter
*
*		climit_*_* 
*
*		I.E. : limit_gorge_max, limit_gorge_min,...
*
*		Where the first * is either - gorge, lerk, fade, onos, focusfade, jp, ha, hmg, gl, sg
*
*		And the second * is either -  max, min, prop, wait, lvl, frags - where:
*			max - Maximum people allowed to get that upgrade
*			min - Minimum amount of people on the opposite team required to get that upgrade
*			prop - The ratio of marines/aliens required to get that upgrade
*					Example: For 1:3 Onos to Marine ratio, 1 onos for every 3 marines...
*							limit_onos_ratio 3
*			wait - Time in minutes before upgrade is unblocked
*			lvl - Minimum level required to get that upgrade
*			frags - Minimum amount of kills required to get that upgrade
*
*		Also features Focus Fades! (idea from headcrab)
*		Set to -1 to disable that check
*		If prop is set -1 or 0 it'll disable that check (doesn't make sense if you need 0 ratio of people to go gorge)
*		If min is set -1 or 0 it'll disable that check (doesn't make sense if you need 0 people to go gorge)
*		
*		***Setting max to 0 will disable that upgrade***
*		
*		SEE DEFINES BELOW TO SET DEFAULT SETTINGS
*
* Cmds : 
*		None
*
* History :
*		v1.0	- 	Initial Release
*		v1.1	-	Updated for Bots
*		v1.2	-	Major revision, now actually works
*		v1.3	-	Fixed some more things
*		v1.4	- 	Now works with latest version of amxmodx (1.55/1.60)
*		v1.4.1	- 	Fixed onos bug
*		v1.5	-	Updated
*		v1.6	-	Fixed HMG cvar typos
*		v1.7	-	Disabled on classic NS
*				-	Changed cvars to defines
				-	Added limiters for Shotgun
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*/

#include < amxmodx >
#include < engine >
#include < ns >

///////////////
//Begin Editing

//*** MAKE SURE THE NUMBERS ARE IN QUOTES!! ***

#define GORGE_MAX  "-1"
#define LERK_MAX   "-1"
#define FADE_MAX   "-1"
#define ONOS_MAX   "-1"

#define GORGE_MIN "-1"
#define LERK_MIN   "-1"
#define FADE_MIN   "-1"
#define ONOS_MIN   "-1"

#define GORGE_PROP "-1"
#define LERK_PROP  "-1"
#define FADE_PROP  "-1"
#define ONOS_PROP  "-1"

#define GORGE_WAIT "-1"
#define LERK_WAIT  "-1"
#define FADE_WAIT  "-1"
#define ONOS_WAIT  "-1"

#define GORGE_LVL "-1"
#define LERK_LVL  "-1"
#define FADE_LVL  "-1"
#define ONOS_LVL  "-1"

#define GORGE_FRAGS "-1"
#define LERK_FRAGS  "-1"
#define FADE_FRAGS  "-1"
#define ONOS_FRAGS  "-1"

#define FOCUSFADE_TEAM   "-1"
#define FOCUSFADE_MAX    "-1"
#define FOCUSFADE_MIN    "-1"
#define FOCUSFADE_PROP   "-1"
#define FOCUSFADE_WAIT   "-1"
#define FOCUSFADE_LVL    "-1"
#define FOCUSFADE_FRAGS  "-1" 

#define JP_MAX 	 "-1"
#define HA_MAX 	 "-1"
#define HMG_MAX  "-1"
#define GL_MAX 	"-1"
#define SG_MAX 	"-1"

#define JP_MIN 	"-1"
#define HA_MIN 	"-1"
#define HMG_MIN "-1"
#define GL_MIN 	"-1"
#define SG_MIN 	"-1"

#define JP_PROP	 "-1"
#define HA_PROP	 "-1"
#define HMG_PROP "-1"
#define GL_PROP  "-1"
#define SG_PROP  "-1"

#define JP_WAIT  "-1"
#define HA_WAIT	 "-1"
#define HMG_WAIT "-1"
#define GL_WAIT	 "-1"
#define SG_WAIT	 "-1"

#define JP_LVL 	"-1"
#define HA_LVL 	"-1"
#define HMG_LVL "-1"
#define GL_LVL 	"-1"
#define SG_LVL 	"-1"

#define JP_FRAGS  "-1"
#define HA_FRAGS  "-1"
#define HMG_FRAGS "-1"
#define GL_FRAGS  "-1"
#define SG_FRAGS  "-1"

//End editing
/////////////

//Do not edit these
///////////////////////////

#define CHECK_DELAY	0.25

#define IMPULSE_FOCUS	111
#define IMPULSE_GORGE	114
#define IMPULSE_LERK	115
#define IMPULSE_FADE	116
#define IMPULSE_ONOS	117

#define IMPULSE_JP		39
#define	IMPULSE_HA		38
#define IMPULSE_SG		64
#define IMPULSE_HMG		65
#define IMPULSE_GL		66

new Float: g_startTime;
new g_maxPlayers;
new g_GestatingToGorge[5], g_GestatingToLerk[5], g_GestatingToFade[5], g_GestatingToOnos[5], g_GestatingToFocusFade[5];

public plugin_init()
{
	register_plugin( "Combo Limiter", "1.7", "KCE" );
	
	if( !ns_is_combat() )	
		return PLUGIN_CONTINUE;
	
	register_cvar( "amx_combolimit", "1" );

	//ALIENS
	register_cvar( "climit_gorge_max" , GORGE_MAX );
	register_cvar( "climit_lerk_max" , LERK_MAX );
	register_cvar( "climit_fade_max" , FADE_MAX );
	register_cvar( "climit_onos_max" , ONOS_MAX );

	register_cvar( "climit_gorge_min" , GORGE_MIN );
	register_cvar( "climit_lerk_min" , LERK_MIN );
	register_cvar( "climit_fade_min" , FADE_MIN );
	register_cvar( "climit_onos_min" , ONOS_MIN );

	register_cvar( "climit_gorge_prop" , GORGE_PROP );
	register_cvar( "climit_lerk_prop" , LERK_PROP );
	register_cvar( "climit_fade_prop" , FADE_PROP );
	register_cvar( "climit_onos_prop" , ONOS_PROP );

	register_cvar( "climit_gorge_wait" , GORGE_WAIT );
	register_cvar( "climit_lerk_wait" , LERK_WAIT );
	register_cvar( "climit_fade_wait" , FADE_WAIT );
	register_cvar( "climit_onos_wait" , ONOS_WAIT );

	register_cvar( "climit_gorge_lvl" , GORGE_LVL );
	register_cvar( "climit_lerk_lvl" , LERK_LVL );
	register_cvar( "climit_fade_lvl" , FADE_LVL );
	register_cvar( "climit_onos_lvl" , ONOS_LVL );

	register_cvar( "climit_gorge_frags" , GORGE_FRAGS );
	register_cvar( "climit_lerk_frags" , LERK_FRAGS );
	register_cvar( "climit_fade_frags" , FADE_FRAGS );
	register_cvar( "climit_onos_frags" , ONOS_FRAGS );

	//ALIENS - Focus Fade
	register_cvar( "climit_focusfade_max" , FOCUSFADE_MAX );
	register_cvar( "climit_focusfade_min" , FOCUSFADE_MIN );
	register_cvar( "climit_focusfade_prop" , FOCUSFADE_PROP );
	register_cvar( "climit_focusfade_wait" , FOCUSFADE_WAIT );
	register_cvar( "climit_focusfade_lvl" , FOCUSFADE_LVL );
	register_cvar( "climit_focusfade_frags" , FOCUSFADE_FRAGS );
	
	//MARINES
	register_cvar( "climit_jp_max" , JP_MAX );
	register_cvar( "climit_ha_max" , HA_MAX );
	register_cvar( "climit_hmg_max" , HMG_MAX );
	register_cvar( "climit_gl_max" , GL_MAX );
	register_cvar( "climit_sg_max" , SG_MAX );

	register_cvar( "climit_jp_min" , JP_MIN );
	register_cvar( "climit_ha_min" , HA_MIN );
	register_cvar( "climit_hmg_min" , HMG_MIN );
	register_cvar( "climit_gl_min" , GL_MIN );
	register_cvar( "climit_sg_min" , SG_MIN );

	register_cvar( "climit_jp_prop" , JP_PROP );
	register_cvar( "climit_ha_prop" , HA_PROP );
	register_cvar( "climit_hmg_prop" , HMG_PROP );
	register_cvar( "climit_gl_prop" , GL_PROP );
	register_cvar( "climit_sg_prop" , SG_PROP );

	register_cvar( "climit_jp_wait" , JP_WAIT );
	register_cvar( "climit_ha_wait" , HA_WAIT );
	register_cvar( "climit_hmg_wait" , HMG_WAIT );
	register_cvar( "climit_gl_wait" , GL_WAIT );
	register_cvar( "climit_sg_wait" , SG_WAIT );

	register_cvar( "climit_jp_lvl" , JP_LVL );
	register_cvar( "climit_ha_lvl" , HA_LVL );
	register_cvar( "climit_hmg_lvl" , HMG_LVL );
	register_cvar( "climit_gl_lvl" , GL_LVL );
	register_cvar( "climit_sg_lvl" , SG_LVL );

	register_cvar( "climit_jp_frags" , JP_FRAGS );
	register_cvar( "climit_ha_frags" , HA_FRAGS );
	register_cvar( "climit_hmg_frags" , HMG_FRAGS );
	register_cvar( "climit_gl_frags" , GL_FRAGS );
	register_cvar( "climit_sg_frags" , SG_FRAGS );

	register_impulse( IMPULSE_GORGE, "gorgeCheck" );
	register_impulse( IMPULSE_LERK, "lerkCheck" );
	register_impulse( IMPULSE_FADE, "fadeCheck" );
	register_impulse( IMPULSE_ONOS, "onosCheck" );
	
	register_impulse( IMPULSE_JP, "jpCheck" );
	register_impulse( IMPULSE_HA, "haCheck" ); 
	register_impulse( IMPULSE_HMG, "hmgCheck" );
	register_impulse( IMPULSE_GL, "glCheck" );
	register_impulse( IMPULSE_SG, "sgCheck" );
	
	register_impulse( IMPULSE_FOCUS, "focusFadeCheck" );
	
	register_event( "Countdown" , "gameStarting", "a" );
	
	g_maxPlayers = get_maxplayers();
	
	return PLUGIN_CONTINUE;
}

public gameStarting()
{
	g_startTime = get_gametime() + 5.0;
	return PLUGIN_CONTINUE;
}

public gorgeCheck( id )
{
	if ( !get_cvar_num("amx_combolimit" ) )
		return PLUGIN_CONTINUE;
	
	new teamID = entity_get_int(id, EV_INT_team);
	
	new i, g, m;
	for( i = 1; i <= g_maxPlayers; i++ )
	{
		if( !is_user_connected( i ) )
			continue;
			
		new teamI = entity_get_int( i, EV_INT_team );
	
		if( teamI == teamID )
		{
			if ( ns_get_class( i ) == CLASS_GORGE )
			{
				g++;	
			}
		}
	
		if( ( teamI != teamID ) && ( teamI != 0 ) && ( teamI != 6 ) )
		{
			m++;
		}
	}					

	g += g_GestatingToGorge[teamID];
	
	new Float:wait = get_cvar_float( "climit_gorge_wait" );
	if( wait != -1 )
	{
		new Float:minsLeft, Float:secsLeft, Float:timeElapse, Float:startTime2, Float:timeRemain;
		startTime2 = get_gametime();
		
		timeRemain = wait * 60;
	
		timeElapse = startTime2 - g_startTime;
	
		if ( timeElapse < timeRemain )		//not clear
		{
			timeRemain = timeRemain - timeElapse;
			minsLeft = ( timeRemain / 60 );
			secsLeft = ( timeRemain - ( floatround( minsLeft, floatround_floor ) * 60 ) );
			client_print( id, print_chat, "[Combo Limiter] %d minutes %d seconds left until Gorge is unblocked" , floatround ( minsLeft, floatround_floor ), floatround( secsLeft ) );		
			return PLUGIN_HANDLED;
		}
	}

	//If not enough players on the opposing team...
	new least = get_cvar_num( "climit_gorge_min" );
	if( least != -1 && least != 0 )
	{
		if ( m < least )
		{
			client_print( id, print_chat, "[Combo Limiter] %d Marines required to go Gorge" ,least);		
			return PLUGIN_HANDLED;
		}
	}	

	//Require ratio
	new prop = get_cvar_num( "climit_gorge_prop" );
	if( prop != -1 && prop != 0 )
	{
		if ( g >= m/prop )
		{
			client_print( id, print_chat, "[Combo Limiter] 1 Gorge for every %d Marines, you need %d more Marines to go Gorge" , prop, prop - (m%prop));
			return PLUGIN_HANDLED;
		}
	}		

	//If too many players already this class...
	new most = get_cvar_num( "climit_gorge_max" );
	if( most != -1 )
	{
		if ( g >= most )
		{
			client_print( id, print_chat, "[Combo Limiter] Maximum amount of players allowed to go Gorge is %d" ,most);
			return PLUGIN_HANDLED;
		}
	}
	
	//Minimum level required
	new reqlvl = get_cvar_num( "climit_gorge_lvl" );
	if( reqlvl != -1 )
	{
		if( (floatround(floatsqroot(ns_get_exp(id) / 25 + 2.21) - 1)) < reqlvl )
		{
			client_print( id, print_chat, "[Combo Limiter] Level %d is required to go Gorge" ,reqlvl);
			return PLUGIN_HANDLED;
		}
	}
	
	//Certain number of kills required
	new frags = get_cvar_num( "climit_gorge_frags" );
	if( frags != -1 )
	{
		if( get_user_frags( id ) < frags )
		{
			client_print( id, print_chat, "[Combo Limiter] %d kills are required to go Gorge" , frags );
			return PLUGIN_HANDLED;
		}
	}		
	
	g_GestatingToGorge[teamID]++;
	
	new parm[1];
	parm[0] = id;
	set_task(CHECK_DELAY, "checkgorge",_,parm,1);
	
	return PLUGIN_CONTINUE;
}

public checkgorge(parm[1])
{
	new id = parm[0];
	if (ns_get_class(id) == CLASS_GESTATE)		//stil gestating, so keep checking
	{
		set_task(CHECK_DELAY, "checkgorge",_,parm,1);
	}
	else	
	{
		g_GestatingToGorge[entity_get_int( id, EV_INT_team )]--;	
	}	
}

public lerkCheck( id )
{
	if ( !get_cvar_num("amx_combolimit" ) )
		return PLUGIN_CONTINUE;
	
	new teamID = entity_get_int(id, EV_INT_team);
	
	new i, g, m;
	for( i = 1; i <= g_maxPlayers; i++ )
	{
		if( !is_user_connected( i ) )
			continue;
			
		new teamI = entity_get_int( i, EV_INT_team );
	
		if( teamI == teamID )
		{
			if ( ns_get_class( i ) == CLASS_LERK)
			{
				g++;	
			}
		}
	
		if( ( teamI != teamID ) && ( teamI != 0 ) && ( teamI != 6 ) )
		{
			m++;
		}
	}					

	g += g_GestatingToLerk[teamID];
	
	new Float:wait = get_cvar_float( "climit_lerk_wait" );
	if( wait != -1 )
	{
		new Float:minsLeft, Float:secsLeft, Float:timeElapse, Float:startTime2, Float:timeRemain;
		startTime2 = get_gametime();
		
		timeRemain = wait * 60;
	
		timeElapse = startTime2 - g_startTime;
	
		if ( timeElapse < timeRemain )		//not clear
		{
			timeRemain = timeRemain - timeElapse;
			minsLeft = ( timeRemain / 60 );
			secsLeft = ( timeRemain - ( floatround( minsLeft, floatround_floor ) * 60 ) );
			client_print( id, print_chat, "[Combo Limiter] %d minutes %d seconds left until Lerk is unblocked" , floatround ( minsLeft, floatround_floor ), floatround( secsLeft ) );		
			return PLUGIN_HANDLED;
		}
	}

	//If not enough players on the opposing team...
	new least = get_cvar_num( "climit_lerk_min" );
	if( least != -1 && least != 0 )
	{
		if ( m < least )
		{
			client_print( id, print_chat, "[Combo Limiter] %d Marines required to go Lerk" ,least);		
			return PLUGIN_HANDLED;
		}
	}	

	//Require ratio
	new prop = get_cvar_num( "climit_lerk_prop" );
	if( prop != -1 && prop != 0 )
	{
		if ( g >= m/prop )
		{
			client_print( id, print_chat, "[Combo Limiter] 1 Lerk for every %d Marines, you need %d more Marines to go Lerk" , prop, prop - (m%prop));
			return PLUGIN_HANDLED;
		}
	}		

	//If too many players already this class...
	new most = get_cvar_num( "climit_lerk_max" );
	if( most != -1 )
	{
		if ( g >= most )
		{
			client_print( id, print_chat, "[Combo Limiter] Maximum amount of players allowed to go Lerk is %d" ,most);
			return PLUGIN_HANDLED;
		}
	}
	
	//Minimum level required
	new reqlvl = get_cvar_num( "climit_lerk_lvl" );
	if( reqlvl != -1 )
	{
		if( (floatround(floatsqroot(ns_get_exp(id) / 25 + 2.21) - 1)) < reqlvl )
		{
			client_print( id, print_chat, "[Combo Limiter] Level %d is required to go Lerk" ,reqlvl);
			return PLUGIN_HANDLED;
		}
	}
	
	//Certain number of kills required
	new frags = get_cvar_num( "climit_lerk_frags" );
	if( frags != -1 )
	{
		if( get_user_frags( id ) < frags )
		{
			client_print( id, print_chat, "[Combo Limiter] %d kills are required to go Lerk" , frags );
			return PLUGIN_HANDLED;
		}
	}		
	
	g_GestatingToLerk[teamID]++;
	
	new parm[1];
	parm[0] = id;
	set_task(CHECK_DELAY, "checklerk",_,parm,1);
	
	return PLUGIN_CONTINUE;
}

public checklerk(parm[1])
{
	new id = parm[0];
	if (ns_get_class(id) == CLASS_GESTATE)		//stil gestating, so keep checking
	{
		set_task(CHECK_DELAY, "checklerk",_,parm,1);
	}
	else	
	{
		g_GestatingToLerk[entity_get_int( id, EV_INT_team )]--;	
	}	
}

public fadeCheck( id )
{
	if ( !get_cvar_num("amx_combolimit" ) )
		return PLUGIN_CONTINUE;
	
	new teamID = entity_get_int(id, EV_INT_team);
	
	new i, g, m;
	for( i = 1; i <= g_maxPlayers; i++ )
	{
		if( !is_user_connected( i ) )
			continue;
			
		new teamI = entity_get_int( i, EV_INT_team );
	
		if( teamI == teamID )
		{
			if ( ns_get_class( i ) == CLASS_FADE )
			{
				g++;	
			}
		}
	
		if( ( teamI != teamID ) && ( teamI != 0 ) && ( teamI != 6 ) )
		{
			m++;
		}
	}					

	g += g_GestatingToFade[teamID];
	
	new Float:wait = get_cvar_float( "climit_fade_wait" );
	if( wait != -1 )
	{
		new Float:minsLeft, Float:secsLeft, Float:timeElapse, Float:startTime2, Float:timeRemain;
		startTime2 = get_gametime();
		
		timeRemain = wait * 60;
	
		timeElapse = startTime2 - g_startTime;
	
		if ( timeElapse < timeRemain )		//not clear
		{
			timeRemain = timeRemain - timeElapse;
			minsLeft = ( timeRemain / 60 );
			secsLeft = ( timeRemain - ( floatround( minsLeft, floatround_floor ) * 60 ) );
			client_print( id, print_chat, "[Combo Limiter] %d minutes %d seconds left until Fade is unblocked" , floatround ( minsLeft, floatround_floor ), floatround( secsLeft ) );		
			return PLUGIN_HANDLED;
		}
	}

	//If not enough players on the opposing team...
	new least = get_cvar_num( "climit_fade_min" );
	if( least != -1 && least != 0 )
	{
		if ( m < least )
		{
			client_print( id, print_chat, "[Combo Limiter] %d Marines required to go Fade" ,least);		
			return PLUGIN_HANDLED;
		}
	}	

	//Require ratio
	new prop = get_cvar_num( "climit_fade_prop" );
	if( prop != -1 && prop != 0 )
	{
		if ( g >= m/prop )
		{
			client_print( id, print_chat, "[Combo Limiter] 1 Fade for every %d Marines, you need %d more Marines to go Fade" , prop, prop - (m%prop));
			return PLUGIN_HANDLED;
		}
	}		

	//If too many players already this class...
	new most = get_cvar_num( "climit_fade_max" );
	if( most != -1 )
	{
		if ( g >= most )
		{
			client_print( id, print_chat, "[Combo Limiter] Maximum amount of players allowed to go Fade is %d" ,most);
			return PLUGIN_HANDLED;
		}
	}
	
	//Minimum level required
	new reqlvl = get_cvar_num( "climit_fade_lvl" );
	if( reqlvl != -1 )
	{
		if( (floatround(floatsqroot(ns_get_exp(id) / 25 + 2.21) - 1)) < reqlvl )
		{
			client_print( id, print_chat, "[Combo Limiter] Level %d is required to go Fade" ,reqlvl);
			return PLUGIN_HANDLED;
		}
	}
	
	//Certain number of kills required
	new frags = get_cvar_num( "climit_fade_frags" );
	if( frags != -1 )
	{
		if( get_user_frags( id ) < frags )
		{
			client_print( id, print_chat, "[Combo Limiter] %d kills are required to go Fade" , frags );
			return PLUGIN_HANDLED;
		}
	}		
	
	g_GestatingToFade[teamID]++;
	
	new parm[1];
	parm[0] = id;
	set_task(CHECK_DELAY, "checkfade",_,parm,1);
	
	return PLUGIN_CONTINUE;
}

public checkfade(parm[1])
{
	new id = parm[0];
	if (ns_get_class(id) == CLASS_GESTATE)		//stil gestating, so keep checking
	{
		set_task(CHECK_DELAY, "checkfade",_,parm,1);
	}
	else 	
	{
		g_GestatingToFade[entity_get_int( id, EV_INT_team )]--;	
	}	
}

public onosCheck( id )
{
	if ( !get_cvar_num("amx_combolimit" ) )
		return PLUGIN_CONTINUE;
	
	new teamID = entity_get_int(id, EV_INT_team);
	
	new i, g, m;
	for( i = 1; i <= g_maxPlayers; i++ )
	{
		if( !is_user_connected( i ) )
			continue;
			
		new teamI = entity_get_int( i, EV_INT_team );
	
		if( teamI == teamID )
		{
			if ( ns_get_class( i ) == CLASS_ONOS )
			{
				g++;	
			}
		}
	
		if( ( teamI != teamID ) && ( teamI != 0 ) && ( teamI != 6 ) )
		{
			m++;
		}
	}					

	g += g_GestatingToOnos[teamID];
	
	new Float:wait = get_cvar_float( "climit_onos_wait" );
	if( wait != -1 )
	{
		new Float:minsLeft, Float:secsLeft, Float:timeElapse, Float:startTime2, Float:timeRemain;
		startTime2 = get_gametime();
		
		timeRemain = wait * 60;
	
		timeElapse = startTime2 - g_startTime;
	
		if ( timeElapse < timeRemain )		//not clear
		{
			timeRemain = timeRemain - timeElapse;
			minsLeft = ( timeRemain / 60 );
			secsLeft = ( timeRemain - ( floatround( minsLeft, floatround_floor ) * 60 ) );
			client_print( id, print_chat, "[Combo Limiter] %d minutes %d seconds left until Onos is unblocked" , floatround ( minsLeft, floatround_floor ), floatround( secsLeft ) );		
			return PLUGIN_HANDLED;
		}
	}

	//If not enough players on the opposing team...
	new least = get_cvar_num( "climit_onos_min" );
	if( least != -1 && least != 0 )
	{
		if ( m < least )
		{
			client_print( id, print_chat, "[Combo Limiter] %d Marines required to go Onos" ,least);		
			return PLUGIN_HANDLED;
		}
	}	

	//Require ratio
	new prop = get_cvar_num( "climit_onos_prop" );
	if( prop != -1 && prop != 0 )
	{
		if ( g >= m/prop )
		{
			client_print( id, print_chat, "[Combo Limiter] 1 Onos for every %d Marines, you need %d more Marines to go Onos" , prop, prop - (m%prop));
			return PLUGIN_HANDLED;
		}
	}		

	//If too many players already this class...
	new most = get_cvar_num( "climit_onos_max" );
	if( most != -1 )
	{
		if ( g >= most )
		{
			client_print( id, print_chat, "[Combo Limiter] Maximum amount of players allowed to go Onos is %d" ,most);
			return PLUGIN_HANDLED;
		}
	}
	
	//Minimum level required
	new reqlvl = get_cvar_num( "climit_onos_lvl" );
	if( reqlvl != -1 )
	{
		if( (floatround(floatsqroot(ns_get_exp(id) / 25 + 2.21) - 1)) < reqlvl )
		{
			client_print( id, print_chat, "[Combo Limiter] Level %d is required to go Onos" ,reqlvl);
			return PLUGIN_HANDLED;
		}
	}
	
	//Certain number of kills required
	new frags = get_cvar_num( "climit_onos_frags" );
	if( frags != -1 )
	{
		if( get_user_frags( id ) < frags )
		{
			client_print( id, print_chat, "[Combo Limiter] %d kills are required to go Onos" , frags );
			return PLUGIN_HANDLED;
		}
	}		
	
	g_GestatingToOnos[teamID]++;
	
	new parm[1];
	parm[0] = id;
	set_task(CHECK_DELAY, "checkonos",_,parm,1);
	
	return PLUGIN_CONTINUE;
}

public checkonos(parm[1])
{
	new id = parm[0];
	if (ns_get_class(id) == CLASS_GESTATE)		//stil gestating, so keep checking
	{
		set_task(CHECK_DELAY, "checkonos",_,parm,1);
	}
	else 	
	{
		g_GestatingToOnos[entity_get_int( id, EV_INT_team )]--;	
	}	
}

public focusFadeCheck( id )
{
	if ( !get_cvar_num( "amx_combolimit" ) || (ns_get_class(id) != CLASS_FADE) )
		return PLUGIN_CONTINUE;
		
	new teamID = entity_get_int(id, EV_INT_team);
	
	new i, g, m;
	for( i = 1; i <= g_maxPlayers; i++ )
	{
		if( !is_user_connected( i ) )
			continue;
			
		new teamI = entity_get_int( i, EV_INT_team );
	
		if( teamI == teamID )
		{
			if ( ( ns_get_class( i ) == CLASS_FADE ) && ns_get_mask( i, MASK_FOCUS ) )
			{
				g++;	
			}
		}
	
		if( ( teamI != teamID ) && ( teamI != 0 ) && ( teamI != 6 ) )
		{
			m++;
		}
	}					

	g += g_GestatingToFocusFade[teamID];
	
	new Float:wait = get_cvar_float( "climit_focusfade_wait" );
	if( wait != -1 )
	{
		new Float:minsLeft, Float:secsLeft, Float:timeElapse, Float:startTime2, Float:timeRemain;
		startTime2 = get_gametime();
		
		timeRemain = wait * 60;
	
		timeElapse = startTime2 - g_startTime;
	
		if ( timeElapse < timeRemain )		//not clear
		{
			timeRemain = timeRemain - timeElapse;
			minsLeft = ( timeRemain / 60 );
			secsLeft = ( timeRemain - ( floatround( minsLeft, floatround_floor ) * 60 ) );
			client_print( id, print_chat, "[Combo Limiter] %d minutes %d seconds left until Focus Fade is unblocked" , floatround ( minsLeft, floatround_floor ), floatround( secsLeft ) );		
			return PLUGIN_HANDLED;
		}
	}

	//Certain number of kills required
	new frags = get_cvar_num( "climit_focusfade_frags" );
	if( frags != -1 )
	{
		if( get_user_frags( id ) < frags )
		{
			client_print( id, print_chat, "[Combo Limiter] %d kills are required to go Focus Fade" , frags );
			return PLUGIN_HANDLED;
		}
	}

	//Minimum level required
	new reqlvl = get_cvar_num( "climit_focusfade_lvl" );
	if( reqlvl != -1 )
	{
		if( (floatround(floatsqroot(ns_get_exp(id) / 25 + 2.21) - 1)) < reqlvl )
		{
			client_print( id, print_chat, "[Combo Limiter] Level %d is required to go Focus Fade" , reqlvl );
			return PLUGIN_HANDLED;
		}
	}

	//If not enough players on the opposing team...
	new least = get_cvar_num( "climit_focusfade_min" );
	if( least != -1 && least != 0 )
	{
		if ( m < least )
		{
			client_print( id, print_chat, "[Combo Limiter] %d Marines required to go Focus Fade" , least );		
			return PLUGIN_HANDLED;
		}
	}	

	//Require ratio
	new prop = get_cvar_num( "climit_focusfade_prop" );
	if( ( prop != -1 ) && ( prop != 0) )
	{
		if ( g >= m/prop )
		{
			client_print( id, print_chat, "[Combo Limiter] 1 Focus Fade for every %d Marines, you need %d more Marines to go Focus Fade" , prop, prop - (m%prop) );
			return PLUGIN_HANDLED;
		}
	}

	//If too many players already this class...
	new most = get_cvar_num( "climit_focusfade_max" );
	if( most != -1 )
	{
		if ( g >= most )
		{
			client_print( id, print_chat, "[Combo Limiter] Maximum amount of players allowed to go Focus Fade is %d" , most);
			return PLUGIN_HANDLED;
		}
		else
		{
			client_print( id, print_chat, "[Combo Limiter] %d Focus Fades remaining" , most - (g+1));
		}
	}	

	g_GestatingToFocusFade[teamID]++;
	new parm[1];
	parm[0] = id;
	set_task(CHECK_DELAY, "checkfocusfades",_,parm,1);
	
	return PLUGIN_CONTINUE;
}

public checkfocusfades(parm[1])
{
	new id = parm[0];
	if (ns_get_class(id) == CLASS_GESTATE)		//stil gestating, so keep checking
	{
		set_task(CHECK_DELAY, "checkfocusfades",_,parm,1);
	}
	else 	
	{
		g_GestatingToFocusFade[entity_get_int( id, EV_INT_team )]--;	
	}	
}

public jpCheck( id )
{
	if ( !get_cvar_num( "amx_combolimit" ) )
		return PLUGIN_CONTINUE;
	
	new teamID = entity_get_int(id, EV_INT_team);
	
	new i, g, m;
	for( i = 1; i <= g_maxPlayers; i++ )
	{
		if( !is_user_connected( i ) )
			continue;
			
		new teamI = entity_get_int( i, EV_INT_team );
	
		if( teamI == teamID )
		{
			if ( ns_get_class( i ) == CLASS_JETPACK )
			{
				g++;	
			}
		}
	
		if( ( teamI != teamID ) && ( teamI != 0 ) && ( teamI != 6 ) )
		{
			m++;
		}
	}					

	new Float:wait = get_cvar_float( "climit_jp_wait" );
	if( wait != -1 )
	{
		new Float:minsLeft, Float:secsLeft, Float:timeElapse, Float:startTime2, Float:timeRemain;
		startTime2 = get_gametime();
		
		timeRemain = wait * 60;
	
		timeElapse = startTime2 - g_startTime;
	
		if ( timeElapse < timeRemain )		//not clear
		{
			timeRemain = timeRemain - timeElapse;
			minsLeft = ( timeRemain / 60 );
			secsLeft = ( timeRemain - ( floatround( minsLeft, floatround_floor ) * 60 ) );
			client_print( id, print_chat, "[Combo Limiter] %d minutes %d seconds left until Jetpacks are unblocked" , floatround ( minsLeft, floatround_floor ), floatround( secsLeft ) );		
			return PLUGIN_HANDLED;
		}
	}

	//Certain number of kills required
	new frags = get_cvar_num( "climit_jp_frags" );
	if( frags != -1 )
	{
		if( get_user_frags( id ) < frags )
		{
			client_print( id, print_chat, "[Combo Limiter] %d kills are required to go Jetpacker" , frags );
			return PLUGIN_HANDLED;
		}
	}

	//Minimum level required
	new reqlvl = get_cvar_num( "climit_jp_lvl" );
	if( reqlvl != -1 )
	{
		if( (floatround(floatsqroot(ns_get_exp(id) / 25 + 2.21) - 1)) < reqlvl )
		{
			client_print( id, print_chat, "[Combo Limiter] Level %d is required to go Jetpacker" , reqlvl );
			return PLUGIN_HANDLED;
		}
	}

	//If not enough players on the opposing team...
	new least = get_cvar_num( "climit_jp_min" );
	if( least != -1 && least != 0 )
	{
		if ( m < least )
		{
			client_print( id, print_chat, "[Combo Limiter] %d Aliens required to go Jetpacker" , least );		
			return PLUGIN_HANDLED;
		}
	}	

	//Require ratio
	new prop = get_cvar_num( "climit_jp_prop" );
	if( ( prop != -1 ) && ( prop != 0) )
	{
		if ( g >= m/prop )
		{
			client_print( id, print_chat, "[Combo Limiter] 1 Jetpacker for every %d Aliens, you need %d more Aliens to get a Jetpack" , prop, prop - (m%prop) );
			return PLUGIN_HANDLED;
		}
	}

	//If too many players already this class...
	new most = get_cvar_num( "climit_jp_max" );
	if( most != -1 )
	{
		if ( g >= most )
		{
			client_print( id, print_chat, "[Combo Limiter] Maximum amount of players allowed to get Jetpacks is %d" , most);
			return PLUGIN_HANDLED;
		}
		else
		{
			client_print( id, print_chat, "[Combo Limiter] %d Jetpackers remaining" , most - (g+1));
		}
	}
	
	return PLUGIN_CONTINUE;
}

public haCheck( id )
{
	if ( !get_cvar_num( "amx_combolimit" ) )
		return PLUGIN_CONTINUE;

	new teamID = entity_get_int(id, EV_INT_team);
	
	new i, g, m;
	for( i = 1; i <= g_maxPlayers; i++ )
	{
		if( !is_user_connected( i ) )
			continue;
			
		new teamI = entity_get_int( i, EV_INT_team );
	
		if( teamI == teamID )
		{
			if ( ns_get_class( i ) == CLASS_HEAVY )
			{
				g++;	
			}
		}
	
		if( ( teamI != teamID ) && ( teamI != 0 ) && ( teamI != 6 ) )
		{
			m++;
		}
	}					

	new Float:wait = get_cvar_float( "climit_ha_wait" );
	if( wait != -1 )
	{
		new Float:minsLeft, Float:secsLeft, Float:timeElapse, Float:startTime2, Float:timeRemain;
		startTime2 = get_gametime();
		
		timeRemain = wait * 60;
	
		timeElapse = startTime2 - g_startTime;
	
		if ( timeElapse < timeRemain )		//not clear
		{
			timeRemain = timeRemain - timeElapse;
			minsLeft = ( timeRemain / 60 );
			secsLeft = ( timeRemain - ( floatround( minsLeft, floatround_floor ) * 60 ) );
			client_print( id, print_chat, "[Combo Limiter] %d minutes %d seconds left until Heavy Armor is unblocked" , floatround ( minsLeft, floatround_floor ), floatround( secsLeft ) );		
			return PLUGIN_HANDLED;
		}
	}

	//Certain number of kills required
	new frags = get_cvar_num( "climit_ha_frags" );
	if( frags != -1 )
	{
		if( get_user_frags( id ) < frags )
		{
			client_print( id, print_chat, "[Combo Limiter] %d kills are required to get Heavy Armor" , frags );
			return PLUGIN_HANDLED;
		}
	}

	//Minimum level required
	new reqlvl = get_cvar_num( "climit_ha_lvl" );
	if( reqlvl != -1 )
	{
		if( (floatround(floatsqroot(ns_get_exp(id) / 25 + 2.21) - 1)) < reqlvl )
		{
			client_print( id, print_chat, "[Combo Limiter] Level %d is required to get Heavy Armor" , reqlvl );
			return PLUGIN_HANDLED;
		}
	}

	//If not enough players on the opposing team...
	new least = get_cvar_num( "climit_ha_min" );
	if( least != -1 && least != 0 )
	{
		if ( m < least )
		{
			client_print( id, print_chat, "[Combo Limiter] %d Aliens required to get Heavy Armor" , least );		
			return PLUGIN_HANDLED;
		}
	}	

	//Require ratio
	new prop = get_cvar_num( "climit_ha_prop" );
	if( ( prop != -1 ) && ( prop != 0) )
	{
		if ( g >= m/prop )
		{
			client_print( id, print_chat, "[Combo Limiter] 1 Heavy Armor for every %d Aliens, you need %d more Aliens to get Heavy Armor" , prop, prop - (m%prop) );
			return PLUGIN_HANDLED;
		}
	}

	//If too many players already this class...
	new most = get_cvar_num( "climit_ha_max" );
	if( most != -1 )
	{
		if ( g >= most )
		{
			client_print( id, print_chat, "[Combo Limiter] Maximum amount of players allowed to get Heavy Armor is %d" , most);
			return PLUGIN_HANDLED;
		}
		else
		{
			client_print( id, print_chat, "[Combo Limiter] %d Heavy Armor remaining" , most - (g+1));
		}			
	}
	
	return PLUGIN_CONTINUE;
}

public hmgCheck( id )
{
	if ( !get_cvar_num( "amx_combolimit" ) )
		return PLUGIN_CONTINUE;
	
	new teamID = entity_get_int(id, EV_INT_team);
	
	new i, g, m;
	for( i = 1; i <= g_maxPlayers; i++ )
	{
		if( !is_user_connected( i ) )
			continue;
			
		new teamI = entity_get_int( i, EV_INT_team );
	
		if( teamI == teamID )
		{
			if ( ns_has_weapon(i,WEAPON_HMG) )
			{
				g++;	
			}
		}
	
		if( ( teamI != teamID ) && ( teamI != 0 ) && ( teamI != 6 ) )
		{
			m++;
		}
	}					

	new Float:wait = get_cvar_float( "climit_hmg_wait" );
	if( wait != -1 )
	{
		new Float:minsLeft, Float:secsLeft, Float:timeElapse, Float:startTime2, Float:timeRemain;
		startTime2 = get_gametime();
		
		timeRemain = wait * 60;
	
		timeElapse = startTime2 - g_startTime;
	
		if ( timeElapse < timeRemain )		//not clear
		{
			timeRemain = timeRemain - timeElapse;
			minsLeft = ( timeRemain / 60 );
			secsLeft = ( timeRemain - ( floatround( minsLeft, floatround_floor ) * 60 ) );
			client_print( id, print_chat, "[Combo Limiter] %d minutes %d seconds left until HMGs are unblocked" , floatround ( minsLeft, floatround_floor ), floatround( secsLeft ) );		
			return PLUGIN_HANDLED;
		}
	}

	//Certain number of kills required
	new frags = get_cvar_num( "climit_hmg_frags" );
	if( frags != -1 )
	{
		if( get_user_frags( id ) < frags )
		{
			client_print( id, print_chat, "[Combo Limiter] %d kills are required to get HMGs" , frags );
			return PLUGIN_HANDLED;
		}
	}

	//Minimum level required
	new reqlvl = get_cvar_num( "climit_hmg_lvl" );
	if( reqlvl != -1 )
	{
		if( (floatround(floatsqroot(ns_get_exp(id) / 25 + 2.21) - 1)) < reqlvl )
		{
			client_print( id, print_chat, "[Combo Limiter] Level %d is required to get HMGs" , reqlvl );
			return PLUGIN_HANDLED;
		}
	}

	//If not enough players on the opposing team...
	new least = get_cvar_num( "climit_hmg_min" );
	if( least != -1 && least != 0 )
	{
		if ( m < least )
		{
			client_print( id, print_chat, "[Combo Limiter] %d Aliens required to get HMGs" , least );		
			return PLUGIN_HANDLED;
		}
	}	

	//Require ratio
	new prop = get_cvar_num( "climit_hmg_prop" );
	if( ( prop != -1 ) && ( prop != 0) )
	{
		if ( g >= m/prop )
		{
			client_print( id, print_chat, "[Combo Limiter] 1 HMG for every %d Aliens, you need %d more Aliens to get an HMG" , prop, prop - (m%prop) );
			return PLUGIN_HANDLED;
		}
	}

	//If too many players already this class...
	new most = get_cvar_num( "climit_hmg_max" );
	if( most != -1 )
	{
		if ( g >= most )
		{
			client_print( id, print_chat, "[Combo Limiter] Maximum amount of players allowed to get HMGs is %d" , most);
			return PLUGIN_HANDLED;
		}
		else
		{
			client_print( id, print_chat, "[Combo Limiter] %d HMGs remaining" , most - (g+1));
		}			
	}
	
	return PLUGIN_CONTINUE;
}

public glCheck( id )
{
	if ( !get_cvar_num( "amx_combolimit" ) )
		return PLUGIN_CONTINUE;

	new teamID = entity_get_int(id, EV_INT_team);
	
	new i, g, m;
	for( i = 1; i <= g_maxPlayers; i++ )
	{
		if( !is_user_connected( i ) )
			continue;
			
		new teamI = entity_get_int( i, EV_INT_team );
	
		if( teamI == teamID )
		{
			if ( ns_has_weapon(i,WEAPON_GRENADE_GUN) )
			{
				g++;	
			}
		}
	
		if( ( teamI != teamID ) && ( teamI != 0 ) && ( teamI != 6 ) )
		{
			m++;
		}
	}					

	new Float:wait = get_cvar_float( "climit_gl_wait" );
	if( wait != -1 )
	{
		new Float:minsLeft, Float:secsLeft, Float:timeElapse, Float:startTime2, Float:timeRemain;
		startTime2 = get_gametime();
		
		timeRemain = wait * 60;
	
		timeElapse = startTime2 - g_startTime;
	
		if ( timeElapse < timeRemain )		//not clear
		{
			timeRemain = timeRemain - timeElapse;
			minsLeft = ( timeRemain / 60 );
			secsLeft = ( timeRemain - ( floatround( minsLeft, floatround_floor ) * 60 ) );
			client_print( id, print_chat, "[Combo Limiter] %d minutes %d seconds left until GLs are unblocked" , floatround ( minsLeft, floatround_floor ), floatround( secsLeft ) );		
			return PLUGIN_HANDLED;
		}
	}

	//Certain number of kills required
	new frags = get_cvar_num( "climit_gl_frags" );
	if( frags != -1 )
	{
		if( get_user_frags( id ) < frags )
		{
			client_print( id, print_chat, "[Combo Limiter] %d kills are required to get GLs" , frags );
			return PLUGIN_HANDLED;
		}
	}

	//Minimum level required
	new reqlvl = get_cvar_num( "climit_gl_lvl" );
	if( reqlvl != -1 )
	{
		if( (floatround(floatsqroot(ns_get_exp(id) / 25 + 2.21) - 1)) < reqlvl )
		{
			client_print( id, print_chat, "[Combo Limiter] Level %d is required to get GLs" , reqlvl );
			return PLUGIN_HANDLED;
		}
	}

	//If not enough players on the opposing team...
	new least = get_cvar_num( "climit_gl_min" );
	if( least != -1 && least != 0 )
	{
		if ( m < least )
		{
			client_print( id, print_chat, "[Combo Limiter] %d Aliens required to get GLs" , least );		
			return PLUGIN_HANDLED;
		}
	}	

	//Require ratio
	new prop = get_cvar_num( "climit_gl_prop" );
	if( ( prop != -1 ) && ( prop != 0) )
	{
		if ( g >= m/prop )
		{
			client_print( id,print_chat,"1 GL for every %d Aliens, you need %d more Aliens to get a GL" , prop, prop - (m%prop) );
			return PLUGIN_HANDLED;
		}
	}

	//If too many players already this class...
	new most = get_cvar_num( "climit_gl_max" );
	if( most != -1 )
	{
		if ( g >= most )
		{
			client_print( id,print_chat,"Maximum amount of players allowed to get GLs is %d" , most);
			return PLUGIN_HANDLED;
		}
		else
		{
			client_print( id, print_chat, "[Combo Limiter] %d GLs remaining" , most - (g+1));
		}			
	}
	
	return PLUGIN_CONTINUE;
}

public sgCheck( id )
{
	if ( !get_cvar_num( "amx_combolimit" ) )
		return PLUGIN_CONTINUE;

	new teamID = entity_get_int(id, EV_INT_team);
	
	new i, g, m;
	for( i = 1; i <= g_maxPlayers; i++ )
	{
		if( !is_user_connected( i ) )
			continue;
			
		new teamI = entity_get_int( i, EV_INT_team );
	
		if( teamI == teamID )
		{
			if ( ns_has_weapon(i,WEAPON_SHOTGUN) )
			{
				g++;	
			}
		}
	
		if( ( teamI != teamID ) && ( teamI != 0 ) && ( teamI != 6 ) )
		{
			m++;
		}
	}					

	new Float:wait = get_cvar_float( "climit_sg_wait" );
	if( wait != -1 )
	{
		new Float:minsLeft, Float:secsLeft, Float:timeElapse, Float:startTime2, Float:timeRemain;
		startTime2 = get_gametime();
		
		timeRemain = wait * 60;
	
		timeElapse = startTime2 - g_startTime;
	
		if ( timeElapse < timeRemain )		//not clear
		{
			timeRemain = timeRemain - timeElapse;
			minsLeft = ( timeRemain / 60 );
			secsLeft = ( timeRemain - ( floatround( minsLeft, floatround_floor ) * 60 ) );
			client_print( id, print_chat, "[Combo Limiter] %d minutes %d seconds left until Shotguns are unblocked" , floatround ( minsLeft, floatround_floor ), floatround( secsLeft ) );		
			return PLUGIN_HANDLED;
		}
	}

	//Certain number of kills required
	new frags = get_cvar_num( "climit_sg_frags" );
	if( frags != -1 )
	{
		if( get_user_frags( id ) < frags )
		{
			client_print( id, print_chat, "[Combo Limiter] %d kills are required to get Shotguns" , frags );
			return PLUGIN_HANDLED;
		}
	}

	//Minimum level required
	new reqlvl = get_cvar_num( "climit_sg_lvl" );
	if( reqlvl != -1 )
	{
		if( (floatround(floatsqroot(ns_get_exp(id) / 25 + 2.21) - 1)) < reqlvl )
		{
			client_print( id, print_chat, "[Combo Limiter] Level %d is required to get Shotguns" , reqlvl );
			return PLUGIN_HANDLED;
		}
	}

	//If not enough players on the opposing team...
	new least = get_cvar_num( "climit_sg_min" );
	if( least != -1 && least != 0 )
	{
		if ( m < least )
		{
			client_print( id, print_chat, "[Combo Limiter] %d Aliens required to get Shotguns" , least );		
			return PLUGIN_HANDLED;
		}
	}	

	//Require ratio
	new prop = get_cvar_num( "climit_sg_prop" );
	if( ( prop != -1 ) && ( prop != 0) )
	{
		if ( g >= m/prop )
		{
			client_print( id,print_chat,"1 Shotgun for every %d Aliens, you need %d more Aliens to get a Shotgun" , prop, prop - (m%prop) );
			return PLUGIN_HANDLED;
		}
	}

	//If too many players already this class...
	new most = get_cvar_num( "climit_sg_max" );
	if( most != -1 )
	{
		if ( g >= most )
		{
			client_print( id,print_chat,"Maximum amount of players allowed to get Shotguns is %d" , most);
			return PLUGIN_HANDLED;
		}
		else
		{
			client_print( id, print_chat, "[Combo Limiter] %d Shotguns remaining" , most - (g+1));
		}			
	}
	
	return PLUGIN_CONTINUE;
}