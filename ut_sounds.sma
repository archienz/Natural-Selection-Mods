
/*
_________________________________________________________________________________
|Ut_sounds Version 0.8d					|
---------------------------------------------------------------------------------

  Hey dawg, this is meant for Natural Selection. The current version is 3.0 Beta 5
  or something like that. If you want this for another mod, message me. Or go down
  load the original by soul but it doesn't have alot of the stuff in this one.
  Peace, enjoy that unreal skill in old sk00l mods. - Topchris
  PS - Special thanks to Depot and his homie WP and Darkness.
  This version was coded to support MvM by White Panther.
        All defaults are 0
	__________________________
	"amx_victorymode"
	"amx_playmode"
	"amx_excellentmode"
	"amx_expmode"
	All cvars above this line are 0 to enable, 1 to disable.
	All cvars below the line are 0 all, 1 to player only, 2 to disable.
	__________________________
	"amx_humiliationmode"
	"amx_impressivemode"
	"amx_headshotmode"
	"amx_firstbloodmode"
	"amx_multikillmode"
	"amx_killingspreemode"
	"amx_llamamode"
	__________________________

---------------------------------------------------------------------------------
- First Blood
  First kill since round start [red hud to x | sound to x] amx_firstbloodmode
  0 for all, 1 for player, 2 to disable.

   1: Player drew first blood!

- Head Shot
  It's all in the name [red hud to x | sound to x] amx_firstbloodmode
  0 for all, 1 for player, 2 to disable.

   1: Head Shot!!

- Humiliating Defeat
  Played to the losing team [green to x | sound to x] amx_headshotmode
  0 for all, 1 for player, 2 to disable.

   1: Humiliating Defeat

- Winning Victory
  Played to the winning team [green to x | sound to x] amx_firstbloodmode
  0 to enable, 1 to disable.

   2: You have won the match

- Play
  Played at the start of a match [green to x | sound to x] amx_firstbloodmode
  0 to enable, 1 to disable.
  
  1: Play
  
- Impressive
  Played when a player gets amx_impressivekills without dying [purple to all | sound to killer]
  amx_firstbloodmode
  0 for all, 1 for player, 2 to disable.
  
  1: Impressive

- Excellent
  Played when a player's kills divided by deaths are above amx_excellent [purple to killer | sound to killer] 
  amx_firstbloodmode
  0 for all, 1 for player, 2 to disable.

  1: Excellent

- Multi Kill
  Multiple kills, go find the #define MK_INTERVAL seconds for it to last [red to killer | sound to killer]
  amx_multikillmode
  0 for all, 1 for player, 2 to disable.

  2: Double Kill!
  3: Triple Kill!
  4: Multi Kill!
  5: MEGA KILL!
  6: ULTRA KILL!!!
  7: M O N S T E R K I L L!!!
  8: L U D I C R O U S  K I L L!!!
  9: H O L Y  S H I T!!!!!!

- Killing Spree
  Multiple kills without dying [blue to all | sound to all]

   5: Player is on a killing spree!
  10: Player is on a rampage!
  15: Player is dominating!
  20: Player is unstoppable!
  25: Player is Godlike!
  30: Player is Wicked Sick!

- Llama
  Plays Llama to teamkillers use amx_llamamode 0 to play to everyone
  
  1: Player is a Llama with X teamkills


Following files are required on your server in -mod-/sound/misc:
doublekill.wav
triplekill.wav
multikill.wav
megakill.wav
ultrakill.wav
monsterkill.wav
LudicrousKill.wav
HolyShit.wav
killingspree.wav
rampage.wav
dominating.wav
unstoppable.wav
godlike.wav
WhickedSick.wav
firstblood.wav
headshot.wav
humiliation.wav
humiliating_defeat.wav
you_have_won_the_match.wav
play.wav      
impressive.wav
llama.wav
(You can find these files at http://www.angelfire.com/realm3/topchris/sounds.zip)
*/

