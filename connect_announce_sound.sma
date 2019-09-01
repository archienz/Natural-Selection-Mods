/* Connect Announce & Sound
* 
* This plugin announces when a player connects and it plays some music to the 
* one who connects (yes just like Loading Sound plugin)
* 
* Use the defines for configuration
*
* U can get some sounds from http://dl.onos.de/scripting/connect%20sound%20-%20sounds.zip
* Thanx to Airborn who made this songs
*
* And feel free to do your own sounds
* 
* Changelog:
* version 1.0
* - initial release
*/

#include <amxmodx>
#include <geoip>					// comment this line if u dont want to use geoip

#define ANNOUNCE_CONNECT				// comment this line to disable announcements
#define CONNECT_SOUND_FILE "buttons/blip1.wav"		// comment this line to disable the blip sound
#define MAXSOUNDS 5					// comment this line to disable loading sounds


#if defined MAXSOUNDS
// sounds must be in moddir/sound/
// and dont forget the .mp3
new soundlist[MAXSOUNDS][] = {
	"www.onos.de/onos.de_001.mp3",
	"www.onos.de/onos.de_002.mp3",
	"www.onos.de/onos.de_003.mp3",
	"www.onos.de/onos.de_004.mp3",
	"www.onos.de/onos.de_005.mp3"
}
#endif

public plugin_init() {
	register_plugin("Connect Announce & Sound", "1", "skulk_on_dope")
}

#if defined MAXSOUNDS || (defined CONNECT_SOUND_FILE && defined ANNOUNCE_CONNECT)
public plugin_precache() {
	#if defined MAXSOUNDS
	for(new i=0; i <= MAXSOUNDS-1; i++) {
		precache_sound(soundlist[i])
	}
	#endif
	#if defined CONNECT_SOUND_FILE && defined ANNOUNCE_CONNECT
	precache_sound(CONNECT_SOUND_FILE)
	#endif
}
#endif

#if defined MAXSOUNDS
public client_connect(id) {
	new i
	i = random_num(0, MAXSOUNDS-1)
	client_cmd(id, "mp3 play sound/%s", soundlist[i])
	return PLUGIN_CONTINUE
}
#endif

#if defined ANNOUNCE_CONNECT
public client_authorized(id) {
	if(is_user_bot(id) || is_user_hltv(id))
		return PLUGIN_CONTINUE
	
	new szUserName[33]
	get_user_name(id, szUserName, 32)
	
	#if defined _geoip_included
	new szCountry[46], szIP[16]
	get_user_ip(id, szIP, 15, 1)
	geoip_country(szIP, szCountry, 45)
	if(equal(szCountry, "error"))
		format(szCountry, 45, "unknown")
	#endif
		
	#if defined CONNECT_SOUND_FILE
	client_cmd(0, "spk %s", CONNECT_SOUND_FILE)
	#endif
	#if defined _geoip_included
	client_print(0, print_chat, "%s from %s is connecting", szUserName, szCountry)
	#else
	client_print(0, print_chat, "%s is connecting", szUserName)
	#endif
	return PLUGIN_CONTINUE
}
#endif
