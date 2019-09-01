/* Script Forwards - (c) 2007
 * -
 * This plugin sends a couple client command forwards for 
 * very basic events during Natural-Selection.
 *
 * 'Events' tracked:
 *   Blockscripts setting
 *   Map type
 *   Team type
 *   Class type
 *
 * NOTE: The blockscript setting will NOT be updated
 *       if a server administrator changes the cvar
 *       after you had the forward sent.  I see no
 *       justification for changing the cvar mid map,
 *       so adding the overhead of tracking it isnt
 *       worth it.
 *
 * Actual forwards sent:
 *   Blockscripts:
 *      Sent once at the beginning of a map.
 *      * f_bs for mp_blockscripts 1
 *      * f_nobs for mp_blockscripts 0
 *
 * Map type:
 *      Sent once at the beginning of a map.
 *      * f_ns for ns_* map.
 *      * f_co for co_* map.
 *
 * Team type:
 *      Sent once per team type change.  
 *      NOTE: MvM and AvA arent supported, but it should work.
 *      * f_alien for alien team
 *      * f_marine for marine team
 *
 * Class type:
 *      Sent on the original class change.
 *      Example: evolving to gorge, then getting carapace will only send
 *               the gorge forward once.
 *      Alien: f_skulk f_gorge f_lerk f_fade f_onos
 *      Marine: f_light f_heavy f_jetpack f_commander
 * -
 *  This program is free software; you can redistribute it and/or modify it
 *  under the terms of the GNU General Public License as published by the
 *  Free Software Foundation; either version 2 of the License, or (at
 *  your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful, but
 *  WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 *  General Public License for more details.
 */

#include <amxmodx>
#include <ns>

new mp_blockscripts; // pointer to mp_blockscripts
new combat;          // whether or not this map is co_

#define TEAM_UNKNOWN 0
#define TEAM_MARINE 1
#define TEAM_ALIEN 2

/**
 * Definitions of the commands that will be executed
 */
// mp_bs stuff
stock const BlockScriptsOn[]="f_bs";
stock const BlockScriptsOff[]="f_nobs";

// Map execution
stock const CombatMap[]="f_co";
stock const ClassicMap[]="f_ns";

// Team changes
stock const MarineTeam[]="f_marine";
stock const AlienTeam[]="f_alien";

// Marine classes
stock const ClassLightArmor[]="f_light";
stock const ClassHeavyArmor[]="f_heavy";
stock const ClassCommander[]="f_commander";
stock const ClassJetpack[]="f_jetpack";

// Alien classes
stock const ClassSkulk[]="f_skulk";
stock const ClassGorge[]="f_gorge";
stock const ClassLerk[]="f_lerk";
stock const ClassFade[]="f_fade";
stock const ClassOnos[]="f_onos";

new LastPlayerClass[33];   // stores the last non-gestate/dead player class
new LastPlayerTeam[33];    // last team this player was on 
new PlayerInitialized[33]; // whether this player had the [no]bs/co/ns forwards yet

// Just a wrapper so I dont have to format this properly each time
stock Execute(id,const cmd[])
{
	client_cmd(id,"%s",cmd);
}

// Register & hook our commands to stop unknown command messages
public DoNothing(id)
{
	return PLUGIN_HANDLED;
}
stock RegisterCommand(const cmd[])
{
	register_clcmd(cmd,"DoNothing");
}

public plugin_init()
{
	register_plugin("Script Forwards","1.0","sawce");

	mp_blockscripts=get_cvar_pointer("mp_blockscripts");
	combat=ns_is_combat();
	
	RegisterCommand(BlockScriptsOn);
	RegisterCommand(BlockScriptsOff);
	
	RegisterCommand(CombatMap);
	RegisterCommand(ClassicMap);

	RegisterCommand(MarineTeam);
	RegisterCommand(AlienTeam);
	
	RegisterCommand(ClassLightArmor);
	RegisterCommand(ClassHeavyArmor);
	RegisterCommand(ClassCommander);
	RegisterCommand(ClassJetpack);
	
	RegisterCommand(ClassSkulk);
	RegisterCommand(ClassGorge);
	RegisterCommand(ClassLerk);
	RegisterCommand(ClassFade);
	RegisterCommand(ClassOnos);
}

/**
 * Client loaded and is in the ready room now.
 * Set all their data to standard 
 */
