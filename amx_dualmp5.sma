/*##########################################################################
##
## -- www.SteamTools.net
##     _____   _   _       ___   _           ___  ___   _____   _____
##    |  _  \ | | | |     /   | | |         /   |/   | |  _  \ |  ___| 
##    | | | | | | | |    / /| | | |        / /|   /| | | |_| | | |___  
##    | | | | | | | |   / / | | | |       / / |__/ | | |  ___/ \___  \ 
##    | |_| | | |_| |  / /  | | | |___   / /       | | | |      ___| | 
##    |_____/ \_____/ /_/   |_| |_____| /_/        |_| |_|     \_____|
##                                                        
##          |__                   |__  o _|_   ___   __ __  o |__,  ___  
##      --  |__) (__|     (__(__( |  ) |  |_, (__/_ |  )  ) | |  \ (__/_ 
##                  |                                                    
##
##   Replaces your standard MP5 with this DualMP5 model. There's no
## difference in performance (damage, bullets, etc.) unless you set
## the CVARs accordingly. By default you do NOT start with DualMP5,
## and you do NOT have unlimited ammo.
##
##   A sample configuration is below, feel free to contact me
## via PM or email (mellis@traxio.net) if you have any questions
## or comments.
##
##   Enjoy!
##
##
## INSTALLATION
##------------------------------------------------------------------------
## 1) Unzip (which you may have done already)
## 2) Place 'amx_dualmp5.amxx' in 'cstrike/addons/amxmodx/plugins'
## 3) Add a line in 'configs/plugins.ini' containing 'amx_dualmp5.amxx'
## 4) Put 'SteamTools_Net_DualMP5.mdl' in 'cstrike/models' folder
## 5) Open 'cstrike/server.cfg' and add the cvars listed below
## 6) -- Visit www.SteamTools.net, and enjoy your new plugin!
##
##
## SAMPLE CONFIGURATION
##------------------------------------------------------------------------
##
## amx_dualmp5_startwith 1
## amx_dualmp5_startmsg_on 2
## amx_dualmp5_startmsg_msg "These do 2x damage, and you have unlim. ammo!"
## amx_dualmp5_unlimitedammo 1
##
## -- This config will:
##     - Give all players DualMP5's each round
##     - Show the start message only when you start with mp5 (until startwith = 0)
##     - Allow users to continuously fire with no reloads.
##
##
## THE CVARs
##------------------------------------------------------------------------
##
## amx_dualmp5_startwith
##   - Start with mp5
##     + Default is 0
##
## amx_dualmp5_startmsg_on
##   - You can choose to show a start message.
##     0 = OFF
##     1 = ON
##     2 = ON - Only shows when amx_dualmp5_startwith = 1
##     + Default is 2
##
## amx_dualmp5_startmsg_msg
##   - Message to show when startmsg_on is enabled.
##     + Default is "These do 2x normal damage, enjoy!"
##
## amx_dualmp5_unlimitedammo
##   - Dual MP5s have unlimited ammo
##     + Default is FALSE
##
##
##########################################################################*/


#include <amxmodx>
#include <engine>
#include <fun>

new MP5_MODEL_NAME[64] = "models/SteamTools_net_DualMP5.mdl"

public plugin_init(){
	register_plugin("SteamTools.net Dual MP5s","0.1","SteamTools.net")
	// Register my plugin, lots of thanks to RadidEskimo & Freecode

	register_cvar("amx_dualmp5_startwith", "0")
	// Start with mp5? Default is FALSE

	register_cvar("amx_dualmp5_startmsg_on", "2")
	// You can choose to show a start message.
	// 0 = OFF
	// 1 = ON
	// 2 = ON - Only when amx_dualmp5_startwith = 1
	// Default is 2

	register_cvar("amx_dualmp5_startmsg_msg", "These do 2x normal damage, enjoy!")
	// Message to show when startmsg_on is enabled.

	register_cvar("amx_dualmp5_unlimitedammo", "0")
	// Dual MP5s have unlimited ammo? Default is FALSE

	register_cvar("amx_dualmp5_doubledamage", "0")
	// Dual MP5s do DOUBLE damage? Default is FALSE

	register_event("ResetHUD","newRound","b")
	// Call newRound() when the round is over

	register_event("WeapPickup","checkModel","b","1=19")
	// When a weapon is picked up (or bought) call checkModel()

	register_event("CurWeapon","checkWeapon","be","1=1")
	// Call checkWeapon() when shots are fired

	if(get_cvar_num("amx_dualmp5_doubledamage") == 1) {
		register_event("Damage", "doDamage", "b", "2!0")
		// When somebody has damage done to them, call doDamage (so we can multiply 2x)
	}
}

public newRound(id){
	if(get_cvar_num("amx_dualmp5_startwith") == 1){
		give_item(id,"weapon_mp5navy")
		give_item(id,"ammo_9mm")
	}
    //
    // Basically, if you set "amx_dualmp5_startwith" to 1..
    // every new round the user will get an MP5
    //
    // The ResetHUD event calls newRound(id) for every user when
    // the new round begins.. so it will loop this for all users in game
    //
}

