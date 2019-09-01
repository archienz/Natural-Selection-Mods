// 	ComBot WhichBot Controler
//
// If you've ever wanted to give the ability to your server admins to use bots to help 
// fill the server in combat only, then this script is for you!
// 
// This script only allows bots to be added during combat mode. All the commands are 
// completely disabled during classic mode. Every time a player connects to the server
// one bot will be removed. This is to ensure that no human clients are being blocked 
// out of the server by a bot.
// 
// Available commands in combat mode:
// wb_add	-Changes mp_autoconcede and mp_limitteams so that many bots can be 
//		 added at once.
// wb_remove	-Removes a bot from the server.
// wb_boost	-Boosts a bot to the level specified (  1-15 )
// wb_gestate	-Forces bots to go a certain lifeform once they get the level.
// 

#include <amxmodx>
#include <amxmisc>
#include <ns>

#define PLUGIN "ComBot Controler"
#define VERSION "0.3"
#define AUTHOR "nhdriver4"

new g_BotON = 0;

public plugin_init() 
{
	if(ns_is_combat()) 
	{
		register_plugin(PLUGIN, VERSION, AUTHOR)
		register_dictionary("combot.txt")
		register_clcmd("wb_add","wbAdd",ADMIN_KICK,"- adds a bot to the server")
		register_clcmd("wb_remove","wbRemove",ADMIN_KICK,"- removes a bot from the server")
		register_clcmd("wb_boost","wbBoost",ADMIN_KICK,"- changes a bots level (1-15)")
		register_clcmd("wb_gestate","wbGestate",ADMIN_KICK,"<skulk | lerk | fade | onos>")
	}
	else 
	{
		register_plugin(PLUGIN, VERSION, AUTHOR)
	} 
	return PLUGIN_CONTINUE
}

public wbAdd(id,level,cid) 
{
	if (!cmd_access(id,level,cid,1))  
	{
		console_print(id,"[COMBOT] %L", id, "NO_ACCESS")
		return PLUGIN_HANDLED
	}
	else 
	{
		if (g_BotON) 
		{
			server_cmd("wb add")
			console_print(id,"[COMBOT] %L", id, "BOT_ADD")
			return PLUGIN_HANDLED
		}
		else  
		{
			new maxpl = get_maxplayers()
					
			g_BotON = 1
			set_cvar_num("mp_autoconcede",maxpl)
			set_cvar_num("mp_limitteams",maxpl)
			server_cmd("wb add")
			console_print(id,"[COMBOT] %L", id, "BOT_ADD")
			return PLUGIN_HANDLED
		}
	}
	return PLUGIN_HANDLED
}

public wbRemove(id,level,cid) 
{
	if (!cmd_access(id,level,cid,1)) 
	{
		console_print(id,"[COMBOT] %L", id, "NO_ACCESS")
		return PLUGIN_HANDLED
	}
	else {
		if (g_BotON) 
		{
			server_cmd("wb remove")
			client_print(0,print_chat,"[COMBOT] %L", id, "BOT_DEL")
			return PLUGIN_HANDLED
		}
		else 
		{
			console_print(id,"[COMBOT] %L", id, "BOT_NOTON")
			return PLUGIN_HANDLED
		}
	}
	return PLUGIN_HANDLED
}

public wbBoost(id,level,cid) 
{
	if (!cmd_access(id,level,cid,1)) 
	{
		console_print(id,"[COMBOT] %L", id, "NO_ACCESS")
		return PLUGIN_HANDLED
	}
	else 
	{
		if (g_BotON) 
		{
			new readlevel[3]
			read_argv(1,readlevel,2)
			
			new input = str_to_num(readlevel)
			if(input >= 1 && input <= 15) 
			{
				server_cmd("wb boost %s",readlevel)
				client_print(0,print_chat,"[COMBOT] %L", id, "BOT_UP", readlevel)
				return PLUGIN_HANDLED
			}
			
			else 
			{
				console_print(id,"[COMBOT] %L", id, "BOT_UP_INVAL")
				return PLUGIN_HANDLED
			}
		}
		else 
		{
			console_print(id,"[COMBOT] %L", id, "BOT_NOTON")
			return PLUGIN_HANDLED
		}
	}
	return PLUGIN_HANDLED
}

public wbGestate(id,level,cid) 
{
	if (!cmd_access(id,level,cid,1))  
	{
		console_print(id,"[COMBOT] %L", id, "NO_ACCESS")
		return PLUGIN_HANDLED
	}
	else 
	{
		if (g_BotON) 
		{
			new lifeform[8]
			read_argv(1,lifeform,7)
	
			if (equal(lifeform,"skulk")) 
			{
				server_cmd("wb evolve skulk");
				client_print(0,print_chat,"[COMBOT] %L", 0, "BOT_FORM_SKUL")
				return PLUGIN_HANDLED
			} 
			if (equal(lifeform,"lerk")) 
			{
				server_cmd("wb evolve lerk");
				client_print(0,print_chat,"[COMBOT] %L", 0, "BOT_FORM_LERK")
				return PLUGIN_HANDLED
			} 
			if (equal(lifeform,"fade")) 
			{
				server_cmd("wb evolve fade");
				client_print(0,print_chat,"[COMBOT] %L", 0, "BOT_FORM_FADE")
				return PLUGIN_HANDLED
			} 
			if (equal(lifeform,"onos")) 
			{
				server_cmd("wb evolve onos");
				client_print(0,print_chat,"[COMBOT] %L", 0, "BOT_FORM_ONOS")
				return PLUGIN_HANDLED
			}
			else 
			{
				console_print(id,"[COMBOT] %L", id, "BOT_FORM_INVAL")
				return PLUGIN_HANDLED
			}
		}
		else 
		{
			console_print(id,"[COMBOT] %L", "BOT_NOTON")
			return PLUGIN_HANDLED
		}
	}
	return PLUGIN_HANDLED
}

public client_connect(id) 
{ 
	if (is_user_bot(id)) 
	{
		return PLUGIN_HANDLED
	}
	else 
	{
		if (g_BotON) 
		{
			server_cmd("wb remove")
		}
		else 
		{
			return PLUGIN_HANDLED
		}
	}
	return PLUGIN_HANDLED
}
