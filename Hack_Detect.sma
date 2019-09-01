/////////////////////////////////////
// Hack Detector, v1.12 by solcott //
///////////////////////////////////////////////////////////////
// Based of off _special command blocker, by Cheesy Peteza.  //
// Special thanks to Dark_Matter, for getting automatic      //
// banning of cheaters to work.                              //
//                                                           //
// Now includes AMXBANS support, scroll down to line 188     //
// for AMXBANS configuration. (disabled by default)          //
//                                                           //
// Changes in 1.12                                           //
//   * fixed a typo, thanks BooF                             //
//                                                           //
// Changes in 1.11                                           //
//   * expanded circumvention detection                      //
//                                                           //
// Changes in 1.1 (unreleased)                               //
//   * circumvention detection added                         //
//                                                           //
// Changes in 1.04                                           //
//   * author name changed for NSSB compatibility            //
//                                                           //
// Changes in 1.03                                           //
//   * fixed problem with clients being able to spam the     //
//     laughter sound effect after being banned              //
//                                                           //
// Changes in 1.02                                           //
//   * added support for AMXBANS, see line 185               //
//                                                           //
// Changes in 1.01                                           //
//   * fixed banning method to automatically ban cheaters    //
//                                                           //
// Changes in 1.0                                            //
//   * updated _special command blocker to support NS > 1.04 //
///////////////////////////////////////////////////////////////
#include <amxmodx> 

///////////////////////////////////////
// Bunny Hop Script Detection Config //
//////////////////////////////////////////////////////////
// This is really only used to detect _special scripts, //
// so unless you are running a NS 1.04/2.0 server you   //
// can ignore this section because _special has been    //
// taken out of NS 3.0 and newer.                       //
//////////////////////////////////////////////////////////

#define LOG_TO_FILE      1   // Log detected users to addons/amxmodx/logs/bhdetected.log 
#define DISPLAY_HUD_MSG      1   // Display big center screen detected message to everyone 
#define PRINT_TO_ALL_CONSOLE   1   // Print detected message to everyones console 
#define PRINT_TO_ADMIN_CHAT   1   // Print detected message to admin chat 
#define DISPLAY_CON_MSG      1   // Display message below to users detected 
stock const DETECTED_MSG[] =   "[AMX] Please remove your illegal bunny hop script before rejoining the server" 
#define BAN_IF_DETECTED      1   // Ban detected user 
#define BAN_TIME      2   // Ban time in minutes ( use 0 for permanent )
#define BAN_SOUND 1   // Laugh at people when they get caught.

/////////////////////////////
// Buzz Hook Detect Config //
/////////////////////////////////////////////////
// Check line 435 for further configuration of //
// Buzz Hook detection.                        //
/////////////////////////////////////////////////

#define BUZZ_LOG_TO_FILE      1   // Log detected users to addons/amxmodx/logs/bhdetected.log 
#define BUZZ_DISPLAY_HUD_MSG      1   // Display big center screen detected message to everyone 
#define BUZZ_PRINT_TO_ALL_CONSOLE   1   // Print detected message to everyones console 
#define BUZZ_PRINT_TO_ADMIN_CHAT   1   // Print detected message to admin chat 
#define BUZZ_DISPLAY_CON_MSG      1   // Display message below to users detected 
stock const BUZZ_DETECTED_MSG[] =   "Buzz Hook Detected! Ban Incoming!" 
#define BUZZ_BAN_IF_DETECTED      1   // Ban detected user 
#define BUZZ_BAN_TIME         0   // Ban time in minutes ( use 0 for permanent )
#define BUZZ_SOUND 1  // Laugh at people when they get caught.

////////////////////////////
// Circumvention   Config //
////////////////////////////
#define CIRCUM_LOG_TO_FILE      1   // Log detected users to addons/amxmodx/logs/bhdetected.log 
#define CIRCUM_DISPLAY_HUD_MSG      1   // Display big center screen detected message to everyone 
#define CIRCUM_PRINT_TO_ALL_CONSOLE   1   // Print detected message to everyones console 
#define CIRCUM_PRINT_TO_ADMIN_CHAT   1   // Print detected message to admin chat 
#define CIRCUM_DISPLAY_CON_MSG      1   // Display message below to users detected 
stock const CIRCUM_DETECTED_MSG[] =   "Aimbotti Detected! Ban Incoming!" 
#define CIRCUM_BAN_IF_DETECTED      1   // Ban detected user 
#define CIRCUM_BAN_TIME         0   // Ban time in minutes ( use 0 for permanent )
#define CIRCUM_BAN_SOUND 1  // Laugh at people when they get caught.

////////////////////////////
// Aimbotti Detect Config //
////////////////////////////
#define AIMBOTTI_LOG_TO_FILE      1   // Log detected users to addons/amxmodx/logs/bhdetected.log 
#define AIMBOTTI_DISPLAY_HUD_MSG      1   // Display big center screen detected message to everyone 
#define AIMBOTTI_PRINT_TO_ALL_CONSOLE   1   // Print detected message to everyones console 
#define AIMBOTTI_PRINT_TO_ADMIN_CHAT   1   // Print detected message to admin chat 
#define AIMBOTTI_DISPLAY_CON_MSG      1   // Display message below to users detected 
stock const AIMBOTTI_DETECTED_MSG[] =   "Aimbotti Detected! Ban Incoming!" 
#define AIMBOTTI_BAN_IF_DETECTED      1   // Ban detected user 
#define AIMBOTTI_BAN_TIME         0   // Ban time in minutes ( use 0 for permanent )
#define AIMBOTTI_SOUND 1  // Laugh at people when they get caught.

////////////////////////////
// PFT Hack Detect Config //
////////////////////////////
#define PFT_LOG_TO_FILE      1   // Log detected users to addons/amxmodx/logs/bhdetected.log 
#define PFT_DISPLAY_HUD_MSG      1   // Display big center screen detected message to everyone 
#define PFT_PRINT_TO_ALL_CONSOLE   1   // Print detected message to everyones console 
#define PFT_PRINT_TO_ADMIN_CHAT   1   // Print detected message to admin chat 
#define PFT_DISPLAY_CON_MSG      1   // Display message below to users detected 
stock const PFT_DETECTED_MSG[] =   "PFT Detected! Ban Incoming!" 
#define PFT_BAN_IF_DETECTED      1   // Ban detected user 
#define PFT_BAN_TIME         0   // Ban time in minutes ( use 0 for permanent )
#define PFT_SOUND 1  // Laugh at people when they get caught.

