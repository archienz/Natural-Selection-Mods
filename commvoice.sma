///////////////////////////////////////////////////////////////////////////////////////
//
//	AMX Mod (X)
//
//	Developed by:
//	Team SEK2000 - Blackhawk
//
//	Name:		Coammnder's master voice system
//	Author:		Blackhawk
//	Description:	This plugin will allow commanders to be heard by all marines
//	V 1.0	- initial
//
///////////////////////////////////////////////////////////////////////////////////////
// Includes and variables control
#include <amxmodx>
#include <amxmisc>
#include <engine>
#include <fun>
#include <fakemeta>
#include <ns>
#define MARINE  1

new Players[32]		// Array of Player indices
new Players_count	// Numbers of used indices in array
new i			// temp var for counters
///////////////////////////////////////////////////////////////////////////////////////
// Name and version control
//
new PLUGIN_AUTHOR[] 	= "[SEK2000]Blackhawk"
new PLUGIN_NAME[] 	= "The Commander's Voice"
new PLUGIN_VERSION[] 	= "1.0"
//
///////////////////////////////////////////////////////////////////////////////////////

public plugin_init()
{
	register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR)
	register_clcmd("+Commvoice", "cmd_Commvoice_on",  0, "Starts COMM Voice")
	register_clcmd("-Commvoice", "cmd_Commvoice_off", 0, "Stops COMM Voice")
	
}


public cmd_Commvoice_on(id)
{
	if(!(ns_get_class(id) == CLASS_COMMANDER))
		return PLUGIN_HANDLED
		
	get_players(Players, Players_count, "c")
	for(i = 0; i < Players_count; i++)
	{
		if( pev(Players[i], pev_team) == MARINE && !(ns_get_class(Players[i]) == CLASS_COMMANDER))
			set_speak(Players[i], SPEAK_MUTED)
	}
	client_cmd(id, "+voicerecord")
	client_print(id, print_chat, "[Commander's Voice] Please speak, Sir.")	
	return PLUGIN_CONTINUE
}


public cmd_Commvoice_off(id)
{
	if(!(ns_get_class(id) == CLASS_COMMANDER))
		return PLUGIN_HANDLED
	client_cmd(id, "-voicerecord")
	
	get_players(Players, Players_count, "c")

	for(i = 0; i < Players_count; i++)
	{
		if( pev(Players[i], pev_team) == MARINE) set_speak(Players[i], SPEAK_NORMAL)
	}
	
	client_print(id, print_chat, "[Commander's Voice] Channel closed")
	return PLUGIN_CONTINUE
}

public client_changeclass( id, newclass, oldclass )
{
	if (newclass == CLASS_COMMANDER) client_print(id,print_chat,"Bind +commvoice to mute all others while you talk!")
}