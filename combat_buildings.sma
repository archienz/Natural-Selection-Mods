/*
 *   Name: combat_buildings
 *   Author: #endgame
 *   Version: Zeta 8
 *   Plugin Type: AMXX Plugin
 *
 *   Allows the construction of buildings in combat
 *   for both teams. (Must be gorge for alien buildings)
 *   (Must have welder for marine buildings)
 *
 *   Commands Provided:
 *   "say_team /buildmenu"
 *   "say /buildmenu"
 *   "say_team buildmenu"
 *   "say buildmenu"
 *   All structures cost 1 level.
 *
 *   Structures Buildable:
 *
 *   Alien:
 *   Defense Chambers
 *   Movement Chambers
 *   Sensory Chambers
 *   Offense Chambers
 *
 *   Marine:
 *   Turret Factory
 *   Sentry Turret
 *   Observatory
 *   Phase Gate
 *   
 *   Thanks To:
 *   Mayhem for providing fixes for cleaning up structures when a player
 *   disconnects or goes to the readyroom and for providing a pseudocode
 *   shell for what became pulse_buildings.
 *
 *   Cheeserm! for extralevels2, which helped me understand menus and handling XP.
 *
 *   Zodiac Mindwarp and the richnet.tv forum regulars for balance help, a server
 *   to test on and constant spam to keep me working.
 *
 *   9 iI IN C IH G IL O C IK of richnet.tv for the extra MvM models.
 *
 *   RazorZero of ModNS.org for the per player building limit code.
 *
 *   The buildings spawn on top of you, but you can walk out and the'll fall.
 *   The buildings don't make any special noises or visual effects
 *   when you create them.
 *   Tested on Windows listen server and richnet.tv using AMXX 1.55
 *
 */

/* Version History
 * Zeta 8 - 03/Mar/2006
 * - Fixed pre-placed buildings from being removed
 *   in maps such as co_volcanodrop_r1.
 *
 * Zeta 7 - 26/Jan/2006
 * - Swapped options 7 and 9 in the build menu, so recycle is back on option 9.
 * - Typo corrected in build menu.
 *
 * Zeta 6 - 23/Jan/2006
 * - Added new recycling behaviour.
 *   o 'Recycle Last' will remove the last building a player placed.
 *   o 'Recycle All' will remove all buildings a player placed.
 * - The new recycle commands have their own shortcut console commands:
 *   'recycle_last' and 'recycle_all'.
 *
 * Zeta 5 - 15/Jan/2006
 * - Fixed a bug where F4 would cause a player to lose all their buildings.
 *
 * Zeta 4 - 21/Dec/2005
 * - Fixed a bug where this plugin would mess with classic mode.
 *
 * Zeta 3 - 12/Dec/2005
 * - Fixed a bug where per-player building limits failed to work.
 *
 * Zeta 2 - 9/Dec/2005
 * - Fixed a bug where the marine player could build structures without a
 *   welder.
 *
 * Zeta 1 - 21/Sep/2005
 * - It is now possible to set structure limits per player, rather than per team.
 *   Thanks to RazorZero of ModNS.org
 *
 * Epsilon 6 - 7/Sep/2005
 * - The "<player> dropped <building>" messages now display correctly.
 *
 * Epsilon 5 - 6/Sep/2005
 * - admin_probe now returns names like "Turret Factory" instead of entity names
 *   like "team_turretfactory"
 * - When limited buildings are on, each person will be informed when a teammate drops
 *   a building, with the number remaining displayed.
 * - Structure limit defaults tweaked.
 *
 * Epsilon 4 - 6/Sep/2005
 * - New #define option - CBUILD_ENFORCE_LIMITS - enables limit checking.
 * - New limits for structures by cvar.
 *
 * Epsilon 3 - 5/Sep/2005
 * - Observatory CVar was missing, now added.
 *
 * Epsilon 2 - 4/Sep/2005
 * - Exports cb_version for the benefit of server browsers.
 * - Almost all config is now with CVars instead of #defines.
 * - Disabled exploit where digesting marines could build. Thakns to RazorZero of ModNS.org
 *
 * Epsilon 1 - 28/Jul/2005
 * - This version is derived from Gamma 5, to hopefully be stable.
 * - MvM Support, Take 2.
 *
 * Delta 3 - 9/Jul/2005
 * - Changed MvM detection method, to hopefully be more stable.
 *
 * Delta 2 - 1/Jul/2005
 * - Precached additional models required for mvm:
 * "models/marinevsmarine/b_turretfactoryblueT.mdl"
 * "models/marinevsmarine/b_turretfactoryredT.mdl"
 * "models/marinevsmarine/b_sentryblueT.mdl"
 * "models/marinevsmarine/b_sentryredT.mdl"
 * "models/marinevsmarine/b_observatoryblueT.mdl"
 * "models/marinevsmarine/b_observatoryredT.mdl"
 *
 * Delta 1 - 1/Jul/2005
 * - mvm is now supported! Additional models courtesy of 9 iI IN C IH G IL O C IK
 * of richnet.tv
 * Additional model files expected are:
 * "models/marinevsmarine/b_turretfactoryblue.mdl"
 * "models/marinevsmarine/b_turretfactoryred.mdl"
 * "models/marinevsmarine/b_sentryblue.mdl"
 * "models/marinevsmarine/b_sentryred.mdl"
 * "models/marinevsmarine/b_observatoryblue.mdl"
 * "models/marinevsmarine/b_observatoryred.mdl"
 * "models/marinevsmarine/b_phasegateblue.mdl"
 * "models/marinevsmarine/b_phasegatered.mdl"
 * - The mvm support only recolours the additional bulidings. All other mvm is
 *   assumed to be handled by another plugin, like White Panther's mvm_allinone.
 * - If the game is mvm, an extra credit message is displayed for 9 iI IN C IH.
 *
 * Gamma 5 - 25/Jun/2005
 * - Moved the welcome message to an ns_popup rather than a client_print(id,
 *   print_chat,...), because so many plugins spam on print_chat on join.
 * - Added admin_probe - see who built the structure.
 * - Renamed CBUILD_ADMIN_RECYCLE_LEVEL to CBUILD_ADMIN_COMMAND_LEVEL to better
 *   reflect its purpose.
 *
 * Gamma 4
 * - Players can now recycle buildings by looking at them, then activating
 *   recycle on the build menu or console command "recycle".
 * - Build menu now has console command "buildmenu" in addition to the
 *   say_team version.
 * - Buildings are now destroyed properly (i.e. Phasegates don't leave that
 *   annoying glow and hum when the person who built them quits).
 * - Admins can recycle any building that this plugin can drop. Console
 *   command is admin_recycle, and its level is configurable by #define.
 * - Marines now need a welder to build things (can be disabled by #define).
 * - Marines can call in scans either by the buildmenu or by console command
 *   "scan". To do this, the marine needs to have bought the scan upgrade,
 *   and the team must have built an observatory.
 * - Scan spam is limited by a timer.
 * - Headroom checking was removed, I can't see why it caused such problems.
 *
 * Gamma 2,3
 * - Lost the exact changelog, all changes in these versions made it into
 *   the Gamma 4 version.
 *
 * Gamma++:
 * - Fixed the "telefrag the cc" bug, along with blocking building in
 *   places with very little headroom.
 *
 * Gamma:
 * - Fixed a bug where having the buildmenu open when you died let you
 *   drop alien buildings onto the person you were spectating.
 *
 * Beta:
 * - Fixed a bug where disabling electrified TFs cause the code to not compile.
 * - Electrified TFs electrify after they finish building.
 *
 * Alpha:
 * - Initial release.
 */

