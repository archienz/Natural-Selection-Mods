/* AMX_PopeLightning
*    a chance slay plugin
*
* by CubicVirtuoso
* August 2005
*
* Thanks to: Bailopan for the name
*
* This plugin came to me when I was coding my Requiem plugin and got to the lightning part.
* I thought to myself damn it would be awesome to have a slay plugin were sometimes the
* admin doesn't always win. Well heres the plugin. Amx_popelightning is a little plugin 
* where an admin can spawn lightning bolts around a player. These bolts are semi-random
* and they MAY strike the player. If they strike the player he will loose 50 health.
* If the player isn't dead by the time the fifty hp runs out... he blows up anyway. 
* Although there is a high chance that the lightning will not strike the player.
*
* I also added popezap that allows you to zap a certain player with lightning. Adds some
* effects... essentially its the same as popelightning only horizontal.  
*
* Due to popular demand I also added pope aim zap. Which is exactly like pope zap but you can
* aim where it goes and it will deal damage to those you shoot it at. This is very fun. Also
* the giver of the aim pope zap will no longer be damaged from his own zap.  
* 
* Commands:
* amx_popelightning <target>
* amx_popezap <target>
* amx_aim_popezap
*
* CVAR:
* amx_popefreeze <1/0> : Toggles the bury effect
*/

#include <amxmodx> // Amx mod include definitions
#include <fun> // Fun Module
#include <amxmisc> // Useful functions
#include <engine> // Engine Plugin

new PLUGIN[]="Pope Lightning"
new AUTHOR[]="CubicVirtuoso"
new VERSION[]="4.00"

new SpriteLightning, SpriteSmoke
new bool:damagedalready[33] = false
new sparks[10][7]

//-------------------------------------------------------------------------------------------------------------------

public plugin_init()
{
	register_plugin(PLUGIN,VERSION,AUTHOR) // Register Function
	register_concmd("amx_popelightning", "CMD_thunderslay", ADMIN_SLAY, "<target> ")
	register_cvar("amx_popefreeze","1",FCVAR_SERVER|FCVAR_EXTDLL|FCVAR_UNLOGGED|FCVAR_SPONLY) 
	register_concmd("amx_popezap", "CMD_thunderzap", ADMIN_SLAY, "<target> ")
	register_concmd("amx_aim_popezap", "CMD_aim_popezap", ADMIN_SLAY)
	
	for (new a = 0; a<10; a++)
	{
		for (new b = 0; b<7; b++)
		{
			sparks[a][b] = 0
		}
	}
}

//-------------------------------------------------------------------------------------------------------------------

public plugin_precache()
{
	precache_sound("ambience/sparks.wav") // Sparks sound for lightning
	precache_sound("ambience/port_suckin1.wav") // Thunder
	SpriteSmoke = precache_model("sprites/steam1.spr") // Smoke sprite
	SpriteLightning = precache_model("sprites/lgtning.spr") // Lightning sprite
	precache_model("sprites/xspark2.spr") // Spark sprite
}

