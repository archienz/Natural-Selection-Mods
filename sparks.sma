/* AMX Mod script.
*
* Author: Sandstorm
* This file is provided as is (no warranties). 
* Ported to AMX Mod X by Depot 02/04/05
*
* This plugin causes damaged heavy armor to shoot out sparks.
* As the damage becomes severe, the heavy armor will start to
* smoke.
*
* Cvars:
* sparks_enabled "1"		- Enables or Disables plugin
*
* Modules: 
* ns   fakemeta
*
*/

#include <amxmodx> 
#include <amxmisc>
#include <ns>
#include <fakemeta>

stock Float:pev_f(_index,_field)
{
  new Float:f
  pev(_index,_field,f)
  return f
}

#define TE_SMOKE			5
#define TE_SPARKS			9
#define SPARKS_ARMOR		100
#define SMOKE_ARMOR		25
#define SPARKS_INTERVAL		3.0
#define SMOKE_INTERVAL		0.5
#define MAX_PLAYERS		32

new sparks_name[] =		"sparks"
new sparks_version[] =		"1.0"
new sparks_author[] =		"Sandstorm"
new cvar_enabled[] =		"sparks_enabled"
new cvar_version[] =		"sparks_version"
new smoke_index
new smoke_name[] = 		"sprites/steam1.spr"
new sparksound_name[] = 	"ambience/hotspark.wav"
new smokesound_name[] = 	"weapons/welder.wav"
new sparklist[MAX_PLAYERS]
new smokelist[MAX_PLAYERS]

// True if player is sparking
public is_sparking(id)
  return sparklist[id-1] == 1

// True if player is smoking
public is_smoking(id)
  return smokelist[id-1] == 1

// True if player is a heavy
public is_heavy(id)
  return ns_get_class(id) == CLASS_HEAVY

// True if plugin is enabled
public is_enabled()
  return get_cvar_num(cvar_enabled)

// True if player can spark
public can_spark(id)
{
  new armor = floatround(pev_f(id, pev_armorvalue))
  new result = is_heavy(id) && (armor <= SPARKS_ARMOR)

  // We aren't sparking anymore if we can't spark
  if (!result)
    sparklist[id-1] = 0

  return result
}

// True if player can smoke
public can_smoke(id)
{
  new armor = floatround(pev_f(id, pev_armorvalue))
  new result = is_heavy(id) && (armor <= SMOKE_ARMOR)

  // We aren't smoking anymore if we can't smoke
  if (!result)
    smokelist[id-1] = 0

  return result
}

// Makes player shoot out sparks
public make_sparks(id)
{
  new userorigin[3]
  get_user_origin(id,userorigin)

  message_begin(MSG_BROADCAST, SVC_TEMPENTITY) 
  write_byte(TE_SPARKS) 
  write_coord(userorigin[0])		// x
  write_coord(userorigin[1]) 		// y
  write_coord(userorigin[2]) 		// z
  message_end()

  emit_sound(id,CHAN_AUTO,sparksound_name,VOL_NORM,ATTN_NORM,0,PITCH_NORM)

  // We have sparked
  sparklist[id-1] = 1

  return
}

// Makes player shoot out smoke
public make_smoke(id)
{
  new userorigin[3]
  get_user_origin(id,userorigin)

  message_begin(MSG_BROADCAST, SVC_TEMPENTITY) 
  write_byte(TE_SMOKE) 
  write_coord(userorigin[0]) 		// x
  write_coord(userorigin[1]) 		// y
  write_coord(userorigin[2]) 		// z
  write_short(smoke_index)		// Sprite index
  write_byte(6)				// Scale
  write_byte(10)				// Framerate
  message_end()

  emit_sound(id,CHAN_AUTO,smokesound_name,VOL_NORM,ATTN_NORM,0,PITCH_NORM)

  // We have smoked
  smokelist[id-1] = 1

  return
}

// Called to check for sparks
public update_sparks(parameter[1])
{
  if (!is_enabled())
    return

  new id = parameter[0]
  
  // No reason to keep updating if we can't spark
  if (!can_spark(id))
    return

  make_sparks(id)
  set_task(SPARKS_INTERVAL,"update_sparks",400+id,parameter,1)
}

// Called to check for smoke
public update_smoke(parameter[1])
{
  if (!is_enabled())
    return

  new id = parameter[0]

  // No reason to keep updating if we can't smoke
  if (!can_smoke(id))
    return

  make_smoke(id)
  set_task(SMOKE_INTERVAL,"update_smoke",500+id,parameter,1)
}

// Check for potential sparking when damaged
public check_sparks(id)
{
  if (!is_enabled())
    return

  new parameter[1]
  parameter[0] = id

  // If they aren't already, make them keep sparking
  if (!is_sparking(id))
    update_sparks(parameter)

  // If they aren't already, make them keep smoking
  if (!is_smoking(id))
    update_smoke(parameter)

  // Players will spark immediately when damaged
  if (can_spark(id))
    make_sparks(id)

  // Players will smoke immediately when damaged
  if (can_smoke(id))
    make_smoke(id)
}

// Precache sprites and sounds
public plugin_precache()
{
  smoke_index = precache_model(smoke_name)
  precache_sound(sparksound_name)
  precache_sound(smokesound_name)
}

public plugin_init()
{ 
  register_plugin(sparks_name,sparks_version,sparks_author)
  register_event("Damage", "check_sparks", "b")
  register_cvar(cvar_enabled,"1")
  register_cvar(cvar_version,sparks_version,FCVAR_EXTDLL | FCVAR_SERVER)
  return PLUGIN_CONTINUE
}