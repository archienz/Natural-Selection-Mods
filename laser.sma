/* AMX Mod script.
*
* Author: Sandstorm
* This file is provided as is (no warranties). 
*
* This plugin adds a laser beam to light marines and the pistol.
*
* Cvars:
* laser_enable		- Enables/Disables the plugin
* laser_default		- Enables/Disables the lasers by default
* laser_cull		- Enables/Disables laser culling
* laser_enemy		- Enables/Disables enemy lasers
*
* Commands:
* /laser		- Toggles a client's preference for lasers
*
* Modules (AMX):
* NS2AMX v1.0
*
* Modules (AMX Mod X 0.20):
* NS
*
* 1.4	- Added cvar laser_enemy, controls if enemies see the laser
*	- Laser setting saved to infostring "ls"
* 1.3	- Fixed digesting marines having lasers
*	- Laser no longer starts inside Marine (AMXMODX only)
*	- Laser beam hidden when spectating a Marine
*	- Added cvar laser_cull, controls laser culling
* 1.2	- Added laser culling, to reduce bandwidth usage
*	- Marines now have lasers in the readyroom
* 1.1	- Changed laser to a more subtle look
*	- Player only sees his own laser as a dot
*	- Allow clients to toggle laser preference
*	- Fixed bug that gave the commander a pistol laser
*/

#include <amxmodx>
#include <ns>
#include <engine>
#include <fakemeta>

#define MAXPLAYERS		32
#define MAXMESSAGELENGTH	80
#define CULL_DISTANCE		1000		// Max distance lasers will be drawn from player
#define CULL_COUNT		10		// Max lasers drawn in 100ms time period
#define CULL_MINLENGTH		20		// Minimum length beam must be to draw it
#define LASER_BRIGHTNESS	30		// How bright lasers are
#define LASER_SIZE		1		// How big lasers are
#define TE_BEAMPOINTS		0
#define TE_SPRITE		17
#define TE_BEAMSPRITE		18
 
new laser_name[] =		"Marine Lasersight"
new laser_version[] =		"1.4"
new laser_author[] =		"Sandstorm"
new cvar_version[] =		"laser_version"
new cvar_enable[] =		"laser_enable"
new cvar_default[] =		"laser_default"
new cvar_cull[] =		"laser_cull"
new cvar_enemy[] =		"laser_enemy"
new info_lasersetting[] =	"ls"
new cmd_laser[] =		"/laser"
new say_laser[] =		"say /laser"
new sayteam_laser[] =		"say_team /laser"
new msg_on[] = 			"[LASER] Lasers are now visible. Type /laser to hide them"
new msg_off[] = 		"[LASER] Lasers are now hidden. Type /laser to see them"
new msg_disabled[] = 		"[LASER] Lasers are disabled.  The /laser command has no effect"
new msg_nocull[] = 		"[LASER] Laser culling is off. The /laser command has no effect"
new msg_intro_off[] =		"[LASER] This server has Marine lasers. Type /laser to see them"
new msg_intro_on[] =		"[LASER] This server has Marine lasers. Type /laser to hide them"
new msg_intro_nocull[] =	"[LASER] This server has Marine lasers. Laser culling is off"
new mdl_laser[] =		"sprites/laserbeam.spr"
new mdl_dot[] =			"sprites/ns_nothing/redflare2.spr"

new laser_index
new dot_index
new cl_laser_on[MAXPLAYERS]			// Stores client laser settings
new cl_laser_count[MAXPLAYERS]			// Number of lasers sent to client, reset every 100ms

// Teams
enum {
  tNone = 0,
  tMarine,
  tAlien,
  tMarine2,
  tAlien2,
  tSpectator
}

#if !defined _amxmodx_included
  stock ns_get_class(id)
    return get_class(id)

  stock ns_get_mask(id,mask)
    return get_mask(id,mask)

  stock Float:vector_distance(Float:start[3], Float:end[3])
  {
    // For simplicity sake, we'll use the built-in AMX int vectors
    new istart[3], iend[3], result
    get_vector_int(start,istart)
    get_vector_int(end,iend)
    result = get_distance(istart,iend)
    return float(result)
  }
#endif

// Returns if a client wants lasers
stock is_laser_on(id)
  return cl_laser_on[id-1]

// Set a client's laser preference to on
stock set_laser_on(id)
  cl_laser_on[id-1] = 1

// Set a client's laser preference to off
stock set_laser_off(id)
  cl_laser_on[id-1] = 0

