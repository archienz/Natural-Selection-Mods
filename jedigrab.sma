/* AMX Mod script.
*
* Jedi Force Grab
* by SpaceDude
* email: eayumns@nottingham.ac.uk
* MSN: eayumns@nottingham.ac.uk
* ICQ: 1615758
* IRC: Quakenet, nickname: "SpaceDude"
*
* Description:
*
* Another plugin for those admins who like to abuse their players and have a little fun.
* With this plugin you can literally pick players up, drag them around in the air and then
* depending on your mood either slam them into the ground or let them go free.
*
*
* Server Side Cvars:
*
* sv_grabforce - sets the amount of force used when grabbing players, default is 8
*
* sv_choketime - sets how long to choke players, default is 8
* 
* sv_throwforce - sets the power used when throwing players, default is 1500
*
* sv_glowred - sets red amount for glow
*
* sv_glowgreen - sets green amount for glow
*
* sv_glowblue - sets blue amount for glow
*
* Client Side Commands:
*
* +grab - bind a key to +grab like this: bind <key> +grab, once you have done that
* hold the key down and look at someone. Once you see their ID pop-up on
* the screen you will be able to drag them around, just look in the direction
* you want them to go and they will be dragged there. requires level ADMIN_SLAY.
*
* grab_toggle - works in the same way as +grab except it is a toggle press once to grab
* press a second time to release.
*
* +pull/+push - pulls or pushes the grabee towards/away from you as you hold the button.
* Atm its speed is set at 35, feel free to change it below.
*
* choke - chokes the grabee for 8 seconds (it damages the grabee with 3 hp per second)
*
* throw - throws the grabee
* Atm its power is set at 1500, feel free to change it below.
*
*
* Revision History:
* v1.6.2 (by KCE)- Added Disable/Enable cvar (amx_jedigrab 1|0 Enabled\Disable)
*		   Added cvar, sv_choketime, sets how long to choke person
*
* v1.6.1 (by KCE) - Fixed bug where if graber disconnected while grabbing someone, the grabee was not released
*
* v1.6 (by KCE) - Fixed glowing and added cvars to customize it
*               - Made buildings glow also
*               - Changed cmd names
*
* v1.5 (by KCE) - Ported back to AMX X 1.0
*		  Added cvar sv_throwforce to adjust throwing power ingame
*
* v1.4 (by KRoTaL) - Converted to AMX 0.9.9, added jedichoke command from the Star Wars Mod *plugin by Gev
*	           - Added throw command
*
* v1.3 (by BOB_SLAYER) - Added +push and +pull commands
*
* v1.2 (by kosmo111) - Added ability to grab entities
*
* v1.1
* - Added a grab_toggle as an alternative to +grab
* - Added notify messages
* - Made it possible to grab people while dead (works best in Free View mode)
*
* v1.0 - Initial Release
*/

#include <amxmodx>
#include <amxmisc>
#include <fun>
#include <engine>

new grabbed[33]
new grablength[33]
new bool:grabmodeon[33]
new velocity_multiplier
new Throw_force

#define JEDI ADMIN_LEVEL_A

stock is_player(id)
{
	for(new i = 1 ;i <= get_maxplayers() ;i++) 
	{ 
		if (i == id)
		{
			return true
		}
	}

	return false
}

public grabtask(parm[])
{
	new id = parm[0]
	new targetid, body
	if (!grabbed[id])
	{
		get_user_aiming(id, targetid, body)
		if (targetid)
		{
			set_grabbed(id, targetid)
		}
	}
	if (grabbed[id])
	{
		new origin[3], look[3], direction[3], moveto[3], Float:grabbedorigin[3], Float:velocity[3], length
		get_user_origin(id, origin, 1)
		get_user_origin(id, look, 3)
		entity_get_vector(grabbed[id], EV_VEC_origin, grabbedorigin)


		direction[0]=look[0]-origin[0]
		direction[1]=look[1]-origin[1]
		direction[2]=look[2]-origin[2]
		length = get_distance(look,origin)
		if (!length) length=1 // avoid division by 0

		moveto[0]=origin[0]+direction[0]*grablength[id]/length
		moveto[1]=origin[1]+direction[1]*grablength[id]/length
		moveto[2]=origin[2]+direction[2]*grablength[id]/length

		velocity[0]=(moveto[0]-grabbedorigin[0])*velocity_multiplier
		velocity[1]=(moveto[1]-grabbedorigin[1])*velocity_multiplier
		velocity[2]=(moveto[2]-grabbedorigin[2])*velocity_multiplier

		entity_set_vector(grabbed[id], EV_VEC_velocity, velocity)
	}
}

