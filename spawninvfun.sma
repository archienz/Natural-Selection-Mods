/*
* Makes Peaple invul after spawn for short time
* Set inulnerability time with the cvar mp_spawninvulnerabletime
* Set inulnerability mode with the cvar mp_spawninvulnerablemode (0 = off / 1 = co only / 2 = ns only / 3 = ns + co (default ns + co))
* Default is 3.0 seconds
*
* by Cheesy Peteza
*
* ported to Amx Mod X by White Panther (v1.1)
*	- added:	
*		- support for MvM and AvA
*		- cvar "mp_spawninvulnerablemode" (0 = off / 1 = co only / 2 = ns only / 3 = ns + co) (default ns + co)
*	- fixed:	
*		- exploit for infinite godmode
*		- little error and MvM + AvA
*		- some colors bugs
*	- changed:
*		- system of getting the team
*		(increased version number therefore)
*
* v1.2:
*	- fixed:
*		- problems with colors (again)
*	- changed:
*		- the way of checking if a player spawned
*
* v1.2.1:
*	- fixed:
*		- compatibility issue
*
* v1.2.2:
*	- changed:
*		- fun module not needed anymore
*
* v1.2.3:
*	- fixed:
*		- runtime error
*	- changed:
*		- minor code tweaks
*
* v1.2.4:
*	- changed:
*		- code improvements
*/

#include <amxmodx>
#include <engine>
#include <ns>

new plugin_author[] = "Cheesy Peteza/White Panther"
new plugin_version[] = "1.2.4"

// Marines 1 (Blue)
#define MRED 0
#define MGREEN 170
#define MBLUE 255

// Aliens 1 (Yellow)
#define ARED 255
#define AGREEN 170
#define ABLUE 0

// Marines 2 (Red)
#define M2RED 200
#define M2GREEN 0
#define M2BLUE 0
// or green (comment 3 lines above and uncomment the 3 lines blow)
//#define M2RED 0
//#define M2GREEN 200
//#define M2BLUE 50

// Aliens 2 (red)
#define A2RED 200
#define A2GREEN 0
#define A2BLUE 0
// or green (uncomment the 3 lines below and coment the 3 line above)
//#define A2RED 0
//#define A2GREEN 200
//#define A2BLUE 50

new is_combat_running
new player_team[33]

new CVAR_invultime, CVAR_invulmode, CVAR_tournament

public plugin_init( )
{
	register_plugin("Spawn Invulnerability", plugin_version, plugin_author)
	register_cvar("spawninvfun_version", plugin_version, FCVAR_SERVER)
	set_cvar_string("spawninvfun_version", plugin_version)
	
	register_event("TeamInfo", "eTeamChanges", "ab")
	
	is_combat_running = ns_is_combat()
	
	CVAR_invultime = register_cvar("mp_spawninvulnerabletime", "3.0")
	CVAR_invulmode = register_cvar("mp_spawninvulnerablemode", "3")
	CVAR_tournament = get_cvar_pointer("mp_tournamentmode")
}

public client_putinserver( id )
{
	reset(id)
}

public client_changeteam( id , newteam , oldteam )
{
	if ( newteam < 1 || newteam > 4 )
		reset(id)
	else
		client_spawn(id)
}

public client_changeclass( id , newclass , oldclass )
{
	if ( newclass == 0 || newclass == 11 || newclass == 12 )
		reset(id, 0)
}

public client_spawn( id )
{
	if ( allow_to_run() )
	{
		if ( !get_pcvar_float(CVAR_invultime) || get_pcvar_num(CVAR_tournament) )
			return PLUGIN_HANDLED
		
		if ( player_team[id] )
		{
			switch ( player_team[id] )
			{
				case 1:
					set_rendering(id, kRenderFxGlowShell, MRED, MGREEN, MBLUE, kRenderNormal, 25)
				case 3:
					set_rendering(id, kRenderFxGlowShell, M2RED, M2GREEN, M2BLUE, kRenderNormal, 25)
				case 2:
					set_rendering(id, kRenderFxGlowShell, ARED, AGREEN, ABLUE, kRenderNormal, 25)
				case 4:
					set_rendering(id, kRenderFxGlowShell, A2RED, A2GREEN, A2BLUE, kRenderNormal, 25)
			}
			
			entity_set_float(id, EV_FL_takedamage, 0.0)
			set_task(get_pcvar_float(CVAR_invultime), "disable_inv", 5500 + id)
		}else if ( 1 <= entity_get_int(id, EV_INT_team) <= 4 )
			set_task(0.3, "client_spawn_timer", 6000 + id)
	}
	
	return PLUGIN_CONTINUE
}

public eTeamChanges( )
{
	if ( allow_to_run() )
	{
		new teamname[32], id = read_data(1)
		read_data(2, teamname, 31)
		
		if ( equali(teamname, "marine1team") )
			player_team[id] = 1
		else if ( equali(teamname, "marine2team") )
			player_team[id] = 3
		else if ( equali(teamname, "alien1team") )
			player_team[id] = 2
		else if ( equali(teamname, "alien2team") )
			player_team[id] = 4
		else
			player_team[id] = 0
	}
}

/* additional Functions */
allow_to_run( )
{
	switch ( get_pcvar_num(CVAR_invulmode) )
	{
		case 0 :
			return 0
		case 1 :
			if ( is_combat_running )
				return 1
		case 2 :
			if ( !is_combat_running )
				return 1
		case 3 :
			return 1
	}
	return 0
}

reset( id , team_change = 1 )
{
	if ( is_user_connected(id) )
	{
		entity_set_float(id, EV_FL_takedamage, 2.0)
		set_rendering(id, kRenderFxGlowShell, 0, 0, 0, kRenderNormal, 0)
	}
	remove_task(5500 + id)
	remove_task(6000 + id)
	if ( team_change )
		player_team[id] = 0
}

/* Timer Functions */
public client_spawn_timer( timerid_id )
{
	if ( is_user_connected(timerid_id - 6000) )
		client_spawn(timerid_id - 6000)
}

public disable_inv( timerid_id )
{
	reset(timerid_id - 5500)
}