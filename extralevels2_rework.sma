/*
*	Allows players to go above Level 10 in Combat, and adds 11 new upgrades (6 for Marines, 5 for Aliens)
*
* Author:
*	-> White Panther
*
* Credits:
*	-> Cheesy Peteza			-	his ExtraLevels plugin
*	-> Cheeserm! (alias Silent Skulk)	-	ExtraLevels2 (his advancements to ExtraLevels)
*	-> Depot				-	his assistance in getting bugs fixed
*	-> [I-AM]Xman				-	his assistance in getting bugs fixed
*
* Usage:
*	-> say "xmenu" or "/xmenu" to bring up a menu of extra upgrades
*	-> say "/xhelp" to bring up a menu with some information
*	-> amx_maxlevel		-	Set to the highest level you want to allow (default 50)
*
*	this plugin is a rework of "ExtraLevels 2"
*	based on Cheeserm!'s "ExtraLevels 2 v1.7e" (28.01.05)
*
* v0.7.8b: (compatability for Gnome 0.6.3b or higher)
*	- fixed:
*		- 5 defines removed (unnecessary) and all associated coding removed or modified (PV_EXPERIENCE compilation error)
*		- Rejoin bug exploit has been removed. Players who now retry start from scratch
*		- Weld issue fixed in "public weldoverbasemax(id)" section (Cheeserm fixed incorrectly in 1.7e)
*		- when player with Staticfield was spectating, Staticfield worked as if the spectated player had it
*		- when self welding the sound now stops when finished
*		- problem where no extrapoints were given (should be fixed)
*		- aliens with hunger could get a higher health boost than defined in "HUNGERHEALTH"
*		- incorrect display of next level staticfield and ethernaltracking (++)
*		- some sounds not being precached and wrong/unnecessary sounds being used
*		- ethernal shift acting as one level lower than player has
*	- added:
*		- Gnome compatability (95 %)
*		- Gnome gets a reduced speed bonus
*		- when welding over max base armor there is a weld sound
*		- SHIFTCLASSMULTI define: skulk, gorge and lerk SHIFTLEVEL gets multiplied by it (eg: level 5 time: old = 2,25 / new = 3,50)
*		- player now only get as many points as he can spent
*	- changed:
*		- many code improvements (~600 lines saved, removed 16 timers and added 1, ...)
*		- selfweld sound system (1 sound constant + 1 sound every selfweld-time is done) (old: every selfweld-time 1 random sound out of 2)
*		- onos can now do ethernalshift (can be turned off with a define)
*		- rewritten the XP system, it is now dynamic and only the cvar "amx_maxlevel" blocks you from getting higher levels
*		- point giving system (improved/removed unnecessary/reworked code) (+++)
*
* v0.7.9:
*	- changed:
*		- moved from pev/set_pev to entity_get/entity_set (no fakemeta)
*
* v0.8.2b:
*	- fixed:
*		- the health addition to HUNGER upgrade was not correctly calculated, "HUNGERHEALTH" should be +x% but was +HP/x (eg HUNGERHEALTH = 100 and maxhp = 100, normally 100+100 but was 100+1)
*	- added:
*		- a define for NS version cause of the armor bonus in 3.03
*		- check for GorgZilla
*	- changed:
*		- many code improvements ( ~60 lines saved, performance, code cleaning)
*
* v0.8.5:
*	- fixed:
*		- selfhealing sound for aliens did not stop after reaching maximum health
*	- changed:
*		- rewritten the menu code ( now there are 2 menus instead of 6 )
*		- many code improvements ( ~180 lines saved, code cleaning )
*
* v0.8.7:
*	- fixed:
*		- while spectating the hud message was messed up
*		- when "amx_huddisplay" was set to 1 hud message has not been set before reaching lvl 11, now it starts with lvl 10
*	- changed:
*		- code improvements
*
* v0.8.8:
*	- fixed:
*		- rare bug where percentage to next level was negative
*
* v0.8.9:
*	- changed:
*		- server_frame is hooked with ent and support other plugins that uses the same system (speed improvement thx OneEyed)
*		- code improvements
*
* v0.9.6b:
*	- fixed:
*		- no XP display shown when spawned untill you earned some XP (eg: killed someone)
*		- Bloodlust is now calculated correctly ( no super bloodlust)
*		- Bloodlust is now given every 0.1 seconds instead of server frame (prevents 2nd calculation mistake)
*		- exploit where you kept extra upgrades after going to readyroom
*	- added:
*		- possiblility to customize XP (up to level 10 it is not changable)
*		- new upgrades (marines: Uranium Ammo / aliens: Sense of Ancients)
*	- changed:
*		- adjusted menu so it is not overlapping with chat anymore
*		- percentage is now shown as a float
*		- cosmetic improvemts to menu
*		- removed unneeded include
*		- menu now displays current- / max- level of each upgrade
*		- code improvements
*		- Rank names are now dynamically set (depending on max level when map starts)
*
* v1.0.0:
*	- fixed:
*		- players with cybernetics do not get little extra speed boost anymore
*		- regeneration has now correct sound (not metabolize anymore)
*		- health gained by hive regeneration is now correct
*		- distance to get hive regeneration has been corrected
*		- hive now only healths thickened skin when normal health reached (not when health was below anymore)
*		- lerks base health corrected
*		- possible exploits with ResetHUD event
*	- added:
*		- Sense of Ancients for gestating aliens (armor bonus)
*		- aliens are now gestating when extra upgrade has been choosen
*	- changed:
*		- removed some unneeded code
*		- code improvements
*/

#include <amxmodx>
#include <engine>
#include <fakemeta>
#include <ns>

// set this to 0 if lower than 3.0.3
#define NS_303 1

// upgrade enabled/disable
#define CYBERNETICS		1		// Set to "0" to disable the Cybernetics upgrade
#define REINFORCEARMOR		1		// Set to "0" to disable the Reinforced Armor upgrade
#define NANOARMOR		1		// Set to "0" to disable the Nano Armor upgrade
#define ETHTRACKING		1		// Set to "0" to disable the Ethereal Tracking upgrade
#define STATICFIELD		1		// Set to "0" to disable the Static Field upgrade
#define WELDOVERBASE		1		// Set to "0" to disable normal welders from welding above the base max armor when the target has Reinforced Armor
#define URANUIMAMMO		1		// Set to "0" to disable the Uranium Ammunition upgrade

#define THICKSKIN		1		// Set to "0" to disable the Thickened Skin upgrade
#define ETHSHIFT		1		// Set to "0" to disable the Ethereal Shift upgrade
#define BLOODLUST		1		// Set to "0" to disable the Blood Lust upgrade
#define HUNGER			1		// Set to "0" to disable the Hunger upgrade
#define SENSEOFANCIENTS		1		// Set to "0" to disable the Sense of Ancients upgrade

// upgrade costs
#define CYBERNETICSCOST		1		// Set to the amount of points you want Cybernetics to cost
#define REINFORCEARMORCOST	1		// Set to the amount of points you want Reinforced Armor to cost
#define NANOARMORCOST		1		// Set to the amount of points you want Nano Armor to cost
#define ETHTRACKINGCOST		1		// Set to the amount of points you want Ethereal Tracking to cost
#define STATICFIELDCOST		2		// Set to the amount of points you want Static Field to cost
#define URANUIMAMMOCOST		1		// Set to the amount of points you want Uranium Ammunition to cost

#define THICKSKINCOST		1		// Set to the amount of points you want Thickened Skin to cost
#define ETHSHIFTCOST		1		// Set to the amount of points you want Ethereal Shift to cost
#define BLOODLUSTCOST		1		// Set to the amount of points you want Blood Lust to cost
#define HUNGERCOST		1		// Set to the amount of points you want Hunger to cost
#define SENSEOFANCIENTSCOST	1		// Set to the amount of points you want Sense of Ancients to cost

// upgrade max level
#define CYBERNETICSMAX		5		// Set to the max level of the Cybernetics upgrade you want possible (0 is infinate)
#define REINFORCEARMORMAX	5		// Set to the max level of the Rienforced Armor upgrade you want possible (0 is infinate)
#define NANOARMORMAX		5		// Set to the max level of the Nano Armor upgrade you want possible (0 is infinate)
#define ETHTRACKINGMAX		5		// Set to the max level of the Ethereal Tracking upgrade you want possible (0 is infinate)
#define STATICFIELDMAX		5		// Set to the max level of the Static Field upgrade you want possible (0 is infinate)
#define URANUIMAMMOMAX		5		// Set to the max level of the Uranium Ammunition upgrade you want possible (0 is infinate)

#define THICKENEDSKINMAX	5		// Set to the max level of the Thickened Skin upgrade you want possible (0 is infinate)
#define ETHSHIFTMAX		5		// Set to the max level of the Ethereal Shift upgrade you want possible (0 is infinate)
#define BLOODLUSTMAX		5		// Set to the max level of the Blood Lust upgrade you want possible (0 is infinate)
#define HUNGERMAX		5		// Set to the max level of the Hunger upgrade you want possible (0 is infinate)
#define SENSEOFANCIENTSMAX	5		// Set to the max level of the Sense of Ancients upgrade you want possible (0 is infinate)


// CYBERNETICS options
#define CYBERNETICSLEVEL	5		// Required player level to get the Cybernetics upgrade
#define SPEED_MA		20		// Amount of speed normal marines and jet-packers get per level of cybernetics
#define SPEED_HA		10		// Amount of speed heavy marines get per level of cybernetics

// REINFORCEARMOR options
#define REINFORCEARMORLEVEL	0		// Required player level to get the Reinforced Armor upgrade
#define ARMOR_MA		10		// Amount of armor normal marines and jet-packers get per level of reinforced armor
#define ARMOR_HA		20		// Amount of armor heavy marines get per level of reinforced armor

// NANOARMOR options
#define NANOARMORLEVEL		0		// Required player level to get the Nano Armor upgrade
#define SELFWELD_MA		2		// Amount of armor normal marines and jet-packers self-weld per second per level of nano armor
#define SELFWELD_HA		4		// Amount of armor heavy marines self-weld per second per level of nano armor

// ETHTRACKING options
#define ETHTRACKINGLEVEL	0		// Required player level to get the Ethereal Tracking upgrade
#define ETHTRACKINGINITIALRANGE	400		// Amount of range the Ethereal Tracking upgrade starts out with
#define ETHTRACKLEVELRANGE	100		// Amount of range the Ethereal Tracking upgrade gains per level beyond the first

// STATICFIELD options
#define STATICFIELDLEVEL	0		// Required player level to get the Static Field upgrade
#define STATICFIELDINITIALRANGE	400		// Amount of range the Static Field upgrade starts out with
#define STATICFIELDLEVELRANGE	50		// Amount of range the Static Field upgrade gains per level
#define STATICFIELDNUMERATORIN	1		// The numerator for the fraction of an aliens max health that will be taken from it when it enters the Static Field (initial valaue)
#define STATICFIELDNUMERATORLV	1		// The increase in numerator for the Static Field upgrade per level
#define STATICFIELDDENOMENATOR	8		// The denomenator in the Static Field fraction
#define MAXSTATICNUMERATOR	5		// The maximum numerator for the Static Field fraction, I suggest keeping it at 5 or below to prevent aliens becoming too weak

// URANUIMAMMO options
#define URANUIMAMMO_BULLET	17		// Amount of percent the Bullets damage will be improved each level
#define URANUIMAMMO_GREN	10		// Amount of percent the Grenades damage will be improved each level

// THICKSKIN options
#define THICKENEDSKINLEVEL	0		// Required player level to get the Thickened Skin upgrade
#define HEALTHSKULK		10.0		// Amount of health Skulk's get per level of Thickened Skin
#define HEALTHGORGE		25.0		// Amount of health Gorge's get per level of Thickened Skin
#define HEALTHLERK		15.0		// Amount of health Lerk's get per level of Thickened Skin
#define HEALTHFADE		25.0		// Amount of health Fade's get per level of Thickened Skin
#define HEALTHONOS		30.0		// Amount of health Oni get per level of Thickened Skin
#define HEALTHGESTATE		20.0		// Amount of health Embryo's get per level of Thickened Skin

// ETHSHIFT options
#define ETHSHIFTLEVEL		5		// Required player level to get the Ethereal Shift upgrade
#define SHIFTINITIAL		1.0		// Amount of initial invisibility time for Ethereal Shift (seconds)
#define SHIFTLEVEL		0.25		// Amount of invisibility time that is added to the initial amount for every level gained in Ethereal Shift after 1st (seconds)
#define SHIFTCLASSMULTI		2		// Set to how much a Skulk's, Lerk's and Gorge's SHIFTLEVEL should be increased (default 2 times longer shift than fade or onos)
#define	ONOS_SHIFT		1		// Set to "0" to disable Ethernal Shift for Onos

// BLOODLUST options
#define BLOODLUSTLEVEL		0		// Required player level to get the Blood Lust upgrade
#define BLOODLUSTSPEED		4		// Amount of energy added every 0.1 seconds per level of Blood Lust (note that the normal energy gain speed is ~7 and with adrenaline ~15)

// HUNGER options
#define HUNGERLEVEL		0		// Required player level to get the Hunger upgrade
#define HUNGERSPEED		6		// Amount of speed an alien gets per kill per level of hunger for the time that the hunger bonus last
#define HUNGERHEALTH		10		// Percent of max health that is added to the alien's current health per level (when it kills something)
#define HUNGERINITIALTIME	3.0		// Amount of initial time that the Hunger upgrade's bonuses last (seconds)
#define HUNGERLEVELTIME		1.0		// Amount of time that is added to the initial Hunger upgrade's bonus time (seconds)

// SENSEOFANCIENTS options
#define SOA_PARASITE_INIT	200		// Amount of range the SoA upgrade for Skulks starts out with
#define SOA_PARASITE_ADD	30		// Amount of range the SoA upgrade for Skulks gains per level
#define SOA_PARASITE_DMG	3		// Amount of percent the Parasite will be improved each level
#define SOA_HEALSPRAY_DMG	30		// Amount of percent the Healspray will be improved each level
#define SOA_GASDAMAGE		3		// Amount of damage Marines with HA get by gas
#define SOA_BLINK_ENERGY_BONUS	20		// Amount of percent the Blink's energy requirement will be reduced each level
#define SAO_DEVOUR_ADDER	5		// Amount of levels needed to devour one more player (starting with level 1, eg: setting to 5 means with level 1, 6, 11,... one more player)
#define SOA_DEVOURTIME_INIT	3.0		// Amount of time player needs to wait to enable 2nd Devour
#define SOA_DEVOURTIME_BONUS	0.5		// Amount of time decreasing the time to wait for 2nd Devour each level
#define SOA_GESTATE_ARMOR_ADD	15		// Amount of Armor bonus a gestating alien gets each level

