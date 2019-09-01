#include <amxmodx>
#include <engine>
#include <fun>

new v_dual_hmg_MODEL_NAME[64] = "models/v_dual_hmg.mdl"

public plugin_init(){
	register_plugin("dualhmg","0.1")
	// Register my plugin, lots of thanks to RadidEskimo & Freecode

	register_cvar("amx_dualhmg_startwith", "0")
	// Start with dualhmg? Default is FALSE

	register_cvar("amx_dualhmg_startmsg_on", "2")
	// You can choose to show a start message.
	// 0 = OFF
	// 1 = ON
	// 2 = ON - Only when amx_dualhmg_startwith = 1
	// Default is 2

	register_cvar("amx_dualhmg_startmsg_msg", "These do 2x normal damage, enjoy!")
	// Message to show when startmsg_on is enabled.

	register_cvar("amx_dualhmg_unlimitedammo", "0")
	// dualhmg have unlimited ammo? Default is FALSE

	register_cvar("amx_dualhmg_doubledamage", "0")
	// dualhmg do DOUBLE damage? Default is FALSE

	register_event("ResetHUD","newRound","b")
	// Call newRound() when the round is over

	register_event("WeapPickup","checkModel","b","1=19")
	// When a weapon is picked up (or bought) call checkModel()

	register_event("CurWeapon","checkWeapon","be","1=1")
	// Call checkWeapon() when shots are fired

	if(get_cvar_num("amx_dualhmg_doubledamage") == 1) {
		register_event("Damage", "doDamage", "b", "2!0")
		// When somebody has damage done to them, call doDamage (so we can multiply 2x)
	}
}

public newRound(id){
	if(get_cvar_num("amx_dualhmg_startwith") == 1){
		give_item(id,"weapon_v_dual_hmg")
	///	give_item(id,"shell")
	}
    //
    // Basically, if you set "amx_dualhmg_startwith" to 1..
    // every new round the user will get an dualhmg
    //
    // The ResetHUD event calls newRound(id) for every user when
    // the new round begins.. so it will loop this for all users in game
    //
}

public client_putinserver(id){
	new msgStr[100],msgNum,startWith
	get_cvar_string("amx_dualhmg_startmsg_msg", msgStr, 99)
	msgNum = get_cvar_num("amx_dualhmg_startmsg_on")
	startWith = get_cvar_num("amx_dualhmg_startwith")

	if(msgNum == 2 && startWith == 1) {
		client_print(id, print_chat, "[AMXX] dualhmg Mod: %s", msgStr)
	}

	if(msgNum == 1) {
		client_print(id, print_chat, "[AMXX] dualhmg Mod: %s", msgStr)
	}

	//
	// If they do start with dualhmg, and there is a msg, show the info message
	//
}

public plugin_precache(){
	precache_model(v_dual_hmg_MODEL_NAME)
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

	entity_set_string(id, EV_SZ_viewmodel, v_dual_hmg_MODEL_NAME)
	// Find and change the user's dualhmg to OUR custom model (v_dual_hmg_MODEL_NAME)..
    
	new iCurrent
	iCurrent = find_ent_by_class(-1,"weapon_v_dual_hmg")

	while(iCurrent != 0) {
		iCurrent = find_ent_by_class(iCurrent,"weapon_v_dual_hmg")
	}

	return PLUGIN_HANDLED
} 

public checkWeapon(id){ 
	new plrClip, plrAmmo, plrWeap[32]
	new plrWeapId

	plrWeapId = get_user_weapon(id, plrClip, plrAmmo)
	// Define certain variables needed in this function, get the
	// current ID of the weapon the user picked up

	if (plrWeapId == v_dual_hmg){
		checkModel(id)
		// If the user picked up an hmg then change the model to OUR model..
	}
	else {
	    // Otherwise just leave this function
		return PLUGIN_CONTINUE
	}

	if (plrClip == 0){
		if(get_cvar_num("amx_dualhmg_unlimitedammo") == 1) {
			// ^ If the user is out of ammo..
			get_weaponname(plrWeapId, plrWeap, 31)
			// Get the name of their weapon (dualhmg, duh!)
			give_item(id, plrWeap)
			// Give them another dualhmg (ammo)
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

	if (plrWeap != v_dual_hmg){
	    // If the damage was not done with an dualhmg, just exit function..
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
			
			write_string("v_dual_hmg")
			// Write the weapon VICTIM ID was killed with..
			
			message_end()
			// End the message..
		}
		set_user_health(id, plrNewDmg)
		// Then set the health, even if it will kill the player
	}
	return PLUGIN_CONTINUE
}
