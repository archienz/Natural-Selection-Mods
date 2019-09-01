/*
*	NS MapCycle
*	devicenull
*	If you got this from any web site other then www.amxmodx.org please notify
*	the author (devicenull AT gmail DOT com)	
*
*	Make sure that none of the maps are duplicated in your mapcyclefile
*
*
*  This program is free software; you can redistribute it and/or modify it
*  under the terms of the GNU General Public License as published by the
*  Free Software Foundation; either version 2 of the License, or (at
*  your option) any later version.
*
*  This program is distributed in the hope that it will be useful, but
*  WITHOUT ANY WARRANTY; without even the implied warranty of
*  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
*  General Public License for more details.
*
*  You should have received a copy of the GNU General Public License
*  along with this program; if not, write to the Free Software Foundation,
*  Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
*
*  In addition, as a special exception, the author gives permission to
*  link the code of this program with the Half-Life Game Engine ("HL
*  Engine") and Modified Game Libraries ("MODs") developed by Valve,
*  L.L.C ("Valve"). You must obey the GNU General Public License in all
*  respects for all of the code used other than the HL Engine and MODs
*  from Valve. If you modify this file, you may extend this exception
*  to your version of the file, but you are not obligated to do so. If
*  you do not wish to do so, delete this exception statement from your
*  version.
*/
#include <amxmodx>
#define MAXMAPS 300
#define MAXNAMELEN 128

new sNextMap[MAXNAMELEN]
new sMaps[MAXMAPS][MAXNAMELEN]
new iMin[MAXMAPS]
new iMax[MAXMAPS]
new iCurIndex=-1

public plugin_init() {
	register_plugin("Nextmap","0.1","devicenull")
	register_clcmd("say nextmap","sayNextMap",0,"- displays nextmap")
	register_clcmd("amx_nextmap","sayNextMap",0,"- displays nextmap")
	register_cvar("amx_nextmap","",FCVAR_SERVER|FCVAR_EXTDLL|FCVAR_SPONLY)
	loadMaps()
	getNextMap()
	set_cvar_string("amx_nextmap",sNextMap)
	server_print("Nextmap is %s",sNextMap)
}

public loadMaps() {
	new mapcyclefile[64]
	get_cvar_string("mapcyclefile",mapcyclefile,64)
	if (!file_exists(mapcyclefile)) {
		log_amx("[NSM] Error opening mapcyclefile, file not found")
		return 0
	}
	//ns_nothing "\minplayers\16\maxplayers\32\"
	new i, sBuffer[256], sMapName[MAXNAMELEN], iParam, sParam[64], sCurMap[MAXNAMELEN]
	new iTmp, sTmp[3], c=-1, a
	get_mapname(sCurMap,MAXNAMELEN)
	while (read_file(mapcyclefile,i,sBuffer,256,a)) {
		i++
		if (!isalpha(sBuffer[0])) continue //Make sure this isnt a comment or empty line
		c++
		copyc(sMapName,MAXNAMELEN,sBuffer,32) //Get the map name out of the buffer
		copy(sMaps[c],MAXNAMELEN,sMapName) //Put the map name into our array
		if (equali(sMapName,sCurMap)) {
			iCurIndex = c
		 }
		iParam = strlen(sMaps[c])+3 //Character that starts the extra stuff
		while (iParam <= strlen(sBuffer)) {
			copyc(sParam,64,sBuffer[iParam],92)
			if (equali(sParam,"minplayers")) {
				iTmp = strlen(sParam) + iParam + 1
				copyc(sTmp,3,sBuffer[iTmp],92) //Gets the number of players
				iMin[c] = str_to_num(sTmp)
				iParam=iParam+strlen(sTmp)+1
			}
			else if (equali(sParam,"maxplayers")) {
				iTmp = strlen(sParam) + iParam + 1
				copyc(sTmp,3,sBuffer[iTmp],92) // Gets the number of maxplayers
				iMax[c] = str_to_num(sTmp)
				iParam=iParam+strlen(sTmp)+1
			}
			iParam=iParam+strlen(sParam)+1
			if (iMin[c] > 0 && iMax[c] > 0) break
		}
		//server_print("Map: %s   MinPlayers: %i    MaxPlayers %i",sMaps[c],iMin[c],iMax[c])
	}
	return 0
}
	
public getNextMap() {
	new i, iPlayers, done, ldown=0
	i=iCurIndex + 1
	iPlayers = get_playersnum()
	server_print("%i",iPlayers)
	while (!done) {
		if (isalpha(sMaps[i][0])) {
			if (iPlayers >= iMin[i] && iPlayers <= iMax[i]) {
				copy(sNextMap,MAXNAMELEN,sMaps[i])
				done=1
			}
			else { 
				if (i>=MAXMAPS && !ldown) {
					i=-1
					ldown = 1
				}
				else if (i>=MAXMAPS && ldown) {
					done=1
					copy(sNextMap,MAXNAMELEN,"ERROR!")
				}
			}
		}
		i++
	}
	set_cvar_string("amx_nextmap",sNextMap)
}
			
public sayNextMap(id) {
	getNextMap()
	if (iCurIndex == -1) {
		client_print(0,print_chat,"Current map not in mapcycle! Unable to get posistion!")
		return PLUGIN_HANDLED
	}
	client_print(0,print_chat,"Nextmap is %s",sNextMap)
	return PLUGIN_HANDLED
}