// Adjust level needed for each level (starting with 11)
#define CUSTOM_LEVELS			0	// Set this to "1" to use the configs below
#define BASE_XP_TO_NEXT_LEVEL		550	// XP needed to get to next level (level 10 = 2700 XP + 550 = level 11)
#define NEXT_LEVEL_XP_MODIFIER		50	// XP that is added to XP_TO_NEXT_LEVEL each level up (eg: level 11 => 2700 + 550 => level 12 / level 12 => 3250 + 550 + 50 => level 13)


// *** DO NOT MODIFY BELOW EXCEPT YOU KNOW WHAT YOU ARE DOING *** //

// gives Extralevels2 Rework 16k of memory for variables
#pragma dynamic 4096

#define MARINE			1
#define ALIEN			2
#define HUD_CHANNEL		3

new plugin_author[] = "White Panther (orig. by Cheeserm!)"
new plugin_version[] = "1.0.0"

new g_informsshown[33]
new g_authorsshown[33]
new g_extralevels[33]
new g_points[33]
new g_maxPlayers
new g_lastxp[33]

new g_speedupgrade[33]
new g_armorupgrade[33]
new g_selfweldupgrade[33]
new g_ethtrackingupgrade[33]
new g_staticfieldupgrade[33]
new g_uranuimammo[33]

new g_healthupgrade[33]
new g_etherealshiftupgrade[33]
new g_justshifted[33]
new g_detected[33]
new g_bloodlustupgrade[33]
new g_hungerupgrade[33]
new g_lastfragcheck[33]
new g_justkilled[33]
new g_soaupgrade[33]

new Float:g_HungerDurr[33]
new Float:g_LastShift[33]
new Float:g_ShiftTime[33]
new Float:g_LastRegen[33]
new Float:g_LastHiveRegen[33]
new Float:g_LastMetabolizeRegen[33]
new Float:g_LastWeld[33]
new Float:g_LastBloodLust[33]
new Float:g_SoA_devourtime[33]

// new vars by White Panther
#define SND_STOP		(1<<5)

#define BASE_DAMAGE_HG		20.0	// Pistol
#define BASE_DAMAGE_LMG		10.0	// Machinegun
#define BASE_DAMAGE_SG		17.0	// Shotgun
#define BASE_DAMAGE_HMG		20.0	// Heavymachingun
#define BASE_DAMAGE_GL		125.0	// Grenadelauncher
#define BASE_DAMAGE_GREN	100.0	// Handgrenade
#define BASE_DAMAGE_PARA	10.0	// Parasite
#define BASE_DAMAGE_HEAL	15.6	// Healspray

new marine_rang[29][] =
{
	"KAZE XTREME!", "Legendary Dreadnought", "Dreadnought", "Planetary Elite, Class1",
	"Planetary Elite", "Planetary Fighter, Class1", "Planetary Fighter", "Planetary Guard, Class1", "Planetary Guard",
	"Planetary Patrol, Class1", "Planetary Patrol", "Spec ops, Class1","Spec Ops", "Battle Master",
	"5 star*****", "4 star****", "3 star***", "2 star**", "1 star*",
	
	"General", "Field Marshal", "Major", "Commander", "Captain",
	"Lieutenant", "Sergant", "Corporal", "Private First Class", "Private"
}

new alien_rang[29][] =
{
	"FAMINE SPIRIT!", "Black Ethergaunt", "White Ethergaunt", "Red Etherguant",
	"Green Etherguant", "Xerfilstyx", "Paeliryon","Xerfilyx", "Myrmyxicus",
	"Wastrilith", "Skulvynn", "Alkilith", "Klurichir", "Maurezhi",
	"Shatorr", "Kelubar", "Faarastu", "Cronotyryn", "Ancient Behemoth",
	
	"Behemoth", "Nightmare", "Eliminator", "Slaughterer", "Rampager",
	"Attacker", "Ambusher", "Minion", "Xenoform", "Hatchling"
}

new level_cvar_list[19][] =
{
	"amx_XlevelS", "amx_XlevelR", "amx_XlevelQ", "amx_XlevelP", "amx_XlevelO",
	"amx_XlevelN", "amx_XlevelM", "amx_XlevelL", "amx_XlevelK", "amx_XlevelJ",
	"amx_XlevelI", "amx_XlevelH", "amx_XlevelG", "amx_XlevelF", "amx_XlevelE",
	"amx_XlevelD", "amx_XlevelC", "amx_XlevelB", "amx_XlevelA"
}

#define MAX_SOUND_FILES		20
new sound_files[MAX_SOUND_FILES][] =
{
	"misc/elecspark3.wav",
	"weapons/metabolize1.wav", "weapons/metabolize2.wav", "weapons/metabolize3.wav",
	"weapons/welderidle.wav",		// selfweld in progress
	"weapons/welderstop.wav",		// selfweld done
	"weapons/welderhit.wav",		// selfweld in progress 2
	"misc/a-levelup.wav",			// levelup sound aliens
	"misc/levelup.wav",			// levelup sound marines
	"misc/startcloak.wav",
	"misc/endcloak.wav",
	"misc/scan.wav",
	"weapons/primalscream.wav",
	"weapons/chargekill.wav",
	"misc/regeneration.wav",
	"player/role3_spawn1.wav",
	"player/role4_spawn1.wav",
	"player/role5_spawn1.wav",
	"player/role6_spawn1.wav",
	"player/role7_spawn1.wav"
}

enum
{
	sound_elecspark = 0,
	sound_metabolize1,
	sound_metabolize2,
	sound_metabolize3,
	sound_welderidle,
	sound_welderstop,
	sound_welderhit,
	sound_Alevelup,
	sound_Mlevelup,
	sound_cloakstart,
	sound_cloakend,
	sound_scan,
	sound_primalscream,
	sound_chargekill,
	sound_regen,
	gestate_finished_first
}

#define ALIEN_UP_ARRAY_START	6
new upgrade_names[11][] =
{
	"Cybernetics",
	"Reinforced Armor",
	"Nano Armor",
	"Ethereal Tracking",
	"Static Field",
	"Uranium Ammunition",
	"Thickened Skin",
	"Ethereal Shift",
	"Blood Lust",
	"Hunger",
	"Sense of Ancients"
}

new rand_para_chance[30] =
{
	9, 13, 27, 32, 46, 59, 65, 74, 88, 97,
	3, 12, 29, 36, 41, 55, 63, 76, 82, 93,
	4, 17, 23, 38, 44, 58, 60, 78, 84, 91
}

new viewmodels[13][] =
{
	"models/v_kn.mdl", "models/v_hg.mdl", "models/v_mg.mdl",
	"models/v_sg.mdl", "models/v_hmg.mdl", "models/v_gg.mdl",
	
	"models/v_kn_hv.mdl", "models/v_hg_hv.mdl", "models/v_mg_hv.mdl",
	"models/v_sg_hv.mdl", "models/v_hmg_hv.mdl", "models/v_gg_hv.mdl",
	
	"models/v_pick.mdl"
}

new weapmodels[9][] =
{
	"models/p_kn.mdl", "models/p_hg.mdl", "models/p_mg.mdl",
	"models/p_sg.mdl", "models/p_hmg.mdl", "models/p_gg.mdl",
	
	"models/p_pick.mdl", "models/p_hg_gnome.mdl", "models/p_mg_gnome.mdl"
}

new alien_weapon_list[20][] =
{
	"weapon_bitegun", "weapon_parasite", "weapon_leap", "weapon_divinewind",		// Skulk
	"weapon_spit", "weapon_healingspray", "weapon_bilebombgun", "weapon_webspinner",	// Gorge
	"weapon_bite2gun", "weapon_spore", "weapon_umbra", "weapon_primalscream",		// Lerk
	"weapon_swipe", "weapon_blink", "weapon_metabolize", "weapon_acidrocketgun",		// Fade
	"weapon_claws", "weapon_devour", "weapon_stomp", "weapon_charge"			// Onos
}

new alien_weapon_num[20] =
{
	5, 10, 21, 12,	// Skulk
	2, 27, 25, 8,	// Gorge
	6, 3, 23, 24,	// Lerk
	7, 11, 9, 26,	// Fade
	1, 30, 29, 22,	// Onos
}

new Float:alien_base_hp_ap[18] =
{
	70.0, 150.0, 125.0, 300.0, 700.0, 200.0,
	
	10.0, 50.0, 30.0, 150.0, 600.0, 150.0,
	30.0, 100.0, 60.0, 250.0, 950.0, 150.0
}

new clcmd_menu_text[] = "saying this will bring up the menu of ExtraLevels2 Rework upgrades"
new clcmd_help_text[] = "saying this will bring up a help text"

new player_team[33]
new lastlevel[33]
new player_level[33] = {1,...}			// you start with level 1
new players_xp_to_next_lvl[33] = {100,...}	// level 2 is reached with 100 XP
new player_base_level_xp[33]

new upgrade_choice[33] = {-1,...}
new g_player_used_weap_imp[33][5]
new alien_gestate_points[33]
new just_respawned[33]
new player_gestating_emu[33]
new Float:player_gestate_time_emu[33]
new player_gestate_emu_class[33]
new player_gestate_extracheck[33]
new Float:player_gestate_hp[33], Float:player_gestate_ap[33]
new Float:player_gestate_origin[33][3]
new ScoreInfo_data[33][5]

// max default upgrades + ( if_available * cost * amount_of_upgrades )
new max_marine_points = 20 + CYBERNETICS*CYBERNETICSCOST*CYBERNETICSMAX + REINFORCEARMOR*REINFORCEARMORCOST*REINFORCEARMORMAX + NANOARMOR*NANOARMORCOST*NANOARMORMAX + ETHTRACKING*ETHTRACKINGCOST*ETHTRACKINGMAX + STATICFIELD*STATICFIELDCOST*STATICFIELDMAX + URANUIMAMMO*URANUIMAMMOCOST*URANUIMAMMOMAX
new max_alien_points = 16 + THICKSKIN*THICKSKINCOST*THICKENEDSKINMAX + ETHSHIFT*ETHSHIFTCOST*ETHSHIFTMAX + BLOODLUST*BLOODLUSTCOST*BLOODLUSTMAX + HUNGER*HUNGERCOST*HUNGERMAX + SENSEOFANCIENTS*SENSEOFANCIENTSCOST*SENSEOFANCIENTSMAX

new gnome_id[2], gnome_base_armor, gnome_max_armor, gnome_speed

new spore_event, cloak_event, DeathMsg_id, ScoreInfo_id, HideWeapon_id, Progress_id, WeapPickup_id, max_entities

new welding_self[33], welding_overmax[33], welded_overmax[33]
new fresh_parasite[33]
new player_in_spore[33], spore_data[90][5], spore_num
new g_fade_blinked[33]
new my_digester[33], currently_digesting[33], redeemed[33]
new g_SoA_devourtime_multiply[33] = {1,...}
new g_soa_just_devoured[33], g_SoA_player_amount[33], devouring_players_num[33]

new Float:nanoweld_time[33], Float:ethtracking_staticfield_time[33]
new Float:health_time[33], Float:digest_time[33], Float:g_nextdevour_time[33]
new Float:parasite_time[33]
new Float:g_fade_energy[33]
new Float:before_redeem_orig[33][3]

new extralevels_running, is_gnome_running


public plugin_init( )
{
	register_plugin("ExtraLevels2 Rework", plugin_version, plugin_author)
	register_cvar("extralevels2_rework_version", plugin_version, FCVAR_SERVER)
	
	if ( ns_is_combat() )
	{
		extralevels_running = 1
		g_maxPlayers = get_maxplayers()
		max_entities = get_global_int(GL_maxEntities)
		spore_event = precache_event(1, "events/SporeCloud.sc")
		cloak_event = precache_event(1, "events/StartCloak.sc")
		DeathMsg_id = get_user_msgid("DeathMsg")
		ScoreInfo_id = get_user_msgid("ScoreInfo")
		HideWeapon_id = get_user_msgid("HideWeapon")
		Progress_id = get_user_msgid("Progress")
		WeapPickup_id = get_user_msgid("WeapPickup")
		
		register_cvar("amx_notifyme", "3")					// Set to the number of times you want the "ExtraLevels2 Rework" message to be displayed on spawn.
		register_cvar("amx_instruct", "3")					// Set to the number of times you want the "type /help for more info" message to be displayed on spawn.
		register_cvar("amx_huddisplay", "1")					// Set to 1 to get the normal levels display, set to 2 to get the alternate levels display. If you change from "2" to "1" in the same round, you may expirience some problems with the hud levels display for the round!
		register_cvar("amx_maxlevel", "50")
		
		new Float:level_step = float(get_cvar_num("amx_maxlevel") - 10) / 20.0
		new level_increaser = floatround(level_step, floatround_floor)
		new Float:levels_remaining
		new level_to_set = 10
		for ( new k = 0; k < 19; k++ )
		{
			level_to_set += level_increaser
			levels_remaining += level_step
			new level_difference = floatround(levels_remaining - float(level_increaser), floatround_floor)
			if ( level_difference >= 1 )
			{
				level_to_set += level_difference
				levels_remaining -= float(level_difference)
			}else
				levels_remaining -= float(level_increaser)
			
			register_cvar(level_cvar_list[18-k], "")
			set_cvar_num(level_cvar_list[18-k], level_to_set)
		}
		
		register_event("ResetHUD", "eResetHUD", "b")
		register_event("DeathMsg", "eDeath", "a")
		register_event("TeamInfo", "eTeamChanges", "ab")
		register_event("Damage", "eDamage", "b", "2!0")
		register_message(ScoreInfo_id, "editScoreInfo")
		
		register_menucmd(register_menuid("Help:"), MENU_KEY_0, "actionMenuHelp")
		register_menucmd(register_menuid("Choose an upgrade to view information about:"), MENU_KEY_1|MENU_KEY_2|MENU_KEY_3|MENU_KEY_4|MENU_KEY_5|MENU_KEY_6|MENU_KEY_0, "actionMenu")
		for ( new j = 0; j < 11; j++ )
		{
			new upgrade_name[24]
			format(upgrade_name, 23, "%s:", upgrade_names[j])
			register_menucmd(register_menuid(upgrade_name), MENU_KEY_2|MENU_KEY_0, "choice_one_to_six")
			
		}
		
		register_impulse(100, "etherealshift")
		register_clcmd("say /xmenu", "showMenu", 0, clcmd_menu_text)
		register_clcmd("say_team /xmenu", "showMenu", 0, clcmd_menu_text)
		register_clcmd("say xmenu", "showMenu", 0, clcmd_menu_text)
		register_clcmd("say_team xmenu", "showMenu", 0, clcmd_menu_text)
		register_clcmd("say /xhelp", "showHelpMenu", 0, clcmd_help_text)
		register_clcmd("readyroom", "block_exploit")

		set_task(0.25, "checkLevels_showXP", 100, _, _, "b")	// Test for XP gained from methods other than killing someone + Show hud message
		
		register_forward(FM_PlaybackEvent, "PlaybackEvent")
		set_task(1.0, "emulated_spore_timer", 1000, _, _, "b")
		
		new name[32], version[32], author[32], filename[32], status[32]
		for ( new i = 0; i < get_pluginsnum(); i++ )
		{
			get_plugin(i, filename, 31, name, 31, version, 31, author, 31, status, 31)
			if ( equal(filename, "gnome.amxx") != -1 )
				if ( equal(status, "running") || equal(status, "debug") )
					is_gnome_running = 1
		}
		
		new fakeEnt = find_ent_by_class(-1, "ServerFrameFake")
		if ( fakeEnt <= 0 )
		{
			fakeEnt = create_entity("info_target")
			entity_set_string(fakeEnt, EV_SZ_classname, "ServerFrameFake")
			entity_set_float(fakeEnt, EV_FL_nextthink, halflife_time() + 0.01)
		}
		register_think("ServerFrameFake", "server_frame_fake")
	}
}

