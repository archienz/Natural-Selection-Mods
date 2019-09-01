/* Higher LifeForm Plugin that won't allow a player to go Onos or Fade Until 
 * A certain number of hives are built or a certain time has passed.
 *
 * This is a modified NS_Classic Version of (c) 2005 Joe "Lord Skitch" Jackson's comBalance
 * I couldn't have done this without his Original Code - SilverSquirrl {2Frag4Fun}
 *
 * 	Configuration cvars:
 *		block_onos   - The number of hives needed to go Onos
 *			Default 3
 *		blockt_onos  -The time in min until you can go Onos
 *			Default 15
 *		block_fade   - The number of hives needed to go fade
 *			Default 2
 *		blockt_fade  -The time in min until you can go fade
 *			Default 9
 *
 */




#include <amxmodx>
#include <ns>
#include <engine>

public plugin_init()
{
	if (ns_is_combat()){
		register_plugin("NSBalancer (off)", "3.0", "SilverSquirrl -2F4F")
	}
	else{
		register_plugin("NSBalancer","3.0","SilverSquirrl -2F4F")
		register_cvar("block_onos","3",FCVAR_SERVER)
		register_cvar("block_fade","2",FCVAR_SERVER)
		register_cvar("blockT_onos","15",FCVAR_SERVER)
		register_cvar("blockT_fade","9",FCVAR_SERVER)
		register_impulse(117,"checkOnos")
		register_impulse(116,"checkFade")
		register_cvar("hookTime","0",FCVAR_SERVER)
		register_event("Countdown","gameStarting","a")
	}
}

public checkOnos(id) {
	new x
	x = checkBlock(id,0)
	if (x == 0)
		return PLUGIN_HANDLED
	else
		return PLUGIN_CONTINUE
	return PLUGIN_CONTINUE
}

public checkFade(id) {
	new x
	x = checkBlock(id,1)
	if (x == 0)
		return PLUGIN_HANDLED
	else
		return PLUGIN_CONTINUE
	return PLUGIN_CONTINUE
}

public checkBlock(id, impulVar)
{
	new numhive, needhive
	numhive = ns_get_build("team_hive",1)
	new Float:minsLeft, Float:secsLeft, Float:timeElapse, Float:startTime, Float:startTime2, Float:timeRemain, class[16]
	startTime = get_cvar_float("hookTime")
	startTime2 = get_gametime()

	
	switch (impulVar) {
		case 0: needhive = get_cvar_num("block_onos"), timeRemain = get_cvar_float("blockT_onos") * 60;
		case 1: needhive = get_cvar_num("block_fade"), timeRemain = get_cvar_float("blockT_fade") * 60;
		}

	switch (impulVar) {
		case 0: class = "ONOS";
		case 1: class = "FADE";
		}

	timeElapse = startTime2 - startTime


	if (numhive < needhive && timeElapse < timeRemain)	{
			client_print(id,print_chat,"There are %d hives built, you need %d Hives or",numhive,needhive)
			timeRemain = timeRemain - timeElapse
			minsLeft = (timeRemain / 60)
			secsLeft = (timeRemain-(floatround(minsLeft, floatround_floor)*60))
			client_print(id,print_chat,"%d minutes %d seconds until %s is unblocked",floatround(minsLeft, floatround_floor),floatround(secsLeft),class)
			entity_set_int(id,EV_INT_impulse,0) 
			return 0
	}

	if (numhive >= needhive || timeElapse >= timeRemain)	{
		return 1
	}
	return 1
}

public gameStarting()
{
	new Float:startTime
	startTime = get_gametime()
	set_cvar_float("hookTime", startTime+5)
	return PLUGIN_CONTINUE
}