// MK = Multi Kill
// KS = Killing Spree
// FB = First Blood
// HS = Head Shot
// HM = Humiliation
// HD = Humiliating Defeat
// WV = Winning Victory
// PL = Play
// IM = Impressive
// EX = Excellent
// LL = Llama

#include <amxmodx>
#include <ns>
#include <fakemeta>

// MVM AVA
#define MARINE 1
#define ALIEN 2

// MVM
new g_teamtype[3]

// Force clients to download wav files?
#define DL_MK true
#define DL_WV true
#define DL_HD true
#define DL_KS true
#define DL_FB true
#define DL_HS false	// NS does not support headshots
#define DL_HM true
#define DL_PL true
#define DL_IM true
#define DL_EX true
#define DL_LL true

// MK
#define MK_INTERVAL 10.0 // This is the one you need to change for Multikill Intervals!
#define MK_INTERVAL2 10 // This is the one you need to change for Multikill Intervals!(except no decimal)
#define MK_START 2
#define MK_STEP 1
#define MK_LEVELS 8

// KS
#define KS_START 5
#define KS_STEP 5
#define KS_LEVELS 6
#define KS_TOP KS_START + KS_STEP * (KS_LEVELS - 1)

// MK
new MK_timer[33] = {0,...}
new MK_count[33] = {0,...}
new lastMK_check[33]
new MK_msg[MK_LEVELS][] = {
	"Double Kill!",
	"Triple Kill!",
	"Multi Kill!",
	"MEGA KILL!",
	"ULTRA KILL!!!",
	"M O N S T E R K I L L!!!",
	"L U D I C R O U S  K I L L!!!",
	"H O L Y  S H I T!!!!!!"
}
new MK_snd[MK_LEVELS][] = {
	"misc/doublekill.wav",
	"misc/triplekill.wav",
	"misc/multikill.wav",
	"misc/megakill.wav",
	"misc/ultrakill.wav",
	"misc/monsterkill.wav",
	"misc/LudicrousKill.wav",
	"misc/HolyShit.wav"
}

// KS
new KS_count[33] = {0,...}
new KS_msg[KS_LEVELS][] = {
	"%s is on a killing spree!",
	"%s is on a rampage!",
	"%s is dominating!",
	"%s is unstoppable!",
	"%s is Godlike!",
	"%s is Wicked Sick!!!"
}
new KS_snd[KS_LEVELS][] = {
	"misc/killingspree.wav",
	"misc/rampage.wav",
	"misc/dominating.wav",
	"misc/unstoppable.wav",
	"misc/godlike.wav",
	"misc/WhickedSick.wav"
}
new KS_endmsg[] = "%s's killing spree was ended by %s"
new KS_suicidemsg[] = "%s was looking good till he killed himself!"

// FB
new bool:FB = true
new FB_msg[] = "%s drew first blood!"
new FB_snd[] = "misc/firstblood.wav"

// HS
#if DL_HS
new HS_msg[] = "Head Shot!!"
new HS_snd[] = "misc/headshot.wav"
#endif

// HM
new HM_msg[] = "%s has humiliated %s with the knife!"
new HM_snd[] = "misc/humiliation.wav"

// WV
new WV_msg[] = "You have won the match"
new WV_snd[] = "misc/You_have_won_the_match.wav"

// HD
new HD_msg[] = "You have suffered a humiliating defeat"
new HD_snd[] = "misc/Humiliating_Defeat.wav"

// PL
new PL_msg[] = "Play"
new PL_snd[] = "misc/play.wav"

// IM
new IM_msg[] = "%s is impressive with %d kills after killing %s"
new IM_snd[] = "misc/impressive.wav"
new impressive[33]
new impressivestreak[33]

// EX
new EX_msg[] = "%s is excellent with %d kills and %d only %d deaths"
new EX_snd[] = "misc/excellent.wav"

// LL
new LL_msg[] = "%s is a Llama with %d teamkills"
new LL_snd[] = "misc/llama.wav"
new Llamatks[33]
new Llamatkstreak[33]

// Color
new Blue[3] = {0,63,191}
new Red[3] = {255,0,0}
new Green[3] = {0,191,63}
new Purple[3] = {128,0,128}
new Yellow[3] = {230,230,0}

