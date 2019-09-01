/*
About:
This plugin is designed to making scripts in TS harder to make and less effective. It will NOT competly block
"cheat" script nor prevent them from working. For that to happen it requires a client side part period.
The way this plugin works is by either "locking" cvars ( Yes, i know this can be countered, but now at least they can 
change the cvar more then once). It can also block keyboard viewing commands and so called "dobble fire" where both
+attack and +attack2 is used at once (When a player does this, only the first attack is vaild, (If both where pressed at the same exact time
then only +attack happens.) But remember the client prediction code will still show a client side effect)

Forum thread: http://www.amxmodx.org/forums/viewtopic.php?p=67175

FAQ
Q) What sort of issues will blocking keyboard movement make?
A) If someone uses the keyboard to look with ( basicly bind a +left, instead of the normal bind a +stafeleft) they will not be albe to do this.
Personaly i dont think anyone still uses the keyboard to look with, and blocking these commands is proberbly most effective against scripts

Q) What sort of issues will blocking cvars make?
A) None i can think off unless they using keyboard to look with. And need to change the cvar often(Witch in effect would be like changing the sensitivity cvar while playing)

Q) What sort of isses will blocking "dual attack" make?
A) Blocking this might piss alot of ppl off, but other then that.

Q) XXXX is in the logs and tried to do XXXX, should i ban him?
A) Thats your choice, but remember that the client tried to change cl_pitchspeed, could be something as stupid has him having cl_pitchspeed X in his config.cfg ( For some reason )

Q) My logs get spammed by XX used XXX like 100 times
A) The logs are writen for every time the user is doing it, that means if i do +left in the console. And the server is running at 100fps this it gets logged 100times a sec

Q) Why does ppl that use +left / +right get slaped?
A) Since there is not simple way to block the effect, we instead have to slap the user. So stop the players from abusing it, they get slapped with damange

Q) Does this plugin use alot of CPU?
A) No.

Q) Cant you just block scripts that include +attack?
A) no, not without a client side modifikation.

Q) I found a script that this plugin does not "block" can you please update the plugin?
A) I might, if you pm the script to me via either the TS boards or AMXX boards ( My name on them is EKS )

Installing the plugin:
1)Install the plugin like any other
2)Make sure the engine module is running
3)add sv_scriptblock / sv_script to amxx.cfg ( Remember cvars will only be checked on map restart)

sv_script 3 		// 0 = Loging and echo disabled | 1 = Logs when someone is doing something restriced by the plugin | 2 = Echos when someone is doing something thats restriced | 3 = echo and log
sv_scriptblock 15

// Add the vaules together. (everything is 15 )
1 = Block keyboard looking 				// This is by far the thing thats gonna mess up most scripts
2 = Block holding both attack1 and 2	// Blocking players +attack and +attack2 at the same time
4 = Block cvars ( cl_yawspeed / cl_pitchspeed) // These cvars are used to control the speed of keyboard looking
8 = Punish players using +left +right ( Since the plugin does not have a way to block the effect, we just slap the user instead)

Credits:
Twilight Suzuka <-> For example scripts & help
Ops in #AMXmod @ Quakenet for alot of help ( + AssKicker & CheesyPeteza ) 

Changelog
 1.0.0 (16.10-2004)
 	- First version

*/

#include <amxmodx>
#include <engine>

/*
mangler
+lookup
+lookdown
cl_lw
fov 10
*/

#define PLAYER_ATTACK 1			// Player is holding down the attack button
#define PLAYER_JUMP 2			// Player is holding down the jump button
#define PLAYER_DUCK 4			// Player is holding down the duck button
#define PLAYER_FORWARD 8		// Player is holding down the walk forward button
#define PLAYER_BACK 16			// Player is holdign down the back button
#define PLAYER_LEFT 128			// Player is holdign down the left  button
#define PLAYER_RIGHT 256		// Player is holdign down the right button
#define PLAYER_STRAFELEFT 512	// Player is holdign down the strafe left button
#define PLAYER_STRAFERIGHT 1024	// Player is holdign down the strafe right button
#define PLAYER_ATTACK2 2048		// Player is holdign down the attack2 button

#define BlockMovment 1
#define BlockDubbleAttack 2
#define BlockCVARS 4
#define PunsihPlayer 8

#define LogBeforeWrite 128
#define MAXPLAYERS 32

//new g_Users[MAXPLAYERS+1]
new g_Action2Block					// Used to save the save the vault of the sv_scriptblock cvar
new g_LastAttack[MAXPLAYERS+1]		// Used to save what the first attack was ( if it was +attack or +attack2 )
new gs_clcmd[3][24]					// Used save the client cmds sendt to overwrite the  cl_yawspeed / cl_pitchspeed  cvars
new gs_Log[LogBeforeWrite+1][256]
new g_LogsWriten
new gs_LogFile[64]
new gs_MapName[32]
new g_BlockCheck[MAXPLAYERS+1]	// When the plugin tries to alisa over the cvars it also tries to give them a new value, to make sure the client does trigger a false "detection" their marked to be ignored for a few sec
new g_EchoOrLog

public plugin_init() 
{ 
	register_plugin("TS Script block","1.0.0","EKS")
	register_cvar("sv_scriptblock","15")
	register_cvar("sv_scriptlog","3")
	
	get_mapname(gs_MapName,31)
	get_localinfo("amxx_basedir",gs_LogFile,63)
	format(gs_LogFile,63,"%s/logs/ts_scriptblock.log",gs_LogFile)
	
	format(gs_clcmd[0],23,"used_yawspeed%d",random_num(100,50000))
	format(gs_clcmd[1],23,"Used_Pitchspeed%d",random_num(100,50000))
	format(gs_clcmd[2],23,"Used_Fov%d",random_num(100,50000))
	register_clcmd(gs_clcmd[0],"Used_Yawspeed",0,"- DONT USE THIS COMMAND")
	register_clcmd(gs_clcmd[1],"Used_Pitchspeed",0,"- DONT USE THIS COMMAND")
	register_clcmd(gs_clcmd[2],"Used_Fov",0,"- DONT USE THIS COMMAND")
}

