/* Multiple blocker for things such as FADE, ONOS, JP, HA, HMG
* 
* Cvars
* amx_blocker Controls whether plugin is blocking. (default 1, change to 0 to turnoff plugin)
* blkr_minfades Minimum number of players to go Fade
* blkr_minoni Minimum number of players to go Onos
* blkr_proponi Number of rines to every 1 onos.(default is 3.  SO, you need 3 rines for every one onos)
* blkr_minjp Minimum number of players to go JP
* blkr_minha Minimum number of players to go HA
* blkr_minhmg Minimum number of players to get a HMG
* blkr_mingl Minimum number of players to get a GL
* 
* This was based off of class Control plugin.
* This was made by Riot_Starter and Newbster. 
* If there are n e bugs please report them to CBribiescas@satx.rr.com
* Visit my clan website at www.j00s.com (j00s is spelt with zeros, not letters)
* Visit the clan forums at forums.j00s.com (j00s is spelt with zeros, not letters)
* Natural Selection clan Server at www.j00s.com (j00s is spelt with zeros, not letters)
*
* Updates
*
*
* 1.1 to 1.2
* added GL blocker to the blocker
* added cvar blkr_mingl to control minimum number of players need to get a GL.
*
* 1.0 to 1.1
* Got it to block correctly....
*
*/
#include <amxmodx>
#include <engine>
#include <fakemeta>
#include <ns>

#define IMPULSE_FADE	116
#define IMPULSE_ONOS	117
#define IMPULSE_JP	39
#define	IMPULSE_HA	38
#define IMPULSE_HMG	65
#define IMPULSE_GL      66

new playerCount 
new message[120]

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
		register_plugin("Blocker", "1.3", "-j00- Clan")
		
		register_cvar("amx_blocker", "1")
		
		register_cvar("blkr_minfades", "5")
		register_cvar("blkr_minoni", "8")
		register_cvar("blkr_proponi", "3")
		register_cvar("blkr_minjp", "5")
		register_cvar("blkr_minha", "5")
		register_cvar("blkr_minhmg", "5")
		register_cvar("blkr_mingl", "5")

		register_impulse(IMPULSE_HMG,"hmghook")
		register_impulse(IMPULSE_FADE,"fadehook")
		register_impulse(IMPULSE_ONOS,"onoshook")
		register_impulse(IMPULSE_JP,"jphook")
		register_impulse(IMPULSE_HA,"hahook")
		register_impulse(IMPULSE_GL,"glhook")
	}
	return
}

public fadehook(id)
{
	if (!get_cvar_num("amx_blocker"))
		return PLUGIN_CONTINUE
	playerCount = get_playersnum ()
	if(playerCount<get_cvar_num("blkr_minfades"))		//Can't get fade
	{
		format(message,120, "Sorry you need %d players to get fade!!!",get_cvar_num("blkr_minfades"))
		client_print (id,print_chat,message)
		return PLUGIN_HANDLED
	}
	return PLUGIN_CONTINUE
}

public onoshook(id)
{
	if (!get_cvar_num("amx_blocker"))
		return PLUGIN_CONTINUE

	new rines
	new count
	playerCount = get_playersnum ()
	if(playerCount<get_cvar_num("blkr_minoni"))		//Can't get onos
	{
		format(message,120, "Sorry you need %d players to get onos!!!",get_cvar_num("blkr_minoni"))
		client_print (id,print_chat,message)
		return PLUGIN_HANDLED
	}
	else
	{
		for(new i = 0; i <= playerCount; i++)
		{
			if (ns_get_class(i) != CLASS_ONOS)
				count++
		}
		
		new onoses = playerCount - count
		rines = rinecount()
		
		if (onoses >= rines/get_cvar_num("blkr_proponi"))
		{
			format(message,120, "There is a limit of 1 onos for every %d rines,sorry",get_cvar_num("blkr_proponi"))
			client_print (id,print_chat,message)
			return PLUGIN_HANDLED
		}
	}
	return PLUGIN_CONTINUE
}

public jphook(id)
{
	if (!get_cvar_num("amx_blocker"))
		return PLUGIN_CONTINUE
	playerCount = get_playersnum ()
	if(playerCount<get_cvar_num("blkr_minjp"))		//Can't get jetpack
	{
		format(message,120, "Sorry you need %d players to get a jetpack!!!",get_cvar_num("blkr_minjp"))
		client_print (id,print_chat,message)
		return PLUGIN_HANDLED
	}
	return PLUGIN_CONTINUE
}

public hahook(id)
{
	if (!get_cvar_num("amx_blocker"))			
		return PLUGIN_CONTINUE
	playerCount = get_playersnum ()
	if(playerCount<get_cvar_num("blkr_minha"))		//Can't get heavy armor
	{
		format(message,120, "Sorry you need %d players to get heavy armor!!!",get_cvar_num("blkr_minha"))
		client_print (id,print_chat,message)
		return PLUGIN_HANDLED
	}
	return PLUGIN_CONTINUE
}

public hmghook(id)				
{
	if (!get_cvar_num("amx_blocker"))
		return PLUGIN_CONTINUE


	playerCount = get_playersnum ()


	if(playerCount<get_cvar_num("blkr_minhmg"))		//Can't get HMG
	{
		format(message,120, "Sorry you need %d players to get a HMG!!!",get_cvar_num("blkr_minhmg"))
		client_print (id,print_chat,message)
		return PLUGIN_HANDLED
	}
	return PLUGIN_CONTINUE
}
public glhook(id)
{
	if (!get_cvar_num("amx_blocker"))
		return PLUGIN_CONTINUE


	playerCount = get_playersnum ()


	if(playerCount<get_cvar_num("blkr_mingl"))		//Can't get GL
	{
		format(message,120, "Sorry you need %d players to get a GL!!!",get_cvar_num("blkr_mingl"))
		client_print (id,print_chat,message)
		return PLUGIN_HANDLED
	}
	return PLUGIN_CONTINUE
}
public rinecount()
{
	new marinecount
	playerCount = get_playersnum ()
	for(new i = 0; i <= playerCount; i++)
	{
		if ( get_user_team(i) == 1)    
			marinecount++
	}
	return marinecount
}
