/* AMX Mod script.
*
*
* AMX Rate Manager (rate_manager)
* 
* (c) Copyright 2003 by Marach (marach@phreaker.net, ICQ: 242122535, AIM: marach24, MSN IM: marach24@hotmail.com)
*
* Ported to AMX Mod X by [RST] FireStorm
*
* This file is provided as is (no warranties). 
*
*
* This plugin will allow you to restrict clients' cl_updaterate and rate CVARs. You can set maximum and minimum
* cl_updaterate and rate values a client can use when playing on your server. Plugin checks clients' CVARs and
* corrects exceeded CVARs to the limits you set. Local players playing from LAN, players with specific IP and
* players with specific steamID can be excluded from plugin calculations (by ping, IP and steamID). Plugin is able
* to exclude all players belonging to the same network subnet (192.168.15.x for example) if you want to. Exclusion
* by ping, IP and steamID makes it possible to make two groups of clients (excluded clients and normal clients). The
* plugin can then use different bandwith limits for each group. Plugin is also able to limit bandwith of dead players
* by the percent you set. When a player is dead plugin will lower his CVARs by the set percent and restore them back
* when a new round begins. That way you can leave more server's bandwith and CPU power to alive players.
*
*
* Usage:
*	- open file addons\amxx\configs\amxx.cfg
*	- add these lines to amxx.cfg only if you don't like defaults:
*		rm_maxupdr <max cl_updaterate>
*		rm_minupdr <min cl_updaterate>
*		rm_maxrate <max rate>
*		rm_minrate <min rate>
*		rm_exclmaxupdr <max cl_updaterate>
*		rm_exclminupdr <min cl_updaterate>
*		rm_exclmaxrate <max rate>
*		rm_exclminrate <min rate>
*		rm_delay <delay>
*		rm_deadratio <ratio>
*		rm_localping <ping>
*		rm_ignoreip <IP> [IP] [IP] [IP] ...
*		rm_ignoresteamid <steamID> [steamID] [steamID] [steamID] ...
*		rm_announce <0 or 1>
*		rm_hello <0 or 1>
*	- save the changes to file amxx.cfg :)
*
*
* CVAR explanation:
*	rm_maxupdr - max cl_updaterate a normal client can have (default 36)
*	rm_minupdr - min cl_updaterate a normal client can have (default 12)
*	rm_maxrate - max rate and cl_rate a normal client can have (default 9216 = 9kb)
*	rm_minrate - min rate and cl_rate a normal client can have (default 3072 = 3kb)
*	rm_exclmaxupdr - max cl_updaterate an excluded client can have (default 60)
*	rm_exclminupdr - min cl_updaterate an excluded client can have (default 24)
*	rm_exclmaxrate - max rate and cl_rate an excluded client can have (default 15360 = 15kb)
*	rm_exclminrate - min rate and cl_rate an excluded client can have (default 6144 = 6kb)
*	rm_delay - delay in seconds between checking clients (default 20 seconds)
*	rm_deadratio - lower dead players net setting to this ratio of default net settings (default 0.4 = 40%)
*	rm_localping - plugin will exclude clients who have ping equal or lower than this value (default 0)
*	rm_ignoreip - plugin will exclude clients whose IP is listed with this command
*	rm_ignoresteamid - plugin will exclude clients whose steamID is listen with this command
*	rm_announce - toggle announcing plugin actions on and off (default 1 = on)
*	rm_hello - toggle displaying plugin info to connecting players (default 1 = on)
*
* If you leave defaults (you don't add any lines to amxx.cfg) then the plugin will check all clients every 20
* seconds. Plugin will announce and correct if a normal client has cl_updaterate set below 12 or over 36. Plugin
* will do the same if a normal client has rate set below 3072 or over 9216. Excluded clients (either excluded by
* ping or IP) can set their cl_updaterate between 24 and 60, and their rate between 6144 and 15360. Plugin will
* never announce excluded clients going over set limits. Plugin will lower all dead players' net settings to 40%
* of their default net settings and restore them back when new round begins. Example: if a player has cl_updaterate
* set to 30 and rate set to 8000, when he dies plugin will set his cl_updaterate to 18 and rate to 4800. On a new
* round plugin will restore that particular player's cl_updaterate back to 30 and rate back to 8000. By default,
* players with ping 0 will not be calculated (rm_localping default value is 0). By default, plugin will display
* info message to all connecting players.
*
*
* Notes:
*	- plugin has two parts that can be independently toggled on and off:
*		a) net settings restriction - toggle it off by setting rm_delay to 0
*		b) dead players bandwith saver - toggle it off by setting rm_deadratio to 1.0
* 	- set rm_localping to -1 if you want the plugin to take players with ping 0 into calculations
* 	- using more rm_ignoreip commands adds entries to existing ignore IP list (you will not make a fresh new list)
*	- you can add IP addresses to the ignore IP list using one rm_ignoreip with many IPs specified in one line or
*		using more rm_ignoreip commands (to make it more tidy like in below example of custom settings)
* 	- you can exclude the hole subnet of IPs from plugin calculations by using a letter 'x' when specifying IP
*		with rm_ignoreip (look below example of custom settings to see how to do it)
*	- player who runs a non-dedicated server and is playing on it can be excluded from plugin calculations by
*		adding an entry named 'loopback' to ignore IP list (rm_ignoreip loopback) or by ping
* 	- using more rm_ignoresteamid commands only adds entries to existing ignore steamID list (you will not make a fresh
* 		new list every time use rm_ignoresteamid command)
*	- you can add steamIDs to the ignore steamID list using one rm_ignoresteamid with many steamIDs specified in one line
*		or using more rm_ignoresteamid commands (to make it more tidy like in below example of custom settings)
*
*
* Example of custom plugin settings (amxx.cfg):
*	rm_maxupdr 40
*	rm_minupdr 20
*	rm_maxrate 15000
*	rm_minrate 5000
*	rm_exclmaxupdr 70
*	rm_exclminupdr 30
*	rm_exclmaxrate 20000
*	rm_exclminrate 10000
*	rm_delay 30
*	rm_deadratio 0.8
* 	rm_localping 15
*	rm_ignoreip 192.168.4.12 loopback 68.120.14.155
*	rm_ignoreip 148.122.5.x 165.12.x.x 195.4.202.15
*	rm_ignoresteamid 627543 1945822 122986
*	rm_ignoresteamid 445682 
*	rm_announce 0
*	rm_hello 0
*
* Plugin will check clients every 30 seconds. If plugin finds cl_updaterate set below 20 or over 50, rate set below
* 5000 or over 15000 on a normal client then plugin will correct it but will not announce it. Excluded players can
* have cl_updaterate set from 30 to 70 and rate set from 10000 to 20000. Dead players will have their cl_updaterate
* and rate set to 80% of their default settings and restored back when alive again. Players with ping 15 or less will
* not be taken into calculation at all. Players having IP 192.168.4.12, 68.120.14.155, 195.4.202.15 and player playing
* from loopback (player who's running a non-dedicated server) will not be calculated. All players whose IPs starts with
* 148.122.5. and 165.12. (players belonging to subnets 148.122.5.x and 165.12.x.x) will not be taken into calculation
* at all. Players with steamIDs 627543, 1945822, 122986 and 445682 will be excluded too. No plugin info message will be
* displayed to connecting players.
*
*
*/

