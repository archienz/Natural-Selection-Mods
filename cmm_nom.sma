#include <amxmodx>
#include <amxmisc>

/*
Copyright (C) 2005 Head crab

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
*/

/************************************************************************
*									*
* Crab's Map Manager, v1.6aNom						*
* by Head crab								*
*									*
* Originally created in March 2004					*
* designed for Natural Selection					*
*									*
* This plugin offers 2 map votes that are triggered when the time	*
* limit has been reached and while there is no game currently being	*
* played.								*
*									*
* The first vote will give many map options to the players. The		*
* second vote will feature the 2 maps that have had the most votes in	*
* the first vote.							*
*									*
* This system prevents a map chosen in a minority victory (less than	*
* 50%) to be selected as the next map.					*
*									*
* However, if you set your VOTE_LIMIT to 2, only one vote will occur.	*
*									*
* You can specify a map history limit to avoid getting the last played	*
* maps in the next votes.						*
*									*
* You may choose to specify a minimum amount of players required in	*
* order to use the mapcycle.txt file. If the amount of players is	*
* insufficient, mapcycle2.txt will be used for the vote.		*
*									*
* You can set each single map to a specific type in their respective	*
* mapcycle file. Each map type will be available in the vote options.	*
* If you decide not to use map types, each map will be set to map type	*
* of 1 by default.							*
*									*
* The results of the map votes can directly be displayed on the HUD	*
* while there is a vote. But you can desactivate this feature. At the	*
* same time, the remaining time to the vote will be displayed.		*
									*
* If "amx_vote_answers" is activated, the names of the voters and	*
* their choices will be displayed in the chat area.			*
*									*
* Use the "amx_vote_time" cvar to determine the amount of time a vote	*
* will last.								*
*									*
* A built-in "nextmap" command is available to fit this plugin. It	*
* will display the maps which are going to be included in the next	*
* vote. So it is recommended to remove the "nextmap.amx" plugin.	*
*									*
* There is a bell sound when a vote occurs.				*
*									*
* Admins may use the "amx_mapoption <Option number> <Map name>" command	*
* to change one of the map options before a map vote is started. They	*
* can use the "amx_showmapoptions" command to display the current map	*
* vote options.								*
*									*
* They can also use the "amx_startmapvote" command to begin a vote	*
* during a game if they wish.						*
*									*
* A map extend option is available. You can extend a map for a specific *
* number of times defined in the options below.				*
*									*
* Variables:								*
*   amx_mapvoteplayers	-> minimum players needed for mapcycle.txt	*
*   amx_vote_time	-> time the vote goes on			*
*   amx_vote_answers	-> shows the vote of each player		*
*									*
*									*
* Yes, I know I'm awesome.						*
* P.S. mp_blockscripts 0 and don't ban good players kthx.		*
*									*
************************************************************************/

// The amount of map options in the first vote (2-9)
// Warning: consider if the number of maps available on your server
// is enough for all the limits (VOTE_LIMIT and HISTORY_LIMIT)
// i.e. 7 maps won't be enough for VOTE_LIMIT 5 and HISTORY_LIMIT 3
// considering that 3 maps are taken out in the history and that the
// current map being played is taken out, that leaves only 3 maps that
// could be in the vote options, so set your VOTE_LIMIT to 3.
// Note: you MUST set this between 2 and 9. Setting it to 10 may cause problems
// with the map extend option.
#define VOTE_LIMIT 9

// The map history limit. These maps are the last maps played and will
// not be brought back in the vote list until they have been replaced.
#define HISTORY_LIMIT 3

// Set your map history filename and folder here (keep the quotes).
// i.e. "addons/amx/maphistory.ini"
new g_MapHistFile[64] = "maphistory.ini"

// The maximum of maps the plugin will try to look for in your
// mapcycle files (maps are selected at random).
#define MAP_LIMIT 70

// Amount of map extends possible. The map extend option will always use the last
// slot available (the last voting key). Set to 0 to disable.
// Note: you should keep the value low, because maps get boring when being played
// too much.
#define MAP_EXTEND 0

// Allow a mapcycle restriction due to the players' amount (set to 0 to disable
// and set to 1 to enable). Mapcycle files being respectively mapcycle.txt and
// mapcycle2.txt, the first one will be used when there are equal or more than
// the specified number of players while the inverse situation will use the second
// one. This is useful to seperate combat maps from classic maps in Natural Selection.
// The minimum player requirement is set by the amx_mapminplayers cvar (default 6).
#define MAPCYCLE_RESTRICTION 0

// You can define map types by adding a specific number after a map name in the
// mapcycle files. For example, "co_core 2" would have the map "co_core" defined
// as a map type "2", here used to define combat maps in Natural Selection. If no
// number is specified, all maps are set to map type "1" by default. The map vote
// will attempt to include a map of each type in the vote options as long as it is
// possible. Set to 1 to disable or specify the number of different map types. This
// can be useful to include custom maps along with official maps in the vote, as well
// as making sure there are classic, combat AND custom maps in the vote at all times.
// You could also set the maps "ns_eclipse" as a map type 1 and "ns_veil" as a map
// type 2. Note that if all the maps of a specific type may not be available if they
// are taken away by the map history.
#define MAP_TYPES 7

