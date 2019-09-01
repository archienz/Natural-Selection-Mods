/* Unchained Chambers - v 0.20 (AMXX)
 * -
 * This plugin will allow gorges to build any form of chamber
 * so long as they have one hive.  However, aliens may only get
 * one upgrade for each active hive they have.
 *
 * cvars:
 * me_unchain - Does nothing, ignore it.
 * mp_unchained - Three modes (0,1,2; default: 1):
 *                0 - Disabled.
 *                1 - Enabled, chambers cost: d: 12, m: 10, s: 15
 *                2 - Enabled, chambers cost default values.
 *                Note: Changes to this cvar are only registered at
 *                      map change.
 *
 * Other notes:  This plugin automatically disables itself when
 *               mp_tournamentmode > 0
 * -
 * Originally created by (posted on modNS.org): 
 * -mE- (www.psix.info)
 */
#include <amxmodx>
#include <engine>
#include <ns>


#define IMPULSE_DC    92
#define IMPULSE_SC    93
#define IMPULSE_MC    94
new needMsg[33]
new active

public plugin_modules()
{
  require_module("ns")
  require_module("engine")
}

public plugin_init()
{
  if (!ns_is_combat())
  {
    new i
    while (i<33)
    {
      needMsg[i]=0
      i++
    }
    register_plugin("Unchained [active]","0.20","Steve Dudenhoeffer")
    register_impulse(101,"upgrade")
    register_impulse(102,"upgrade")
    register_impulse(103,"upgrade")
    register_impulse(107,"upgrade")
    register_impulse(108,"upgrade")
    register_impulse(109,"upgrade")
    register_impulse(110,"upgrade")
    register_impulse(111,"upgrade")
    register_impulse(112,"upgrade")
    
    register_impulse(92,"build")
    register_impulse(93,"build")
    register_impulse(94,"build")
    register_event("HudText2","SendNotice","b","1=ReadyRoomMessage")
    register_message(get_user_msgid("SetTech"),"SetTech")
  }
  else
    register_plugin("Unchained [off]","0.20","Steve Dudenhoeffer")
  register_cvar("mp_unchained","1",FCVAR_SERVER)
  register_cvar("me_unchain","amxx",FCVAR_SERVER) // does nothing but requested by original author
}
public SetTech(id)
{
  if (active!=1 || get_cvar_num("mp_tournamentmode"))
    return PLUGIN_CONTINUE
    
  switch (get_msg_arg_int(2))
  {
  case IMPULSE_DC:
    set_msg_arg_int(6,ARG_SHORT,12)
  case IMPULSE_SC:
    set_msg_arg_int(6,ARG_SHORT,15)
  }
  return PLUGIN_CONTINUE
}
public plugin_cfg()
{
  active=get_cvar_num("mp_unchained")
}
public SendNotice(id)
{
  if (!active || get_cvar_num("mp_tournamentmode"))
    return PLUGIN_CONTINUE
  if (needMsg[id])
    ns_popup(id,"[AMXX] This server is running the unchained chambers modification.")
  needMsg[id]=0
  return PLUGIN_CONTINUE
}
public client_connect(id)
{
  needMsg[id]=1
}
  
  
public build(id,imp)
{
  if (active!=1 || get_cvar_num("mp_tournamentmode"))
    return PLUGIN_CONTINUE
  
  switch(imp)
  {
  case IMPULSE_DC:
      if (ns_get_res(id) < 12)
        return PLUGIN_HANDLED
  case IMPULSE_SC:
      if (ns_get_res(id) < 15)
        return PLUGIN_HANDLED
  }
  return PLUGIN_CONTINUE
}
stock get_num_upgrades(id)
{
  new c=0;
  if (ns_get_mask(id,MASK_SILENCE))
    c++;
  if (ns_get_mask(id,MASK_ADRENALINE))
    c++;
  if (ns_get_mask(id,MASK_CELERITY))
    c++;
  if (ns_get_mask(id,MASK_CARAPACE))
    c++;
  if (ns_get_mask(id,MASK_REDEMPTION))
    c++;
  if (ns_get_mask(id,MASK_REGENERATION))
    c++;
  if (ns_get_mask(id,MASK_FOCUS))
    c++;
  if (ns_get_mask(id,MASK_SCENTOFFEAR))
    c++;
  if (ns_get_mask(id,MASK_CLOAKING))
    c++;
  return c;
}
public upgrade(id)
{
  if (!active || get_cvar_num("mp_tournamentmode"))
    return PLUGIN_CONTINUE
  if (ns_get_build("team_hive",1,0) <= get_num_upgrades(id))
  {
    ns_popup(id,"[AMXX] Only one upgrade allowed per hive.")
    return PLUGIN_HANDLED
  }
  return PLUGIN_CONTINUE
}

public client_built(idPlayer,idStructure,type,impulse)
{
  if (!active || get_cvar_num("mp_tournamentmode"))
    return PLUGIN_CONTINUE
  if (type == 2)
  {
    new i
    for (i=1;i<=ns_get_build("team_hive",1,0);i++)
    {
      ns_set_hive_trait(ns_get_build("team_hive",1,i),HIVETRAIT_NONE)
    }
    // fix the player's res
    switch (impulse)
    {
    case IMPULSE_DC:
      ns_set_res(idPlayer,ns_get_res(idPlayer)-2)
    case IMPULSE_SC:
      ns_set_res(idPlayer,ns_get_res(idPlayer)-5)
    }
  }
  return PLUGIN_CONTINUE
}
