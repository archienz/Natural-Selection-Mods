/* c_limit.SMA - 1.1.0
 * -
 * Adds restictions to how much of
 * some things can be built.
 *
 * Auth: Carling.
 *
 * Ported to AMX ModX by Depot; Limits on Phasegates, Observatories,
 * Prototype Labs, and Armslabs added. 11/08/04
 *
 * Updated 10/13/05 v1.1.0: White Panther added check for cc recycling.
 */

#include <amxmodx>
#include <ns>
#include <engine>
#include <fakemeta>

#define DC_LIMIT 50	// chambers per map (8 per group).
#define MC_LIMIT 50	// chambers per map (8 per group).
#define SC_LIMIT 50	// chambers per map (8 per group).
#define OC_LIMIT 25	// chambers per map (8 per group).
#define TF_LIMIT 10	// Number of Turret Factories per map.
#define T_LIMIT 6	// Number of Turrets per TF.
#define CC_LIMIT 2	// Number of CC's permited.
#define uCC_LIMIT 1	// Number of UNBUILT CC's permited.
#define PG_LIMIT 6	// Number of Phase Gates per map.
#define OB_LIMIT 8	// Number of Observatories per map.
#define uOB_LIMIT 2	// Number of UNBUILT Observatories permited.
#define PL_LIMIT 2	// Number of Prototype Labs per map.
#define uPL_LIMIT 2	// Number of UNBUILT Prototype Labs permited.
#define AL_LIMIT 2	// Number of Armslabs per map.
#define uAL_LIMIT 2	// Number of UNBUILT Armslabs permited.
#define ST_LIMIT 2     	// Number of Siege turrets PER advTF
#define IP_LIMIT 6	// Number of Infantry Portals.
#define M_LIMIT 100	// Number of Mines.
#define MED_LIMIT 20	// Number of Medi Packs
#define AMO_LIMIT 20	// Number of Ammo Packs
#define AR_LIMIT 8	// Number of Armories.
#define uAR_LIMIT 2	// Number of UNBUILT Armorys permited
#define T_MODE 0        // Ignore. unfinshed
#define MARINE 1	// Teams (do not change)
#define ALIEN 2		// Teams (do not change)

public plugin_init() {
   register_plugin("Build Limiter", "1.1", "Carling")
   register_cvar("Build Limiter", "1.1", FCVAR_SERVER)

   register_impulse(91, "build_oc")
   register_impulse(92, "build_dc")
   register_impulse(93, "build_sc")
   register_impulse(94, "build_mc")
   register_impulse(43, "build_tf")
   register_impulse(56, "build_t")  // Turret
   register_impulse(57, "build_st") // Siege Turret
   register_impulse(58, "build_cc") // Command Chair
   register_impulse(40, "build_ip") // Infantry Portal
   register_impulse(61, "drop_mines") // Drop mine pack
   register_impulse(59, "drop_medi") // Drop medi pack
   register_impulse(60, "drop_ammo") // Drop Ammo pack
   register_impulse(48, "build_armory") // Drop Armory

   register_impulse(55, "build_pg") // Phasegate
   register_impulse(51, "build_ob") // Observatory
   register_impulse(46, "build_pl") // Prototype Lab
   register_impulse(45, "build_al") // Armslab

}

public build_armory(id) {
   if (pev(id,pev_team) == MARINE && ((ns_get_build("team_armory",0,0) + ns_get_build("team_advarmory",0,0)) >= AR_LIMIT)) {
      client_print(id,print_center,"Max armorys reached! (%i)", AR_LIMIT)
      return PLUGIN_HANDLED  
   }
   if (pev(id,pev_team) == MARINE && (((ns_get_build("team_armory",0,0) + ns_get_build("team_advarmory",0,0)) - (ns_get_build("team_armory",0,1) + ns_get_build("team_advarmory",0,1))) >= uAR_LIMIT)) {
      client_print(id,print_center,"Max unbuilt armorys reached! (%i)^nFinish building the ones you have first!", uAR_LIMIT)
      return PLUGIN_HANDLED  
   }
   return PLUGIN_CONTINUE
}

