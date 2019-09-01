/* AMX MOD X
* 
* Thanks to Cheesy Peteza for his original glbock plugin.
* 
* This plugin was ported to v1.00 by Depot and is intended
* to prohibit grenade launcher usage on MvM maps.
* 
* I offer limited support on this plugin.
*  
*/

#include <amxmodx> 
#include <engine> 
#include <fakemeta> 
#include <ns>
 
#define MESSAGE_DELAY	8 
 
new bool:g_ismvm 
new Float:g_lastmessage[33] 
 
public plugin_init(){ 
	register_plugin("GL Block for MvM", "1.0", "Cheesy Peteza") 
	register_cvar("glblock_version", "1.0", FCVAR_SERVER) 
	register_cvar("amx_glblock", "1") 
 
	if ( is_mvm() ){ 
		register_impulse(66, "buyGL") 
	} 
} 
 
public buyGL(id) { 
	if ( !g_ismvm ) 
		return PLUGIN_CONTINUE 
 
	if ( !get_cvar_num("amx_glblock") ) 
		return PLUGIN_CONTINUE 
 
	if ( (get_gametime() - g_lastmessage[id]) > MESSAGE_DELAY ){ 
		ns_popup(id, "Grenade Launchers are prohibited in MvM maps.  Read the rules plz!") 
		g_lastmessage[id] = get_gametime() 
	} 
 
	set_pev(id, pev_impulse, 0) 
	return PLUGIN_HANDLED 
} 
 
is_mvm(){ 
	new mapname[4] 
	get_mapname(mapname, 3) 
	if ( !equal(mapname, "co_") ) 
		return 0 
 
	if ( ns_get_build("team_command",0, 0) > 1 ){ 
		g_ismvm = true 
		return 1 
	} 
 
	return 0

 }