#include <amxmodx>
#include <amxmisc>

new origupdr[33], origrate[33], excl[33]
#define MAX_IP 32
new ignip[MAX_IP][32], ippos=0
#define MAX_steamID 128
new ignsteamid[MAX_steamID], steamidpos=0

public check_rr() {
	new maxupdr=get_cvar_num("rm_maxupdr")
	new minupdr=get_cvar_num("rm_minupdr")
	new maxrate=get_cvar_num("rm_maxrate")
	new minrate=get_cvar_num("rm_minrate")
	new announce=get_cvar_num("rm_announce")
	new players[32], np, i, playername[32]
	new clupdr[8], clrt[16], msg[256]
	new tmpupdr, tmprate, cmdexe[32]
	get_players(players, np, "ac")
	for(i=0; i<np; i++)
		if ((players[i]!=0)&&(!is_user_hltv(players[i]))) {
			get_user_ping(players[i], tmpupdr, tmprate)
			if ((tmpupdr>get_cvar_num("rm_localping"))&&(excl[players[i]]==0)) {
				get_user_info(players[i], "cl_updaterate", clupdr, 7)
				get_user_info(players[i], "rate", clrt, 15)
				tmpupdr=str_to_num(clupdr)
				tmprate=str_to_num(clrt)
				if (announce)
					get_user_name(players[i],playername,31)
				if (tmpupdr>maxupdr) {
					origupdr[players[i]]=maxupdr
					format(cmdexe, 31, "cl_updaterate %i", maxupdr)
					client_cmd(players[i], cmdexe)
					if (announce) {	
						format(msg, 255, "* [AMX_RM] %s set 'cl_updaterate' to '%i' (max '%i') - blocked by plugin !", playername, tmpupdr, maxupdr)
						client_print(0, print_chat, msg)
						}
					}
				if (tmpupdr<minupdr) {
					origupdr[players[i]]=minupdr
					format(cmdexe, 31, "cl_updaterate %i", minupdr)
					client_cmd(players[i], cmdexe)
					if (announce) {	
						format(msg, 255, "* [AMX_RM] %s set 'cl_updaterate' to '%i' (min '%i') - blocked by plugin !", playername, tmpupdr, minupdr)
						client_print(0, print_chat, msg)
						}
					}
				if (tmprate>maxrate) {
					origrate[players[i]]=maxrate
					format(cmdexe, 31, "rate %i", maxrate)
					client_cmd(players[i], cmdexe)
					format(cmdexe, 31, "cl_rate %i", maxrate)
					client_cmd(players[i], cmdexe)
					if (announce) {	
						format(msg, 255, "* [AMX_RM] %s set 'rate' to '%i' (max '%i') - blocked by plugin !", playername, tmprate, maxrate)
						client_print(0, print_chat, msg)
						}
					}
				if (tmprate<minrate) {
					origrate[players[i]]=minrate
					format(cmdexe, 31, "rate %i", minrate)
					client_cmd(players[i], cmdexe)
					format(cmdexe, 31, "cl_rate %i", minrate)
					client_cmd(players[i], cmdexe)
					if (announce) {	
						format(msg, 255, "* [AMX_RM] %s set 'rate' to '%i' (min '%i') - blocked by plugin !", playername, tmprate, minrate)
						client_print(0, print_chat, msg)
						}
					}
				}
			}
	new Float:freq=get_cvar_float("rm_delay")
	if (freq > 0.0) set_task(freq, "check_rr")
	return PLUGIN_CONTINUE
}