public plugin_precache( )
{
	for ( new file = 0; file < MAX_SOUND_FILES; file++ )
	{
		new temp_file[64]
		format(temp_file, 63, "sound/%s", sound_files[file])
		if ( file_exists(temp_file) )
			precache_sound(sound_files[file])
	}
}

public client_disconnect( id )
{
	if ( extralevels_running )
		reset_upgrades_vars(id)
}

public client_connect( id )
{
	if ( extralevels_running )
		reset_upgrades_vars(id)
}

public client_changeteam( id , newteam , oldteam )
{
	if ( extralevels_running )
	{
		if ( get_cvar_num("zilla_GorgZilla") )
			return
		
		if ( 1 <= newteam <= 4 && newteam != oldteam )
			reset_upgrades_vars(id, 1)
		else
		{
			client_cmd(id, "slot10")
			player_team[id] = 0
		}
	}
}

public client_changeclass( id , newclass , oldclass )
{
	if ( extralevels_running )
	{
		if ( get_cvar_num("zilla_GorgZilla") )
			return
		
		if ( oldclass == CLASS_GESTATE )
		{
			if ( newclass == CLASS_GORGE )
			{
				alien_gestate_points[id] = 1
				if ( g_soaupgrade[id] )
					set_task(0.2, "set_weapon_damage_timer", 300 + id)
			}else if ( newclass == CLASS_LERK )
				alien_gestate_points[id] = 2
			else if ( newclass == CLASS_FADE )
				alien_gestate_points[id] = 3
			else if ( newclass == CLASS_ONOS )
				alien_gestate_points[id] = 4
			
			player_gestate_extracheck[id] = 0
		}else if ( newclass == CLASS_GESTATE )
		{
			if ( g_soaupgrade[id] )
				entity_set_float(id, EV_FL_armorvalue, entity_get_float(id, EV_FL_armorvalue) + SOA_GESTATE_ARMOR_ADD * g_soaupgrade[id])
			
			client_cmd(id, "slot10")
		}
	}
}

public client_spawn( id )
{
	if ( get_cvar_num("zilla_GorgZilla") )
		return
	
	just_respawned[id] = 1
	player_gestate_extracheck[id] = 1
	if ( g_uranuimammo[id] || g_soaupgrade[id] )
		set_task(0.2, "set_weapon_damage_timer", 300 + id)
	
	if ( player_team[id] == MARINE )
	{	// only marines can receive armor upgrade
		if ( g_armorupgrade[id] )
		{	// only marines with armor upgrade can get it
			new Float:armorvalue, Float:maxarmor
			get_max_armor(id, armorvalue, maxarmor)
			entity_set_float(id, EV_FL_armorvalue, maxarmor)
		}
	}else if( player_team[id] == ALIEN && g_healthupgrade[id] )
	{
		new Float:basehealthvalue, Float:healthadd
		get_base_add_health(id, basehealthvalue, healthadd)
		entity_set_float(id, EV_FL_health, basehealthvalue + healthadd)
	}
}

public client_impulse( id , impulse )
{
	if ( get_cvar_num("zilla_GorgZilla") )
		return PLUGIN_CONTINUE
	
	if ( g_uranuimammo[id] || g_soaupgrade[id] )
	{
		if ( player_team[id] == MARINE )
		{
			new parm[3]
			if ( impulse == 64 )
			{
				parm[1] = WEAPON_SHOTGUN
				parm[2] = 1
			}else if ( impulse == 65 )
			{
				parm[1] = WEAPON_HMG
				parm[2] = 2
			}else if ( impulse == 66 )
			{
				parm[1] = WEAPON_GRENADE_GUN
				parm[2] = 3
			}else if ( impulse == 37 )
			{
				parm[1] = WEAPON_GRENADE
				parm[2] = 4
			}
			
			if ( parm[1] )
			{
				parm[0] = id
				set_task(0.1, "check_weapons_after_impulse", 400 + id, parm, 3)
			}
		}else if ( player_team[id] == ALIEN )
		{
			if ( ns_get_class(id) == CLASS_ONOS )
			{
				if ( devouring_players_num[id] )
				{
					if ( 101 <= impulse <= 103 || 107 <= impulse <= 112 || impulse == 118 || impulse == 226 )
						return PLUGIN_HANDLED
				}
			}
		}
	}
	return PLUGIN_CONTINUE
}

public server_frame_fake( fakeent_id )
{
	if ( get_cvar_num("zilla_GorgZilla") )
		return
	
	if ( extralevels_running ){
		new Float:onos_devour_origin[3]
		for ( new id = 1; id <= g_maxPlayers; id++ )
		{
			if ( !is_user_connected(id) )
				continue
			
			if ( !is_user_alive(id) )
			{
				if ( g_soaupgrade[id] )
				{
					entity_get_vector(id, EV_VEC_origin, before_redeem_orig[id])
					free_digested_players(id)
				}
				continue
			}
			
			if ( !player_team[id] )		// player has not joined a team
				continue
			
			new ammo, reserve, got_bloodlust_bonus
			new weaponid = get_user_weapon(id, ammo, reserve)
			new player_attacking = ( entity_get_int(id, EV_INT_button) & IN_ATTACK )
			new Float:gametime = get_gametime()
			
			// Emulate gestating
			if ( player_gestating_emu[id] )
			{
				if ( player_gestating_emu[id] == 1 )
				{
					player_gestate_hp[id] = entity_get_float(id, EV_FL_health)
					player_gestate_ap[id] = entity_get_float(id, EV_FL_armorvalue)
					
					if ( player_gestate_extracheck[id] )		// if after spawn no real gestate was done, we need to set gestate class again (otherwise it will be buggy)
						entity_set_int(id, EV_INT_iuser3, 8)
					
					player_gestate_time_emu[id] = gametime
					
					player_gestating_emu[id]++
				}else if ( player_gestating_emu[id] == 2 )
				{
					client_cmd(id, "spk hud/points_spent")
					
					gestate_messages(id, 1, 1, 10, 8)
					
					new array_position = player_gestate_emu_class[id] - 1
					new carapace_add = ns_get_mask(id, MASK_CARAPACE) * 6
					if ( player_gestate_hp[id] > alien_base_hp_ap[array_position] )
						player_gestate_hp[id] = alien_base_hp_ap[array_position]
					if ( player_gestate_ap[id] > alien_base_hp_ap[6 + array_position + carapace_add] )
						player_gestate_ap[id] = alien_base_hp_ap[6 + array_position + carapace_add]
					
					entity_set_float(id, EV_FL_health, 200.0 / alien_base_hp_ap[array_position] * player_gestate_hp[id])
					entity_set_float(id, EV_FL_armorvalue, 150.0 / alien_base_hp_ap[6 + array_position + carapace_add] * player_gestate_ap[id])
					
					player_gestating_emu[id]++
				}else if ( player_gestating_emu[id] == 3 )
				{
					// normally 100.0 / 1.0 but that is 100.0 / and 1000.0 = 100.0 * 10.0
					entity_set_float(id, EV_FL_fuser3, 1000.0 * ( gametime - player_gestate_time_emu[id] ))
				}else if ( player_gestating_emu[id] == 4 )
				{
					new array_position
					for ( new j = 0; j < 4; j++ )
					{
						array_position = j + ( 4 * ( player_gestate_emu_class[id] - 1 ) )
						message_begin(MSG_ONE, WeapPickup_id, {0,0,0}, id)
						write_byte(alien_weapon_num[array_position])
						message_end()
						
						ns_give_item(id, alien_weapon_list[array_position])
					}
					
					array_position = ( player_gestate_emu_class[id] - 1 )
					new Float:cur_health = entity_get_float(id, EV_FL_health)
					if ( cur_health > alien_base_hp_ap[5] )
						cur_health = alien_base_hp_ap[5]
					new Float:cur_armor = entity_get_float(id, EV_FL_armorvalue)
					if ( cur_armor > alien_base_hp_ap[6 + 5] )
						cur_armor = alien_base_hp_ap[6 + 5]
					
					entity_set_float(id, EV_FL_health, alien_base_hp_ap[array_position] / 200.0 * cur_health)
					entity_set_float(id, EV_FL_armorvalue, alien_base_hp_ap[6 + array_position + ns_get_mask(id, MASK_CARAPACE) * 6] / 150.0 * cur_armor)
					
					if ( player_gestate_emu_class[id] == CLASS_ONOS )
					{
						player_gestate_origin[id][2] += 18.0
						entity_set_origin(id, player_gestate_origin[id])
					}
					
					emit_sound(id, CHAN_BODY, sound_files[gestate_finished_first + player_gestate_emu_class[id] - 1], 1.0, ATTN_NORM, 0, PITCH_NORM)
					
					player_gestating_emu[id] = 0
				}
				if ( gametime - player_gestate_time_emu[id] >= 1.0 && player_gestating_emu[id] )
				{
					if ( CLASS_FADE <= player_gestate_emu_class[id] <= CLASS_ONOS )
					{
						if ( !(entity_get_int(id, EV_INT_flags) & FL_DUCKING) )
							entity_set_int(id, EV_INT_flags, entity_get_int(id, EV_INT_flags) + FL_DUCKING )
					}
					
					entity_get_vector(id, EV_VEC_origin, player_gestate_origin[id])
					
					ns_set_mask(id, MASK_ALIEN_EMBRYO, 0)
					
					entity_set_float(id, EV_FL_fuser3, 1000.0)
					
					gestate_messages(id, 0, -1, player_gestate_emu_class[id] + 3, player_gestate_emu_class[id] + 2)	// scoreboard skulk = 4 not 1 AND iuser3 skulk = 3 not 1
					
					player_gestating_emu[id]++
				}
			}
			
			// Check for Ethereal Tracking and Static Field
			if ( ( g_ethtrackingupgrade[id] || g_staticfieldupgrade[id] ) && gametime - ethtracking_staticfield_time[id] > 1.0 )
			{
				ethtracking_staticfield_time[id] = gametime
				etherealtracking_staticfield(id)
			}
			// Check for Metabolize + Hive heal over max base health
			if ( g_healthupgrade[id] && gametime - health_time[id] >= 0.5 )
			{
				health_time[id] = gametime
				metabolize_hive_heal(id, gametime, weaponid, player_attacking)
			}
			// Weld over max base armor
			if ( WELDOVERBASE && weaponid == WEAPON_WELDER && player_attacking )
			{
				if ( !welded_overmax[id] )
				{
					if ( gametime - g_LastWeld[id] >= 0.7 )
					{
						g_LastWeld[id] = gametime
						weldoverbasemax(id)
					}
				}else if ( welding_overmax[id] || welded_overmax[id] )
				{
					emit_sound(id, CHAN_AUTO, sound_files[sound_welderhit], 0.0, ATTN_NORM, SND_STOP, PITCH_NORM)
					emit_sound(id, CHAN_STREAM, sound_files[sound_welderidle], 0.0, ATTN_NORM, SND_STOP, PITCH_NORM)
					welding_overmax[id] = 0
					welded_overmax[id] = 0
				}
			}
			
			// unshift
			new uncloakweapon = 0
			if ( weaponid != WEAPON_METABOLIZE && weaponid != WEAPON_BLINK && weaponid != WEAPON_UMBRA && weaponid != WEAPON_PRIMALSCREAM && weaponid != WEAPON_METABOLIZE && weaponid != WEAPON_LEAP )
				uncloakweapon = 1
			
			if ( g_justshifted[id] && ( g_detected[id] == 1 || ( g_etherealshiftupgrade[id] && ( gametime - g_LastShift[id] >= g_ShiftTime[id] || ( uncloakweapon == 1 && player_attacking ) ) ) ) )
			{
				entity_set_int(id, EV_INT_rendermode,0)
				if ( !ns_get_mask(id, MASK_SILENCE) )
				{
					if ( g_detected[id] == 0 )
						emit_sound(id, CHAN_ITEM, sound_files[sound_cloakend], 0.5, ATTN_NORM, 0, PITCH_NORM)
					
					if ( g_detected[id] == 1 )
					{
						emit_sound(id, CHAN_ITEM, sound_files[sound_scan], 0.5, ATTN_NORM, 0, PITCH_NORM)
						g_detected[id] = 0
					}
				}
				g_justshifted[id] = 0
			}
			
			// Blood Lust
			new Float:energy = entity_get_float(id, EV_FL_fuser3)
			if ( g_bloodlustupgrade[id] )
			{
				if ( gametime - g_LastBloodLust[id] >= 0.1 )
				{
					energy += ( BLOODLUSTSPEED * g_bloodlustupgrade[id] )
					if ( energy > 1000.0 )
						energy = 1000.0
					
					entity_set_float(id, EV_FL_fuser3, energy)
					g_LastBloodLust[id] = gametime
					got_bloodlust_bonus = 1
				}
			}
			
			// Hunger
			if ( g_hungerupgrade[id] )
			{
				new frags = get_user_frags(id)
				new Float:basehealthvalue, Float:healthadd
				get_base_add_health(id, basehealthvalue, healthadd)
				if ( g_justkilled[id] )		// keep this mask ON untill hungertime runs out
					ns_set_mask(id, 1048576, 1)
				
				new Float:max_health = basehealthvalue + healthadd
				if ( frags > g_lastfragcheck[id] )
				{
		   			emit_sound(id, CHAN_ITEM, sound_files[sound_primalscream], 0.5, ATTN_NORM, 0, PITCH_NORM)
					g_justkilled[id] = 1
					g_HungerDurr[id] = gametime + HUNGERINITIALTIME + ( HUNGERLEVELTIME * ( g_hungerupgrade[id] - 1 ) )
					
					new Float:hunger_healthadd = max_health / 100 * HUNGERHEALTH
					entity_set_float(id, EV_FL_health, entity_get_float(id, EV_FL_health) + hunger_healthadd)
					g_lastfragcheck[id] = frags
					ns_set_speedchange(id, ns_get_speedchange(id) + HUNGERSPEED * g_hungerupgrade[id])
				}else if ( gametime >= g_HungerDurr[id] && g_justkilled[id] )
				{
					if ( entity_get_float(id, EV_FL_health) > max_health )
						entity_set_float(id, EV_FL_health, max_health)
					
					emit_sound(id, CHAN_ITEM, sound_files[sound_chargekill], 0.5, ATTN_NORM, 0, PITCH_NORM)
					ns_set_speedchange(id, 0)
					g_justkilled[id] = 0
				}
			}
			
			new class = ns_get_class(id)
			// Sense of Ancients (Fade)
			if ( class == CLASS_FADE && g_soaupgrade[id] )
			{
				if ( weaponid == WEAPON_BLINK )
				{
					if ( player_attacking )
						g_fade_blinked[id] = 1
					else if ( g_fade_blinked[id] )
					{
						new Float:energy_bonus_from_bl, Float:energy_lost_with_blink
						if ( got_bloodlust_bonus )
						{
							energy_bonus_from_bl = energy - ( BLOODLUSTSPEED * g_bloodlustupgrade[id] )
							energy_lost_with_blink = g_fade_energy[id] - energy_bonus_from_bl
						}else
							energy_lost_with_blink = g_fade_energy[id] - energy
						
						energy += energy_lost_with_blink / 100 * ( SOA_BLINK_ENERGY_BONUS * g_soaupgrade[id] )
						entity_set_float(id, EV_FL_fuser3, energy)
						g_fade_blinked[id] = 0
					}
				}
				g_fade_energy[id] = energy
			}
			
			// Sense of Ancients (Onos)
			if ( my_digester[id] )
			{	// player being digested
				if ( id != currently_digesting[my_digester[id]] )
				{
					entity_get_vector(my_digester[id], EV_VEC_origin, onos_devour_origin)
					entity_set_origin(id, onos_devour_origin)
					entity_set_string(id, EV_SZ_viewmodel, "")
					entity_set_string(id, EV_SZ_weaponmodel, "")
					
					if ( gametime - digest_time[id] >= 1.0 )
					{
						new Float:cur_hp = entity_get_float(id, EV_FL_health)
						new Float:onos_hp = entity_get_float(my_digester[id], EV_FL_health)
						new Float:onos_ap = entity_get_float(my_digester[id], EV_FL_armorvalue)
						new carapace_bonus = ( ns_get_mask(my_digester[id], MASK_CARAPACE) ) ? 350 : 0
						if ( onos_hp < 700 )
						{
							if ( onos_hp + 15.0 <= 700 )
								entity_set_float(my_digester[id], EV_FL_health, onos_hp + 15.0)
							else
								entity_set_float(my_digester[id], EV_FL_health, 700.0)
						}else if ( onos_ap < ( 600 + carapace_bonus ) )
						{
							if ( onos_ap + 15.0 <= ( 600 + carapace_bonus ) )
								entity_set_float(my_digester[id], EV_FL_armorvalue, onos_ap + 15.0)
							else
								entity_set_float(my_digester[id], EV_FL_armorvalue, float(600 + carapace_bonus))
						}
						
						if ( cur_hp - 15.25 < 1.0 )
						{
							kill_digested_player(id, my_digester[id])
							reset_devour_vars(id)
						}else
							entity_set_float(id, EV_FL_health, cur_hp - 15.25)
						
						digest_time[id] = gametime
					}
				}
			}else if ( class == CLASS_ONOS )
			{	// digester
				if ( g_soaupgrade[id] )
				{
					if ( ns_get_mask(id, MASK_DIGESTING) )
					{
						if ( devouring_players_num[id] < g_SoA_player_amount[id] )
						{
							if ( !g_soa_just_devoured[id] )
							{
								g_soa_just_devoured[id] = 1
								g_nextdevour_time[id] = gametime
							}else if ( gametime - g_nextdevour_time[id] > g_SoA_devourtime[id] )
							{
								ns_set_mask(id, MASK_DIGESTING, 0)
								g_nextdevour_time[id] = gametime
								g_soa_just_devoured[id] = 0
							}
							devouring_players_num[id]++
						}
					}
				}
			}else
			{
				if ( ns_get_mask(id, MASK_DIGESTING) )
				{	// check if being digested
					new digested_by = get_my_onos(id)
					my_digester[id] = digested_by
					currently_digesting[digested_by] = id
				}
			}
		}
	}
	entity_set_float(fakeent_id, EV_FL_nextthink, halflife_time() + 0.01)
}

