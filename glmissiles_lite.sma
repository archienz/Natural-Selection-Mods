/* 
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
*
* GLMissiles Lite enables a player to turn their gl into a basic missile launcher
* Copyright © 2005  KCE
* 
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public License
* as published by the Free Software Foundation; either version 2
* of the License, or (at your option) any later version.
* 
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.
* 
* You should have received a copy of the GNU General Public License
* along with this program; if not, write to the Free Software
* Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
* 
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
*
* Title : GLMissiles Lite
* 
* Author : KCE
* 
* Special Thanks & Credit :
*
*	PLUGINS:
*	§	Missiles Launcher v3.8.3 ( Ludwig van ) - Missiles
*	§	Enemy spotted v0.1 by JGHG - FOV calculation
*	§	Bazooka v0.9 by More - Base code
*	§	ExtraLevels 2 v1.7e by CheesyPeteza - Experience code and enums
*	§	Superlift v1.3.2c by mE @ psix.info & Cheesy Peteza & White Panther - custom dmg code 
*	§	MvM all-in-one by White Panther - Scoreboard code and enums
*	§	Combat Limit - glmissile limiter
*	§	Sporemines - Sporeeffect for chem missiles 
*	§	ConcGren by Depot - Concussion missiles
*	§	Lud's Flamethrower - Napalm missiles and burning effect
*	§	HandHeldSiege_v1.01a by [WHO]Them (go me) & Steve_Dudenhoeffer - Recoil effect
*
*	PEOPLE:
*	§	Modns.org && Maps, Models, etc. for NS - For giving a home to ns plugins
*	§	Mayhem - Got me started
*	§	Darkness - A lot of help with calculations
*	§	Tom, Woody69 - Testing. Thanks for putting up with all my crashes ; )
*	§	Anyone else who helped me that I have forgotten. : (
*
* Version : Beta
* 
* Description : Turns your gl into a basic missile launcher.
*
* Cvars (name/default value/description) : 
*
*	"amx_glmissiles", 			"1" 	"Enables (1) /Disables (0) glmissiles"
*	"glmissiles_speed", 		"1100" 	"Sets speed of missiles, do not set above 3000 or missile will launch funny"
*	"glmissiles_damage", 		"0" 	"Any value greater than 0 will be used as the damage for the missile, else if 0 then it will use same damage as grenade launcher"
*	"glmissiles_dmgradius", 	"0"		"Same as glmissiles_damage except with damage radius, (default gl dmgradius is 350)
*	"glmissiles_fuel", 			"4.0"	"Time in seconds missiles stays in the air, after this time runs out, it falls to the ground"
*	"glmissiles_obeyffcvar", 	"1"		"Set to 1 to obey mp_friendly cvar, else set to 0 to do damage to everyone"
*	"glmissiles_trail", 		"3"		"Trail type, 0 - no trail, 1 - by team color, 2 - random colors, 3 - generic white"
*	"glmissiles_trail_width", 	"3"		"Width of trail"
*	"glmissiles_trail_time", 	"30"	"How long in seconds, trail stays in the air until it fades"
*	"glmissiles_tfc", 			"0"		"Set to one to enable tfc style missiles (glowing)"
*	"glmissiles_model", 		"0"		"Set to 1 to use missile model, set to 0 to use rpg model (rpg model suggested)"
*	"glmissiles_recoil", 		"300.0"	"Sets recoil when firing missile launcher"
*
* Usage : 
*
*		Say in global or team chat, "/glmissile", to turn your gl into a missile launcher
*		OR
*		bind <key> glmissile
*
*		Say in global or team chat, "/mlhelp, to see help info
*
* History :
*		BETA	- 	BETA Release
*
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*/

#include <amxmodx>
#include <fakemeta>
#include <engine>
#include <ns>

//4 is used by extralevels
#define HUD_CHANNEL1    2

//Vector-to-angle defines
#define ANGLEVECTOR_FORWARD      1 
#define ANGLEVECTOR_RIGHT        2 
#define ANGLEVECTOR_UP           3 

new g_explosion
new g_smoke
new g_missilesmoke

new g_isCombat
new g_mvm
new g_inMissileMode[33]