// Display the results on the HUD during the vote (0 to disable, 1 to enable)
#define SHOW_RESULTS 1

// HUD channel (1 - 4) to use to show the vote results and to show the time
// remaining to a vote (can conflict with other plugins)
#define DISPLAY_HUD_CHANNEL 1

// Time (seconds) of delay before a vote starts after the map time limit has
// been reached. Note that players are usually brought back to the readyroom
// 8 seconds after a round has ended.
#define VOTE_DELAY 10

// AMX level required to represent more votes
#define ACCESS_LEVEL ADMIN_VOTE

// Amount of votes a privileged user represent (set to 1 to ignore this feature)
#define VOTE_AMOUNT 1

// AMX level required to modify map options before a vote and to start a map
// vote manually.
#define ACCESS_LEVEL2 ADMIN_VOTE

// Maximum number of nominations allowed per player.
#define MAX_NOMINATIONS 2

// Amount of maps displayed in console when listing all the available maps. Avoid
// too high numbers to keep safe from console flood and spam.
#define MAPS_DISPLAYED 20

/*======================Don't edit below======================*/

new g_MapName[MAP_LIMIT][32]
new g_MapHistName[HISTORY_LIMIT][32]
new g_MapChoices[VOTE_LIMIT + 1][32]
new g_VoteCast[VOTE_LIMIT + 1]
new g_VoteCast2[2]
new g_WinningMaps[2][32]
new g_MapCycleFile[64]
new g_MapPlayed = 0
new g_TimeLimit = 0
new g_VoteStarted = 0
new g_VoteNum = 0
new g_VoteTime = 0
new g_CurrentGame = 0
new g_NextMapName[32]
new g_MapCycleStatus = 0
new g_ExtendStatus = MAP_EXTEND
new g_Extend = 0
new g_EnoughMaps = 0
new g_FloodProtect[33]
new g_MapNominated[VOTE_LIMIT][32]
new g_PlayerNom[33]

public plugin_init() {
	register_plugin("Crab'sMapManager","1.6aNom","Head crab")
	register_cvar("crab_map_manager","1.6aNom",FCVAR_SPONLY|FCVAR_SERVER)
	register_clcmd("say nextmap","DisplayNextMap",0,"- displays next map vote's options")
	register_clcmd("say","NominateMap",0,"Say a maps name to nominate it")
	register_clcmd("say_team","NominateMap",0,"Say a maps name to nominate it")
	register_concmd("amx_showallmaps","ShowAllMaps",0,"shows all of the server's maps.")
	register_concmd("amx_mapoption","AdminChange",ACCESS_LEVEL2,"<Vote number> <Map name> - changes a map vote option.")
	register_concmd("amx_showmapoptions","ShowMaps",0,"shows the current map vote options.")
	register_concmd("amx_startmapvote","AdminStartVote",ACCESS_LEVEL2,"- starts a Crab's Map Manager map vote.")
	register_cvar("amx_mapvoteplayers","2")
	register_cvar("amx_vote_time","10")
	register_cvar("amx_last_voting","0")
	register_cvar("amx_vote_answers","0")
	register_menucmd(register_menuid("Nextmap vote (Take 1):"),(-1^(-1<<(VOTE_LIMIT + 1))),"FirstVote")
	register_menucmd(register_menuid("Nextmap vote (Take 2):"),(1<<0)|(1<<1),"SecondVote")
	if (!file_exists(g_MapHistFile))
		write_file(g_MapHistFile,"",0)
	register_event("GameStatus","RoundStarts","abc","1=3")
	register_event("GameStatus","RoundEnds","abc","1=2")
	set_task(1.0,"TimeCheck",16549705,"",0,"b")
	SetMapChoices()
}

public ChangeMap() {
	if (g_Extend == 1) {
		new GameTime = floatround(get_gametime())
		server_cmd("mp_timelimit %d",(GameTime / 60) + 1 + g_TimeLimit)
		g_Extend = 0
		SetMapChoices()
	}
	else {
		server_cmd("mp_timelimit %d",g_TimeLimit)
		if (is_map_valid(g_NextMapName)) {
			server_cmd("changelevel %s",g_NextMapName)
		}
	}
	return PLUGIN_CONTINUE
}

public RoundStarts() {
	if (read_data(3) != 0)
		return PLUGIN_CONTINUE
	if (g_MapPlayed != 2)
		g_MapPlayed = 1
	g_CurrentGame = 1
	return PLUGIN_CONTINUE
}

public RoundEnds() {
	g_CurrentGame = 0
	return PLUGIN_CONTINUE
}