public client_putinserver(id)
{
	LastPlayerClass[id]=CLASS_UNKNOWN; // Reset so first time spawns will always forward
	LastPlayerTeam[id]=TEAM_UNKNOWN;
}

/**
 * Helper to send nobs/bs/co/ns forwards
 * Have to call this from whenever a normal forward gets called
 * because it here since it doesnt like it in client_putinserver 
 * for some reason...
 */
stock InitializePlayer(id)
{
	if (get_pcvar_num(mp_blockscripts)>0) // mp_bs is on
	{
		Execute(id,BlockScriptsOn);
	}
	else
	{
		Execute(id,BlockScriptsOff);
	}
	
	if (combat) // co_ map
	{
		Execute(id,CombatMap);
	}
	else
	{
		Execute(id,ClassicMap);
	}
	
	PlayerInitialized[id]=1;
}

/**
 * NS Module forward for when the client class has changed
 */
public client_changeclass(id, newclass, oldclass)
{
	if (is_user_bot(id)) // just ignore bots
	{
		return PLUGIN_CONTINUE;
	}
	
	// If its not a gestate, dead, unknown or ready room then forward it
	if (newclass!=CLASS_GESTATE && 
		newclass!=CLASS_UNKNOWN &&
		newclass!=CLASS_NOTEAM &&
		newclass!=CLASS_DEAD)
	{
		// had the [no]bs/co/ns forwards yet?
		if (!PlayerInitialized[id])
		{
			InitializePlayer(id);
		}
		
		if (newclass!=LastPlayerClass[id]) // but only if its different!
		{
			LastPlayerClass[id]=newclass;
			
			switch(newclass)
			{
				// Marine classes
				case CLASS_MARINE:
				{
					if (LastPlayerTeam[id]!=TEAM_MARINE)
					{
						LastPlayerTeam[id]=TEAM_MARINE;
						Execute(id,MarineTeam);
					}
					Execute(id,ClassLightArmor);
				}
				case CLASS_HEAVY:
				{
					if (LastPlayerTeam[id]!=TEAM_MARINE)
					{
						LastPlayerTeam[id]=TEAM_MARINE;
						Execute(id,MarineTeam);
					}
					Execute(id,ClassHeavyArmor);
				}
				case CLASS_COMMANDER:
				{
					if (LastPlayerTeam[id]!=TEAM_MARINE)
					{
						LastPlayerTeam[id]=TEAM_MARINE;
						Execute(id,MarineTeam);
					}
					Execute(id,ClassCommander);
				}
				case CLASS_JETPACK:
				{
					if (LastPlayerTeam[id]!=TEAM_MARINE)
					{
						LastPlayerTeam[id]=TEAM_MARINE;
						Execute(id,MarineTeam);
					}
					Execute(id,ClassJetpack);
				}

				// Alien classes
				case CLASS_SKULK:
				{
					if (LastPlayerTeam[id]!=TEAM_ALIEN)
					{
						LastPlayerTeam[id]=TEAM_ALIEN;
						Execute(id,AlienTeam);
					}
					Execute(id,ClassSkulk);
				}
				case CLASS_GORGE:
				{
					if (LastPlayerTeam[id]!=TEAM_ALIEN)
					{
						LastPlayerTeam[id]=TEAM_ALIEN;
						Execute(id,AlienTeam);
					}
					Execute(id,ClassGorge);
				}
				case CLASS_LERK:
				{
					if (LastPlayerTeam[id]!=TEAM_ALIEN)
					{
						LastPlayerTeam[id]=TEAM_ALIEN;
						Execute(id,AlienTeam);
					}
					Execute(id,ClassLerk);
				}
				case CLASS_FADE:
				{
					if (LastPlayerTeam[id]!=TEAM_ALIEN)
					{
						LastPlayerTeam[id]=TEAM_ALIEN;
						Execute(id,AlienTeam);
					}
					Execute(id,ClassFade);
				}
				case CLASS_ONOS:
				{
					if (LastPlayerTeam[id]!=TEAM_ALIEN)
					{
						LastPlayerTeam[id]=TEAM_ALIEN;
						Execute(id,AlienTeam);
					}
					Execute(id,ClassOnos);
				}
			}
		}
	}
	
	return PLUGIN_CONTINUE;
}