enum 
{
	XP_LEVEL_1	=     0,
	XP_LEVEL_2	=   100,
	XP_LEVEL_3	=   250,
	XP_LEVEL_4	=   450,
	XP_LEVEL_5	=   700,
	XP_LEVEL_6	=  1000,
	XP_LEVEL_7	=  1350,
	XP_LEVEL_8	=  1750,
	XP_LEVEL_9	=  2200,
	XP_LEVEL_10	=  2700,
	XP_LEVEL_11	=  3250,
	XP_LEVEL_12	=  3850,
	XP_LEVEL_13	=  4500,
	XP_LEVEL_14	=  5200,
	XP_LEVEL_15	=  5950,
	XP_LEVEL_16	=  6750,
	XP_LEVEL_17	=  7600,
	XP_LEVEL_18	=  8500,
	XP_LEVEL_19	=  9450,
	XP_LEVEL_20	= 10450,
	XP_LEVEL_21	= 11500,
	XP_LEVEL_22	= 12600,
	XP_LEVEL_23	= 13800,
	XP_LEVEL_24	= 15050,
	XP_LEVEL_25	= 16350,
	XP_LEVEL_26	= 17750,
	XP_LEVEL_27	= 19200,
	XP_LEVEL_28	= 20700,
	XP_LEVEL_29	= 22250,
	XP_LEVEL_30	= 23850,
	XP_LEVEL_31	= 25500,
	XP_LEVEL_32	= 27200,
	XP_LEVEL_33	= 28950,
	XP_LEVEL_34	= 30750,
	XP_LEVEL_35	= 32600,
	XP_LEVEL_36	= 34500,
	XP_LEVEL_37	= 36450,
	XP_LEVEL_38	= 38450,
	XP_LEVEL_39	= 40500,
	XP_LEVEL_40	= 42600,
	XP_LEVEL_41	= 44750,
	XP_LEVEL_42	= 46950,
	XP_LEVEL_43	= 49200,
	XP_LEVEL_44	= 51500,
	XP_LEVEL_45	= 53850,
	XP_LEVEL_46	= 56250,
	XP_LEVEL_47	= 58700,
	XP_LEVEL_48	= 61300,
	XP_LEVEL_49	= 63950,
	XP_LEVEL_50	= 66650
}

enum 
{
	PLAYERCLASS_NONE = 0,
	PLAYERCLASS_ALIVE_MARINE,
	PLAYERCLASS_ALIVE_ALIEN,
	PLAYERCLASS_ALIVE_JETPACK,
	PLAYERCLASS_ALIVE_HEAVY_MARINE,
	PLAYERCLASS_ALIVE_LEVEL1,
	PLAYERCLASS_ALIVE_LEVEL2,
	PLAYERCLASS_ALIVE_LEVEL3,
	PLAYERCLASS_ALIVE_LEVEL4,
	PLAYERCLASS_ALIVE_LEVEL5,
	PLAYERCLASS_ALIVE_DIGESTING,
	PLAYERCLASS_ALIVE_GESTATING,
	PLAYERCLASS_DEAD_MARINE,
	PLAYERCLASS_DEAD_ALIEN,
	PLAYERCLASS_COMMANDER,
	PLAYERCLASS_REINFORCING,
	PLAYERCLASS_SPECTATOR
}

enum 
{
	PLAYMODE_UNDEFINED = 0,
	PLAYMODE_READYROOM = 1,
	PLAYMODE_PLAYING = 2,
	PLAYMODE_AWAITINGREINFORCEMENT = 3,	// Player is dead and waiting in line to get back in
	PLAYMODE_REINFORCING = 4,		// Player is in the process of coming back into the game
	PLAYMODE_OBSERVER = 5
}

public plugin_init() 
{
	register_plugin("GlMissiles Lite", "beta", "KCE")

	register_cvar("amx_glmissiles", "1")
	register_cvar("glmissiles_speed", "1100")
	register_cvar("glmissiles_damage", "0")
	register_cvar("glmissiles_dmgradius", "0")
	register_cvar("glmissiles_fuel", "4.0")
	register_cvar("glmissiles_obeyffcvar", "1")
	register_cvar("glmissiles_trail", "3")
	register_cvar("glmissiles_trail_width", "3")
	register_cvar("glmissiles_trail_time", "30")
	register_cvar("glmissiles_tfc", "0")
	register_cvar("glmissiles_model", "0")
	register_cvar("glmissiles_recoil", "300.0")		
	
	register_clcmd("glmissile", "missilemode")
	
	register_clcmd("say /glmissile", "missilemode")
	register_clcmd("say_team /glmissile", "missilemode")

	register_clcmd("say /mlhelp", "mlhelp")
	register_clcmd("say_team /mlhelp", "mlhelp")		

	register_event("ResetHUD", "PlayerSpawned", "b")
	
	register_forward(FM_PlayerPreThink, "forward_playerprethink")

	register_message(get_user_msgid("DeathMsg"),"checkDeathMsg")
	
	g_mvm = is_mvm()
	g_isCombat = ns_is_combat()		
	
}