// Return if server has lasers enabled
stock is_laser_enabled()
  return get_cvar_num(cvar_enable)

// Return if laser defaults to on
stock is_laser_default()
  return get_cvar_num(cvar_default)

// Return if culling is enabled
stock is_culling_on()
  return get_cvar_num(cvar_cull)

// Returns if a laser should be culled
stock is_laser_culled(id)
  return cl_laser_count[id-1] > CULL_COUNT

// Returns if enemy lasers are visible
stock is_enemy_visible()
  return get_cvar_num(cvar_enemy)

// Return if two players are enemies
stock is_enemy(id1,id2)
{
  if(pev(id1,pev_team) == tSpectator || pev(id2,pev_team) == tSpectator)
    return 0
  if(pev(id1,pev_team) == tNone || pev(id2,pev_team) == tNone)
    return 0
  if(pev(id1,pev_team) == pev(id2,pev_team))
    return 0
  return 1
}

stock set_laser_setting(id)
  client_cmd(id,"setinfo %s %d",info_lasersetting,is_laser_on(id))

stock get_laser_setting(id)
{
  new output[MAXMESSAGELENGTH+1]
  get_user_info(id,info_lasersetting,output,MAXMESSAGELENGTH)
  if (!output[0])
    return is_laser_default()
  return str_to_num(output)
}

// Adds another laser to the count
stock laser_count_add(id)
  if(id) 
    cl_laser_count[id-1] += 1

// Resets the laser count
stock laser_count_reset(id)
  if(id)
    cl_laser_count[id-1] = 0

// Returns who the player is currently spectating
stock get_spec_target(id)
  return pev(id,pev_iuser2)

// Returns if the player is digesting
stock is_player_digesting(id)
  return ns_get_mask(id,MASK_DIGESTING)

// Is the player a light/jetpack marine
stock is_player_light(id)
{
  new model[MAXMESSAGELENGTH+1]
  switch (ns_get_class(id)) {
    case CLASS_MARINE, CLASS_JETPACK:
      return 1
    case CLASS_NOTEAM, CLASS_UNKNOWN: {
        pev(id,pev_model,model,MAXMESSAGELENGTH)
	if (equal(model,"models/player/soldier/soldier.mdl"))
	  return 1
	return 0
      }
    default:
      return 0
  }
  return 0
}

// Is the player a readyroom unit (they're slightly shorter apparently)
stock is_player_readyroom(id)
{
  new model[MAXMESSAGELENGTH+1]
  switch (ns_get_class(id)) {
    case CLASS_NOTEAM, CLASS_UNKNOWN: {
        pev(id,pev_model,model,MAXMESSAGELENGTH)
	if (equal(model,"models/player.mdl"))
	  return 1
	return 0
      }
    default:
      return 0
  }
  return 0
}


// Is the player's weapon a pistol
stock is_weapon_pistol(id)
{
  if (ns_get_class(id) == CLASS_COMMANDER)
    return 0

  new clip, ammo
  switch (get_user_weapon(id, clip, ammo)) {
    case WEAPON_PISTOL:
      return 1
    default:
      return 0
  }
  return 0  
}

// Is the player a valid player
stock is_player_valid(id)
{
  if (!is_user_connected(id))
    return 0
  if (!is_user_alive(id))
    return 0
  return 1
}

// Copy a float vector to an int vector
stock get_vector_int(Float:vector[3], ivector[3])
{
  ivector[0] = floatround(vector[0])
  ivector[1] = floatround(vector[1])
  ivector[2] = floatround(vector[2])
}

// Return if two float vectors are equal
stock is_vector_equal(Float:vector1[3], Float:vector2[3])
{
  if (vector1[0] == vector2[0])
    if (vector1[1] == vector2[1])
      if (vector1[2] == vector2[2])
        return 1
  return 0
}

// Get the user's location as a float vector
stock get_user_vector(id,Float:vector[3],type)
{
  new origin[3]
  get_user_origin(id,origin,type)
  vector[0] = float(origin[0])
  vector[1] = float(origin[1])
  vector[2] = float(origin[2])
}

// Return vector in winner which is visible by the user
stock find_vector_visible(id,Float:vec1[3],Float:vec2[3],Float:vec3[3],Float:winner[3])
{
  new Float:start[3]
  get_user_vector(id,start,1)

  trace_line(id,start,vec1,winner)
  if (is_vector_equal(vec1,winner))
    return 1
  trace_line(id,start,vec2,winner)
  if (is_vector_equal(vec2,winner))
    return 2
  trace_line(id,start,vec3,winner)
  if (is_vector_equal(vec3,winner))
    return 3
  return 0
}