public drop_ammo(id) {
   if (pev(id,pev_team) == MARINE && (ns_get_build("item_genericammo",0,0) >= AMO_LIMIT)) {
      client_print(id,print_center,"Max Ammo Packs reached! (%i)", AMO_LIMIT)
      return PLUGIN_HANDLED  
   }
   return PLUGIN_CONTINUE
}
public drop_medi(id) {
   if (pev(id,pev_team) == MARINE && (ns_get_build("item_health",0,0) >= MED_LIMIT)) {
      client_print(id,print_center,"Max Medi Packs reached! (%i)", MED_LIMIT)
      return PLUGIN_HANDLED  
   }
   return PLUGIN_CONTINUE
}
public drop_mines(id) {
   if (pev(id,pev_team) == MARINE && ((ns_get_build("item_mine",0,0) + (ns_get_build("weapon_mine",0,0) * 4)) >= M_LIMIT)) {
      client_print(id,print_center,"Max Mines reached! (%i)", M_LIMIT)
      return PLUGIN_HANDLED  
   }
   return PLUGIN_CONTINUE
}
public build_ip(id) {
   if (pev(id,pev_team) == MARINE && (ns_get_build("team_infportal",0,0) >= IP_LIMIT)) {
      client_print(id,print_center,"Max Infantry Portals reached! (%i)", IP_LIMIT)
      return PLUGIN_HANDLED  
   }
   return PLUGIN_CONTINUE
}
public build_pg(id) {
   if (pev(id,pev_team) == MARINE && (ns_get_build("phasegate",0,0) >= PG_LIMIT)) {
      client_print(id,print_center,"Max Phasegates reached! (%i)", PG_LIMIT)
      return PLUGIN_HANDLED  
   }
   return PLUGIN_CONTINUE
}
public build_ob(id) {
   if (pev(id,pev_team) == MARINE && ((ns_get_build("team_observatory",0,0) + ns_get_build("team_advobservatory",0,0)) >= OB_LIMIT)) {
      client_print(id,print_center,"Max Observatories reached! (%i)", OB_LIMIT)
      return PLUGIN_HANDLED  
   }
   if (pev(id,pev_team) == MARINE && (((ns_get_build("team_observatory",0,0) + ns_get_build("team_advobservatory",0,0)) - (ns_get_build("team_observatory",0,1) + ns_get_build("team_advobservatory",0,1))) >= uOB_LIMIT)) {
      client_print(id,print_center,"Max unbuilt Observatories reached! (%i)^nFinish building the ones you have first!", uOB_LIMIT)
      return PLUGIN_HANDLED 
   }
   return PLUGIN_CONTINUE
}
public build_pl(id) {
   if (pev(id,pev_team) == MARINE && ((ns_get_build("team_prototypelab",0,0) + ns_get_build("team_advprototypelab",0,0)) >= PL_LIMIT)) {
      client_print(id,print_center,"Max Prototype Labs reached! (%i)", PL_LIMIT)
      return PLUGIN_HANDLED  
   }
   if (pev(id,pev_team) == MARINE && (((ns_get_build("team_prototypelab",0,0) + ns_get_build("team_advprototypelab",0,0)) - (ns_get_build("team_prototypelab",0,1) + ns_get_build("team_advprototypelab",0,1))) >= uPL_LIMIT)) {
      client_print(id,print_center,"Max unbuilt Prototype Labs reached! (%i)^nFinish building the ones you have first!", uPL_LIMIT)
      return PLUGIN_HANDLED 
   }
   return PLUGIN_CONTINUE
}
public build_al(id) {
   if (pev(id,pev_team) == MARINE && ((ns_get_build("team_armslab",0,0) + ns_get_build("team_advarmslab",0,0)) >= AL_LIMIT)) {
      client_print(id,print_center,"Max Armslabs reached! (%i)", AL_LIMIT)
      return PLUGIN_HANDLED  
   }
   if (pev(id,pev_team) == MARINE && (((ns_get_build("team_armslab",0,0) + ns_get_build("team_advarmslab",0,0)) - (ns_get_build("team_armslab",0,1) + ns_get_build("team_advarmslab",0,1))) >= uAL_LIMIT)) {
      client_print(id,print_center,"Max unbuilt Armslabs reached! (%i)^nFinish building the ones you have first!", uAL_LIMIT)
      return PLUGIN_HANDLED 
   }
   return PLUGIN_CONTINUE
}
public build_oc(id) {
   if (pev(id,pev_team) == ALIEN && (ns_get_build("offensechamber",0,0) >= OC_LIMIT)) {
      client_print(id,print_center,"Max Offense Chambers reached! (%i)", OC_LIMIT)
      return PLUGIN_HANDLED  
   }
   return PLUGIN_CONTINUE
}
public build_dc(id) {
   if (pev(id,pev_team) == ALIEN && (ns_get_build("defensechamber",0,0) >= DC_LIMIT)) {
      client_print(id,print_center,"Max Defense Chambers reached! (%i)", DC_LIMIT)
      return PLUGIN_HANDLED  
   }
   return PLUGIN_CONTINUE
}
public build_sc(id) {
   if (pev(id,pev_team) == ALIEN && (ns_get_build("sensorychamber",0,0) >= SC_LIMIT)) {
      client_print(id,print_center,"Max Sensory Chambers reached! (%i)", SC_LIMIT)
      return PLUGIN_HANDLED  
   }
   return PLUGIN_CONTINUE
}
public build_mc(id) {
   if (pev(id,pev_team) == ALIEN && (ns_get_build("movementchamber",0,0) >= MC_LIMIT)) {
      client_print(id,print_center,"Max Movment Chambers reached! (%i)", MC_LIMIT)
      return PLUGIN_HANDLED  
   }
   return PLUGIN_CONTINUE
}
public build_tf(id) {
   if (pev(id,pev_team) == MARINE && ((ns_get_build("team_turretfactory",0,0) + ns_get_build("team_advturretfactory",0,0)) >= TF_LIMIT)) {
      client_print(id,print_center,"Max turret factorys deployed! (%i)", TF_LIMIT)
      return PLUGIN_HANDLED  
   }
   #if T_MODE == 1
   listtf(id)
   #endif
   return PLUGIN_CONTINUE
}
public build_t(id) {
   if (pev(id,pev_team) == MARINE && (ns_get_build("turret",0,0) >= ((ns_get_build("team_turretfactory",0,0) + ns_get_build("team_advturretfactory",0,0)) * T_LIMIT))) {
      client_print(id,print_center,"Max turrets deployed! (%i)^nConstruct more Turret Factorys!", ((ns_get_build("team_turretfactory",0,0) + ns_get_build("team_advturretfactory",0,0)) * T_LIMIT))
      return PLUGIN_HANDLED  
   }
   return PLUGIN_CONTINUE
}
public build_st(id) {
   if (pev(id,pev_team) == MARINE && (ns_get_build("siegeturret",0,0) >= (ns_get_build("team_advturretfactory",0,0) * ST_LIMIT))) {
      client_print(id,print_center,"Max siege turrets deployed! (%i)^nConstruct more Adv Turret Factorys!", (ns_get_build("team_advturretfactory",0,0) * ST_LIMIT))
      return PLUGIN_HANDLED  
   }
   return PLUGIN_CONTINUE
}