//Toggles grab.
public grab_toggle(id)
{
	if (get_cvar_num("amx_jedigrab")) 
	{
		if (grabmodeon[id])
			release(id)
		else
			grab(id)
	} 
	else 
	{
		client_print(id,print_chat,"[AMX] Jedi Grab has been disabled")
	}
	return PLUGIN_CONTINUE
}

//Actually does the grabbing. 
public grab(id)
{
	if (!(get_user_flags(id)&JEDI))
	{
		console_print(id,"[AMX] You have no access to that command")
		return PLUGIN_CONTINUE
	}
	if (get_cvar_num("amx_jedigrab")) 
	{
		if (!grabmodeon[id])
		{
			new targetid, body
			new parm[1]
			parm[0] = id
			velocity_multiplier = get_cvar_num("sv_grabforce")
			grabmodeon[id]=true
			set_task(0.1, "grabtask", 100+id, parm, 1, "b")
			get_user_aiming(id, targetid, body)
			if (targetid)
			{
				if (get_cvar_num("amx_jedigrab_playersonly"))
				{
					if (is_player(targetid))
						set_grabbed(id, targetid)
					else
						client_print(id,print_chat,"[AMX] You can only grab players")						
				}
				else
				{
					set_grabbed(id, targetid)				
				}
			}
			else
			{
				client_print(id,print_chat,"[AMX] Searching for a target")
			}
		}
	} 
	else 
	{
		client_print(id,print_chat,"[AMX] Jedi Grab has been disabled")
	}
		
	return PLUGIN_CONTINUE
}

//Releases the grab.
public release(id)
{
	if (!(get_user_flags(id)&JEDI))
	{
		console_print(id,"[AMX] You have no access to that command")
		return PLUGIN_CONTINUE
	}
	if (grabmodeon[id])
	{
		grabmodeon[id]=false

		if (grabbed[id])
		{
			set_rendering(grabbed[id])
			client_print(id,print_chat,"[AMX] You have released something!")
		}
		else
		{
			client_print(id,print_chat,"[AMX] No target found")
		}
		grabbed[id]=0
		remove_task(100+id)
	}
	return PLUGIN_CONTINUE
}

public throw(id)
{
	if (!(get_user_flags(id)&JEDI))
	{
		console_print(id,"[AMX] You have no access to that command")
		return PLUGIN_CONTINUE
	}
	if (grabbed[id])
	{
		Throw_force = get_cvar_num("sv_throwforce")
		new Float:pVelocity[3]
		VelocityByAim(id,Throw_force,pVelocity)
		entity_set_vector(grabbed[id],EV_VEC_velocity,pVelocity)
		client_print(id,print_chat,"[AMX] You have thrown something!")
		grabbed[id]=0
		grabmodeon[id]=false
		set_rendering(grabbed[id])
		remove_task(100+id)
	}
	return PLUGIN_CONTINUE
}

//Allows you to spec grab.
public spec_event(id)
{
	new targetid = read_data(2)

	if (targetid < 1 || targetid > 32)
		return PLUGIN_CONTINUE

	if (grabmodeon[id] && !grabbed[id])
	{
		set_grabbed(id, targetid)
	}
	return PLUGIN_CONTINUE
}