public alive_again(id) {
	if ((is_user_bot(id))||(is_user_hltv(id)))
		return PLUGIN_CONTINUE
	if (excl[id]==1)
		return PLUGIN_CONTINUE
	new Float:ratio=get_cvar_float("rm_deadratio")
	if (ratio==1.0)
		return PLUGIN_CONTINUE
	new ping, loss
	get_user_ping(id, ping, loss)
	if (ping>get_cvar_num("rm_localping")) {
		new cmdexe[32]
		format(cmdexe, 31, "cl_updaterate %i", origupdr[id])
		client_cmd(id, cmdexe)
		format(cmdexe, 31, "rate %i", origrate[id])
		client_cmd(id, cmdexe)
		format(cmdexe, 31, "cl_rate %i", origrate[id])
		client_cmd(id, cmdexe)
		if (get_cvar_num("rm_announce")) {
			new msg[256]
			format(msg, 255, "* [AMX_RM] Your net settings have been restored : 'cl_updaterate' = '%i', 'rate' = '%i'", origupdr[id], origrate[id])
			client_print(id, print_chat, msg)
			}
		}
	return PLUGIN_CONTINUE
}

public dead_now() {
	new victim=read_data(2)
	if ((is_user_bot(victim))||(is_user_hltv(victim)))
		return PLUGIN_CONTINUE
	if (excl[victim]==1)
		return PLUGIN_CONTINUE		
	new Float:ratio=get_cvar_float("rm_deadratio")
	if (ratio==1.0)
		return PLUGIN_CONTINUE
	new tmpupdr, tmprate
	get_user_ping(victim, tmpupdr, tmprate)
	if (tmpupdr>get_cvar_num("rm_localping")) {		
		new cmdexe[32]
		tmpupdr=floatround(float(origupdr[victim])*ratio)
		tmprate=floatround(float(origrate[victim])*ratio)
		format(cmdexe, 31, "cl_updaterate %i", tmpupdr)
		client_cmd(victim, cmdexe)
		format(cmdexe, 31, "rate %i", tmprate)
		client_cmd(victim, cmdexe)
		format(cmdexe, 31, "cl_rate %i", tmprate)
		client_cmd(victim, cmdexe)
		if (get_cvar_num("rm_announce")) {
			new msg[256]
			format(msg, 255, "* [AMX_RM] Your net settings have been lowered : 'cl_updaterate' = '%i', 'rate' = '%i'", tmpupdr, tmprate)
			client_print(victim, print_chat, msg)
			}
		}
	return PLUGIN_CONTINUE
}