public client_putinserver(id){
	new msgStr[100],msgNum,startWith
	get_cvar_string("amx_dualmp5_startmsg_msg", msgStr, 99)
	msgNum = get_cvar_num("amx_dualmp5_startmsg_on")
	startWith = get_cvar_num("amx_dualmp5_startwith")

	if(msgNum == 2 && startWith == 1) {
		client_print(id, print_chat, "[AMXX] Dual MP5 Mod: %s", msgStr)
	}

	if(msgNum == 1) {
		client_print(id, print_chat, "[AMXX] Dual MP5 Mod: %s", msgStr)
	}

	//
	// If they do start with MP5's, and there is a msg, show the info message
	//
}

public plugin_precache(){
	precache_model(MP5_MODEL_NAME)
	return PLUGIN_CONTINUE
	//
	// Just precache the model, so if the user does not have it, they have to download
	//
}

public checkModel(id){ 
	if (!is_user_alive(id)){
		return PLUGIN_CONTINUE
	}
	// If the user that picked up the weapon is alive..

	entity_set_string(id, EV_SZ_viewmodel, MP5_MODEL_NAME)
	// Find and change the user's MP5 to OUR custom model (MP5_MODEL_NAME)..
    
	new iCurrent
	iCurrent = find_ent_by_class(-1,"weapon_mp5navy")

	while(iCurrent != 0) {
		iCurrent = find_ent_by_class(iCurrent,"weapon_mp5navy")
	}

	return PLUGIN_HANDLED
} 

public checkWeapon(id){ 
	new plrClip, plrAmmo, plrWeap[32]
	new plrWeapId

	plrWeapId = get_user_weapon(id, plrClip, plrAmmo)
	// Define certain variables needed in this function, get the
	// current ID of the weapon the user picked up

	if (plrWeapId == CSW_MP5NAVY){
		checkModel(id)
		// If the user picked up an MP5 then change the model to OUR model..
	}
	else {
	    // Otherwise just leave this function
		return PLUGIN_CONTINUE
	}

	if (plrClip == 0){
		if(get_cvar_num("amx_dualmp5_unlimitedammo") == 1) {
			// ^ If the user is out of ammo..
			get_weaponname(plrWeapId, plrWeap, 31)
			// Get the name of their weapon (MP5, duh!)
			give_item(id, plrWeap)
			// Give them another MP5 (ammo)
			engclient_cmd(id, plrWeap) 
			engclient_cmd(id, plrWeap)
			engclient_cmd(id, plrWeap)
			// Sending multiple times may help
		}
	}

	return PLUGIN_CONTINUE 
} 

public doDamage(id){
	new plrDmg = read_data(2)
	new plrWeap
	new plrPartHit
	new plrAttacker = get_user_attacker(id, plrWeap, plrPartHit)
	new plrHealth = get_user_health(id)
	new plrNewDmg

	//
	// plrDmg is set to how much damage was done to the victim
	// plrHealth is set to how much health the victim has
	// plrAttacker is set to the id of the person doing the shooting
	//
	// Could have put the above on one line, didn't for learning purposes (nubs may read this!) lol
	// Example: new plrWeap, plrPartHit, plrAttacker = get_user_attacker( .. etc etc
	//

	if (plrWeap != CSW_MP5NAVY){
	    // If the damage was not done with an MP5, just exit function..
		return PLUGIN_CONTINUE
	}

	if (is_user_alive(id)){
	    // If the victim is still alive.. (should be)
		plrNewDmg = (plrHealth - plrDmg)
		//
		// Make the new damage their current health - plrDmg..
		// This is actually damage 2x, becuase when they did the damage
		// lets say it was 10, now this is subtracting 10 from current heatlh
		// doing 20, so thats 2 times =D
		//
		if(plrNewDmg < 1){
			// If the new damage will kill the player..

			set_msg_block(get_user_msgid("DeathMsg"),BLOCK_ONCE);
			// Block one the death messages to prevent 'suicide'

			message_begin(MSG_ALL, get_user_msgid("DeathMsg"), {0,0,0}, 0)
			// Start a death message, so it doesnt just say "Player Died",
			// the killer will get the credit
			
			write_byte(plrAttacker)
			// Write KILLER ID
			
			write_byte(id)
			// Write VICTIM ID
            
			write_byte(random_num(0,1))
			// Write HEAD SHOT or not
			// I made this random because I was unsure of how to detect
			// if plrPartHit was "head" or not.. someone help..
			
			write_string("mp5navy")
			// Write the weapon VICTIM ID was killed with..
			
			message_end()
			// End the message..
		}
		set_user_health(id, plrNewDmg)
		// Then set the health, even if it will kill the player
	}
	return PLUGIN_CONTINUE
}