// Returns true if dot is visible for player
stock is_dot_visible(id,Float:point[3])
{
  // Always return true if culling is off
  if (!is_culling_on())  
    return 1

  new Float:start[3], Float:result[3], Float:distance
  get_user_vector(id,start,1)

  // If distance exceeds our cull distance, not visible
  distance = vector_distance(start,point)
  if (floatround(distance) > CULL_DISTANCE)
    return 0

  // If we can't see this laser dot, not visible
  trace_line(id,start,point,result)
  if (!is_vector_equal(point,result))
    return 0

  return 1
}

// Draw a laser dot
stock laser_draw_dot(id,Float:point[3])
{
  new ipoint[3]
  if (!is_dot_visible(id,point))
    return

  // Draw the laser dot
  get_vector_int(point,ipoint)
  if(is_culling_on())
    message_begin(MSG_PVS,SVC_TEMPENTITY,ipoint,id)
  else
    message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
  write_byte(TE_SPRITE)
  write_coord(ipoint[0])
  write_coord(ipoint[1]) 
  write_coord(ipoint[2]) 
  write_short(dot_index) 
  write_byte(1)				// Scale
  write_byte(LASER_BRIGHTNESS)		// Brightness
  message_end()
  laser_count_add(id)
}

// Returns true if line is visible for player, use best[] for PVS check
stock is_line_visible(id,Float:src[3],Float:dest[3],Float:best[3])
{
  // Always return true if culling is off
  if (!is_culling_on())  
    return 1

  new Float:start[3], Float:mid[3]
  new Float:src_dist, Float:dest_dist, Float:mid_dist
  get_user_vector(id,start,1)

  // Find the midpoint
  mid[0] = (src[0] + dest[0]) / 2
  mid[1] = (src[1] + dest[1]) / 2
  mid[2] = (src[2] + dest[2]) / 2

  // If the beam distance is too short, not visible
  src_dist = vector_distance(src,dest)
  if (floatround(src_dist) < CULL_MINLENGTH)
    return 0

  // If all points exceed our cull distance, not visible
  src_dist = vector_distance(start,src)
  dest_dist = vector_distance(start,dest)
  mid_dist = vector_distance(start,mid)
  if (floatround(src_dist) > CULL_DISTANCE)
    if (floatround(dest_dist) > CULL_DISTANCE)
      if (floatround(mid_dist) > CULL_DISTANCE)
        return 0

  // If none of these can be seen by the player, not visible
  if (!find_vector_visible(id,src,mid,dest,best))
    return 0

  return 1
}

// Draw a laser line
stock laser_draw_line(id,Float:src[3],Float:dest[3])
{
  new Float:result[3]
  new isrc[3], idest[3], iresult[3]
  
  if(!is_line_visible(id,src,dest,result))
    return

  // Draw the laser beam
  get_vector_int(src,isrc)  
  get_vector_int(dest,idest)  
  get_vector_int(result,iresult)  
  
  if(is_culling_on())
    message_begin(MSG_PVS,SVC_TEMPENTITY,iresult,id)
  else
    message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
  write_byte(TE_BEAMPOINTS)
  write_coord(isrc[0])
  write_coord(isrc[1]) 
  write_coord(isrc[2]) 
  write_coord(idest[0]) 
  write_coord(idest[1]) 
  write_coord(idest[2]) 
  write_short(laser_index) 
  write_byte(1)			// Starting Frame
  write_byte(5)			// Frame rate
  write_byte(1)			// Life
  write_byte(LASER_SIZE)	// Line Width
  write_byte(0)			// Noise
  write_byte(255)		// Color: Red
  write_byte(0)			// Color: Green
  write_byte(0)			// Color: Blue
  write_byte(LASER_BRIGHTNESS)	// Brightness
  write_byte(0)			// Scroll speed
  message_end()
  laser_count_add(id)
}

/* 

This is the old laser draw function.

stock laser_draw_old(src[3],dest[3])
{
  message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
  write_byte(TE_BEAMSPRITE)
  write_coord(src[0])
  write_coord(src[1]) 
  write_coord(src[2]) 
  write_coord(dest[0]) 
  write_coord(dest[1]) 
  write_coord(dest[2]) 
  write_short(laser_index) 
  write_short(dot_index)
  message_end()
}
*/