///////////////////////////////
// Penaro Hack Detect Config //
///////////////////////////////
#define PENARO_LOG_TO_FILE      1   // Log detected users to addons/amxmodx/logs/bhdetected.log 
#define PENARO_DISPLAY_HUD_MSG      1   // Display big center screen detected message to everyone 
#define PENARO_PRINT_TO_ALL_CONSOLE   1   // Print detected message to everyones console 
#define PENARO_PRINT_TO_ADMIN_CHAT   1   // Print detected message to admin chat 
#define PENARO_DISPLAY_CON_MSG      1   // Display message below to users detected 
stock const PENARO_DETECTED_MSG[] =   "PENARO Detected! Ban Incoming!" 
#define PENARO_BAN_IF_DETECTED      1   // Ban detected user 
#define PENARO_BAN_TIME         0   // Ban time in minutes ( use 0 for permanent )
#define PENARO_SOUND 1  // Laugh at people when they get caught.

///////////////////////////////
// Talis Hack Detect Config  // 
///////////////////////////////
#define TALIS_LOG_TO_FILE      1   // Log detected users to addons/amxmodx/logs/bhdetected.log 
#define TALIS_DISPLAY_HUD_MSG      1   // Display big center screen detected message to everyone 
#define TALIS_PRINT_TO_ALL_CONSOLE   1   // Print detected message to everyones console 
#define TALIS_PRINT_TO_ADMIN_CHAT   1   // Print detected message to admin chat 
#define TALIS_DISPLAY_CON_MSG      1   // Display message below to users detected 
stock const TALIS_DETECTED_MSG[] =   "TALIS Detected! Ban Incoming!" 
#define TALIS_BAN_IF_DETECTED      1   // Ban detected user 
#define TALIS_BAN_TIME         0   // Ban time in minutes ( use 0 for permanent )
#define TALIS_SOUND 1  // Laugh at people when they get caught.

///////////////////////////////
// AIMBOT Hack Detect Config // 
////////////////////////////////////////////////////////////////
// This does NOT detect all aimbots, it simply checks clients //
// configuration for having a setting called 'aimbot'         //
////////////////////////////////////////////////////////////////
#define AIMBOT_LOG_TO_FILE      1   // Log detected users to addons/amxmodx/logs/bhdetected.log 
#define AIMBOT_DISPLAY_HUD_MSG      1   // Display big center screen detected message to everyone 
#define AIMBOT_PRINT_TO_ALL_CONSOLE   1   // Print detected message to everyones console 
#define AIMBOT_PRINT_TO_ADMIN_CHAT   1   // Print detected message to admin chat 
#define AIMBOT_DISPLAY_CON_MSG      1   // Display message below to users detected 
stock const AIMBOT_DETECTED_MSG[] =   "AIMBOT Detected! Ban Incoming!" 
#define AIMBOT_BAN_IF_DETECTED      1   // Ban detected user 
#define AIMBOT_BAN_TIME         0   // Ban time in minutes ( use 0 for permanent )
#define AIMBOT_SOUND 1  // Laugh at people when they get caught.

////////////////////////////
// S Value Detect Config  // 
////////////////////////////////////////////////////
// S Value Detection is for detection of modified //
// Buzz Hooks, or other hooks written from the    //
// Buzz Hook source.                              //
////////////////////////////////////////////////////
#define S_LOG_TO_FILE      1   // Log detected users to addons/amxmodx/logs/bhdetected.log 
#define S_DISPLAY_HUD_MSG      1   // Display big center screen detected message to everyone 
#define S_PRINT_TO_ALL_CONSOLE   1   // Print detected message to everyones console 
#define S_PRINT_TO_ADMIN_CHAT   1   // Print detected message to admin chat 
#define S_DISPLAY_CON_MSG      1   // Display message below to users detected 
stock const S_DETECTED_MSG[] =   "Modified Buzz Hook Detected! Ban Incoming!" 
#define S_BAN_IF_DETECTED      1   // Ban detected user 
#define S_BAN_TIME         0   // Ban time in minutes ( use 0 for permanent )
#define S_SOUND 1  // Laugh at people when they get caught.

new detectedusers[33] 