public plugin_precache() 
{
	precache_model("models/hvr.mdl")
	precache_model("models/rpgrocket.mdl")

	precache_sound("weapons/rocketfire1.wav")
	precache_sound("weapons/mortarhit.wav")
	precache_sound("weapons/explode3.wav")
	precache_sound("ambience/rocket_steam1.wav")
	precache_sound("weapons/rocket1.wav")
	
	g_missilesmoke = precache_model("sprites/smoke.spr")	
	g_smoke = precache_model("sprites/steam1.spr")	
	g_explosion = precache_model("sprites/zerogxplode.spr")
}

public client_disconnect(id) 
{
	g_inMissileMode[id] = 0
}

public client_connect(id) 
{
	g_inMissileMode[id] = 0
}

public checkDeathMsg(msg_id, msg_dest, msg_entity)
{
	new szWeapon[33]
	new szAttacker[4]

	new szWeaponClassname[50]
	get_msg_arg_string(3,szWeaponClassname,49)

	parse(szWeaponClassname,szAttacker,3,szWeapon,32)
	
	new killer = str_to_num(szAttacker)

	if(is_user_connected(killer))
	{
		set_msg_arg_int(1,1,killer)				//set the killer to killer
		
		if( entity_get_int(killer,EV_INT_team) == entity_get_int(get_msg_arg_int(2),EV_INT_team) && (get_msg_arg_int(2) != killer) )	//if ff	and not suicide		
			set_msg_arg_string(3,"teamate")
		else
			set_msg_arg_string(3,szWeapon)
	}
	
	return PLUGIN_CONTINUE
}

