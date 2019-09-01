/*
* This plugin limits MvM combat to 1 GL
* Originally created for sentiel's server(s)
*
* by DDR Khat
*
* v1.0:
*	- initial release
*/

#include <amxmodx>
#include <ns>
#include <engine>
#include <fakemeta>

#define PLUGIN "GL Limiter"
#define VERSION "1.0"
#define AUTHOR "DDR Khat"
#define NULL ""

//All our needed variables
new team1gl[60];
new team3gl[60];
new g_maxPlayers;
new g_f4ing[33] = 0;
new is_mvm = 0
//Lets get going!

public plugin_precache()
{
	register_forward(FM_KeyValue, "fw_keyvalue")
}

public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	if(ns_is_combat() && is_mvm)
	{
		register_impulse(66,"newgl")
		register_clcmd("readyroom","f4")
		g_maxPlayers = get_maxplayers();
		
	}
		
}

public client_disconnect(id)
{
	new szID[60];
	get_user_authid(id,szID,59);
	switch(pev(id, pev_team))
	{
		case 1:
			if(szID[0] == team1gl[0])
			{
				team1gl = NULL
				send_to_team(1,"The GL is available again")
			}
		case 3:
			if(szID[0] == team3gl[0])
			{
				team3gl = NULL
				send_to_team(3,"The GL is available again")
			}
	}
}
public f4(id)
{
	if(g_f4ing[id])
	{
		new szID[60];
		get_user_authid(id,szID,59);
		switch(pev(id, pev_team))
		{
			case 1:
			{
				team1gl = NULL
				send_to_team(1,"The GL is available again")
			}
			case 3:
			if(szID[0] == team3gl[0])
			{
				team3gl = NULL
				send_to_team(3,"The GL is available again")
			}
		}
	}
	else{
		new params[1];
		params[0] = id;
		g_f4ing[id] = 1;
		set_task(2.0, "abortf4", 0, params, 1);
	}
}

public abortf4(params[], id){
  new player = params[0];
  g_f4ing[player] = 0;
}

public newgl(id)
{	
	new szID[60];
	get_user_authid(id,szID,59);
	switch(pev(id, pev_team))
	{
		case 1:
			if(!team1gl[0] && ns_get_points(id)>0)
				team1gl = szID
			else
			{
				if(ns_get_points(id)>1)
				{
					client_print(id, print_chat, "[AMXX] You're team has a GL")
					return PLUGIN_HANDLED
				}
			}
		case 3:
			if(!team3gl[0] && ns_get_points(id)>0)
				team3gl = szID;
			else
			{
				if(ns_get_points(id)>1)
				{
					client_print(id, print_chat, "[AMXX] You're team has a GL")
					return PLUGIN_HANDLED
				}
			}
	}
	return PLUGIN_CONTINUE
}

public send_to_team(id, msg[]){
  new team = id;
  for(new i = 1 ; i <= g_maxPlayers ; i++){
    if(!is_user_connected(i)) continue;
    else
      if(pev(i, pev_team) == team)
	client_print(i, print_chat, msg);
  }
}

public fw_keyvalue( ent , kvdid )
{
	new classname[32]
	new keyname[32]
	new keyvalue[32]
	get_kvd(kvdid, KV_KeyName, keyname, 31)
	get_kvd(kvdid, KV_Value, keyvalue, 31)
	if ( pev_valid(ent) )
	{
		get_kvd(kvdid, KV_ClassName, classname, 31)
		
		if ( equali(classname, "info_gameplay") )
		{
			if ( equali(keyname, "teamtwo") && !equali(keyvalue,"2") )
			is_mvm = 1
		}
	}
	
	return FMRES_IGNORED
}