// General
new utsoundson[33]

stock is_hm_all
public reset_MK(param[]){
	new id = param[0]
	MK_timer[id] = 0
	MK_count[id] = 0
}

public reset_all(id){
	if ( MK_timer[id] ){
		remove_task(id)
		MK_timer[id] = 0
	}
	MK_count[id] = 0
	KS_count[id] = 0
}

public say_KS(id){
	new name[32]
	new KS_lvl
	new msg[128]
	new Float:exp = ns_get_exp(id)
	KS_lvl = ( KS_count[id] - KS_START ) / KS_STEP
	if ( KS_lvl > KS_LEVELS - 1 )
		KS_lvl = KS_LEVELS - 1
	
	get_user_name(id,name,31)
	format(msg,127,KS_msg[KS_lvl],name)
	
	new killigspree_mode = ( get_cvar_num("amx_killingspreemode") )
	if ( killigspree_mode == 0 ){
	        for(new x=1;x<=get_maxplayers();x++) {
	        if (is_user_connected(x)){
	        if (is_user_alive(x)){
	        if ((utsoundson[x]) == 0){
		set_hudmessage(Blue[0],Blue[1],Blue[2],0.05,0.65,2,0.02,6.0,0.01,0.1,2)
		show_hudmessage(x,msg)
		client_cmd(x,"spk %s",KS_snd[KS_lvl])
		client_print(x,print_chat,"* %s",msg)
		if (get_cvar_num("amx_expmode") == 0) {
		ns_set_exp(id, (exp = exp + (35 * KS_lvl)))
		}
		}
                }
                }
                }
	}
	if ( killigspree_mode == 1 ){
	        for(new x=1;x<=get_maxplayers();x++) {
	        if (is_user_connected(x)){
	        if (is_user_alive(x)){
	        if ((utsoundson[x]) == 0){
	        if ((x) == (id)) {
		set_hudmessage(Blue[0],Blue[1],Blue[2],0.05,0.65,2,0.02,6.0,0.01,0.1,2)
		show_hudmessage(id,msg)
		client_cmd(id,"spk %s",KS_snd[KS_lvl])
		client_print(id,print_chat,"* %s",msg)
		if (get_cvar_num("amx_expmode") == 0) {
		ns_set_exp(id, (exp = exp + (35 * KS_lvl)))
		}
		}
		}
		}
		}
		}
	}
}

public say_MK(id){
	new name[32]
	new MK_lvl
	new msg[128]
	new Float:exp = ns_get_exp(id)
	MK_lvl = (MK_count[id] - MK_START) / MK_STEP
	if ( MK_lvl > MK_LEVELS - 1 )
		MK_lvl = MK_LEVELS - 1
	
	new multikill_mode = ( get_cvar_num("amx_multikillmode") )
	if ( multikill_mode == 0 ){
	        for(new x=1;x<=get_maxplayers();x++) {
	        if (is_user_connected(x)){
	        if (is_user_alive(x)){
	        if ((utsoundson[x]) == 0){
		format(msg,127,MK_msg[MK_lvl],name)
		set_hudmessage(Red[0],Red[1],Red[2],0.05,0.65,2,0.02,6.0,0.01,0.1,2)
		show_hudmessage(x,msg)
		client_cmd(x,"spk %s",MK_snd[MK_lvl])
		client_print(x,print_chat,"* %s",msg)
		if (get_cvar_num("amx_expmode") == 0) {
		ns_set_exp(id, (exp = exp + (35 * MK_lvl)))
		}
		}
		}
		}
		}
	}
	if ( multikill_mode == 1 ){
	        for(new x=1;x<=get_maxplayers();x++) {
	        if (is_user_connected(x)){
	        if (is_user_alive(x)){
	        if ((utsoundson[x]) == 0){
	        if ((x) == (id)) {
		format(msg,127,MK_msg[MK_lvl],name)
		set_hudmessage(Red[0],Red[1],Red[2],0.05,0.65,2,0.02,6.0,0.01,0.1,2)
		show_hudmessage(id,msg)
		client_cmd(id,"spk %s",MK_snd[MK_lvl])
		client_print(id,print_chat,"* %s",msg)
		if (get_cvar_num("amx_expmode") == 0) {
		ns_set_exp(id, (exp = exp + (35 * MK_lvl)))
		}
	        }
	        }
	        }
	        }
	        }
	}
}