public make_missile(id)
{
	new args[2]
	new Float:StartOrigin[3], Float:Angle[3]

	//so the missile appears to come from the gl
	new PlayerOrigin[3]
	get_user_origin(id, PlayerOrigin, 1)
	
	//Convert player origin to float
	StartOrigin[0] = float(PlayerOrigin[0])
	StartOrigin[1] = float(PlayerOrigin[1])
	StartOrigin[2] = float(PlayerOrigin[2])
	
	entity_get_vector(id, EV_VEC_v_angle, Angle)
	
	Angle[0] = Angle[0] * -1.0
	
	new MissileEnt = create_entity("info_target")
	entity_set_string(MissileEnt, EV_SZ_classname, "glmissile")

	entity_set_origin(MissileEnt, StartOrigin)
	entity_set_vector(MissileEnt, EV_VEC_angles, Angle)

	if(get_cvar_num("glmissiles_model") == 1)	//missile
		entity_set_model(MissileEnt, "models/hvr.mdl")
	else 										//rpg
		entity_set_model(MissileEnt, "models/rpgrocket.mdl")
	
	new Float:MinBox[3] = {-1.0, -1.0, -1.0}
	new Float:MaxBox[3] = {1.0, 1.0, 1.0}
	
	entity_set_vector(MissileEnt, EV_VEC_mins, MinBox)
	entity_set_vector(MissileEnt, EV_VEC_maxs, MaxBox)

	entity_set_int(MissileEnt, EV_INT_solid, 2)
	entity_set_int(MissileEnt, EV_INT_movetype, 5)
	
	entity_set_edict(MissileEnt, EV_ENT_owner, id)

	if(get_cvar_num("glmissiles_tfc"))	//glow
		entity_set_int(MissileEnt, EV_INT_effects, 64)
	else 
		entity_set_int(MissileEnt, EV_INT_effects, 2)		//light
	
	entity_set_int(MissileEnt,EV_INT_team,entity_get_int(id,EV_INT_team))

	new Float:Velocity[3]
	VelocityByAim(id, get_cvar_num("glmissiles_speed"), Velocity)
	entity_set_vector(MissileEnt, EV_VEC_velocity, Velocity)
	
	emit_sound(MissileEnt, CHAN_WEAPON, "weapons/rocketfire1.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	emit_sound(MissileEnt, CHAN_VOICE, "weapons/rocket1.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	
	args[0] = id
	args[1] = MissileEnt	//rocket

	message_begin(MSG_BROADCAST, SVC_TEMPENTITY) //BEGIN MESSAGE
	write_byte(22)	//TYPE
	write_short(MissileEnt) //WHICH ENTITY TO FOLLOW
	write_short(g_missilesmoke)   //BEAM SPRITE
	write_byte(get_cvar_num("glmissiles_trail_time")) //TIME
	write_byte(get_cvar_num("glmissiles_trail_width")) //WIDTH
	
	switch (get_cvar_num("glmissiles_trail"))
	{
		case 0: //NONE
		{
				write_byte(0) //R
				write_byte(0)	//G
				write_byte(0)	//B
				write_byte(0)	//BRIGHTNESS
				message_end() //END MESSAGE
		}
	
		case 1: //TEAM
		{
			if ( g_mvm )
			{
				if(entity_get_int(id,EV_INT_team) == 1) //IF TEAM BLUE
				{
					write_byte(0) //R
					write_byte(0)	//G
					write_byte(254)	//B
					write_byte(254)	//BRIGHTNESS
					message_end() //END MESSAGE
				} 
				else //IF TEAM Red
				{
					write_byte(254) //R
					write_byte(0)	//G
					write_byte(0)	//B
					write_byte(254)	//BRIGHTNESS
					message_end() //END MESSAGE				
				}
			}
			else  //else is combat
			{
				write_byte(0) //R
				write_byte(254)	//G
				write_byte(0)	//B
				write_byte(254)	//BRIGHTNESS
				message_end() //END MESSAGE
			}
		}
	
		case 2: //RANDOM COLORS
		{
				write_byte(random_num(0,255))     // r, g, b
				write_byte(random_num(0,255))   // r, g, b
				write_byte(random_num(0,255))    // r, g, b
				write_byte(254)	//BRIGHTNESS
				message_end() //END MESSAGE
		}
	
		case 3:  //g_white COLOR GENERIC
		{
				write_byte(254) //R
				write_byte(254)	//G
				write_byte(254)	//B
				write_byte(254)	//BRIGHTNESS
				message_end() //END MESSAGE
		}
	
		default:  //g_white COLOR GENERIC
		{
				write_byte(254) //R
				write_byte(254)	//G
				write_byte(254)	//B
				write_byte(254)	//BRIGHTNESS
				message_end() //END MESSAGE
		}
	}
	
	set_task(get_cvar_float("glmissiles_fuel"),"missile_fuel_timer",1234+MissileEnt,args,16)	//set missile fuel task

}

public missile_fuel_timer(args[])
{
	new ent = args[1]
	remove_task(1234+ent)	//remove all tasks

	entity_set_int(ent, EV_INT_effects, 2)
	entity_set_int(ent, EV_INT_rendermode,0)
	entity_set_int(ent, EV_INT_movetype, 6)	//gravity

	emit_sound(ent, CHAN_VOICE, "ambience/rocket_steam1.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	
	return PLUGIN_CONTINUE
}

public pfn_touch(ptr, ptd) 
{
	new ClassName[32]
		
	if (is_valid_ent(ptr)) 
		entity_get_string(ptr, EV_SZ_classname, ClassName, 31)
	
	if (equal(ClassName, "glmissile")) 
	{
		new attacker = entity_get_edict(ptr, EV_ENT_owner)//owner of rocket
		new attacker_team = entity_get_int(attacker,EV_INT_team)
		
		if(task_exists(1234+ptr,0))
			remove_task(1234+ptr)

		new Float:EndOrigin[3]
		entity_get_vector(ptr, EV_VEC_origin, EndOrigin)
		
		emit_sound(ptr, CHAN_WEAPON, "weapons/explode3.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
		emit_sound(ptr, CHAN_VOICE, "weapons/explode3.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)

		//Fire
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY) 
		write_byte(3)
		write_coord(floatround(EndOrigin[0])) //EXPLODE AT COORDINATES
		write_coord(floatround(EndOrigin[1])) //EXPLODE AT COORDINATES
		write_coord(floatround(EndOrigin[2])) //EXPLODE AT COORDINATES
		write_short(g_explosion)		
		write_byte(60)
		write_byte(15)
		write_byte(0)
		message_end()

		//g_smoke
		message_begin(MSG_BROADCAST,SVC_TEMPENTITY) 
		write_byte(5) 
		write_coord(floatround(EndOrigin[0])) //EXPLODE AT COORDINATES
		write_coord(floatround(EndOrigin[1])) //EXPLODE AT COORDINATES
		write_coord(floatround(EndOrigin[2])) //EXPLODE AT COORDINATES
		write_short(g_smoke)
		write_byte(69) 
		write_byte(12)    
		message_end() 

		//SEND SPARKS
		message_begin(MSG_BROADCAST,SVC_TEMPENTITY) 
		write_byte(9) 
		write_coord(floatround(EndOrigin[0])) //EXPLODE AT COORDINATES
		write_coord(floatround(EndOrigin[1])) //EXPLODE AT COORDINATES
		write_coord(floatround(EndOrigin[2])) //EXPLODE AT COORDINATES
		message_end() 

		new Float:maxdamage = 0.0
		new damageradius = 350
	
		new customdmgradius = get_cvar_num("glmissiles_dmgradius")
	
		if ( customdmgradius > 0)
			damageradius = customdmgradius
		else
			damageradius = 350

		new customdmg = get_cvar_num("glmissiles_damage")
			
		if ( customdmg  > 0.0 )
		{
			maxdamage = float(customdmg)
		}
		else
		{
			if ( ns_get_mask(attacker,MASK_WEAPONS1) )
			{
				if ( ns_get_mask(attacker,MASK_WEAPONS2) )
				{
					if ( ns_get_mask(attacker,MASK_WEAPONS3) )
					{
						maxdamage = 162.5
					}
					else
					{
						maxdamage = 150.0
					}
				}
				else
				{
					maxdamage = 137.5	
				}
			}
			else
			{
				maxdamage = 125.0
			}
		}
		
		for (new i = 1; i <= entity_count(); i++) 
		{
			if ( is_valid_ent(i) )
			{
				if ( i != ptr )
				{
					new EntPos[3], distance
					new Float:damage
					new Float:fl_EntPos[3]	
					entity_get_vector(i,EV_VEC_origin,fl_EntPos)
					EntPos[0] = floatround(fl_EntPos[0])
					EntPos[1] = floatround(fl_EntPos[1])
					EntPos[2] = floatround(fl_EntPos[2])
					
					new NonFloatEndOrigin[3]
					NonFloatEndOrigin[0] = floatround(EndOrigin[0])
					NonFloatEndOrigin[1] = floatround(EndOrigin[1])
					NonFloatEndOrigin[2] = floatround(EndOrigin[2])
			
					distance = get_distance(EntPos, NonFloatEndOrigin)
					
					if ( distance <= (damageradius*3) )	//for shaking distance
					{
						if (ent_in_view(ptr,i))	//clear LOS
						{
							damage = dfalloff_damage(float(distance), float(damageradius), maxdamage)
							
							new classname[32]
							entity_get_string( i, EV_SZ_classname, classname, 31 )
						
							//If building
							if ( is_building(classname) )
							{	
								if (distance <= damageradius)
								{
									if (attacker_team != entity_get_int(i,EV_INT_team))  //if different team
									{
										fakedamage(i,classname,damage+damage,0) //do double damage
								
										if (g_isCombat && (equal(classname,"team_command") || equal(classname,"team_hive")) )
										{
											new Float: exp = 0.12 * damage //(0.06 * 2.0)
											ns_set_exp(attacker,ns_get_exp(attacker) + exp)
										}
									} 
									else if(get_cvar_num("glmissiles_obeyffcvar"))
									{
										if (get_cvar_num("mp_friendlyfire")) 
											fakedamage(i,classname,damage+damage,0) //do double damage
									}
									else	//same team
									{
										fakedamage(i,classname,damage+damage,0) //do double damage
									}
								}
							} else if ( equal(classname,"player") && is_user_alive(i) )
							{
								// ScreenShake
								message_begin(MSG_ONE, get_user_msgid("ScreenShake"), {0,0,0}, i)  // Screen Shake
								write_short(65535)
								write_short(4096) 
								write_short(25600)
								message_end()
								
								if (distance <= damageradius)
								{
									if (attacker_team != entity_get_int(i,EV_INT_team))
									{
										take_dmg(i,attacker,damage,"grenade")
									}
									else if (attacker == i) 
									{
										take_dmg(i,attacker,(0.25*damage),"grenade")																											
									} 
									else if(attacker_team == entity_get_int(i,EV_INT_team))	//ff
									{
										if(get_cvar_num("glmissiles_obeyffcvar"))
										{
											if (get_cvar_num("mp_friendlyfire")) 
											{
												take_dmg(i,attacker,(0.25*damage),"grenade")																											
											}
										}
										else
										{
											take_dmg(i,attacker,(0.25*damage),"grenade")
										}									
									}
								}
							}
						}
					}
				}
			}
		}
		remove_entity(ptr)
	}
	
	return PLUGIN_CONTINUE
}

public forward_playerprethink(id) 
{
	if (is_user_alive(id)) 
	{
		if (get_cvar_num("amx_glmissiles"))
		{
			new weaponid, clip, ammo
			weaponid = get_user_weapon(id, clip, ammo)
			if ((weaponid == WEAPON_GRENADE_GUN) && g_inMissileMode[id]) 
			{
				new grenID = find_ent_by_owner(-1,"grenade",id,0)
				
				if (grenID) 
				{
					do_recoil(id)	//apply recoil
					remove_entity(grenID)	//remove old grenade
					make_missile(id)	//replace with missile missile
				}
			}
		}
	}
}

public do_recoil(id)
{
	new Float:velocity[3]
	new Float:avelocity[3]
	
	entity_get_vector(id,EV_VEC_velocity,velocity)
	entity_get_vector(id,EV_VEC_avelocity,avelocity)
	
	new Float:v_forward[3]
	get_global_vector(GL_v_forward,v_forward)

	new Float:recoil = get_cvar_float("glmissiles_recoil")
	
	if(entity_get_int(id,EV_INT_flags) & FL_DUCKING) 	//if ducking reduce recoil by half
	{
		velocity[0] = velocity[0] + (v_forward[0] * (recoil/2)) * -1
		velocity[1] = velocity[1] + (v_forward[1] * (recoil/2)) * -1
		velocity[2] = velocity[2] + (v_forward[2] * (recoil/2)) * -1
	
		avelocity[0] = avelocity[0] + (v_forward[0] * (recoil/2)) * -1
		avelocity[1] = avelocity[1] + (v_forward[1] * (recoil/2)) * -1
		avelocity[2] = avelocity[2] + (v_forward[2] * (recoil/2)) * -1
	}
	else
	{
		velocity[0] = velocity[0] + (v_forward[0] * recoil) * -1
		velocity[1] = velocity[1] + (v_forward[1] * recoil) * -1					
		velocity[2] = velocity[2] + (v_forward[2] * recoil) * -1						
	
		avelocity[0] = avelocity[0] + (v_forward[0] * recoil) * -1
		avelocity[1] = avelocity[1] + (v_forward[1] * recoil) * -1						
		avelocity[2] = avelocity[2] + (v_forward[2] * recoil) * -1	
	}
	
	entity_set_vector(id,EV_VEC_velocity,velocity)
	entity_set_vector(id,EV_VEC_avelocity,avelocity)
}

public PlayerSpawned(id)
{
	set_task(1.1,"showUsage",id)
}

//CMDS
public showUsage(id) 
{
	if (get_cvar_num("amx_glmissiles"))
	{
		if (entity_get_int(id,EV_INT_team) == 1 || g_mvm)
		{
			client_print(id, print_chat, "[GLMissiles] GLMissiles Lite BETA by KCE, type /mlhelp for info")
		}
	}
	else
	{
		client_print(id, print_chat, "[GLMissiles] GLMissiles Lite BETA by KCE, missiles are disabled")
	}
	
	return PLUGIN_CONTINUE
}

public mlhelp(id)
{
	if (get_cvar_num("amx_glmissiles"))
	{
		if ( entity_get_int(id,EV_INT_team) == 1 || g_mvm )
		{
			new len = 1023
			new n = 0
			new message[1024]			
			
			n += format( message[n],len-n,"Say in chat - /glmissile^n")
			n += format( message[n],len-n,"or^n") 
			n += format( message[n],len-n,"bind <key> glmissile^n")
			
			set_hudmessage(255,255,255, 0.0, 0.0, 2, 0.02,18.0, 0.01, 1.0, HUD_CHANNEL1)
			show_hudmessage(id,message)
		}
	}
	
	return PLUGIN_HANDLED
}

public missilemode(id)
{
	if (get_cvar_num("amx_glmissiles"))
	{
		if ( entity_get_int(id,EV_INT_team) == 1 || g_mvm )
		{
			if (is_user_alive(id))
			{	
				if(ns_has_weapon(id,NSWeapon:WEAPON_GRENADE_GUN))
				{
					if(g_inMissileMode[id])
					{
						g_inMissileMode[id] = 0
						client_print(id, print_chat, "[GLMissiles] Your gl is now a normal gl")
					} 
					else
					{
						g_inMissileMode[id] = 1
						client_print(id, print_chat, "[GLMissiles] Your gl is now a missile launcher")				
					}								
				}
				else
				{
					client_print(id, print_chat, "[GLMissiles] Your need a gl first")				
				}
			} 
			else
			{
				client_print(id, print_chat, "[GLMissiles] You cannot use this while you are dead")	
			}
		}
		else
		{
			client_print(id, print_chat, "[GLMissiles] You need to be on the marine team")				
		}			
	}
	else
	{
		client_print(id, print_chat, "[GLMissiles] Missiles have been disabled!")	
	}
	
	return PLUGIN_HANDLED
	
}

take_dmg(victim,attacker,Float:dmg_to_do,weapon_name[] = "")
{
	if (is_user_alive(victim))
	{
		new attackerid[50]
		format(attackerid,49,"%d %s",attacker,weapon_name)	//format string
		
		fakedamage(victim,attackerid,dmg_to_do,0)
		
		if(!is_user_alive(victim))	//if he died after taking damage
		{
			new victim_team = entity_get_int(victim,EV_INT_team)
			new attacker_team = entity_get_int(attacker,EV_INT_team)
		
			if(victim_team != attacker_team)
			{
				new frags = get_user_frags(attacker) + 1
				set_user_frags(attacker,frags)
				
				new score = ns_get_score(attacker) + frags
	
				if(g_isCombat)
				{
					score += get_level(attacker)
					ns_set_exp(attacker,ns_get_exp(attacker) + float( get_level(attacker) * 10 + 80 ) )	//90 exp
				}
				
				new deaths = ns_get_deaths(attacker)
				
				new class = scoreboard_class(attacker)

				message_begin(MSG_ALL, get_user_msgid("ScoreInfo"))
				write_byte(attacker)
				write_short(score)	// score
				write_short(frags)	// frags
				write_short(deaths)	// deaths
				write_byte(class)	// class
				write_short(0)		// auth status
				write_short(get_team(attacker))				
				message_end()
			}
		}
	}
}

stock scoreboard_class(id)
{
	new class_score
	new cur_class = ns_get_class(id)
	new alive = is_user_alive(id)
	new playerclass = entity_get_int(id, EV_INT_playerclass)
	new teamname[32]
	get_user_team(id,teamname,31)
			
	if ( playerclass == PLAYMODE_AWAITINGREINFORCEMENT || playerclass == PLAYMODE_REINFORCING )
	{
		class_score = PLAYERCLASS_REINFORCING
	}else if ( containi(teamname,"alien") != -1 )
	{
		if ( !alive )
			class_score = PLAYERCLASS_DEAD_ALIEN
		else if ( cur_class == CLASS_SKULK )
			class_score = PLAYERCLASS_ALIVE_LEVEL1
		else if ( cur_class == CLASS_GORGE )
			class_score = PLAYERCLASS_ALIVE_LEVEL2
		else if ( cur_class == CLASS_LERK )
			class_score = PLAYERCLASS_ALIVE_LEVEL3
		else if ( cur_class == CLASS_FADE )
			class_score = PLAYERCLASS_ALIVE_LEVEL4
		else if ( cur_class == CLASS_ONOS )
			class_score = PLAYERCLASS_ALIVE_LEVEL5
		else if ( cur_class == CLASS_GESTATE )
			class_score = PLAYERCLASS_ALIVE_GESTATING
		else
			class_score = PLAYERCLASS_ALIVE_ALIEN
	}else if ( containi(teamname,"marine") != -1 ){
		if ( !alive )
			class_score = PLAYERCLASS_DEAD_MARINE
		else if ( ns_get_mask(id,MASK_DIGESTING) )
			class_score = PLAYERCLASS_ALIVE_DIGESTING
		else if ( cur_class == CLASS_COMMANDER )
			class_score = PLAYERCLASS_COMMANDER
		else if ( cur_class == CLASS_HEAVY )
			class_score = PLAYERCLASS_ALIVE_HEAVY_MARINE
		else if ( cur_class == CLASS_JETPACK )
			class_score = PLAYERCLASS_ALIVE_JETPACK
		else
			class_score = PLAYERCLASS_ALIVE_MARINE
	}else if ( containi(teamname,"specta") != -1 )
		class_score = PLAYERCLASS_SPECTATOR
	
	return class_score
}

stock get_level(index) 
{
	new userxp = get_xp(index)

	if (userxp > XP_LEVEL_50)	return 50
	if (userxp > XP_LEVEL_49)	return 49
	if (userxp > XP_LEVEL_48)	return 48
	if (userxp > XP_LEVEL_47)	return 47
	if (userxp > XP_LEVEL_46)	return 46
	if (userxp > XP_LEVEL_45)	return 45
	if (userxp > XP_LEVEL_44)	return 44
	if (userxp > XP_LEVEL_43)	return 43
	if (userxp > XP_LEVEL_42)	return 42
	if (userxp > XP_LEVEL_41)	return 41
	if (userxp > XP_LEVEL_40)	return 40
	if (userxp > XP_LEVEL_39)	return 39
	if (userxp > XP_LEVEL_38)	return 38
	if (userxp > XP_LEVEL_37)	return 37
	if (userxp > XP_LEVEL_36)	return 36
	if (userxp > XP_LEVEL_35)	return 35
	if (userxp > XP_LEVEL_34)	return 34
	if (userxp > XP_LEVEL_33)	return 33
	if (userxp > XP_LEVEL_32)	return 32
	if (userxp > XP_LEVEL_31)	return 31
	if (userxp > XP_LEVEL_30)	return 30
	if (userxp > XP_LEVEL_29)	return 29
	if (userxp > XP_LEVEL_28)	return 28
	if (userxp > XP_LEVEL_27)	return 27
	if (userxp > XP_LEVEL_26)	return 26
	if (userxp > XP_LEVEL_25)	return 25
	if (userxp > XP_LEVEL_24)	return 24
	if (userxp > XP_LEVEL_23)	return 23
	if (userxp > XP_LEVEL_22)	return 22
	if (userxp > XP_LEVEL_21)	return 21
	if (userxp > XP_LEVEL_20)	return 20
	if (userxp > XP_LEVEL_19)	return 19
	if (userxp > XP_LEVEL_18)	return 18
	if (userxp > XP_LEVEL_17)	return 17
	if (userxp > XP_LEVEL_16)	return 16
	if (userxp > XP_LEVEL_15)	return 15
	if (userxp > XP_LEVEL_14)	return 14
	if (userxp > XP_LEVEL_13)	return 13
	if (userxp > XP_LEVEL_12)	return 12
	if (userxp > XP_LEVEL_11)	return 11
	if (userxp > XP_LEVEL_10)	return 10
	if (userxp > XP_LEVEL_9)	return 9
	if (userxp > XP_LEVEL_8)	return 8
	if (userxp > XP_LEVEL_7)	return 7
	if (userxp > XP_LEVEL_6)	return 6
	if (userxp > XP_LEVEL_5)	return 5
	if (userxp > XP_LEVEL_4)	return 4
	if (userxp > XP_LEVEL_3)	return 3
	if (userxp > XP_LEVEL_2)	return 2
	if (userxp >= XP_LEVEL_1)	return 1

	return 0
}

stock get_xp(index) 
{
	return floatround(ns_get_exp(index))
}

stock bool:is_building(classname[])
{
	if (equal(classname,"team_command")) 
		return true
	if (equal(classname,"team_armory"))
		return true
	if (equal(classname,"team_advarmory"))
		return true
	if (equal(classname,"phasegate"))
		return true
	if (equal(classname,"resourcetower"))
		return true
	if (equal(classname,"team_turretfactory")) 
		return true
	if (equal(classname,"team_armslab")) 
		return true
	if (equal(classname,"team_prototypelab")) 
		return true
	if (equal(classname,"team_observatory"))
		return true
	if (equal(classname,"turret"))
		return true
	if (equal(classname,"siegeturret"))
		return true
	if (equal(classname,"alienresourcetower"))
		return true
	if (equal(classname,"offensechamber"))
		return true
	if (equal(classname,"defensechamber"))
		return true
	if (equal(classname,"sensorychamber"))
		return true		
	if (equal(classname,"movementchamber"))
		return true		
	if (equal(classname,"team_hive"))
		return true		
	if (equal(classname,"func_breakable"))	//breakable objects included
		return true		
	
	return false
}

stock Float:dfalloff_damage(Float:dist, Float:maxdist, Float:maxdamage)
{
	return maxdamage * (1.0 - (dist / maxdist))
}

// Returns 1 if iStartEnt has unobstructed path to iEndEnt 
stock ent_in_view( iStartEnt, iEndEnt ) 
{ 
    new Float:fStartOrigin[3]; 
    entity_get_vector( iStartEnt, EV_VEC_origin, fStartOrigin )

    new Float:fEndOrigin[3]; 
    entity_get_vector( iEndEnt, EV_VEC_origin, fEndOrigin )

    new Float:vReturn[3]; 
    new iHitEnt = trace_line( iStartEnt, fStartOrigin, fEndOrigin, vReturn )

    // Check if Obstruction Hit is an Ent 

    while ( iHitEnt > 0 ) 
    { 
        if ( iHitEnt == iEndEnt ) 
            return 1

        entity_get_vector( iHitEnt, EV_VEC_origin, fStartOrigin )
        iHitEnt = trace_line( iHitEnt, fStartOrigin, fEndOrigin, vReturn )
    } 

    // Check if Return / End Origin are the same 

    if ( !vector_distance( vReturn, fEndOrigin ) ) 
        return 1

    return 0
} 
	
stock get_team(id)
{
	new teamname[32]
	get_user_team(id,teamname,31)
	new team
	
	if ( equali(teamname,"marine1team") )
		team = 1
	else if ( equali(teamname,"marine2team") )
		team = 4
	else if ( equali(teamname,"alien1team") )
		team = 2
	else if ( equali(teamname,"undefined") )	
		team = 0
	else if ( equali(teamname,"spectatorteam") )	
		team = 6
		
	return team
}

stock is_mvm()
{
	// Check if map is currently MvM.
	if (!ns_is_combat()) // If it's not combat, it can't be MvM.
		return 0
	if (ns_get_build("team_command",0,0) > 1)
		return 1 // There are more than 1 command consoles in the map.
	return 0
}