public TimeCheck() {
	new Timeleft = get_timeleft()
	if (!g_CurrentGame && Timeleft <= 5 && !equal(g_MapChoices[0],"") && !g_VoteStarted 
		&& get_cvar_num("mp_timelimit") != 0 && g_EnoughMaps == 1)
	{
		g_VoteStarted = 1
		if (g_ExtendStatus == MAP_EXTEND)
			g_TimeLimit = get_cvar_num("mp_timelimit")
		server_cmd("mp_timelimit 0")
		SetMapChoices()
		set_task(float(VOTE_DELAY),"BeginVote")
	}
	return PLUGIN_CONTINUE
}

public DisplayHud() {
	new ShowResults = SHOW_RESULTS
	if (ShowResults == 1) {
		if (g_VoteNum == 1) {
			new MenuText[256]
			MenuText = "Map vote results (Take 1):^n"
			if (g_ExtendStatus > 0) {
				for (new a = 0; a < (VOTE_LIMIT + 1); a++) {
					format(MenuText,255,"%s%d. %s (%d)^n",MenuText,(a + 1),g_MapChoices[a],g_VoteCast[a])
				}
			}
			else {
				for (new a = 0; a < (VOTE_LIMIT); a++) {
					format(MenuText,255,"%s%d. %s (%d)^n",MenuText,(a + 1),g_MapChoices[a],g_VoteCast[a])
				}
			}
			g_VoteTime--
			if (g_VoteTime < 0)
				g_VoteTime = 0
			format(MenuText,255,"%s^n^nVote timeleft: %d",MenuText,g_VoteTime)
			set_hudmessage(200,200,255,0.55,0.15,0,0.02,(get_cvar_float("amx_vote_time") * 2) + 5.0,0.01,0.1,DISPLAY_HUD_CHANNEL)
			show_hudmessage(0,MenuText)
		}
		else if (g_VoteNum == 2) {
			new MenuText[256]
			MenuText = "Map vote results (Take 2):^n"
			format(MenuText,255,"%s1. %s (%d)^n2. %s (%d)^n",MenuText,g_WinningMaps[0],g_VoteCast2[0],g_WinningMaps[1],g_VoteCast2[1])
			g_VoteTime--
			if (g_VoteTime < 0) {
				g_VoteTime = 0
				remove_task(16549709)
			}
			format(MenuText,255,"%s^n^nVote timeleft: %d",MenuText,g_VoteTime)
			set_hudmessage(200,200,255,0.55,0.15,0,0.02,(get_cvar_float("amx_vote_time") * 2) + 5.0,0.01,0.1,DISPLAY_HUD_CHANNEL)
			show_hudmessage(0,MenuText)
		}
	}
	else {
		if (g_VoteNum == 1) {
			new MenuText[256]
			MenuText = "Map vote options (Take 1):^n"
			if (g_ExtendStatus > 0) {
				for (new a = 0; a < (VOTE_LIMIT + 1); a++) {
					format(MenuText,255,"%s%d. %s^n",MenuText,(a + 1),g_MapChoices[a])
				}
			}
			else {
				for (new a = 0; a < (VOTE_LIMIT); a++) {
					format(MenuText,255,"%s%d. %s^n",MenuText,(a + 1),g_MapChoices[a])
				}
			}
			g_VoteTime--
			if (g_VoteTime < 0)
				g_VoteTime = 0
			format(MenuText,255,"%s^n^nVote timeleft: %d",MenuText,g_VoteTime)
			set_hudmessage(200,200,255,0.55,0.15,0,0.02,(get_cvar_float("amx_vote_time") * 2) + 5.0,0.01,0.1,DISPLAY_HUD_CHANNEL)
			show_hudmessage(0,MenuText)
		}
		else if (g_VoteNum == 2) {
			new MenuText[256]
			MenuText = "Map vote options (Take 2):^n"
			format(MenuText,255,"%s1. %s^n2. %s^n",MenuText,g_WinningMaps[0],g_WinningMaps[1])
			g_VoteTime--
			if (g_VoteTime < 0) {
				g_VoteTime = 0
				remove_task(16549709)
			}
			format(MenuText,255,"%s^n^nVote timeleft: %d",MenuText,g_VoteTime)
			set_hudmessage(200,200,255,0.55,0.15,0,0.02,(get_cvar_float("amx_vote_time") * 2) + 5.0,0.01,0.1,DISPLAY_HUD_CHANNEL)
			show_hudmessage(0,MenuText)
		}
	}
	return PLUGIN_CONTINUE
}

public DisplayNextMap(id) {
	if (g_FloodProtect[id] == 1)
		return PLUGIN_HANDLED
	new NextMapNames[192]
	NextMapNames = "* The next map vote options are "
	for (new a = 0; a < VOTE_LIMIT; a++) {
		if (a != (VOTE_LIMIT - 1))
			format(NextMapNames,191,"%s %s,",NextMapNames,g_MapChoices[a])
		else
			format(NextMapNames,191,"%s %s",NextMapNames,g_MapChoices[a])
	}
	client_print(id,print_chat,"%s",NextMapNames)
	set_task(0.75,"RemoveFlood",id)
	g_FloodProtect[id] = 1
	return PLUGIN_HANDLED
}