public event_deathmsg(){
	new killer = read_data(1)
	if ( !is_user_connected(killer) )
		return PLUGIN_CONTINUE
	
	new victim = read_data(2)
	lastMK_check[victim] = 0
	new name_v[32]
	new msg[128]
	new killerweapon[32], killerweaponid, killerweaponammo, killerweaponclip;
	new Float:exp = ns_get_exp(killer)
	killerweaponid = get_user_weapon(killer,killerweaponclip,killerweaponammo);
	get_weaponname(killerweaponid,killerweapon,32);
	get_user_name(victim,name_v,31)
	impressive[victim] = 0
	Llamatkstreak[victim] = 0
	
	new killigspree_mode = ( get_cvar_num("amx_killingspreemode") )
	if ( killer == victim ){
		if ( killigspree_mode == 0 ){
	                        for(new x=1;x<=get_maxplayers();x++) {
	                        if (is_user_connected(x)){
	                        if (is_user_alive(x)){
	                        if ((utsoundson[x]) == 0){
				format(msg,127,KS_suicidemsg,name_v)
				set_hudmessage(Blue[0],Blue[1],Blue[2],0.05,0.65,2,0.02,6.0,0.01,0.1,2)
			 	show_hudmessage(x,msg)
				client_print(x,print_chat,"* %s",msg)
				client_cmd(x,"spk %s", HM_snd)
				}
		                }
		                }
		                }
		}
		if ( killigspree_mode == 1 ){
	                        for(new x=1;x<=get_maxplayers();x++) {
	                        if (is_user_connected(x)){
	                        if (is_user_alive(x)){
	                        if ((utsoundson[x]) == 0){
	                        if ((x) == (killer)) {
				format(msg,127,KS_suicidemsg,name_v)
				set_hudmessage(Blue[0],Blue[1],Blue[2],0.05,0.65,2,0.02,6.0,0.01,0.1,2)
			 	show_hudmessage(killer,msg)
				client_print(killer,print_chat,"* %s",msg)
				client_cmd(killer,"spk %s", HM_snd)
                                }
                                }
                                }
                                }
                                }
		}
	}else{
		new name_k[32]
		get_user_name(killer,name_k,31)

// why count impressive when kill can be a TK ?
// lets do this when we are sure player killed enemy
//		impressivestreak[killer] += 1
//		impressive[killer] += 1
		if ( lastMK_check[killer] < MK_count[killer] ) {
			MK_timer[killer] = MK_INTERVAL2
			lastMK_check[killer] = MK_count[killer]
		}
		if ( pev(killer,pev_team) == pev(victim,pev_team) ){
			if ( get_cvar_num("amx_llamamode") <= 1 ){
				Llamatks[killer] += 1
				Llamatkstreak[killer] += 1
				if ( Llamatkstreak[killer] >= get_cvar_num("amx_llamatks") ){
					Llamatkstreak[killer] = 0
					new llama_mode = ( get_cvar_num("amx_llamamode") )
					if ( llama_mode == 0 ){
				                for(new x=1;x<=get_maxplayers();x++) {
	                                        if (is_user_connected(x)){
	                                        if (is_user_alive(x)){
	                                        if ((utsoundson[x]) == 0){
						format(msg,127,LL_msg, name_k, Llamatks[killer])
						set_hudmessage(Yellow[0],Yellow[1],Yellow[2],0.05,0.65,2,0.02,6.0,0.01,0.1,2)	
						show_hudmessage(x,msg)
						client_cmd(x,"spk %s",LL_snd)
						client_print(x,print_chat,"* %s",msg)
						if (get_cvar_num("amx_expmode") == 0) {
						ns_set_exp(killer, (exp = exp - (50)))
						}
						}
						}
						}
					        }
					}
					if ( llama_mode == 1 ){
			                        for(new x=1;x<=get_maxplayers();x++) {
	                                        if (is_user_connected(x)){
	                                        if (is_user_alive(x)){
	                                        if ((utsoundson[x]) == 0){
	                                        if ((x) == (killer)) {
						format(msg,127,LL_msg, name_k, Llamatks[killer])
						set_hudmessage(Yellow[0],Yellow[1],Yellow[2],0.05,0.65,2,0.02,6.0,0.01,0.1,2)	
						show_hudmessage(killer,msg)
						client_cmd(killer,"spk %s",LL_snd)
						client_print(killer,print_chat,"* %s",msg)
						if (get_cvar_num("amx_expmode") == 0) {
						ns_set_exp(killer, (exp = exp - (50)))
						}
			                        }
			                        }
			                        }
			                        }
			                        }
					}
				}
			}
		}else{
			// player killed enemy
			impressivestreak[killer] += 1
			impressive[killer] += 1

			new impress_mode = ( get_cvar_num("amx_impressivemode") )
			new humilation_mode = ( get_cvar_num("amx_humiliationmode") )
			if ( impress_mode == 0 ){
				if ( impressive[killer] == get_cvar_num("amx_impressivekills") ){
				        for(new x=1;x<=get_maxplayers();x++) {
	                                if (is_user_connected(x)){
	                                if (is_user_alive(x)){
	                                if ((utsoundson[x]) == 0){
					impressive[killer] = 0
					format(msg,127,IM_msg, name_k, impressivestreak[killer], name_v)
					set_hudmessage(Purple[0],Purple[1],Purple[2],0.05,0.65,2,0.02,6.0,0.01,0.1,2)
					show_hudmessage(x,msg)
					client_cmd(x,"spk %s",IM_snd)
					client_print(x,print_chat,"* %s",msg)
					if (get_cvar_num("amx_expmode") == 0) {
					ns_set_exp(killer, (exp = exp + (150)))
					}
					}
					}
					}
					}
				}
			}
			if ( impress_mode == 1 ){
				if ( impressive[killer] == get_cvar_num("amx_impressivekills") ){
	                                for(new x=1;x<=get_maxplayers();x++) {
	                                if (is_user_connected(x)){
	                                if (is_user_alive(x)){
	                                if ((utsoundson[x]) == 0){
	                                if ((x) == (killer)) {
					impressive[killer] = 0
					format(msg,127,IM_msg, name_k, impressivestreak[killer], name_v)
					set_hudmessage(Purple[0],Purple[1],Purple[2],0.05,0.65,2,0.02,6.0,0.01,0.1,2)
					show_hudmessage(killer,msg)
					client_cmd(killer,"spk %s",IM_snd)
					client_print(killer,print_chat,"* %s",msg)
					if (get_cvar_num("amx_expmode") == 0) {
					ns_set_exp(killer, (exp = exp + (150)))
					}
				        }
				        }
				        }
				        }
				        }
				}
			}
			if ( humilation_mode == 0 ){
				if (killerweaponid == (WEAPON_KNIFE)){
			                for(new x=1;x<=get_maxplayers();x++) {
	                                if (is_user_connected(x)){
	                                if (is_user_alive(x)){
	                                if ((utsoundson[x]) == 0){
					format(msg,127,HM_msg,name_k,name_v)
					set_hudmessage(Red[0],Red[1],Red[2],0.05,0.65,2,0.02,6.0,0.01,0.1,2)
					show_hudmessage(x,msg)
					client_cmd(x,"spk %s",HM_snd)
					client_print(x,print_chat,"* %s",msg)
					ns_set_exp(killer, (exp = exp + (25)))
				        }
					}
					}
					}
				}
			}
			if ( humilation_mode == 1 ){
				if (killerweaponid == (WEAPON_KNIFE)){
				        for(new x=1;x<=get_maxplayers();x++) {
	                                if (is_user_connected(x)){
	                                if (is_user_alive(x)){
	                                if ((utsoundson[x]) == 0){
	                                if ((x) == (victim)) {
					format(msg,127,HM_msg,name_k,name_v)
					set_hudmessage(Red[0],Red[1],Red[2],0.05,0.65,2,0.02,6.0,0.01,0.1,2)
					show_hudmessage(victim,msg)
					client_cmd(victim,"spk %s",HM_snd)
					client_print(victim,print_chat,"* %s",msg)
					ns_set_exp(killer, (exp = exp + (25)))
					}
					}
					}
					}
					}
				}
			}
			if ( killigspree_mode == 0 ){
				if (KS_count[victim] >= KS_START){
					format(msg,127,KS_endmsg,name_v,name_k)
					set_hudmessage(Blue[0],Blue[1],Blue[2],0.05,0.65,2,0.02,6.0,0.01,0.1,2)
					show_hudmessage(0,msg)
					client_print(0,print_chat,"* %s",msg)
				}
			}
			if ( killigspree_mode == 1 ){
				if (KS_count[victim] >= KS_START){
					format(msg,127,KS_endmsg,name_v,name_k)
					set_hudmessage(Blue[0],Blue[1],Blue[2],0.05,0.65,2,0.02,6.0,0.01,0.1,2)
					show_hudmessage(killer,msg)
					client_print(killer,print_chat,"* %s",msg)
				}
			}
			
//		if ( pev(killer,pev_team) != pev(victim,pev_team) ){
			new firstblood_mode = ( get_cvar_num("amx_firstbloodmode") )
			// FB
			if ( firstblood_mode == 0 ){
				if ( FB ){
					FB = false
				        for(new x=1;x<=get_maxplayers();x++) {
	                                if (is_user_connected(x)){
	                                if (is_user_alive(x)){
	                                if ((utsoundson[x]) == 0){
					format(msg,127,FB_msg,name_k)
					set_hudmessage(Red[0],Red[1],Red[2],0.05,0.65,2,0.02,6.0,0.01,0.1,2)
					show_hudmessage(x,msg)
					client_cmd(x,"spk %s",FB_snd)
					client_print(x,print_chat,"* %s",msg)
					if (get_cvar_num("amx_expmode") == 0) {
					ns_set_exp(killer, (exp = exp + (100)))
					}
					}
					}
					}
					}
				}
			}
			if ( firstblood_mode == 1 ){
				if ( FB ){
					FB = false
			                for(new x=1;x<=get_maxplayers();x++) {
	                                if (is_user_connected(x)){
	                                if (is_user_alive(x)){
	                                if ((utsoundson[x]) == 0){
	                                if ((x) == (killer)) {
					format(msg,127,FB_msg,name_k)
					set_hudmessage(Red[0],Red[1],Red[2],0.05,0.65,2,0.02,6.0,0.01,0.1,2)
					show_hudmessage(0,msg)
					client_cmd(killer,"spk %s",FB_snd)
					client_print(killer,print_chat,"* %s",msg)
					if (get_cvar_num("amx_expmode") == 0) {
					ns_set_exp(killer, (exp = exp + (100)))
					}
				        }
				        }
				        }
				        }
				        }
				}
			}
			// HS
#if DL_HS
			new headshot_mode = ( get_cvar_num("amx_headshotmode") )
			if ( headshot_mode == 0 ){
				if ( read_data(3) ){
					for(new x=1;x<=get_maxplayers();x++) {
	                                if (is_user_connected(x)){
	                                if (is_user_alive(x)){
	                                if ((utsoundson[x]) == 0){
					set_hudmessage(Red[0],Red[1],Red[2],0.05,0.65,2,0.02,6.0,0.01,0.1,2)
					show_hudmessage(0,HS_msg)
					client_cmd(0,"spk %s",HS_snd)
					if (get_cvar_num("amx_expmode") == 0) {
					ns_set_exp(killer, (exp = exp + (150)))
					}
					}
					}
					}
					}
				}
			}
			if ( headshot_mode == 1 ){
				if ( read_data(3) ){
				        for(new x=1;x<=get_maxplayers();x++) {
	                                if (is_user_connected(x)){
	                                if (is_user_alive(x)){
	                                if ((utsoundson[x]) == 0){
	                                if ((x) == (killer)) {
					set_hudmessage(Red[0],Red[1],Red[2],0.05,0.65,2,0.02,6.0,0.01,0.1,2)
					show_hudmessage(killer,HS_msg)
					client_cmd(killer,"spk %s",HS_snd)
					if (get_cvar_num("amx_expmode") == 0) {
					ns_set_exp(killer, (exp = exp + (150)))
					}
					}
					}
					}
					}
					}
				}
			}
#endif
			// MK
			if ( MK_timer[killer] ){
				remove_task(killer)
				MK_timer[killer] = 0
			}
			MK_count[killer]++
			if ( MK_count[killer] >= MK_START && (MK_count[killer] - MK_START) % MK_STEP == 0 ){
				say_MK(killer)
			}
			
			new param[2]
			param[0] = killer
			set_task(MK_INTERVAL,"reset_MK",killer,param,1)
			
			// KS
			KS_count[killer]++
			if ( KS_count[killer] >= KS_START && KS_count[killer] <= KS_TOP && (KS_count[killer] - KS_START) % KS_STEP == 0 ){
				say_KS(killer)
			}
		}
	}
	reset_all(victim)
	
	return PLUGIN_CONTINUE
}

