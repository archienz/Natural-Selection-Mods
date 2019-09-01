/* 
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
*
* Redemption Kill enables gives marines experience (equal to as if they killed them) 
*	for causing an alien to redempt
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
* Title : Redemption Kill
* 
* Author : KCE
* 
* Version : 1.3
*
* Description :
*	Marines get experience (equal to as if they killed them) for causing an alien to redempt
*
* Cvars (name/default value/description) : 
*	rk_multiplier 	1 	"How much to multiply base experience by"
*					
*	Putting 0 means they get no experience
*	Basically its a percent:
*	0.1 = 1% (1/100th experience)
*	1 = 100% (normal experience)
*	2 = 200% (double experience)
*
* Notes:
*	Thanks tom (Teamplay) for the idea!
*
* History :
*		v1.0	- 	Initial Release
*		v1.2	-	Changed method of getting player level
*					Players in range get experience also
*		v1.2.1	-	Slight error calculation fixed
*		v1.2.2	-	Fixed runtime error (thx nf/WP)
*		v1.3	-	Added support for helper plugin
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

#define XPSHARE_RADIUS		522

new g_StartCloak
new g_lastEvent[33]
new g_maxPlayers

public plugin_init()
{
	register_plugin("Redemption Kill","1.3","KCE")
	register_cvar("rk_multiply", "1")
	register_forward(FM_PlaybackEvent,"fwPlaybackEvent")
	g_StartCloak = precache_event(1,"events/StartCloak.sc")
	g_maxPlayers = get_maxplayers()
}

public client_connect(id)
{
	g_lastEvent[id] = 0
}

public client_disconnect(id)
{
	g_lastEvent[id] = 0
}

public fwPlaybackEvent(flags, entid, eventid, Float:delay, Float:Origin[3], Float:Angles[3], Float:fparam1, Float:fparam2, iparam1, iparam2, bparam2 )
{
	//Make sure eventid is redemption event
	if( eventid != g_StartCloak )
		return FMRES_IGNORED
		
	//Iterate event for id
	g_lastEvent[entid]++

	//Have to do this since its called twice, only givexp for one of them (the first one)
	//1st being starting origin redempt, 2nd being hive origin redempt	
	if(g_lastEvent[entid] == 2)
	{
		g_lastEvent[entid] = 0	//reset it
	}	
	else if(g_lastEvent[entid] == 1)	
	{
		//get weap that last attacked alien
		new weapID = entity_get_edict(entid, EV_ENT_dmg_inflictor)	
		
		//so its not caused by worldspawn, or some other non-human dmg
		if( !is_valid_ent(weapID) )	
			return FMRES_IGNORED

		//get owner of weapon that last attacked player, to get player who caused redempt
		new attackerID = entity_get_edict(weapID, EV_ENT_owner)		
		
		if ( !is_user_connected(attackerID) ) 
			return FMRES_IGNORED		
		
		new Float:attackerorigin[3]
		entity_get_vector( attackerID, EV_VEC_origin, attackerorigin )

		//find players who will also get exp
		new id, nearplayers[33], Float:npcount, attackerTeam = entity_get_int(attackerID,EV_INT_team)
		for( id = 1; id <= g_maxPlayers; id++ )
		{
			if( !is_user_connected(id) || (entity_get_int(id,EV_INT_team) != attackerTeam)  )
				continue

			new Float:idorigin[3]
			entity_get_vector( id, EV_VEC_origin, idorigin )
				
			if( vector_distance( attackerorigin, idorigin ) > XPSHARE_RADIUS )
				continue
				
			nearplayers[id] = 1
			npcount += 1.0
		}				
		
		//calculates what each player will get
		new Float:xpgained = ((((float(ns_get_level( entid )) * 10.0) + 50.0) + (npcount * 10.0)) / npcount) * get_cvar_float("rk_multiply")

		//dish out exp
		new id2
		for( id2 = 1; id2 <= g_maxPlayers; id2++ )
		{
			if( !is_user_connected(id2) || !nearplayers[id2] )
				continue

			ns_set_exp( id2, ns_get_exp(id2) + xpgained )					
		}	
	}
		
	return FMRES_HANDLED
}

stock ns_get_level(id)
{
	return floatround(floatsqroot(ns_get_exp(id) / 25 + 2.21) - 1) 
}

#if HELPER == 1
public client_help(id)
{
	help_add("Information","This plugin allows marines to get xp from causing aliens to redempt")
	help_add("Usage","None")
	help_add("Commands","None")
}

public client_advertise(id)	return PLUGIN_CONTINUE
#endif