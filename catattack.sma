/*
 * Name: Catalyst Attack
 * Author: #endgame
 * Version: Alpha
 *
 * Catalysts are stored on contact and then used when +attack is next
 * pressed.
 *
 * Tested on Win32 listen server:
 * AMXX Version: 1.76b
 * Metamod Version: 1.19
 * NS Version: 3.2b2
 * NS Module Version: Steve_DudenHoeffer's 3.2b2 (dated 20070109)
 *
 * Modules Required: FakeMeta, NS
 *
 * Cvars provided:
 * catattack_version (string): For NSSB etc. Don't change.
 *
 * ChangeLog:
 * Alpha: 10 Feb 2007
 *   - Initial Release
 */

// Set to 0 if you don't run mE's Helper on your server
#define HELPER 1
#define VERSION "Alpha"
#define F4_RATE 2.0

#include <amxmodx>
#include <fakemeta>
#include <fakemeta_stocks>
#include <ns>

#if HELPER == 1
#include <helper>
#endif

#pragma semicolon 1
#pragma ctrlchar '\'//'

new g_combat;
new bool:g_co_catalyst[33];
new bool:g_f4ing[33];
new bool:g_holdingcat[33];
new g_magic_catpack = -1;

new snd_get[] = "items/gunpickup2.wav";

public plugin_init(){
  register_plugin("Catalyst Attack", VERSION, "#endgame");
  register_clcmd("readyroom", "cl_readyroom", ADMIN_ALL, "Ready Room");
  register_cvar("catattack_version", VERSION, FCVAR_SERVER);
  register_forward(FM_CmdStart, "fwd_cmdstart");
  register_forward(FM_Touch, "fwd_touch");
  register_forward(FM_PlayerPreThink, "fwd_prethink");
  g_combat = ns_is_combat();
  if(g_combat){
    register_event("ResetHUD", "evt_resethud", "b");
  }
}

public plugin_precache(){
  precache_sound(snd_get);
}

#if HELPER == 1
public client_advertise(id){
  if(pev(id, pev_team) % 2 == 1) // Marine?
    return PLUGIN_CONTINUE;
  return PLUGIN_HANDLED;
}

public client_help(id){
  help_add("Information", "Marines now hold onto their catalysts until they start attacking.");
  help_add("Usage", "+attack after collecting a catalyst pack will use it automatically.");
  if(g_combat)
    help_add("Combat Usage", "In combat maps, buying catalysts grants an extra catalyst pack per life that is used by pressing +attack.");
  return PLUGIN_CONTINUE;
}
#endif

public client_connect(id){
  g_co_catalyst[id] = false;
  g_holdingcat[id] = false;
  return PLUGIN_CONTINUE;
}

public cl_readyroom(id){
  if(g_f4ing[id])
    g_co_catalyst[id] = g_holdingcat[id] = false;
  else{
    new params[1];
    params[0] = id;
    g_f4ing[id] = true;
    set_task(F4_RATE, "task_abortf4", 0, params, 1);
  }
  return PLUGIN_CONTINUE;
}

public evt_resethud(id){
  g_holdingcat[id] = g_co_catalyst[id];
  return PLUGIN_CONTINUE;
}

public fwd_cmdstart(id, uc, seed){
  switch(get_uc(uc, UC_Impulse)){
  case 5: // Ready Room
    g_co_catalyst[id] = g_holdingcat[id] = false;
  case 27: // Catalyst
    if((unspent_points(id) > 1) &&
       (g_co_catalyst[id] == false) &&
       (pev(id, pev_team) % 2 == 1)) // Marine?
      g_co_catalyst[id] = g_holdingcat[id] = true;
  }
  return FMRES_IGNORED;
}

public fwd_prethink(id){
  if(pev(id, pev_button) & IN_ATTACK){
    if((g_holdingcat[id] == true) &&
       (ns_get_mask(id, MASK_PRIMALSCREAM) == 0) &&
       (ns_get_mask(id, MASK_TOPDOWN) == 0)){
      g_holdingcat[id] = false;
      give_catalyst(id);
    }
  }
  return FMRES_IGNORED;
}

public fwd_touch(touched, toucher){
  new classname[32];
  pev(toucher, pev_classname, classname, 31);
  if(equal(classname, "player")){
    pev(touched, pev_classname, classname, 31);
    if(equal(classname, "item_catalyst")){
      if(touched == g_magic_catpack){
	g_magic_catpack = -1;
	return FMRES_IGNORED;
      }
      if(g_holdingcat[toucher] == false){
	g_holdingcat[toucher] = true;
	EF_RemoveEntity(touched);
	emit_sound(toucher, CHAN_AUTO, snd_get, VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
      }
      return FMRES_SUPERCEDE;
    }
  }
  return FMRES_IGNORED;
}

public task_abortf4(params[], id){
  g_f4ing[params[0]] = false;
}

enum {
  XP_LEVEL_1  =    0,
  XP_LEVEL_2  =  100,
  XP_LEVEL_3  =  250,
  XP_LEVEL_4  =  450,
  XP_LEVEL_5  =  700,
  XP_LEVEL_6  = 1000,
  XP_LEVEL_7  = 1350,
  XP_LEVEL_8  = 1750,
  XP_LEVEL_9  = 2200,
  XP_LEVEL_10 = 2700
};

get_level(id) {
  new xp = floatround(ns_get_exp(id));

  if (xp > XP_LEVEL_10)   return 10;
  if (xp > XP_LEVEL_9)   return 9;
  if (xp > XP_LEVEL_8)   return 8;
  if (xp > XP_LEVEL_7)   return 7;
  if (xp > XP_LEVEL_6)   return 6;
  if (xp > XP_LEVEL_5)   return 5;
  if (xp > XP_LEVEL_4)   return 4;
  if (xp > XP_LEVEL_3)   return 3;
  if (xp > XP_LEVEL_2)   return 2;
  return 1;
}

unspent_points(id){
  return (get_level(id) - ns_get_points(id));
}

give_catalyst(id){
  new ent;
  new Float:origin[3];
  pev(id, pev_origin, origin);
  ent = EF_CreateNamedEntity(EF_AllocString("item_catalyst"));
  set_pev(ent, pev_origin, origin);
  DF_Spawn(ent);
  g_magic_catpack = ent;
  DF_Touch(ent, id);
}
