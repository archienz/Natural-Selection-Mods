// Plugin by blu.knight   AMXX 1.60
//   This plugin makes it so that skulks can jump off
//   walls at a higher velocity.
//   Can be disabled via the amx_incr_wjump cvar.

#include <amxmodx>
#include <engine>
#include <ns>

#define maxplayers 33
new bool:applyjump[maxplayers] = false

public plugin_init() {
  register_plugin("Skulk Wall-Jump", "1.1 ", "blu.knight")
  register_cvar("amx_incr_wjump", "1")
}

public client_putinserver(id) { 
  applyjump[id] = false
}
public client_disconnect(id) { 
  applyjump[id] = false 
}

public client_PreThink(id) {
  if (!is_user_alive(id))
    return PLUGIN_CONTINUE
     
  if (get_cvar_num("amx_incr_wjump")) {
    if (button_down(id, IN_JUMP) && is_class(id,CLASS_SKULK) && ns_get_mask(id,MASK_WALLSTICKING)) {
      applyjump[id] = true
   }    
  }
    
  return PLUGIN_CONTINUE
}

public client_PostThink(id) {
  if (applyjump[id]) {
     makejump(id)
     applyjump[id] = false
  }
  
  return PLUGIN_CONTINUE
}

public makejump(id) {
  new Float:velo[3]	
  new Float:oldvelo[3]
  new Float:newvelo[3]
  
  VelocityByAim(id, 200, velo) // Velocity in direction of player's view
  entity_get_vector(id,EV_VEC_velocity,oldvelo) // Grab current velocity
  for (new i = 0; i < 3; i++)  // Add the old and aim velocity
    newvelo[i] = velo[i] + oldvelo[i] 
  entity_set_vector(id,EV_VEC_velocity,newvelo) // set new
}
	
/*
 // This was created to tell the velocity and magnitude, when needed.
public hookvelo(id) {
  new Float:velocity[3]
  entity_get_vector(id,EV_VEC_velocity,velocity)
  client_print(id,print_chat,"Velocity at test: %f %f %f",velocity[0], velocity[1], velocity[2])
  new Float:magnitude 
  magnitude = floatpower(velocity[0],2.0) + floatpower(velocity[1],2.0) + floatpower(velocity[2],2.0)
  magnitude = floatpower(magnitude, 0.5)
  client_print(id,print_chat,"Magnitude at test: %f", magnitude)
  return FMRES_HANDLED
}*/
	
// -----The functins below simplify some ugly code
public is_class(id, class) {
  return (ns_get_class(id) == class)
}

public button_up(id, button) {
  return (!(get_user_button(id) & button) && (get_user_oldbutton(id) & button))
}
public button_down(id, button) {
  return ((get_user_button(id) & button) && !(get_user_oldbutton(id) & button))
}
public button_held(id, button) {
  return ((get_user_button(id) & button) && (get_user_oldbutton(id) & button))
}

public entity_flag(id, flag) {
  return (get_entity_flags(id) & FL_ONGROUND)
}
