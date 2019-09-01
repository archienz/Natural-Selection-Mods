#include <amxmodx>
#include <engine>

/*
Bouncy grenades ported by mE @ psix.info
----------------------------------------
Originally by lillbrorsan:

This is a simple plugin that makes the grenades from gl bounce and glow.

kl_bounce = On(1) Off(0)
kl_bouncy = Change how much the grenade should be able to bounce around

I want to thank prsearle who helped me all way through this
plug-in. I have learned alot about metamod because of his
patience and explanations of the different commands etc.

I owe prsearle alot for these hours it took to make. Thx prsearle
that you listened and helped me. I have learn ALOT. Thx again.

kristoffer_lov@hotmail.com
www.kristoffersworld.tk
*/

public plugin_init(){
  register_plugin("Bouncy grenades","1.0","mE @ psix.info & lillbrorsan")
  register_cvar("amx_bouncygrenades", "1.0",4)
  register_cvar("kl_bounce","1")
  register_cvar("kl_bouncy","0.1")
  
  set_task(0.5,"check_grenades",0,"",0,"b")
}

public check_grenades(){
  if(!get_cvar_num("kl_bounce")) return
  new ent
  while((ent = find_ent_by_class(ent,"grenade")) > 0){
    new Float:f[3]
    entity_get_vector(ent,EV_VEC_vuser1,f)
    if(f[0] == 123.4) continue
    
    //client_print(0,print_chat,"[AMXX] New grenade bouncing!")

    f[0] = 123.4
    entity_set_vector(ent,EV_VEC_vuser1,f)
    
    entity_set_int(ent,EV_INT_rendermode,kRenderNormal)
    entity_set_int(ent,EV_INT_renderfx,kRenderFxGlowShell)
    entity_set_float(ent,EV_FL_renderamt,0.0)
    entity_set_vector(ent,EV_VEC_rendercolor,Float:{0.0,0.0,0.0})
    new effects = entity_get_int(ent,EV_INT_effects)
    if(!(effects & EF_DIMLIGHT)){
      entity_set_int(ent,EV_INT_effects,effects + EF_DIMLIGHT)
    }
    entity_set_float(ent,EV_FL_friction,get_cvar_float("kl_bouncy"))
    entity_set_float(ent,EV_FL_gravity,get_cvar_float("kl_bouncy"))
  }
  return
}
