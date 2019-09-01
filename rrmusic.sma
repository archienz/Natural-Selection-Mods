/* RR Music
 * -
 * By Steve Dudenhoeffer
 * Ported by mE @ psix.info
 * fixes White Panther
 * - 
 * Start music in the ready room.
 * Uses a config file located in: <ns directory>/map_music.txt
 * The syntax of the config file is as follows:
 *
 * map_name path/to/music/relative/to/ns/directory.mp3 <volume> <fade distance>
 *
 * If volume or fade distance (mirrors values from the target_mp3audio entity) are not provided
 * then the values 200 and 1000 are use, respectively.
 *
 * An example config file:
 *
 * ns_eclipse mp3/base.mp3 200 1500
 * co_daimos mp3/bananaphone.mp3
 * co_pulse mp3/a.mp3
 *
 *
 * Things to note:
 * - Do NOT use comments in the config file. 
 * - Put the path to the mp3 (and any config) on the line immediately following the map name
 * - The music must be precached (meaning if the client doesn't have it, he will download it)
 *   so it's advised to use small mp3s and/or enable sv_downloadurl.
 * - Some music may go through walls into the game play area.  If this is unwanted, tweaking of fade distance would be required.
 * - max <fade distance> is 1499, every value above this one will make the mp3 not play
 *
 * v1.2:
 *	- fixed:
 *		- now working with amx mod X 1.6
 */


#include <amxmodx>
#include <engine>

new g_szMusic[256]
new g_szVolume[6]
new g_szFade[6]
new g_loaded=0

new plugin_version[] = "1.2"

public plugin_init( )
{
	register_plugin("RR Music", plugin_version, "Steve Dudenhoeffer")
	register_cvar("rrmusic_version", plugin_version, FCVAR_SERVER)
}

public plugin_precache()
{
	new lines = file_size("map_music.txt", 1)
	if ( lines == -1 )
	{
		server_print("[rrmusic] Error: map_music.txt not in NS directory!")
		return PLUGIN_CONTINUE
	}
	// Scan the file for the current map name..
	new szMap[128]
	new szMapLine[128]
	get_mapname(szMap, 127)
	new szLine[512]
	for ( new i = 0; i < lines; i++ )
	{
		new len
		read_file("map_music.txt", i, szLine, 511, len)
		parse(szLine, szMapLine, 127, g_szMusic, 255, g_szVolume, 5, g_szFade, 5)
		if ( equal(szMapLine, szMap) )
		{
			if ( equal(g_szVolume, "") )
				copy(g_szVolume, 5, "200")
			if ( equal(g_szFade, "") )
				copy(g_szFade, 5, "1000")
			if ( !file_exists(g_szMusic) )
			{
				server_print("[rrmusic] Music ^"%s^" not found! Not loading music.", g_szMusic)
				return PLUGIN_CONTINUE
			}
			server_print("[rrmusic] Using music ^"%s^" [volume: %s fade: %s]", g_szMusic, g_szVolume, g_szFade)
			g_loaded=1
			precache_generic(g_szMusic)
			break
		}
	}
	return PLUGIN_CONTINUE
}

public pfn_spawn( entid )
{
	if ( g_loaded != 1 || !is_valid_ent(entid) )
		return PLUGIN_CONTINUE
	
	new szClassname[32]
	entity_get_string(entid, EV_SZ_classname, szClassname, 31)
	if ( equal(szClassname, "info_player_start") )
	{
			// RR spawn
			g_loaded = 2
			
			new Float:fOrigin[3]
			entity_get_vector(entid, EV_VEC_origin, fOrigin)
			
			new ent = create_entity("target_mp3audio")
			entity_set_vector(ent, EV_VEC_origin, fOrigin)
			DispatchKeyValue(ent, "spawnflags", "6")
			DispatchKeyValue(ent, "soundname", g_szMusic)
			DispatchKeyValue(ent, "fadedistance", g_szFade)
			DispatchKeyValue(ent, "soundvolume", g_szVolume)
			DispatchSpawn(ent)
	}
	return PLUGIN_CONTINUE
}