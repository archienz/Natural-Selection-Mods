
/***************************************************************************
 * amx_ejl_nukem.sma     beta version 1.4  (11/17/02) Date: 2/13/2003
 *  Author: Eric Lidman      ejlmozart@hotmail.com
 *  Alias: Ludwig van        Upgrade: http://lidmanmusic.com/cs/plugins.html           
 *  Edited by Sandman[SA]    08/27/05
 *
 * COMMANDS:
 * 
 *    amx_nukem
 *    amx_nukem_jk
 *
 *  amx_nukem is a slayall command that calls on lots of special effects in
 *   in the process. amx_nukem_jk is the "just kidding" version of the nuke.
 *   Its non-lethal, and just does the explosions and FX which includes 2 
 *   screen shakes, howling people suffereing, and a whole lot of fire and
 *   explosions.
 *
 * KNOWN ISSUES:
 *
 *  It does have a tendency to cause some clients to disconnect, I want you 
 *   to know that. In my tests, it seems to be only clients with D3D video 
 *   mode, but OPEN GL is safe for clients. I figure thats OK though, I 
 *   mean its a nuke! Were not kidding around here! This is some power! 
 *   However, if there are some experienced and knowledgeable people who can 
 *   make better use of stuff from the Half-Life SDK, I am certainly open 
 *   to changing this plugin to be more client friendly, and yet still 
 *   maintain its awesomeness. Contact me: ejlmozart@hotmail.com 
 *   On the other hand, its not a command you would use frequently I hope, 
 *   so the issues are not that much of an issue. I still wouldnt mind 
 *   learning to use the SDK better though. 
 *
 *   Thanks to f117bomb for help with the effects such as shake and flash
 *
 **************************************************************************/
	
#include <amxmodx>
#include <amxmisc>

new BOMB_FUSE = 15        // fuse time - 10

new gmsgShake
new gmsgFade
new fire1
new fire2
new white 
new fire
new bool:bIsNuking = false
new bool:lethal = true
new nuke_tmr
new immune
new tscore[3] 
new tteamid[33] 
new tfrags[33] 
new tclass[33] 
new tdeaths[33] 
new gmsgScoreInfo 

explode(vec1[3]){ 
   // blast circles 
   message_begin( MSG_BROADCAST,SVC_TEMPENTITY,vec1) 
   write_byte( 21 ) 
   write_coord(vec1[0]) 
   write_coord(vec1[1]) 
   write_coord(vec1[2] + 16) 
   write_coord(vec1[0]) 
   write_coord(vec1[1]) 
   write_coord(vec1[2] + 1936) 
   write_short( white ) 
   write_byte( 0 ) // startframe 
   write_byte( 0 ) // framerate 
   write_byte( 2 ) // life 2
   write_byte( 128 ) // width 16 
   write_byte( 0 ) // noise 
   write_byte( 255 ) // r 
   write_byte( 255 ) // g 
   write_byte( 255 ) // b 
   write_byte( 255 ) //brightness 
   write_byte( 0 ) // speed 
   message_end() 

   //Explosion2 
   message_begin( MSG_BROADCAST,SVC_TEMPENTITY) 
   write_byte( 12 ) 
   write_coord(vec1[0]) 
   write_coord(vec1[1]) 
   write_coord(vec1[2])
   write_byte( 188 ) // byte (scale in 0.1's) 188 
   write_byte( 10 ) // byte (framerate) 
   message_end() 
    
   //TE_Explosion 
   message_begin( MSG_BROADCAST,SVC_TEMPENTITY,vec1) 
   write_byte( 3 ) 
   write_coord(vec1[0]) 
   write_coord(vec1[1]) 
   write_coord(vec1[2])
   write_short( fire ) 
   write_byte( 188 ) // byte (scale in 0.1's) 188 
   write_byte( 10 ) // byte (framerate) 
   write_byte( 0 ) // byte flags 
   message_end() 
} 

