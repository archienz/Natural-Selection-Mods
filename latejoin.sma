#include <amxmodx>
#include <engine>
#include <ns>

#define XPSYS_NONE		1
#define XPSYS_LEVELCONTROL	2
#define XPSYS_EXTRALEVELS	3

//-------------------------------------------------------------------------------------------------
///////////////////	DO NOT MESS WITH ANYTHING ABOVE THIS LINE!
//-------------------------------------------------------------------------------------------------

/*
	IMPORTANT:
	The next line defines what extra level system the plugin should work with.
		For Extralevels3: use XPSYS_EXTRALEVELS
		For LevelControl: use XPSYS_LEVELCONTROL
	If you are not running an extra level system, use XPSYS_NONE
*/
#define USE_XP_SYSTEM 	XPSYS_NONE

//-------------------------------------------------------------------------------------------------
///////////////////	DO NOT MESS WITH ANYTHING BELOW THIS LINE!
//-------------------------------------------------------------------------------------------------

#if USE_XP_SYSTEM == XPSYS_LEVELCONTROL
#include <lvlctrl>
#endif

#define VERSION			"2.01"
//mode stuff
#define OTHER			0
#define MARINE			(1<<0)	//1
#define ALIEN			(1<<1)	//2

new g_bActive
new g_iMaxPlayers
new g_pcvarAverageBoth, g_pcvarMax_Marine, g_pcvarMax_Alien, g_pcvarMultiplier

#if USE_XP_SYSTEM == XPSYS_EXTRALEVELS
new g_pcvarMaxLevel
#endif

public plugin_init()
{
	register_cvar("v_latejoin", VERSION, FCVAR_SERVER)
	
	g_pcvarAverageBoth = register_cvar("lg_averageboth", "0")
	g_pcvarMax_Marine = register_cvar("lg_max_marine", "5")
	g_pcvarMax_Alien = register_cvar("lg_max_alien", "5")
	g_pcvarMultiplier = register_cvar("lg_multiplier", "0.75")
	
#if USE_XP_SYSTEM == XPSYS_EXTRALEVELS
	g_pcvarMaxLevel = get_cvar_pointer("amx_maxlevel")
#endif
	
	g_bActive = false
	
	if (!ns_is_combat())
	{
		register_plugin("LateJoin(OFF)", VERSION, "Darkns")
	}
	else
	{
		register_plugin("LateJoin(ON)", VERSION, "Darkns")
		
		register_message(get_user_msgid("ResetHUD"),"hook_ResetHUD")
		g_iMaxPlayers = get_maxplayers()
		
		g_bActive = true
	}
}

public hook_ResetHUD(iMsgId, iDest, eTarget)
{
	if (g_bActive)
		if (is_user_alive(eTarget))
			if (get_team(eTarget))
				if (!is_user_bot(eTarget))
					CheckLateXP(eTarget)
}

CheckLateXP(ePlayer)
{
	new iTeam = get_team(ePlayer)
	new iLateGiveMax = 0
	new iTeamType = get_teamtype(iTeam)
	if (iTeamType == MARINE)
		iLateGiveMax = get_pcvar_num(g_pcvarMax_Marine)
	else if (iTeamType == ALIEN)
		iLateGiveMax = get_pcvar_num(g_pcvarMax_Alien)
	
	if (iLateGiveMax > 0)
	{
		new iTeamMaxLevel = x_get_maxlevel(iTeamType)
		if (iLateGiveMax > iTeamMaxLevel)
			iLateGiveMax = iTeamMaxLevel
		
		new iPlayerCount = 0
		new iPlayerLevels = 0
		new bAverageBoth = get_pcvar_num(g_pcvarAverageBoth)
		for (new eOther = 1; eOther <= g_iMaxPlayers; eOther++)
		{
			if (eOther != ePlayer)
			{
				if (is_user_connected(eOther))
				{
					if ( (get_team(eOther) == iTeam) || bAverageBoth)
					{
						iPlayerCount++
						iPlayerLevels += x_get_level(eOther)
					}
				}
			}
		}
		
		if (iPlayerCount)
		{
			new iAveragePlayerLevels = xfloor((float(iPlayerLevels) / float(iPlayerCount)) * get_pcvar_float(g_pcvarMultiplier))
			
			new iCurLevel = x_get_level(ePlayer)
			if (iAveragePlayerLevels > iLateGiveMax)
				iAveragePlayerLevels = iLateGiveMax
			if (iCurLevel < iAveragePlayerLevels)
			{
				x_set_xp(ePlayer, x_min_xp(iAveragePlayerLevels))
				new iLevelBoost = iAveragePlayerLevels - iCurLevel
				client_print(ePlayer, print_chat, "[LateJoin] You recieved a boost of %i %s because you were too far behind.", iLevelBoost, (iLevelBoost == 1)?"level":"levels")
			}
		}
	}
}

