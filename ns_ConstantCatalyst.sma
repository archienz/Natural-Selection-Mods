/************************************************
	Constant Catalyst for Combat
	Author: Rabid Baboon
	Version: 2.2
	Mod: Natural Selection
	Requires: AMX mod X v1.71 or better
	Modules: NS, Fakemeta and Fun
	Description:
		Three modes: (mode 1 is default)
		0 - Default catalyst behavoir
		1 - Gives a marine constant catalyst once they have gotten the catalyst upgrade		
		2 - Players can now trigger a catalyst pack by pressing the +use key at the cost
		    of sv_cat_costhp (Default: 10) and sv_cat_costap (Default: 0).
		
	Commands
		sv_catmode 0/1/2
			0 = default catalyst behavior
			1 = constant catalyst mode (Default mode)
			2 = stimpack mode - activated by player at the cost of sv_cat_costhp (Default: 10) and sv_cat_costap (Default: 0)
			  
		sv_cat_costhp (Default: 10)
			Change the amount of hp lost when in stimpack mode
			
		sv_cat_costap (Default: 0)
			Change the amount of armor lost when in stimpack mode
			
	Changelog
		v2.2
			*** Fixed *** Cat pack not being given on respawn in cat mode 1
			Added defines for default hp and armor lost values for stimpack mode
		v2.1
			Added sv_cat_costhp and sv_cat_costap to adjust hp and armor loss while in stimpack mode
			
		v2.0
			Added three modes. See above for details.
			Added stimpack mode. Cat Pack can be triggered by press the use key now. If in mode 2			

			
	Special Thanks:
		nf.crew l DeAtH07 for the variable cost idea		
************************************************/
#include <amxmodx>
#include <ns>
#include <fakemeta>
#include <fun>

//default values, maybe changed
#define HP_COST "10" //default amount of hp lost in stimpack mode
#define AP_COST "0" //default amount of armor lost in stimepack mode

/***	Don't change anything below here. Unless you know what you are doing. :) ***/
#define TITLE "Constant Catalyst"
#define VERSION "2.2"
#define AUTHOR "Rabid Baboon"

//Global vars
new bool:g_PlayerGotCat[33];
//cvar pointers
new g_catMode;
new g_catCostHP;
new g_catCostAP;

/************************************************
	plugin_init()
	Initilizaes the plugin	
************************************************/
public plugin_init()
{
	if(ns_is_combat())
	{
		register_plugin(TITLE, VERSION, AUTHOR);
		register_forward(FM_PlayerPreThink, "PreThink");
		
		//server commands
		g_catMode = register_cvar("sv_catmode", "1", FCVAR_SERVER);
		g_catCostHP = register_cvar("sv_cat_costhp", HP_COST, FCVAR_SERVER);
		g_catCostAP = register_cvar("sv_cat_costap", AP_COST, FCVAR_SERVER);
	}
	else
	{
		register_plugin("Constant Catalyst Disabled", "v1.0", "Rabid Baboon");
	}

	return PLUGIN_HANDLED
}
/************************************************
	client_changeteam(index, newteam, oldteam)
		Resets players data on team change
************************************************/
public client_changeteam(playerID, newteam, oldteam)
{
	g_PlayerGotCat[playerID] = false;
}
/************************************************
	PreThink(playerID)
	Takes care of the catalyst logic.	
************************************************/
public PreThink(playerID)
{
	new catMode = get_pcvar_num(g_catMode);
	
	if(catMode == 0)
	{
		return FMRES_IGNORED ;
	}
	
	new playerClass = ns_get_class(playerID);
	
	//if the player is a marine run cat checking
	//else set players got cat to 0
	if(playerClass >= CLASS_MARINE && playerClass <= CLASS_HEAVY)
	{
		new playerCatFlag = ns_get_mask(playerID, MASK_PRIMALSCREAM);
		if(g_PlayerGotCat[playerID])
		{
			if(catMode == 1)
			{
				if(playerCatFlag == 0)
				{
					ns_give_item(playerID,"item_catalyst");
				}
			}
			else
			{
				DoStimpack(playerID, playerCatFlag);	
			}
		}
		else
		{
			if(playerCatFlag == 1)
			{
				g_PlayerGotCat[playerID] = true;
			}
		}
	}
	
	return FMRES_HANDLED;
	
}
/************************************************
	DoStimpack(playerID)
	Takes care of the stimpack logic.	
************************************************/
stock DoStimpack(playerID, playerCatFlag)
{
	new buttonsPressed = pev(playerID, pev_button);
	//if the player pressed their use key give'm a stimpack
	if((buttonsPressed & 32)) //32 is the button code for +use
	{
		if(playerCatFlag == 0)
		{
			ns_give_item(playerID,"item_catalyst");
			
			new playerHP = pev(playerID, pev_health);
			new playerAP = pev(playerID, pev_armorvalue);
			new catCostHP = get_pcvar_num(g_catCostHP); //hp lost for a stimpack
			new catCostAP = get_pcvar_num(g_catCostAP); //armor lost for a stimpack
			
			if(playerHP > catCostHP)
			{
				playerHP -= catCostHP;				
				set_user_health(playerID, playerHP);
			}
			
			if(playerAP > catCostAP)
			{
				playerAP -= catCostAP;
				set_user_armor(playerID, playerAP);
			}	
		
		}
	}

}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1033\\ f0\\ fs16 \n\\ par }
*/