public plugin_init() 
	{ 
	//Setup Plugin Info
	register_plugin("Hack Detector","1.12","solcott") 
	register_cvar("bhdetector_version", "1.12", FCVAR_SERVER) 
	
	////////////////////////////
	// AMXBANS Support Config // 
	////////////////////////////////////////////////////
	// This is to set whether or not you are using    //
	// AMXBANS or not. Set to 1 if you use AMXBANS or //
	// set to 0 if you do not.                        //
	////////////////////////////////////////////////////
	register_cvar("hack_amxban", "0", FCVAR_SERVER) 
	
	// ANTI-BUZZ circumvention support
	register_clcmd("menu_toggle","circumventiondetected") 
	register_clcmd("menu_up","circumventiondetected")
	register_clcmd("menu_down","circumventiondetected")
	register_clcmd("menu_select","circumventiondetected")
	register_clcmd("menu_back","circumventiondetected")
	register_clcmd("console_toggle","circumventiondetected")
	register_clcmd("console_select","circumventiondetected")
	register_clcmd("+justaim","circumventiondetected")
	register_clcmd("-justaim","circumventiondetected")
	register_clcmd("justaim","circumventiondetected")
	register_clcmd("+doaim","circumventiondetected")
	register_clcmd("-doaim","circumventiondetected")
	register_clcmd("doaim","circumventiondetected")
	register_clcmd("+thru","circumventiondetected")
	register_clcmd("-thru","circumventiondetected")
	register_clcmd("thru","circumventiondetected")
	register_clcmd("+doshoot","circumventiondetected")
	register_clcmd("-doshoot","circumventiondetected")
	register_clcmd("doshoot","circumventiondetected")
	register_clcmd("+csgaim","circumventiondetected")
	register_clcmd("-csgaim","circumventiondetected")
	register_clcmd("csgaim","circumventiondetected")
	register_clcmd("jsn_ns1","circumventiondetected")
	register_clcmd("jsn_ns2","circumventiondetected")
	register_clcmd("jsn_ns3","circumventiondetected")
	register_clcmd("jsn_ns4","circumventiondetected")
	register_clcmd("jsn_ns5","circumventiondetected")
	register_clcmd("jsn_ns6","circumventiondetected")
	register_clcmd("jsn_ns7","circumventiondetected")
	register_clcmd("humaim0","circumventiondetected")
	register_clcmd("humaim1","circumventiondetected")
	register_clcmd("smooth0","circumventiondetected")
	register_clcmd("smooth1","circumventiondetected")
	
	
	// _special scripts supported
	register_clcmd("bhdetector","specialdetected") 
	register_clcmd("bhop","specialdetected") 
	register_clcmd("bunnyhop","specialdetected") 
	
	// Hacks supported, made by very stupid hack authors who add setinfo's to their hacks.
	// If you find a hack that uses setinfo, please send a private message to solcott
	// on the modns.org forums and I will add support for it to this plugin.
	register_clcmd("amx_buzzcheck","checkforbuzzhook") 
	register_clcmd("amx_aimbotticheck","checkforaimbotti") 
	register_clcmd("amx_pftcheck","checkforpft") 
	register_clcmd("amx_penarocheck","checkforpenaro") 
	register_clcmd("amx_talischeck","checkfortalis") 
	register_clcmd("amx_scheck","checkfor_s") 
	register_clcmd("amx_s2check","checkfor_s2") 
	register_clcmd("amx_s3check","checkfor_s3")
	
	//	set_task(0.5, "bhdetect", 1, "", 0, "b") 
} 
////////////////////////////////////
// Laugh at that cheating biatch! //
////////////////////////////////////
public plugin_precache()
	{
	precache_sound("misc/detect_01.wav")
}

public scriptdetect() 
	{ 
	client_cmd(0 , "alias ^"_special^" ^"bhdetector^" ^"bhop^" ^"bunnyhop^"") 
} 

public circumventiondetected(id) 
	{ 
	if (!detectedusers[id] && is_user_alive(id)) { 
		detectedusers[id] = 1 
		new name[32], authid[32] 
		get_user_name(id, name, 31) 
		get_user_authid(id, authid, 31) 
		
		#if CIRCUM_LOG_TO_FILE == 1 
		new userip[16] 
		get_user_ip(id, userip, 15, 1) 
		log_to_file("bhdetected.log", "<%s><Auth ID: %s><IP: %s><ANTI-BUZZ circumvention was used>", name, authid, userip) 
		#endif 
		
		#if CIRCUM_DISPLAY_HUD_MSG == 1 
		new huddisplay[128] 
		format(huddisplay, 127, "Buzz Hook detected on %s^nAuth ID: %s", name, authid) 
		set_hudmessage(200, 100, 10, -1.0, 0.25, 0, 0.1, 5.0, 0.5, 0.5, 4) 
		show_hudmessage(0, huddisplay) 
		#endif 
		
		#if CIRCUM_BAN_SOUND == 1
		client_cmd(0,"spk misc/detect_01.wav")	
		#endif
		
		#if CIRCUM_PRINT_TO_ALL_CONSOLE == 1 
		client_print(0, print_console, "[AMX] Buzz Hook circumvented detected on %s <Auth ID: %s>", name, authid) 
		#endif 
		
		#if CIRCUM_PRINT_TO_ADMIN_CHAT == 1 
		for ( new i = 1; i <= get_maxplayers(); i++) 
			{ 
			if (get_user_flags(i)&ADMIN_CHAT) 
				{ 
				client_print(i, print_chat, "[AMX] Buzz Hook detected on %s <Auth ID: %s>", name, authid) 
			} 
		} 
		#endif 
		#if CIRCUM_DISPLAY_CON_MSG == 1 
		client_print(id, print_console, "%s", DETECTED_MSG) 
		#endif 
		#if CIRCUM_BAN_IF_DETECTED == 1 
		set_task(2.0, "bancircumventer", 2, authid, 31) 
		#endif 
		
	} 
	return PLUGIN_HANDLED 
} 

public specialdetected(id) 
	{ 
	if (!detectedusers[id] && is_user_alive(id)) { 
		detectedusers[id] = 1 
		new name[32], authid[32] 
		get_user_name(id, name, 31) 
		get_user_authid(id, authid, 31) 
		
		#if LOG_TO_FILE == 1 
		new userip[16] 
		get_user_ip(id, userip, 15, 1) 
		log_to_file("bhdetected.log", "<%s><Auth ID: %s><IP: %s><Illegal script was used>", name, authid, userip) 
		#endif 
		
		#if DISPLAY_HUD_MSG == 1 
		new huddisplay[128] 
		format(huddisplay, 127, "Illeagal scripts detected on %s^nAuth ID: %s", name, authid) 
		set_hudmessage(200, 100, 10, -1.0, 0.25, 0, 0.1, 5.0, 0.5, 0.5, 4) 
		show_hudmessage(0, huddisplay) 
		#endif 
		
		#if BAN_SOUND == 1
		client_cmd(0,"spk misc/detect_01.wav")	
		#endif
		
		#if PRINT_TO_ALL_CONSOLE == 1 
		client_print(0, print_console, "[AMX] Bunny hop script detected on %s <Auth ID: %s>", name, authid) 
		#endif 
		
		#if PRINT_TO_ADMIN_CHAT == 1 
		for ( new i = 1; i <= get_maxplayers(); i++) 
			{ 
			if (get_user_flags(i)&ADMIN_CHAT) 
				{ 
				client_print(i, print_chat, "[AMX] Bunny hop script detected on %s <Auth ID: %s>", name, authid) 
			} 
		} 
		#endif 
		
		#if DISPLAY_CON_MSG == 1 
		client_print(id, print_console, "%s", DETECTED_MSG) 
		#endif 
		#if BAN_IF_DETECTED == 1 
		set_task(2.0, "banuser", 2, authid, 31) 
		#endif 
		
	} 
	return PLUGIN_HANDLED 
} 