public build_cc( id )
{
	new cc_count, cc_count_unbuilt, cc_id = -1
	while ( ( cc_id = find_ent_by_class(cc_id, "team_command") ) > 0 )
	{
		if ( ! ( entity_get_int(cc_id, EV_INT_effects) & 128 ) )
		{
			cc_count++
			if ( ns_get_mask(cc_id, MASK_BUILDABLE) )
				cc_count_unbuilt++
		}
	}

	if ( cc_count )
	{
	 	if ( entity_get_int(id, EV_INT_team) == MARINE )
	 	{
	 		if ( cc_count >= CC_LIMIT )
			{
				client_print(id, print_center, "Max command chairs reached! (%i)",  CC_LIMIT)
				return PLUGIN_HANDLED
			}else if ( cc_count_unbuilt - cc_count >= uCC_LIMIT )
			{

client_print(id, print_center, "Max unbuilt command chairs reached! (%i)^nFinish building the ones you have first!", uCC_LIMIT)
return PLUGIN_HANDLED
			}
		}
	}
	return PLUGIN_CONTINUE
}

public gettfcount(id)
{
  new j
  for (new i=1;i<=ns_get_build("team_turrertfactory",0,0);i++)
  {
    if (entity_range(id,ns_get_build("team_turrertfactory",0,i)) <= 1000)
    {
      j++
    }
  }
  for (new i=1;i<=ns_get_build("team_advturrertfactory",0,0);i++)
  {
    if (entity_range(id,ns_get_build("team_advturrertfactory",0,i)) <= 1000)
    {
      j++
    }
  }
  return j
}

public listtf(id) {

   client_print(id,print_center,"Wootage")
}