public event_roundtime() {
	if ( get_cvar_num("mp_roundtime") * 60 == read_data(1) )
		FB = true
}

public client_putinserver(id){
	reset_all(id)
}

public plugin_precache(){
#if DL_MK
	for (new i=0; i < MK_LEVELS; i++)
		precache_sound(MK_snd[i])
#endif

#if DL_KS
	for (new i=0; i < KS_LEVELS; i++)
		precache_sound(KS_snd[i])
#endif

#if DL_FB
	precache_sound(FB_snd)
#endif

#if DL_HS
	precache_sound(HS_snd)
#endif

#if DL_HM
	precache_sound(HM_snd)
#endif

#if DL_WV
	precache_sound(WV_snd)
#endif

#if DL_HD
	precache_sound(HD_snd)
#endif

#if DL_PL
	precache_sound(PL_snd)
#endif

#if DL_IM
	precache_sound(IM_snd)
#endif

#if DL_EX
	precache_sound(EX_snd)
#endif

#if DL_LL
	precache_sound(LL_snd)
#endif
}

public new_round(id){
	impressivestreak[id] = 0
	impressive[id] = 0
}

public ut_activate(id) {
if (utsoundson[id] == 1) {
     utsoundson[id] = 0
     client_print(id, print_chat, "You have enabled the ut_sounds")
     return PLUGIN_HANDLED
     }
if (utsoundson[id] == 0) {
     utsoundson[id] = 1
     client_print(id, print_chat, "You have disabled the ut_sounds")
     return PLUGIN_HANDLED
     }
return PLUGIN_CONTINUE
}