public ignore_ip(id) {
	new argc=read_argc()
	if (argc<2) { 
      		console_print(id, "Usage: rm_ignoreip <IP> [IP] [IP] [IP] ...") 
      		return PLUGIN_CONTINUE
   		} 
	for(new i=1; i<argc; i++)
		if (ippos<MAX_IP) {
			read_argv(i, ignip[ippos], 31)
			ippos++
		}
		else {
			console_print(id, "* [AMX_RM] Too many IP addresses added to the ignore IP list")
			return PLUGIN_CONTINUE
		}
	return PLUGIN_CONTINUE
}

public ignore_steamid(id) {
	new argc=read_argc()
	if (argc<2) { 
      		console_print(id, "Usage: rm_ignoresteamid <steamID> [steamID] [steamID] [steamID] ...") 
      		return PLUGIN_CONTINUE
   		} 
   	new tmp[32]
	for(new i=1; i<argc; i++)
		if (steamidpos<MAX_steamID) {
			read_argv(i, tmp, 31)
			ignsteamid[steamidpos]=str_to_num(tmp)
			steamidpos++
		}
		else {
			console_print(id, "* [AMX_RM] Too many steamIDs added to the ignore steamID list")
			return PLUGIN_CONTINUE
		}
	return PLUGIN_CONTINUE
}