//Grabs onto someone
public set_grabbed(id, targetid)
{
	new origin1[3], origin2[3], Float:forigin2[3]
	get_user_origin(id, origin1)
	entity_get_vector(targetid, EV_VEC_origin, forigin2)
	
	set_rendering(targetid,kRenderFxGlowShell,get_cvar_num("sv_glowred"),get_cvar_num("sv_glowgreen"),get_cvar_num("sv_glowblue"), kRenderNormal, 16)

	FVecIVec(forigin2, origin2)
	grabbed[id]=targetid
	grablength[id]=get_distance(origin1,origin2)
	client_print(id,print_chat,"[AMX] You have grabbed something!")
}

public disttask(parm[])
{
	new id = parm[0]
	if (grabbed[id])
	{
		if (parm[1] == 1)
		{
			grablength[id] -= 35
		}
		else if (parm[1] == 2)
		{
			grablength[id] += 35
		}
	}
}

public startpull(id)
{
	if (!(get_user_flags(id)&JEDI))
	{
		console_print(id,"[AMX] You have no access to that command")
		return PLUGIN_CONTINUE
	}
	if (grabbed[id])
	{
		new parm[2]
		parm[0] = id
		parm[1] = 1
		set_task(0.1, "disttask", 500+id, parm, 2, "b")
	}
	return PLUGIN_CONTINUE
}

public startpush(id)
{
	if (!(get_user_flags(id)&JEDI))
	{
		console_print(id,"[AMX] You have no access to that command")
		return PLUGIN_CONTINUE
	}
	if (grabbed[id])
	{
		new parm[2]
		parm[0] = id
		parm[1] = 2
		set_task(0.1, "disttask", 500+id, parm, 2, "b")
	}
	return PLUGIN_CONTINUE
}

public stopdist(id)
{
	if (!(get_user_flags(id)&JEDI))
	{
		console_print(id,"[AMX] You have no access to that command")
		return PLUGIN_CONTINUE
	}
	if (grabbed[id])
	{
		remove_task(500+id)
	}
	return PLUGIN_CONTINUE
}

public choke_func(id)
{
	if (!(get_user_flags(id)&JEDI))
	{
		console_print(id,"[AMX] You have no access to that command")
		return PLUGIN_CONTINUE
	}
	if (grabbed[id]>0 && grabbed[id]<33 && !task_exists(id+200))
	{
		new victim_name[33]
		get_user_name(grabbed[id], victim_name, 32)
		client_print(grabbed[id],print_chat,"*** You Are Being Choked By A Jedi !")
		client_print(id,print_chat,"*** You Are Choking %s !", victim_name)
		message_begin(MSG_ONE, get_user_msgid("ScreenShake") , {0,0,0}, grabbed[id])
		write_short(1<<14)
		write_short(1<<14)
		write_short(1<<14)
		message_end()
		message_begin(MSG_ONE, get_user_msgid("ScreenFade") , {0,0,0}, grabbed[id])
		write_short(1<<1) //total duration
		write_short(1<<0) //time it stays one color
		write_short(0<<1) //fade out, which means it goes away
		write_byte(255) //red
		write_byte(30) //green
		write_byte(30) //blue
		write_byte(180) //alpha, 255 means non-transparent
		message_end()
		new vec[3]
		get_user_origin(grabbed[id],vec)
		message_begin(MSG_ONE, get_user_msgid("Damage"), {0,0,0}, grabbed[id]) 
		write_byte(30) // dmg_save 
		write_byte(30) // dmg_take 
		write_long(1<<0) // visibleDamageBits
		write_coord(vec[0]) // damageOrigin.x 
		write_coord(vec[1]) // damageOrigin.y 
		write_coord(vec[2]) // damageOrigin.z 
		message_end()
		new var[1],health
		var[0]=id
		set_task(1.0,"repeat_shake",id+200,var,1,"a",get_cvar_num("sv_choketime") )
		emit_sound(grabbed[id],CHAN_BODY,"player/PL_PAIN2.WAV",1.0,ATTN_NORM,0, PITCH_NORM)
		health=get_user_health(grabbed[id])
		if(health>3)
			set_user_health(grabbed[id],get_user_health(grabbed[id])-3)
	}
	return PLUGIN_CONTINUE
}