public eResetHUD( id )
{
	if ( get_cvar_num("zilla_GorgZilla") )
		return
	
	g_lastxp[id] = -1
	if ( g_authorsshown[id] < get_cvar_num("amx_notifyme") )
	{
		client_print(id, print_chat, "[ExtraLevels2 Rework] This server is running ExtraLevels2 Rework v%s by %s", plugin_version, plugin_author)
		g_authorsshown[id] += 1
	}
	if ( g_informsshown[id] < get_cvar_num("amx_instruct") )
	{
		client_print(id, print_chat, "type /xmenu or xmenu in chat to show a menu of extra upgrades. Type /xhelp for more info.")
		g_informsshown[id] += 1
	}
}

public eDeath( )
{
	if ( get_cvar_num("zilla_GorgZilla") )
		return
	
	new victim = read_data(2)
	if ( is_user_connected(victim) )
	{
		welding_self[victim] = 0
		emit_sound(victim, CHAN_STREAM, sound_files[sound_welderidle], 0.0, ATTN_NORM, SND_STOP, PITCH_NORM)
		
		if ( victim == currently_digesting[my_digester[victim]] )
			currently_digesting[my_digester[victim]] = 0
		
		if ( my_digester[victim] )
			devouring_players_num[my_digester[victim]]--
		
		reset_devour_vars(victim)
		reset_gestate_emu(victim)
		
		client_cmd(victim, "slot10")
	}
	
	set_task(0.1, "checkLevels_showXP", 200 + victim)	// Player died, XP must have changed, check everyone immediately.
}

public eTeamChanges( )
{
	new teamname[32], id = read_data(1)
	read_data(2, teamname, 31)
	if ( equal(teamname, "alien", 5) )
		player_team[id] = ALIEN
	else if ( equal(teamname, "marine", 6) )
		player_team[id] = MARINE
}

public eDamage( id )
{
	new attacker_weapon_id = entity_get_edict(id, EV_ENT_dmg_inflictor)
	if ( is_valid_ent(attacker_weapon_id) )
	{
		new attacker_weapon[51]
		entity_get_string(attacker_weapon_id, EV_SZ_classname, attacker_weapon, 50)
		if ( equal(attacker_weapon, "weapon_parasite") )
			fresh_parasite[id] = 0
	}
}

public editScoreInfo( )
{
	new id = get_msg_arg_int(1)
	// we do not need first arg (ID) nor last on (team, as only aliens get this and they are team 2)
	for ( new i = 0; i < 5; i++ )
		ScoreInfo_data[id][i] = get_msg_arg_int(i + 2)
}

public actionMenuHelp( id , key )
{
	return PLUGIN_HANDLED
}