public bancircumventer(params[]) 
	{ 
	new hack_amxban = get_cvar_num("hack_amxban")
	new reason[31] = "[ANTIBUZZ] Buzz Hook Detected"
	
	// check if ban via amxban is enabled
	if( hack_amxban == 1)
		{
		// here the ban is done by amxbans
		server_cmd("amx_ban %i %s %s", S_BAN_TIME, params, reason )
		server_cmd("banid ^"%i^" ^"%s^" kick", S_BAN_TIME, params) 
		server_cmd("kick #%d", params)
		server_cmd("writeid")
	}
	else 
		{
		// here the ban is done normaly
		server_cmd("banid ^"%i^" ^"%s^" kick", S_BAN_TIME, params) 
		server_cmd("kick #%d", params)
		server_cmd("writeid")
	}
}

public banuser(params[]) 
	{ 
	new hack_amxban = get_cvar_num("hack_amxban")
	new reason[35] = "[ANTIBUZZ] Illegal Script Detected"
	
	// check if ban via amxban is enabled
	if( hack_amxban == 1)
		{
		// here the ban is done by amxbans
		server_cmd("amx_ban %i %s %s", S_BAN_TIME, params, reason )
		server_cmd("banid ^"%i^" ^"%s^" kick", S_BAN_TIME, params) 
		server_cmd("kick #%d", params)
		server_cmd("writeid")
	}
	else 
		{
		// here the ban is done normaly
		server_cmd("banid ^"%i^" ^"%s^" kick", S_BAN_TIME, params) 
		server_cmd("kick #%d", params)
		server_cmd("writeid")
	}
}

public client_disconnect(id) 
	{ 
	detectedusers[id] = 0 
} 

public client_connect(id) 
	{   
	return PLUGIN_CONTINUE
} 

public client_authorized(id)
	{
	return PLUGIN_CONTINUE
}

///////////////////////////////////////////
// Client is in server, check for hacks  //
///////////////////////////////////////////
public client_putinserver(id)
	{
	checkforbuzzhook(id)
	checkforaimbotti(id)
	checkforpft(id)
	checkforpenaro(id)
	checkfortalis(id)
	checkforaimbot(id)
	checkfor_s(id)
	checkfor_s2(id)
	checkfor_s3(id)
}

//////////////////////
// Buzz hook Detect //
///////////////////////////////////////////////////////
//  The Lines 'if (equal(s4info, "pige0n"))' and     //
//  'if(strlen(s4info) > 0)' are used to choose      //
//  your BuzzHook detection method. The line         //
//  'if (equal(s4info, "pige0n"))' is commented out  //
//  by default and is used to detect only hackers    //
//  who have not modified thier Buzz Hook to set s4  //
//  to something else. The other detection line,     //
//  'if(strlen(s4info) > 0)' is used to detect if s4 //
//  is set to any value and is recommended.          //
///////////////////////////////////////////////////////
public checkforbuzzhook(id) 
	{ 
	new s4info[32]; 
	get_user_info(id,"s4",s4info,31) 
	//if (equal(s4info, "pige0n"))
	if(strlen(s4info) > 0)
		{ 
		new name[32], authid[32] 
		get_user_name(id, name, 31) 
		get_user_authid(id, authid, 31) 
		
		#if BUZZ_LOG_TO_FILE == 1 
		new userip[16] 
		get_user_ip(id, userip, 15, 1) 
		log_to_file("bhdetected.log", "<%s><Auth ID: %s><IP: %s><Buzz Hook has been used by this player>", name, authid, userip) 
		#endif 
		
		#if BUZZ_DISPLAY_HUD_MSG == 1 
		new huddisplay[128] 
		format(huddisplay, 127, "Buzz Hook detected on %s^nAuth ID: %s", name, authid) 
		set_hudmessage(200, 100, 10, -1.0, 0.25, 0, 0.1, 5.0, 0.5, 0.5, 4) 
		show_hudmessage(0, huddisplay) 
		#endif 
		
		#if BUZZ_SOUND == 1
		client_cmd(0,"spk misc/detect_01.wav")	
		#endif
		
		#if BUZZ_PRINT_TO_ALL_CONSOLE == 1 
		client_print(0, print_console, "[ALERT!] Buzz Hook Natural-Selection HACK detected on %s <Auth ID: %s>", name, authid) 
		#endif 
		
		#if BUZZ_DISPLAY_CON_MSG == 1 
		client_print(id, print_console, "%s", BUZZ_DETECTED_MSG) 
		#endif 
		
		#if BUZZ_BAN_IF_DETECTED == 1 
		set_task(2.0, "buzz_banuser", 2, authid, 31) 
		#endif 
		
		#if BUZZ_PRINT_TO_ADMIN_CHAT == 1 
		for ( new i = 1; i <= get_maxplayers(); i++) 
			{ 
			if (get_user_flags(i)&ADMIN_CHAT) 
				{ 
				client_print(i, print_chat, "[ALERT!] Buzz Hook Natural-Selection HACK detected on %s <Auth ID: %s>", name, authid) 
			} 
		} 
		#endif 
		
	} 
	return PLUGIN_HANDLED 
} 

public buzz_banuser(params[]) 
	{ 
	new hack_amxban = get_cvar_num("hack_amxban")
	new reason[31] = "[ANTIBUZZ] Buzz Hook Detected"
	
	// check if ban via amxban is enabled
	if( hack_amxban == 1)
		{
		// here the ban is done by amxbans
		server_cmd("amx_ban %i %s %s", S_BAN_TIME, params, reason )
		server_cmd("banid ^"%i^" ^"%s^" kick", S_BAN_TIME, params) 
		server_cmd("kick #%d", params)
		server_cmd("writeid")
	}
	else 
		{
		// here the ban is done normaly
		server_cmd("banid ^"%i^" ^"%s^" kick", S_BAN_TIME, params) 
		server_cmd("kick #%d", params)
		server_cmd("writeid")
	}
}

