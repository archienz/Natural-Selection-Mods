/*
*
*
*				    Night Vision - Reborn
*
*  					by semaja2 / peachy
*  			     orginal code base by mahnsawce
*			  some code used from ava_enable by DDR Khat
*
*  				  E-Mail: semaja2[AT]gmail.com
* 			This plugin was brought to you by the number PI,
*		http://3.141592653589793238462643383279502884197169399375105820974944592.com
*
*
* Description: Allows any player in game to enable the use of Night Vision and/or Heat Vision
*
* Commands: say /nvg to enable night vision
*           say /hvg to enable heat vision
*           flashlight key (impulse 100) to use the night vision (for marines or readyroomers) or heat vision (for aliens)
*
* Changelog:
*	    Version 1.0 : Inital Release
*	    Version 1.1 : Added sound files
*			  Separated aliens from marines
*			  Removed engine module dependency
*			  Code clean up and optimisation
*			  Fixed minor bugs
*	    Version 1.2 : Fixed sound mixing up
*			  Added sound client info (say /nvsound)
*			  Fixed the glow disappering after 25 seconds
*
*/

#define PLUGIN "Night Vision - Reborn"
#define VERSION "1.2"
#define AUTHOR "semaja2.net / peachy"

/*
INT (1)
0 - Do use default helper output
1 - Use the "Helper" plugin! (recommended)
*/
#define HELPER 1

#include <amxmodx>
#include <fakemeta>
#include <ns>
#include <ns2amx>

#if HELPER == 1                                                                 // make sure we only include the helper if we actually want to use it! server ops may not have this file and therefor do not wish to include it, although it doesn't harm if the Helper is disabled
#include <helper>
#else
#define help_add set_localinfo                                                  // hax hax, this will allow us to use help_add although we did not include the helper
#endif                                                                          // it will replace all help_adds with set_localinfos. this doesn't do any harm as the forwards aren't called anyway
// this way is recommended as it requires the least work

//Sound files
#define USE_SOUND		1

#define NVG_ON			"nv_plugin/nv_on.wav"
#define NVG_OFF			"nv_plugin/nv_off.wav"
#define HVG_ON			"nv_plugin/tv_on.wav"
#define HVG_OFF			"nv_plugin/tv_off.wav"

//Who should recieve night vision
#define READYROOMNVG	1
#define MARINE1TEAMNVG	1
#define ALIEN1TEAMNVG	1
#define MARINE2TEAMNVG	1
#define ALIEN2TEAMNVG	1

// Night Vision stuff
new iFlashLight[33]
new iNVEnabled[33]
new iHVEnabled[33]
new iSoundEnabled[33]
new gmsgScreenFade

enum
{
	NV_RED = 0,
	NV_GREEN,
	NV_BLUE,
	NV_ALPHA,
	NV_LIGHT_RED,
	NV_LIGHT_GREEN,
	NV_LIGHT_BLUE,
	NV_MAX
}
//Colour array
//{RED, GREEN, BLUE, ALPHA, LIGHT RED, LIGHT GREEN, LIGHT BLUE}
new g_colors[5][NV_MAX] =
{
	//ReadyroomNVG
	{ 200,   0,200,   64,  0,   255, 0   },
	//Marine1teamNVG
	{ 0,   255, 0,   64,  0,   255, 0   },
	//Alien1teamNVG
	{ 220, 220, 54,  64,  165, 165, 54  },
	//Marine2teamNVG
	{ 255, 0,   0,   64,  255, 0,   0   },
	//Alien2teamNVG
	{ 255, 0,   0,   64,  255, 0,   0   }
}

#define NV_LIGHT_RADIUS	400

#define FFADE_IN		0x0000		// Just here so we don't pass 0 into the function
#define FFADE_OUT		0x0001		// Fade out (not in)
#define FFADE_MODULATE	0x0002		// Modulate (don't blend)
#define FFADE_STAYOUT	0x0004		// ignores the duration, stays faded out until new ScreenFade message received

#define TE_ELIGHT		28

#if USE_SOUND == 1
public plugin_precache()
{
	precache_sound(NVG_ON)
	precache_sound(NVG_OFF)
	precache_sound(HVG_ON)
	precache_sound(HVG_OFF)
}
#endif

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	if (is_plugin_loaded("AvAEnable") == -1)
	{
		gmsgScreenFade = get_user_msgid("ScreenFade")

		//Nightvision keys
		register_forward(FM_CmdStart, "CmdStart")

		//Nightvision enable/disable commands
		register_clcmd("say /nvg", "do_nvg")
		register_clcmd("say_team /nvg", "do_nvg")
		register_clcmd("say /hvg", "do_hvg")
		register_clcmd("say_team /hvg", "do_hvg")
		
		#if USE_SOUND == 1
		register_clcmd("say /nvsound", "do_sound")
		register_clcmd("say_team /nvsound", "do_sound")
		#endif
		
		register_event("ScreenFade","do_sf","b")
		register_event("DeathMsg","do_dm","ab")
		
		set_task(5.0,"checknv",0,"",0,"b")
	}
	else
	{
		//Paused because AvA enable is running
		pause("ad")
	}
	
}