#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <engine>
#include <ns>

#pragma semicolon 1

#define CBUILD_VERSION "Zeta 8"

#define MARINE 1
#define ALIEN 2

#define MENU_KEYS MENU_KEY_1|MENU_KEY_2|MENU_KEY_3|MENU_KEY_4|MENU_KEY_6|MENU_KEY_7|MENU_KEY_8|MENU_KEY_9|MENU_KEY_0

// Compile time options

// Set to 0 to disable
// Set to 1 to enforce per-team structure limits.
// Set to 2 to enforce per-player structure limits.
#define CBUILD_ENFORCE_LIMITS 1

/* Required level to use the admin commands:
 * admin_recycle and admin_probe
 */
#define CBUILD_ADMIN_COMMAND_LEVEL ADMIN_KICK

// How often to allow people to scan
#define CBUILD_SCAN_RATE 10.0

// END OF Compile time options.
// Build limits and the like (anything below this line) is configured with
// a CVAR.

// CVAR related defs
#define CBUILD_VERSION_CVAR "cb_version"

// CVARs for creating buildings: 1 is enable, 0 is disable.
#define CBUILD_DC "cb_dc"
#define CBUILD_MC "cb_mc"
#define CBUILD_SC "cb_sc"
#define CBUILD_OC "cb_oc"

#define CBUILD_TF "cb_tf"
#define CBUILD_ETF "cb_etf" // Electric
#define CBUILD_TURRET "cb_turret"
#define CBUILD_OBS "cb_obs"
#define CBUILD_PG "cb_pg"

// Do marines need welder to build things 1 = yes, 0 = no
#define CBUILD_MARINES_NEED_WELDER "cb_welders"

// How many times the information message will be shown
// The message is shown once per spawn
#define CBUILD_HELPMESSAGECOUNT "cb_help"

// Configure the spacing limits between buildings
#define CBUILD_DC_SPACING "cb_dc_space"
#define CBUILD_MC_SPACING "cb_mc_space"
#define CBUILD_SC_SPACING "cb_sc_space"
#define CBUILD_OC_SPACING "cb_oc_space"
#define CBUILD_TF_SPACING "cb_tf_space"
#define CBUILD_TURRET_SPACING "cb_turret_space"
#define CBUILD_OBS_SPACING "cb_obs_space"
#define CBUILD_PG_SPACING "cb_pg_space"
#define CBUILD_CC_SPACING "cb_cc_space"
#define CBUILD_ARM_SPACING "cb_arm_space"
#define CBUILD_HIVE_SPACING "cb_hive_space"

// Building limit
#if CBUILD_ENFORCE_LIMITS != 0
#define CBUILD_DC_LIMIT "cb_dc_limit"
#define CBUILD_MC_LIMIT "cb_mc_limit"
#define CBUILD_SC_LIMIT "cb_sc_limit"
#define CBUILD_OC_LIMIT "cb_oc_limit"

#define CBUILD_TF_LIMIT "cb_tf_limit"
#define CBUILD_TURRET_LIMIT "cb_turret_limit"
#define CBUILD_OBS_LIMIT "cb_obs_limit"
#define CBUILD_PG_LIMIT "cb_pg_limit"
#endif

// DO NOT CHANGE - Bits for upgrades bought
#define CBUILD_SCAN 1
#define CBUILD_RECENT_SCAN 2
#define CBUILD_WELDER 4

// How fast to press F4 to go to the readyroom
#define CBUILD_F4_TIMER 2.0

new g_structs[33] = 0;
new g_seenHelp[33] = 0;
new g_upgrades[33] = 0; // Bitmask to store bought upgrades
new g_f4ing[33] = 0;
new g_lastBuilding[33] = 0;
new g_maxPlayers;

new g_welcomeMessage[180];
new g_welderMessage[] = "Marines need welders to build.";
new g_builtWelcomeMessage = 0;
new g_mvm = 0;
new g_co = 0;

/* Deprecated as of AMXX 1.50
   public plugin_modules(){
   require_module("ns");
   require_module("engine");
   require_module("fakemeta");
   }
*/