public repeat_shake(var[])
{
	new id=var[0]
	if (grabbed[id]>0 && grabbed[id]<33)
	{
		message_begin(MSG_ONE, get_user_msgid("ScreenShake") , {0,0,0}, grabbed[id])
		write_short(1<<14)
		write_short(1<<14)
		write_short(1<<14)
		message_end()
		message_begin(MSG_ONE, get_user_msgid("ScreenFade") , {0,0,0}, grabbed[id])
		write_short(1<<1) //total duration
		write_short(1<<0) //time it stays one color
		write_short(0<<1) //fade out, which means it goes away
		write_byte(255) //red
		write_byte(30) //green
		write_byte(30) //blue
		write_byte(180) //alpha, 255 means non-transparent
		message_end()
		new vec[3]
		get_user_origin(grabbed[id],vec)
		message_begin(MSG_ONE, get_user_msgid("Damage"), {0,0,0}, grabbed[id]) 
		write_byte(30) // dmg_save 
		write_byte(30) // dmg_take 
		write_long(1<<0) // visibleDamageBits
		write_coord(vec[0]) // damageOrigin.x 
		write_coord(vec[1]) // damageOrigin.y 
		write_coord(vec[2]) // damageOrigin.z 
		message_end()
		new health=get_user_health(grabbed[id])
		if(health>3)
			set_user_health(grabbed[id],get_user_health(grabbed[id])-3)
		emit_sound(grabbed[id],CHAN_BODY,"player/PL_PAIN2.WAV",1.0,ATTN_NORM,0, PITCH_NORM)
	}
	else
	{
		if(task_exists(id+200))
			remove_task(id+200)
	}
	return PLUGIN_CONTINUE
}

//Forces them into your vision and grabs em.

/*
*
* Right now still buggy as the grabee gets stuck into the wall or floor
*
*/

public force_grab(id){

	if (!(get_user_flags(id)&JEDI))
	{
		console_print(id,"[AMX] You have no access to that command")
		return PLUGIN_CONTINUE
	}
	else
	{
   	new arg[33], aimvec[3]
	read_argv(1, arg, 32)

	new targetid = cmd_target(id, arg, 1)

   	if (targetid < 1 || targetid > 32) return PLUGIN_CONTINUE

	get_user_origin(id,aimvec,3)
	set_user_origin(targetid,aimvec)
	grab(id)
//   	return PLUGIN_CONTINUE
	}

	return PLUGIN_CONTINUE

}

public client_disconnect(id)
{

	if(grabbed[id] || grabmodeon[id])
	{
	release(id)
	}


}

public plugin_precache()
{
	precache_sound("player/PL_PAIN2.WAV")
	return PLUGIN_CONTINUE
} 

public plugin_init()
{
	register_plugin("Jedi Force Grab","1.6.2","SpaceDude")
	register_cvar("amx_jedigrab","1")
	register_cvar("amx_jedigrab_playersonly","0")
	register_cvar("sv_throwforce","1500")
	register_cvar("sv_grabforce","8")
	register_cvar("sv_choketime", "8")
	register_cvar("sv_glowred","50")
	register_cvar("sv_glowblue","0")
	register_cvar("sv_glowgreen","0")
	register_clcmd("grab_toggle","grab_toggle",JEDI,"press once to grab and again to release")
	register_clcmd("+grab","grab",JEDI,"bind a key to +grab")
	register_clcmd("-grab","release",JEDI)
	register_clcmd("+pull","startpull",JEDI,"bind a key to +pull")
	register_clcmd("-pull","stopdist",JEDI)
	register_clcmd("+push","startpush",JEDI,"bind a key to +push")
	register_clcmd("-push","stopdist",JEDI)
	register_concmd("choke","choke_func",JEDI,"chokes the grabee")
	register_concmd("throw","throw",JEDI,"throws the grabee")
	register_event("StatusValue","spec_event","be","1=2")
}