public client_connect( id )
{
	new ret[32]
	get_user_info(id, "nvg", ret, 31)
	iNVEnabled[id] = (str_to_num(ret)) ? 1 : 0
	get_user_info(id, "hvg", ret, 31)
	iHVEnabled[id] = (str_to_num(ret)) ? 1 : 0
	get_user_info(id, "nvsound", ret, 31)
	iSoundEnabled[id] = (str_to_num(ret)) ? 1 : 0
}

public client_changeclass(id, newclass, oldclass)
{
	if (newclass == CLASS_COMMANDER || newclass == CLASS_DEAD)
	{
		iFlashLight[id] = 0
	}
}

public checknv()
{
	new i
	for (i=1;i<=get_maxplayers();i++)
	{
		if (is_entity(i) == 1 && iFlashLight[i] == 1)
		{
			//if (get_class(i) < 6 || get_class(i) > 8)
			//{
			//	iFlashLight[i]=0
			//}
			//else
				do_light(i)
		}
	}	
}

public do_nvg(id)
{
	if (iNVEnabled[id] == 0)
	{
		iNVEnabled[id] = 1
		ns_popup(id,"Night vision turned ON.")
	}
	else
	{
		iNVEnabled[id] = 0
		ns_popup(id,"Night vision turned OFF.")
	}
	client_cmd(id,"setinfo ^"nvg^" ^"%i^"",iNVEnabled[id])
	return PLUGIN_CONTINUE
	
}
#if USE_SOUND == 1
public do_sound(id)
{
	if (iSoundEnabled[id] == 0)
	{
		iSoundEnabled[id] = 1
		ns_popup(id,"Night/Heat vision sound turned ON.")
	}
	else
	{
		iSoundEnabled[id] = 0
		ns_popup(id,"Night/Heat vision sound turned OFF.")
	}
	client_cmd(id,"setinfo ^"nvsound^" ^"%i^"",iSoundEnabled[id])
	return PLUGIN_CONTINUE
	
}
#endif
public do_hvg(id)
{
	if (iHVEnabled[id] == 0)
	{
		iHVEnabled[id] = 1
		ns_popup(id,"Night vision turned ON.")
	}
	else
	{
		iHVEnabled[id] = 0
		ns_popup(id,"Night vision turned OFF.")
	}
	client_cmd(id,"setinfo ^"hvg^" ^"%i^"",iHVEnabled[id])
	return PLUGIN_CONTINUE
}

/////////////Night Vision////////////////////////////////
public do_dm( id )
{
	new deadid = read_data(2)
	if ( iFlashLight[deadid] )
	{
		do_nvoff(deadid)
		iFlashLight[deadid] = 0
	}
}

public do_nvon(nvuser)
{
	new team = pev(nvuser, pev_team)
	new origin[3]
	pev(nvuser, pev_origin, origin)
	
	message_begin( MSG_ONE, SVC_TEMPENTITY, origin, nvuser )
	write_byte(TE_ELIGHT)
	write_short(nvuser)
	write_coord(origin[0]) 
	write_coord(origin[1]) 
	write_coord(origin[2]) 
	write_coord(NV_LIGHT_RADIUS)
	write_byte(g_colors[team][NV_LIGHT_RED])
	write_byte(g_colors[team][NV_LIGHT_GREEN])
	write_byte(g_colors[team][NV_LIGHT_BLUE])
	write_byte(255)
	write_coord(0)
	message_end()

	message_begin(MSG_ONE, gmsgScreenFade, {0, 0, 0}, nvuser)
	write_short(1)
	write_short(2)
	write_short(FFADE_OUT | FFADE_STAYOUT)
	write_byte(g_colors[team][NV_RED])
	write_byte(g_colors[team][NV_GREEN])
	write_byte(g_colors[team][NV_BLUE])
	write_byte(g_colors[team][NV_ALPHA])
	message_end()
	
	//set_task(20.0, "do_light", 31400 + nvuser, "", 0, "b")
}

public do_light(nvuser)
{
	new team = pev(nvuser, pev_team)
	new origin[3]
	pev(nvuser, pev_origin, origin)

	message_begin( MSG_ONE, SVC_TEMPENTITY, origin, nvuser )
	write_byte(TE_ELIGHT)
	write_short(nvuser)
	write_coord(origin[0]) 
	write_coord(origin[1]) 
	write_coord(origin[2]) 
	write_coord(NV_LIGHT_RADIUS)
	write_byte(g_colors[team][NV_LIGHT_RED])
	write_byte(g_colors[team][NV_LIGHT_GREEN])
	write_byte(g_colors[team][NV_LIGHT_BLUE])
	write_byte(255)
	write_coord(0)
	message_end()
}