public ShowMaps(id) {
	if (g_FloodProtect[id] == 1)
		return PLUGIN_HANDLED
	if (id != 0)
		console_print(id,"[Crab's Map Manager] Map vote options:")
	else
		server_print("[Crab's Map Manager] Map vote options:")
	for (new a = 0; a < VOTE_LIMIT; a++) {
		if (id != 0)
			console_print(id,"%d. %s",a + 1,g_MapChoices[a])
		else
			server_print("%d. %s",a + 1,g_MapChoices[a])
	}
	set_task(0.75,"RemoveFlood",id)
	g_FloodProtect[id] = 1
	return PLUGIN_HANDLED
}

public ShowAllMaps(id) {
	if (g_FloodProtect[id] == 1)
		return PLUGIN_HANDLED
	new Arg[16],MapsNum = MAPS_DISPLAYED
	read_argv(1,Arg,15) 
	new Line = str_to_num(Arg),MaxLines,MaxLines2 = MAP_LIMIT,MaxLines3
	new a = 0
	while (a < (MaxLines2 - 1)) {
		if (!equal(g_MapName[a],""))
			MaxLines3++
		a++
	}
	Line = Line - 1
	if (Line < 0 || Line >= MaxLines3)
		Line = 0
	MaxLines = Line + MapsNum
	if (MaxLines > MaxLines3)
		MaxLines = MaxLines3
	if (id != 0)
		console_print(id,"[Crab's Map Manager] Listing Maps (%d to %d): total of %d found.",Line + 1,MaxLines,MaxLines3)
	else
		server_print("[Crab's Map Manager] Listing Maps (%d to %d): total of %d found.",Line + 1,MaxLines,MaxLines3)
	while (Line < MaxLines) {
		if (!equal(g_MapName[Line],"")) {
			if (id != 0)
				console_print(id,"%d. %s",Line + 1,g_MapName[Line])
			else
				server_print("%d. %s",Line + 1,g_MapName[Line])
		}
		Line++
	}
	if (MaxLines < MaxLines3) {
		if (id != 0)
			console_print(id,"[Crab's Map Manager] Type ^"amx_showallmaps %d^" for next results.",MaxLines)
		else
			server_print("[Crab's Map Manager] Type ^"amx_showallmaps %d^" for next results.",MaxLines)
	}
	else {
		if (id != 0)
			console_print(id,"[Crab's Map Manager] End of listing.")
		else
			server_print("[Crab's Map Manager] End of listing.")
	}
	set_task(0.75,"RemoveFlood",id)
	g_FloodProtect[id] = 1
	return PLUGIN_HANDLED
}

public NominateMap(id) {
	new text[32],name[32],curmap[32]
	read_args(text,32)
	remove_quotes(text)
	get_user_name(id,name,31)
	get_mapname(curmap,31) 
	if (!equal(text,"") && is_map_valid(text)) {
		new a = 0, MapLimit = MAP_LIMIT
		while (a < MapLimit) {
			if (equali(text,g_MapName[a]))
				break
			if (a >= (MapLimit - 1))
				return PLUGIN_CONTINUE
			a++
		}
		if (g_PlayerNom[id] >= MAX_NOMINATIONS) {
			client_print(id,print_chat,"* No more than %d maps can be nominated by each player.",MAX_NOMINATIONS)
			return PLUGIN_CONTINUE
		}
		if (equali(curmap,text)) {
			client_print(id,print_chat,"* The current map can't be nominated.")
			return PLUGIN_CONTINUE
		}
		if (!equal(g_MapNominated[VOTE_LIMIT - 1],"")) {
			client_print(id,print_chat,"* No more nominations can be made until the vote.")
			return PLUGIN_CONTINUE
		}
		for (new i = 0; i < HISTORY_LIMIT; i++) {
			if (equali(g_MapHistName[i],text)) {
				client_print(id,print_chat,"* %s was played recently and can't be nominated.",text)
				return PLUGIN_CONTINUE
			}
		}
		for (new i = 0; i < VOTE_LIMIT; i++) {
			if (equali(g_MapChoices[i],text)) {
				client_print(id,print_chat,"* %s was already nominated.",text)
				return PLUGIN_CONTINUE
			}
		}
		for (new i = 0; i < VOTE_LIMIT; i++) {
			if (equal(g_MapNominated[i],"")) {
				g_MapNominated[i] = text	
				break
			}
		}	
		for (new i = 0; i < VOTE_LIMIT; i++) {
			if (is_map_valid(g_MapNominated[i])) 			
				g_MapChoices[i] = g_MapNominated[i]
		}
		g_PlayerNom[id]++
		client_print(0,print_chat,"* %s has nominated %s.",name,text)
		return PLUGIN_CONTINUE
	}
	return PLUGIN_CONTINUE
}

