/* This simple plugin fixes the Onos stuck issue when
 * teleporting (or redeeming) to Angel's Grave hive
 * in ns_machina in NS 3.2 beta 2.
 * -
 * I assume this will be fixed in the next release,
 * so I put a check in to disable this plugin if
 * it is loaded with a non-3.2beta2 release
 * -
 * NOTE: This plugin will stop itself when it's done
 *       this is NORMAL, and is nothing to be worried
 *       about.
 */

#include <amxmodx>
#include <fakemeta>

new SpawnForward;
public plugin_precache()
{
	new NSVersion[32];
	//FM_SetKeyValue
	dllfunc(DLLFunc_GetGameDescription,NSVersion,sizeof(NSVersion)-1);

	// Compensate for the -test1 appendix
	NSVersion[15]='^0';
	
	
	if (strcmp(NSVersion,"NS v3.2.0-Beta2")==0)
	{
		new Map[32];
		get_mapname(Map,sizeof(Map)-1);
		if (strcmp(Map,"ns_machina")==0)
		{
			SpawnForward=register_forward(FM_Spawn,"Spawn_Hook");
			register_plugin("Machina Fix(active)","3.2b2","sawce");
			
		}
		else
		{
			register_plugin("Machina Fix(off)","3.2b2","sawce");
			pause("ad");
		}
	}
	else
	{
		set_fail_state("Invalid NS Version! This plugin can be removed!");
	}
	
}
public Spawn_Hook(id)
{
	static Float:origin[3];
	static Float:origin_look[3] = { -3216.00000, -740.00000, 190.00000 };
	
	pev(id,pev_origin,origin);
	
	
	// tag this as _ so it doesnt call floatcmp natives like crazy
	// should still work!
	if (_:origin[0]==_:origin_look[0] &&
		_:origin[1]==_:origin_look[1] &&
		_:origin[2]==_:origin_look[2])
	{
		static Classname[32];
		pev(id,pev_classname,Classname,sizeof(Classname)-1);
	
		
		if (strcmp(Classname,"info_team_start")==0)
		{
			// This is the buggy spawn, move the origin down 32 units
			origin[2]-=32.0;
			engfunc(EngFunc_SetOrigin,id,origin);
			
			// no need to forward anymore
			unregister_forward(FM_Spawn,SpawnForward);
			
			// all done, now stop this plugin
			pause("ad");
		}
	}
}