public do_nvoff(nvuser)
{
	new team = pev(nvuser, pev_team)
	new origin[3]
	pev(nvuser, pev_origin, origin)

	message_begin( MSG_ONE, SVC_TEMPENTITY, origin, nvuser )
	write_byte(TE_ELIGHT)
	write_short(nvuser)
	write_coord(origin[0]) 
	write_coord(origin[1]) 
	write_coord(origin[2]) 
	write_coord(NV_LIGHT_RADIUS)
	write_byte(0)
	write_byte(0)
	write_byte(0)
	write_byte(0)
	write_coord(0)
	message_end()

	message_begin(MSG_ONE, gmsgScreenFade, {0, 0, 0}, nvuser)
	write_short(1)
	write_short(2)
	write_short(FFADE_IN)
	write_byte(g_colors[team][NV_RED])
	write_byte(g_colors[team][NV_GREEN])
	write_byte(g_colors[team][NV_BLUE])
	write_byte(g_colors[team][NV_ALPHA])
	message_end()
	
	remove_task(31400 + nvuser)
}

public do_sf( id ) {
	iFlashLight[id] = 0
	new origin[3]
	pev(id, pev_origin, origin)

	message_begin( MSG_ONE, SVC_TEMPENTITY, origin, id )
	write_byte(TE_ELIGHT)
	write_short(id)
	write_coord(origin[0]) 
	write_coord(origin[1]) 
	write_coord(origin[2]) 
	write_coord(NV_LIGHT_RADIUS)
	write_byte(0)
	write_byte(0)
	write_byte(0)
	write_byte(0)
	write_coord(0)
	message_end()
}

public CmdStart( id, cmd, random_seed )
{
	if (get_uc(cmd, UC_Impulse) == 100)
	{
		new iTeam = pev(id, pev_team)
		switch (iTeam)
		{
		case 0, 1, 3:
			if ( iNVEnabled[id] )
			{
				switch (iTeam)
				{
#if READYROOMNVG == 0
				case 0:
					return FMRES_IGNORED
#endif
#if MARINE1TEAMNVG == 0
				case 1:
					return FMRES_IGNORED
#endif
#if MARINE2TEAMNVG == 0
				case 3:
					return FMRES_IGNORED
#endif
				}
				if ( iFlashLight[id] == 0 )
				{
					iFlashLight[id] = 1
					do_nvon(id)
#if USE_SOUND == 1
				if (iSoundEnabled[id] == 1)
					client_cmd(id, "spk %s", NVG_ON)
#endif
					set_uc(cmd, UC_Impulse, 0)
					return FMRES_SUPERCEDE
				}
				else
				{
					iFlashLight[id] = 0
					do_nvoff(id)
#if USE_SOUND == 1
				if (iSoundEnabled[id] == 1)
					client_cmd(id, "spk %s", NVG_OFF)
#endif
					set_uc(cmd, UC_Impulse, 0)
					return FMRES_SUPERCEDE
				}
			}
		case 2, 4:
			if ( iHVEnabled[id] )
			{
				switch (iTeam)
				{
#if ALIEN1TEAMNVG == 0
				case 2:
					return FMRES_IGNORED
#endif
#if ALIEN2TEAMNVG == 0
				case 4:
					return FMRES_IGNORED
#endif
				}
				if ( iFlashLight[id] == 0 )
				{
					iFlashLight[id] = 1
					do_nvon(id)
#if USE_SOUND == 1
				if (iSoundEnabled[id] == 1)
					client_cmd(id, "spk %s", HVG_ON)
#endif
					set_uc(cmd, UC_Impulse, 0)
					return FMRES_SUPERCEDE
				}
				else
				{
					iFlashLight[id] = 0
					do_nvoff(id)
#if USE_SOUND == 1
				if (iSoundEnabled[id] == 1)
					client_cmd(id, "spk %s", HVG_OFF)
#endif
					set_uc(cmd, UC_Impulse, 0)
					return FMRES_SUPERCEDE
				}
			}
		}
	}
	return FMRES_IGNORED
}

public send_info_nv(id)
{
	client_cmd(id,"setinfo ^"nvg^" ^"%i^"",iNVEnabled[id])
}

public send_info_hv(id)
{
	client_cmd(id,"setinfo ^"hvg^" ^"%i^"",iHVEnabled[id])
}

#if HELPER == 1
public client_help( id )
{
	help_add("Information", "NightVision")
	help_add("Usage", "In say type /nvg or /hvg to toggle nightvision or heatvision respectively^nThen press the flashlight key to use^n To disable the sound effects type /nvsound in say")
}

public client_advertise(id)	return PLUGIN_CONTINUE
#endif