explodeall(vec1[3]){ 
   // blast circles 
   message_begin( MSG_BROADCAST,SVC_TEMPENTITY,vec1) 
   write_byte( 21 ) 
   write_coord(vec1[0]) 
   write_coord(vec1[1]) 
   write_coord(vec1[2] + 16) 
   write_coord(vec1[0]) 
   write_coord(vec1[1]) 
   write_coord(vec1[2] + 1936) 
   write_short( fire2 ) 
   write_byte( 0 ) // startframe 
   write_byte( 0 ) // framerate 
   write_byte( 24 ) // life 2
   write_byte( 128 ) // width 16 
   write_byte( 0 ) // noise 
   write_byte( 188 ) // r 
   write_byte( 220 ) // g 
   write_byte( 255 ) // b 
   write_byte( 255 ) //brightness 
   write_byte( 0 ) // speed 
   message_end() 
    
   //TE_Explosion 
   message_begin( MSG_BROADCAST,SVC_TEMPENTITY,vec1) 
   write_byte( 3 ) 
   write_coord(vec1[0]) 
   write_coord(vec1[1]) 
   write_coord(vec1[2])
   write_short( fire1 ) 
   write_byte( 188 ) // byte (scale in 0.1's) 188 
   write_byte( 10 ) // byte (framerate) 
   write_byte( 0 ) // byte flags 
   message_end() 
}

public roundend_cleanup(){
	if(bIsNuking == true){
		blowem_up()
	}
}

public admin_nukem(id,level,cid){
	if (!cmd_access(id,level,cid,1))
		return PLUGIN_HANDLED
	if(bIsNuking == true){
		client_print(id,print_console,"[AMX] The nuke is already in progress")
		return PLUGIN_HANDLED
	}
	new cmd[32]
	read_argv(0,cmd,32)	
	if(equal (cmd[10], "j",1))
		lethal = false
	else
		lethal = true		

	new name[32]
	get_user_name(id,name,32)
	client_cmd(0,"spk ^"vox/alert _comma _comma atomic weapon detected^"")	
	client_print(0,print_chat,"[AMX] :  %s has launched the NUKE, were all gonna die!!!", name)
	immune = id

	new authid[16]
	get_user_authid(id,authid,16)
	log_message("NUKEM - %s<%d><%s><> - NUKEM", name,get_user_userid(id),authid) 


	bIsNuking = true
	nuke_tmr = BOMB_FUSE
	
	if ( gmsgShake == 0 )
		gmsgShake = get_user_msgid("ScreenShake") 
		
	if ( gmsgFade == 0 )	
		gmsgFade = get_user_msgid("ScreenFade")	
		
	set_task( 1.0, "nuke_timer", 108, "", 0, "a", BOMB_FUSE )
	
	return PLUGIN_HANDLED
}

public nuke_timer(){
	if(bIsNuking == false){
		return PLUGIN_HANDLED
	}
	new maxpl = get_maxplayers()+1
	new players[32], inum
	nuke_tmr -=1

	if (nuke_tmr > 0){
		if( (nuke_tmr > 5) && (nuke_tmr < 11) ){
			set_hudmessage(200,0,0, 0.03, 0.76, 2, 0.02, 1.0, 0.01, 0.1, 2)
			show_hudmessage(0,"The world will explode in %d seconds.",nuke_tmr - 5)
		}
		if(nuke_tmr == 12){
			client_cmd(0, "spk ^"ambience/jetflyby1^"")
		}
		if(nuke_tmr == 11){
			client_cmd(0,"spk ^"fvox/range^"")	
		}
		if( (nuke_tmr < 11) && (nuke_tmr > 5) ){
			new temp[48]
			num_to_word(nuke_tmr-5,temp,48)
			client_cmd(0,"spk ^"fvox/%s^"",temp)
		}
		if( nuke_tmr == 5){
			client_cmd(0, "spk ^"ambience/the_horror1^"")
			get_players(players,inum,"ac")
			for(new i = 0 ;i < inum; ++i){
				message_begin(MSG_ONE,gmsgFade,{0,0,0},players[i]) // use the magic #1 for "one client" 
				write_short( 1<<11 ) // fade lasts this long furation 
				write_short( 1<<11 ) // fade lasts this long hold time 
				write_short( 1<<12 ) // fade type (in / out) 
				write_byte( 250 ) // fade red 
				write_byte( 250 ) // fade green 
				write_byte( 250 ) // fade blue 
				write_byte( 255 ) // fade alpha 
				message_end()
			}
			new origin[3]
			explodeall(origin)
		}
		if(nuke_tmr < 5){
			get_players(players,inum,"ac")
			client_cmd(0, "spk ^"ambience/the_horror%d^"",nuke_tmr)
			if(inum < 1){
				blowem_up()
				return PLUGIN_HANDLED
			}else{
				new origin[3]
				if(nuke_tmr == 4){
					get_players(players,inum,"c")
					for(new i = 0 ;i < inum; ++i){
						message_begin(MSG_ONE,gmsgShake,{0,0,0},players[i]) 
						write_short( 1<<14 )// shake amount
						write_short( 1<<14 )// shake lasts this long
						write_short( 1<<14 )// shake noise frequency
						message_end()
					}
					explodeall(origin)
				}else{
					new rorigin[3],sb
					for(new i = 1 ;i < 50; ++i){
						rorigin[0] = random(3000)
						rorigin[1] = random(3000)
						rorigin[2] = random(2000)
						sb = random(2)
						if(sb == 0)
							rorigin[0] = rorigin[0] * -1
						sb = random(2)
						if(sb == 0)
							rorigin[1] = rorigin[1] * -1
						sb = random(2)
						if(sb == 0)
							rorigin[2] = rorigin[2] * -1
						explodeall(rorigin)
					}
				}
				for(new i = 1 ;i < maxpl; ++i){
					new rndkill = random(9)
					if(rndkill == 0){
						if(lethal == true){
							if(i != immune){
								user_kill(i,1)
							}
						}
						get_user_origin(i,origin)
						origin[2] = origin[2] - 26  
						explode(origin)
					}
				}
			}
		}
		if(nuke_tmr == 2){
			get_players(players,inum,"c")
			for(new i = 0 ;i < inum; ++i){
				message_begin(MSG_ONE,gmsgShake,{0,0,0},players[i]) 
				write_short( 1<<14 )// shake amount
				write_short( 1<<14 )// shake lasts this long
				write_short( 1<<14 )// shake noise frequency
				message_end()
			}
		}
	}else{
		blowem_up()
	}
	return PLUGIN_CONTINUE
}