public plugin_init() {
  register_plugin("combat_buildings", CBUILD_VERSION, "#endgame");
  register_cvar(CBUILD_VERSION_CVAR, CBUILD_VERSION, FCVAR_SERVER);
  g_co = ns_is_combat();
  if (g_co) {
    register_cvar(CBUILD_DC, "1", FCVAR_SERVER);
    register_cvar(CBUILD_MC, "1", FCVAR_SERVER);
    register_cvar(CBUILD_SC, "1", FCVAR_SERVER);
    register_cvar(CBUILD_OC, "1", FCVAR_SERVER);
    register_cvar(CBUILD_TF, "1", FCVAR_SERVER);
    register_cvar(CBUILD_ETF, "1", FCVAR_SERVER);
    register_cvar(CBUILD_TURRET, "1", FCVAR_SERVER);
    register_cvar(CBUILD_OBS, "1", FCVAR_SERVER);
    register_cvar(CBUILD_PG, "1", FCVAR_SERVER);
    
    register_cvar(CBUILD_DC_SPACING, "75", FCVAR_SERVER);
    register_cvar(CBUILD_MC_SPACING, "75", FCVAR_SERVER);
    register_cvar(CBUILD_SC_SPACING, "75", FCVAR_SERVER);
    register_cvar(CBUILD_OC_SPACING, "75", FCVAR_SERVER);
    register_cvar(CBUILD_TF_SPACING, "90", FCVAR_SERVER);
    register_cvar(CBUILD_TURRET_SPACING, "75", FCVAR_SERVER);
    register_cvar(CBUILD_OBS_SPACING, "90", FCVAR_SERVER);
    register_cvar(CBUILD_PG_SPACING, "100", FCVAR_SERVER);
    register_cvar(CBUILD_CC_SPACING, "100", FCVAR_SERVER);
    register_cvar(CBUILD_ARM_SPACING, "100", FCVAR_SERVER);
    register_cvar(CBUILD_HIVE_SPACING, "100", FCVAR_SERVER);
    
#if CBUILD_ENFORCE_LIMITS != 0
    register_cvar(CBUILD_DC_LIMIT, "2", FCVAR_SERVER);
    register_cvar(CBUILD_MC_LIMIT, "2", FCVAR_SERVER);
    register_cvar(CBUILD_SC_LIMIT, "2", FCVAR_SERVER);
    register_cvar(CBUILD_OC_LIMIT, "2", FCVAR_SERVER);
    register_cvar(CBUILD_TF_LIMIT, "1", FCVAR_SERVER);
    register_cvar(CBUILD_TURRET_LIMIT, "4", FCVAR_SERVER);
    register_cvar(CBUILD_OBS_LIMIT, "6", FCVAR_SERVER);
    register_cvar(CBUILD_PG_LIMIT, "3", FCVAR_SERVER);
#endif

    register_cvar(CBUILD_MARINES_NEED_WELDER, "1", FCVAR_SERVER);
    register_cvar(CBUILD_HELPMESSAGECOUNT, "2", FCVAR_SERVER);
        
    new cc = -1;
    new count;
    while((cc = find_ent_by_class(cc,"team_command")) > 0)
      count++;
    if(count > 1){
      g_mvm = 1;
      cbuild_precache_mvm();
    }
    register_clcmd("say_team /buildmenu", "buildMenu", ADMIN_ALL, "Building Menu");
    register_clcmd("say /buildmenu", "buildMenu", ADMIN_ALL, "Building Menu");
    register_clcmd("say_team buildmenu", "buildMenu", ADMIN_ALL, "Building Menu");
    register_clcmd("say buildmenu", "buildMenu", ADMIN_ALL, "Building Menu");
    register_clcmd("buildmenu", "buildMenu", ADMIN_ALL, "Building Menu");
    register_clcmd("recycle", "recycle", ADMIN_ALL, "Recycle");
    register_clcmd("recycle_last", "recycleLast", ADMIN_ALL, "Recycle Last");
    register_clcmd("recycle_all", "removeOwnedStructs", ADMIN_ALL, "Recycle All");
    register_clcmd("readyroom", "f4", ADMIN_ALL, "Ready Room");
    register_clcmd("scan", "callScan", ADMIN_ALL, "Call in a scan");
    register_concmd("admin_recycle", "adminRecycle", CBUILD_ADMIN_COMMAND_LEVEL, "Admin Recycle");
    register_concmd("admin_probe", "adminProbe", CBUILD_ADMIN_COMMAND_LEVEL, "Admin Building Probe");
    register_event("Countdown", "setup_tasks", "a");
    register_event("ResetHUD", "playerSpawned", "b");
    register_impulse(5, "cleanup");
    register_impulse(53, "buyScan");
    register_impulse(62, "buyWelder");
    register_menucmd(register_menuid("Build what?"), MENU_KEYS, "processBuilding");
    
    for(new i = 0 ; i < 33 ; i++){
      g_structs[i] = 0;
      g_seenHelp[i] = 0;
      g_upgrades[i] = 0;
    }
  }
}

public f4(id){
  if(g_f4ing[id])
    cleanup(id);
  else{
    new params[1];
    params[0] = id;
    g_f4ing[id] = 1;
    set_task(CBUILD_F4_TIMER, "abortf4", 0, params, 1);
  }
}

public abortf4(params[], id){
  new player = params[0];
  g_f4ing[player] = 0;
}

/* Thanks to mvm_allinone (i.e. White Panther)
 * doing the precache with fakemeta is his thing.
 */
public cbuild_precache_mvm(){
  engfunc(EngFunc_PrecacheModel, "models/marinevsmarine/b_turretfactoryblue.mdl");
  engfunc(EngFunc_PrecacheModel, "models/marinevsmarine/b_turretfactoryblueT.mdl");
  engfunc(EngFunc_PrecacheModel, "models/marinevsmarine/b_turretfactoryred.mdl");
  engfunc(EngFunc_PrecacheModel, "models/marinevsmarine/b_turretfactoryredT.mdl");
  engfunc(EngFunc_PrecacheModel, "models/marinevsmarine/b_sentryblue.mdl");
  engfunc(EngFunc_PrecacheModel, "models/marinevsmarine/b_sentryblueT.mdl");
  engfunc(EngFunc_PrecacheModel, "models/marinevsmarine/b_sentryred.mdl");
  engfunc(EngFunc_PrecacheModel, "models/marinevsmarine/b_sentryredT.mdl");
  engfunc(EngFunc_PrecacheModel, "models/marinevsmarine/b_observatoryblue.mdl");
  engfunc(EngFunc_PrecacheModel, "models/marinevsmarine/b_observatoryblueT.mdl");
  engfunc(EngFunc_PrecacheModel, "models/marinevsmarine/b_observatoryred.mdl");
  engfunc(EngFunc_PrecacheModel, "models/marinevsmarine/b_observatoryredT.mdl");
  engfunc(EngFunc_PrecacheModel, "models/marinevsmarine/b_phasegateblue.mdl");
  engfunc(EngFunc_PrecacheModel, "models/marinevsmarine/b_phasegatered.mdl");
  return PLUGIN_CONTINUE;
}