// Draw a laser for clients that want them
stock laser_draw(id,Float:src[3],Float:dest[3])
{
  if (!is_culling_on()) {
    laser_draw_dot(0,dest)
    laser_draw_line(0,src,dest)
    return
  }

  new viewid  
  for(new i=1;i<=MAXPLAYERS;i++)  
    if(is_user_connected(i))
      if(is_laser_on(i)) 
        if(!is_laser_culled(i)) {
          // If the player is spectating someone, use the spec's id
          viewid = !get_spec_target(i) ? i : get_spec_target(i)
	  if(is_enemy_visible() || !is_enemy(id,viewid)) {
            laser_draw_dot(viewid,dest)
            // Players don't see their own beams
            if(id != viewid)
              laser_draw_line(i,src,dest)
	  }
        }
}

// Get the vectors for a player's laser
stock laser_get_vectors(id,Float:player[3],Float:hitpoint[3],height=0)
{
  new Float:origin[3]
  get_user_vector(id,origin,1)
  get_user_vector(id,hitpoint,3)
  origin[2] += float(height)
  trace_line(0,hitpoint,origin,player)
}

// Update laser for this player
stock laser_update_player(id)
{
  if (!is_player_valid(id))
    return

  if (is_player_digesting(id))
    return

  new Float:start[3], Float:hitpoint[3]
  if (is_player_light(id)) {
    laser_get_vectors(id,start,hitpoint,10)
    laser_draw(id,start,hitpoint)
  }

  if (is_player_readyroom(id)) {
    laser_get_vectors(id,start,hitpoint)
    laser_draw(id,start,hitpoint)
  }

  if (is_weapon_pistol(id)) {
    laser_get_vectors(id,start,hitpoint)
    laser_draw(id,start,hitpoint)
  }
}

// Client wants to toggle their laser settings
public do_laser(id)
{
  if (!is_laser_enabled()) {
    client_print(id,print_chat,msg_disabled)
    console_print(id,msg_disabled)
    return PLUGIN_HANDLED
  }

  if (!is_culling_on()) {
    client_print(id,print_chat,msg_nocull)
    console_print(id,msg_nocull)
    return PLUGIN_HANDLED
  }

  if(is_laser_on(id)) {
    set_laser_off(id)
    set_laser_setting(id)
    client_print(id,print_chat,msg_off)
    console_print(id,msg_off)
  }
  else {
    set_laser_on(id)
    set_laser_setting(id)
    client_print(id,print_chat,msg_on)
    console_print(id,msg_on)
  }

  return PLUGIN_HANDLED
}

// Our culling of lasers has expired, reset it
public laser_reset_cull()
  for(new i=0;i<MAXPLAYERS;i++)
    laser_count_reset(i+1)

// Give out info on the laser plugin
public laser_intro(parameter[1])
{
  new id = parameter[0]

  if(!is_culling_on()) {
    client_print(id,print_chat,msg_intro_nocull)
    console_print(id,msg_intro_nocull)
    return
  }

  if(is_laser_on(id)) {
    client_print(id,print_chat,msg_intro_on)
    console_print(id,msg_intro_on)
  }
  else {
    client_print(id,print_chat,msg_intro_off)
    console_print(id,msg_intro_off)
  }  
}

// Player joined the game
public client_putinserver(id)
{
  if(!is_laser_enabled())
    return  

  new parameter[1]
  parameter[0] = id

  if(get_laser_setting(id))
    set_laser_on(id)
  else
    set_laser_off(id)

  set_task(3.0,"laser_intro",_,parameter,1)
}

// Player is updated
public client_PostThink(id)
  if (is_laser_enabled())
    laser_update_player(id)

public plugin_precache()
{
  laser_index = precache_model(mdl_laser)
  dot_index = precache_model(mdl_dot)
}

public plugin_init() 
{ 
  register_plugin(laser_name,laser_version,laser_author)
  register_cvar(cvar_version,laser_version,FCVAR_EXTDLL | FCVAR_SERVER)
  register_cvar(cvar_enable,"1")
  register_cvar(cvar_default,"0")
  register_cvar(cvar_cull,"1")
  register_cvar(cvar_enemy,"0")
  register_clcmd(cmd_laser,"do_laser")
  register_clcmd(say_laser,"do_laser")
  register_clcmd(sayteam_laser,"do_laser")
  set_task(0.1,"laser_reset_cull",_,_,_,"b")
  return PLUGIN_CONTINUE
}

#if defined _amxmodx_included
  public plugin_modules() 
  {
    require_module("ns_amxx")
    require_module("engine_amxx")
    require_module("fakemeta_amxx")
  }
#endif