public client_connect(id) if(g_Action2Block & BlockCVARS) BlockAliasOnClient(id)
public plugin_cfg()
{
	g_EchoOrLog = get_cvar_num("sv_scriptlog")
	g_Action2Block = get_cvar_num("sv_scriptblock")
}

stock BlockAliasOnClient(id)
{
	g_BlockCheck[id] = 1
	client_cmd(id,"cl_yawspeed 1;alias cl_yawspeed %s",gs_clcmd[0])
	client_cmd(id,"cl_pitchspeed 1;alias cl_pitchspeed %s",gs_clcmd[1])
	client_cmd(id,"alias fov %s",gs_clcmd[2])
	g_BlockCheck[id] = 0
}
public Used_Fov(id)
{
	if(g_BlockCheck[id] == 1) return PLUGIN_CONTINUE

	EchoAbuse(id,"has tried to change fov")
	Write2Log(id,"has tried to change fov")
	return PLUGIN_HANDLED
}
public Used_Pitchspeed(id)
{
	if(g_BlockCheck[id] == 1) return PLUGIN_CONTINUE

	EchoAbuse(id,"has tried to change cl_pitchspeed")
	Write2Log(id,"has tried to change cl_pitchspeed")
	return PLUGIN_HANDLED
}

public Used_Yawspeed(id)
{
	if(g_BlockCheck[id] == 1) return PLUGIN_CONTINUE

	EchoAbuse(id,"has tried to change cl_yawspeed")
	Write2Log(id,"has tried to change cl_yawspeed")
	return PLUGIN_HANDLED
}

public client_PreThink(id)
{
	if(!is_user_alive(id)) return PLUGIN_CONTINUE
	
	new flags = entity_get_int(id,EV_INT_button)
	
	if(g_Action2Block & BlockMovment) // Checks if the player is using keyboard based movement keys
	{
		if(flags & PLAYER_LEFT)
		{
			PunishUser(id)
			Write2Log(id,"has used +left")
			EchoAbuse(id,"has used +left")
		}
		else if(flags & PLAYER_RIGHT)
		{
			PunishUser(id)
			Write2Log(id,"has used +right")
			EchoAbuse(id,"has used +right")
		}
	}
	if(g_Action2Block & BlockDubbleAttack) // Checks if the player is using keyboard based movement keys
	{
		if(flags & PLAYER_ATTACK && flags & PLAYER_ATTACK2) // If the user is holding down both attack buttons we remove the last one pressed
		{
			if(g_LastAttack[id] == 0) // This means the player
				entity_set_int(id,EV_INT_button,(flags-PLAYER_ATTACK2))
			else if(g_LastAttack[id] == PLAYER_ATTACK)
			{
				entity_set_int(id,EV_INT_button,(flags-PLAYER_ATTACK2))
				//server_print("Client did attack2 while holding attack")	// debug
			}
			else if(g_LastAttack[id] == PLAYER_ATTACK2)
			{
				entity_set_int(id,EV_INT_button,(flags-PLAYER_ATTACK))
				//server_print("Client did attack while holding attack2")	// debug
			}
		}
		else if(flags & PLAYER_ATTACK || flags & PLAYER_ATTACK2) // used to save
		{
			if(g_LastAttack[id] & PLAYER_ATTACK)
				g_LastAttack[id] = PLAYER_ATTACK
			else 
				g_LastAttack[id] = PLAYER_ATTACK2
		}
		else g_LastAttack[id] = 0 // This means the user is NOT holding down attack so we clear the array holding the last attack
	}
	return PLUGIN_CONTINUE
}

stock PunishUser(id)
{
	if( g_Action2Block & PunsihPlayer) user_kill(id)
}

stock WriteLogs2File()
{
	for(new b=0;b<=g_LogsWriten;b++)
	{
		write_file(gs_LogFile,gs_Log[b],-1)
	}
	g_LogsWriten = 0		
}

public plugin_end()	if(g_LogsWriten !=0) WriteLogs2File()

stock Write2Log(id,Text[256])
{
	if(g_EchoOrLog != 1 && g_EchoOrLog != 3) return PLUGIN_CONTINUE
	
	if(g_LogsWriten == LogBeforeWrite) WriteLogs2File()
	
	new CurrentTime[9],Name[32],Auth[35]
	get_user_name(id,Name,31)
	get_user_authid(id,Auth,35)
		
	get_time("%H:%M:%S",CurrentTime,8)
	
	format(gs_Log[g_LogsWriten],255,"%s (%s) <-> %s<%s> %s",CurrentTime,gs_MapName,Name,Auth,Text)
	g_LogsWriten++
	return PLUGIN_CONTINUE
}
stock EchoAbuse(id,Text[64])
{
	if(g_EchoOrLog != 2 && g_EchoOrLog != 3 || g_BlockCheck[id] ) return PLUGIN_CONTINUE		
	
	new parm[1]
	parm[0] = id
	set_task(2.0,"Task_RemoveBlock",id,parm,1,"a",1)
	g_BlockCheck[id] = 1 // Since a abuser will trigger abouse like 100 times a sec, there is no point in echoing this that often
	
	new Name[32]
	get_user_name(id,Name,31)
	client_print(0,print_chat,"[AMXX] %s %s",Name,Text)
	return PLUGIN_CONTINUE
}

public Task_RemoveBlock(parm[])
{
	g_BlockCheck[parm[0]] = 0
}