/* Again, code borrowed from WP's mvm_allinone */
morph_model(bid,blue_model[],red_model[]){
  new Float:MinBox[3];
  new Float:MaxBox[3];
  new Float:orig[3];
  entity_get_vector(bid, EV_VEC_origin, orig);
  entity_get_vector(bid, EV_VEC_mins, MinBox);
  entity_get_vector(bid, EV_VEC_maxs, MaxBox);
  if( entity_get_int(bid, EV_INT_team) == 1 )
    entity_set_model(bid,blue_model);
  else
    entity_set_model(bid,red_model);
  entity_set_vector(bid, EV_VEC_mins, MinBox);
  entity_set_vector(bid, EV_VEC_maxs, MaxBox);
  entity_set_origin(bid, orig);
  entity_set_int(bid,EV_INT_solid,2);
}

public aps(classname[]){
  new i;
  new count = 0;
  new temp;
  count = ns_get_build(classname);
  for(i = 1 ; i <= count ; i++){
    temp = ns_get_build(classname, 0, i);
    if(ns_get_struct_owner(temp) == -1)
      ns_set_struct_owner(temp, 0);
  }
}

public adjust_preplaced_structs(){
  aps("team_turretfactory");
  aps("turret");
  aps("team_observatory");
  aps("phasegate");
  
  aps("defensechamber");
  aps("movementchamber");
  aps("sensorychamber");
  aps("offensechamber");
}

public setup_tasks(){
  adjust_preplaced_structs();
  set_task(1.0, "pulse_buildings", 0, "", 0, "b");
  set_task(CBUILD_SCAN_RATE, "pulse_scans", 0, "", 0, "b");
  g_maxPlayers = get_maxplayers();
}

public plugin_precache() {
  precache_generic("models/ba_defense.mdl");
  precache_generic("models/ba_defenset.mdl");

  precache_generic("models/ba_movement.mdl");
  precache_generic("models/ba_movementt.mdl");

  precache_generic("models/ba_sensory.mdl");
  precache_generic("models/ba_sensoryt.mdl");

  precache_generic("models/ba_offense.mdl");
  precache_generic("models/ba_offenset.mdl");

  precache_generic("models/b_turretfactory.mdl");
  precache_generic("models/b_turretfactoryt.mdl");

  precache_generic("models/b_sentry.mdl");
  precache_generic("models/b_sentryt.mdl");

  precache_generic("models/b_observatory.mdl");
  precache_generic("models/b_observatoryt.mdl");

  precache_generic("models/b_phasegate.mdl");
}

enum {
  XP_LEVEL_1   =     0,
  XP_LEVEL_2   =   100,
  XP_LEVEL_3   =   250,
  XP_LEVEL_4   =   450,
  XP_LEVEL_5   =   700,
  XP_LEVEL_6   =  1000,
  XP_LEVEL_7   =  1350,
  XP_LEVEL_8   =  1750,
  XP_LEVEL_9   =  2200,
  XP_LEVEL_10  =  2700
};

get_xp(index){
  return floatround(ns_get_exp(index));
}
 
