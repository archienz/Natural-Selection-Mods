#include <amxmodx>
#include <fakemeta>
#include <ns>


public plugin_init() 
{ 
  register_plugin("botcontrol","0.1d","superelf")
  if(ns_is_combat() )	
  {
	set_task(10.0,"maxbot")
	register_event("ResetHUD", "playerSpawned", "b")

  }
} 
public maxbot()	{
	server_cmd("rcbot config max_bots 0")
	set_task(20.0,"check_user_number")
}
public check_user_number() {
	server_cmd("rcbot config max_bots 0")
	server_cmd("mp_friendlyfire 0")
	set_task(3.0,"check_usernumber",0,"",0,"b")
	if ( get_playersnum() < 10 )	{
		server_cmd("rcbot config max_bots %d",get_playersnum() + 1)
		server_cmd("rcbot addbot 1")
		server_cmd("wb add")
	}
}
public check_usernumber ()
{	
	new bot_num = 0
	new marine_num = 0
	new alien_num = 0
	for (new i = 1;i <= get_maxplayers(); ++i) 	{
		if ( is_user_bot(i) != 0 )  ++bot_num
		if ( pev(i,pev_team) == 1 ) ++marine_num
		if ( pev(i,pev_team) == 2 ) ++alien_num
		if ( pev(i,pev_team) == 0 && is_user_bot(i) == 1 )	
		{

					if ( get_playersnum() < 10 ) 
					{	
						new name[32]
						get_user_name(i,name,4)	// check strlen 4 [WB]
						if ( equal(name,"[wb]" ))
						{
							server_cmd("rcbot config max_bots %d",get_playersnum() + 1)
							server_cmd("rcbot addbot 1")
							server_cmd("rcbot config max_bots 0")	
						}
						else	server_cmd("wb add") 

					}
					if ( get_playersnum() > 9 ) 
					{	
						new name[32]
						get_user_name(i,name,4)	// check strlen 4 [WB]
						if ( equal(name,"[wb]" ))
						{
							server_cmd("wb remove")
						}
						else	server_cmd("rcbot removebot") 

					}

		}
	}
	if ( get_playersnum() < 10 ) {
		if ( marine_num > alien_num )	server_cmd("wb add")
		if ( marine_num == alien_num )  server_cmd("wb add") 
		if ( marine_num < alien_num )	{
				server_cmd("rcbot config max_bots %d",get_playersnum() + 1)
				server_cmd("rcbot addbot 1")
				server_cmd("rcbot config max_bots 0")	
		}
	}
	if ( get_playersnum() > 13 && bot_num > 1 ) {
		if ( marine_num < alien_num )  server_cmd("wb remove")
		else	{
			if ( marine_num > alien_num )	{
				for (new i = 1;i <= get_maxplayers(); ++i) {
					if ( is_user_bot(i) != 0 && pev(i,pev_team) == 1)	{
					if ( is_user_bot(i) == 1 ) server_cmd("rcbot removebot")
					break
					}
				}
			}
		}
	}
	return PLUGIN_CONTINUE
}
	
public playerSpawned(id) {
	new g_ping,g_los
	get_user_ping(id,g_ping,g_los)
	if ( is_user_bot(id) != 0 && g_ping == 0 ) {
		if ( pev(id,pev_team) == 2 && ns_get_mask(id,1024) == 0 )	
		{
			ns_set_mask(id,16,1)
			ns_set_mask(id,64,1)
			ns_set_mask(id,8192,1)
			ns_set_mask(id,32768,1)
			ns_set_mask(id,131072,1)
			if ( get_gametime() > 60 )	ns_set_mask(id,8,1)
			if ( get_gametime() > 150 )	ns_set_mask(id,512,1)
			if ( get_gametime() > 450 )	ns_set_mask(id,1024,1)
		}
		if ( pev(id,pev_team) == 1 )	{
			ns_give_item ( id,"weapon_welder") 
			if ( get_gametime() > 300 )	{
				ns_set_mask(id,32,1)
				ns_set_mask(id,256,1)
				if ( get_gametime() > 600 )	{
					ns_give_item ( id,"weapon_heavymachinegun")
					set_task(0.5,"giveweapon",11784+id)
				}
				else ns_give_item ( id,"weapon_shotgun")
				return PLUGIN_CONTINUE
			}
			if ( get_gametime() > 180 )	{
				ns_set_mask(id,16,1)
				ns_set_mask(id,128,1)
				return PLUGIN_CONTINUE
			}
			if ( get_gametime() > 60 )	{
				ns_set_mask(id,8,1)
				ns_set_mask(id,64,1)
				return PLUGIN_CONTINUE
			}
		}
	}
	return PLUGIN_CONTINUE
}


public giveweapon(id)	{
  id -= 11784;
  new weapons=random(2)
  if ( weapons == 0 )	{ 
	if ( ns_get_mask(id,32768) ==0 && ns_get_mask(id,512) ==0 ) ns_give_item ( id,"item_heavyarmor")
	ns_set_speedchange(id,0)
  }
  if ( weapons == 1 )	{ 
	if ( ns_get_mask(id,32768) ==0 && ns_get_mask(id,512) ==0 ) ns_give_item ( id,"item_jetpack") 
	ns_set_speedchange(id,100)
  }
}