//-------------------------------------------------------------------------------------------------------------------
public CMD_aim_popezap(id, level, cid)
{
	if (!cmd_access(id, level, cid, 1)) // Checks if the command user has access
		return PLUGIN_HANDLED
		
	new startpoint[3]
	new endpoint[3]
	get_user_origin(id,startpoint) // set location
	get_user_origin(id, endpoint, 2) // set location
	new flag = 0
	
	new randomvariance
	
	for (new i=0; i<4; i++)
	{
		randomvariance = random_num(20, 120)
		beampoints(startpoint, endpoint, SpriteLightning, 1, 10, 10, 50, randomvariance, 0, 0, 255, 100, 100) // creates lightning bolt
	}
	
	smoke(endpoint, SpriteSmoke, 5, 10) // creates smoke puff
	
	for(new i = 0; i<7; i++)
	{
		if (sparks[id][i] == 0 && flag != 1)
		{
			createspark(endpoint, id, i, id) // creates spark
			flag = 1
		}
	}
	
	emit_sound(id,CHAN_AUTO, "ambience/port_suckin1.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
	emit_sound(id,CHAN_AUTO, "ambience/sparks.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
	set_task(1.0,"removesparks",id)
	set_task(5.0,"stopsound")
	
	new lowerlocation[3] // new posistion for freeze of player
	lowerlocation[0] = startpoint[0]
	lowerlocation[1] = startpoint[1]
	lowerlocation[2] = startpoint[2] - 5
	
	if(get_cvar_num("amx_popefreeze") == 1)
	{
		set_user_origin(id,lowerlocation)
		
		set_task(1.2,"resetlocation",id) // unstucks the player
	}
	
	new players[32]
	new playercount
		
	get_players(players,playercount,"a")
		
	for (new i=0; i<playercount; i++)
	{
		new playerlocation[3]
		new resultdistance
			
		get_user_origin(players[i], playerlocation)
			
		resultdistance = get_distance(playerlocation,endpoint)
			
		if(resultdistance < 200 && players[i] != id)
		{
			emit_sound(players[i],CHAN_AUTO, "ambience/sparks.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
			set_task(5.0,"stopsound")
			set_task(1.0,"lightningdamage",players[i],_,_,"a",5)
			
			set_task(0.1,"glow",players[i])
			set_task(0.3,"unglow",players[i])
			set_task(0.5,"glow",players[i])
			set_task(0.7,"unglow",players[i])
			set_task(0.9,"glow",players[i])
			set_task(1.1,"unglow",players[i])
			set_task(1.3,"glow",players[i])
			set_task(1.5,"unglow",players[i])
			set_task(1.7,"glow",players[i])
			set_task(1.9,"unglow",players[i])
			set_task(2.1,"glow",players[i])
			set_task(2.3,"unglow",players[i])
			set_task(2.5,"glow",players[i])
			set_task(2.7,"unglow",players[i])
			set_task(2.9,"glow",players[i])
			set_task(3.1,"unglow",players[i])
			set_task(3.3,"unglow",players[i])
			set_task(3.5,"glow",players[i])
			set_task(3.7,"unglow",players[i])
			set_task(3.9,"glow",players[i])
			set_task(4.1,"unglow",players[i])
			set_task(4.3,"unglow",players[i])
			set_task(4.5,"glow",players[i])
			set_task(4.7,"unglow",players[i])
			
			client_print(players[i],print_chat,"You got in the Popes way!!")
		}
	}
	
	return PLUGIN_HANDLED
}

/* Resets players location from slight bury */
public resetlocation(id)
{
	new idlocation[3] // location
	get_user_origin(id,idlocation) // reads current locations
	idlocation[2] = idlocation[2] + 6 // moves them up one
	set_user_origin(id,idlocation)
}

public CMD_thunderzap(id, level, cid)
{
	if (!cmd_access(id, level, cid, 2)) // Checks if the command user has access
		return PLUGIN_HANDLED
	
	new Arg1[24]
	read_argv(1, Arg1, 23) // Reads the players name
	
	new player = cmd_target(id, Arg1, 1)
	
	if (!player) // if player not found
	{
		client_print(id, print_chat, "Player count not be found") // print console error
		return PLUGIN_HANDLED
	}
	
	new playerlocation[3]
	new idlocation[3]
	get_user_origin(player,playerlocation)
	get_user_origin(id,idlocation)
	
	new randomvariance
	
	for (new i=0; i<4; i++)
	{
		randomvariance = random_num(20,120)
		
		beampoints(idlocation, playerlocation, SpriteLightning, 1, 10, 10, 50, randomvariance, 0, 0, 255, 100, 100) // creates lightning bolt
		
		emit_sound(id,CHAN_AUTO, "ambience/port_suckin1.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
	}
	
	set_task(0.1,"glow",player)
	set_task(0.3,"unglow",player)
	set_task(0.5,"glow",player)
	set_task(0.7,"unglow",player)
	set_task(0.9,"glow",player)
	set_task(1.1,"unglow",player)
	set_task(1.3,"glow",player)
	set_task(1.5,"unglow",player)
	set_task(1.7,"glow",player)
	set_task(1.9,"unglow",player)
	set_task(2.1,"glow",player)
	set_task(2.3,"unglow",player)
	set_task(2.5,"glow",player)
	set_task(2.7,"unglow",player)
	set_task(2.9,"glow",player)
	set_task(3.1,"unglow",player)
	set_task(3.3,"unglow",player)
	set_task(3.5,"glow",player)
	set_task(3.7,"unglow",player)
	set_task(3.9,"glow",player)
	set_task(4.1,"unglow",player)
	set_task(4.3,"unglow",player)
	set_task(4.5,"glow",player)
	set_task(4.7,"unglow",player)
	
	set_task(1.0,"lightningdamage",player,_,_,"a",5)
	
	emit_sound(id,CHAN_AUTO, "ambience/port_suckin1.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
	emit_sound(player,CHAN_AUTO, "ambience/sparks.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
	set_task(5.0,"stopsound")
	
	client_print(player,print_chat,"A pope is electrocuting you OMFG!!11")
	
	return PLUGIN_HANDLED
}

public CMD_thunderslay(id, level, cid)
{
	if (!cmd_access(id, level, cid, 2)) // Checks if the command user has access
		return PLUGIN_HANDLED
	
	new Arg1[24] // player name
	read_argv(1, Arg1, 23) // Reads the players name
	
	new player = cmd_target(id, Arg1, 1) // finds a player id that matches the partial name given, also immunity
	
	if (!player) // if player not found
	{
		client_print(id, print_chat, "Player could not be found") // print console error
		return PLUGIN_HANDLED
	}
	
	new playerlocation[3]
	get_user_origin(player,playerlocation) // gets the players location and sets it to location
	
	new flag = 0
	for (new k = 0; k<10; k++)
	{
		if (sparks[k][0] == 0)
		{
			for (new i = 0; i<7; i++) // goes through lightning spawn 7 times
			{
			
				new randomlocation[3] // random location for lightning placement
				new higherlocation[3] // location higher up in the sky
			
				randomlocation[2] = playerlocation[2]-30 // sets the z value of the random location to the same as the players
				randomlocation[0] = playerlocation[0]+(random_num(-200,200)) // sets random location for lightning spawn
				randomlocation[1] = playerlocation[1]+(random_num(-200,200)) // similiar
			
				higherlocation[0] = randomlocation[0]
				higherlocation[1] = randomlocation[1]
				higherlocation[2] = randomlocation[2] + 300 // sets height
			
				beampoints(randomlocation, higherlocation, SpriteLightning, 1, 10, 10, 50, 100, 0, 0, 255, 100, 100) // creates lightning bolt
				smoke(randomlocation, SpriteSmoke, 5, 10) // creates smoke puff
				createspark(randomlocation, k, i, id) // creates spark
				
				set_task(1.0,"removesparks",i)
			
				new resultdistance // resulting distance from subtraction
			
				resultdistance = get_distance(playerlocation,randomlocation) // calculates the distance between players
			
				emit_sound(player,CHAN_AUTO, "ambience/port_suckin1.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
			
				if(resultdistance <= 60)
				{
					client_print(player,print_chat,"Pope was sleeping.. oh pope!!")
					set_task(0.1,"glow",player)
					set_task(0.3,"unglow",player)
					set_task(0.5,"glow",player)
					set_task(0.7,"unglow",player)
					set_task(0.9,"glow",player)
					set_task(1.1,"unglow",player)
					set_task(1.3,"glow",player)
					set_task(1.5,"unglow",player)
					set_task(1.7,"glow",player)
					set_task(1.9,"unglow",player)
					set_task(2.1,"glow",player)
					set_task(2.3,"unglow",player)
					set_task(2.5,"glow",player)
					set_task(2.7,"unglow",player)
					set_task(2.9,"glow",player)
					set_task(3.1,"unglow",player)
					set_task(3.3,"unglow",player)
					set_task(3.5,"glow",player)
					set_task(3.7,"unglow",player)
					set_task(3.9,"glow",player)
					set_task(4.1,"unglow",player)
					set_task(4.3,"unglow",player)
					set_task(4.5,"glow",player)
					set_task(4.7,"unglow",player)
					
					set_task(1.0,"lightningdamage",player,_,_,"a",5)
					
					emit_sound(player,CHAN_AUTO, "ambience/sparks.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
					
					set_task(5.0,"stopsound")
					set_task(5.0,"finalblow",player)
					
					flag = 1
				}
			}
			
			if(flag == 0)
			{
				client_print(player,print_chat,"OMFG THE POPE SAVED YOU!111```oneone")
			}
			
			return PLUGIN_HANDLED
		}
	}
	
	client_print(id,print_chat,"Too many people are using Pope Lightning")
	
	return PLUGIN_HANDLED
}

//-------------------------------------------------------------------------------------------------------------------
public removesparks(posistion)
{
	for (new i = 0; i<7; i++)
	{
		remove_entity(sparks[posistion][i])
		sparks[posistion][i] = 0
	}
}
//-------------------------------------------------------------------------------------------------------------------
public pfn_touch(ptr,ptd)
{

	if(ptr == 0 || ptd == 0) // if world
	{
		return PLUGIN_CONTINUE // kill touch
	}
	else
	{
		if(validSpark(ptr))
		{
			client_print(0,print_chat,"VALID SPARK")
			if(ptd<=32)
			{
				set_task(1.0,"damageinnocent",ptd,_,_,"a",5)
				set_task(0.1,"glow",ptd)
				set_task(0.3,"unglow",ptd)
				set_task(0.5,"glow",ptd)
				set_task(0.7,"unglow",ptd)
				set_task(0.9,"glow",ptd)
				set_task(1.1,"unglow",ptd)
				set_task(1.3,"glow",ptd)
				set_task(1.5,"unglow",ptd)
				set_task(1.7,"glow",ptd)
				set_task(1.9,"unglow",ptd)
				set_task(2.1,"glow",ptd)
				set_task(2.3,"unglow",ptd)
				set_task(2.5,"glow",ptd)
				set_task(2.7,"unglow",ptd)
				set_task(2.9,"glow",ptd)
				set_task(3.1,"unglow",ptd)
				set_task(3.3,"unglow",ptd)
				set_task(3.5,"glow",ptd)
				set_task(3.7,"unglow",ptd)
				set_task(3.9,"glow",ptd)
				set_task(4.1,"unglow",ptd)
				set_task(4.3,"unglow",ptd)
				set_task(4.5,"glow",ptd)
				set_task(4.7,"unglow",ptd)
			}
			return PLUGIN_CONTINUE
		}
		else if(validSpark(ptd))
		{
			client_print(0,print_chat,"VALID SPARK")
			if(ptr<=32)
			{
				set_task(1.0,"damageinnocent",ptr,_,_,"a",5)
				set_task(0.1,"glow",ptr)
				set_task(0.3,"unglow",ptr)
				set_task(0.5,"glow",ptr)
				set_task(0.7,"unglow",ptr)
				set_task(0.9,"glow",ptr)
				set_task(1.1,"unglow",ptr)
				set_task(1.3,"glow",ptr)
				set_task(1.5,"unglow",ptr)
				set_task(1.7,"glow",ptr)
				set_task(1.9,"unglow",ptr)
				set_task(2.1,"glow",ptr)
				set_task(2.3,"unglow",ptr)
				set_task(2.5,"glow",ptr)
				set_task(2.7,"unglow",ptr)
				set_task(2.9,"glow",ptr)
				set_task(3.1,"unglow",ptr)
				set_task(3.3,"unglow",ptr)
				set_task(3.5,"glow",ptr)
				set_task(3.7,"unglow",ptr)
				set_task(3.9,"glow",ptr)
				set_task(4.1,"unglow",ptr)
				set_task(4.3,"unglow",ptr)
				set_task(4.5,"glow",ptr)
				set_task(4.7,"unglow",ptr)
			}
			return PLUGIN_CONTINUE
		}
		else
		{
			return PLUGIN_CONTINUE
		}
	}
	
	return PLUGIN_CONTINUE
}
//-------------------------------------------------------------------------------------------------------------------

stock validSpark(entity)
{
	new usage
	new sprite
	for(usage=0; usage<10; usage++)
	{
		for(sprite=0; sprite<7; sprite++)
		{
			if(sparks[usage][sprite] == entity)
			{
				client_print(0,print_chat,"Valid Spark")
				return 1 // something useful
			}
		}
	}
	return 0 // garbage entity
}

//-------------------------------------------------------------------------------------------------------------------

public createspark(location[3], set, sparknum, id)
{
	new Float:LocVec[3]
	IVecFVec(location, LocVec)
	
	sparks[set][sparknum] = create_entity("env_sprite") // creates enterance ball
	if (!sparks[set][sparknum]) // if not exist
		return PLUGIN_HANDLED
					
	entity_set_string(sparks[set][sparknum], EV_SZ_classname, "Sparks") // set name
	entity_set_edict(sparks[set][sparknum], EV_ENT_owner, id) // set owner
	set_rendering(sparks[set][sparknum], kRenderFxNoDissipation, 0, 0, 0, kRenderGlow, 200) // normal and slight glow
	entity_set_int(sparks[set][sparknum], EV_INT_solid, 1) // not a solid but interactive
	entity_set_int(sparks[set][sparknum], EV_INT_movetype, 0) // set move type to toss
	entity_set_float(sparks[set][sparknum], EV_FL_framerate, 10.0) // Frame Rate
	entity_set_model(sparks[set][sparknum], "sprites/xspark2.spr") // enterance sprite
	entity_set_origin(sparks[set][sparknum], LocVec) // start posistion 
	DispatchSpawn(sparks[set][sparknum]) // Dispatches the Fire
	
	return PLUGIN_CONTINUE
}
					
//-------------------------------------------------------------------------------------------------------------------

public lightningdamage(id)
{
	if (get_user_health(id) <= 10 && !damagedalready[id]) // checks if users health is lower than 10 and not damaged already
	{
		fakedamage(id,"Lightning",10.0,DMG_BLAST)
		
		damagedalready[id] = true // set damage to true so they still don't bleed after respawn
		set_task(5.0,"undamagedalready",id) // resets damage 5 seconds after death
	}
	else if (!damagedalready[id]) // checks if player is damaged already
	{
		fakedamage(id,"Lightning",10.0,DMG_BLAST)
	}

	return PLUGIN_CONTINUE
}
//-------------------------------------------------------------------------------------------------------------------

public damageinnocent(id)
{
	if (get_user_health(id) <= 10 && !damagedalready[id]) // checks if users health is lower than 10 and not damaged already
	{
		client_print(0,print_chat,"IN FINISHING")
		return PLUGIN_CONTINUE
	}
	else
	{
		client_print(0,print_chat,"IN DAMAGE")
		fakedamage(id,"Lightning",10.0,DMG_BLAST)
		return PLUGIN_CONTINUE
	}
	return PLUGIN_CONTINUE
}

//-------------------------------------------------------------------------------------------------------------------

public finalblow(id)
{
	if (!damagedalready[id]) // checks if they were damaged already
	{
		fakedamage(id,"Lightning",2000.0,DMG_BLAST)
		emit_sound(id,CHAN_AUTO, "ambience/port_suckin1.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
	}
}

//-------------------------------------------------------------------------------------------------------------------

public glow(id)
{
	set_user_rendering(id,kRenderFxGlowShell,0,0,255,kRenderNormal,25)
}
public unglow(id)
{
	set_user_rendering(id,kRenderFxGlowShell,0,0,0,kRenderNormal,25)
}

//-------------------------------------------------------------------------------------------------------------------

// Stopsound function for looping sounds
public stopsound()
{
	client_cmd(0,"stopsound") // stops sound on all clients 
}

//-------------------------------------------------------------------------------------------------------------------

public undamagedalready(id) 
{ 
    damagedalready[id] = false 
    return PLUGIN_HANDLED 
}

//-------------------------------------------------------------------------------------------------------------------

/* SVC_TEMPENTITY Effect using TE_BEAMPOINTS
   INPUT: below for description
   OUTPUT: Beam between two points
*/
public beampoints(startloc[3], endloc[3], spritename, startframe, framerate, life, width, amplitude, r, g, b, brightness, speed)
{
	message_begin( MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(0) // TE_BEAMPOINTS
	write_coord(startloc[0])
	write_coord(startloc[1])
	write_coord(startloc[2]) // start location
	write_coord(endloc[0])
	write_coord(endloc[1])
	write_coord(endloc[2]) // end location
	write_short(spritename) // spritename
	write_byte(startframe) // start frame
	write_byte(framerate) // framerate
	write_byte(life) // life
	write_byte(width) // line width
	write_byte(amplitude) // amplitude
	write_byte(r)
	write_byte(g)
	write_byte(b) // color
	write_byte(brightness) // brightness
	write_byte(speed) // speed
	message_end()
}
//-------------------------------------------------------------------------------------------------------
/* SVC_TEMPENTITY Effect using TE_SMOKE
   INPUT: below for description
   OUTPUT: Gentle smoke stream travelling upwards
*/
public smoke(startloc[3], spritename, scale, framerate)
{
	message_begin( MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(5) // TE_SMOKE
	write_coord(startloc[0])
	write_coord(startloc[1])
	write_coord(startloc[2]) // start location
	write_short(spritename) // spritename
	write_byte(scale) // scale of sprite
	write_byte(framerate) // framerate of sprite
	message_end()
}
//-------------------------------------------------------------------------------------------------------