public actionMenu( id , key )
{
	if ( get_cvar_num("zilla_GorgZilla") )
		return PLUGIN_HANDLED
	
	if( is_user_alive(id) )
	{
		new upgrlevel, pointcost
		new class = ns_get_class(id)
		new menuBody[512]
		new len
		new found_error
		new requirements_correct
		new level = player_level[id]
		new menu_keys = (1<<9)
		switch ( key )
		{
			case 0:{
				if ( player_team[id] == MARINE )
				{
					upgrade_choice[id] = 0
					upgrlevel = g_speedupgrade[id] + 1
					pointcost = CYBERNETICSCOST
					
					requirements_correct = ( g_points[id] >= CYBERNETICSCOST && level >= CYBERNETICSLEVEL && ( g_speedupgrade[id] < CYBERNETICSMAX || CYBERNETICSMAX == 0 ) )
					
					len = format(menuBody,511, "%s:^n^n", upgrade_names[upgrade_choice[id]])
					len += format(menuBody[len], 511-len, "Cybernetically enhances leg muscles to improve overall movement speed^nSpeed bonus is less for heavy armors^n^nRequires: Level %d, %d point%s^n^nNext level [%d]^n^n%s%s^n^n0. Exit^n^n^n^n^n^n^n", CYBERNETICSLEVEL, pointcost, pointcost > 1 ? "s" : "", upgrlevel, requirements_correct ? "2. Buy " : "", requirements_correct ? upgrade_names[upgrade_choice[id]] : "")
				}else if ( player_team[id] == ALIEN )
				{
					upgrade_choice[id] = ALIEN_UP_ARRAY_START
					upgrlevel = g_healthupgrade[id] + 1
					pointcost = THICKSKINCOST
					
					new Float:maxhealth
					if ( class == CLASS_SKULK )
						maxhealth = HEALTHSKULK * upgrlevel + 70.0
					else if ( class == CLASS_GORGE )
						maxhealth = HEALTHGORGE * upgrlevel + 150.0
					else if ( class == CLASS_LERK )
						maxhealth = HEALTHLERK * upgrlevel + 120.0
					else if ( class == CLASS_FADE )
						maxhealth = HEALTHFADE * upgrlevel + 300.0
					else if ( class == CLASS_ONOS )
						maxhealth = HEALTHONOS * upgrlevel + 700.0
					else if ( class == CLASS_GESTATE )
						maxhealth = HEALTHGESTATE * upgrlevel + 200.0
					
					requirements_correct = ( g_points[id] >= THICKSKINCOST && level >= THICKENEDSKINLEVEL && ns_get_mask(id, MASK_REGENERATION) && ns_get_mask(id, MASK_CARAPACE) && ( g_healthupgrade[id] < THICKENEDSKINMAX || THICKENEDSKINMAX == 0 ) )
					
					len = format(menuBody, 511, "%s:^n^n", upgrade_names[upgrade_choice[id]])
					len += format(menuBody[len], 511-len, "Thickens skin to increase health. Health bonus varies with life form^nMax health of [%d] (for current life form)^n^nRequires: Carapace , Regeneration , Level %d, %d point%s^n^nNext level [%d]^n^n%s%s^n^n0. Exit^n^n^n^n^n^n^n", floatround(maxhealth), THICKENEDSKINLEVEL, pointcost, pointcost > 1 ? "s" : "", upgrlevel, requirements_correct ? "2. Buy " : "", requirements_correct ? upgrade_names[upgrade_choice[id]] : "")
				}
			}
			case 1:{
				if ( player_team[id] == MARINE )
				{
					upgrade_choice[id] = 1
					new Float:maxarmor, Float:dummy
					get_max_armor(id, dummy, maxarmor)
					upgrlevel = g_armorupgrade[id] + 1
					pointcost = REINFORCEARMORCOST
					
					maxarmor += ( ns_get_class(id) == CLASS_HEAVY ? ARMOR_HA : ARMOR_MA )
					
					requirements_correct = ( g_points[id] >= REINFORCEARMORCOST && level >= REINFORCEARMORLEVEL && ns_get_mask(id, MASK_ARMOR3) && ( g_armorupgrade[id] < REINFORCEARMORMAX || REINFORCEARMORMAX == 0 ) )
					
					len = format(menuBody, 511, "%s:^n^n", upgrade_names[upgrade_choice[id]])
					len += format(menuBody[len], 511-len, "Reinforces armor with stronger materials^nMax armor of [%d] (for current armor type)^n^nRequires: Armor 3 , Level %d, %d point%s^n^nNext level [%d]^n^n%s%s^n^n0. Exit^n^n^n^n^n^n^n", floatround(maxarmor), REINFORCEARMORLEVEL, pointcost, pointcost > 1 ? "s" : "", upgrlevel, requirements_correct ? "2. Buy " : "", requirements_correct ? upgrade_names[upgrade_choice[id]] : "")
				}else if ( player_team[id] == ALIEN )
				{
					upgrade_choice[id] = ALIEN_UP_ARRAY_START + 1
					upgrlevel = g_etherealshiftupgrade[id] + 1
					pointcost = ETHSHIFTCOST
					
					new Float:shift_level = SHIFTLEVEL
					if ( class == CLASS_SKULK || class == CLASS_GORGE || class == CLASS_LERK )
						shift_level *= SHIFTCLASSMULTI
					new Float:maxtime = SHIFTINITIAL + shift_level * upgrlevel
					
					requirements_correct = ( g_points[id] >= ETHSHIFTCOST && level >= ETHSHIFTLEVEL && ns_get_mask(id, MASK_ADRENALINE) && ns_get_mask(id, MASK_CLOAKING) && level >= 5 && ( g_etherealshiftupgrade[id] < ETHSHIFTMAX || ETHSHIFTMAX == 0 ) )
					
					len = format(menuBody, 511, "%s:^n^n", upgrade_names[upgrade_choice[id]])
					len += format(menuBody[len], 511-len, "Shifts you to ethereal state making you invisible until you attack, or your time runs out^nPress flashlight key to activate ( costs energy! )")
					len += format(menuBody[len], 511-len, "^nMax shift time of [%.2f] second%s (for current life form)^n^nRequires: Adrenaline , Cloaking , Level %d, %d point%s^n^nNext level [%d]^n^n%s%s^n^n0. Exit^n^n^n^n^n^n^n^n", maxtime, maxtime == 1.0 ? "" : "s", ETHSHIFTLEVEL, pointcost, pointcost > 1 ? "s" : "", upgrlevel, requirements_correct ? "2. Buy " : "", requirements_correct ? upgrade_names[upgrade_choice[id]] : "")
				}
			}
			case 2:{
				if ( player_team[id] == MARINE )
				{
					upgrade_choice[id] = 2
					upgrlevel = g_selfweldupgrade[id] + 1
					pointcost = NANOARMORCOST
					
					new maxweld
					if (class == CLASS_HEAVY) 
						maxweld = SELFWELD_HA * upgrlevel
					else if ( class == CLASS_MARINE || class == CLASS_JETPACK )
						maxweld = SELFWELD_MA * upgrlevel
					
					requirements_correct = ( g_points[id] >= NANOARMORCOST && level >= NANOARMORLEVEL && g_armorupgrade[id] && ( g_selfweldupgrade[id] < NANOARMORMAX || NANOARMORMAX == 0 ) )
					
					len = format(menuBody, 511, "%s:^n^n", upgrade_names[upgrade_choice[id]])
					len += format(menuBody[len], 511-len, "Armor is created with tiny nano bots that weld your armor^nSelf weld per second is [+%d] (for current armor type)^n^nRequires: Reinforced Armor 1 , Level %d, %d point%s^n^nNext level [%d]^n^n%s%s^n^n0. Exit^n^n^n^n^n^n^n", maxweld, NANOARMORLEVEL, pointcost, pointcost > 1 ? "s" : "", upgrlevel, requirements_correct ? "2. Buy " : "", requirements_correct ? upgrade_names[upgrade_choice[id]] : "")
				}else if ( player_team[id] == ALIEN )
				{
					upgrade_choice[id] = ALIEN_UP_ARRAY_START + 2
					upgrlevel = g_bloodlustupgrade[id] + 1
					pointcost = BLOODLUSTCOST
					
					new bloodlust_percentage = ( BLOODLUSTSPEED * 100 / 15 ) * upgrlevel
					
					requirements_correct = ( g_points[id] >= BLOODLUSTCOST && level >= BLOODLUSTLEVEL && ns_get_mask(id, MASK_ADRENALINE) && ( g_bloodlustupgrade[id] < BLOODLUSTMAX || BLOODLUSTMAX == 0 ) )
					
					len = format(menuBody, 511, "%s:^n^n", upgrade_names[upgrade_choice[id]])
					len += format(menuBody[len], 511-len, "Increases your blood lust, increasing the rate at which you recharge energy^nEnergy recharge is increased by about [+%d%%]^n^nRequires: Adrenaline , Level %d, %d point%s^n^nNext level [%d]^n^n%s%s^n^n0. Exit^n^n^n^n^n^n^n", bloodlust_percentage, BLOODLUSTLEVEL, pointcost, pointcost > 1 ? "s" : "", upgrlevel, requirements_correct ? "2. Buy " : "", requirements_correct ? upgrade_names[upgrade_choice[id]] : "")
				}
			}
			case 3:{
				if ( player_team[id] == MARINE )
				{
					upgrade_choice[id] = 3
					upgrlevel = g_ethtrackingupgrade[id] + 1
					pointcost = ETHTRACKINGCOST
					
					// init range + ( levelrange * rangelevelmultiplier )
					new range = ETHTRACKINGINITIALRANGE + ( ETHTRACKLEVELRANGE * ( upgrlevel - 1 ) )
					
					requirements_correct = ( g_points[id] >= ETHTRACKINGCOST && level >= ETHTRACKINGLEVEL && ns_get_mask(id, MASK_MOTION) && ( g_ethtrackingupgrade[id] < ETHTRACKINGMAX || ETHTRACKINGMAX == 0 ) )
					
					len = format(menuBody, 511, "%s:^n^n", upgrade_names[upgrade_choice[id]])
					len += format(menuBody[len], 511-len, "Your visor has special enhancements that detect and undo ethereal activity^nWorks in a range of [%d]^n^nRequires: Motion Tracking , Level %d, %d point%s^n^nNext level [%d]^n^n%s%s^n^n0. Exit^n^n^n^n^n^n^n", range, ETHTRACKINGLEVEL, pointcost, pointcost > 1 ? "s" : "", upgrlevel, requirements_correct ? "2. Buy " : "", requirements_correct ? upgrade_names[upgrade_choice[id]] : "")
				}else if ( player_team[id] == ALIEN )
				{
					upgrade_choice[id] = ALIEN_UP_ARRAY_START + 3
					upgrlevel = g_hungerupgrade[id] + 1
					pointcost = HUNGERCOST
					
					new Float:hungermaxtime = HUNGERINITIALTIME + HUNGERLEVELTIME * upgrlevel
					new hungerspeed = HUNGERSPEED * upgrlevel
					
					requirements_correct = ( g_points[id] >= HUNGERCOST && level >= HUNGERLEVEL && g_bloodlustupgrade[id] && ( g_hungerupgrade[id] < HUNGERMAX || HUNGERMAX == 0 ) )
					
					len = format(menuBody, 511, "%s:^n^n", upgrade_names[upgrade_choice[id]])
					len += format(menuBody[len], 511-len, "Gives you bonuses when you kill an enemy, these bonuses last for the specified time^nLasts [%.2f] second%s, gain is [+%d%%] of maxhealth, effects of primalscream and speed increasement by [+%d] upon kill (bonuses stack)^n^n", hungermaxtime, hungermaxtime == 1.0 ? "" : "s", HUNGERHEALTH, hungerspeed)
					len += format(menuBody[len], 511-len, "Requires: Blood Lust , Level %d, %d point%s^n^nNext level [%d]^n^n%s%s^n^n0. Exit^n^n^n^n^n^n^n", HUNGERLEVEL, pointcost, pointcost > 1 ? "s" : "", upgrlevel, requirements_correct ? "2. Buy " : "", requirements_correct ? upgrade_names[upgrade_choice[id]] : "")
				}
			}
			case 4:{
				if ( player_team[id] == MARINE )
				{
					upgrade_choice[id] = 4
					upgrlevel = g_staticfieldupgrade[id] + 1
					pointcost = STATICFIELDCOST
					
					new staticrangelevelmult = upgrlevel - 1
					new staticrangeadd = STATICFIELDLEVELRANGE * staticrangelevelmult
					new staticrange = STATICFIELDINITIALRANGE + staticrangeadd
					new staticnumerator = STATICFIELDNUMERATORIN
					if ( upgrlevel >= 2 ){
						staticnumerator += STATICFIELDNUMERATORLV * staticrangelevelmult
						if (staticnumerator > MAXSTATICNUMERATOR)
							staticnumerator = MAXSTATICNUMERATOR
					}
					staticnumerator = STATICFIELDDENOMENATOR - staticnumerator
					
					requirements_correct = ( g_points[id] >= STATICFIELDCOST && level >= STATICFIELDLEVEL && g_ethtrackingupgrade[id] && ns_get_mask(id, MASK_WEAPONS2) && ( g_staticfieldupgrade[id] < STATICFIELDMAX || STATICFIELDMAX == 0 ) )
					
					len = format(menuBody, 511, "%s:^n^n", upgrade_names[upgrade_choice[id]])
					len += format(menuBody[len], 511-len, "Uses a special electric shock to weaken the natural toughness of aliens^nLowers max health of aliens in range of [%d] to [%d] / %d^n^n", staticrange, staticnumerator, STATICFIELDDENOMENATOR)
					len += format(menuBody[len], 511-len, "Requires: Ethereal Tracking , Weapons 2 , Level %d, %d point%s^n^nNext level [%d]^n^n%s%s^n^n0. Exit^n^n^n^n^n^n^n", STATICFIELDLEVEL, pointcost, pointcost > 1 ? "s" : "", upgrlevel, requirements_correct ? "2. Buy " : "", requirements_correct ? upgrade_names[upgrade_choice[id]] : "")
				}else if ( player_team[id] == ALIEN )
				{
					if ( player_level[id] >= 10 )
					{
						upgrade_choice[id] = ALIEN_UP_ARRAY_START + 4
						upgrlevel = g_soaupgrade[id] + 1
						pointcost = SENSEOFANCIENTSCOST
						
						new dev_time_mult = ( upgrlevel % SAO_DEVOUR_ADDER == 1 ) ? 1 : g_SoA_devourtime_multiply[id] + 1
						new Float:devour_time = SOA_DEVOURTIME_INIT - ( dev_time_mult * SOA_DEVOURTIME_BONUS )
						new players_to_devour = floatround( float(upgrlevel) / float(SAO_DEVOUR_ADDER), floatround_ceil)
						
						new dc_up = ( ns_get_mask(id, MASK_CARAPACE) || ns_get_mask(id, MASK_REGENERATION) || ns_get_mask(id, MASK_REDEMPTION) )
						new mc_up = ( ns_get_mask(id, MASK_CELERITY) || ns_get_mask(id, MASK_ADRENALINE) || ns_get_mask(id, MASK_SILENCE) )
						new sc_up = ( ns_get_mask(id, MASK_CLOAKING) || ns_get_mask(id, MASK_FOCUS) || ns_get_mask(id, MASK_SCENTOFFEAR) )
						requirements_correct = ( g_points[id] >= SENSEOFANCIENTSCOST && level >= 10 && dc_up && mc_up && sc_up && ( g_soaupgrade[id] < SENSEOFANCIENTSMAX || SENSEOFANCIENTSMAX == 0 ) )
						
						len = format(menuBody, 511, "%s:^n^n", upgrade_names[upgrade_choice[id]])
						len += format(menuBody[len], 511-len, "Skulk: Parasite with [+%d%%] damage, infects nearby players in range [%d] by chance (10-30%) over 5 seconds^nGorge: Stronger Healspray [+%d%%]^nLerk: Gas with [%d] damage to armor of HA^n", SOA_PARASITE_DMG * upgrlevel, SOA_PARASITE_INIT + upgrlevel * SOA_PARASITE_ADD, upgrlevel * SOA_HEALSPRAY_DMG, upgrlevel * SOA_GASDAMAGE)
						len += format(menuBody[len], 511-len, "Fade: Blink energy is reduced by [%d%%]^nOnos: You can devour [%d] more player%s, with a cooldown time of [%2.1f] second%s between devours^nGestate: Armor increased by [+%d]^n^n", upgrlevel * SOA_BLINK_ENERGY_BONUS, players_to_devour, ( players_to_devour > 1 ) ? "s" : "", devour_time, devour_time == 1.0 ? "" : "s", upgrlevel * SOA_GESTATE_ARMOR_ADD)
						len += format(menuBody[len], 511-len, "Requires: 1 Upgrade of each Upgrade Chamber , Level 10, %d point%s^n^nNext level [%d]^n^n%s%s^n^n0. Exit^n^n^n^n^n^n^n^n^n^n^n", pointcost, pointcost > 1 ? "s" : "", upgrlevel, requirements_correct ? "2. Buy " : "", requirements_correct ? upgrade_names[upgrade_choice[id]] : "")
					}else
					{
						found_error = 1
						showMenu(id)
					}
				}
			}
			case 5:{
				if ( player_team[id] == MARINE )
				{
					if ( player_level[id] >= 10 )
					{
						upgrade_choice[id] = 5
						upgrlevel = g_uranuimammo[id] + 1
						pointcost = URANUIMAMMOCOST
						
						requirements_correct = ( g_points[id] >= URANUIMAMMOCOST && level >= 10 && ns_get_mask(id, MASK_WEAPONS3) && ( g_uranuimammo[id] < URANUIMAMMOMAX || URANUIMAMMOMAX == 0 ) )
						
						len = format(menuBody, 511, "%s:^n^n", upgrade_names[upgrade_choice[id]])
						len += format(menuBody[len], 511-len, "Ammunition contains depleted uranium to enhance damage for all weapons except (Knife, Welder)^nBullets [+%d%%] / Grenades [+%d%%] Damage^n^nRequires: Weapons 3 , Level 10, %d point%s^n^nNext level [%d]^n^n%s%s^n^n0. Exit^n^n^n^n^n^n^n", upgrlevel * URANUIMAMMO_BULLET, upgrlevel * URANUIMAMMO_GREN, pointcost, pointcost > 1 ? "s" : "", upgrlevel, requirements_correct ? "2. Buy " : "", requirements_correct ? upgrade_names[upgrade_choice[id]] : "")
					}else
					{
						found_error = 1
						showMenu(id)
					}
				}
			}
		}
		if ( !found_error && key != 9 )
		{
			if ( requirements_correct )
				menu_keys |= (1<<1)
			show_menu(id, menu_keys, menuBody)
		}
	}
	
	return PLUGIN_HANDLED
}