public blowem_up(){

	bIsNuking = false
	nuke_tmr = 0

	set_hudmessage(255,50,50, -1.0, 0.50, 2, 0.02, 4.0, 0.01, 0.1, 2)
	if(lethal == true)
		show_hudmessage(0,"The world has exploded.")
	else
		show_hudmessage(0,"HAHAHAHA -- Just kidding. That wasnt a real NUKE.")

	new origin[3]	
	new maxpl = get_maxplayers() +1
	for(new a=1; a<=maxpl; a++){
		if(is_user_connected(a) == 1){
			get_user_origin(a,origin)
			origin[2] = origin[2] - 26  
			explode(origin)
			if(lethal == true){
				if(a != immune){
					user_kill(a,1)
				}
			}
		}
	}
	return PLUGIN_HANDLED
}

send_own_score(id) { 
	new mode[8] 
	get_cvar_string("amx_ownscore_mode",mode,8) 
	new rules = read_flags(mode) 
	if (rules & 1) return /* do no changes */ 
	message_begin(MSG_ALL, gmsgScoreInfo) 
	write_byte(id) 
	write_short( (rules&2) ? tscore[tteamid[id]] : tfrags[id] ) 
	write_short( (rules&4) ? 0 : tdeaths[id] ) 
	write_short( tclass[id] ) 
	write_short( tteamid[id] ) 
	message_end() 
} 

public scoreinfo_event() { 
	new id = read_data(1) /* about who is this score */ 
	tfrags[id] = read_data(2) 
	tdeaths[id] = read_data(3) 
	tclass[id] = read_data(4) /* in CS there is no classes - this is always 0 */ 
	tteamid[id] = read_data(5) 
	send_own_score(id) 
} 

public plugin_precache(){ 
   white = precache_model("sprites/white.spr")
   fire = precache_model("sprites/explode1.spr")
   fire1 = precache_model("sprites/hexplo.spr")
   fire2 = precache_model("sprites/fire.spr")
   return PLUGIN_CONTINUE 
}

public plugin_init(){
	register_plugin("Nukem","1.0","Sandman[SA]")
	register_concmd("amx_nukem","admin_nukem",ADMIN_LEVEL_A,": blows everyone up except you in a firestorm of explosions")
	register_concmd("amx_nukem_jk","admin_nukem",ADMIN_LEVEL_A,": does the nukem count down and FX, but doesnt kill anyone")

	gmsgShake = get_user_msgid("ScreenShake") 
	gmsgFade = get_user_msgid("ScreenFade")

//	register_event("ScoreInfo","scoreinfo_event","a") 
	gmsgScoreInfo = get_user_msgid("ScoreInfo") 

	// set_task(1.0,"nuke_timer",646,"",0,"a", 9999)
	return PLUGIN_CONTINUE
}