get_level(id) {
  new xp = get_xp(id);

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

// Get the team for a player
get_team(id){
  new class = ns_get_class(id);
  if((class == CLASS_MARINE) || (class == CLASS_JETPACK) || (class == CLASS_HEAVY))
    return MARINE;
  return ALIEN;
}

// Destroy a building
destroy_building(bldg){
  fakedamage(bldg, "worldspawn", 10000.0, 1);
}

// Test for enough points
enough_points(id){
  return ((get_level(id) - ns_get_points(id)) > 1);
}

// a do_nothing style function
null(){
  return;
}

// Building distance check
// Given a player id, check all buildings of a classname
// if any are within dist, return 0
// else return 1
bdc(id, class[], Float:dist){
  new i;
  new tempEnt;
  new entCount = 0;
  entCount = ns_get_build(class, 0);
  for(i = 1 ; i <= entCount ; i++){
    tempEnt = ns_get_build(class, 0, i);
    if(get_entity_distance(id, tempEnt) < dist)
      return 0;
  }
  return 1;
}

// Main building spacing function
// Call bdc a lot, return 0 if any of them do
// else return 1 (i.e. 1 means OK to build)
building_distance_check(id){
  // Alien Buildable
  new dcOK = bdc(id, "defensechamber", get_cvar_float(CBUILD_DC_SPACING));
  if(dcOK == 0) return 0;
  new mcOK = bdc(id, "movementchamber", get_cvar_float(CBUILD_MC_SPACING));
  if(mcOK == 0) return 0;
  new scOK = bdc(id, "sensorychamber", get_cvar_float(CBUILD_SC_SPACING));
  if(scOK == 0) return 0;
  new ocOK = bdc(id, "offensechamber", get_cvar_float(CBUILD_OC_SPACING));
  if(ocOK == 0) return 0;
  // Marine Buildable
  new tfOK = bdc(id, "team_turretfactory", get_cvar_float(CBUILD_TF_SPACING));
  if(tfOK == 0) return 0;
  new stOK = bdc(id, "turret", get_cvar_float(CBUILD_TURRET_SPACING));
  if(stOK == 0) return 0;
  new obsOK = bdc(id, "team_observatory", get_cvar_float(CBUILD_OBS_SPACING));
  if(obsOK == 0) return 0;
  new pgOK = bdc(id, "phasegate", get_cvar_float(CBUILD_PG_SPACING));
  if(pgOK == 0) return 0;
  // Pre Placed
  new ccOK = bdc(id, "team_command", get_cvar_float(CBUILD_CC_SPACING));
  if(ccOK == 0) return 0;
  new armOK = bdc(id, "team_armory", get_cvar_float(CBUILD_ARM_SPACING));
  if(armOK == 0) return 0;
  new hiveOK = bdc(id, "team_hive", get_cvar_float(CBUILD_HIVE_SPACING));
  if(hiveOK == 0) return 0;
  return 1;
}

// Test if near a TF
near_a_tf(id){
  new i;
  new tempTF;
  new TFTeam;
  new team = pev(id, pev_team);
  new TFCount = 0;
  TFCount = ns_get_build("team_turretfactory");
  for(i = 1 ; i <= TFCount ; i++){
    tempTF = ns_get_build("team_turretfactory", 1, i);
    TFTeam = pev(tempTF, pev_team);
    if(TFTeam == team)
      if(get_entity_distance(id, tempTF) < 300)
	return 1;
  }
  return 0;
}

// Test if a team has a functioning observatory
team_has_obs(id){
  new i;
  new tempObs;
  new ObsTeam;
  new team = pev(id, pev_team);
  new ObsCount = 0;
  ObsCount = ns_get_build("team_observatory");
  for(i = 1 ; i <= ObsCount ; i++){
    tempObs = ns_get_build("team_observatory", 1, i);
    ObsTeam = pev(tempObs, pev_team);
    if(ObsTeam == team)
      return 1;
  }
  return 0;
}


// Test if a player is alive
is_dead(id){
  if(pev(id, pev_deadflag) > 0)
    return 1;
  return 0;
}

// Get a real name from the building entity name.
get_building_name(classname[], buildingname[], len){
  if(equal(classname, "defensechamber"))
    copy(buildingname, len, "Defense Chamber");
  else if(equal(classname, "movementchamber"))
    copy(buildingname, len, "Movement Chamber");
  else if(equal(classname, "sensorychamber"))
    copy(buildingname, len, "Sensory Chamber");
  else if(equal(classname, "offensechamber"))
    copy(buildingname, len, "Offense Chamber");
  else if(equal(classname, "team_turretfactory"))
    copy(buildingname, len, "Turret Factory");
  else if(equal(classname, "turret"))
    copy(buildingname, len, "Sentry Turret");
  else if(equal(classname, "team_observatory"))
    copy(buildingname, len, "Observatory");
  else if(equal(classname, "phasegate"))
    copy(buildingname, len, "Phase Gate");
  else null(); // WTF? Should never get here.
}

#if CBUILD_ENFORCE_LIMITS != 0
// Get the appropriate building limit cvar
// from the classname. Len is the maximum number of
// chars to copy into cvarname (overrun protection)
get_limit_cvar(classname[], cvarname[], len){
  if(equal(classname, "defensechamber"))
    copy(cvarname, len, CBUILD_DC_LIMIT);
  else if(equal(classname, "movementchamber"))
    copy(cvarname, len, CBUILD_MC_LIMIT);
  else if(equal(classname, "sensorychamber"))
    copy(cvarname, len, CBUILD_SC_LIMIT);
  else if(equal(classname, "offensechamber"))
    copy(cvarname, len, CBUILD_OC_LIMIT);
  else if(equal(classname, "team_turretfactory"))
    copy(cvarname, len, CBUILD_TF_LIMIT);
  else if(equal(classname, "turret"))
    copy(cvarname, len, CBUILD_TURRET_LIMIT);
  else if(equal(classname, "team_observatory"))
    copy(cvarname, len, CBUILD_OBS_LIMIT);
  else if(equal(classname, "phasegate"))
    copy(cvarname, len, CBUILD_PG_LIMIT);
  else null(); // WTF? Should never get here.
}
#endif

#if CBUILD_ENFORCE_LIMITS == 1
// Count structures built by a team
// Return the number of buildings left if we're allowed to build else 0
building_limit_ok(player, classname[]){
  new team = pev(player, pev_team);
  new count = ns_get_build(classname, 0, 0);
  new buildingCount = 0;
  new tempEnt;
  new cvar[64];
  new limit;
  for(new i = 1 ; i <= count ; i++){
    tempEnt = ns_get_build(classname, 0, i);
    if(pev(tempEnt, pev_team) == team)
      buildingCount++;
  }
  get_limit_cvar(classname, cvar, 63);
  limit = get_cvar_num(cvar);
  if(limit > buildingCount)
    return (limit - buildingCount);
  return 0;
}

// Send out a message to everyone on the same team as id
send_to_team(id, msg[]){
  new team = pev(id, pev_team);
  
  for(new i = 1 ; i <= g_maxPlayers ; i++){
    if(!is_user_connected(i)) continue;
    else
      if(pev(i, pev_team) == team)
	client_print(i, print_chat, msg);
  }
}
#endif

#if CBUILD_ENFORCE_LIMITS == 2
// Count structures built by a player
// Return amount of structures left if we're allowed to build else 0
building_limit_ok(player, classname[]){
  new count = ns_get_build(classname, 0, 0);
  new buildingCount = 0;
  new tempEnt;
  new cvar[64];
  new limit;
  for(new i = 1; i <= count; i++){
    tempEnt = ns_get_build(classname, 0, i);
    if(ns_get_struct_owner(tempEnt) == player)
      buildingCount++;
  }
  get_limit_cvar(classname, cvar, 63);
  limit = get_cvar_num(cvar);
  if(limit > buildingCount)
    return (limit - buildingCount);
  return 0;
}
#endif

// Check all the building conditions,
// and actually create the building.
public make_building(id, name[]){
  if(is_dead(id) == 1)
    client_print(id, print_chat, "[Combat_Buildings] You can't build while dead. Sorry.");
  else{
    if(enough_points(id)){
      if(building_distance_check(id)){
	if((get_team(id) == ALIEN) && (ns_get_class(id) != CLASS_GORGE)){
	  client_print(id, print_chat, "[Combat_Buildings] You must be a gorge to build things. Sorry.");
	  return;
	}
	if(get_cvar_num(CBUILD_MARINES_NEED_WELDER) == 1)
	  if((get_team(id) == MARINE) && (!((g_upgrades[id] & CBUILD_WELDER) == CBUILD_WELDER))){
	    client_print(id, print_chat, "[Combat_Buildings] You need a welder to build things. Sorry.");
	    return;
	  }
	// Can't build while being digested. Thanks to RazorZero at ModNS.org
	// This assumes that only gorges can build, and gorges can never get devour.
	// (meaning no changes will be required if/when AvA becomes a reality)
	// (some random server plugins can make this possible)
	if(ns_get_mask(id, MASK_DIGESTING)){
	  client_print(id, print_chat, "[Combat_Buildings] You can't build while being digested. Sorry.");
	  return;
	}
	// Server limits
#if CBUILD_ENFORCE_LIMITS != 0
	new buildingsLeft = building_limit_ok(id, name);
	new message[151];
	new player[51];
	new building[51];
	if(buildingsLeft == 0){
	  client_print(id, print_chat, "[Combat_Buildings] Cannot build due to administrator-set limit. Sorry.");
	  return;
	}else{
	  get_user_name(id, player, 50);
	  get_building_name(name, building, 50);
	  format(message, 150, "[Combat_Buildings] %s dropped %s. %d left.", player, building, buildingsLeft - 1);
#if CBUILD_ENFORCE_LIMITS == 1
	  send_to_team(id, message);
#endif
#if CBUILD_ENFORCE_LIMITS == 2
	  client_print(id, print_chat, message);
#endif
	}
#endif
	new team = pev(id, pev_team);
	ns_set_points(id, ns_get_points(id) + 1);
	new ent = create_entity(name);
	new Float:origin[3];
	entity_get_vector(id, EV_VEC_origin,origin);
	entity_set_origin(ent,origin);
	DispatchSpawn(ent);
	set_pev(ent,pev_fuser1,0);
	set_pev(ent,pev_fuser2,500);
	set_pev(ent,pev_team,team); // Use pev(id, pev_team) to get the team and not get_team(id) so MvM works.
	ns_set_struct_owner(ent, id);
	g_lastBuilding[id] = ent;
	g_structs[id]++;
	if(g_mvm == 1){ // Recolour
	  if(equal(name,"team_turretfactory")) morph_model(ent, "models/marinevsmarine/b_turretfactoryblue.mdl", "models/marinevsmarine/b_turretfactoryred.mdl");
	  else if(equal(name,"turret")) morph_model(ent, "models/marinevsmarine/b_sentryblue.mdl", "models/marinevsmarine/b_sentryred.mdl");
	  else if(equal(name,"team_observatory")) morph_model(ent, "models/marinevsmarine/b_observatoryblue.mdl", "models/marinevsmarine/b_observatoryred.mdl");
	  else if(equal(name,"phasegate")) morph_model(ent, "models/marinevsmarine/b_phasegateblue.mdl", "models/marinevsmarine/b_phasegatered.mdl");
	  else null();
	}
      }else
	client_print(id, print_chat, "[Combat_Buildings] Can't build so close to existing structures. Sorry.");
    }else
      client_print(id, print_chat, "[Combat_Buildings] You need a point to spend on the structure. Build aborted. Sorry.");
  }
}

// Recycle (i.e. destroy) a building
public recycle(id){
  new target;
  new dummy;
  get_user_aiming(id, target, dummy);
  if(is_valid_ent(target))
    if(ns_get_struct_owner(target) == id)
      destroy_building(target);
    else
      client_print(id, print_chat, "[Combat_Buildings] You can only recycle your own buildings.");
  else
    client_print(id, print_chat, "[Combat_Buildings] Look at a building to recycle, then activate the recycle option.");
  return PLUGIN_HANDLED;
}

public is_combat_building(entName[]){
  return (equal(entName, "team_turretfactory")||
	  equal(entName, "turret")||
	  equal(entName, "team_observatory")||
	  equal(entName, "phasegate")||
	  equal(entName, "defensechamber")||
	  equal(entName, "movementchamber")||
	  equal(entName, "sensorychamber")||
	  equal(entName, "offensechamber"));
}

// Admin Recycle
public adminRecycle(id, level, cid){
  new target;
  new dummy;
  new entName[51];
  if(cmd_access(id, level, cid, 1)){
    get_user_aiming(id, target, dummy);
    if(is_valid_ent(target)){
      entity_get_string(target, EV_SZ_classname, entName, 50);
      // We don't want them recycling, say, other players
      if(is_combat_building(entName))
	destroy_building(target);
      else
	client_print(id, print_chat, "[Combat_Buildings] You can only recycle deployable buildings.");
    }else
      client_print(id, print_chat, "[Combat_Buildings] Look at a building to recycle, then activate the admin recycle option.");
  }else
    client_print(id, print_chat, "[Combat_Buildings] Don't try to admin-recycle unless you have access.");
  return PLUGIN_HANDLED;
}

public adminProbe(id, level, cid){
  new target;
  new dummy;
  new entName[51];
  new builderID;
  new builder[51];
  new buildingName[51];
  new probe[150];
  if(cmd_access(id, level, cid, 1)){
    get_user_aiming(id, target, dummy);
    if(is_valid_ent(target)){
      entity_get_string(target, EV_SZ_classname, entName, 50);
      if(is_combat_building(entName)){ // Can only probe the bulidables.
	builderID = ns_get_struct_owner(target);
	get_user_name(builderID, builder, 50);
	get_building_name(entName, buildingName, 50);
	format(probe, 149, "Probe Result: Building: %s Builder: %s", buildingName, builder);
	client_print(id, print_chat, probe);
      }
    }
  }
  return PLUGIN_HANDLED;
}

public callScan(id){
  if(get_team(id) != MARINE)
    return PLUGIN_HANDLED;
  if(team_has_obs(id))
    if((g_upgrades[id] & CBUILD_SCAN) == CBUILD_SCAN)
      if(!((g_upgrades[id] & CBUILD_RECENT_SCAN) == CBUILD_RECENT_SCAN)){
	new Float:origin[3];
	entity_get_vector(id, EV_VEC_origin,origin);
	origin[2] -= 20;
	new ent = create_entity("scan");
	entity_set_origin(ent,origin);
	set_pev(ent, pev_team, pev(id, pev_team));
	DispatchSpawn(ent);
	g_upgrades[id] = g_upgrades[id] | CBUILD_RECENT_SCAN;
	return PLUGIN_HANDLED;
      }else
	client_print(id, print_chat, "[Combat_Buildings] Cannot call in scans so frequently.");
    else
      client_print(id, print_chat, "[Combat_Buildings] Cannot call in scans without purchasing the upgrade.");
  else
    client_print(id, print_chat, "[Combat_Buildings] Cannot call in scans without a functioning observatory.");
  return PLUGIN_HANDLED;
}

// Remove all structs of class name owned by id
public removeStructsOfTypeOwnedBy(id, name[]){
  new count = ns_get_build(name, 0, 0);
  new i;
  new tempEnt;
  for(i = 1 ; i <= count ; i++){
    tempEnt = ns_get_build(name, 0, i);
    if(ns_get_struct_owner(tempEnt) == id)
      destroy_building(tempEnt);
  }
}

// Remove all structures owned by a player id
public removeOwnedStructs(id){
  removeStructsOfTypeOwnedBy(id, "defensechamber");
  removeStructsOfTypeOwnedBy(id, "movementchamber");
  removeStructsOfTypeOwnedBy(id, "sensorychamber");
  removeStructsOfTypeOwnedBy(id, "offensechamber");
  removeStructsOfTypeOwnedBy(id, "team_turretfactory");
  removeStructsOfTypeOwnedBy(id, "turret");
  removeStructsOfTypeOwnedBy(id, "team_observatory");
  removeStructsOfTypeOwnedBy(id, "phasegate");
  g_lastBuilding[id] = 0;
  return PLUGIN_HANDLED;
}

public cleanup(id){
  g_structs[id] = 0;
  g_upgrades[id] = 0;
  g_f4ing[id] = 0;
  g_lastBuilding[id] = 0;
  removeOwnedStructs(id);
  return PLUGIN_CONTINUE;
}

// Remove all structures not owned by a player
public removeOrphanStructs(){
  removeStructsOfTypeOwnedBy(-1, "defensechamber");
  removeStructsOfTypeOwnedBy(-1, "movementchamber");
  removeStructsOfTypeOwnedBy(-1, "sensorychamber");
  removeStructsOfTypeOwnedBy(-1, "offensechamber");
  removeStructsOfTypeOwnedBy(-1, "team_turretfactory");
  removeStructsOfTypeOwnedBy(-1, "turret");
  removeStructsOfTypeOwnedBy(-1, "team_observatory");
  removeStructsOfTypeOwnedBy(-1, "phasegate");
}

// Count all structures owned by if with name name
public countStructsOfTypeOwnedBy(id, name[]){
  new count = ns_get_build(name, 0, 0);
  new i;
  new tempEnt;
  new personalCount = 0;
  for(i = 1 ; i <= count ; i++){
    tempEnt = ns_get_build(name, 0, i);
    if(ns_get_struct_owner(tempEnt) == id)
      personalCount++;
  }
  return personalCount;
}

// Clean up a mess after a DC
public client_disconnect(id){
  if(g_co){
    g_seenHelp[id] = 0;
    cleanup(id);
  }
}

// Count all stuctures owned by a player ID
public countOwnedStructs(id){
  return countStructsOfTypeOwnedBy(id, "defensechamber") +
    countStructsOfTypeOwnedBy(id, "movementchamber") +
    countStructsOfTypeOwnedBy(id, "sensorychamber") +
    countStructsOfTypeOwnedBy(id, "offensechamber") +
    countStructsOfTypeOwnedBy(id, "team_turretfactory") +
    countStructsOfTypeOwnedBy(id, "turret") +
    countStructsOfTypeOwnedBy(id, "team_observatory") +
    countStructsOfTypeOwnedBy(id, "phasegate");
}

public removeBuildingsNearCC(){
  new tempPG;
  new PGCount = 0;
  new tempCC;
  new CCCount = 0;
  new tempTF;
  new TFCount = 0;
  new i;
  new j;
  CCCount = ns_get_build("team_command", 0);
  PGCount = ns_get_build("phasegate", 0);
  TFCount = ns_get_build("team_turretfactory", 0);
  for(i = 1 ; i <= CCCount ; i++){
    tempCC = ns_get_build("team_command", 0, i);
    for(j = 1 ; j <= PGCount ; j++){
      tempPG = ns_get_build("phasegate", 0, j);
      if(get_entity_distance(tempPG, tempCC) <= get_cvar_float(CBUILD_CC_SPACING))
	destroy_building(tempPG);
    }
    for(j = 1 ; j <= TFCount ; j++){
      tempTF = ns_get_build("team_turretfactory", 0, j);
      if(get_entity_distance(tempTF, tempCC) <= get_cvar_float(CBUILD_CC_SPACING))
	destroy_building(tempTF);
    }
  }
}

public buyScan(id){
  if((get_team(id) == MARINE) && (enough_points(id)))
    g_upgrades[id] = g_upgrades[id] | CBUILD_SCAN;
  return PLUGIN_CONTINUE;
}

public buyWelder(id){
  if((get_team(id) == MARINE) && (enough_points(id)))
    g_upgrades[id] = g_upgrades[id] | CBUILD_WELDER;
  return PLUGIN_CONTINUE;
}

// General maintanance: Remove any orphaned structures
// to prevent exploits, electrify any recently completed
// TFs, refund any points from buildings that have been
// destroyed/recycled, and kill any PGs/TFs near the CC.
public pulse_buildings(id){
  new count = 0;
  new i;

  removeOrphanStructs();
  removeBuildingsNearCC();

  // Electric TF
  if(get_cvar_num(CBUILD_ETF) == 1){
    new j;
    new tempTF;
    new TFCount = ns_get_build("team_turretfactory");
    for(j = 1 ; j <= TFCount ; j++){
      tempTF = ns_get_build("team_turretfactory", 1, j);
      set_pev(tempTF, pev_iuser4, pev(tempTF, pev_iuser4)|MASK_ELECTRICITY);
    }
  }

  for(i = 1 ; i <= g_maxPlayers ; i++){
    if(!is_user_connected(i)) continue;
    count = countOwnedStructs(i);

    if(count < g_structs[i]){
      ns_set_points(i, ns_get_points(i) - g_structs[i] + count);
      g_structs[i] = count;
    }
  }
  return PLUGIN_CONTINUE;
}

public pulse_scans(id){
  new i;
  for(i = 1 ; i <= g_maxPlayers ; i++)
    g_upgrades[i] = g_upgrades[i] & ~CBUILD_RECENT_SCAN;
}

// Once a player spawns, show them help
// if they haven't seen it enough
public playerSpawned(id){
  if(g_seenHelp[id] < get_cvar_num(CBUILD_HELPMESSAGECOUNT)){
    g_seenHelp[id]++;
    if(g_builtWelcomeMessage == 0){
      format(g_welcomeMessage, 179, "Server is running Combat_Buildings by #endgame (Version: %s). Say /buildmenu to get the build menu. Aliens must be gorge to build. %s", CBUILD_VERSION, (get_cvar_num(CBUILD_MARINES_NEED_WELDER) == 1 ? g_welderMessage : ""));
      g_builtWelcomeMessage = 1;
    }
    ns_popup(id, g_welcomeMessage);
    if(g_mvm == 1)
      client_print(id, print_chat, "[Combat_Buildings] Additional MvM models by 9 iI IN C IH G IL O C IK of richnet.tv");
#if CBUILD_ENFORCE_LIMITS == 1
    client_print(id, print_chat, "[Combat_Buildings] Per-Team building limits imposed.");
#endif
#if CBUILD_ENFORCE_LIMITS == 2
    client_print(id, print_chat, "[Combat_Buildings] Per-Player builing limits imposed. Code by RazorZero of ModNS.org");
#endif
  }
}

// Show the building menu.
// All validity tests are done in make_building (Alien gorge etc.)
public buildMenu(id){
  new menuText[192];
  if(get_team(id) == MARINE){
    format(menuText, 191, "Build what?^n1. Turret Factory^n2. Sentry Turret^n3. Observatory^n4. Phase Gate^n^n6. Call in a scan^n7. Recycle All^n8. Recycle Last^n9. Recycle^n0. Abort");
    show_menu(id, MENU_KEYS, menuText);
  }else{
    format(menuText, 191, "Build what?^n1. Defense Chamber^n2. Movement Chamber^n3. Sensory Chamber^n4. Offense Chamber^n^n7. Recycle All^n8. Recycle Last^n9. Recycle^n0. Abort");
    show_menu(id, MENU_KEYS, menuText);
  }
  return PLUGIN_HANDLED;
}

// Check that they're not dead.
// If not, check their team and call the appropriate make_building call.
public processBuilding(id, key){
  if(get_team(id) == MARINE)
    switch(key){
    case 0: // TF
      if(get_cvar_num(CBUILD_TF) == 1)
        make_building(id, "team_turretfactory");
      else
        client_print(id, print_chat, "[Combat_Buildings] Turret Factories have been disabled by the administrator. Sorry.");
    case 1: // Sentry Turret
      if(near_a_tf(id) == 1){
        if(get_cvar_num(CBUILD_TURRET) == 1)
	  make_building(id, "turret");
        else
	  client_print(id, print_chat, "[Combat_Buildings] Sentry Guns have been disabled by the administrator. Sorry.");
      }else
	client_print(id, print_chat, "[Combat_Buildings] You need to be near a TF to build turrets. Sorry.");
    case 2: // Observatory
      if(get_cvar_num(CBUILD_OBS) == 1)
        make_building(id, "team_observatory");
      else
        client_print(id, print_chat, "[Combat_Buildings] Observatories have been disabled by the administrator. Sorry.");
    case 3: // PG
      if(get_cvar_num(CBUILD_PG) == 1)
        make_building(id, "phasegate");
      else
        client_print(id, print_chat, "[Combat_Buildings] Phase Gates have been disabled by the administrator. Sorry.");
    case 5: // Call in scan
      callScan(id);
    case 6: // Recycle All
      removeOwnedStructs(id);
    case 7: // Recycle Last
      recycleLast(id);
    case 8: // Recycle
      recycle(id);
    case 9: // Cancel
      client_print(id, print_chat, "[Combat_Buildings] Build aborted.");
    }
  else
    switch(key){
    case 0: // DC
      if(get_cvar_num(CBUILD_DC) == 1)
        make_building(id, "defensechamber");
      else
        client_print(id, print_chat, "[Combat_Buildings] Defense Chambers have been disabled by the administrator. Sorry.");
    case 1: // MC
      if(get_cvar_num(CBUILD_MC) == 1)
        make_building(id, "movementchamber");
      else
        client_print(id, print_chat, "[Combat_Buildings] Movement Chambers have been disabled by the administrator. Sorry.");
    case 2: // SC
      if(get_cvar_num(CBUILD_SC) == 1)
        make_building(id, "sensorychamber");
      else
        client_print(id, print_chat, "[Combat_Buildings] Sensory Chambers have been disabled by the administrator. Sorry.");
    case 3: // OC
      if(get_cvar_num(CBUILD_OC) == 1)
        make_building(id, "offensechamber");
      else
        client_print(id, print_chat, "[Combat_Buildings] Offense Chambers have been disabled by the administrator. Sorry.");
    case 5: // Scans
      null();
    case 6: // Recycle All
      removeOwnedStructs(id);
    case 7: // Recycle Last
      recycleLast(id);
    case 8: // Recycle
      recycle(id);
    case 9: // Cancel
      client_print(id, print_chat, "[Combat_Buildings] Build aborted.");
    }
}

// Delete the last building a player dropped
public recycleLast(id){
  new building = g_lastBuilding[id];
  if(building == 0){
    client_print(id, print_chat, "[Combat_Buildings] You have no buildings, or you've recycled your latest already.");
    return PLUGIN_HANDLED;
  }

  if(!is_valid_ent(building)){
    client_print(id, print_chat, "[Combat_buildings] Can't find your latest building.");
    return PLUGIN_HANDLED;
  }

  if(ns_get_struct_owner(building) == id)
    destroy_building(building);
  g_lastBuilding[id] = 0;
  return PLUGIN_HANDLED;
}