public roundEnded(id) {
	new msg[128]
	new kills = get_user_frags(id)
	new deaths = get_user_deaths(id)
	new hivealive = ns_get_build("team_hive",1,1)
	new ccalive = ns_get_build("team_command",1,1)
	if ( pev(ccalive,pev_effects) & 128 )	// EF_NODRAW
		ccalive = 0
	lastMK_check[id] = 0
	if ( get_cvar_num("amx_victorymode") == 0 ){
	        if ((utsoundson[id]) == 0){
		new winner_team
		if ( g_teamtype[1] == MARINE ){
			if ( g_teamtype[2] == ALIEN ){
				if ( hivealive && ccalive )
					winner_team = 3
				else if ( hivealive )
					winner_team = ALIEN
				else
					winner_team = MARINE
			}else if ( g_teamtype[2] == MARINE ){
				new cc_in_team[5]
				for ( new i = 1; i <= ns_get_build("team_command",0,0); i++ ){
					new ccid = ns_get_build("team_command",0,i)
					cc_in_team[pev(ccid,pev_team)] += 1
				}
				if ( cc_in_team[1] && cc_in_team[2] )
					winner_team = 3
				else if ( cc_in_team[1] )
					winner_team = MARINE
				else
					winner_team = ALIEN	// marines2 are aliens in MvM
			}
		}else if ( g_teamtype[1] == ALIEN && g_teamtype[2] == ALIEN )
			winner_team = pev(hivealive,pev_team)

		set_hudmessage(Green[0],Green[1],Green[2],0.05,0.65,2,0.02,6.0,0.01,0.1,2)
		if ( pev(id, pev_team) == winner_team || ( pev(id, pev_team) == ALIEN && winner_team == 3 ) ){
			show_hudmessage(id,WV_msg)
			client_cmd(id,"spk %s",WV_snd)
			client_print(id,print_chat,"* %s",WV_msg)
		}else{
			show_hudmessage(id,HD_msg)
			client_cmd(id,"spk %s",HD_snd)
			client_print(id,print_chat,"* %s",HD_msg)
		}
		}
	}
	if ( get_cvar_num("amx_excellentmode") == 0 ){
		if ( (kills >= 1) && (deaths >= 1) ){
			if ( kills / deaths >= get_cvar_num("amx_excellent") ){
				for(new x=1;x<=get_maxplayers();x++) {
	                        if (is_user_connected(x)){
	                        if (is_user_alive(x)){
	                        if ((utsoundson[id]) == 0){
				format(msg,127,EX_msg,id,kills,deaths)
				set_hudmessage(Purple[0],Purple[1],Purple[2],0.05,0.65,2,0.02,6.0,0.01,0.1,2)
				show_hudmessage(id,EX_msg)
				client_cmd(id,"spk %s",EX_snd)
				client_print(id,print_chat,"* %s",EX_msg)
				}
				}
				}
				}
			}
		}
	}
	reset_all(id)
	
	return PLUGIN_CONTINUE
}