public choice_one_to_six( id , key )
{
	switch ( key )
	{
		case 1:{
			new message[180]
			new enabled, cur_level, maxupgrlevel, cost
			if ( player_team[id] == MARINE )
			{
				if ( upgrade_choice[id] == 0 )
				{
					if ( ( enabled = CYBERNETICS ) )
					{
						if ( ( maxupgrlevel = CYBERNETICSMAX ) == 0 )
							maxupgrlevel = 999
						
						cur_level = g_speedupgrade[id] += 1
						cost = CYBERNETICSCOST
					}
				}else if ( upgrade_choice[id] == 1 )
				{
					if ( ( enabled = REINFORCEARMOR ) )
					{
						if ( ( maxupgrlevel = REINFORCEARMORMAX ) == 0 )
							maxupgrlevel = 999
						
						cur_level = g_armorupgrade[id] +=1
						cost = REINFORCEARMORCOST
						
						if ( is_gnome_running )
							armorup_to_gnome(id)
						
						new Float:armorvalue, Float:maxarmor
						get_max_armor(id, armorvalue, maxarmor)
						
						// if player does not have max armor dont give max armor but only the upgrade value
						if ( ns_get_class(id) == CLASS_HEAVY )
							entity_set_float(id, EV_FL_armorvalue, armorvalue +  ARMOR_HA)
						else
							entity_set_float(id, EV_FL_armorvalue, armorvalue +  ARMOR_MA)
					}
				}else if ( upgrade_choice[id] == 2 )
				{
					if ( ( enabled = NANOARMOR ) )
					{
						if ( ( maxupgrlevel = NANOARMORMAX ) == 0 )
							maxupgrlevel = 999
						
						cur_level = g_selfweldupgrade[id] += 1
						cost = NANOARMORCOST
					}
				}else if ( upgrade_choice[id] == 3 )
				{
					if ( ( enabled = ETHTRACKING ) )
					{
						if ( ( maxupgrlevel = ETHTRACKINGMAX ) == 0 )
							maxupgrlevel = 999
						
						cur_level = g_ethtrackingupgrade[id] += 1
						cost = ETHTRACKINGCOST
					}
				}else if ( upgrade_choice[id] == 4 )
				{
					if ( ( enabled = STATICFIELD ) )
					{
						if ( ( maxupgrlevel = STATICFIELDMAX ) == 0 )
							maxupgrlevel = 999
						
						cur_level = g_staticfieldupgrade[id] += 1
						cost = STATICFIELDCOST
					}
				}else if ( upgrade_choice[id] == 5 )
				{
					if ( ( enabled = URANUIMAMMO ) )
					{
						if ( ( maxupgrlevel = URANUIMAMMOMAX ) == 0 )
							maxupgrlevel = 999
						
						cur_level = g_uranuimammo[id] += 1
						cost = URANUIMAMMOCOST
						
						set_weapon_damage(id)
					}
				}
			}else if ( player_team[id] == ALIEN )
			{
				if ( upgrade_choice[id] == ALIEN_UP_ARRAY_START )
				{
					if ( ( enabled = THICKSKIN ) )
					{
						if ( ( maxupgrlevel = THICKENEDSKINMAX ) == 0 )
							maxupgrlevel = 999
						
						cur_level = g_healthupgrade[id] += 1
						cost = THICKSKINCOST
					}
				}else if ( upgrade_choice[id] == ALIEN_UP_ARRAY_START + 1 )
				{
					if ( ( enabled = ETHSHIFT ) )
					{
						if ( ( maxupgrlevel = ETHSHIFTMAX ) == 0 )
							maxupgrlevel = 999
						
						cur_level = g_etherealshiftupgrade[id] += 1
						cost = ETHSHIFTCOST
						
						new class = ns_get_class(id)
						new Float:shift_level = SHIFTLEVEL
						if ( class == CLASS_SKULK || class == CLASS_GORGE || class == CLASS_LERK )
							shift_level *= SHIFTCLASSMULTI
						g_ShiftTime[id] = SHIFTINITIAL + shift_level * g_etherealshiftupgrade[id]
					}
				}else if ( upgrade_choice[id] == ALIEN_UP_ARRAY_START + 2 )
				{
					if ( ( enabled = BLOODLUST ) )
					{
						if ( ( maxupgrlevel = BLOODLUSTMAX ) == 0 )
							maxupgrlevel = 999
						
						cur_level = g_bloodlustupgrade[id] += 1
						cost = BLOODLUSTCOST
					}
				}else if ( upgrade_choice[id] == ALIEN_UP_ARRAY_START + 3 )
				{
					if ( ( enabled = HUNGER ) )
					{
						if ( ( maxupgrlevel = HUNGERMAX ) == 0 )
							maxupgrlevel = 999
						
						cur_level = g_hungerupgrade[id] += 1
						cost = HUNGERCOST
					}
				}else if ( upgrade_choice[id] == ALIEN_UP_ARRAY_START + 4 )
				{
					if ( ( enabled = SENSEOFANCIENTS ) )
					{
						if ( ( maxupgrlevel = SENSEOFANCIENTSMAX ) == 0 )
							maxupgrlevel = 999
						
						cur_level = g_soaupgrade[id] += 1
						cost = SENSEOFANCIENTSCOST
						
						if ( cur_level % SAO_DEVOUR_ADDER == 1 )
						{
							g_SoA_devourtime_multiply[id] = 1
							g_SoA_player_amount[id] += 1
						}else
							g_SoA_devourtime_multiply[id] += 1
						
						g_SoA_devourtime[id] = SOA_DEVOURTIME_INIT - ( g_SoA_devourtime_multiply[id] * SOA_DEVOURTIME_BONUS )
						set_weapon_damage(id)
					}
				}
			}
			
			if ( player_team[id] )
			{
				if( enabled > 0 )
				{
					format(message, 179, "You got Level %d of %d levels of %s", cur_level, maxupgrlevel, upgrade_names[upgrade_choice[id]])
					
					ns_set_points(id, ns_get_points(id) + cost)
					
					// check level immidiatly (exploit fix)
					check_level_player(id)
					
					if ( player_team[id] == ALIEN )
					{
						player_gestating_emu[id] = 1
						player_gestate_emu_class[id] = ns_get_class(id)
					}
				}else
					format(message, 179, "%s is not enabled on this server, sorry for the inconvenience", upgrade_names[upgrade_choice[id]])
				
				ns_popup(id, message)
			}
		}
	}
	upgrade_choice[id] = -1
	
	return PLUGIN_HANDLED
}

public etherealshift( id )
{
	if ( get_cvar_num("zilla_GorgZilla") )
		return PLUGIN_CONTINUE
	
	if ( g_etherealshiftupgrade[id] )
	{
		new Float:energy = entity_get_float(id, EV_FL_fuser3)
		if ( get_gametime() - g_LastShift[id] >= g_ShiftTime[id] && energy >= 300 && ( ONOS_SHIFT || ns_get_class(id) != CLASS_ONOS ) )
		{
			g_LastShift[id] = get_gametime()
			entity_set_int(id, EV_INT_rendermode, 2)
			g_justshifted[id] = 1
			energy -= 300
			entity_set_float(id, EV_FL_fuser3, energy)
			if ( !ns_get_mask(id, MASK_SILENCE) )
				emit_sound(id, CHAN_ITEM, sound_files[sound_cloakstart], 0.5, ATTN_NORM, 0, PITCH_NORM)
		}
	}
	return PLUGIN_CONTINUE
}

public showMenu( id )
{
	if ( get_cvar_num("zilla_GorgZilla") )
		return PLUGIN_HANDLED
	
	if ( is_user_alive(id) && player_team[id] && ns_get_class(id) != CLASS_GESTATE )
	{
		new keys = (1<<0)|(1<<1)|(1<<2)|(1<<3)|(1<<4)|(1<<9)
		new menuBody[512]
		new len = format(menuBody, 511, "Choose an upgrade to view information about:^n^n")
		if ( player_team[id] == MARINE )
		{
			keys |= (1<<5)
			len += format(menuBody[len], 511-len, "1. Cybernetics                  ( %3d / %3d )^n2. Reinforced Armor        ( %3d / %3d )^n3. Nano Armor                  ( %3d / %3d )^n", g_speedupgrade[id], CYBERNETICSMAX, g_armorupgrade[id], REINFORCEARMORMAX, g_selfweldupgrade[id], NANOARMORMAX)
			len += format(menuBody[len], 511-len, "4. Ethereal Tracking        ( %3d / %3d )^n5. Static Field                   ( %3d / %3d )^n", g_ethtrackingupgrade[id], ETHTRACKINGMAX, g_staticfieldupgrade[id], STATICFIELDMAX)
			if ( player_level[id] >= 10 )
				len += format(menuBody[len], 511-len, "6. Uranium Ammunition   ( %3d / %3d )^n^n0. Exit^n^n^n^n^n", g_uranuimammo[id], URANUIMAMMOMAX)
			else
				len += format(menuBody[len], 511-len, "6. Uranium Ammunition (blocked till level 10)^n^n0. Exit^n^n^n^n^n")
		}else if ( player_team[id] == ALIEN )
		{
			len += format(menuBody[len], 511-len, "1. Thickened Skin        ( %3d / %3d )^n2. Ethereal Shift           ( %3d / %3d )^n3. Blood Lust                ( %3d / %3d )^n4. Hunger                      ( %3d / %3d )^n", g_healthupgrade[id], THICKENEDSKINMAX, g_etherealshiftupgrade[id], ETHSHIFTMAX, g_bloodlustupgrade[id], BLOODLUSTMAX, g_hungerupgrade[id], HUNGERMAX)
			if ( player_level[id] >= 10 )
				len += format(menuBody[len], 511-len, "5. Sense of Ancients   ( %3d / %3d )^n^n0. Exit^n^n^n^n", g_soaupgrade[id], SENSEOFANCIENTSMAX)
			else
				len += format(menuBody[len], 511-len, "5. Sense of Ancients%s^n^n0. Exit^n^n^n^n", ( player_level[id] >= 10 ) ?  "" : " (blocked till level 10)")
		}
		
		show_menu(id, keys, menuBody)
	}
	
	return PLUGIN_HANDLED
}

public showHelpMenu( id )
{
	if ( get_cvar_num("zilla_GorgZilla") )
		return PLUGIN_HANDLED
	
	new menuBody[512]
	new len = format(menuBody, 511, "Help:^nThis server is running ExtraLevels2 Rework^n^n")
	len += format(menuBody[len], 511-len, "With ExtraLevels2 Rework, two major things happen that usually don't^n^na) You can get to level %i.^n^nb) You can get extra upgrades^n^nTry typing /xmenu or xmenu to view these extra upgrades^nmake sure you have all the requirement to get an extra upgrade.^nHAVE FUN!!!^n^n0. Exit^n^n^n^n^n^n^n^n^n", get_cvar_num("amx_maxlevel"))
	show_menu(id, (1<<9), menuBody)
	return PLUGIN_HANDLED
}

public block_exploit( id )
{
	reset_upgrades_vars(id, 1)
	
	return PLUGIN_CONTINUE
}

public checkLevels_showXP( )
{
	if ( get_cvar_num("zilla_GorgZilla") )
		return PLUGIN_HANDLED
	
	new max_level = get_cvar_num("amx_maxlevel")
	if ( max_level < 11 )
		return PLUGIN_HANDLED
	
	new Float:gametime = get_gametime()
	
	for ( new id = 1; id <= g_maxPlayers; id++ )
	{
		if ( !is_user_connected(id) )
			continue
		
		if ( !player_team[id] )
			continue
		
		new vid
		if ( is_user_alive(id) )
		{
			vid = id
			if ( g_speedupgrade[id] )
				speedupgrade(id)
			
			if ( g_healthupgrade[id] )
				healthupgrade(id, gametime)
			
			if ( g_selfweldupgrade[id] )
				selfweldupgrade(id, gametime)
			
			// Sense of Ancients Skulk
			if ( !fresh_parasite[id] )
			{
				if ( ns_get_mask(id, MASK_PARASITED) )
				{
					fresh_parasite[id] = 1
					parasite_time[id] = gametime
				}
			}else if ( 1 <= fresh_parasite[id] <= 5 && gametime - parasite_time[id] >= 1.0 )
			{
				parasite_time[id] = gametime
				new global_chance = random(100), chance_mode = random(3) + 1
				for ( new i = 0; i < 10 * chance_mode; i++ )
				{
					if ( rand_para_chance[i] == global_chance )
					{
						parasite_players_in_range(id)
						break
					}
				}
				
				fresh_parasite[id]++
			}
		}else if ( entity_get_int(id, EV_INT_iuser1) == 4 && entity_get_int(id, EV_INT_iuser2) > 0 )
		{	// First Person Spectating mode and Person being spectated is set
			vid = entity_get_int(id, EV_INT_iuser2)
		}else
		{
			if ( g_lastxp[id] == -1 )
				continue
			
			set_hudmessage(0, 0, 0, -1.0, 0.89, 0, 0.0, 3600.0, 0.0, 0.0, HUD_CHANNEL)
			show_hudmessage(id, " ")
			g_lastxp[id] = -1
			continue
		}
		
		new xp
		check_level_player(vid, xp)
		
		if ( xp == g_lastxp[id] && !just_respawned[id] )
			continue
		else if ( g_lastxp[vid] > xp )
		{
			// XP has reduce somehow, so get correct level
			player_level[vid] = 1			// you start with level 1
			players_xp_to_next_lvl[vid] = 100	// level 2 is reached with 100 XP
			player_base_level_xp[vid] = 0
			get_lvl_last_next_xp(vid, xp)
		}
		
		g_lastxp[vid] = xp
		
		new level = player_level[vid]
		just_respawned[id] = 0
		
		if ( get_cvar_num("amx_huddisplay") == 1 )
		{
			if ( level < 10 )
				continue
		}
		
		new is_marine = ( player_team[vid] == MARINE )
		set_hudmessage(is_marine ? 0 : 160, is_marine ? 75 : 100, is_marine ? 100 : 0, -1.0, is_user_alive(id) ? 0.89 : 0.82, 0, 0.0, 3600.0, 0.0, 0.0, HUD_CHANNEL)
		
		// check if we advanced in level, if so play a sound
		if ( level > lastlevel[vid] )
		{
			lastlevel[vid] = level
			if ( level > 10 )
			{
				if( is_marine )
					emit_sound(id, CHAN_AUTO, sound_files[sound_Mlevelup], 0.5, ATTN_NORM, 0, PITCH_NORM)
				else if( !ns_get_mask(id, MASK_SILENCE) )
					emit_sound(id, CHAN_AUTO, sound_files[sound_Alevelup], 0.5, ATTN_NORM, 0, PITCH_NORM)
			}
		}
		if ( level >= max_level )
		{
			show_hudmessage(id, "Level %d: GODLIKE!!!", max_level)
		}else
		{
			new Float:percentage = ( ( float(xp) - float(player_base_level_xp[vid]) ) * 100.0 ) / float(players_xp_to_next_lvl[vid] + 1)		// + 1 is a fix (eg 2701 is level 10 NOT 2700)
			
			new temp[13], message_set
			for ( new i = 0; i < 19; i++ )
			{
				if ( level >= get_cvar_num(level_cvar_list[i]) )
				{
					if ( get_cvar_num("amx_huddisplay") == 1 )
						show_hudmessage(id, "Level %d: %s (%3.1f%%)", level, is_marine ? marine_rang[i] : alien_rang[i], percentage)
					else if ( get_cvar_num("amx_huddisplay") == 2 )
						show_hudmessage(id, "Level %d/%d: %s (%3.1f%%)", level, max_level, is_marine ? marine_rang[i] : alien_rang[i], percentage)
					message_set = 1
					
					break
				}
				temp[0] = 0
			}
			if ( !message_set )
			{
				if ( get_cvar_num("amx_huddisplay") == 2 )
				{
					for ( new j = 19; j < 29; j++ )
					{
						if ( level >= 29 - j )
							show_hudmessage(id, "Level %d/%d: %s (%3.1f%%)", level, max_level, is_marine ? marine_rang[j] : alien_rang[j], percentage)
					}
				}else if ( get_cvar_num("amx_huddisplay") == 1 && level >= 10 )
					show_hudmessage(id, "Level %d: %s (%3.1f%%)", level, is_marine ? marine_rang[19] : alien_rang[19], percentage)
			}
		}
	}
	return PLUGIN_HANDLED
}

public PlaybackEvent( flags , ent_id , event_id , Float:delay , Float:Origin[3] )
{	// rest of parameters is not needed
	if( event_id == spore_event )
	{	//Make sure event_id is spore event
		new owner = entity_get_edict(ent_id, EV_ENT_owner)
		if ( g_soaupgrade[owner] )
		{
			if ( spore_num < 90 - 1 )
			{
				new Float:orig[3]
				entity_get_vector(ent_id, EV_VEC_origin, orig)
				spore_data[spore_num][0] = floatround(orig[0])
				spore_data[spore_num][1] = floatround(orig[1])
				spore_data[spore_num][2] = floatround(orig[2])
				spore_data[spore_num][3] = owner
				spore_data[spore_num][4] = 0
				spore_num++
			}
		}
	}else if( event_id == cloak_event )
	{
		if ( !redeemed[ent_id] )
		{
			before_redeem_orig[ent_id][0] = Origin[0]
			before_redeem_orig[ent_id][1] = Origin[1]
			before_redeem_orig[ent_id][2] = Origin[2]
			redeemed[ent_id] = 1
			free_digested_players(ent_id)
		}else
			redeemed[ent_id] = 0
	}
}