get_team(eEnt)
	return entity_get_int(eEnt, EV_INT_team)

get_teamtype(iTeam)	//MvM support...
{
	if (iTeam)
	{
		if (iTeam & MARINE)
			return MARINE
		else
			return ALIEN
	}
	return OTHER
}

xfloor(Float:fNum)
	return floatround(fNum, floatround_floor)

//change these for compatibility wtih extralevels/levelcontrol/or nothing...
x_get_maxlevel(iTeamType)
{
#if USE_XP_SYSTEM == XPSYS_NONE
	return 10
#endif
#if USE_XP_SYSTEM == XPSYS_LEVELCONTROL
	return lvlc_GetMaxLevel(iTeamType)
#endif
#if USE_XP_SYSTEM == XPSYS_EXTRALEVELS
	return get_pcvar_num(g_pcvarMaxLevel)
#endif
}

x_set_xp(ePlayer, iXP)
{
#if USE_XP_SYSTEM == XPSYS_NONE
	ns_set_exp(ePlayer, float(iXP))
#endif
#if USE_XP_SYSTEM == XPSYS_LEVELCONTROL
	lvlc_SetXP(ePlayer, iXP)
#endif
#if USE_XP_SYSTEM == XPSYS_EXTRALEVELS
	ns_set_exp(ePlayer, float(iXP))
#endif
}

x_get_level(ePlayer)
{
#if USE_XP_SYSTEM == XPSYS_NONE
	new iXP = floatround(ns_get_exp(ePlayer))
	if (iXP <= 0)		//it can get negetive after a reset, where it kinda borks for a sec, though only if maxlevel is 1...
		return 1	//0xp is really level 0 and 98%, so...
	
	return floatround((floatsqroot((4.0 * iXP) + 221.0) - 5.0) / 10.0, floatround_floor)
#endif
#if USE_XP_SYSTEM == XPSYS_LEVELCONTROL
	return lvlc_GetLevel(ePlayer)
#endif
#if USE_XP_SYSTEM == XPSYS_EXTRALEVELS
	new iXP = floatround(ns_get_exp(ePlayer))
	if (iXP <= 0)		//it can get negetive after a reset, where it kinda borks for a sec, though only if maxlevel is 1...
		return 1	//0xp is really level 0 and 98%, so...
	
	return floatround((floatsqroot((4.0 * iXP) + 221.0) - 5.0) / 10.0, floatround_floor)
#endif
}

x_min_xp(iLevel)
{
#if USE_XP_SYSTEM == XPSYS_NONE
	return ((25 * iLevel) * (iLevel + 1)) - 49
#endif
#if USE_XP_SYSTEM == XPSYS_LEVELCONTROL
	return lvlc_MinXP(iLevel)
#endif
#if USE_XP_SYSTEM == XPSYS_EXTRALEVELS
	return ((25 * iLevel) * (iLevel + 1)) - 49
#endif
}