//////////////////////
// aimbotti  Detect //
//////////////////////

public checkforaimbotti(id)
	{
	new aimbottiinfo[32]; 
	get_user_info(id,"aimbotti",aimbottiinfo,31)
	
	if(strlen(aimbottiinfo) > 0)
		{ 
		new name[32], authid[32] 
		get_user_name(id, name, 31) 
		get_user_authid(id, authid, 31) 
		
		#if AIMBOTTI_LOG_TO_FILE == 1 
		new userip[16] 
		get_user_ip(id, userip, 15, 1) 
		log_to_file("bhdetected.log", "<%s><Auth ID: %s><IP: %s><Aimbotti has been used by this player>", name, authid, userip) 
		#endif 
		
		#if AIMBOTTI_DISPLAY_HUD_MSG == 1 
		new huddisplay[128] 
		format(huddisplay, 127, "Aimbotti detected on %s^nAuth ID: %s", name, authid) 
		set_hudmessage(200, 100, 10, -1.0, 0.25, 0, 0.1, 5.0, 0.5, 0.5, 4) 
		show_hudmessage(0, huddisplay) 
		#endif 
		
		#if AIMBOTTI_SOUND == 1
		client_cmd(0,"spk misc/detect_01.wav")	
		
		#endif
		
		#if AIMBOTTI_PRINT_TO_ALL_CONSOLE == 1 
		client_print(0, print_console, "[ALERT!] Aimbotti HACK detected on %s <Auth ID: %s>", name, authid) 
		#endif 
		
		#if AIMBOTTI_DISPLAY_CON_MSG == 1 
		client_print(id, print_console, "%s", AIMBOTTI_DETECTED_MSG) 
		#endif 
		
		#if AIMBOTTI_BAN_IF_DETECTED == 1 
		set_task(2.0, "aimbotti_banuser", 2, authid, 31) 
		#endif 
		
		#if AIMBOTTI_PRINT_TO_ADMIN_CHAT == 1 
		for ( new i = 1; i <= get_maxplayers(); i++) 
			{ 
			if (get_user_flags(i)&ADMIN_CHAT) 
				{ 
				client_print(i, print_chat, "[ALERT!] Aimbotti HACK detected on %s <Auth ID: %s>", name, authid) 
			} 
		} 
		#endif 
		
	} 
	return PLUGIN_HANDLED 
}

public aimbotti_banuser(params[]) 
	{ 
	new hack_amxban = get_cvar_num("hack_amxban")
	new reason[30] = "[ANTIBUZZ] Aimbotti Detected"
	
	// check if ban via amxban is enabled
	if( hack_amxban == 1)
		{
		// here the ban is done by amxbans
		server_cmd("amx_ban %i %s %s", S_BAN_TIME, params, reason )
		server_cmd("banid ^"%i^" ^"%s^" kick", S_BAN_TIME, params) 
		server_cmd("kick #%d", params)
		server_cmd("writeid")
	}
	else 
		{
		// here the ban is done normaly
		server_cmd("banid ^"%i^" ^"%s^" kick", S_BAN_TIME, params) 
		server_cmd("kick #%d", params)
		server_cmd("writeid")
	}
}  

//////////////////////
// PFT Hack  Detect //
//////////////////////

public checkforpft(id)
	{
	new panzerfausthaxinfo[32]; 
	get_user_info(id,"panzerfausthax",panzerfausthaxinfo,31)
	
	if(strlen(panzerfausthaxinfo) > 0)  //  Key and Value detect
		{ 
		new name[32], authid[32] 
		get_user_name(id, name, 31) 
		get_user_authid(id, authid, 31) 
		
		#if PFT_LOG_TO_FILE == 1 
		new userip[16] 
		get_user_ip(id, userip, 15, 1) 
		log_to_file("bhdetected.log", "<%s><Auth ID: %s><IP: %s><PFT hack has been used by this player>", name, authid, userip) 
		#endif 
		
		#if PFT_DISPLAY_HUD_MSG == 1 
		new huddisplay[128] 
		format(huddisplay, 127, "PFT hack detected on %s^nAuth ID: %s", name, authid) 
		set_hudmessage(200, 100, 10, -1.0, 0.25, 0, 0.1, 5.0, 0.5, 0.5, 4) 
		show_hudmessage(0, huddisplay) 
		#endif 
		
		#if PFT_SOUND == 1
		client_cmd(0,"spk misc/detect_01.wav")	
		
		#endif
		
		#if PFT_PRINT_TO_ALL_CONSOLE == 1 
		client_print(0, print_console, "[ALERT!] PFT HACK detected on %s <Auth ID: %s>", name, authid) 
		#endif 
		
		#if PFT_DISPLAY_CON_MSG == 1 
		client_print(id, print_console, "%s", PFT_DETECTED_MSG) 
		#endif 
		
		#if PFT_BAN_IF_DETECTED == 1 
		set_task(2.0, "pft_banuser", 2, authid, 31) 
		#endif 
		
		#if PFT_PRINT_TO_ADMIN_CHAT == 1 
		for ( new i = 1; i <= get_maxplayers(); i++) 
			{ 
			if (get_user_flags(i)&ADMIN_CHAT) 
				{ 
				client_print(i, print_chat, "[ALERT!] PFT HACK detected on %s <Auth ID: %s>", name, authid) 
			} 
		} 
		#endif 
		
	} 
	return PLUGIN_HANDLED 
}

public pft_banuser(params[]) 
	{ 
	new hack_amxban = get_cvar_num("hack_amxban")
	new reason[28] = "[ANTIBUZZ] PFThax Detected"
	
	// check if ban via amxban is enabled
	if( hack_amxban == 1)
		{
		// here the ban is done by amxbans
		server_cmd("amx_ban %i %s %s", S_BAN_TIME, params, reason )
		server_cmd("banid ^"%i^" ^"%s^" kick", S_BAN_TIME, params) 
		server_cmd("kick #%d", params)
		server_cmd("writeid")
	}
	else 
		{
		// here the ban is done normaly
		server_cmd("banid ^"%i^" ^"%s^" kick", S_BAN_TIME, params) 
		server_cmd("kick #%d", params)
		server_cmd("writeid")
	}
}  

