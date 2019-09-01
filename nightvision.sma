#include <amxmodx>
#include <ns2amx>

new iFlashLight[33]
new iFLEnabled[33]

#define NV_RED		100
#define NV_GREEN	200
#define NV_BLUE		100
#define NV_ALPHA	64

#define NV_LIGHT_RED	0
#define NV_LIGHT_GREEN	255
#define NV_LIGHT_BLUE	0
#define NV_LIGHT_RADIUS	400

#define FFADE_IN	0x0000		// Just here so we don't pass 0 into the function
#define FFADE_OUT	0x0001		// Fade out (not in)
#define FFADE_MODULATE	0x0002		// Modulate (don't blend)
#define FFADE_STAYOUT	0x0004		// ignores the duration, stays faded out until new ScreenFade message received
#define TE_ELIGHT			28


public plugin_init()
{
	for (new i = 0;i<=32;i++)
	{
		iFlashLight[i] = 0
		iFLEnabled[i] = 0
	}
	register_clcmd("say /nvg","donvg")
	register_clcmd("say_team /nvg","donvg")
	register_plugin("Night Vision AMX", "0.13.1", "mahnsawce")
	register_cvar("ns2amx_nightvision","0.13.1",4)
	register_impulse(100,"do_flashlight")
	register_clcmd("flashlight","do_flashlight")
	register_event("ScreenFade","do_sf","b")
	register_event("DeathMsg","do_dm","ab")
	set_task(5.0,"checknv",0,"",0,"b")
}
public plugin_precache()
{
	precache_sound("buttons/button3.wav")
}
public do_dm(id)
{
	if (iFlashLight[read_data(2)]==1)
	{
		donv_off(read_data(2))
	}
	iFlashLight[read_data(2)]=0
}
public checknv()
{
	new i
	for (i=1;i<=get_maxplayers();i++)
	{
		if (is_entity(i) == 1 && iFlashLight[i] == 1)
		{
			if (get_class(i) < 6 || get_class(i) > 8)
			{
				iFlashLight[i]=0
			}
			else
				donv_on(i)
		}
	}	
}
public donv_on(nvuser)
{
	new origin[3]
	get_user_origin(nvuser, origin)

	message_begin( MSG_ONE, SVC_TEMPENTITY, origin, nvuser )
	write_byte(TE_ELIGHT)
	write_short(nvuser) // entity to follow

   	write_coord( origin[0] ) 
   	write_coord( origin[1] ) 
   	write_coord( origin[2] ) 

	write_coord(NV_LIGHT_RADIUS) // radius

	write_byte(NV_LIGHT_RED) // color
	write_byte(NV_LIGHT_GREEN)
	write_byte(NV_LIGHT_BLUE)

	write_byte(255) // life
	write_coord(0) // decay
	message_end()
}
public donv_off(nvuser)
{
	new origin[3]
	get_user_origin(nvuser, origin)
	message_begin( MSG_ONE, SVC_TEMPENTITY, origin, nvuser )
	write_byte(TE_ELIGHT)
	write_short(nvuser) // entity to follow

   	write_coord( origin[0] ) 
   	write_coord( origin[1] ) 
   	write_coord( origin[2] ) 

	write_coord(NV_LIGHT_RADIUS) // radius

	write_byte(0) // color
	write_byte(0)
	write_byte(0)

	write_byte(0) // life
	write_coord(0) // decay
	message_end()
}
public client_putinserver(id)
{
	new ret[32];
	new i
	get_user_info(id,"nvg",ret,31)
	i = str_to_num(ret)
	if (i == 1)
	{
		iFLEnabled[id] = 1
	}
	else
	{
		iFLEnabled[id] = 0
	}
	iFlashLight[id]=1
}

public donvg(id)
{
	if (iFLEnabled[id] == 0)
	{
		iFLEnabled[id] = 1
		ns2amx_nspopup(id,"[AMX] Night vision for marines turned ON.")
	}
	else
	{
		iFLEnabled[id] = 0
		ns2amx_nspopup(id,"[AMX] Night vision for marines turned OFF.")
	}
	send_info(id)
	return PLUGIN_CONTINUE
	
}
public do_sf(id)
{
	iFlashLight[id]=0
	donv_off(id)
}
public do_flashlight(id)
{
	if (get_class(id) < 6 || get_class(id) > 8)
		return PLUGIN_CONTINUE
	if (iFlashLight[id] == 0)
	{
		if (entity_get_int(id,EV_INT_team) == 1 || entity_get_int(id,EV_INT_team) == 3)
		{
			if (iFLEnabled[id] == 1)
			{
				iFlashLight[id] = 1
				donv_on(id)
				//do_nv(id,1,2.0,get_cvar_num("sd_nv_alpha"),FFADE_OUT | FFADE_STAYOUT, get_cvar_num("sd_nv_red"),get_cvar_num("sd_nv_blue"),get_cvar_num("sd_nv_green"))
				//emit_sound(id, CHAN_ITEM,"buttons/button3.wav",1.0,ATTN_NORM,0,PITCH_NORM)
				do_nv(id,1,2.0,NV_ALPHA,FFADE_OUT | FFADE_STAYOUT, NV_RED, NV_BLUE, NV_GREEN)
				set_pev_i(id,pev_impulse,0)
				return PLUGIN_HANDLED
			}
		}
		return PLUGIN_CONTINUE
	}
	else
	{
		iFlashLight[id] = 0
		donv_off(id)
		//do_nv(id,1,2.0,get_cvar_num("sd_nv_alpha"),FFADE_IN, get_cvar_num("sd_nv_red"),get_cvar_num("sd_nv_blue"),get_cvar_num("sd_nv_green"))
		do_nv(id,1,2.0,NV_ALPHA,FFADE_IN, NV_RED, NV_BLUE, NV_GREEN)
		set_pev_i(id,pev_impulse,0)
		return PLUGIN_HANDLED
	}
	return PLUGIN_CONTINUE
}

public do_nv(id,duration,Float:hold,alpha,flags,red,blue,green)
{
	message_begin(MSG_ONE,get_user_msgid("ScreenFade"),{0,0,0},id)
	write_short(duration)
	write_short(floatround(hold))
	write_short(flags)
	write_byte(red)
	write_byte(green)
	write_byte(blue)
	write_byte(alpha)
	message_end()
}
public send_info(id)
{
	client_cmd(id,"setinfo ^"nvg^" ^"%i^"",iFLEnabled[id])
}