public startThePlugin(){
	if ( get_cvar_num("amx_playmode") == 0 )
		set_task(5.5,"startThePlugin2")
}

public startThePlugin2(){
	set_hudmessage(Green[0],Green[1],Green[2],0.05,0.65,2,0.02,6.0,0.01,0.1,2)
	show_hudmessage(0,PL_msg)
	client_cmd(0,"spk %s",PL_snd)
	client_print(0,print_chat,"%s",PL_msg)
	new commcount = ns_get_build("team_command",0,0)
	if ( commcount == 0 ){
		g_teamtype[1] = ALIEN
	  	g_teamtype[2] = ALIEN
	}else{
		g_teamtype[1] = MARINE
	 	if ( commcount == 1 )
	 		g_teamtype[2] = ALIEN
		else
	  		g_teamtype[2] = MARINE
	}
}

//  I don't think plugin init needed to be all the way the hell at the top.

public plugin_init(){
	register_plugin("UT Sounds NS","0.8d","Topchris")
	register_event("DeathMsg", "event_deathmsg", "a")
	register_event("Countdown", "startThePlugin", "a")
	register_event("GameStatus", "roundEnded", "ab", "1=2")
	register_event("GameStatus", "new_round", "ab", "1=2")
	register_clcmd("say ut_activate","ut_activate",0,"typing this in will disable/enable the ut sounds")
	register_clcmd("say_team ut_activate","ut_activate",0,"typing this in will disable/enable the ut sounds")
        register_cvar("amx_llamamode", "0")
        register_cvar("amx_humiliationmode", "0")
	register_cvar("amx_victorymode", "0")
	register_cvar("amx_playmode", "0")
	register_cvar("amx_expmode", "1")
	register_cvar("amx_llamatks", "3")
	register_cvar("amx_excellentmode", "0")
	register_cvar("amx_impressivemode", "0")
	register_cvar("amx_headshotmode", "0")
	register_cvar("amx_firstbloodmode", "0")
	register_cvar("amx_multikillmode", "0")
	register_cvar("amx_killingspreemode", "0")
	register_cvar("amx_impressivekills", "11")
	register_cvar("amx_excellent", "10")
}


