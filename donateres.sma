/*
* This Plugin allows aliens to donate res to other players and
* distribute his res when leaving
* Say "giveres x" or "/giveres x" or type in console giveres x while looking at player to donate
*
* amx_donateres_cvar gorgeonly 1/0	: player can only donate to gorge
* amx_donateres_cvar tax x		: how much to pay for transfer (percent)
* amx_donateres_cvar shareonexit 1/0	: player share res on disconnect on/off
* amx_donateres 1/0 or on/off		: turns Donate Res on/off
*
* by White Panther
*
* v1.0:
*	- first release
*
* v1.1.5:
*	- bug fixed where only skulks could donate to skulks, gorge to gorge, ...
*	- bug where gorgeonly could not be turned off after enabling
*	- res of players that leave can be distribute to all others (use "amx_donateres_cvar shareonexit 0" to disable )
*	- fixed bug where player could disconnect, distribute res, connect again and still has his res
*
* v1.2.2b:
*	- now working with NS 3 b5
*	- minor adjustments / fixes
*	- moved from ns2amx to engine + fakemeta + ns
*	- fixed bug for 32 players
*
* v1.2.3:
*	- minor code fixes
*
* v1.2.4:
*	- changed:
*		- moved from pev/set_pev to entity_get/entity_set (no fakemeta)
*
* v1.2.5:
*	- fixed:
*		- possible runtime errors (wrong check order)
*	- changed:
*		- if u have less res than u want to give, all res u have are given
*		- range increased (added define)
*		- minor code improvements
*
* v1.2.8:
*	- fixed:
*		- last alien available on team wont get res in "shareonexit" mode when alien leaves
*		- sharing res on exit tried to split the res to the leaving player too
*	- added:
*		- define to set how long players need to wait before they may start donating after round has started (default 0 seconds)
*		- now players can use "giveres" and "/giveres"
*		- in team chat players can now use the commands too
*	- changed:
*		- sharing res when player leaves server is now taxed
*		- calculation of res to donate/shareonexit
*
* v1.2.9:
*	- fixed:
*		- not running on combat anymore
*
* v1.3.0:
*	- changed:
*		- no more "alternative_linux" define ( unneeded )
*		- code improvements
*/

#include <amxmodx>
#include <amxmisc>
#include <engine>
#include <ns>

#define PLAYER_RANGE		200	// maximum distance player can have while donating
#define DONATE_WAIT_TIME	0	// time players have to wait before they can donate res after round start (in seconds)

new plugin_author[] = "White Panther"
new plugin_version[] = "1.3.0"

new GRrunning = 1
//new Float:bonusres[33]
new disconnected[33]
new Float:roundstart_time
new g_maxplayers
new running_classic

#define cvar_num	3
new CVAR_pointers[cvar_num]

new svar[cvar_num][] =
{
	"gorgeonly",
	"tax",
	"shareonexit"
}

new ivar[cvar_num][] =
{
	"0",
	"10",
	"1"
}

new infovar[cvar_num][] =
{
	"specify if player can only donate to gorges (on/off)",
	"how much tax is paid for the transfer (in percent)",
	"player share res on disconnect on/off"
}

enum
{
	GORGE_ONLY = 0,
	TAX,
	SHARE_ON_EXIT
}

/* Init and forwards */
public plugin_init( )
{
	running_classic = !ns_is_combat()
	register_cvar("donateres_version", plugin_version, FCVAR_SERVER)
	set_cvar_string("donateres_version", plugin_version)
	
	if ( running_classic )
	{
		register_plugin("Donate Res", plugin_version, plugin_author)
		register_concmd("amx_donateres", "amx_donateres", ADMIN_LEVEL_E, "<on/off> or <1/0> turns Donate Res on or off")
		register_concmd("amx_donateres_cvar", "amx_donateres_cvar", ADMIN_LEVEL_E, "type ^"amx_donateres_cvar list^" to get all available cvars")
		register_clcmd("giveres", "donate_res")
		register_clcmd("say", "donate_res_say")
		register_clcmd("say_team", "donate_res_say")
		register_event("Countdown", "eCountdown", "ab")
		
		g_maxplayers = get_maxplayers()
		
		for( new a = 0; a < cvar_num; ++a )
			CVAR_pointers[a] = register_cvar(svar[a], ivar[a])
	}else
		register_plugin("Donate Res (off)", plugin_version, plugin_author)
}

public client_disconnect( id )
{
	if ( running_classic )
	{
		/* share res */
		if ( get_pcvar_num(CVAR_pointers[SHARE_ON_EXIT]) == 1 )
		{
			if ( is_alien(id) )
			{
				new alien_id[32], alien_num
				for ( new player_id = 1; player_id <= g_maxplayers; ++player_id )
				{
					if ( is_user_connected(player_id) && player_id != id )
					{
						if ( is_alien(player_id) )
						{
							alien_id[alien_num] = player_id
							++alien_num
						}
					}
				}
				
				if ( alien_num )
				{
					new Float:restoshare = ns_get_res(id) / alien_num
					new Float:taxres = restoshare * get_pcvar_num(CVAR_pointers[TAX]) / 100.0
					new Float:restogive = restoshare - taxres
					
					for ( new b = 0; b < alien_num; ++b )
						ns_set_res(alien_id[b], ns_get_res(alien_id[b]) + restogive)
				}
				disconnected[id] = 1
			}
		}
	}
}