public emulated_spore_timer( )
{
	for ( new sporeid = 0; sporeid < spore_num; sporeid++ )
	{
		if ( spore_data[sporeid][4] == 6 )
		{
			for ( new sporeid_temp = sporeid; sporeid_temp < spore_num - 1; sporeid_temp++ )
			{
				spore_data[sporeid_temp][0] = spore_data[sporeid_temp + 1][0]
				spore_data[sporeid_temp][1] = spore_data[sporeid_temp + 1][1]
				spore_data[sporeid_temp][2] = spore_data[sporeid_temp + 1][2]
				spore_data[sporeid_temp][3] = spore_data[sporeid_temp + 1][3]
				spore_data[sporeid_temp][4] = spore_data[sporeid_temp + 1][4]
			}
			sporeid--
			spore_num--
		}else
		{
			new Float:ent_orig[3]
			ent_orig[0] = float(spore_data[sporeid][0])
			ent_orig[1] = float(spore_data[sporeid][1])
			ent_orig[2] = float(spore_data[sporeid][2])
			for ( new id = 1; id <= g_maxPlayers; id++ )
			{
				if ( !player_in_spore[id] )
				{
					if ( player_team[id] == MARINE )
					{	// player has a team so he must be connected
						new Float:origin[3]
						entity_get_vector(id, EV_VEC_origin, origin)
						if ( vector_distance(ent_orig, origin) <= 250.0 )
						{
							if ( is_user_alive(id) )
							{
								if ( ns_get_class(id) == CLASS_HEAVY )
								{
									new Float:new_armor = entity_get_float(id, EV_FL_armorvalue) - ( g_soaupgrade[spore_data[sporeid][3]] * SOA_GASDAMAGE )
									if ( new_armor < 0.0 )
										new_armor = 0.0
									entity_set_float(id, EV_FL_armorvalue, new_armor)
								}
							}
							// if in distance but cannot be spored exclude from further checks
							player_in_spore[id] = 1
						}
					}else
						player_in_spore[id] = 1
				}
			}
			spore_data[sporeid][4]++
		}
	}
	for ( new id = 1; id <= g_maxPlayers; id++ )
		player_in_spore[id] = 0
}

etherealtracking_staticfield( id )
{
	// init range + ( levelrange * rangelevelmultiplier )
	new Float:trackrange = float(ETHTRACKINGINITIALRANGE + ( ETHTRACKLEVELRANGE * ( g_ethtrackingupgrade[id] - 1 ) ))
	
	// init range + ( levelrange * rangelevelmultiplier )
	new Float:staticrange = float(STATICFIELDINITIALRANGE + ( STATICFIELDLEVELRANGE * ( g_staticfieldupgrade[id] - 1 ) ))
	for ( new targetid = 1; targetid <= g_maxPlayers; targetid++ )
	{
		if( is_user_connected(targetid) )
		{
			if( is_user_alive(targetid) )
			{
				if ( g_ethtrackingupgrade[id] )
				{
					if ( entity_range(id, targetid) <= trackrange )
						g_detected[targetid] = 1
				}
				if ( g_staticfieldupgrade[id] )
				{
					if( entity_get_int(targetid, EV_INT_team) != entity_get_int(id, EV_INT_team) && entity_range(id, targetid) <= staticrange )
					{
						new Float:scurrenthealth = entity_get_float(targetid, EV_FL_health)
						new Float:sbasehealthvalue, Float:shealthadd
						get_base_add_health(targetid, sbasehealthvalue, shealthadd)
						new Float:smaxhealth = sbasehealthvalue + shealthadd
						new Float:statichealth = smaxhealth / float(STATICFIELDDENOMENATOR)
						new sstaticnumerator = STATICFIELDNUMERATORIN
						if ( g_staticfieldupgrade[id] > 1 )
						{
							sstaticnumerator = g_staticfieldupgrade[id] * STATICFIELDNUMERATORLV
							if ( sstaticnumerator > MAXSTATICNUMERATOR )
								sstaticnumerator = MAXSTATICNUMERATOR
						} 
						statichealth *= ( STATICFIELDDENOMENATOR - sstaticnumerator )
						if ( scurrenthealth > statichealth )
						{
							entity_set_float(targetid, EV_FL_health, statichealth)
							emit_sound(id, CHAN_ITEM, sound_files[sound_elecspark], 0.5, ATTN_NORM, 0, PITCH_NORM)
						}
					}
				}
			}
		}
	}
}

metabolize_hive_heal( id , Float:gametime , weaponid , player_attacking )
{
	if ( player_team[id] == ALIEN )
	{
		new Float:basehealthvalue, Float:healthadd, Float:hive_regenvalue
		get_base_add_health(id, basehealthvalue, healthadd, hive_regenvalue)
		new Float:currenthealth = entity_get_float(id, EV_FL_health)
		new Float:maxhealth = basehealthvalue + healthadd
		if ( basehealthvalue <= currenthealth < maxhealth )
		{
			new health_sound
			new Float:newhealth = currenthealth
			if ( weaponid == WEAPON_METABOLIZE && player_attacking && gametime - g_LastMetabolizeRegen[id] >= 1.5 )
			{
				g_LastMetabolizeRegen[id] = gametime
				newhealth += 20.0
				health_sound = random(3) + 1
			}
			if ( gametime - g_LastHiveRegen[id] >= 1.0 )
			{
				g_LastHiveRegen[id] = gametime
				new hiveid = -1
				while ( ( hiveid = find_ent_by_class(hiveid, "team_hive") ) > 0 )
				{
					if ( entity_range(id, hiveid) <= 525.0 )
					{
						newhealth += hive_regenvalue
						if ( !health_sound )
							health_sound = sound_regen
					}
				}
			}
			if ( health_sound )
				change_health_and_sound(id, maxhealth, newhealth, health_sound)
		}
		
	}
}

weldoverbasemax( id )
{
	new entity, part
	get_user_aiming(id, entity, part)
	if ( is_user_connected(entity) )
	{
		if ( entity_get_int(id, EV_INT_team) == entity_get_int(entity, EV_INT_team) && is_user_alive(entity) )
		{
			if ( entity_range(id, entity) < 200.0 )
			{
				new Float:armorvalue,Float:maxarmor, Float:max_basearmor
				get_max_armor(entity, armorvalue, maxarmor, max_basearmor)
				
				if ( max_basearmor <= armorvalue < maxarmor && player_team[id] == MARINE )
				{
					armorvalue += 35.0
					if ( armorvalue > maxarmor )
						armorvalue = maxarmor
					
					entity_set_float(entity, EV_FL_armorvalue, armorvalue)
					welded_overmax[id] = 0
					if ( !welding_overmax[id] )
					{
						emit_sound(id, CHAN_AUTO, sound_files[sound_welderhit], 0.5, ATTN_NORM, 0, PITCH_NORM)
						emit_sound(id, CHAN_STREAM, sound_files[sound_welderidle], 0.5, ATTN_NORM, 0, PITCH_NORM)
						welding_overmax[id] = 1
					}
				}else if ( welding_overmax[id] )
					welded_overmax[id] = 1
			}
		}
	}
}

speedupgrade( id )
{
	new class = ns_get_class(id)
	new speedbonus
	if ( id == gnome_id[0] || id == gnome_id[1] )
		speedbonus = gnome_speed + SPEED_MA / 2 * g_speedupgrade[id]
	else if ( class == CLASS_MARINE || class == CLASS_JETPACK )
		speedbonus = SPEED_MA * g_speedupgrade[id]
	else if (class == CLASS_HEAVY) 
		speedbonus = SPEED_HA * g_speedupgrade[id]
	
	ns_set_speedchange(id, speedbonus)
}

healthupgrade( id , Float:gametime )
{
	if ( gametime - g_LastRegen[id] >= 2.0 )
	{
		g_LastRegen[id] = gametime
		new Float:basehealthvalue, Float:healthadd, Float:healthregen, Float:dummy
		get_base_add_health(id, basehealthvalue, healthadd, dummy, healthregen)
		new Float:healthvalue = entity_get_float(id, EV_FL_health)
		new Float:healthmax = basehealthvalue + healthadd
		if ( healthvalue < basehealthvalue || healthvalue >= healthmax )
			return
		
		new Float:newhealthvalue = healthvalue + healthregen
		if ( newhealthvalue > healthmax )
			newhealthvalue = healthmax
		if ( newhealthvalue > 999.0 )
			newhealthvalue = 999.0
		
		if ( !ns_get_mask(id, MASK_SILENCE) )
			emit_sound(id, CHAN_ITEM, sound_files[sound_regen], 0.5, ATTN_NORM, 0, PITCH_NORM)
		
		entity_set_float(id, EV_FL_health, newhealthvalue)
	}
}

selfweldupgrade( id , Float:gametime )
{
	if ( gametime - nanoweld_time[id] > 1.0 )
	{
		new class = ns_get_class(id)
		new Float:armorvalue, Float:maxarmor
		get_max_armor(id, armorvalue, maxarmor)
		if ( armorvalue < maxarmor )
		{
			if ( !welding_self[id] )
				emit_sound(id, CHAN_STREAM, sound_files[sound_welderidle], 0.5, ATTN_NORM, 0, PITCH_NORM)
			welding_self[id] = 1
			emit_sound(id, CHAN_AUTO, sound_files[sound_welderstop], 0.5, ATTN_NORM, 0, PITCH_NORM)
		}else if ( welding_self[id] )
		{	// as we already have max stop selfweld + sound
			welding_self[id] = 0
			emit_sound(id, CHAN_STREAM, sound_files[sound_welderidle], 0.0, ATTN_NORM, SND_STOP, PITCH_NORM)
			return
		}
		
		new selfweldvalue
		if ( class == CLASS_MARINE || class == CLASS_JETPACK )
			selfweldvalue = SELFWELD_MA * g_selfweldupgrade[id]
		else if ( class == CLASS_HEAVY )
			selfweldvalue = SELFWELD_HA * g_selfweldupgrade[id]
		
		new Float:newarmorvalue = armorvalue + selfweldvalue
		if ( newarmorvalue > maxarmor )
			newarmorvalue = maxarmor
		
		entity_set_float(id, EV_FL_armorvalue, newarmorvalue)
		
		nanoweld_time[id] = gametime
	}
}

get_lvl_last_next_xp( id , &xp )
{
	xp = floatround(ns_get_exp(id))
	while ( xp > ( players_xp_to_next_lvl[id] + player_base_level_xp[id] ) )
	{
		player_base_level_xp[id] += players_xp_to_next_lvl[id]
#if CUSTOM_LEVELS == 0
		players_xp_to_next_lvl[id] += 50
#else
		if ( player_level[id] < 10 )
		{
			players_xp_to_next_lvl[id] += 50
		}else if ( player_level[id] == 10 )
		{	// activate custom level XP
			players_xp_to_next_lvl[id] = NEXT_LEVEL_XP_MODIFIER
			player_base_level_xp[id] += BASE_XP_TO_NEXT_LEVEL
		}else
			players_xp_to_next_lvl[id] += NEXT_LEVEL_XP_MODIFIER
#endif
		
		player_level[id] += 1
	}
}

reset_upgrades_vars( id , ingame = 0 )
{
	g_extralevels[id] = 0
	g_points[id] = 0
	g_lastxp[id] = 0
	
	g_speedupgrade[id] = 0
	g_armorupgrade[id] = 0
	g_selfweldupgrade[id] = 0
	g_ethtrackingupgrade[id] = 0
	g_staticfieldupgrade[id] = 0
	g_uranuimammo[id] = 0
	
	g_healthupgrade[id] = 0
	g_etherealshiftupgrade[id] = 0
	g_ShiftTime[id] = 0.0
	g_bloodlustupgrade[id] = 0
	g_hungerupgrade[id] = 0
	g_soaupgrade[id] = 0
	fresh_parasite[id] = 0
	g_fade_blinked[id] = 0
	g_fade_energy[id] = 0.0
	g_SoA_devourtime_multiply[id] = 1
	g_SoA_devourtime[id] = SOA_DEVOURTIME_INIT
	g_SoA_player_amount[id] = 0
	redeemed[id] = 0
	
	reset_gestate_emu(id)
	reset_devour_vars(id)
	
	if ( !ingame )
	{
		g_authorsshown[id] = 0
		g_informsshown[id] = 0
	}
	
	welding_self[id] = 0
	welding_overmax[id] = 0
	welded_overmax[id] = 0
	lastlevel[id] = 0
	
	player_level[id] = 1			// you start with level 1
	players_xp_to_next_lvl[id] = 100	// level 2 is reached with 100 XP
	player_base_level_xp[id] = 0
	
	ns_set_speedchange(id, 0)
	
	emit_sound(id, CHAN_STREAM, sound_files[sound_welderidle], 0.0, ATTN_NORM, SND_STOP, PITCH_NORM)
}

reset_devour_vars( id )
{
	my_digester[id] = 0
	digest_time[id] = 0.0
	devouring_players_num[id] = 0
}

reset_gestate_emu( id )
{
	player_gestating_emu[id] = 0
	player_gestate_emu_class[id] = 0
}

get_base_add_health( id , &Float:basehealthvalue , &Float:healthadd , &Float:hive_regenvalue = 0.0 , &Float:healthregen = 0.0 )
{
	new class = ns_get_class(id)
	if ( class == CLASS_SKULK )
	{
		basehealthvalue = 70.0
		hive_regenvalue = 10.0
		healthregen = 6.0
		healthadd = HEALTHSKULK
	}else if ( class == CLASS_GORGE )
	{
		basehealthvalue = 150.0
		hive_regenvalue = 22.0
		healthregen = 13.0
		healthadd = HEALTHGORGE
	}else if ( class == CLASS_LERK )
	{
		basehealthvalue = 125.0
		hive_regenvalue = 18.0
		healthregen = 11.0
		healthadd = HEALTHLERK
	}else if ( class == CLASS_FADE )
	{
		basehealthvalue = 300.0
		hive_regenvalue = 54.0
		healthregen = 27.0
		healthadd = HEALTHFADE
	}else if ( class == CLASS_ONOS )
	{
		basehealthvalue = 700.0
		hive_regenvalue = 105.0
		healthregen = 63.0
		healthadd = HEALTHONOS
	}else if ( class == CLASS_GESTATE )
	{
		basehealthvalue = 200.0
		hive_regenvalue = 20.0
		healthregen = 18.0
		healthadd = HEALTHGESTATE
	}else if ( class == CLASS_MARINE || class == CLASS_JETPACK || class == CLASS_HEAVY )
		basehealthvalue = 100.0
	
	healthadd *= g_healthupgrade[id]
}