/////////////////////////
// Penaro Hack  Detect //
/////////////////////////

public checkforpenaro(id)
	{
	new penaroinfo[32]; 
	get_user_info(id,"penaro",penaroinfo,31)
	
	if(strlen(penaroinfo) > 0)  //  Key and Value detect
		{ 
		new name[32], authid[32] 
		get_user_name(id, name, 31) 
		get_user_authid(id, authid, 31) 
		
		#if PENARO_LOG_TO_FILE == 1 
		new userip[16] 
		get_user_ip(id, userip, 15, 1) 
		log_to_file("bhdetected.log", "<%s><Auth ID: %s><IP: %s><Penaro hack has been used by this player>", name, authid, userip) 
		#endif 
		
		#if PENARO_DISPLAY_HUD_MSG == 1 
		new huddisplay[128] 
		format(huddisplay, 127, "Penaro detected on %s^nAuth ID: %s", name, authid) 
		set_hudmessage(200, 100, 10, -1.0, 0.25, 0, 0.1, 5.0, 0.5, 0.5, 4) 
		show_hudmessage(0, huddisplay) 
		#endif 
		
		#if PENARO_SOUND == 1
		client_cmd(0,"spk misc/detect_01.wav")	
		
		#endif
		
		#if PENARO_PRINT_TO_ALL_CONSOLE == 1 
		client_print(0, print_console, "[ALERT!] Penaro HACK detected on %s <Auth ID: %s>", name, authid) 
		#endif 
		
		#if PENARO_DISPLAY_CON_MSG == 1 
		client_print(id, print_console, "%s", PENARO_DETECTED_MSG) 
		#endif 
		
		#if PENARO_BAN_IF_DETECTED == 1 
		set_task(2.0, "penaro_banuser", 2, authid, 31) 
		#endif 
		
		#if PENARO_PRINT_TO_ADMIN_CHAT == 1 
		for ( new i = 1; i <= get_maxplayers(); i++) 
			{ 
			if (get_user_flags(i)&ADMIN_CHAT) 
				{ 
				client_print(i, print_chat, "[ALERT!] Penaro HACK detected on %s <Auth ID: %s>", name, authid) 
			} 
		} 
		#endif 
		
	} 
	return PLUGIN_HANDLED 
}

public penaro_banuser(params[]) 
	{ 
	new hack_amxban = get_cvar_num("hack_amxban")
	new reason[28] = "[ANTIBUZZ] Penaro Detected"
	
	// check if ban via amxban is enabled
	if( hack_amxban == 1)
		{
		// here the ban is done by amxbans
		server_cmd("amx_ban %i %s %s", S_BAN_TIME, params, reason )
		server_cmd("banid ^"%i^" ^"%s^" kick", S_BAN_TIME, params) 
		server_cmd("kick #%d", params)
		server_cmd("writeid")
	}
	else 
		{
		// here the ban is done normaly
		server_cmd("banid ^"%i^" ^"%s^" kick", S_BAN_TIME, params) 
		server_cmd("kick #%d", params)
		server_cmd("writeid")
	}
}  

/////////////////////////
// talis Hack  Detect //
/////////////////////////

public checkfortalis(id)
	{
	new talisinfo[32]; 
	get_user_info(id,"talis",talisinfo,31)
	
	if(strlen(talisinfo) > 0)  //  Key and Value detect
		{ 
		new name[32], authid[32] 
		get_user_name(id, name, 31) 
		get_user_authid(id, authid, 31) 
		
		#if TALIS_LOG_TO_FILE == 1 
		new userip[16] 
		get_user_ip(id, userip, 15, 1) 
		log_to_file("bhdetected.log", "<%s><Auth ID: %s><IP: %s><talis hack has been used by this player>", name, authid, userip) 
		#endif 
		
		#if TALIS_DISPLAY_HUD_MSG == 1 
		new huddisplay[128] 
		format(huddisplay, 127, "talis detected on %s^nAuth ID: %s", name, authid) 
		set_hudmessage(200, 100, 10, -1.0, 0.25, 0, 0.1, 5.0, 0.5, 0.5, 4) 
		show_hudmessage(0, huddisplay) 
		#endif 
		
		#if TALIS_SOUND == 1
		client_cmd(0,"spk misc/detect_01.wav")	
		
		#endif
		
		#if TALIS_PRINT_TO_ALL_CONSOLE == 1 
		client_print(0, print_console, "[ALERT!] talis HACK detected on %s <Auth ID: %s>", name, authid) 
		#endif 
		
		#if TALIS_DISPLAY_CON_MSG == 1 
		client_print(id, print_console, "%s", TALIS_DETECTED_MSG) 
		#endif 
		
		#if TALIS_BAN_IF_DETECTED == 1 
		set_task(2.0, "talis_banuser", 2, authid, 31) 
		#endif 
		
		#if TALIS_PRINT_TO_ADMIN_CHAT == 1 
		for ( new i = 1; i <= get_maxplayers(); i++) 
			{ 
			if (get_user_flags(i)&ADMIN_CHAT) 
				{ 
				client_print(i, print_chat, "[ALERT!] talis HACK detected on %s <Auth ID: %s>", name, authid) 
			} 
		} 
		#endif 
		
	} 
	return PLUGIN_HANDLED 
}

public talis_banuser(params[]) 
	{ 
	new hack_amxban = get_cvar_num("hack_amxban")
	new reason[27] = "[ANTIBUZZ] Talis Detected"
	
	// check if ban via amxban is enabled
	if( hack_amxban == 1)
		{
		// here the ban is done by amxbans
		server_cmd("amx_ban %i %s %s", S_BAN_TIME, params, reason )
		server_cmd("banid ^"%i^" ^"%s^" kick", S_BAN_TIME, params) 
		server_cmd("kick #%d", params)
		server_cmd("writeid")
	}
	else 
		{
		// here the ban is done normaly
		server_cmd("banid ^"%i^" ^"%s^" kick", S_BAN_TIME, params) 
		server_cmd("kick #%d", params)
		server_cmd("writeid")
	}
}  