public client_changeclass( id , newclass , oldclass )
{
	if ( running_classic )
	{
		if ( is_user_connected(id) )
		{
			if ( 1 <= newclass <= 5 )
			{
				if ( disconnected[id] )
					set_task(5.0, "resetres", 100 + id) // 5 secs, cause ns changes it after ~ 3-5 secs
			}
		}
	}
}

/* Donateres */
public amx_donateres( id , level , cid )
{
	if ( !cmd_access(id, level, cid, 2) )
		return PLUGIN_HANDLED
	
	new onoff[5]
	read_argv(1, onoff, 4)
	if ( equal(onoff, "on") || equal(onoff, "1") )
	{
		if ( GRrunning == 1 )
		{
			console_print(id, "Donate Res already enabled")
		}else
		{
			GRrunning = 1
			console_print(id, "Donate Res enabled")
			client_print(0, print_chat, "[AMX] Admin has turned on Donate Res")
		}
	}else if ( equal(onoff, "off") || equal(onoff, "0") )
	{
		if ( GRrunning == 0 )
		{
			console_print(id, "Donate Res already disabled")
		}else
		{
			GRrunning = 0
			console_print(id, "Donate Res disabled")
			client_print(0, print_chat, "[AMX] Admin has turned off Donate Res")
		}
	}
	return PLUGIN_HANDLED
}

public amx_donateres_cvar( id , level , cid )
{
	if ( !cmd_access(id, level,cid, 2) )
		return PLUGIN_HANDLED
	
	new arg1[41], arg2[5]
	read_argv(1, arg1, 40)
	read_argv(2, arg2, 4)
	if ( cvar_exists(arg1) )
	{
		new var_num = str_to_num(arg2)
		if ( equali(arg2, "") )
		{
			new num
			for ( new a = 0; a < cvar_num; ++a )
			{
				if ( equal(arg1, svar[a]) )
				{
					num = a
					break
				}
			}
			console_print(id, "%s currently set to %i    |    %s", arg1, get_cvar_num(CVAR_pointers[num]), infovar[num])
		}else
		{
			set_cvar_num(arg1, var_num)
			console_print(id, "%s set to %i", arg1, var_num)
		}
	}else if ( equal(arg1, "list") )
	{
		console_print(id, "%4s %s %22s %5s       %s", " ", "Cvars:", " ", "Value:", "Info:")
		for ( new a = 0; a < cvar_num; ++a )
			console_print(id, "%3d: %18.18s %10d    |    %s", a + 1, svar[a], get_pcvar_num(CVAR_pointers[a]), infovar[a])
	}else
		console_print(id, "Not a valid cvar, type ^"amx_donateres_cvar list^" to get all available cvars")
	
	return PLUGIN_HANDLED
}


public donate_res( id )
{
	if ( is_alien(id) )
	{
		new res[4]
		read_argv(1, res, 3)
		check_and_donate(id, float(str_to_num(res)))
	}
	return PLUGIN_HANDLED
}

public donate_res_say( id )
{
	if ( is_alien(id) )
	{
		new Speech[31]
		read_args(Speech, 30)
		remove_quotes(Speech)
		if ( equal(Speech, "giveres", 7) || equal(Speech, "/giveres", 8) )
		{
			new res
			for ( new i = 0; Speech[i]; ++i )
			{
				if ( isdigit(Speech[i]) )
				{
					res = str_to_num(Speech[i])
					break
				} 
			}
			check_and_donate(id, float(res))
			return PLUGIN_HANDLED
		}
	}
	return PLUGIN_CONTINUE
}

public eCountdown( )
{
	roundstart_time = get_gametime()
	
	return PLUGIN_HANDLED
}

/* additional Functions */
check_and_donate( id , Float:res )
{
	new aimedid, dummy
	get_user_aiming(id, aimedid, dummy, PLAYER_RANGE)
	if ( GRrunning == 1 )
	{
		if ( get_gametime() - roundstart_time > DONATE_WAIT_TIME )
		{
			if ( is_user_connected(aimedid) )
			{
				if ( entity_get_int(id, EV_INT_team) == entity_get_int(aimedid, EV_INT_team) )
				{
					if ( res > 0.0 )
					{
						if ( ns_get_class(aimedid) == CLASS_GORGE || get_pcvar_num(CVAR_pointers[GORGE_ONLY]) != 1 )
						{
							new Float:userres = ns_get_res(id)	// - res
							
							if ( userres >= 1.0 )
							{
								if ( userres < res )
								{
									userres = 0.0
									res = userres
								}else
									userres -= res
								
								ns_set_res(id, userres)
								
								new Float:taxres = res * get_pcvar_num(CVAR_pointers[TAX]) / 100.0
								new Float:restogive = res - taxres
								
								ns_set_res(aimedid, ns_get_res(aimedid) + restogive )
							}else
								client_print(id, print_chat, "[Donate Res] You must have at least 1 res")
						}else
							client_print(id, print_chat, "[Donate Res] Player is not a Gorge")
					}else
						client_print(id, print_chat, "[Donate Res] You have to donate at least 1 res")
				}else
					client_print(id, print_chat, "[Donate Res] You have to look at a player in your team")
			}
		}else
			client_print(id, print_chat, "[Donate Res] You may not donate until DONATE_WAIT_TIME seconds into the game")
	}else
		client_print(id, print_chat, "[Donate Res] Donating is currently off")
}

is_alien( id )
{
	new teamname[32]
	get_user_team(id, teamname, 31)
	if ( equali(teamname, "alien", 5) )
		return 1
	
	return 0
}

/* Timer Functions */
public resetres( timerid_id )
{
	new id = timerid_id - 100
	ns_set_res(id, 0.1)
	disconnected[id] = 0
}