public SetMapChoices() {
	new MapNameNum[MAP_LIMIT],ValidMaps[MAP_LIMIT][32],ValidMapsNum[MAP_LIMIT]
	new MapCycleRest = MAPCYCLE_RESTRICTION
	if (MapCycleRest != 0) {
		if (get_playersnum() >= get_cvar_num("amx_mapvoteplayers")) {
			g_MapCycleFile = "mapcycle.txt"
			if (g_MapCycleStatus == 1)
				return PLUGIN_CONTINUE
			g_MapCycleStatus = 1
		}
		else {
			g_MapCycleFile = "mapcycle2.txt"
			if (g_MapCycleStatus == 2)
				return PLUGIN_CONTINUE
			g_MapCycleStatus = 2
		}
	}
	else {
		g_MapCycleFile = "mapcycle.txt"
		if (g_MapCycleStatus == 1)
			return PLUGIN_CONTINUE
		g_MapCycleStatus = 1
	}
	new length = 0,Num = 0,CurrentMap[32],rpos = 0
	get_mapname(CurrentMap,31)
	if (file_exists(g_MapCycleFile)) {
		new Text[32],pos = 0
		while ((pos - rpos) < MAP_LIMIT && read_file(g_MapCycleFile,pos,Text,31,length)) {
			g_MapName[pos - rpos] = ""
			new VerifyName[32],VerifyNum[16]
			parse(Text,VerifyName,31,VerifyNum,15)
			if (!equal(VerifyName,";")
				&& !equal(VerifyName,"//")
				&& !equal(VerifyName,"")
				&& is_map_valid(VerifyName)) {
				g_MapName[pos - rpos] = VerifyName
				new Num2 = str_to_num(VerifyNum)
				if (Num2 < 1 || Num2 > MAP_TYPES)
					MapNameNum[pos -rpos] = 1
				else
					MapNameNum[pos -rpos] = Num2
			}
			else {
				rpos++
			}
			pos++
		}
	}
	if (file_exists(g_MapHistFile)) {
		new SameMap
		new a = 0
		while (a < MAP_LIMIT) {
			SameMap = 0
			new pos = 0
			while (pos < HISTORY_LIMIT) {
				read_file(g_MapHistFile,pos,g_MapHistName[pos],31,length)
				new VerifyName[32]
				parse(g_MapHistName[pos],VerifyName,31)
				if (equal(g_MapName[a],VerifyName)) {
					SameMap = 1
					break
				}
				pos++
			}
			if (!is_map_valid(g_MapName[a]) || equal(g_MapName[a],CurrentMap)) {
				SameMap = 1
			}
			new b = 0
			while (b < MAP_LIMIT) {
				if (equal(g_MapName[a],ValidMaps[b])) {
					SameMap = 1
					break
				}
				b++
			}
			if (SameMap == 0) {
				ValidMaps[Num] = g_MapName[a]
				ValidMapsNum[Num] = MapNameNum[a]
				Num++
			}
			a++
		}
	}
	if (Num >= VOTE_LIMIT)
		g_EnoughMaps = 1
	else {
		g_EnoughMaps = 0
		return PLUGIN_CONTINUE
	}
	new ValidMapsTypes[MAP_TYPES][MAP_LIMIT],ValidMapsTypes2[MAP_TYPES]
	for (new a = 0; a < MAP_TYPES; a++) {
		new MapCount = 0
		for (new b = 0; b < MAP_LIMIT; b++) {
			if (ValidMapsNum[b] == a + 1) {
				ValidMapsTypes[a][MapCount] = b
				MapCount++
			}
		}
		ValidMapsTypes2[a] = MapCount
	}
	new RanNum,Num3 = 0
	for (new a = 0; a < VOTE_LIMIT; a++) {
		while (ValidMapsTypes2[Num3] < 1) {
			Num3++
			if (Num3 > MAP_TYPES - 1)
				Num3 = 0
		}
		RanNum = random_num(0,ValidMapsTypes2[Num3] - 1)
		new d = ValidMapsTypes[Num3][RanNum]
		g_MapChoices[a] = ValidMaps[d]
		for (new c = (RanNum + 1); c < ValidMapsTypes2[Num3]; c++) {
			ValidMapsTypes[Num3][RanNum] = ValidMapsTypes[Num3][c]
		}
		ValidMapsTypes2[Num3]--
		if (Num3 >= MAP_TYPES - 1)
			Num3 = 0
		else
			Num3++
	}
	if (g_ExtendStatus > 0)
		format(g_MapChoices[VOTE_LIMIT],31,"extend %s",CurrentMap)
	else
		format(g_MapChoices[VOTE_LIMIT],31,"")
	return PLUGIN_CONTINUE
}

public client_putinserver(id) {
	g_PlayerNom[id] = 0
	new userid[1]
	userid[0] = id
	set_task(20.0,"NominateMessage",id,userid,1)
	return PLUGIN_CONTINUE
}

public NominateMessage(userid[]) {
	new PlayerID = userid[0]
	client_print(PlayerID,print_chat,"* Type a map's name to nominate it for map voting.")
	return PLUGIN_HANDLED
}