public client_connect(id) {
	if ((is_user_bot(id))||(is_user_hltv(id)))
		return PLUGIN_CONTINUE
	new clupdr[8], clrt[16]
	get_user_info(id, "cl_updaterate", clupdr, 7)
	get_user_info(id, "rate", clrt, 15)
	origupdr[id]=str_to_num(clupdr)
	origrate[id]=str_to_num(clrt)
	excl[id]=0
	new i
	if (ippos>0) {
		new userip[32]
		get_user_ip(id, userip, 31)
		copyc(userip, 31, userip, ':')
		new len
		for(i=0; i<ippos; i++) {
			len=containi(ignip[i],".x")
			if (len>-1) {
				if (equal(userip, ignip[i], len)) {
					excl[id]=1
					break
					}
				}
			else if (equal(userip, ignip[i])) {
				excl[id]=1
				break
				}
			}
		}
	if ((steamidpos>0)&&(excl[id]==0)) {
		new steamid[32]
		get_user_authid(id,steamid,31)
		if (get_user_authid(id,steamid,31)>0)
			for(i=0; i<steamidpos; i++)
				if (get_user_authid(id,steamid,31)==ignsteamid[i]) {
					excl[id]=1
					break
					}
		}
	if (get_cvar_num("rm_hello")==0)
		return PLUGIN_CONTINUE
	new plgver[16]
	get_cvar_string("rate_manager", plgver, 15)
	client_cmd(id, "echo ======================================================================")
      	client_cmd(id, "echo ^"* AMX Rate Manager v%s by Marach, marach@phreaker.net, ICQ: 242122535 *^"", plgver)
	new Float:freq=get_cvar_float("rm_delay")
	if (freq>0.0) {	
		new maxupdr=get_cvar_num("rm_maxupdr")
		new minupdr=get_cvar_num("rm_minupdr")
		new maxrate=get_cvar_num("rm_maxrate")
		new minrate=get_cvar_num("rm_minrate")
		client_cmd(id, "echo ^"   - allowed 'cl_updaterate' range : '%i' - '%i', you have '%i'^"", minupdr, maxupdr, origupdr[id])
		client_cmd(id, "echo ^"   - allowed 'rate' range : '%i' - '%i', you have '%i'^"", minrate, maxrate, origrate[id])
		}
	new Float:ratio=get_cvar_float("rm_deadratio")
	if (ratio<1.0)
		client_cmd(id, "echo ^"   - dead players use %2.0f%%%% of their normal net settings^"", (ratio*100.0))
	client_cmd(id, "echo ======================================================================")
	return PLUGIN_CONTINUE
}

public client_disconnect(id) {
	if ((is_user_bot(id))||(is_user_hltv(id)))
		return PLUGIN_CONTINUE
	origupdr[id]=get_cvar_num("rm_minupdr")
	origrate[id]=get_cvar_num("rm_minrate")
	excl[id]=0
	return PLUGIN_CONTINUE
}

public set_servercvars() {
	new tmp[16]
	get_cvar_string("rm_exclmaxupdr", tmp, 15)
	set_cvar_string("sv_maxupdaterate", tmp)
	get_cvar_string("rm_exclminupdr", tmp, 15)
	set_cvar_string("sv_minupdaterate", tmp)
	get_cvar_string("rm_exclmaxrate", tmp, 15)
	set_cvar_string("sv_maxrate", tmp)
	get_cvar_string("rm_exclminrate", tmp, 15)
	set_cvar_string("sv_minrate", tmp)
	if (get_cvar_num("rm_announce"))
		console_print(0, "* [AMX_RM] Bandwith limits for excluded players have been set")
	return PLUGIN_CONTINUE
}

public plugin_init() {
	register_plugin("Rate Manager", "1.2", "Marach")
	register_cvar("rate_manager", "1.2", FCVAR_SERVER)
	register_event("ResetHUD", "alive_again", "be","1=1")
	register_event("DeathMsg","dead_now","a")
	register_cvar("rm_maxupdr", "36")
	register_cvar("rm_minupdr", "12")
	register_cvar("rm_maxrate", "9216")
	register_cvar("rm_minrate", "3072")
	register_cvar("rm_exclmaxupdr", "60")
	register_cvar("rm_exclminupdr", "24")
	register_cvar("rm_exclmaxrate", "15360")
	register_cvar("rm_exclminrate", "6144")	
	register_cvar("rm_delay", "20")
	register_cvar("rm_deadratio", "0.4")
	register_cvar("rm_localping", "0")
	register_cvar("rm_announce", "1")
	register_cvar("rm_hello", "1")
	register_srvcmd("rm_ignoreip", "ignore_ip")
	register_srvcmd("rm_ignoresteamid", "ignore_steamid")
	new Float:freq=get_cvar_float("rm_delay")
	if (freq>0.0) {
		set_task(freq, "check_rr")
		set_task(5.0, "set_servercvars")
		}
	return PLUGIN_CONTINUE
}