change_health_and_sound( id , Float:maxhealth , Float:newhealth , health_sound )
{
	if ( newhealth > maxhealth )
		newhealth = maxhealth
	
	entity_set_float(id, EV_FL_health, newhealth)
	if ( !ns_get_mask(id, MASK_SILENCE) )
		emit_sound(id, CHAN_ITEM, sound_files[health_sound], 0.5, ATTN_NORM, 0, PITCH_NORM)
}

get_max_armor( id , &Float:armorvalue , &Float:maxarmor , &Float:max_basearmor = 0.0 )
{
	new class = ns_get_class(id)
	armorvalue = entity_get_float(id, EV_FL_armorvalue)
	if ( id == gnome_id[0] || id == gnome_id[1] ){
		max_basearmor = float(gnome_base_armor)
		maxarmor = float(gnome_max_armor)
	}else if ( class == CLASS_MARINE || class == CLASS_JETPACK )
	{
		max_basearmor = 90.0
#if NS_303 == 0
		max_basearmor -= 5.0
#endif
		maxarmor = ARMOR_MA * g_armorupgrade[id] + max_basearmor
	}else if ( class == CLASS_HEAVY )
	{
		max_basearmor = 290.0
		maxarmor = ARMOR_HA * g_armorupgrade[id] + max_basearmor
	}
	if ( maxarmor > 999.0 )
		maxarmor = 999.0
}

check_level_player( id, &xp = 0 )
{
	get_lvl_last_next_xp(id, xp)
	
	if ( !is_user_alive(id) )
		return
	
	if ( player_level[id] >= get_cvar_num("amx_maxlevel") )
		return
	
	new levelsspent = ns_get_points(id)
	
	// when gestated and respawn NS is giving points back, so do a support
	if ( levelsspent < 0 )
	{
		levelsspent += alien_gestate_points[id]
		ns_set_points(id, levelsspent)
		g_extralevels[id] -= alien_gestate_points[id]	// tell extralevels points that we just got some points back
		alien_gestate_points[id] = 0
	}
	
	if ( 0 <= levelsspent < 10 )
	{
		g_points[id] = player_level[id] - 1 - levelsspent
		if ( player_level[id] >= 11 )
			g_points[id] -= ( player_level[id] - 10 )
		
		new extralevel = player_level[id] - 10 - g_extralevels[id]
		if ( extralevel > 8 )
			extralevel = 8	// We can't give more than 8 levels at a time
		
		new max_points = ( player_team[id] == MARINE ) ? max_marine_points : ( player_team[id] == ALIEN ) ? max_alien_points : 0
		if ( extralevel > 0 && g_extralevels[id] + 10 < max_points )
		{
			new newlevelsspent = (  extralevel > levelsspent ) ? levelsspent : extralevel
			if ( newlevelsspent > levelsspent )
				newlevelsspent = levelsspent
			g_extralevels[id] += newlevelsspent
			ns_set_points(id, levelsspent - newlevelsspent)
		}
	}
}

set_weapon_damage( id , weapon_id = 0 )
{
	new Float:bullet_amplifier = ( ( float(g_uranuimammo[id] * URANUIMAMMO_BULLET) / 100.0 ) + 1.0 )
	new Float:gren_amplifier = ( ( float(g_uranuimammo[id] * URANUIMAMMO_GREN) / 100.0 ) + 1.0 )
	new Float:parasite_amplifier = ( ( float(g_soaupgrade[id] * SOA_PARASITE_DMG) / 100.0 ) + 1.0 )
	new Float:healspray_amplifier = ( ( float(g_soaupgrade[id] * SOA_HEALSPRAY_DMG) / 100.0 ) + 1.0 )
	for ( new entid = g_maxPlayers + 1; entid <= max_entities; entid++ )
	{
		if ( is_valid_ent(entid) )
		{
			if ( entity_get_edict(entid, EV_ENT_owner) == id )
			{
				new classname[64]
				entity_get_string(entid, EV_SZ_classname, classname, 63)
				if ( weapon_id == 0 )
				{
					new Float:base_dmg, found, Float:amplyfier
					if ( player_team[id] == MARINE )
					{
						if ( equal(classname, "weapon_pistol") )
						{
							base_dmg = BASE_DAMAGE_HG
							found = 1
							amplyfier = bullet_amplifier
						}else if ( equal(classname, "weapon_machinegun") )
						{
							base_dmg = BASE_DAMAGE_LMG
							found = 1
							amplyfier = bullet_amplifier
						}else if ( equal(classname, "weapon_heavymachinegun") )
						{
							base_dmg = BASE_DAMAGE_HMG
							found = 1
							amplyfier = bullet_amplifier
						}else if ( equal(classname, "weapon_shotgun") )
						{
							base_dmg = BASE_DAMAGE_SG
							found = 1
							amplyfier = bullet_amplifier
						}else if ( equal(classname, "weapon_grenadegun") )
						{
							base_dmg = BASE_DAMAGE_GL
							found = 1
							amplyfier = gren_amplifier
						}else if ( equal(classname, "weapon_grenade") )
						{
							base_dmg = BASE_DAMAGE_GREN
							found = 1
							amplyfier = gren_amplifier
						}
					}else
					{
						if ( equali(classname, "weapon_parasite") )
						{
							base_dmg = BASE_DAMAGE_PARA
							found = 1
							amplyfier = parasite_amplifier
						}else if ( equal(classname, "weapon_healingspray") )
						{
							base_dmg = BASE_DAMAGE_HEAL
							found = 1
							amplyfier = healspray_amplifier
						}
					}
					if ( found )
					{
						if ( id == gnome_id[0] || id == gnome_id[1] )
						{
							if ( !get_cvar_num("mp_gnome_damage_pick_only") )
								base_dmg *= get_cvar_float("mp_gnome_damage_amplifier")
						}
						ns_set_weap_dmg(entid, base_dmg * amplyfier)
					}
				}else
				{
					if ( ( weapon_id == WEAPON_SHOTGUN && equal(classname, "weapon_shotgun") ) || ( weapon_id == WEAPON_HMG && equal(classname, "weapon_heavymachinegun") ) )
						ns_set_weap_dmg(entid, ns_get_weap_dmg(entid) * bullet_amplifier)
					else if ( ( weapon_id == WEAPON_GRENADE_GUN && equal(classname, "weapon_grenadegun") ) || ( weapon_id == WEAPON_GRENADE && equal(classname, "weapon_grenade") ) )
						ns_set_weap_dmg(entid, ns_get_weap_dmg(entid) * gren_amplifier)
				}
			}
		}
	}
}

parasite_players_in_range( parasited_player )
{
	new team = entity_get_int(parasited_player, EV_INT_team)
	for ( new player = 1; player <= g_maxPlayers; player++ )
	{
		if ( player == parasited_player )
			continue
		
		if ( is_user_connected(player) )
		{
			if ( entity_get_int(player, EV_INT_team) == team )
			{
				if ( is_user_alive(player) )
				{
					if ( entity_range(player, parasited_player) <= 200.0 )
					{
						ns_set_mask(player, MASK_PARASITED, 1)
						fresh_parasite[player] = 6
					}
				}
			}
		}
	}
}

get_my_onos( victim_id )
{
	new Float:range = 1000.0
	new my_onos_id
	for ( new id = 1; id <= g_maxPlayers; id++ )
	{
		if ( is_user_connected(id) )
		{
			if ( ns_get_class(id) == CLASS_ONOS )
			{
				new Float:temp = entity_range(id, victim_id)
				if ( temp < range )
				{
					range = temp
					my_onos_id = id
				}
			}
		}
	}
	
	return my_onos_id
}

free_digested_players( onos_id )
{
	for ( new id = 1; id <= g_maxPlayers; id++ )
	{
		if ( my_digester[id] == onos_id )
		{
			if ( entity_get_float(id, EV_FL_health) >= 1.0 )
			{
				if ( id != currently_digesting[my_digester[id]] )
				{
					entity_set_byte(id, EV_BYTE_controller2, 0)
					entity_set_int(id, EV_INT_solid, 3)
					entity_set_int(id, EV_INT_effects, 0)
					if ( !( entity_get_int(id, EV_INT_flags) & 512 ) )
						entity_set_int(id, EV_INT_flags, entity_get_int(id, EV_INT_flags) + 512)
					entity_set_int(id, EV_INT_weaponanim, 2)
					entity_set_float(id, EV_FL_flFallVelocity, 0.0)
					entity_set_float(id, EV_FL_fuser2, 1000.0)
					entity_set_float(id, EV_FL_fuser3, 0.0)
					ns_set_mask(id, MASK_DIGESTING, 0)
					
					entity_set_origin(id, before_redeem_orig[onos_id])
					new Float:nullvec[3]
					entity_set_vector(id, EV_VEC_velocity, nullvec)	// prevents player from dying after released from onos
					entity_set_float(id, EV_FL_takedamage, 2.0)
					set_player_weaponmodel(id)
				}
				reset_devour_vars(id)
			}
		}
	}
	reset_devour_vars(onos_id)
}

set_player_weaponmodel( id )
{
	new weapon_list[32], weapon_num, weapon_array, found_max
	get_user_weapons(id, weapon_list, weapon_num)
	for ( new a = 0; a < weapon_num; a++ )
	{
		if ( weapon_list[a] == WEAPON_KNIFE )
			weapon_array = 0
		else if ( weapon_list[a] == WEAPON_PISTOL )
			weapon_array = 1
		else if ( weapon_list[a] == WEAPON_LMG )
		{
			weapon_array = 2
			found_max = 1
		}else if ( weapon_list[a] == WEAPON_SHOTGUN )
		{
			weapon_array = 3
			found_max = 1
		}else if ( weapon_list[a] == WEAPON_HMG )
		{
			weapon_array = 4
			found_max = 1
		}else if ( weapon_list[a] == WEAPON_GRENADE_GUN )
		{
			weapon_array = 5
			found_max = 1
		}
		
		if ( found_max )
			break
	}
	
	if ( id == gnome_id[0] || id == gnome_id[1] )
	{
		if ( weapon_array == 0 )
			entity_set_string(id, EV_SZ_viewmodel, viewmodels[12])
		else
			entity_set_string(id, EV_SZ_viewmodel, viewmodels[weapon_array])
		
		if ( weapon_array <= 2 )	// just in case gnome gets a heavy weapon somehow
			entity_set_string(id, EV_SZ_weaponmodel, weapmodels[6 + weapon_array])
		else
			entity_set_string(id, EV_SZ_weaponmodel, weapmodels[weapon_array])
	}else
	{
		if ( ns_get_class(id) == CLASS_HEAVY )
			entity_set_string(id, EV_SZ_viewmodel, viewmodels[6 + weapon_array])
		else
			entity_set_string(id, EV_SZ_viewmodel, viewmodels[weapon_array])
	
		entity_set_string(id, EV_SZ_weaponmodel, weapmodels[weapon_array])
	}
}

kill_digested_player( victim_id , onos_id )
{
	entity_set_float(victim_id, EV_FL_health, 1.0)
	entity_set_float(victim_id, EV_FL_takedamage, 2.0)
	set_msg_block(DeathMsg_id, BLOCK_ONCE)
	fakedamage(victim_id, "trigger_hurt", 2.0, 0)
	message_begin(MSG_ALL, DeathMsg_id)
	write_byte(onos_id)
	write_byte(victim_id)
	write_string("devour")
	message_end()
	entity_set_float(onos_id, EV_FL_frags, entity_get_float(onos_id, EV_FL_frags) + 1.0)
	ns_set_score(onos_id, ns_get_score(onos_id) + 1)
}

gestate_messages( id , hide_weapons , progress , scoreboard_class , iuser3_class )
{
	entity_set_int(id, EV_INT_iuser3, iuser3_class)
	
	message_begin(MSG_ONE, HideWeapon_id, {0,0,0}, id)
	write_byte(hide_weapons)
	message_end()
	
	message_begin(MSG_ONE, Progress_id, {0,0,0}, id)
	write_short(progress)
	write_byte(3)
	message_end()
	
	message_begin(MSG_ALL, ScoreInfo_id)
	write_byte(id)
	write_short(ScoreInfo_data[id][0])
	write_short(ScoreInfo_data[id][1])
	write_short(ScoreInfo_data[id][2])
	write_byte(scoreboard_class)
	write_short(ScoreInfo_data[id][4])
	write_short(2)
	message_end()
}

/* Timer Functions */
public set_weapon_damage_timer( timerid_id )
{
	new id = timerid_id - 300
	if ( is_user_connected(id) )
		set_weapon_damage(id)
}

public check_weapons_after_impulse( parm[] )
{
	new id = parm[0]
	if ( is_user_connected(id) )
	{	// check if player got weapon or been blocked
		new weapon_id = parm[1]
		new weapon_list[32], weapon_num, found
		get_user_weapons(id, weapon_list, weapon_num)
		
		for ( new a = 0; a < weapon_num; a++ )
		{
			if ( weapon_list[a] == weapon_id )
			{
				if ( !g_player_used_weap_imp[id][parm[2]] )
				{
					found = 1
					g_player_used_weap_imp[id][parm[2]] = 1
				}
				break
			}
		}
		
		if ( found )
			set_weapon_damage(id, weapon_id)
	}
}

/* This function is called by Gnome to update who is gnome */
public who_is_gnome( id , gnome_number , make_him , gnomespeed )
{
	gnome_speed = gnomespeed
	if ( make_him )
		gnome_id[gnome_number] = id
	else
		gnome_id[gnome_number] = 0
}

/* This function sends information to Gnome */
armorup_to_gnome( id )
{
	new check = callfunc_begin("gnome_ap_info", "gnome.amxx")
	
	if ( check == 0 )
		log_amx("Plugin ^"gnome.amxx^" Runtime error")
	else if ( check == -1 )
		log_amx("Plugin ^"gnome.amxx^" not found")
	else if ( check == -2 )
		log_amx("Function ^"gnome_ap_info^" not found")
	else
	{
		callfunc_push_int(id)
		callfunc_push_int(g_armorupgrade[id])
		callfunc_push_int(ARMOR_MA)
		callfunc_push_int(ARMOR_HA)
		callfunc_push_intrf(gnome_base_armor)
		callfunc_push_intrf(gnome_max_armor)
		callfunc_end()
	}
}