public AdminChange(id,level,cid) {
	if (!cmd_access(id,level,cid,3))
		return PLUGIN_HANDLED
	if (g_VoteNum != 0) {
		if (id != 0)
			console_print(id,"[Crab's Map Manager] The map vote has already begun.")
		else
			server_print("[Crab's Map Manager] The map vote has already begun.")
		return PLUGIN_HANDLED
	}
	new Arg[2],MapName[32]
	read_argv(1,Arg,1)
	read_argv(2,MapName,31)
	new Num = str_to_num(Arg)
	if (Num <= VOTE_LIMIT) {
		if (is_map_valid(MapName)) {
			g_MapChoices[Num - 1] = MapName
			if (id != 0)
				console_print(id,"[Crab's Map Manager] Map option #%d has been changed to %s.",Num,MapName)
			else
				server_print("[Crab's Map Manager] Map option #%d has been changed to %s.",Num,MapName)
		}
		else {
			if (id != 0)
				console_print(id,"[Crab's Map Manager] Invalid map name.")
			else
				server_print("[Crab's Map Manager] Invalid map name.")
		}
	}
	else {
		if (id != 0)
			console_print(id,"[Crab's Map Manager] There is no map option #%d.",Num)
		else
			server_print("[Crab's Map Manager] There is no map option #%d.",Num)
	}
	return PLUGIN_HANDLED
}

public AdminStartVote(id,level,cid) {
	if (!cmd_access(id,level,cid,1))
		return PLUGIN_HANDLED
	if (!equal(g_MapChoices[0],"") && !g_VoteStarted) {
		if (g_EnoughMaps == 0) {
			console_print(id,"[Crab's Map Manager] There are not enough valid maps for a vote.")
			return PLUGIN_HANDLED
		}
		g_VoteStarted = 1
		if (g_ExtendStatus == MAP_EXTEND)
			g_TimeLimit = get_cvar_num("mp_timelimit")
		server_cmd("mp_timelimit 0")
		SetMapChoices()
		set_task(float(VOTE_DELAY),"BeginVote")
	}
	return PLUGIN_HANDLED
}

public BeginVote() {
	for (new a = 0; a < (VOTE_LIMIT + 1); a++) {
		g_VoteCast[a] = 0
	}
	g_VoteCast2[0] = 0,g_VoteCast2[1] = 0
	set_cvar_float("amx_last_voting", get_gametime() + get_cvar_float("amx_vote_time") + 5.0)
	if (g_MapPlayed == 1) {
		g_MapPlayed = 2
		new CurrentMap[32]
		get_mapname(CurrentMap,31)
		if (file_exists(g_MapHistFile)) {
			new text[32],length = 0,pos = 0
			while (pos < HISTORY_LIMIT) {
				read_file(g_MapHistFile,pos + 1,text,31,length)
				write_file(g_MapHistFile,text,pos)
				pos++
			}
		}
		write_file(g_MapHistFile,CurrentMap,HISTORY_LIMIT - 1)
	}
	client_cmd(0,"spk buttons/bell1")
	new MenuText[256],keys
	MenuText = "Nextmap vote (Take 1):^n"
	if (g_ExtendStatus > 0) {
		for (new a = 0; a < (VOTE_LIMIT + 1); a++) {
			format(MenuText,255,"%s%d. %s^n",MenuText,(a + 1),g_MapChoices[a])
		}
		keys = (-1^(-1<<(VOTE_LIMIT + 1)))
	}
	else {
		for (new a = 0; a < VOTE_LIMIT; a++) {
			format(MenuText,255,"%s%d. %s^n",MenuText,(a + 1),g_MapChoices[a])
		}
		keys = (-1^(-1<<(VOTE_LIMIT)))
	}
	show_menu(0,keys,MenuText,get_cvar_num("amx_vote_time"))
	g_VoteTime = get_cvar_num("amx_vote_time")
	new ShowResults = SHOW_RESULTS,MenuText2[256]
	if (ShowResults == 0) {
		g_VoteNum = 1
		MenuText2 = "Map vote options (Take 1):^n"
		if (g_ExtendStatus > 0) {
			for (new a = 0; a < (VOTE_LIMIT + 1); a++) {
				format(MenuText2,255,"%s%d. %s^n",MenuText2,(a + 1),g_MapChoices[a])
			}
		}
		else {
			for (new a = 0; a < VOTE_LIMIT; a++) {
				format(MenuText2,255,"%s%d. %s^n",MenuText2,(a + 1),g_MapChoices[a])
			}
		}
	}
	else {
		g_VoteNum = 1
		MenuText2 = "Map vote results (Take 1):^n"
		if (g_ExtendStatus > 0) {
			for (new a = 0; a < (VOTE_LIMIT + 1); a++) {
				format(MenuText2,255,"%s%d. %s (0)^n",MenuText2,(a + 1),g_MapChoices[a])
			}
		}
		else {
			for (new a = 0; a < VOTE_LIMIT; a++) {
				format(MenuText2,255,"%s%d. %s (0)^n",MenuText2,(a + 1),g_MapChoices[a])
			}
		}
	}
	format(MenuText2,255,"%s^n^nVote timeleft: %d",MenuText2,g_VoteTime)
	set_hudmessage(200,200,255,0.55,0.15,0,0.02,(get_cvar_float("amx_vote_time") * 2) + 5.0,0.01,0.1,DISPLAY_HUD_CHANNEL)
	show_hudmessage(0,MenuText2)
	set_task(1.0,"DisplayHud",16549709,"",0,"b")
	set_task(get_cvar_float("amx_vote_time"),"CountVotes",16549707)
	return PLUGIN_HANDLED
}

