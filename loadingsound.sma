/*
* Play a sound during the connection.
* Random code part taken from plugin
* connectsound by DarK_SouL
*
* Plugin para tocar musica enquanto o
* usuario baixa os arquivos necessarios
* ele toca de forma alternada
*
* Translate by DarK_SouL
*
* v1.1
*
*/

#include <amxmodx>
#define Maxsounds 6 // maximas musicas

// sounds localized in gcf cache (valve/media)
// you can add more song if you want.

// pasta das musicas localizada em valve/media
// voce pode adicionar mais musicas se desejar

// name of music files / nome dos arquivos de musica
new soundlist[Maxsounds][] = {"Half-Life01","Half-Life02","Half-Life08","Half-Life12","Half-Life16","Half-Life17"}

public client_connect(id) {
	new i
	i = random_num(0,Maxsounds-1)
	client_cmd(id,"mp3 play media/%s",soundlist[i])
	return PLUGIN_CONTINUE
}

public plugin_init() {
	register_plugin("Loading Sound","1.1","Amx User")
	return PLUGIN_CONTINUE
}