////////////////////
// Aimbot  Detect //
////////////////////

public checkforaimbot(id)
	{
	new aimbotinfo[32]; 
	get_user_info(id,"aimbot",aimbotinfo,31)
	
	if(strlen(aimbotinfo) > 0)  //  Key and Value detect
		{ 
		new name[32], authid[32] 
		get_user_name(id, name, 31) 
		get_user_authid(id, authid, 31) 
		
		#if AIMBOT_LOG_TO_FILE == 1 
		new userip[16] 
		get_user_ip(id, userip, 15, 1) 
		log_to_file("bhdetected.log", "<%s><Auth ID: %s><IP: %s><aimbot hack has been used by this player>", name, authid, userip) 
		#endif 
		
		#if AIMBOT_DISPLAY_HUD_MSG == 1 
		new huddisplay[128] 
		format(huddisplay, 127, "aimbot detected on %s^nAuth ID: %s", name, authid) 
		set_hudmessage(200, 100, 10, -1.0, 0.25, 0, 0.1, 5.0, 0.5, 0.5, 4) 
		show_hudmessage(0, huddisplay) 
		#endif 
		
		#if AIMBOT_SOUND == 1
		client_cmd(0,"spk misc/detect_01.wav")	
		
		#endif
		
		#if AIMBOT_PRINT_TO_ALL_CONSOLE == 1 
		client_print(0, print_console, "[ALERT!] aimbot HACK detected on %s <Auth ID: %s>", name, authid) 
		#endif 
		
		#if AIMBOT_DISPLAY_CON_MSG == 1 
		client_print(id, print_console, "%s", AIMBOT_DETECTED_MSG) 
		#endif 
		
		#if AIMBOT_BAN_IF_DETECTED == 1 
		set_task(2.0, "aimbot_banuser", 2, authid, 31) 
		#endif 
		
		#if AIMBOT_PRINT_TO_ADMIN_CHAT == 1 
		for ( new i = 1; i <= get_maxplayers(); i++) 
			{ 
			if (get_user_flags(i)&ADMIN_CHAT) 
				{ 
				client_print(i, print_chat, "[ALERT!] aimbot HACK detected on %s <Auth ID: %s>", name, authid) 
			} 
		} 
		#endif 
		
	} 
	return PLUGIN_HANDLED 
}

public aimbot_banuser(params[]) 
	{ 
	new hack_amxban = get_cvar_num("hack_amxban")
	new reason[28] = "[ANTIBUZZ] Aimbot Detected"
	
	// check if ban via amxban is enabled
	if( hack_amxban == 1)
		{
		// here the ban is done by amxbans
		server_cmd("amx_ban %i %s %s", S_BAN_TIME, params, reason )
		server_cmd("banid ^"%i^" ^"%s^" kick", S_BAN_TIME, params) 
		server_cmd("kick #%d", params)
		server_cmd("writeid")
	}
	else 
		{
		// here the ban is done normaly
		server_cmd("banid ^"%i^" ^"%s^" kick", S_BAN_TIME, params) 
		server_cmd("kick #%d", params)
		server_cmd("writeid")
	}
}  

/////////////////////
// S value  Detect //
/////////////////////

public checkfor_s(id)
	{
	new sinfo[32]; 
	get_user_info(id,"s",sinfo,31)
	
	if(strlen(sinfo) > 0)  
		{ 
		new name[32], authid[32] 
		get_user_name(id, name, 31) 
		get_user_authid(id, authid, 31) 
		
		#if S_LOG_TO_FILE == 1 
		new userip[16] 
		get_user_ip(id, userip, 15, 1) 
		log_to_file("bhdetected.log", "<%s><Auth ID: %s><IP: %s><S value (hack) has been used by this player>", name, authid, userip) 
		#endif 
		
		#if S_DISPLAY_HUD_MSG == 1 
		new huddisplay[128] 
		format(huddisplay, 127, "S value (hack) detected on %s^nAuth ID: %s", name, authid) 
		set_hudmessage(200, 100, 10, -1.0, 0.25, 0, 0.1, 5.0, 0.5, 0.5, 4) 
		show_hudmessage(0, huddisplay) 
		#endif 
		
		#if S_SOUND == 1
		client_cmd(0,"spk misc/detect_01.wav")	
		
		#endif
		
		#if S_PRINT_TO_ALL_CONSOLE == 1 
		client_print(0, print_console, "[ALERT!] S value (hack) detected on %s <Auth ID: %s>", name, authid) 
		#endif 
		
		#if S_DISPLAY_CON_MSG == 1 
		client_print(id, print_console, "%s", S_DETECTED_MSG) 
		#endif 
		
		#if S_BAN_IF_DETECTED == 1 
		set_task(2.0, "s_banuser", 2, authid, 31) 
		#endif 
		
		#if S_PRINT_TO_ADMIN_CHAT == 1 
		for ( new i = 1; i <= get_maxplayers(); i++) 
			{ 
			if (get_user_flags(i)&ADMIN_CHAT) 
				{ 
				client_print(i, print_chat, "[ALERT!] S value (hack) detected on %s <Auth ID: %s>", name, authid) 
			} 
		} 
		#endif 
		
	} 
	return PLUGIN_HANDLED 
}


public s_banuser(params[]) 
	{ 
	new hack_amxban = get_cvar_num("hack_amxban")
	new reason[40] = "[ANTIBUZZ] Modified Buzz Hook Detected"
	
	// check if ban via amxban is enabled
	if( hack_amxban == 1)
		{
		// here the ban is done by amxbans
		server_cmd("amx_ban %i %s %s", S_BAN_TIME, params, reason )
		server_cmd("banid ^"%i^" ^"%s^" kick", S_BAN_TIME, params) 
		server_cmd("kick #%d", params)
		server_cmd("writeid")
	}
	else 
		{
		// here the ban is done normaly
		server_cmd("banid ^"%i^" ^"%s^" kick", S_BAN_TIME, params) 
		server_cmd("kick #%d", params)
		server_cmd("writeid")
	}
}  