public FirstVote(id,key) {
	if (get_cvar_num("amx_vote_answers")) { 
		new name[32]
		get_user_name(id,name,31)
		client_print(0,print_chat,"* %s voted for %s",name,g_MapChoices[key])
	}
	if (get_user_flags(id) & ACCESS_LEVEL)
		g_VoteCast[key] = g_VoteCast[key] + VOTE_AMOUNT
	else
		g_VoteCast[key]++
	console_print(id,"[Crab's Map Manager] Take 1: you voted for %s.",g_MapChoices[key])
	return PLUGIN_HANDLED
}

public CountVotes() {
	new MapRank[VOTE_LIMIT + 1],MaxVotes = VOTE_LIMIT,taken1 = 0,taken2 = 0
	if (g_ExtendStatus > 0) {
		for (new a = 0; a < (VOTE_LIMIT + 1); a++) {
			new rank = 1
			for (new b = 0; b < (VOTE_LIMIT + 1); b++) {
				if (a != b) {
					if (g_VoteCast[a] < g_VoteCast[b])
						rank++
				}
			}
			MapRank[a] = rank
		}
	}
	else {
		for (new a = 0; a < (VOTE_LIMIT); a++) {
			new rank = 1
			for (new b = 0; b < (VOTE_LIMIT); b++) {
				if (a != b) {
					if (g_VoteCast[a] < g_VoteCast[b])
						rank++
				}
			}
			MapRank[a] = rank
		}
	}
	if (g_ExtendStatus > 0) {
		if ((MaxVotes + 1) > 2) {
			for (new a = 0; a < (VOTE_LIMIT + 1); a++) {
				if (MapRank[a] == 1) {
					if (taken1 == 0) {
						g_WinningMaps[0] = g_MapChoices[a]
						taken1 = 1
					}
					else {
						g_WinningMaps[1] = g_MapChoices[a]
					}
				}
				if (MapRank[a] == 2) {
					if (taken2 == 0) {
						g_WinningMaps[1] = g_MapChoices[a]
						taken2 = 1
					}
				}
			}
			EndVote()
		}
		else if ((MaxVotes + 1) == 2) {
			if (g_VoteCast[0] > g_VoteCast[1]) {
				g_NextMapName = g_MapChoices[0]
				client_print(0,print_chat,"* The next map will be %s",g_MapChoices[0])
			}
			else if (g_VoteCast[0] < g_VoteCast[1]) {
				g_NextMapName = g_MapChoices[1]
				client_print(0,print_chat,"* The next map will be %s",g_MapChoices[1])
			}
			else if (g_VoteCast[0] == g_VoteCast[1]) {
				new num = random_num(0,1)
				g_NextMapName = g_MapChoices[num]
				client_print(0,print_chat,"* The next map will be %s",g_MapChoices[num])
			}
		}
	}
	else {
		if (MaxVotes > 2) {
			for (new a = 0; a < (VOTE_LIMIT); a++) {
				if (MapRank[a] == 1) {
					if (taken1 == 0) {
						g_WinningMaps[0] = g_MapChoices[a]
						taken1 = 1
					}
					else {
						g_WinningMaps[1] = g_MapChoices[a]
					}
				}
				if (MapRank[a] == 2) {
					if (taken2 == 0) {
						g_WinningMaps[1] = g_MapChoices[a]
						taken2 = 1
					}
				}
			}
			EndVote()
		}
		else if (MaxVotes == 2) {
			if (g_VoteCast[0] > g_VoteCast[1]) {
				g_NextMapName = g_MapChoices[0]
				client_print(0,print_chat,"* The next map will be %s",g_MapChoices[0])
			}
			else if (g_VoteCast[0] < g_VoteCast[1]) {
				g_NextMapName = g_MapChoices[1]
				client_print(0,print_chat,"* The next map will be %s",g_MapChoices[1])
			}
			else if (g_VoteCast[0] == g_VoteCast[1]) {
				new num = random_num(0,1)
				g_NextMapName = g_MapChoices[num]
				client_print(0,print_chat,"* The next map will be %s",g_MapChoices[num])
			}
		}
	}
	return PLUGIN_CONTINUE
}

public EndVote() {
	set_cvar_float("amx_last_voting",get_gametime() + get_cvar_float("amx_vote_time") + 5.0)
	client_cmd(0,"spk buttons/bell1")
	new MenuText[256]
	MenuText = "Nextmap vote (Take 2):^n"
	format(MenuText,255,"%s1. %s^n2. %s^n",MenuText,g_WinningMaps[0],g_WinningMaps[1])
	new keys = (1<<0)|(1<<1)
	show_menu(0,keys,MenuText,get_cvar_num("amx_vote_time"))
	g_VoteTime = get_cvar_num("amx_vote_time")
	new ShowResults = SHOW_RESULTS
	if (ShowResults == 0) {
		g_VoteNum = 2
		new MenuText2[256]
		MenuText2 = "Map vote results (Take 2):^n"
		format(MenuText2,255,"%s1. %s^n2. %s^n",MenuText2,g_WinningMaps[0],g_WinningMaps[1])
		format(MenuText2,255,"%s^n^nVote timeleft: %d",MenuText2,g_VoteTime)
		set_hudmessage(200,200,255,0.55,0.15,0,0.02,(get_cvar_float("amx_vote_time") * 2) + 5.0,0.01,0.1,DISPLAY_HUD_CHANNEL)
		show_hudmessage(0,MenuText2)
	}
	else {
		g_VoteNum = 2
		new MenuText2[256]
		MenuText2 = "Map vote results (Take 2):^n"
		format(MenuText2,255,"%s1. %s (0)^n2. %s (0)^n",MenuText2,g_WinningMaps[0],g_WinningMaps[1])
		format(MenuText2,255,"%s^n^nVote timeleft: %d",MenuText2,g_VoteTime)
		set_hudmessage(200,200,255,0.55,0.15,0,0.02,(get_cvar_float("amx_vote_time") * 2) + 5.0,0.01,0.1,DISPLAY_HUD_CHANNEL)
		show_hudmessage(0,MenuText2)
	}
	set_task(get_cvar_float("amx_vote_time"),"CountVotes2",16549708)
	set_task(get_cvar_float("amx_vote_time") + 4.0,"ChangeMap",16549706)
	return PLUGIN_CONTINUE
}

public SecondVote(id,key) {
	if (get_cvar_num("amx_vote_answers")) {
		new name[32]
		get_user_name(id,name,31)
		client_print(0,print_chat,"* %s voted for %s",name,g_WinningMaps[key])
	}
	if (get_user_flags(id) & ACCESS_LEVEL)
		g_VoteCast2[key] = g_VoteCast2[key] + VOTE_AMOUNT
	else
		g_VoteCast2[key]++
	console_print(id,"[Crab's Map Manager] Take 2: you voted for %s.",g_WinningMaps[key])
	return PLUGIN_HANDLED
}

public CountVotes2() {
	new CurrentMap[32],TempName[32]
	get_mapname(CurrentMap,31)
	format(TempName,31,"extend %s",CurrentMap)
	if (g_VoteCast2[0] > g_VoteCast2[1]) {
		if (equal(TempName,g_WinningMaps[0])) {
			g_NextMapName = CurrentMap
			g_Extend = 1
			g_ExtendStatus--
			g_VoteNum = 0
			for (new a = 0; a < 33; a++)
				g_PlayerNom[a] = 0
			for (new a = 0; a < VOTE_LIMIT; a++)
				g_MapNominated[a] = ""
			client_print(0,print_chat,"* This map will be extended for %d minutes",g_TimeLimit)
		}
		else {
			g_NextMapName = g_WinningMaps[0]
			client_print(0,print_chat,"* The next map will be %s",g_WinningMaps[0])
		}
	}
	else if (g_VoteCast2[0] < g_VoteCast2[1]) {
		if (equal(TempName,g_WinningMaps[1])) {
			g_NextMapName = CurrentMap
			g_Extend = 1
			g_ExtendStatus--
			g_VoteNum = 0
			for (new a = 0; a < 33; a++)
				g_PlayerNom[a] = 0
			for (new a = 0; a < VOTE_LIMIT; a++)
				g_MapNominated[a] = ""
			client_print(0,print_chat,"* This map will be extended for %d minutes",g_TimeLimit)
		}
		else {
			g_NextMapName = g_WinningMaps[1]
			client_print(0,print_chat,"* The next map will be %s",g_WinningMaps[1])
		}
	}
	else if (g_VoteCast2[0] == g_VoteCast2[1]) {
		new num = random_num(0,1)
		if (equal(TempName,g_WinningMaps[num])) {
			g_NextMapName = CurrentMap
			g_Extend = 1
			g_ExtendStatus--
			g_VoteNum = 0
			for (new a = 0; a < 33; a++)
				g_PlayerNom[a] = 0
			for (new a = 0; a < VOTE_LIMIT; a++)
				g_MapNominated[a] = ""
			client_print(0,print_chat,"* This map will be extended for %d minutes",g_TimeLimit)
		}
		else {
			g_NextMapName = g_WinningMaps[num]
			client_print(0,print_chat,"* The next map will be %s",g_WinningMaps[num])
		}
	}
	g_VoteStarted = 0
	g_MapCycleStatus = 0
	return PLUGIN_CONTINUE
}

public RemoveFlood(id) {
	if (task_exists(id))
		remove_task(id)
	g_FloodProtect[id] = 0
	return PLUGIN_CONTINUE
}