//////////////////////
// S2 value  Detect //
//////////////////////

public checkfor_s2(id)
	{
	new s2info[32]; 
	get_user_info(id,"s2",s2info,31)
	
	if(strlen(s2info) > 0)
		{ 
		new name[32], authid[32] 
		get_user_name(id, name, 31) 
		get_user_authid(id, authid, 31) 
		
		#if S_LOG_TO_FILE == 1 
		new userip[16] 
		get_user_ip(id, userip, 15, 1) 
		log_to_file("bhdetected.log", "<%s><Auth ID: %s><IP: %s><S2 value (hack) has been used by this player>", name, authid, userip) 
		#endif 
		
		#if S_DISPLAY_HUD_MSG == 1 
		new huddisplay[128] 
		format(huddisplay, 127, "S2 value (hack) detected on %s^nAuth ID: %s", name, authid) 
		set_hudmessage(200, 100, 10, -1.0, 0.25, 0, 0.1, 5.0, 0.5, 0.5, 4) 
		show_hudmessage(0, huddisplay) 
		#endif 
		
		#if S_SOUND == 1
		client_cmd(0,"spk misc/detect_01.wav")	
		
		#endif
		
		#if S_PRINT_TO_ALL_CONSOLE == 1 
		client_print(0, print_console, "[ALERT!] S2 value (hack) detected on %s <Auth ID: %s>", name, authid) 
		#endif 
		
		#if S_DISPLAY_CON_MSG == 1 
		client_print(id, print_console, "%s", S_DETECTED_MSG) 
		#endif 
		
		#if S_BAN_IF_DETECTED == 1 
		set_task(2.0, "s2_banuser", 2, authid, 31) 
		#endif 
		
		#if S_PRINT_TO_ADMIN_CHAT == 1 
		for ( new i = 1; i <= get_maxplayers(); i++) 
			{ 
			if (get_user_flags(i)&ADMIN_CHAT) 
				{ 
				client_print(i, print_chat, "[ALERT!] S2 value (hack) detected on %s <Auth ID: %s>", name, authid) 
			} 
		} 
		#endif 
		
	} 
	return PLUGIN_HANDLED 
}


public s2_banuser(params[]) 
	{ 
	new hack_amxban = get_cvar_num("hack_amxban")
	new reason[40] = "[ANTIBUZZ] Modified Buzz Hook Detected"
	
	// check if ban via amxban is enabled
	if( hack_amxban == 1)
		{
		// here the ban is done by amxbans
		server_cmd("amx_ban %i %s %s", S_BAN_TIME, params, reason )
		server_cmd("banid ^"%i^" ^"%s^" kick", S_BAN_TIME, params) 
		server_cmd("kick #%d", params)
		server_cmd("writeid")
	}
	else 
		{
		// here the ban is done normaly
		server_cmd("banid ^"%i^" ^"%s^" kick", S_BAN_TIME, params) 
		server_cmd("kick #%d", params)
		server_cmd("writeid")
	}
}  


//////////////////////
// S3 value  Detect //
//////////////////////

public checkfor_s3(id)
	{
	new s3info[32]; 
	get_user_info(id,"s3",s3info,31)
	
	if(strlen(s3info) > 0)  
		{ 
		new name[32], authid[32] 
		get_user_name(id, name, 31) 
		get_user_authid(id, authid, 31) 
		
		#if S_LOG_TO_FILE == 1 
		new userip[16] 
		get_user_ip(id, userip, 15, 1) 
		log_to_file("bhdetected.log", "<%s><Auth ID: %s><IP: %s><S3 value (hack) has been used by this player>", name, authid, userip) 
		#endif 
		
		#if S_DISPLAY_HUD_MSG == 1 
		new huddisplay[128] 
		format(huddisplay, 127, "S3 value (hack) detected on %s^nAuth ID: %s", name, authid) 
		set_hudmessage(200, 100, 10, -1.0, 0.25, 0, 0.1, 5.0, 0.5, 0.5, 4) 
		show_hudmessage(0, huddisplay) 
		#endif 
		
		#if S_SOUND == 1
		client_cmd(0,"spk misc/detect_01.wav")	
		
		#endif
		
		#if S_PRINT_TO_ALL_CONSOLE == 1 
		client_print(0, print_console, "[ALERT!] S3 value (hack) detected on %s <Auth ID: %s>", name, authid) 
		#endif 
		
		#if S_DISPLAY_CON_MSG == 1 
		client_print(id, print_console, "%s", S_DETECTED_MSG) 
		#endif 
		
		#if S_BAN_IF_DETECTED == 1 
		set_task(2.0, "s3_banuser", 2, authid, 31) 
		#endif 
		
		#if S_PRINT_TO_ADMIN_CHAT == 1 
		for ( new i = 1; i <= get_maxplayers(); i++) 
			{ 
			if (get_user_flags(i)&ADMIN_CHAT) 
				{ 
				client_print(i, print_chat, "[ALERT!] S3 value (hack) detected on %s <Auth ID: %s>", name, authid) 
			} 
		} 
		#endif 
		
	} 
	return PLUGIN_HANDLED 
}

public s3_banuser(params[]) 
	{ 
	new hack_amxban = get_cvar_num("hack_amxban")
	new reason[40] = "[ANTIBUZZ] Modified Buzz Hook Detected"
	
	// check if ban via amxban is enabled
	if( hack_amxban == 1)
		{
		// here the ban is done by amxbans
		server_cmd("amx_ban %i %s %s", S_BAN_TIME, params, reason )
		server_cmd("banid ^"%i^" ^"%s^" kick", S_BAN_TIME, params) 
		server_cmd("kick #%d", params)
		server_cmd("writeid")
	}
	else 
		{
		// here the ban is done normaly
		server_cmd("banid ^"%i^" ^"%s^" kick", S_BAN_TIME, params) 
		server_cmd("kick #%d", params)
		server_cmd("writeid")
	}
}