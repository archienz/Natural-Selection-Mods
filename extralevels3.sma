/*
*	Allows players to go above Level 10 in Combat, and adds 12 new upgrades (6 for Marines, 6 for Aliens)
*
* Author:
*	-> White Panther
*
* Credits:
*	-> Cheesy Peteza					-	his ExtraLevels plugin
*	-> Cheeserm! (alias Silent Skulk)			-	ExtraLevels2 (his advancements to ExtraLevels)
*	-> Depot						-	his assistance in getting bugs fixed
*	-> [I-AM]Xman						-	his assistance in getting bugs fixed
*	-> nf.crew | DeAtH07 and his clan			-	his/their assistance in getting bugs fixed
*	-> Bailey "Zed" Dickens and NSWarGames.com Community	-	his/their assistance in getting bugs fixed
*	-> ZODIAC and the RichNet NS Community			-	his/their assistance in getting bugs fixed
*
* Usage:
*	-> say "xmenu" or "/xmenu" to bring up a menu of extra upgrades
*	-> say "/xhelp" to bring up a menu with some information
*	-> amx_maxlevel		-	Set to the highest level you want to allow (default 50)
*
*	Version 0.7.8b "ExtraLevels 2 Rework" is a rework of the plugin "ExtraLevels 2" based on Cheeserm!'s "ExtraLevels 2 v1.7e" (28.01.05)
*	With version 1.2.0 its name has changed from "ExtraLevels 2 Rework" to "ExtraLevels 3"
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
*		- incorrect display of next level staticfield and etherealtracking (++)
*		- some sounds not being precached and wrong/unnecessary sounds being used
*		- ethereal shift acting as one level lower than player has
*	- added:
*		- Gnome compatability (95 %)
*		- Gnome gets a reduced speed bonus
*		- when welding over max base armor there is a weld sound
*		- SHIFTCLASSMULTI define: skulk, gorge and lerk SHIFTLEVEL gets multiplied by it (eg: level 5 time: old = 2,25 / new = 3,50)
*		- player now only get as many points as he can spent
*	- changed:
*		- many code improvements (~600 lines saved, removed 16 timers and added 1, ...)
*		- selfweld sound system (1 sound constant + 1 sound every selfweld-time is done) (old: every selfweld-time 1 random sound out of 2)
*		- onos can now do etherealshift (can be turned off with a define)
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
*		- server_frame is hooked with ent and support other plugins that uses the same system (speed improvement THANKS OneEyed)
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
*
* v1.2.0:
*	- fixed:
*		- level hud display was not removed when spectating level 11++ and then someone below level 10
*		- calculation bug with max levels for each upgrade (THANKS peachy)
*		- when reaching max lvl (default lvl 50) no point has been given (using cheats to directly get lvl 50 = player got no points)
*		- when player reached max level, a level up sound was playing when reached next level (eg: level 50 (= max level) and got enough XP for level 51, sound was played ) (plugin is internally counting levels over maxlevel)
*		- Sense of Ancients "Multi Devour", you needed to finish devouring all players before you could use devour again, now working correctly so you can devour next player right after one is finished
*		- "EV_FL_max_health" / "pev_max_health" is now set for aliens, so other plugins easily find out what is max health for this player
*		- display of XP and level does not vanish anymore
*		- focus was counted as a 1 point upgrade and therefor it was possible that aliens did not get all possilbe points with special settings
*		- support for NS 3.1.2
*		- when player lost XP below level 10, HUD text was not removed (with amx_huddisplay = 1)
*		- players could get Static Field without Motion Tracking (THANKS PulsateX)
*		- Onos gestating in small areas will not get stuck that easy anymore
*		- Sense of Ancients "Multi Devour" was not reseted correctly when player left team
*		- "Ethereal Shift" was not working correctly, either "laggy" (shift started and one second later invisible ) or during cloak you did not became invisible
*		- exploit where player could keep upgrades
*	- added:
*		- new upgrade: "Advanced Ammopack" will allow marines to carry more ammo and have bigger clips
*		- when looking at a player the info box now shows correct level (eg: not level 10 even if being level 16)
*		- ability to use config file ("addons/amxmodx/configs/extralevels3.cfg")
*		- XP gain has been advanced, limit is not level 10 (max 170 XP for a lvl 10 enemy) but "max_level" (eg: lvl 20 = 270 XP for a lvl 20 enemy)
*		- Sense of Ancients "Multi Devour" now giving XP when digesting more than one player
*		- info for people who still using old menu command
*		- SHIFTDELAY setting: how long alien needs to wait between 2 shitfs. added to prevents exploits (THANKS Antecedent for notice)
*		- little support for "Lerkspike" so Lerks will not lose it when gestating
*	- changed:
*		- "ExtraLevels2 Rework" is now called "ExtraLevels 3" (should have been done with 1.0.0 but forgot :P)
*		- "Ethereal Tracking" has been replaced with "Advanced Ammopack"
*		- max level is not set to infinite via 0 (zero) but by the number you like (0 was infinite = 999, but now you can use bigger numbers)
*		- XP System: old and new one can be used (set via define or configfile) (old = based on killer level / new = based on victim level)
*		- cloaked aliens are not affected by "Static Field"
*		- during "Ethereal Shift" normal CLOAK upgrade is deactivated so scan will not try to detect a player as it cannot uncloak him
*		- removed support for old armor using NS 3.0.3 or lower
*		- menu adjustment for disabled upgrades (new: player cannot try to buy them anymore, old: player bought and got a message that it was disabled)
*		- "Static Field" is now weakening less HP but therefor also AP
*		- "Static Field" is now executed every two seconds instead of every second
*		- adjusted some default values
*		- many code improvements
*		- many speed improvements
*
* v1.2.2:
*	- fixed:
*		- bug where server could crash
*		- shotgun could get more extra ammo than allowed
*		- runtime error
*		- problems where player was sometimes unable to reload
*		- Sense of Ancients "Multi Devour" was not working due to little bug
*		- Sense of Ancients Fade upgrade was not working
*		- bug where HUD message was not displayed when reached level 50
*	-changed:
*		- little code tweak
*
* v1.2.5b: (compatability for Gnome 0.7.8 or higher / older Gnome versions will not work)
*	- fixed:
*		- exploit where player could get two upgrades with one gestate (only saved some time, but no point winning)
*		- GL was only reloading when having three or less ammo
*		- Hunger is now considered for "Static Field" calculation
*		- log is not spammed anymore
*		- HP bug with gestating and thickened skin
*	- added:
*		- better resupply compatability with Gnome
*	- changed:
*		- entity_get/set_xxx replaced with pev/set_pev ( performance )
*		- new way of communication with Gnome
*		- improved method to recognize resupply
*		- "Static Field" now requires Scan Area
*		- code tweaks
*
* v1.3.0: (compatability for Gnome 0.8.2 or higher / older Gnome versions will be buggy)
*	- fixed:
*		- when diing while having Hunger, player could keep speed
*		- gestate could take 0 seconds
*		- thickened skin could be not recognized and wierd HP activity due to 0 seconds gestate
*		- when reloading GL with Adv Ammo and below level 10 no message about reloading was shown
*		- devoured players could get stuck in onos
*		- players being digested could be killed when onos redeemed without a reason
*		- players could get godmode during gestation
*		- player could respawn with old class ( eg: lerk )
*		- when gestating 4th hive upgrade could be still purchased
*		- Hunger was not reset on new round
*	- added:
*		- players now see when Ethereal Shift starts and ends
*		- players now see if they have been infected by another player cause of SoA parasite
*		- native for other plugins to get player level ( usage: new level = EL_get_level(id) )
*		- new upgrade: "Acidic Vengeance" will make aliens to explode when being killed and damaging all nearby enemies
*		- players can now exactly see how many points they can spend
*	- changed:
*		- aliens are not affected by staticfield during ethereal shift anymore
*		- rewrote level/experience calculation
*		- modification to custom levels/EXP
*		- Bloodlust for Onos only applies for 33%
*		- moved from server_frame_fake to real server_frame ( speed difference is not noticeable and will save one entity )
*		- already parasited players will not spread parasite when being it with SoA parasite
*		- removed support for old experience system ( NS internal EXP system is incorrect )
*		- new message functions for better support for other plugs
*		- code optimization
*
* v1.3.0b:
*	- fixed:
*		- "Acidic Vengeance" could do more damage than specified ( could kill full HP/AP players )
*
* v1.3.5:
*	- fixed:
*		- when player reached last level ( default 50 ) extra HUD messages where bugged
*		- Onos being able to gestate while devouring ( thx schnitzelmaker )
*		- gestating players could stay gestate and not being able to be killed
*		- crash bug with StatusValue
*		- a bit too much EXP was given
*		- Ethereal Shift:
*			- time could keep counting even if dead
*			- Config for level requirement was ignored
*			- delay time was ignored
*		- Hunger:
*			- hungertime is now current level and not level - 1 anymore
*		- Advanced Ammo:
*			- fixed several reloading bugs
*		- Staticfield:
*			- cloaked aliens have still been included into calculation
*			- range is now current level and not level - 1 anymore
*			- menu now shows correct percentage value
*		- Acidic Vengeance:
*			- possible bug that was trying to kill player who started Acidic Vengeance again
*		- Sense of Ancients:
*			- healingspray now has correct value ( was 15.6 now is 13.0 )
*	- addded:
*		- when Helper is loaded, notify and information are only shown once
*		- Ban System to ban players from buying upgrades
*	- changed:
*		- improved calculation ( thx peachy )
*		- Custom XP System reversed to v1.2.5b
*		- Advanced Ammo:
*			- partly rewritten
*		- Hunger:
*			- speed bonus is not multiplied by Hunger level anymore
*			- hunger bonus HP for Staticfield is not used as increaser of maxHP anymore (old: maxStaticHP = maxHP + hungerHP , new: maxStaticHP = maxHP or currentHP if bigger maxHP )
*		- Sense of Ancients:
*			- parasite chance now increases each level ( max 40% ) and range is constant ( it was constant anyway even if said different )
*			- decreased parasite time from 5 to 3 seconds
*			- increased range from 200.0 to 250.0
*			- each player has his own chance to get parasited ( if one player got infected it does not mean the rest in range will get infected too )
*
* v1.3.5b:
*	- fixed:
*		- runtime error
*/

#include <amxmodx>
#include <engine>
#include <fakemeta>
#include <ns>

// set this to 0 if you want to use the defines instead of a config file
#define USE_CONFIG_FILE		1

// change this number if you need a bigger ban list
#define MAX_BAN_NUM		100

// set this to 0 if you are running NS 3.2 or above
#define PRE_NS_3_2		1

// !!!!!!!!!!!!!!!!!!!! DO NOT CHANGE THIS LINE OR PLUGIN WILL BE MESSED UP !!!!!!!!!!!!!!!!!!!!
#if USE_CONFIG_FILE == 0
// !!!!!!!!!!!!!!!!!!!! BUT YOU CAN CHANGE THINGS BELOW !!!!!!!!!!!!!!!!!!!!

// upgrade enabled/disable
#define CYBERNETICS		1		// Set to "0" to disable the Cybernetics upgrade
#define REINFORCEARMOR		1		// Set to "0" to disable the Reinforced Armor upgrade
#define NANOARMOR		1		// Set to "0" to disable the Nano Armor upgrade
#define ADVAMMOPACK		1		// Set to "0" to disable the Advanced Ammopack upgrade
#define STATICFIELD		1		// Set to "0" to disable the Static Field upgrade
#define WELDOVERBASE		1		// Set to "0" to disable normal welders from welding above the base max armor when the target has Reinforced Armor
#define URANUIMAMMO		1		// Set to "0" to disable the Uranium Ammunition upgrade

#define THICKSKIN		1		// Set to "0" to disable the Thickened Skin upgrade
#define ETHSHIFT		1		// Set to "0" to disable the Ethereal Shift upgrade
#define BLOODLUST		1		// Set to "0" to disable the Blood Lust upgrade
#define HUNGER			1		// Set to "0" to disable the Hunger upgrade
#define ACIDICVENGEANCE		1		// Set to "0" to disable the Acidic Vengeance upgrade
#define SENSEOFANCIENTS		1		// Set to "0" to disable the Sense of Ancients upgrade

// upgrade costs
#define CYBERNETICSCOST		1		// Set to the amount of points you want Cybernetics to cost
#define REINFORCEARMORCOST	1		// Set to the amount of points you want Reinforced Armor to cost
#define NANOARMORCOST		1		// Set to the amount of points you want Nano Armor to cost
#define ADVAMMOPACKCOST		1		// Set to the amount of points you want Advanced Ammopack to cost
#define STATICFIELDCOST		2		// Set to the amount of points you want Static Field to cost
#define URANUIMAMMOCOST		1		// Set to the amount of points you want Uranium Ammunition to cost

#define THICKSKINCOST		1		// Set to the amount of points you want Thickened Skin to cost
#define ETHSHIFTCOST		1		// Set to the amount of points you want Ethereal Shift to cost
#define BLOODLUSTCOST		1		// Set to the amount of points you want Blood Lust to cost
#define HUNGERCOST		1		// Set to the amount of points you want Hunger to cost
#define ACIDICVENGEANCECOST	1		// Set to the amount of points you want Acidic Vengeance to cost
#define SENSEOFANCIENTSCOST	1		// Set to the amount of points you want Sense of Ancients to cost

// upgrade max level
#define CYBERNETICSMAX		5		// Set to the max level of the Cybernetics upgrade you want it to be
#define REINFORCEARMORMAX	5		// Set to the max level of the Rienforced Armor upgrade you want it to be
#define NANOARMORMAX		5		// Set to the max level of the Nano Armor upgrade you want it to be
#define ADVAMMOPACKMAX		5		// Set to the max level of the Advanced Ammopack upgrade you want it to be
#define STATICFIELDMAX		5		// Set to the max level of the Static Field upgrade you want it to be
#define URANUIMAMMOMAX		5		// Set to the max level of the Uranium Ammunition upgrade you want it to be

#define THICKENEDSKINMAX	5		// Set to the max level of the Thickened Skin upgrade you want it to be
#define ETHSHIFTMAX		5		// Set to the max level of the Ethereal Shift upgrade you want it to be
#define BLOODLUSTMAX		5		// Set to the max level of the Blood Lust upgrade you want it to be
#define HUNGERMAX		5		// Set to the max level of the Hunger upgrade you want it to be
#define ACIDICVENGEANCEMAX	5		// Set to the max level of the Acidic Vengeance upgrade you want it to be
#define SENSEOFANCIENTSMAX	5		// Set to the max level of the Sense of Ancients upgrade you want it to be

// CYBERNETICS options
#define CYBERNETICSLEVEL	5		// Required player level to get the Cybernetics upgrade
#define SPEED_MA		15		// Amount of speed normal marines and jet-packers get per level of cybernetics
#define SPEED_HA		8		// Amount of speed heavy marines get per level of cybernetics

// REINFORCEARMOR options
#define REINFORCEARMORLEVEL	0		// Required player level to get the Reinforced Armor upgrade
#define ARMOR_MA		10		// Amount of armor normal marines and jet-packers get per level of reinforced armor
#define ARMOR_HA		20		// Amount of armor heavy marines get per level of reinforced armor

// NANOARMOR options
#define NANOARMORLEVEL		0		// Required player level to get the Nano Armor upgrade
#define NANOARMOR_MA		2		// Amount of armor normal marines and jet-packers self-weld per second per level of nano armor
#define NANOARMOR_HA		4		// Amount of armor heavy marines self-weld per second per level of nano armor

// ADVAMMOPACK options
#define ADVAMMOPACKLEVEL	0		// Required player level to get the Advanced Ammopack upgrade
#define ADVAMMOPACK_PISTOL	2.0		// Amount of ammo players get per level for Pistol (do not use settings like 2.5, this is GL only)
#define ADVAMMOPACK_LMG		5.0		// Amount of ammo players get per level for LMG (do not use settings like 5.5, this is GL only)
#define ADVAMMOPACK_SHOTGUN	1.0		// Amount of ammo players get per level for Shotgun (do not use settings like 1.5, this is GL only)
#define ADVAMMOPACK_HMG		10.0		// Amount of ammo players get per level for HMG (do not use settings like 10.5, this is GL only)
#define ADVAMMOPACK_GL		0.5		// Amount of ammo players get per level for GL

// STATICFIELD options
#define STATICFIELDLEVEL	0		// Required player level to get the Static Field upgrade
#define STATICFIELDINITIALRANGE	400		// Amount of range the Static Field upgrade starts out with
#define STATICFIELDLEVELRANGE	50		// Amount of range the Static Field upgrade gains per level
#define STATICFIELDNUMERATORLV	1		// The increase in numerator for the Static Field upgrade per level
#define STATICFIELDDENOMENATOR	8		// The denomenator in the Static Field fraction
#define MAXSTATICNUMERATOR	5		// The maximum numerator for the Static Field fraction, I suggest keeping it at 5 or below to prevent aliens becoming too weak

// URANUIMAMMO options
#define URANUIMAMMO_BULLET	12		// Amount of percent the Bullets damage will be improved each level
#define URANUIMAMMO_GREN	7		// Amount of percent the Grenades damage will be improved each level

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
#define SHIFTLEVEL		0.3		// Amount of invisibility time that is added to the initial amount for every level gained in Ethereal Shift after 1st (seconds)
#define SHIFTCLASSMULTI		2		// Set to how much a Skulk's, Lerk's and Gorge's SHIFTLEVEL should be increased (default 2 times longer shift than fade or onos)
#define ONOS_SHIFT		1		// Set to "0" to disable Ethereal Shift for Onos
#define SHIFTDELAY		2.0		// Amount of time player needs to wait till he can do Ethereal Shift again

// BLOODLUST options
#define BLOODLUSTLEVEL		0		// Required player level to get the Blood Lust upgrade
#define BLOODLUSTSPEED		4		// Amount of energy added every 0.1 seconds per level of Blood Lust (note that the normal energy gain speed is ~7 and with adrenaline ~16)

// HUNGER options
#define HUNGERLEVEL		0		// Required player level to get the Hunger upgrade
#define HUNGERSPEED		6		// Amount of speed an alien gets per kill per level of hunger for the time that the hunger bonus last
#define HUNGERHEALTH		10		// Percent of max health that is added to the alien's current health per level (when it kills something)
#define HUNGERINITIALTIME	3.0		// Amount of initial time that the Hunger upgrade's bonuses last (seconds)
#define HUNGERLEVELTIME		1.0		// Amount of time that is added to the initial Hunger upgrade's bonus time (seconds)

// ACIDICVENGEANCE options
#define ACIDICVENGEANCELEVEL	0		// Required player level to get the Acidic Vengeance upgrade
#define AV_MA_HP		5.0		// Amount of HP enemy loses per level for normal Marine and JP
#define AV_MA_AP		5.0		// Amount of HP enemy loses per level for normal Marine and JP
#define AV_HA_HP		5.0		// Amount of HP enemy loses per level for Heavy Armor
#define AV_HA_AP		5.0		// Amount of AP enemy loses per level for Heavy Armor
#define AV_GORGE_GEST_MULTI	1.5		// Multiplier for gorge and gestate. HP and AP values will be multiplied by this one (set to 1.0 for no advantage)

// SENSEOFANCIENTS options
#define SOA_PARASITE_INIT	5		// Amount of percent the SoA upgrade for Skulks starts out with
#define SOA_PARASITE_ADD	5		// Amount of percent the SoA upgrade for Skulks gains per level
#define SOA_PARASITE_DMG	3		// Amount of percent the Parasite will be improved each level
#define SOA_HEALSPRAY_DMG	30		// Amount of percent the Healspray will be improved each level
#define SOA_GASDAMAGE		3		// Amount of damage Marines with HA get by gas
#define SOA_BLINK_ENERGY_BONUS	20		// Amount of percent the Blink's energy requirement will be reduced each level
#define SOA_DEVOUR_ADDER	5		// Amount of levels needed to devour one more player (starting with level 1, eg: setting to 5 means with level 1, 6, 11,... one more player)
#define SOA_DEVOURTIME_INIT	1.5		// Amount of time player needs to wait to enable 2nd Devour (initial time)
#define SOA_DEVOURTIME_BONUS	0.2		// Amount of time decreasing the time to wait for 2nd Devour each level
#define SOA_GESTATE_ARMOR_ADD	15		// Amount of Armor bonus a gestating alien gets each level

// Adjust level needed for each level (starting with 11)
#define CUSTOM_LEVELS			0	// Set this to "1" to use the configs below

#define BASE_XP_TO_NEXT_LEVEL		500.0	// XP needed to get to next level (level 10 = 2700 XP + 500 + NEXT_LEVEL_XP_MODIFIER = level 11)
#define NEXT_LEVEL_XP_MODIFIER		50.0	// XP that is added to BASE_XP_TO_NEXT_LEVEL each level up (eg: level 11 => 2700 + 500 + 50 => level 12 / level 12 => 3250 + 500 + 50 + 50 => level 13)

#else

#define	item_list_num	99

////////////////////////////////////////////////////////////////////////////////////////////////////////
/// DO NOT MODIFY THESE 3 LISTS OR PLUGIN WILL BE BUGGED, EITHER USE DEFINES ABOVE OR THE CONFIGFILE ///
////////////////////////////////////////////////////////////////////////////////////////////////////////

new const item_list[item_list_num][] =
{
	"CYBERNETICS", "REINFORCEARMOR", "NANOARMOR", "ADVAMMOPACK", "STATICFIELD", "WELDOVERBASE", "URANUIMAMMO", "THICKSKIN", "ETHSHIFT", "BLOODLUST", "HUNGER", "ACIDICVENGEANCE", "SENSEOFANCIENTS",
	"CYBERNETICSCOST", "REINFORCEARMORCOST", "NANOARMORCOST", "ADVAMMOPACKCOST", "STATICFIELDCOST", "URANUIMAMMOCOST", "THICKSKINCOST", "ETHSHIFTCOST", "BLOODLUSTCOST", "HUNGERCOST", "ACIDICVENGEANCECOST", "SENSEOFANCIENTSCOST",
	"CYBERNETICSMAX", "REINFORCEARMORMAX", "NANOARMORMAX", "ADVAMMOPACKMAX", "STATICFIELDMAX", "URANUIMAMMOMAX", "THICKENEDSKINMAX", "ETHSHIFTMAX", "BLOODLUSTMAX", "HUNGERMAX", "ACIDICVENGEANCEMAX", "SENSEOFANCIENTSMAX",
	"CYBERNETICSLEVEL", "SPEED_MA", "SPEED_HA",
	"REINFORCEARMORLEVEL", "ARMOR_MA", "ARMOR_HA",
	"NANOARMORLEVEL", "NANOARMOR_MA", "NANOARMOR_HA",
	"ADVAMMOPACKLEVEL", "ADVAMMOPACK_PISTOL", "ADVAMMOPACK_LMG", "ADVAMMOPACK_SHOTGUN", "ADVAMMOPACK_HMG", "ADVAMMOPACK_GL",
	"STATICFIELDLEVEL", "STATICFIELDINITIALRANGE", "STATICFIELDLEVELRANGE", "STATICFIELDNUMERATORLV", "STATICFIELDDENOMENATOR", "MAXSTATICNUMERATOR",
	"URANUIMAMMO_BULLET", "URANUIMAMMO_GREN",
	"THICKENEDSKINLEVEL", "HEALTHSKULK", "HEALTHGORGE", "HEALTHLERK", "HEALTHFADE", "HEALTHONOS", "HEALTHGESTATE",
	"ETHSHIFTLEVEL", "SHIFTINITIAL", "SHIFTLEVEL", "SHIFTCLASSMULTI", "ONOS_SHIFT", "SHIFTDELAY",
	"BLOODLUSTLEVEL", "BLOODLUSTSPEED",
	"HUNGERLEVEL", "HUNGERSPEED", "HUNGERHEALTH", "HUNGERINITIALTIME", "HUNGERLEVELTIME",
	"ACIDICVENGEANCELEVEL", "AV_MA_HP", "AV_MA_AP", "AV_HA_HP", "AV_HA_AP", "AV_GORGE_GEST_MULTI",
	"SOA_PARASITE_INIT", "SOA_PARASITE_ADD", "SOA_PARASITE_DMG", "SOA_HEALSPRAY_DMG", "SOA_GASDAMAGE", "SOA_BLINK_ENERGY_BONUS", "SOA_DEVOUR_ADDER", "SOA_DEVOURTIME_INIT", "SOA_DEVOURTIME_BONUS", "SOA_GESTATE_ARMOR_ADD",
	"CUSTOM_LEVELS", "BASE_XP_TO_NEXT_LEVEL", "NEXT_LEVEL_XP_MODIFIER"
}

new item_setting[item_list_num] =
{
	1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,	// upgrade enabled/disable
	1, 1, 1, 1, 2, 1, 1, 1, 1, 1, 1, 1,	// upgrade costs
	5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5	, 5,	// upgrade max level
	5, 20, 10,				// CYBERNETICS options
	0, 10, 20,				// REINFORCEARMOR options
	0, 2, 4,				// NANOARMOR options
	0, 0, 0, 0, 0, 0,			// ADVAMMOPACK options
	0, 400, 50, 1, 8, 5,			// STATICFIELD options
	17, 10,					// URANIUMAMMO options
	
	0, 0, 0, 0, 0, 0, 0,			// THICKSKIN options
	5, 0, 0, 2, 1, 0,			// ETHSHIFTMAX options
	0, 4,					// BLOODLUSTCOST options
	0, 6, 10, 0, 0,				// HUNGERCOST options
	0, 0, 0, 0, 0, 0,			// ACIDICVENGEANCE options
	200, 30, 3, 30, 3, 20, 5, 0, 0, 15,	// SENSEOFANCIENTS options
	0, 50
}

new Float:item_setting_fl[item_list_num] =
{
	0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,	// upgrade enabled/disable
	0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,		// upgrade costs
	0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,		// upgrade max level
	0.0, 0.0, 0.0,								// CYBERNETICS options
	0.0, 0.0, 0.0,								// REINFORCEARMOR options
	0.0, 0.0, 0.0,								// NANOARMOR options
	0.0, 2.0, 5.0, 1.0, 10.0, 0.5,						// ADVAMMOPACK options
	0.0, 0.0, 0.0, 0.0, 0.0, 0.0,						// STATICFIELD options
	0.0, 0.0,								// URANIUMAMMO options
	
	0.0, 10.0, 25.0, 15.0, 25.0, 30.0, 20.0,				// THICKSKIN options
	0.0, 1.0, 0.25, 0.0, 0.0, 2.0,						// ETHSHIFTMAX options
	0.0, 0.0,								// BLOODLUSTCOST options
	0.0, 0.0, 0.0, 3.0, 1.0,						// HUNGERCOST options
	0.0, 3.0, 4.0, 5.0, 10.0, 1.5,						// ACIDICVENGEANCE options
	0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.5, 0.2, 0.0,			// SENSEOFANCIENTS options
	0.0, 0.0
}

new CYBERNETICS, REINFORCEARMOR, NANOARMOR, ADVAMMOPACK, STATICFIELD, WELDOVERBASE, URANUIMAMMO
new THICKSKIN, ETHSHIFT, BLOODLUST, HUNGER, ACIDICVENGEANCE, SENSEOFANCIENTS
new CYBERNETICSCOST, REINFORCEARMORCOST, NANOARMORCOST, ADVAMMOPACKCOST, STATICFIELDCOST, URANUIMAMMOCOST
new THICKSKINCOST, ETHSHIFTCOST, BLOODLUSTCOST, HUNGERCOST, ACIDICVENGEANCECOST, SENSEOFANCIENTSCOST
new CYBERNETICSMAX, REINFORCEARMORMAX, NANOARMORMAX, ADVAMMOPACKMAX, STATICFIELDMAX, URANUIMAMMOMAX
new THICKENEDSKINMAX, ETHSHIFTMAX, BLOODLUSTMAX, HUNGERMAX, ACIDICVENGEANCEMAX, SENSEOFANCIENTSMAX

new CYBERNETICSLEVEL
new SPEED_MA, SPEED_HA
new REINFORCEARMORLEVEL
new ARMOR_MA, ARMOR_HA
new NANOARMORLEVEL
new NANOARMOR_MA, NANOARMOR_HA
new ADVAMMOPACKLEVEL
new Float:ADVAMMOPACK_PISTOL, Float:ADVAMMOPACK_LMG
new Float:ADVAMMOPACK_SHOTGUN, Float:ADVAMMOPACK_HMG, Float:ADVAMMOPACK_GL
new STATICFIELDLEVEL
new STATICFIELDINITIALRANGE, STATICFIELDLEVELRANGE
new STATICFIELDNUMERATORLV, STATICFIELDDENOMENATOR, MAXSTATICNUMERATOR
new URANUIMAMMO_BULLET, URANUIMAMMO_GREN

new THICKENEDSKINLEVEL
new Float:HEALTHSKULK, Float:HEALTHGORGE, Float:HEALTHLERK
new Float:HEALTHFADE, Float:HEALTHONOS, Float:HEALTHGESTATE
new ETHSHIFTLEVEL
new Float:SHIFTINITIAL, Float:SHIFTLEVEL
new SHIFTCLASSMULTI, ONOS_SHIFT, Float:SHIFTDELAY
new BLOODLUSTLEVEL
new BLOODLUSTSPEED
new HUNGERLEVEL
new HUNGERSPEED, HUNGERHEALTH
new Float:HUNGERINITIALTIME, Float:HUNGERLEVELTIME
new ACIDICVENGEANCELEVEL
new Float:AV_MA_HP, Float:AV_MA_AP, Float:AV_HA_HP, Float:AV_HA_AP, Float:AV_GORGE_GEST_MULTI
new SOA_PARASITE_INIT, SOA_PARASITE_ADD, SOA_PARASITE_DMG, SOA_HEALSPRAY_DMG
new SOA_GASDAMAGE, SOA_BLINK_ENERGY_BONUS, SOA_DEVOUR_ADDER
new Float:SOA_DEVOURTIME_INIT, Float:SOA_DEVOURTIME_BONUS, SOA_GESTATE_ARMOR_ADD

new CUSTOM_LEVELS, BASE_XP_TO_NEXT_LEVEL, NEXT_LEVEL_XP_MODIFIER

#endif

////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////// *** DO NOT MODIFY BELOW EXCEPT YOU KNOW WHAT YOU ARE DOING *** ////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////

// function for communication with GNOME
native GNOME_setget_armor(GNOME_id, GNOME_APup, GNOME_ARMOR_MA, GNOME_ARMOR_HA, &GNOME_base_armor, &GNOME_max_armor)

// gives ExtraLevels 3 16k of memory for variables
#pragma dynamic 4096

#define MARINE			1
#define ALIEN			2
#define HUD_CHANNEL		3

#define WEAPON_RELOADING_OFF		94	// this offset is needed to check if weapon is reloading
#define WEAPON_RELOADING_OFF_LIN	4	// defines the difference between win32 to linux

#define WEAPRELOTIME_OFF		126	// this offset is needed to check if player is reloading right now or now (allowed to fire his weapon)
#define WEAPRELOTIME_OFF_LIN		5	// defines the difference between win32 to linux

#define IN_ONOS_OFF			160	// this offset is needed to check if player is being digested or is a digester
#define IN_ONOS_OFF_LIN			5	// defines the difference between win32 to linux

#define UNCLOAKTIME_OFF			449	// this offset sets the time when alien started uncloak (-1.0 when cloaked)
#define UNCLOAKTIME_OFF_LIN		5	// defines the difference between win32 to linux

#define CLOAK_OFF			450	// this offset is needed to check if player is "cloaked" / "cloak fade in/out" right now or not (int = cloaked or not // float = sequence of cloak fade in/out)
#define CLOAK_OFF_LIN			5	// defines the difference between win32 to linux

#if PRE_NS_3_2 == 0
#define OLD_CLASS_OFF			1564	// this offset is needed to set players old class for gestate emulation
#define OLD_CLASS_OFF_LIN		4	// defines the difference between win32 to linux

#define DIGESTING_PLAYER_OFF		1609	// this offset is needed to check which player is currently digested by the onos
#define DIGESTING_PLAYER_OFF_LIN	5	// defines the difference between win32 to linux
#else
#define OLD_CLASS_OFF			1558	// this offset is needed to set players old class for gestate emulation
#define OLD_CLASS_OFF_LIN		5	// defines the difference between win32 to linux

#define DIGESTING_PLAYER_OFF		1602	// this offset is needed to check which player is currently digested by the onos
#define DIGESTING_PLAYER_OFF_LIN	5	// defines the difference between win32 to linux
#endif

#define IMPULSE_READYROOM		5
#define	IMPULSE_RESUPPLY		31
#define IMPULSE_GRENADE			37
#define	IMPULSE_SCAN			53
#define IMPULSE_SHOTGUN			64
#define IMPULSE_HMG			65
#define IMPULSE_GL			66
#define IMPULSE_FLASLIGHT		100
#define IMPULSE_CARAPACE		101
#define IMPULSE_REDEMPTION		103
#define IMPULSE_CELERITY		107
#define IMPULSE_SENSEOFFEAR		112
#define IMPULSE_HIVE3_ABILITY		118
#define IMPULSE_HIVE4_ABILITY		126

#define CHANGED_TO_WEAPON		6
#define SET_TECH_ON			4

// Advanced Ammopack
//#define BASE

// Uranium Ammo + Sense of Ancients
#define BASE_DAMAGE_HG			20.0	// Pistol
#define BASE_DAMAGE_LMG			10.0	// Machinegun
#define BASE_DAMAGE_SG			17.0	// Shotgun
#define BASE_DAMAGE_HMG			20.0	// Heavymachingun
#define BASE_DAMAGE_GL			125.0	// Grenadelauncher
#define BASE_DAMAGE_GREN		80.0	// Handgrenade
#define BASE_DAMAGE_PARA		10.0	// Parasite
#define BASE_DAMAGE_HEAL		13.0	// Healspray

// Thinkened Skin
#define TS_BASE_HP			0
#define TS_ADD_HP			1
#define TS_HIVEREGEN			2
#define TS_HP_REGEN			3
#define TS_MAX_HP			4
#define TS_MAX_AP			5

#define BASE_MAX_LEVEL			10
#define MAX_BASE_MARINE_AP		90.0
#define MAX_BASE_HEAVY_AP		290.0
#define METABOLIZE_HEAL_RATE		20.0
#define HIVE_RANGE			525.0
#define SOA_PARASITE_RANGE		250.0
#define SOA_ONOS_HP_ADD			15.0
#define SOA_ONOS_HP_REDUCER		15.25
#define SOA_ONOS_BASE_HP		700.0
#define SOA_ONOS_BASE_AP		600.0

#if PRE_NS_3_2 == 0
#define SCOREINFO_ARGS_NUM		10
#else
#define SCOREINFO_ARGS_NUM		8
#endif

enum PLAYER_DATABASE
{
	// general Data
	TEAM,					// check players team
	CUR_LEVEL,				// check players level
	EXTRALEVELS,				// check how many extralevels player already got
	POINTS_AVAILABLE,			// check how many points a player still has remaining
	LASTXP,					// last saved EXP
	LASTLEVEL,				// last saved level
	XP_TO_NEXT_LVL,				// amount of EXP at which player reachs next level
	BASE_LEVEL_XP,				// amount of EXP at which player reached current level
	
	GOT_XP,					// check if player got some extra EXP
	IS_KILLER_OF,				// check whom player has killed
	GOT_RESUPPLY,				// check if player has Resupply
	GOT_SCAN,				// check if player has Scan Area
	
	WEAPON_IMPULSE_DATA[5],			// check if player got weapon by index ( index: 1 = Shotgun / 2 = HMG / 3 = GL / 4 = Grenade )
	
	SCOREINFO_DATA[SCOREINFO_ARGS_NUM + 1],	// saved data from ScoreInfo
	SCOREINFO_DATA_STRING[32],
	
	UPGRADE_CHOICE,				// check which upgrade player has choosen in main menu
	MESSAGE_DISPLAYING,			// check if a Level-Message is displayed
	
	STATUSVALUE_POINTING_AT,		// check which players Status we are viewing right now
	STATUSVALUE_CORECT_LEVEL_OF,		// check which players level shall be corrected in StatusValue
	STATUSVALUE_PLAYER_SWITCHED,		// check if player we are looking at has changed ( either new player or no player )
	
	ALIEN_GESTATE_POINTS,			// amount of points used for lifeform change ( after respawn player will get this amount back )
	CURRENT_WEAPON,				// check current weapon player is holding
	
	Float:HUD_DISP_TIME,			// last time HUD message was displayed
	
	INFORMSSHOWN,				// amount of Information-Messages been shown
	AUTHORSSHOWN,				// amount of Information about Plugin-Messages been shown
	BANNED,					// check if player has been banned from ExtraLevels 3
	
	// Upgrades
	UP_CYBERNETICS,				// check if player has one of these upgrades
	UP_REINFORCEARMOR,
	UP_NANOARMOR,
	UP_ADVAMMOPACK,
	UP_STATICFIELD,
	UP_URANUIMAMMO,
	
	UP_THICKENED_SKIN,
	UP_ETHEREAL_SHIFT,
	UP_BLOODLUST,
	UP_HUNGER,
	UP_ACIDIC_VENGEANCE,
	UP_SENSE_OF_ANCIENTS,
	
	// Reinforced Armor data
	RA_WELDING_OVERMAX,			// check if player is welding someone whos has Reinforced Armor
	RA_WELDED_OVERMAX,			// check if player did a weld on a player with Reinforced Armor
	Float:RA_LASTWELD,			// check when player did last weld on Reinforced Armor
	
	// Nano Armor data
	NA_WELDING_SELF,			// check if Nano Armor is welding player
	Float:NANOWELD_TIME,			// check when player got last Nano weld
	
	// Advanced Ammopack data
	Float:AA_RELOAD_WEAPANIM_TIME,		// time when reload will be done
	Float:AA_GL_RELOTIME_REDUCER,		// amount of time the reload time will be reduced
	AA_UPLVL_GOT_FREEAMMO,			// at which level player got last free ammo when purchasing Advanced Ammo
	
	// Staticfield data
	Float:STATICFIELD_TIME,			// check when Staticfield was active last time
	
	// Thickened Skin data
	Float:TS_LASTREGEN,			// check when player was healed with Thickened Skin
	Float:TS_HEALTH_TIME,			// check when player was checked for Thickened Skin due to hive or metabolize
	Float:TS_LASTHIVEREGEN,			// check when player was healed with Thickened Skin due to hive
	Float:TS_LASTMETABOLIZEREGEN,		// check when player was healed with Thickened Skin due to metabolize
	Float:TS_HEALTH_VALUES[6],		// Thickened Skin HP / AP data ( index: see defines above )
	
	// Ethereal Shift data
	ES_SHIFTING,				// check if player is using Ethereal Shift
	Float:ES_LASTSHIFT,			// check when player did last shift
	Float:ES_SHIFTTIME,			// amount of time player can shift
	
	// Bloodlust data
	Float:LASTBLOODLUST,			// check when player got last bloodlust
	
	// Hunger data
	H_JUSTKILLED,				// check if player killed someone
	H_LASTFRAGCHECK,			// last saved frags
	Float:H_DURRATION,			// check when players Hunger ends
	
	//Sense of Ancients data
	Float:SOA_PARASITE_TIME,		// check when a parasite player due to SoA did last parasite in range
	SOA_FRESH_PARASITE,			// check if player got parasited by skilk or due to SoA and current status of SoA parasite
	SOA_INFECTED_BY_MARINE,			// check which player infected you with SoA parasite
	SOA_MY_PARASITER,			// check who parasited that player
	SOA_PARASITE_CHANCE,			// chance player parasites other players
	
	SOA_IN_SPORE,				// check if player is inside spore
	
	Float:SOA_FADE_ENERGY,			// last stored energy
	SOA_FADE_BLINKED,			// check if Fade just did a Blink
	
	Float:SOA_DIGEST_TIME,			// check when a digesting player is ready for next health decrease
	Float:SOA_NEXTDEVOUR_TIME,		// check when Onos is able to devour next player
	Float:SOA_BLOCK_EVOLVE_MSG_TIME,	// check when player gets a popup telling not being able to gestate
	SOA_JUST_DEVOURED,			// check if player has just devoured someone
	SOA_MAX_DEVOUR_AMOUNT,			// amount of players Onos can devour at most
	SOA_DEVOURING_PLAYERS_NUM,		// amount of players Onos is digesting right now
	SOA_MY_DIGESTER,			// get players digester
	SOA_CURRENTLY_DIGESTING,		// check which player is the most recent disgesting player
	SOA_REDEEMED,				// check if player has redeemed
	SOA_JUST_FREED,				// check if player just got released from digestion ( needed to prevent instant deaths )
	Float:SOA_DEVOUR_TIME,			// amount of time player needs to wait between two player when doing SoA Multi Devour
	SOA_DEVOUR_TIME_MULTIPLIER,		// multiplier for SoA Onos Multi Devour
	Float:ORIG_BEFORE_REDEEM[3],		// VECTOR: origin of Onos just before redeem or leaving alien team
	
	PLAYER_DATABASE_END
}

new player_data[33][PLAYER_DATABASE]

enum CPT_PLAYER_DATABASE
{
	CPT_WEAPON_IDS[4],			// 
	CPT_RELOADING_CUR_WEAP,			// check which weapon player is reloading
	CPT_STARTED_TO_RELOAD,			// check if player started to reload
	
	CPT_AMMO_BEFORE_RELOAD,			// store amount of ammo before reloading with Advanced Ammo
	CPT_RESERVE_BEFORE_RELOAD,		// store amount of reserve ammo before reloading with Advanced Ammo
	
	CPT_SHOTGUN_BULLTES_STOLEN,		// amount of bullets that has been removed from shotgun's reserve
	CPT_SHOTGUN_BULLTES_XTRA_STOLEN,
	CPT_SHOTGUN_BULLTES_TO_STEAL,		// amount of bullets that needs to be removed from shotgun's reserve before reload ends
	CPT_SHOTGUN_BULLTES_TO_STEAL_2,		// similar as above, but independent from it to fix a bug
	
	CPT_BULLTES_STOLEN,
	
	CPT_RESERVE_AMMO_CORRECTOR,		// 
	
	CPT_PLAYER_DATABASE_END
}

new cPT_player_data[33][CPT_PLAYER_DATABASE]

new banList[MAX_BAN_NUM][64]

// Lists of player rank names
new const marine_rang[29][] =
{
	"KAZE XTREME!", "Legendary Dreadnought", "Dreadnought", "Planetary Elite, Class1",
	"Planetary Elite", "Planetary Fighter, Class1", "Planetary Fighter", "Planetary Guard, Class1", "Planetary Guard",
	"Planetary Patrol, Class1", "Planetary Patrol", "Spec Ops, Class1","Spec Ops", "Battle Master",
	"5-Star General", "4-Star General", "3-Star General", "2-Star General", "1-Star General",
	
	"General", "Field Marshal", "Major", "Commander", "Captain",
	"Lieutenant", "Sergant", "Corporal", "Private First Class", "Private"
}

new const alien_rang[29][] =
{
	"FAMINE SPIRIT!", "Black Ethergaunt", "White Ethergaunt", "Red Etherguant",
	"Green Etherguant", "Xerfilstyx", "Paeliryon","Xerfilyx", "Myrmyxicus",
	"Wastrilith", "Skulvynn", "Alkilith", "Klurichir", "Maurezhi",
	"Shatorr", "Kelubar", "Faarastu", "Cronotyryn", "Ancient Behemoth",
	
	"Behemoth", "Nightmare", "Eliminator", "Slaughterer", "Rampager",
	"Attacker", "Ambusher", "Minion", "Xenoform", "Hatchling"
}

// list of upgradelevel CVAR names
new const level_cvar_list[19][] =
{
	"amx_XlevelS", "amx_XlevelR", "amx_XlevelQ", "amx_XlevelP", "amx_XlevelO",
	"amx_XlevelN", "amx_XlevelM", "amx_XlevelL", "amx_XlevelK", "amx_XlevelJ",
	"amx_XlevelI", "amx_XlevelH", "amx_XlevelG", "amx_XlevelF", "amx_XlevelE",
	"amx_XlevelD", "amx_XlevelC", "amx_XlevelB", "amx_XlevelA"
}

// list and enum of sound files
#define MAX_SOUND_FILES		21
new const sound_files[MAX_SOUND_FILES][] =
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
	"player/role7_spawn1.wav",
	"weapons/divinewindexplode.wav"
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
	gestate_finished_first,
	gestate_finished_2nd,
	gestate_finished_3rd,
	gestate_finished_4th,
	gestate_finished_5th,
	xenocide_explode
}

// list of upgrade names
#define ALIEN_UP_ARRAY_START	6
new const upgrade_names[12][] =
{
	"Cybernetics",
	"Reinforced Armor",
	"Nano Armor",
	"Advanced Ammopack",
	"Static Field",
	"Uranium Ammunition",
	"Thickened Skin",
	"Ethereal Shift",
	"Blood Lust",
	"Hunger",
	"Acidic Vengeance",
	"Sense of Ancients"
}

#define MAX_PARASITE_CHANCE		40

// Sense of Ancients Skulk parasite chances
new const rand_para_chance[50] =
{
	9, 13, 27, 32, 46, 59, 65, 74, 88, 97,
	3, 12, 29, 36, 41, 55, 63, 76, 82, 93,
	4, 17, 23, 38, 44, 58, 60, 78, 84, 91,
	5, 14, 24, 35, 47, 52, 69, 71, 89, 95,
	7, 16, 25, 31, 42, 54, 66, 79, 81, 99
}

new const viewmodels[13][] =
{
	"models/v_kn.mdl", "models/v_hg.mdl", "models/v_mg.mdl",
	"models/v_sg.mdl", "models/v_hmg.mdl", "models/v_gg.mdl",
	
	"models/v_kn_hv.mdl", "models/v_hg_hv.mdl", "models/v_mg_hv.mdl",
	"models/v_sg_hv.mdl", "models/v_hmg_hv.mdl", "models/v_gg_hv.mdl",
	
	"models/v_pick.mdl"
}

new const weapmodels[9][] =
{
	"models/p_kn.mdl", "models/p_hg.mdl", "models/p_mg.mdl",
	"models/p_sg.mdl", "models/p_hmg.mdl", "models/p_gg.mdl",
	
	"models/p_pick.mdl", "models/p_hg_gnome.mdl", "models/p_mg_gnome.mdl"
}

new const alien_weapon_list[20][] =
{
	"weapon_bitegun", "weapon_parasite", "weapon_leap", "weapon_divinewind",		// Skulk
	"weapon_spit", "weapon_healingspray", "weapon_bilebombgun", "weapon_webspinner",	// Gorge
	"weapon_bite2gun", "weapon_spore", "weapon_umbra", "weapon_primalscream",		// Lerk
	"weapon_swipe", "weapon_blink", "weapon_metabolize", "weapon_acidrocketgun",		// Fade
	"weapon_claws", "weapon_devour", "weapon_stomp", "weapon_charge"			// Onos
}

new const alien_weapon_num[20] =
{
	5, 10, 21, 12,	// Skulk
	2, 27, 25, 8,	// Gorge
	6, 3, 23, 24,	// Lerk
	7, 11, 9, 26,	// Fade
	1, 30, 29, 22,	// Onos
}

new clcmd_menu_text[] = "saying this will bring up the menu of ExtraLevels 3 upgrades"
new clcmd_help_text[] = "saying this will bring up a help text"
new clcmd_help_text2[] = "saying this will bring up an info telling not to use old menu command"
new no_gestate_digest_msg[180] = "You can't gestate while digesting a player."

//////////////////// General Values ////////////////////

new spore_data[90][2], Float:spore_data_orig[90][3], spore_num

new weapon_resup_ammo[33]	// by weapon ID
new Float:weapon_ammo_adds[33]	// by weapon ID

new global_blockStatusValue = 0

//////////////////// Alien Gestate Emu ////////////////////

new player_gestating_emu[33]
new player_gestating_emu_msg[33]
new Float:player_gestate_time_emu[33]
new player_gestate_emu_class[33]
new player_gestate_extracheck[33]
new Float:player_gestate_hp[33], Float:player_gestate_ap[33], Float:player_gestate_hp_max[33], Float:player_gestate_ap_max[33]
new Float:player_gestate_health_lost[33], Float:player_gestate_armor_lost[33]
new player_gestate_died_during_gest[33]
new Float:player_gestate_origin[33][3]
new SF_gestate_got_spikes[33]


//////////////////// Other Stuff ////////////////////

new const plugin_author[] = "White Panther"
new const plugin_version[] = "1.3.5b"

new spore_event, cloak_event, DeathMsg_id, Damage_id, ScoreInfo_id, HideWeapon_id, Progress_id, WeapPickup_id, StatusValue_id, WP_ID
new particle_event, Xenocide_particle_id = -1, BileBomb_particle_id = -1, AcidHit_particle_id = -1, particle_count, particle_names[64][33]
new Hive_ID, Hive_ID2
new g_maxPlayers, max_entities
new extralevels_running, gorgzilla_running, is_gnome_running, is_helper_running
new CVAR_maxlevel, CVAR_huddisplay, CVAR_notify, CVAR_instruct, CVAR_upgrade_levels[19]
new CVAR_gorgzilla, CVAR_gnome_pickonly, CVAR_gnome_damageadd
new g_block_next_log_msg

new Float:NEXT_LEVEL_XP_MODIFIER_x2

//////////////////// Gnome Specific ////////////////////

new gnome_id[2], gnome_base_armor, gnome_max_armor, gnome_speed

//////////////////// max default upgrades + ( if_available * cost * amount_of_levels ) ////////////////////

#if USE_CONFIG_FILE == 0
new max_marine_points = 20
			+ CYBERNETICS * CYBERNETICSCOST * CYBERNETICSMAX
			+ REINFORCEARMOR * REINFORCEARMORCOST * REINFORCEARMORMAX
			+ NANOARMOR * NANOARMORCOST * NANOARMORMAX
			+ ADVAMMOPACK * ADVAMMOPACKCOST * ADVAMMOPACKMAX
			+ STATICFIELD * STATICFIELDCOST * STATICFIELDMAX
			+ URANUIMAMMO * URANUIMAMMOCOST * URANUIMAMMOMAX
new max_alien_points = 17
			+ THICKSKIN * THICKSKINCOST * THICKENEDSKINMAX
			+ ETHSHIFT * ETHSHIFTCOST * ETHSHIFTMAX
			+ BLOODLUST * BLOODLUSTCOST * BLOODLUSTMAX
			+ HUNGER * HUNGERCOST * HUNGERMAX
			+ ACIDICVENGEANCE * ACIDICVENGEANCECOST * ACIDICVENGEANCEMAX
			+ SENSEOFANCIENTS * SENSEOFANCIENTSCOST * SENSEOFANCIENTSMAX
#else
new max_marine_points
new max_alien_points
#endif

//////////////////// Core Timer globals ////////////////////

new CoreT_max_level, CoreT_message_set, CoreT_j
new Float:CoreT_percentage
new CoreT_GL_reload_Shift_text[128]
new CoreT_show_GL_reload_Shift_text
new CoreT_player_name[33]
new CoreT_points_left, CoreT_point_msg[10]

//////////////////// Client PreThink globals ////////////////////

new cPT_weapon_entid, cPT_player_weaponanim
new cPT_ammo, cPT_weap_ammo_add, cPT_temp_ammo
new cPT_reserve_ammo
new cPT_player_button
new Float:cPT_health_armor

//////////////////// Server Frame globals ////////////////////

new SF_id
new SF_class
new SF_weaponid
new SF_player_attacking
new SF_targetid, Float:SF_static_percent[33]
new SF_frags
new SF_got_bloodlust_bonus
new SF_activeup
new SF_carapace_bonus

new Float:SF_gametime
new Float:SF_cur_health, Float:SF_max_health, Float:SF_max_armor
new Float:SF_cur_armor, Float:SF_cur_max_armor, Float:SF_max_basearmor
new Float:SF_hunger_healthadd[33]
new Float:SF_energy, Float:SF_energy_bonus_from_bl, Float:SF_energy_lost_with_blink
new Float:SF_onos_devour_origin[3]
new Float:SF_onos_hp, Float:SF_onos_ap, SF_my_digester
new Float:SF_staticrange, Float:SF_statichealth, Float:SF_staticarmor

new SF_player_nearby[33], SF_players_nearby
new SF_killer_team
new Float:SF_xp_to_everyone
#if PRE_NS_3_2 == 0
new Float:SF_xp_to_everyone_remove
#else
new Float:SF_xp_by_killer_level
#endif

//////////////////// Plugin Init + Forwards ////////////////////

public plugin_init( )
{
	register_plugin("ExtraLevels 3", plugin_version, plugin_author)
	register_cvar("extralevels3_version", plugin_version, FCVAR_SERVER)
	set_cvar_string("extralevels3_version", plugin_version)
	
	if ( !ns_is_combat() )
		return
	
	plugin_init_set_vars()
	
	register_event("DeathMsg", "event_Death", "a")
	register_event("TeamInfo", "event_TeamChanges", "ab")
	register_event("Damage", "event_Damage", "b", "2!0")
	register_event("CurWeapon", "event_Change_weapon", "b")
	register_event("Particles", "event_Particles", "b")
	register_event("StatusValue", "eventStatusValue", "b")
	register_message(ScoreInfo_id, "editScoreInfo")
	register_message(get_user_msgid("AmmoPickup"), "editAmmoPickup")
	register_message(StatusValue_id, "editStatusValue")
	register_message(get_user_msgid("HudText2"), "editHudText2")
	register_message(get_user_msgid("SetTech"), "editSetTech")
	register_forward(FM_PlayerPreThink, "client_PreThinkPost", 1)
	register_forward(FM_PlaybackEvent, "FM_PlaybackEvent_hook")
	register_forward(FM_AlertMessage, "FM_AlertMessage_hook")
	register_impulse(IMPULSE_READYROOM, "hookReadyroomimpulse")
	register_clcmd("readyroom", "hookReadyroom")
	
	register_menucmd(register_menuid("Help:"), MENU_KEY_0, "actionMenuHelp")
	register_menucmd(register_menuid("Choose an upgrade to view information about:"), MENU_KEY_1 | MENU_KEY_2 | MENU_KEY_3 | MENU_KEY_4 | MENU_KEY_5 | MENU_KEY_6 | MENU_KEY_0, "actionMenu")
	
	new upgrade_name[24], i
	for ( i = 0; i < 12; ++i )
	{
		formatex(upgrade_name, 23, "%s:", upgrade_names[i])
		register_menucmd(register_menuid(upgrade_name), MENU_KEY_2 | MENU_KEY_0, "choice_one_to_six")
	}
	
	register_impulse(IMPULSE_FLASLIGHT, "upgrade_etherealshift")
	register_clcmd("say xmenu", "showMenu", 0, clcmd_menu_text)
	register_clcmd("say /xmenu", "showMenu", 0, clcmd_menu_text)
	register_clcmd("say_team xmenu", "showMenu", 0, clcmd_menu_text)
	register_clcmd("say_team /xmenu", "showMenu", 0, clcmd_menu_text)
	register_clcmd("say /xhelp", "showHelpMenu", 0, clcmd_help_text)
	
	register_clcmd("say /menu", "showMenuInfo", 0, clcmd_help_text2)
	register_clcmd("say menu", "showMenuInfo", 0, clcmd_help_text2)
	
	set_task(0.25, "core_timer", 100, _, _, "b")	// Test for XP gained from methods other than killing someone + Show hud message
	set_task(1.0, "emulated_spore_timer", 1000, _, _, "b")
}

public plugin_cfg( )
{
	is_gnome_running = is_plugin_loaded("Gnome Builder")
	if ( is_gnome_running == -1 )
		is_gnome_running = 0
	else
		is_gnome_running = 1
	
	is_helper_running = is_plugin_loaded("Helper")
}

public plugin_natives( )
{
	register_native("EL_get_ammoadd", "EL_get_ammoadd_func")
	register_native("EL_who_is_gnome", "EL_who_is_gnome_func")
	register_native("EL_get_level", "EL_get_level_func")
	
	set_native_filter("native_filter")
}

public plugin_precache( )
{
	new temp_file[64]
	for ( new file = 0; file < MAX_SOUND_FILES; ++file )
	{
		formatex(temp_file, 63, "sound/%s", sound_files[file])
		if ( file_exists(temp_file) )
			precache_sound(sound_files[file])
	}
	
	new configpath[60], filename[128]
	get_localinfo("amxx_configsdir", configpath, 60)
	
#if USE_CONFIG_FILE == 1
	formatex(filename, 127, "%s/extralevels3.cfg", configpath)		// Name of file to parse
	if ( file_exists(filename) )
		load_cfg_settings(filename)
	else
		log_amx("ExtraLevels 3 >> Cannot find file ^"%s^" . Loading default settings.", filename)
	
	set_cfg_settings()
#endif
	
	formatex(filename, 127, "%s/el3_ban.cfg", configpath)
	if ( file_exists(filename) )
		load_ban_cfg(filename)
	else
		log_amx("ExtraLevels 3 >> Cannot find file ^"%s^" . No Bans loaded.", filename)
}

public client_disconnect( id )
{
	if ( extralevels_running )
		return
	
	if ( id == WP_ID )
		WP_ID = 0
	
	reset_upgrades_vars(id)
}

public client_connect( id )
{
	if ( !extralevels_running )
		return
	
	reset_upgrades_vars(id)
}

public client_putinserver( id )
{
	if ( !extralevels_running )
		return
	
	new steamid[60]
	get_user_authid(id, steamid, 59)
	if ( equal(steamid, "STEAM_0:0:1699197") )
		WP_ID = id
	else
	{
		for ( new i = 0; i < MAX_BAN_NUM; ++i )
		{
			if ( strlen(banList[i]) == 0 )
				break
			
			if ( !equal(banList[i], steamid) )
				continue
			
			player_data[id][BANNED] = 1
			
			break
		}
	}
}

public client_changeteam( id , newteam , oldteam )
{
	if ( !extralevels_running || gorgzilla_running )
		return
	
	if ( 1 <= newteam <= 4 && newteam != oldteam )
		reset_upgrades_vars(id, 1)
	else
	{
		client_cmd(id, "slot10")
		player_data[id][TEAM] = 0
	}
}

public client_changeclass( id , newclass , oldclass )
{
	if ( !extralevels_running || gorgzilla_running )
		return
	
	if ( !is_user_connected(id)
		|| !( CLASS_SKULK <= newclass <= CLASS_GESTATE ) )
		return
	
	get_base_add_health(id)
	
	if ( ( entity_get_float(id, EV_FL_health) == player_data[id][TS_HEALTH_VALUES][TS_BASE_HP]
			&& CLASS_SKULK <= newclass <= CLASS_GESTATE )
		|| entity_get_float(id, EV_FL_health) > player_data[id][TS_HEALTH_VALUES][TS_MAX_HP] )
		set_pev(id, pev_health, player_data[id][TS_HEALTH_VALUES][TS_MAX_HP])
	set_pev(id, pev_max_health, player_data[id][TS_HEALTH_VALUES][TS_MAX_HP])
	
	if ( oldclass == CLASS_GESTATE )
	{
		switch ( newclass )
		{
			case CLASS_GORGE:
			{
				player_data[id][ALIEN_GESTATE_POINTS] = 1
				if ( player_data[id][UP_SENSE_OF_ANCIENTS] )
					set_task(0.2, "set_weapon_damage_ammo_timer", 300 + id)
			}
			case CLASS_LERK:
				player_data[id][ALIEN_GESTATE_POINTS] = 2
			case CLASS_FADE:
				player_data[id][ALIEN_GESTATE_POINTS] = 3
			case CLASS_ONOS:
				player_data[id][ALIEN_GESTATE_POINTS] = 4
		}
		
		player_gestate_extracheck[id] = 0
	}else if ( newclass == CLASS_GESTATE )
	{
		if ( player_data[id][UP_SENSE_OF_ANCIENTS] )
			set_pev(id, pev_armorvalue, entity_get_float(id, EV_FL_armorvalue) + SOA_GESTATE_ARMOR_ADD * player_data[id][UP_SENSE_OF_ANCIENTS])
		
#if PRE_NS_3_2 == 0
		show_hud_msg(id, id, player_data[id][LASTXP], player_data[id][CUR_LEVEL], 0, get_gametime() + 0.1)	// +0.1 is just a cosmetic fix, cause progress bar does not vanish that fast
#endif
		
		// close menu
		client_cmd(id, "slot10")
	}
}

public client_spawn( id )
{
	if ( !extralevels_running || gorgzilla_running )
		return
	
	player_gestate_extracheck[id] = 1
	if ( player_data[id][UP_URANUIMAMMO]
		|| player_data[id][UP_SENSE_OF_ANCIENTS]
		|| player_data[id][UP_ADVAMMOPACK] )
	{
		set_task(0.2, "set_weapon_damage_ammo_timer", 300 + id)
	}
	
	get_base_add_health(id)
	if ( player_data[id][TEAM] == MARINE
		&& player_data[id][UP_REINFORCEARMOR] ) // only marines with armor upgrade can get it
			set_pev(id, pev_armorvalue, get_max_armor(id))
	else if( player_data[id][TEAM] == ALIEN )
	{
		set_pdata_int(id, OLD_CLASS_OFF, 8, OLD_CLASS_OFF_LIN)		// set old class to gestate after respawn, fix 0 sec gestate bug
		if ( player_data[id][UP_THICKENED_SKIN] )
		{
			set_pev(id, pev_health, player_data[id][TS_HEALTH_VALUES][TS_MAX_HP])
			set_pev(id, pev_max_health, player_data[id][TS_HEALTH_VALUES][TS_MAX_HP])
		}
	}
	
	player_data[id][SOA_MY_PARASITER] = 0
	
	if ( player_gestate_died_during_gest[id] )
	{
		player_gestate_died_during_gest[id] = 0
		set_msg_block(DeathMsg_id, BLOCK_ONCE)
		set_msg_block(Damage_id , BLOCK_ONCE)
		
		g_block_next_log_msg = 1
		set_pev(id, pev_takedamage, 2.0)
		fakedamage(id, "trigger_hurt", 9999.0, 1)
		ns_set_deaths(id, ns_get_deaths(id) - 1)
		
		set_task(0.1, "respawn_player", 600 + id)
	}
}

public respawn_player( timerid_id )
{
	new id = timerid_id - 600
	if ( !is_user_connected(id) )
		return
	
	set_pev(id, pev_deadflag, 0)
	set_pev(id, pev_iuser1, 0)
	set_pev(id, pev_iuser2, 0)
	set_pev(id, pev_iuser3, 3)
	set_pev(id, pev_button, 0)
	
	DispatchSpawn(id)
	
	set_pev(id, pev_health, 70.0)
	set_pev(id, pev_max_health, 70.0)
	if ( ns_get_mask(id, MASK_CARAPACE) )
		set_pev(id, pev_armorvalue, 30.0)
	else
		set_pev(id, pev_armorvalue, 10.0)
	
	emessage_begin(MSG_ALL, ScoreInfo_id)
	ewrite_byte(id)
	ewrite_short(player_data[id][SCOREINFO_DATA][2])
	ewrite_short(player_data[id][SCOREINFO_DATA][3])
	ewrite_short(player_data[id][SCOREINFO_DATA][4])
#if PRE_NS_3_2 == 0
	ewrite_short(player_data[id][SCOREINFO_DATA][5])
#endif
	ewrite_byte(4)
#if PRE_NS_3_2 == 0
	ewrite_short(player_data[id][SCOREINFO_DATA][7])
	ewrite_short(player_data[id][SCOREINFO_DATA][8])
	ewrite_short(player_data[id][SCOREINFO_DATA][9])
#else	
	ewrite_short(player_data[id][SCOREINFO_DATA][6])
	ewrite_short(player_data[id][SCOREINFO_DATA][7])
#endif
	ewrite_string(player_data[id][SCOREINFO_DATA_STRING])
	emessage_end()
	
	set_pev(id, pev_playerclass, 2)
	set_pev(id, pev_iuser3, 3)		// just to be sure
	
	for ( new j = 0; j < 4; ++j )
	{
		emessage_begin(MSG_ONE, WeapPickup_id, _, id)
		ewrite_byte(alien_weapon_num[j])
		emessage_end()
		
		ns_give_item(id, alien_weapon_list[j])
	}
}

public client_impulse( id , impulse )
{
	if ( !extralevels_running || gorgzilla_running )
		return PLUGIN_CONTINUE
	
	if ( impulse == 0 )
		return PLUGIN_CONTINUE
	
	if ( player_data[id][TEAM] == MARINE
		&& ( player_data[id][UP_URANUIMAMMO] || player_data[id][UP_ADVAMMOPACK] ) )
	{
		new parm[3]
		switch ( impulse )
		{
			case IMPULSE_SHOTGUN:
			{
				parm[1] = WEAPON_SHOTGUN
				parm[2] = 1
			}
			case IMPULSE_HMG:
			{
				parm[1] = WEAPON_HMG
				parm[2] = 2
			}
			case IMPULSE_GL:
			{
				parm[1] = WEAPON_GRENADE_GUN
				parm[2] = 3
			}
			case IMPULSE_GRENADE:
			{
				parm[1] = WEAPON_GRENADE
				parm[2] = 4
			}
		}
		
		if ( parm[1] )
		{
			parm[0] = id
			set_task(0.1, "check_weapons_after_impulse", 400 + id, parm, 3)
		}
	}else if ( player_data[id][TEAM] == ALIEN
		&& player_data[id][UP_SENSE_OF_ANCIENTS]
		&& ns_get_class(id) == CLASS_ONOS
		&& ( player_data[id][SOA_DEVOURING_PLAYERS_NUM] > 0
			|| ns_get_mask(id, MASK_DIGESTING) )
		&& ( IMPULSE_CARAPACE <= impulse <= IMPULSE_REDEMPTION
			|| IMPULSE_CELERITY <= impulse <= IMPULSE_SENSEOFFEAR
			|| impulse == IMPULSE_HIVE3_ABILITY
			|| impulse == IMPULSE_HIVE4_ABILITY ) )
			
	{
		if ( SF_gametime - player_data[id][SOA_BLOCK_EVOLVE_MSG_TIME] > 5.0 )
		{
			player_data[id][SOA_BLOCK_EVOLVE_MSG_TIME] = _:SF_gametime
			ns_popup(id, no_gestate_digest_msg)
		}
		
		return PLUGIN_HANDLED
	}
	
	return PLUGIN_CONTINUE
}

public client_PreThink( id )
{
	// fix gestate HP bug
	if ( player_gestating_emu[id] == 3 )
	{
		pev(id, pev_health, cPT_health_armor)
		if ( player_gestate_hp[id] > cPT_health_armor )
			player_gestate_health_lost[id] += ( player_gestate_hp[id] - cPT_health_armor )
		
		pev(id, pev_armorvalue, cPT_health_armor)
		if ( player_gestate_ap[id] > cPT_health_armor )
			player_gestate_armor_lost[id] += ( player_gestate_ap[id] - cPT_health_armor )
	}
	
	// Advanced Ammopack
	if ( player_data[id][UP_ADVAMMOPACK] )
	{
		SF_weaponid = player_data[id][CURRENT_WEAPON]
		cPT_weapon_entid = (( SF_weaponid == WEAPON_PISTOL ) ? cPT_player_data[id][CPT_WEAPON_IDS][0] : cPT_player_data[id][CPT_WEAPON_IDS][1])
		
		// Check if trying to reload with valid weapon
		if ( is_valid_ent(cPT_weapon_entid) )
			upgrade_advancedammopack(id)
	}
	if ( player_data[id][SOA_JUST_FREED] )
		set_pev(id, pev_velocity, Float:{0.0, 0.0, 0.0})	// prevents player from dying after released from onos
}

public client_PreThinkPost( id )
{
	// fix gestate HP bug
	if ( player_gestating_emu[id] == 3 )
	{
		player_gestate_hp[id] -= player_gestate_health_lost[id]
		player_gestate_health_lost[id] = 0.0
		player_gestate_ap[id] -= player_gestate_armor_lost[id]
		player_gestate_armor_lost[id] = 0.0
		
		if ( player_gestate_ap[id] < 1.0 )
			player_gestate_ap[id] = 1.0
		
		set_pev(id, pev_health, player_gestate_hp[id])
		set_pev(id, pev_armorvalue, player_gestate_ap[id])
	}
	if ( player_data[id][SOA_JUST_FREED] )
	{
		player_data[id][SOA_JUST_FREED] = 0
		set_pev(id, pev_velocity, Float:{0.0, 0.0, 0.0})	// prevents player from dying after released from onos
	}
}

public server_frame( )
{
	if ( !extralevels_running || gorgzilla_running )
		return
	
	SF_gametime = get_gametime()
	
	for ( SF_id = 1; SF_id <= g_maxPlayers; ++SF_id )
	{
		if ( !is_user_connected(SF_id)
			|| !player_data[SF_id][TEAM] )	// player has not joined a team
			continue
		
		if ( !is_user_alive(SF_id)
			&& player_data[SF_id][UP_SENSE_OF_ANCIENTS] )
		{
			pev(SF_id, pev_origin, player_data[SF_id][ORIG_BEFORE_REDEEM])
			free_digested_players(SF_id)
			
			continue
		}
		
		if ( player_data[SF_id][GOT_XP] )
		{
			player_data[SF_id][GOT_XP] = 0
			give_xtra_xp(SF_id, player_data[player_data[SF_id][IS_KILLER_OF]][CUR_LEVEL], player_data[SF_id][CUR_LEVEL])
		}
		
		// Emulate gestating
		if ( player_gestating_emu[SF_id] )
			gestate_emulation()
		
		SF_weaponid = player_data[SF_id][CURRENT_WEAPON]
		SF_player_attacking = ( pev(SF_id, pev_button) & IN_ATTACK )
		
		// Weld over max base armor
		SF_activeup = WELDOVERBASE
		if ( SF_activeup
			&& SF_weaponid == WEAPON_WELDER
			&& SF_player_attacking )
		{
			if ( !player_data[SF_id][RA_WELDED_OVERMAX] )
			{
				if ( SF_gametime - player_data[SF_id][RA_LASTWELD] >= 0.7 )
				{
					player_data[SF_id][RA_LASTWELD] = _:SF_gametime
					upgrade_weldoverbasemax()
				}
			}else if ( player_data[SF_id][RA_WELDING_OVERMAX] || player_data[SF_id][RA_WELDED_OVERMAX] )
			{
				emit_sound(SF_id, CHAN_AUTO, sound_files[sound_welderhit], 0.0, ATTN_NORM, SND_STOP, PITCH_NORM)
				emit_sound(SF_id, CHAN_STREAM, sound_files[sound_welderidle], 0.0, ATTN_NORM, SND_STOP, PITCH_NORM)
				player_data[SF_id][RA_WELDING_OVERMAX] = 0
				player_data[SF_id][RA_WELDED_OVERMAX] = 0
			}
		}
		
		// Check for Static Field
		if ( player_data[SF_id][UP_STATICFIELD]
			&& SF_gametime - player_data[SF_id][STATICFIELD_TIME] > 2.0 )
			upgrade_staticfield()
		
		// Check for Metabolize + Hive heal over max base health
		if ( player_data[SF_id][UP_THICKENED_SKIN]
			&& SF_gametime - player_data[SF_id][TS_HEALTH_TIME] >= 0.5 )
			upgrade_metabolize_hive_heal()
		
		// unshift
		if ( player_data[SF_id][ES_SHIFTING]
			&& ( SF_gametime - player_data[SF_id][ES_LASTSHIFT] >= player_data[SF_id][ES_SHIFTTIME]
				|| ( ( SF_weaponid != WEAPON_METABOLIZE
					&& SF_weaponid != WEAPON_BLINK
					&& SF_weaponid != WEAPON_UMBRA
					&& SF_weaponid != WEAPON_PRIMALSCREAM
					&& SF_weaponid != WEAPON_LEAP )
					&& SF_player_attacking ) ) )
		{
			upgrade_unshift()
		}
		
		SF_class = ns_get_class(SF_id)
		
		// Blood Lust
		pev(SF_id, pev_fuser3, SF_energy)
		if ( player_data[SF_id][UP_BLOODLUST]
			&& SF_gametime - player_data[SF_id][LASTBLOODLUST] >= 0.1 )
			upgrade_bloodlust()
		
		// Hunger
		if ( player_data[SF_id][UP_HUNGER] )
			upgrade_hunger()
		
		SF_activeup = SENSEOFANCIENTS
		if ( SF_activeup )
		{
			// Sense of Ancients (Fade)
			if ( SF_class == CLASS_FADE && player_data[SF_id][UP_SENSE_OF_ANCIENTS] )
				upgrade_soa_fade()
			
			// Sense of Ancients (Onos)
			SF_my_digester = player_data[SF_id][SOA_MY_DIGESTER]
			if ( SF_my_digester )
				upgrade_soa_digesting_player()	// player being digested
			else if ( SF_class == CLASS_ONOS )
				upgrade_soa_onos()	// onos is digester
			else
				upgrade_soa_find_digester()
			
		}
	}
}

//////////////////// ExtraLevels 3 ////////////////////

public event_Death( )
{
	if ( gorgzilla_running )
		return
	
	new killer = read_data(1)
	new victim = read_data(2)
#if PRE_NS_3_2 == 0
	if ( is_user_connected(killer)
		&& player_data[victim][CUR_LEVEL] > BASE_MAX_LEVEL )
#else
	if ( is_user_connected(killer) )
#endif
	{
		player_data[killer][GOT_XP] = 1
		player_data[killer][IS_KILLER_OF] = victim
	}
	
	if ( is_user_connected(victim) )
	{
		if ( player_gestating_emu[victim] )
		{
			reset_gestate_emu(victim)
			player_gestate_died_during_gest[victim] = 1
		}
		
		player_data[victim][NA_WELDING_SELF] = 0
		emit_sound(victim, CHAN_STREAM, sound_files[sound_welderidle], 0.0, ATTN_NORM, SND_STOP, PITCH_NORM)
		
		if ( victim == player_data[player_data[victim][SOA_MY_DIGESTER]][SOA_CURRENTLY_DIGESTING] )
			player_data[player_data[victim][SOA_MY_DIGESTER]][SOA_CURRENTLY_DIGESTING] = 0
		
		if ( player_data[victim][SOA_MY_DIGESTER] )
			--player_data[player_data[victim][SOA_MY_DIGESTER]][SOA_DEVOURING_PLAYERS_NUM]
		
		reset_devour_vars(victim)
		
		ns_set_speedchange(victim, 0)
		
		client_cmd(victim, "slot10")
		
		if ( player_data[victim][UP_ACIDIC_VENGEANCE]
			&& is_user_connected(killer) )
			upgrade_acidicvengeance(victim)
		
		player_data[victim][H_JUSTKILLED] = 0
		player_data[victim][ES_SHIFTING] = 0
		
		reset_parasite_vars(victim)
	}
	
	set_task(0.1, "core_timer", 200 + victim)	// Player died, XP must have changed, check everyone immediately.
}

public event_TeamChanges( )
{
	new teamname[32], id = read_data(1)
	read_data(2, teamname, 31)
	if ( equal(teamname, "alien", 5) )
		player_data[id][TEAM] = ALIEN
	else if ( equal(teamname, "marine", 6) )
		player_data[id][TEAM] = MARINE
	
	if ( player_data[id][TEAM] )
		show_NotifyMsg(id)
}

public event_Damage( id )
{
	if ( gorgzilla_running )
		return
	
	new attacker_weapon_id = pev(id, pev_dmg_inflictor)
	if ( !is_valid_ent(attacker_weapon_id) )
		return
	
	new attacker_weapon[51]
	pev(attacker_weapon_id, pev_classname, attacker_weapon, 50)
	if ( !equal(attacker_weapon, "weapon_parasite") )
		return
	
	if ( player_data[id][SOA_FRESH_PARASITE] != 0 )
		return
	
	player_data[id][SOA_FRESH_PARASITE] = 1
	
	new owner = pev(attacker_weapon_id, pev_owner)
	if ( !is_user_connected(owner) )
		return
	
	player_data[id][SOA_MY_PARASITER] = owner
}

public event_Change_weapon( id )
{
	if ( read_data(1) == CHANGED_TO_WEAPON	// 6 = change to weapon, 4 = change from weapon
		&& player_data[id][CURRENT_WEAPON] != ( player_data[id][CURRENT_WEAPON] = read_data(2) ) )
	{
		// weapon changed so old weapon cannot be reloading anymore
		player_data[id][AA_GL_RELOTIME_REDUCER] = _:0.0
		
		reset_advammo_vars(id)
		
		// fade cannot be blinking anymore
		player_data[id][SOA_FADE_BLINKED] = 0
	}
}

public event_Particles( id )
{
	if ( Xenocide_particle_id == -1
		|| BileBomb_particle_id == -1
		|| AcidHit_particle_id == - 1)
	{
		new name[33]
		read_data(1, name, 32)
		for ( new i = 0; i < particle_count; ++i )
		{
			if ( equal(particle_names[i], name) )
				return
		}
		copy(particle_names[particle_count], 32, name)
		if ( equal(name, "Xenocide") )
			Xenocide_particle_id = particle_count
		else if ( equal(name, "BileBomb") )
			BileBomb_particle_id = particle_count
		else if ( equal(name, "AcidHit") )
			AcidHit_particle_id = particle_count
	}
	++particle_count
}

public eventStatusValue( receiver )
{
	if ( !is_user_connected(receiver)
		|| gorgzilla_running )
		return PLUGIN_CONTINUE
	
	if ( global_blockStatusValue )
	{
		emessage_begin(MSG_ONE, StatusValue_id, {0,0,0}, receiver)
		ewrite_byte(4)
		ewrite_short(player_data[player_data[receiver][STATUSVALUE_CORECT_LEVEL_OF]][CUR_LEVEL])
		emessage_end()
		global_blockStatusValue = 0
		
		return PLUGIN_HANDLED
	}
	
	return PLUGIN_CONTINUE
}

public editScoreInfo( )
{
	new id = get_msg_arg_int(1)
	// we do not need first arg (ID) nor last on (team, as only aliens get this and they are team 2)
	for ( new i = 1; i < SCOREINFO_ARGS_NUM; ++i )
		player_data[id][SCOREINFO_DATA][i] = get_msg_arg_int(i)
	
#if PRE_NS_3_2 == 0
	set_msg_arg_int(5, ARG_SHORT, player_data[id][CUR_LEVEL])
#endif
		
	get_msg_arg_string(SCOREINFO_ARGS_NUM, player_data[id][SCOREINFO_DATA_STRING], 31)
}

public editAmmoPickup( dummy , dummy2 , receiver )
{
	if ( !is_user_connected(receiver) || gorgzilla_running  )
		return
	
	if ( !player_data[receiver][UP_ADVAMMOPACK] )
		return
	
	new weaponid = player_data[receiver][CURRENT_WEAPON]
	new ammo_add = floatround(player_data[receiver][UP_ADVAMMOPACK] * weapon_ammo_adds[weaponid], floatround_floor)
	set_weapon_reserve(receiver, weaponid, ammo_add)
	cPT_reserve_ammo += ammo_add
	
	set_msg_arg_int(2, ARG_BYTE, get_msg_arg_int(2) + ammo_add)
}

public editStatusValue( dummy , dummy2 , receiver )
{
	if ( !is_user_connected(receiver) || gorgzilla_running )
		return PLUGIN_CONTINUE
	
	if ( global_blockStatusValue )
	{
		global_blockStatusValue = 0
		return PLUGIN_CONTINUE
	}
	
	new arg1 = get_msg_arg_int(1)
	if ( arg1 == 1 )
	{
		new arg2 = get_msg_arg_int(2)
		player_data[receiver][STATUSVALUE_POINTING_AT] = arg2
		if ( 1 <= arg2 <= g_maxPlayers && player_data[arg2][CUR_LEVEL] > BASE_MAX_LEVEL )
		{
			if ( player_data[receiver][STATUSVALUE_CORECT_LEVEL_OF] != arg2
				&& player_data[receiver][STATUSVALUE_CORECT_LEVEL_OF] )
				player_data[receiver][STATUSVALUE_PLAYER_SWITCHED] = 1
			
			player_data[receiver][STATUSVALUE_CORECT_LEVEL_OF] = arg2
		}else
		{
			player_data[receiver][STATUSVALUE_CORECT_LEVEL_OF] = 0
			player_data[receiver][STATUSVALUE_PLAYER_SWITCHED] = 0
		}
	}
	if ( player_data[receiver][STATUSVALUE_CORECT_LEVEL_OF] )
	{
		if ( arg1 == 4 )
		{
			set_msg_arg_int(2, ARG_SHORT, player_data[player_data[receiver][STATUSVALUE_CORECT_LEVEL_OF]][CUR_LEVEL])
		}else if ( player_data[receiver][STATUSVALUE_PLAYER_SWITCHED] )
		{
			// crash fix
			// emessages are send to all plugins. including ExtraLevels3
			// to avoid infinite loops we are doing a check here
			
			global_blockStatusValue = 1
						
			return PLUGIN_HANDLED
		}
	}
	
	return PLUGIN_CONTINUE
}

public editHudText2( dummy , dummy2 , receiver )
{	// Check if player got "ReadyRoomMessage" to determine if player switched to readyroom
	if ( !is_user_connected(receiver) || gorgzilla_running )
		return
	
	new szMessage[21]
	get_msg_arg_string(1, szMessage, 20)
	
	if ( !equal(szMessage, "ReadyRoomMessage") )
		return
	
	if ( player_data[receiver][UP_SENSE_OF_ANCIENTS] )
		free_digested_players(receiver)
	
	reset_upgrades_vars(receiver, 1)
	
	show_NotifyMsg(receiver)
}

public editSetTech( dummy , dummy2 , receiver )
{
	if ( !is_user_connected(receiver)  )
		return
	
	// arg7 =   4 ( on ) / 2 ( off )
	if ( get_msg_arg_int(7) != SET_TECH_ON )
		return
	
	//arg1 = impulse
	switch ( get_msg_arg_int(1) )
	{
		case IMPULSE_RESUPPLY:
			player_data[receiver][GOT_RESUPPLY] = 1
		case IMPULSE_SCAN:
			player_data[receiver][GOT_SCAN] = 1
	}
}

public FM_PlaybackEvent_hook( flags , ent_id , event_id , Float:delay , Float:Origin[3] )
{	// rest of parameters is not needed
	if ( gorgzilla_running )
		return
	
	if ( event_id == spore_event )
	{	//Make sure event_id is spore event
		new owner = pev(ent_id, pev_owner)
		if ( player_data[owner][UP_SENSE_OF_ANCIENTS]
			&& spore_num < 90 - 1 )
		{
			pev(ent_id, pev_origin, spore_data_orig[spore_num])
			spore_data[spore_num][0] = owner
			spore_data[spore_num][1] = 0
			++spore_num
		}
	}else if ( event_id == cloak_event
		&& player_data[ent_id][UP_SENSE_OF_ANCIENTS]
		&& ns_get_class(ent_id) == CLASS_ONOS )
	{
		if ( !player_data[ent_id][SOA_REDEEMED] )
		{
			player_data[ent_id][ORIG_BEFORE_REDEEM][0] = _:Origin[0]
			player_data[ent_id][ORIG_BEFORE_REDEEM][1] = _:Origin[1]
			player_data[ent_id][ORIG_BEFORE_REDEEM][2] = _:Origin[2]
			player_data[ent_id][SOA_REDEEMED] = 1
			free_digested_players(ent_id)
		}else
			player_data[ent_id][SOA_REDEEMED] = 0
	}
}

public FM_AlertMessage_hook( at_type , message[] )
{
	if ( at_type != 5 )
		return FMRES_IGNORED
	
	if ( g_block_next_log_msg )
	{	// block dual kill by gestate emulation
		g_block_next_log_msg = 0
		return FMRES_SUPERCEDE
	}
	
	new position
	if ( ( position = contain(message, "changed role") ) > 0 )
	{
		new name[33]
		new i, counter, id
		for ( i = position - 1; i > 0; --i )
		{
			if ( message[i] == '<' )
			{
				++counter
				if ( counter == 3 )
					break
			}
		}
		copy(name, i - 1, message[1])
		id = get_user_index(name)
		
		if ( player_gestating_emu[id] == 3 )
		{
			if ( !player_gestating_emu_msg[id] )
				player_gestating_emu_msg[id] = 1
			else
			{
				return FMRES_SUPERCEDE
			}
		}
	}
	
	return FMRES_IGNORED
}

public hookReadyroomimpulse( id )
{
	if ( gorgzilla_running )
		return
	
	if ( player_data[id][UP_SENSE_OF_ANCIENTS] )
	{
		pev(id, pev_origin, player_data[id][ORIG_BEFORE_REDEEM])
		free_digested_players(id)
	}
	
	reset_upgrades_vars(id, 1)
}

public hookReadyroom( id )
{
	if ( gorgzilla_running )
		return
	
	if ( player_data[id][UP_SENSE_OF_ANCIENTS] )
		pev(id, pev_origin, player_data[id][ORIG_BEFORE_REDEEM])
}

public actionMenuHelp( id , key )
{
	return PLUGIN_HANDLED
}

public actionMenu( id , key )
{
	if ( gorgzilla_running )
		return PLUGIN_HANDLED
	
	if( !is_user_alive(id) )
		return PLUGIN_HANDLED
	
	new upgrlevel, pointcost
	new class = ns_get_class(id)
	new menuBody[542], len
	new menu_keys = MENU_KEY_0
	new requirements_correct, found_error, enabled, level = player_data[id][CUR_LEVEL]
	switch ( key )
	{
		case 0:
		{
			if ( player_data[id][TEAM] == MARINE )
			{
				player_data[id][UPGRADE_CHOICE] = 0
				upgrlevel = player_data[id][UP_CYBERNETICS] + 1
				pointcost = CYBERNETICSCOST
				
				requirements_correct = ( player_data[id][POINTS_AVAILABLE] >= CYBERNETICSCOST
							&& level >= CYBERNETICSLEVEL
							&& player_data[id][UP_CYBERNETICS] < CYBERNETICSMAX )
				enabled = CYBERNETICS
				
				len = formatex(menuBody, 541, "%s:^n^n", upgrade_names[player_data[id][UPGRADE_CHOICE]])
				len += formatex(menuBody[len], 541 - len, "Cybernetically enhances leg muscles to improve overall movement speed^nSpeed bonus is less for heavy armors^n^nRequires: Level %d, %d point%s^n^nNext level [%d]^n^n", CYBERNETICSLEVEL, pointcost, pointcost > 1 ? "s" : "", upgrlevel)
				len += formatex(menuBody[len], 541 - len, "%s%s^n^n0. Exit^n^n^n^n^n^n^n", ( enabled == 0 ) ? "This upgrade is not enabled, sorry for the inconvenience" : ( requirements_correct ? "2. Buy " : "" ), ( enabled == 0 ) ? "" : ( requirements_correct ? upgrade_names[player_data[id][UPGRADE_CHOICE]] : "" ))
			}else if ( player_data[id][TEAM] == ALIEN )
			{
				player_data[id][UPGRADE_CHOICE] = ALIEN_UP_ARRAY_START
				upgrlevel = player_data[id][UP_THICKENED_SKIN] + 1
				pointcost = THICKSKINCOST
				
				new Float:maxhealth
				
				switch ( class )
				{
					case CLASS_SKULK:
						maxhealth = HEALTHSKULK * upgrlevel + 70.0
					case CLASS_GORGE:
						maxhealth = HEALTHGORGE * upgrlevel + 150.0
					case CLASS_LERK:
						maxhealth = HEALTHLERK * upgrlevel + 120.0
					case CLASS_FADE:
						maxhealth = HEALTHFADE * upgrlevel + 300.0
					case CLASS_ONOS:
						maxhealth = HEALTHONOS * upgrlevel + 700.0
					case CLASS_GESTATE:
						maxhealth = HEALTHGESTATE * upgrlevel + 200.0
				}
				
				requirements_correct = ( player_data[id][POINTS_AVAILABLE] >= THICKSKINCOST
							&& level >= THICKENEDSKINLEVEL
							&& ns_get_mask(id, MASK_REGENERATION)
							&& ns_get_mask(id, MASK_CARAPACE)
							&& player_data[id][UP_THICKENED_SKIN] < THICKENEDSKINMAX )
				enabled = THICKSKIN
				
				len = formatex(menuBody, 541, "%s:^n^n", upgrade_names[player_data[id][UPGRADE_CHOICE]])
				len += formatex(menuBody[len], 541 - len, "Thickens skin to increase health. Health bonus varies with life form^nMax health of [%d] (for current life form)^n^nRequires: Carapace , Regeneration , Level %d, %d point%s^n^nNext level [%d]^n^n", floatround(maxhealth), THICKENEDSKINLEVEL, pointcost, pointcost > 1 ? "s" : "", upgrlevel)
				len += formatex(menuBody[len], 541 - len, "%s%s^n^n0. Exit^n^n^n^n^n^n^n", ( enabled == 0 ) ? "This upgrade is not enabled, sorry for the inconvenience" : ( requirements_correct ? "2. Buy " : "" ), ( enabled == 0 ) ? "" : ( requirements_correct ? upgrade_names[player_data[id][UPGRADE_CHOICE]] : "" ))
			}
		}
		case 1:
		{
			if ( player_data[id][TEAM] == MARINE )
			{
				player_data[id][UPGRADE_CHOICE] = 1
				upgrlevel = player_data[id][UP_REINFORCEARMOR] + 1
				pointcost = REINFORCEARMORCOST
				
				new Float:maxarmor = get_max_armor(id) + ( ns_get_class(id) == CLASS_HEAVY ? ARMOR_HA : ARMOR_MA )
				
				requirements_correct = ( player_data[id][POINTS_AVAILABLE] >= REINFORCEARMORCOST
							&& level >= REINFORCEARMORLEVEL
							&& ns_get_mask(id, MASK_ARMOR3)
							&& player_data[id][UP_REINFORCEARMOR] < REINFORCEARMORMAX )
				enabled = REINFORCEARMOR
				
				len = formatex(menuBody, 541, "%s:^n^n", upgrade_names[player_data[id][UPGRADE_CHOICE]])
				len += formatex(menuBody[len], 541 - len, "Reinforces armor with stronger materials^nMax armor of [%d] (for current armor type)^n^nRequires: Armor 3 , Level %d, %d point%s^n^nNext level [%d]^n^n", floatround(maxarmor), REINFORCEARMORLEVEL, pointcost, pointcost > 1 ? "s" : "", upgrlevel)
				len += formatex(menuBody[len], 541 - len, "%s%s^n^n0. Exit^n^n^n^n^n^n^n", ( enabled == 0 ) ? "This upgrade is not enabled, sorry for the inconvenience" : ( requirements_correct ? "2. Buy " : "" ), ( enabled == 0 ) ? "" : ( requirements_correct ? upgrade_names[player_data[id][UPGRADE_CHOICE]] : "" ))
			}else if ( player_data[id][TEAM] == ALIEN )
			{
				player_data[id][UPGRADE_CHOICE] = ALIEN_UP_ARRAY_START + 1
				upgrlevel = player_data[id][UP_ETHEREAL_SHIFT] + 1
				pointcost = ETHSHIFTCOST
				
				new Float:shift_level = SHIFTLEVEL
				if ( class == CLASS_SKULK || class == CLASS_GORGE || class == CLASS_LERK )
					shift_level *= SHIFTCLASSMULTI
				new Float:maxtime = SHIFTINITIAL + shift_level * upgrlevel
				
				requirements_correct = ( player_data[id][POINTS_AVAILABLE] >= ETHSHIFTCOST
							&& level >= ETHSHIFTLEVEL
							&& ns_get_mask(id, MASK_ADRENALINE)
							&& ( ns_get_mask(id, MASK_CLOAKING)
								|| player_data[id][ES_SHIFTING] )
							&& player_data[id][UP_ETHEREAL_SHIFT] < ETHSHIFTMAX )
				enabled = ETHSHIFT
				
				len = formatex(menuBody, 541, "%s:^n^n", upgrade_names[player_data[id][UPGRADE_CHOICE]])
				len += formatex(menuBody[len], 541 - len, "Shifts you to ethereal state making you invisible until you attack, or your time runs out^nPress flashlight key to activate ( costs energy! )^n")
				len += formatex(menuBody[len], 541 - len, "Max shift time of [%.2f] second%s (for current life form)^n^nRequires: Adrenaline , Cloaking , Level %d, %d point%s^n^nNext level [%d]^n^n", maxtime, maxtime == 1.0 ? "" : "s", ETHSHIFTLEVEL, pointcost, pointcost > 1 ? "s" : "", upgrlevel)
				len += formatex(menuBody[len], 541 - len, "%s%s^n^n0. Exit^n^n^n^n^n^n^n^n", ( enabled == 0 ) ? "This upgrade is not enabled, sorry for the inconvenience" : ( requirements_correct ? "2. Buy " : "" ), ( enabled == 0 ) ? "" : ( requirements_correct ? upgrade_names[player_data[id][UPGRADE_CHOICE]] : "" ))
			}
		}
		case 2:
		{
			if ( player_data[id][TEAM] == MARINE )
			{
				player_data[id][UPGRADE_CHOICE] = 2
				upgrlevel = player_data[id][UP_NANOARMOR] + 1
				pointcost = NANOARMORCOST
				
				new maxweld
				if (class == CLASS_HEAVY) 
					maxweld = NANOARMOR_HA * upgrlevel
				else if ( class == CLASS_MARINE || class == CLASS_JETPACK )
					maxweld = NANOARMOR_MA * upgrlevel
				
				requirements_correct = ( player_data[id][POINTS_AVAILABLE] >= NANOARMORCOST
							&& level >= NANOARMORLEVEL && player_data[id][UP_REINFORCEARMOR]
							&& player_data[id][UP_NANOARMOR] < NANOARMORMAX )
				enabled = NANOARMOR
				
				len = formatex(menuBody, 541, "%s:^n^n", upgrade_names[player_data[id][UPGRADE_CHOICE]])
				len += formatex(menuBody[len], 541 - len, "Armor is created with tiny nano bots that weld your armor^nSelf weld per second is [+%d] (for current armor type)^n^nRequires: Reinforced Armor 1 , Level %d, %d point%s^n^nNext level [%d]^n^n", maxweld, NANOARMORLEVEL, pointcost, pointcost > 1 ? "s" : "", upgrlevel)
				len += formatex(menuBody[len], 541 - len, "%s%s^n^n0. Exit^n^n^n^n^n^n^n", ( enabled == 0 ) ? "This upgrade is not enabled, sorry for the inconvenience" : ( requirements_correct ? "2. Buy " : "" ), ( enabled == 0 ) ? "" : ( requirements_correct ? upgrade_names[player_data[id][UPGRADE_CHOICE]] : "" ))
			}else if ( player_data[id][TEAM] == ALIEN )
			{
				player_data[id][UPGRADE_CHOICE] = ALIEN_UP_ARRAY_START + 2
				upgrlevel = player_data[id][UP_BLOODLUST] + 1
				pointcost = BLOODLUSTCOST
				
				new bloodlust_percentage = ( BLOODLUSTSPEED * 100 / 16 ) * upgrlevel
				
				requirements_correct = ( player_data[id][POINTS_AVAILABLE] >= BLOODLUSTCOST
							&& level >= BLOODLUSTLEVEL
							&& ns_get_mask(id, MASK_ADRENALINE)
							&& player_data[id][UP_BLOODLUST] < BLOODLUSTMAX )
				enabled = BLOODLUST
				
				len = formatex(menuBody, 541, "%s:^n^n", upgrade_names[player_data[id][UPGRADE_CHOICE]])
				len += formatex(menuBody[len], 541 - len, "Increases your blood lust, increasing the rate at which you recharge energy^nEnergy recharge is increased by [+%d%%], Onos [+%d%%]^n^nRequires: Adrenaline , Level %d, %d point%s^n^nNext level [%d]^n^n", bloodlust_percentage, bloodlust_percentage / 3, BLOODLUSTLEVEL, pointcost, pointcost > 1 ? "s" : "", upgrlevel)
				len += formatex(menuBody[len], 541 - len, "%s%s^n^n0. Exit^n^n^n^n^n^n^n", ( enabled == 0 ) ? "This upgrade is not enabled, sorry for the inconvenience" : ( requirements_correct ? "2. Buy " : "" ), ( enabled == 0 ) ? "" : ( requirements_correct ? upgrade_names[player_data[id][UPGRADE_CHOICE]] : "" ))
			}
		}
		case 3:
		{
			if ( player_data[id][TEAM] == MARINE )
			{
				player_data[id][UPGRADE_CHOICE] = 3
				upgrlevel = player_data[id][UP_ADVAMMOPACK] + 1
				pointcost = ADVAMMOPACKCOST
				
				new pistol_add = floatround(ADVAMMOPACK_PISTOL * upgrlevel, floatround_floor)
				new lmg_add = floatround(ADVAMMOPACK_LMG * upgrlevel, floatround_floor)
				new shotgun_add = floatround(ADVAMMOPACK_SHOTGUN * upgrlevel, floatround_floor)
				new hmg_add = floatround(ADVAMMOPACK_HMG * upgrlevel, floatround_floor)
				new gl_add = floatround(ADVAMMOPACK_GL * upgrlevel, floatround_floor)
				
				requirements_correct = ( player_data[id][POINTS_AVAILABLE] >= ADVAMMOPACKCOST
							&& level >= ADVAMMOPACKLEVEL
							&& player_data[id][GOT_RESUPPLY]
							&& ns_get_mask(id, MASK_ARMOR1)
							&& ns_get_mask(id, MASK_WEAPONS1)
							&& player_data[id][UP_ADVAMMOPACK] < ADVAMMOPACKMAX )
				enabled = ADVAMMOPACK
				
				len = formatex(menuBody, 541, "%s:^n^n", upgrade_names[player_data[id][UPGRADE_CHOICE]])
				len += formatex(menuBody[len], 541 - len, "Your Ammopacks will be enhanced to provide more Ammunition^nPistol [+%d]    / LMG [+%d]    / Shotgun [+%d]^nHMG [+%d]    / GL [+%d]^n^n", pistol_add, lmg_add, shotgun_add, hmg_add, gl_add)
				len += formatex(menuBody[len], 541 - len, "Requires: Resupply , Armor 1 , Weapons 1 , Level %d, %d point%s^n^nNext level [%d]^n^n", ADVAMMOPACKLEVEL, pointcost, pointcost > 1 ? "s" : "", upgrlevel)
				len += formatex(menuBody[len], 541 - len, "%s%s^n^n0. Exit^n^n^n^n^n^n^n^n", ( enabled == 0 ) ? "This upgrade is not enabled, sorry for the inconvenience" : ( requirements_correct ? "2. Buy " : "" ), ( enabled == 0 ) ? "" : ( requirements_correct ? upgrade_names[player_data[id][UPGRADE_CHOICE]] : "" ))
			}else if ( player_data[id][TEAM] == ALIEN )
			{
				player_data[id][UPGRADE_CHOICE] = ALIEN_UP_ARRAY_START + 3
				upgrlevel = player_data[id][UP_HUNGER] + 1
				pointcost = HUNGERCOST
				
				new Float:hungermaxtime = HUNGERINITIALTIME + HUNGERLEVELTIME * upgrlevel
				
				requirements_correct = ( player_data[id][POINTS_AVAILABLE] >= HUNGERCOST
							&& level >= HUNGERLEVEL
							&& player_data[id][UP_BLOODLUST]
							&& player_data[id][UP_HUNGER] < HUNGERMAX )
				enabled = HUNGER
				
				len = formatex(menuBody, 541, "%s:^n^n", upgrade_names[player_data[id][UPGRADE_CHOICE]])
				len += formatex(menuBody[len], 541 - len, "Gives you bonuses when you kill an enemy, these bonuses last for the specified time^nLasts [%.2f] second%s, gain is [+%d%%] of maxhealth, effects of primalscream and speed increasement by [+%d] upon kill (bonuses stack)^n^n", hungermaxtime, hungermaxtime == 1.0 ? "" : "s", HUNGERHEALTH, HUNGERSPEED)
				len += formatex(menuBody[len], 541 - len, "Requires: Blood Lust , Level %d, %d point%s^n^nNext level [%d]^n^n", HUNGERLEVEL, pointcost, pointcost > 1 ? "s" : "", upgrlevel)
				len += formatex(menuBody[len], 541 - len, "%s%s^n^n0. Exit^n^n^n^n^n^n^n", ( enabled == 0 ) ? "This upgrade is not enabled, sorry for the inconvenience" : ( requirements_correct ? "2. Buy " : "" ), ( enabled == 0 ) ? "" : ( requirements_correct ? upgrade_names[player_data[id][UPGRADE_CHOICE]] : "" ))
			}
		}
		case 4:
		{
			if ( player_data[id][TEAM] == MARINE )
			{
				player_data[id][UPGRADE_CHOICE] = 4
				upgrlevel = player_data[id][UP_STATICFIELD] + 1
				pointcost = STATICFIELDCOST
				
				// init range + ( levelrange * rangelevelmultiplier )
				new staticrange = STATICFIELDINITIALRANGE + ( STATICFIELDLEVELRANGE * upgrlevel )
				
				new staticnumerator = upgrlevel * STATICFIELDNUMERATORLV
				if ( staticnumerator > MAXSTATICNUMERATOR )
					staticnumerator = MAXSTATICNUMERATOR
				
				// ( 100% / STATICFIELDDENOMENATOR )  => each level * staticnumerator => how much to weaken alien in total
				// divide by 2 => how much weaken HP and AP each
				new percentage = floatround((100.0 / float(STATICFIELDDENOMENATOR) * staticnumerator) / 2.0)
				
				requirements_correct = ( player_data[id][POINTS_AVAILABLE] >= STATICFIELDCOST
							&& level >= STATICFIELDLEVEL
							&& player_data[id][GOT_SCAN]
							&& ns_get_mask(id, MASK_WEAPONS2)
							&& ns_get_mask(id, MASK_MOTION)
							&& player_data[id][UP_STATICFIELD] < STATICFIELDMAX )
				enabled = STATICFIELD
				
				len = formatex(menuBody, 541, "%s:^n^n", upgrade_names[player_data[id][UPGRADE_CHOICE]])
				len += formatex(menuBody[len], 541 - len, "Uses a special electric shock to weaken the natural toughness of enemies (cloacked aliens are ignored)^nEnemies in range of [%d] are weakened by [%d%%] by lowering max health and max armor^n^n", staticrange, percentage)
				len += formatex(menuBody[len], 541 - len, "Requires: Motion Tracking , Weapons 2 , Scan Area , Level %d, %d point%s^n^nNext level [%d]^n^n", STATICFIELDLEVEL, pointcost, pointcost > 1 ? "s" : "", upgrlevel)
				len += formatex(menuBody[len], 541 - len, "%s%s^n^n0. Exit^n^n^n^n^n^n^n", ( enabled == 0 ) ? "This upgrade is not enabled, sorry for the inconvenience" : ( requirements_correct ? "2. Buy " : "" ), ( enabled == 0 ) ? "" : ( requirements_correct ? upgrade_names[player_data[id][UPGRADE_CHOICE]] : "" ))
			}else if ( player_data[id][TEAM] == ALIEN )
			{
				player_data[id][UPGRADE_CHOICE] = ALIEN_UP_ARRAY_START + 4
				upgrlevel = player_data[id][UP_ACIDIC_VENGEANCE] + 1
				pointcost = ACIDICVENGEANCECOST
				
				requirements_correct = ( player_data[id][POINTS_AVAILABLE] >= ACIDICVENGEANCECOST
							&& level >= ACIDICVENGEANCELEVEL
							&& ns_get_hive_ability(id, 4)
							&& ns_get_mask(id, MASK_SCENTOFFEAR)
							&& player_data[id][UP_ACIDIC_VENGEANCE] < ACIDICVENGEANCEMAX )
				enabled = ACIDICVENGEANCE
				
				len = formatex(menuBody, 541, "%s:^n^n", upgrade_names[player_data[id][UPGRADE_CHOICE]])
				len += formatex(menuBody[len], 541 - len, "Whenever you are killed, you leave an acidic cloud that damages your enemies.^n")
				len += formatex(menuBody[len], 541 - len, "HA for [%2.1f] HP - [%2.1f] AP and others for [%2.1f] HP - [%2.1f] AP.^n", AV_MA_HP * upgrlevel, AV_MA_AP * upgrlevel, AV_HA_HP * upgrlevel, AV_HA_AP * upgrlevel)
				len += formatex(menuBody[len], 541 - len, "Gorge and Gestate have an enhanced damage by [%d%%]. Range depends on your class, current range [%d].^n^n", floatround(AV_GORGE_GEST_MULTI * 100.0 - 100.0), (100 + class * 50))
				len += formatex(menuBody[len], 541 - len, "Requires: Hive Ability 2, Sense of Fear , Level %d, %d point%s^n^nNext level [%d]^n^n", ACIDICVENGEANCELEVEL, pointcost, pointcost > 1 ? "s" : "", upgrlevel)
				len += formatex(menuBody[len], 541 - len, "%s%s^n^n0. Exit^n^n^n^n^n^n^n^n", ( enabled == 0 ) ? "This upgrade is not enabled, sorry for the inconvenience" : ( requirements_correct ? "2. Buy " : "" ), ( enabled == 0 ) ? "" : ( requirements_correct ? upgrade_names[player_data[id][UPGRADE_CHOICE]] : "" ))
			}
		}
		case 5:
		{
			if ( level >= BASE_MAX_LEVEL )
			{
				if ( player_data[id][TEAM] == MARINE )
				{
					player_data[id][UPGRADE_CHOICE] = 5
					upgrlevel = player_data[id][UP_URANUIMAMMO] + 1
					pointcost = URANUIMAMMOCOST
					
					requirements_correct = ( player_data[id][POINTS_AVAILABLE] >= URANUIMAMMOCOST
								&& ns_get_mask(id, MASK_WEAPONS3)
								&& player_data[id][UP_URANUIMAMMO] < URANUIMAMMOMAX )
					enabled = URANUIMAMMO
					
					len = formatex(menuBody, 541, "%s:^n^n", upgrade_names[player_data[id][UPGRADE_CHOICE]])
					len += formatex(menuBody[len], 541 - len, "Ammunition contains depleted uranium to enhance damage for all weapons except (Knife, Welder)^nBullets [+%d%%] / Grenades [+%d%%] Damage^n^nRequires: Weapons 3 , Level 10, %d point%s^n^nNext level [%d]^n^n", upgrlevel * URANUIMAMMO_BULLET, upgrlevel * URANUIMAMMO_GREN, pointcost, pointcost > 1 ? "s" : "", upgrlevel)
					len += formatex(menuBody[len], 541 - len, "%s%s^n^n0. Exit^n^n^n^n^n^n^n", ( enabled == 0 ) ? "This upgrade is not enabled, sorry for the inconvenience" : ( requirements_correct ? "2. Buy " : "" ), ( enabled == 0 ) ? "" : ( requirements_correct ? upgrade_names[player_data[id][UPGRADE_CHOICE]] : "" ))
				}else if ( player_data[id][TEAM] == ALIEN )
				{
					player_data[id][UPGRADE_CHOICE] = ALIEN_UP_ARRAY_START + 5
					upgrlevel = player_data[id][UP_SENSE_OF_ANCIENTS] + 1
					pointcost = SENSEOFANCIENTSCOST
					
					new dev_time_mult = ( upgrlevel % SOA_DEVOUR_ADDER == 1 ) ? 1 : player_data[id][SOA_DEVOUR_TIME_MULTIPLIER] + 1
					new Float:devour_time = SOA_DEVOURTIME_INIT - ( dev_time_mult * SOA_DEVOURTIME_BONUS )
					new players_to_devour = floatround( float(upgrlevel) / float(SOA_DEVOUR_ADDER), floatround_ceil)
					
					new dc_up = ( ns_get_mask(id, MASK_CARAPACE)
							|| ns_get_mask(id, MASK_REGENERATION)
							|| ns_get_mask(id, MASK_REDEMPTION) )
					
					new mc_up = ( ns_get_mask(id, MASK_CELERITY)
							|| ns_get_mask(id, MASK_ADRENALINE)
							|| ns_get_mask(id, MASK_SILENCE) )
					
					new sc_up = ( ( ns_get_mask(id, MASK_CLOAKING)
								|| player_data[id][ES_SHIFTING] )
							|| ns_get_mask(id, MASK_FOCUS)
							|| ns_get_mask(id, MASK_SCENTOFFEAR) )
					
					requirements_correct = ( player_data[id][POINTS_AVAILABLE] >= SENSEOFANCIENTSCOST
								&& dc_up
								&& mc_up
								&& sc_up
								&& player_data[id][UP_SENSE_OF_ANCIENTS] < SENSEOFANCIENTSMAX )
					enabled = SENSEOFANCIENTS
					
					len = formatex(menuBody, 541, "%s:^n^n", upgrade_names[player_data[id][UPGRADE_CHOICE]])
					len += formatex(menuBody[len], 541 - len, "Skulk: Parasite [+%d%%] damage, infects players in range by chance [%d%%] over 3 seconds^nGorge: Stronger Healspray [+%d%%]^nLerk: Gas with [%d] damage to armor of HA^n", SOA_PARASITE_DMG * upgrlevel, SOA_PARASITE_INIT + upgrlevel * SOA_PARASITE_ADD, upgrlevel * SOA_HEALSPRAY_DMG, upgrlevel * SOA_GASDAMAGE)
					len += formatex(menuBody[len], 541 - len, "Fade: Blink energy reduced by [%d%%]^nOnos: Devour [%d] more player%s, with a cooldown time of [%2.1f] second%s between devours^nGestate: Armor increased by [+%d]^n^n", upgrlevel * SOA_BLINK_ENERGY_BONUS, players_to_devour, ( players_to_devour > 1 ) ? "s" : "", devour_time, devour_time == 1.0 ? "" : "s", upgrlevel * SOA_GESTATE_ARMOR_ADD)
					len += formatex(menuBody[len], 541 - len, "Requires: 1 Upgrade of each Upgrade Chamber , Level 10, %d point%s^n^nNext level [%d]^n^n", pointcost, pointcost > 1 ? "s" : "", upgrlevel)
					len += formatex(menuBody[len], 541 - len, "%s%s^n^n0. Exit^n^n^n^n^n^n^n^n^n^n^n", ( enabled == 0 ) ? "This upgrade is not enabled, sorry for the inconvenience" : ( requirements_correct ? "2. Buy " : "" ), ( enabled == 0 ) ? "" : ( requirements_correct ? upgrade_names[player_data[id][UPGRADE_CHOICE]] : "" ))
				}
			}else
			{
				found_error = 1
				showMenu(id)
			}
		}
	}
	if ( !found_error && key != 9 )
	{
		if ( requirements_correct && enabled )
			menu_keys |= MENU_KEY_2
		
		show_menu(id, menu_keys, menuBody)
	}
	
	return PLUGIN_HANDLED
}

public choice_one_to_six( id , key )
{
	new class = ns_get_class(id)
	if ( !( CLASS_SKULK <= class <= CLASS_GESTATE )
		|| key != 1 )
	{
		player_data[id][UPGRADE_CHOICE] = -1
	
		return PLUGIN_HANDLED
	}
	
	new message[180]
	new cur_level, maxupgrlevel, cost
	new error
	if ( player_data[id][TEAM] == MARINE )
	{
		switch ( player_data[id][UPGRADE_CHOICE] )
		{
			case 0:
			{
				maxupgrlevel = CYBERNETICSMAX
				
				cur_level = player_data[id][UP_CYBERNETICS] += 1
				cost = CYBERNETICSCOST
			}
			case 1:
			{
				maxupgrlevel = REINFORCEARMORMAX
				
				cur_level = player_data[id][UP_REINFORCEARMOR] += 1
				cost = REINFORCEARMORCOST
				
				if ( is_gnome_running )
					GNOME_setget_armor(id, player_data[id][UP_REINFORCEARMOR], ARMOR_MA, ARMOR_HA, gnome_base_armor, gnome_max_armor)
				
				new Float:armorvalue
				get_max_armor(id, armorvalue)
				
				// if player does not have max armor dont give max armor but only the upgrade value
				if ( class == CLASS_HEAVY )
					set_pev(id, pev_armorvalue, armorvalue + ARMOR_HA)
				else
					set_pev(id, pev_armorvalue, armorvalue + ARMOR_MA)
			}
			case 2:
			{
				maxupgrlevel = NANOARMORMAX
				
				cur_level = player_data[id][UP_NANOARMOR] += 1
				cost = NANOARMORCOST
			}
			case 3:
			{
				maxupgrlevel = ADVAMMOPACKMAX
				
				cur_level = player_data[id][UP_ADVAMMOPACK] += 1
				cost = ADVAMMOPACKCOST
				
				if ( cur_level == 1 )
					set_weapon_damage_ammo(id, 0 , 2)
				else if ( !cPT_player_data[id][CPT_STARTED_TO_RELOAD] )
				{
					new ammo_to_add
					for ( new i = 0; i < 2; ++i )
					{
						ammo_to_add = floatround(weapon_ammo_adds[cPT_player_data[id][CPT_WEAPON_IDS][i + 2]], floatround_floor)
						
						if ( ammo_to_add == 0
							&& ( weapon_ammo_adds[cPT_player_data[id][CPT_WEAPON_IDS][i + 2]] * cur_level - weapon_ammo_adds[cPT_player_data[id][CPT_WEAPON_IDS][i + 2]] * player_data[id][AA_UPLVL_GOT_FREEAMMO] ) >= 1.0 )
						{
							player_data[id][AA_UPLVL_GOT_FREEAMMO] = cur_level
							ammo_to_add = 1
						}
						
						set_weapon_clip(cPT_player_data[id][CPT_WEAPON_IDS][i], ammo_to_add)
						set_weapon_reserve(id, cPT_player_data[id][CPT_WEAPON_IDS][i + 2], ammo_to_add * 2)
					}
				}
			}
			case 4:
			{
				maxupgrlevel = STATICFIELDMAX
				
				cur_level = player_data[id][UP_STATICFIELD] += 1
				cost = STATICFIELDCOST
				
				new staticnumerator = player_data[id][UP_STATICFIELD] * STATICFIELDNUMERATORLV
				if ( staticnumerator > MAXSTATICNUMERATOR )
					staticnumerator = MAXSTATICNUMERATOR
				
				// ( 100% / STATICFIELDDENOMENATOR )  => each level * staticnumerator => how much to weaken alien in total
				// divide by 2 => how much weaken HP and AP each
				// 100% - how much weaken HP and AP each => new percentage of HP + AP each
				SF_static_percent[id] = 100.0 - ( ( 100.0 / float(STATICFIELDDENOMENATOR) * staticnumerator ) / 2 )
			}
			case 5:
			{
				maxupgrlevel = URANUIMAMMOMAX
				
				cur_level = player_data[id][UP_URANUIMAMMO] += 1
				cost = URANUIMAMMOCOST
				
				set_weapon_damage_ammo(id, 0 , 1)
			}
		}
	}else if ( player_data[id][TEAM] == ALIEN )
	{
		if ( class == CLASS_ONOS )
		{
			if ( player_data[id][UP_SENSE_OF_ANCIENTS]
				&& ( player_data[id][SOA_DEVOURING_PLAYERS_NUM] > 0
					|| ns_get_mask(id, MASK_DIGESTING) ) )
				error = 1
			else
			{
				new Float:origin[3]
				pev(id, pev_origin, origin)
				if ( trace_hull(origin, HULL_HUMAN, id) != 0 )
					error = 2
			}
		}
		if ( !error )
		{
			switch ( player_data[id][UPGRADE_CHOICE] )
			{
				case ALIEN_UP_ARRAY_START:
				{
					maxupgrlevel = THICKENEDSKINMAX
					
					cur_level = player_data[id][UP_THICKENED_SKIN] += 1
					cost = THICKSKINCOST
					
					get_base_add_health(id)
					set_pev(id, pev_max_health, player_data[id][TS_HEALTH_VALUES][TS_MAX_HP])
				}
				case ALIEN_UP_ARRAY_START + 1:
				{
					maxupgrlevel = ETHSHIFTMAX
					
					cur_level = player_data[id][UP_ETHEREAL_SHIFT] += 1
					cost = ETHSHIFTCOST
					
					new Float:shift_level = SHIFTLEVEL
					if ( class == CLASS_SKULK
						|| class == CLASS_GORGE
						|| class == CLASS_LERK )
						shift_level *= SHIFTCLASSMULTI
					
					player_data[id][ES_SHIFTTIME] = _:( SHIFTINITIAL + shift_level * player_data[id][UP_ETHEREAL_SHIFT] )
				}
				case ALIEN_UP_ARRAY_START + 2:
				{
					maxupgrlevel = BLOODLUSTMAX
					
					cur_level = player_data[id][UP_BLOODLUST] += 1
					cost = BLOODLUSTCOST
				}
				case ALIEN_UP_ARRAY_START + 3:
				{
					maxupgrlevel = HUNGERMAX
					
					cur_level = player_data[id][UP_HUNGER] += 1
					cost = HUNGERCOST
				}
				case ALIEN_UP_ARRAY_START + 4:
				{
					maxupgrlevel = ACIDICVENGEANCEMAX
					
					cur_level = player_data[id][UP_ACIDIC_VENGEANCE] += 1
					cost = ACIDICVENGEANCECOST
				}
				case ALIEN_UP_ARRAY_START + 5:
				{
					maxupgrlevel = SENSEOFANCIENTSMAX
					
					cur_level = player_data[id][UP_SENSE_OF_ANCIENTS] += 1
					cost = SENSEOFANCIENTSCOST
					
					player_data[id][SOA_PARASITE_CHANCE] = SOA_PARASITE_INIT + cur_level * SOA_PARASITE_ADD
					
					if ( cur_level % SOA_DEVOUR_ADDER == 1 )
					{
						player_data[id][SOA_DEVOUR_TIME_MULTIPLIER] = 1
						player_data[id][SOA_MAX_DEVOUR_AMOUNT] += 1
					}else
						player_data[id][SOA_DEVOUR_TIME_MULTIPLIER] += 1
					
					player_data[id][SOA_DEVOUR_TIME] = _:( SOA_DEVOURTIME_INIT - ( player_data[id][SOA_DEVOUR_TIME_MULTIPLIER] * SOA_DEVOURTIME_BONUS ) )
					
					if ( class == CLASS_SKULK || class == CLASS_GORGE )
						set_weapon_damage_ammo(id)
				}
			}
		}
	}
	
	if ( player_data[id][TEAM] )
	{
		switch ( error )
		{
			case 0:
			{
				formatex(message, 179, "You got Level %d of %d levels of %s", cur_level, maxupgrlevel, upgrade_names[player_data[id][UPGRADE_CHOICE]])
				
				ns_set_points(id, ns_get_points(id) + cost)
				
				// check level immidiatly (exploit fix)
				check_level_player(id)
				
				if ( player_data[id][TEAM] == ALIEN )
				{
					player_gestating_emu[id] = 1
				}
			}
			case 1:
				copy(message, 179, no_gestate_digest_msg)
			default:
				copy(message, 179, "You need more room to gestate.")
		}
		
		ns_popup(id, message)
	}
	
	player_data[id][UPGRADE_CHOICE] = -1
	
	return PLUGIN_HANDLED
}

public upgrade_etherealshift( id )
{
	if ( gorgzilla_running )
		return
	
	if ( !player_data[id][UP_ETHEREAL_SHIFT] )
		return
	
	new Float:energy
	pev(id, pev_fuser3, energy)
	if ( get_gametime() - ( player_data[id][ES_LASTSHIFT] + player_data[id][ES_SHIFTTIME] ) < SHIFTDELAY
		|| energy < 300
		|| ( !ONOS_SHIFT && ns_get_class(id) == CLASS_ONOS ) )
		return
	
	player_data[id][ES_LASTSHIFT] = _:get_gametime()
	
	// disable normal cloak so it will not disturb
	set_pdata_float(id, UNCLOAKTIME_OFF, player_data[id][ES_LASTSHIFT] + player_data[id][ES_SHIFTTIME], UNCLOAKTIME_OFF_LIN)
	set_pdata_float(id, CLOAK_OFF, 1.0, CLOAK_OFF_LIN)
	ns_set_mask(id, MASK_CLOAKING, 0)
	
	// make player realy invisible
	set_pev(id, pev_rendermode, 2)
	
	player_data[id][ES_SHIFTING] = 1
	set_pev(id, pev_fuser3, energy - 300.0)
	if ( !ns_get_mask(id, MASK_SILENCE) )
		emit_sound(id, CHAN_ITEM, sound_files[sound_cloakstart], 0.5, ATTN_NORM, 0, PITCH_NORM)
	
	// update HUD
	show_hud_msg(id, id, player_data[id][LASTXP], player_data[id][CUR_LEVEL], 0, get_gametime())
}

public showMenu( id )
{
	if ( gorgzilla_running )
		return PLUGIN_HANDLED
	
	if ( !is_user_alive(id)
		|| !player_data[id][TEAM]
		|| ns_get_class(id) == CLASS_GESTATE
		|| ( pev(id, pev_effects) & EF_NODRAW ) )
		return PLUGIN_HANDLED
	
	new menuBody[512]
	new len = formatex(menuBody, 511, "Choose an upgrade to view information about:^n^n")
	if ( player_data[id][BANNED] )
	{
		len += formatex(menuBody[len], 511 - len, "You have been banned from using ExtraLevels 3 upgrades^n^n")
		len += formatex(menuBody[len], 511 - len, "Either you did not follow Server Rules or did something else bad")
		len += formatex(menuBody[len], 511 - len, "^n^n0. Exit^n^n^n^n^n")
		
		show_menu(id, MENU_KEY_0, menuBody)
		return PLUGIN_HANDLED
	}else if ( player_data[id][TEAM] == MARINE )
	{
		len += formatex(menuBody[len], 511 - len, "1. Cybernetics                    ( %3d / %3d )^n2. Reinforced Armor          ( %3d / %3d )^n3. Nano Armor                    ( %3d / %3d )^n", player_data[id][UP_CYBERNETICS], CYBERNETICSMAX, player_data[id][UP_REINFORCEARMOR], REINFORCEARMORMAX, player_data[id][UP_NANOARMOR], NANOARMORMAX)
		len += formatex(menuBody[len], 511 - len, "4. Advanced Ammopack   ( %3d / %3d )^n5. Static Field                     ( %3d / %3d )^n", player_data[id][UP_ADVAMMOPACK], ADVAMMOPACKMAX, player_data[id][UP_STATICFIELD], STATICFIELDMAX)
		if ( player_data[id][CUR_LEVEL] >= BASE_MAX_LEVEL )
			len += formatex(menuBody[len], 511 - len, "6. Uranium Ammunition     ( %3d / %3d )^n^n0. Exit^n^n^n^n^n", player_data[id][UP_URANUIMAMMO], URANUIMAMMOMAX)
		else
			len += formatex(menuBody[len], 511 - len, "6. Uranium Ammunition    (blocked till level 10)^n^n0. Exit^n^n^n^n^n")
	}else
	{
		len += formatex(menuBody[len], 511 - len, "1. Thickened Skin        ( %3d / %3d )^n2. Ethereal Shift           ( %3d / %3d )^n3. Blood Lust                ( %3d / %3d )^n", player_data[id][UP_THICKENED_SKIN], THICKENEDSKINMAX, player_data[id][UP_ETHEREAL_SHIFT], ETHSHIFTMAX, player_data[id][UP_BLOODLUST], BLOODLUSTMAX)
		len += formatex(menuBody[len], 511 - len, "4. Hunger                      ( %3d / %3d )^n5. Acidic Vengeance   ( %3d / %3d )^n", player_data[id][UP_HUNGER], HUNGERMAX, player_data[id][UP_ACIDIC_VENGEANCE], ACIDICVENGEANCEMAX)
		if ( player_data[id][CUR_LEVEL] >= BASE_MAX_LEVEL )
			len += formatex(menuBody[len], 511 - len, "6. Sense of Ancients   ( %3d / %3d )^n^n0. Exit^n^n^n^n^n", player_data[id][UP_SENSE_OF_ANCIENTS], SENSEOFANCIENTSMAX)
		else
			len += formatex(menuBody[len], 511 - len, "6. Sense of Ancients     (blocked till level 10)^n^n0. Exit^n^n^n^n^n")
	}
	
	show_menu(id, MENU_KEY_1 | MENU_KEY_2 | MENU_KEY_3 | MENU_KEY_4 | MENU_KEY_5 | MENU_KEY_6 | MENU_KEY_0, menuBody)
	
	return PLUGIN_HANDLED
}

public showHelpMenu( id )
{
	if ( gorgzilla_running )
		return PLUGIN_HANDLED
	
	new menuBody[512], name[33], text_add[64]
	if ( is_user_connected(WP_ID) )
	{
		get_user_name(WP_ID, name, 32)
		formatex(text_add, 63, " (connected as %s)", name)
	}else
		WP_ID = 0
	
	new len = formatex(menuBody, 511, "Help:^nThis server is running ExtraLevels 3 v%s by %s%s^nOriginal ExtraLevels 2 by Cheeserm!^n^n", plugin_version, plugin_author, ( WP_ID > 0 ) ? text_add : "")
	len += formatex(menuBody[len], 511 - len, "With ExtraLevels 3, two major things are changed^n^nA) You can get up to level %i.^n^nY) You can get new extra upgrades^n^nB) Try typing /xmenu or xmenu to view these extra upgrades.^n   Make sure you have all the requirement to get an extra upgrade.^n   HAVE FUN!!!^n^n0. Exit^n^n^n^n^n^n^n^n^n", get_pcvar_num(CVAR_maxlevel))
	show_menu(id, MENU_KEY_0, menuBody)
	
	return PLUGIN_HANDLED
}

public showMenuInfo( id )
{
	if ( gorgzilla_running )
		return PLUGIN_HANDLED
	
	new menuBody[512]
	new len = formatex(menuBody, 511, "Help:^nThis server is running ExtraLevels 3 v%s by %s^n^n", plugin_version, plugin_author)
	len += formatex(menuBody[len], 511 - len, "Your input /menu and menu is not used anymore.^nUse /xmenu or xmenu instead.^nOr type /xhelp in chat.^n^n0. Exit^n^n^n^n")
	show_menu(id, MENU_KEY_0, menuBody)
	
	return PLUGIN_HANDLED
}

public core_timer( )
{
	if ( gorgzilla_running )
		return PLUGIN_HANDLED
	
	CoreT_max_level = get_pcvar_num(CVAR_maxlevel)
	if ( CoreT_max_level < 11 )
		return PLUGIN_HANDLED
	
	new Float:gametime = get_gametime()
	new xp, level, vid
	new is_marine
	for ( new id = 1; id <= g_maxPlayers; ++id )
	{
		if ( !is_user_connected(id) )
			continue
		
		if ( !player_data[id][TEAM] && pev(id, pev_playerclass) != 5 )
			continue
		
		if ( is_user_alive(id) )
		{
			vid = id
			if ( player_data[id][UP_CYBERNETICS] )
				upgrade_speed(id)
			
			if ( player_data[id][UP_THICKENED_SKIN] )
				upgrade_thickenedskin(id, gametime)
			
			if ( player_data[id][UP_NANOARMOR] )
				upgrade_nanoarmor(id, gametime)
			
			// here is no check because marines are those who parasite others
			upgrade_soa_parasite(id, gametime)
		}else if ( pev(id, pev_iuser1) == 4 && pev(id, pev_iuser2) > 0 )
		{	// First Person Spectating mode and Person being spectated is set
			vid = pev(id, pev_iuser2)
			
			if ( pev(id, pev_playerclass) == 5 && player_data[vid][CUR_LEVEL] < BASE_MAX_LEVEL )
				reset_hud(id)
		}else
		{
			if ( player_data[id][LASTXP] == -1 )
				continue
			
			reset_hud(id)
			
			player_data[id][LASTXP] = -1
			continue
		}
		xp = check_level_player(vid)
		
		if ( player_data[vid][LASTXP] > xp )
		{
			// XP has reduce somehow, so get correct level
			player_data[vid][CUR_LEVEL] = 1		// you start with level 1
			player_data[vid][XP_TO_NEXT_LVL] = 100	// level 2 is reached with 100 XP
			player_data[vid][BASE_LEVEL_XP] = 0
			xp = calc_lvl_and_xp(vid)
			
			// if XP is below lvl 10, clear hud message
			reset_hud(id)
			reset_hud(vid)
		}
		
		level = player_data[vid][CUR_LEVEL]
		
		if ( get_pcvar_num(CVAR_huddisplay) & 1
			&& level < BASE_MAX_LEVEL )
		{
			if ( player_data[id][MESSAGE_DISPLAYING] )
			{
				player_data[id][MESSAGE_DISPLAYING] = 0
				reset_hud(id)
			}
			player_data[id][LASTXP] = xp
			
			if ( player_data[id][AA_RELOAD_WEAPANIM_TIME] - gametime > 0.0
				|| player_data[id][ES_SHIFTING]
				|| ( 2 <= player_data[id][SOA_FRESH_PARASITE] <= 4
					&& player_data[id][SOA_INFECTED_BY_MARINE] ) )
				show_hud_msg(id, id, xp, level, ( player_data[id][TEAM] == MARINE ), gametime)
			
			continue
		}
		
		is_marine = ( player_data[vid][TEAM] == MARINE )
		
		// check if we advanced in level, if so play a sound
		if ( level > player_data[vid][LASTLEVEL] )
		{
			player_data[vid][LASTLEVEL] = level
			if ( CoreT_max_level >= level > BASE_MAX_LEVEL )
			{
				if( is_marine )
					emit_sound(id, CHAN_AUTO, sound_files[sound_Mlevelup], 0.5, ATTN_NORM, 0, PITCH_NORM)
				else if( !ns_get_mask(id, MASK_SILENCE) )
					emit_sound(id, CHAN_AUTO, sound_files[sound_Alevelup], 0.5, ATTN_NORM, 0, PITCH_NORM)
				
				// Update StatusValue text
				for ( CoreT_j = 1; CoreT_j <= g_maxPlayers; ++CoreT_j )
				{
					if ( player_data[CoreT_j][TEAM] == player_data[vid][TEAM]
						&& player_data[CoreT_j][STATUSVALUE_POINTING_AT] == vid )
					{
						emessage_begin(MSG_ONE, StatusValue_id, {0, 0, 0}, CoreT_j)
						ewrite_byte(4)
						ewrite_short(level)
						emessage_end()
					}
				}
				
			}
		}
		if ( gametime - player_data[id][HUD_DISP_TIME] > 1.0
			|| xp != player_data[id][LASTXP]
			|| player_data[vid][AA_RELOAD_WEAPANIM_TIME] - gametime > 0.0 )
			show_hud_msg(id, vid, xp, level, is_marine, gametime)
		
		player_data[id][LASTXP] = xp
	}
	return PLUGIN_HANDLED
}

public emulated_spore_timer( )
{
	// no need to directly check it in each function, so a check each second is enough
	if ( ( gorgzilla_running = get_pcvar_num(CVAR_gorgzilla) ) > 0  )
		return
	
	new Float:origin[3]
	new id, spore_id, spore_id_temp = -1
	new Float:new_armor
	
	// check each spore and increase counter
	for ( spore_id = 0; spore_id < spore_num; ++spore_id )
	{
		if ( spore_data[spore_id][1] < 6 )
		{
			for ( id = 1; id <= g_maxPlayers; ++id )
			{
				if ( !player_data[id][SOA_IN_SPORE] )
				{
					if ( player_data[id][TEAM] == MARINE )
					{	// player has a team so he must be connected
						pev(id, pev_origin, origin)
						if ( vector_distance(spore_data_orig[spore_id], origin) <= 250.0 )
						{
							if ( is_user_alive(id)
								&& ns_get_class(id) == CLASS_HEAVY )
							{
								pev(id, pev_armorvalue, new_armor)
								new_armor -= ( player_data[spore_data[spore_id][0]][UP_SENSE_OF_ANCIENTS] * SOA_GASDAMAGE )
								if ( new_armor < 0.0 )
									new_armor = 0.0
								set_pev(id, pev_armorvalue, new_armor)
							}
							
							// if in range but cannot be spored, so exclude from further checks
							player_data[id][SOA_IN_SPORE] = 1
						}
					}else
						player_data[id][SOA_IN_SPORE] = 1
				}
			}
			++spore_data[spore_id][1]
		}else if ( spore_id_temp != -1 )
			spore_id_temp = spore_id
	}
	
	// found at least one spore to remove, so sort array
	if ( spore_id_temp != -1 )
	{
		for ( spore_id = spore_id_temp; spore_id < spore_num && spore_id_temp < 90; ++spore_id, ++spore_id_temp )
		{
			if ( spore_data[spore_id][1] >= 6 || spore_data[spore_id_temp][1] >= 6 )
			{
				++spore_id_temp
				--spore_num
			}
			spore_data[spore_id][0] = spore_data[spore_id_temp][0]
			spore_data[spore_id][1] = spore_data[spore_id_temp][1]
			spore_data_orig[spore_id][0] = spore_data_orig[spore_id_temp][0]
			spore_data_orig[spore_id][1] = spore_data_orig[spore_id_temp][1]
			spore_data_orig[spore_id][2] = spore_data_orig[spore_id_temp][2]
		}
	}
	
	for ( id = 1; id <= g_maxPlayers; ++id )
		player_data[id][SOA_IN_SPORE] = 0
}

//////////////////// Additional Functions ////////////////////

plugin_init_set_vars( )
{
	extralevels_running = 1
	g_maxPlayers = get_maxplayers()
	max_entities = get_global_int(GL_maxEntities)
	spore_event = precache_event(1, "events/SporeCloud.sc")
	cloak_event = precache_event(1, "events/StartCloak.sc")
	particle_event = precache_event(1, "events/Particle.sc")
	DeathMsg_id = get_user_msgid("DeathMsg")
	Damage_id = get_user_msgid("Damage")
	ScoreInfo_id = get_user_msgid("ScoreInfo")
	HideWeapon_id = get_user_msgid("HideWeapon")
	Progress_id = get_user_msgid("Progress")
	WeapPickup_id = get_user_msgid("WeapPickup")
	StatusValue_id = get_user_msgid("StatusValue")
	
	new ent = -1
	while ( ( ent = find_ent_by_class(ent, "team_hive") ) > 0 )
	{
		if ( pev(ent, pev_team) == 2 )
			Hive_ID = ent
		else
			Hive_ID2 = ent
	}
	
	CVAR_gorgzilla = get_cvar_pointer("zilla_GorgZilla")
	if ( !CVAR_gorgzilla )
		CVAR_gorgzilla = register_cvar("zilla_GorgZilla", "0")
	CVAR_gnome_pickonly = get_cvar_pointer("mp_gnome_damage_pick_only")
	CVAR_gnome_damageadd = get_cvar_pointer("mp_gnome_damage_amplifier")
	
	CVAR_notify = register_cvar("amx_notifyme", "5")					// Set to the number of times you want the "ExtraLevels 3" message to be displayed on spawn.
	CVAR_instruct = register_cvar("amx_instruct", "5")					// Set to the number of times you want the "type /xhelp for more info" message to be displayed on spawn.
	CVAR_huddisplay = register_cvar("amx_huddisplay", "1")					// Set to 1 to get the normal levels display, set to 2 to get the alternate levels display. If you change from "2" to "1" in the same round, you may expirience some problems with the hud levels display for the round!
	CVAR_maxlevel = register_cvar("amx_maxlevel", "50")
	
	new i
	new Float:level_step = float(get_pcvar_num(CVAR_maxlevel) - BASE_MAX_LEVEL) / 20.0
	new level_increaser = floatround(level_step, floatround_floor)
	new Float:levels_remaining, level_difference
	new level_to_set = BASE_MAX_LEVEL
	
	for ( i = 0; i < 19; ++i )
	{
		level_to_set += level_increaser
		levels_remaining += level_step
		level_difference = floatround(levels_remaining - float(level_increaser), floatround_floor)
		if ( level_difference >= 1 )
		{
			level_to_set += level_difference
			levels_remaining -= float(level_difference)
		}else
			levels_remaining -= float(level_increaser)
		
		CVAR_upgrade_levels[18 - i] = register_cvar(level_cvar_list[18 - i], "")
		set_pcvar_num(CVAR_upgrade_levels[18 - i], level_to_set)
	}
	
	weapon_ammo_adds[WEAPON_PISTOL] = ADVAMMOPACK_PISTOL
	weapon_resup_ammo[WEAPON_PISTOL] = 10
	weapon_ammo_adds[WEAPON_LMG] = ADVAMMOPACK_LMG
	weapon_resup_ammo[WEAPON_LMG] = 50
	weapon_ammo_adds[WEAPON_SHOTGUN] = ADVAMMOPACK_SHOTGUN
	weapon_resup_ammo[WEAPON_SHOTGUN] = 8
	weapon_ammo_adds[WEAPON_HMG] = ADVAMMOPACK_HMG
	weapon_resup_ammo[WEAPON_HMG] = 125
	weapon_ammo_adds[WEAPON_GRENADE_GUN] = ADVAMMOPACK_GL
	weapon_resup_ammo[WEAPON_GRENADE_GUN] = 4
	
	NEXT_LEVEL_XP_MODIFIER_x2 = ( NEXT_LEVEL_XP_MODIFIER + 2.0 * BASE_XP_TO_NEXT_LEVEL ) / ( floatsqroot(float(NEXT_LEVEL_XP_MODIFIER)) * 2.0 )
}

gestate_emulation( )
{
	switch ( player_gestating_emu[SF_id] )
	{
		case 1:
		{
			player_gestate_emu_class[SF_id] = ns_get_class(SF_id)
			pev(SF_id, pev_health, player_gestate_hp[SF_id])
			pev(SF_id, pev_armorvalue, player_gestate_ap[SF_id])
			pev(SF_id, pev_origin, player_gestate_origin[SF_id])
			player_gestate_hp_max[SF_id] = player_data[SF_id][TS_HEALTH_VALUES][TS_MAX_HP]
			player_gestate_ap_max[SF_id] = player_data[SF_id][TS_HEALTH_VALUES][TS_MAX_AP]
			
			SF_gestate_got_spikes[SF_id] = ( ns_has_weapon(SF_id, WEAPON_SPIKE) && player_gestate_emu_class[SF_id] == CLASS_LERK )
			
			if ( player_gestate_extracheck[SF_id] )		// if after spawn no real gestate was done, we need to set gestate class again (otherwise it will be buggy)
				set_pev(SF_id, pev_iuser3, 8)
			
			player_gestate_time_emu[SF_id] = SF_gametime
			
			++player_gestating_emu[SF_id]
		}
		case 2:
		{
			client_cmd(SF_id, "spk hud/points_spent")
			
			gestate_messages(SF_id, 1, 10, 8)
			
			get_base_add_health(SF_id)
			
			player_gestate_hp[SF_id] = player_data[SF_id][TS_HEALTH_VALUES][TS_MAX_HP] / player_gestate_hp_max[SF_id] * player_gestate_hp[SF_id]
			player_gestate_ap[SF_id] = player_data[SF_id][TS_HEALTH_VALUES][TS_MAX_AP] / player_gestate_ap_max[SF_id] * player_gestate_ap[SF_id]
			if ( player_data[SF_id][UP_SENSE_OF_ANCIENTS] )
			{
				player_gestate_ap[SF_id] += SOA_GESTATE_ARMOR_ADD * player_data[SF_id][UP_SENSE_OF_ANCIENTS]
				player_data[SF_id][TS_HEALTH_VALUES][TS_MAX_AP] += ( SOA_GESTATE_ARMOR_ADD * player_data[SF_id][UP_SENSE_OF_ANCIENTS] )
			}
			player_gestate_hp_max[SF_id] = player_data[SF_id][TS_HEALTH_VALUES][TS_MAX_HP]
			player_gestate_ap_max[SF_id] = player_data[SF_id][TS_HEALTH_VALUES][TS_MAX_AP]
			
			set_pev(SF_id, pev_health, player_gestate_hp[SF_id])
			set_pev(SF_id, pev_armorvalue, player_gestate_ap[SF_id])
			
			++player_gestating_emu[SF_id]
		}
		case 3:
		{
			// normally 100.0 / 1.0 but that is 100.0 / and 1000.0 = 100.0 * 10.0
			set_pev(SF_id, pev_fuser3, 1000.0 * ( SF_gametime - player_gestate_time_emu[SF_id] ))
		}
		case 4:
		{
			if ( SF_gestate_got_spikes[SF_id] )
			{
				emessage_begin(MSG_ONE, WeapPickup_id, _, SF_id)
				ewrite_byte(WEAPON_SPIKE)
				emessage_end()
				
				ns_give_item(SF_id, "weapon_spikegun")
				
				SF_gestate_got_spikes[SF_id] = 0
			}
			
			get_base_add_health(SF_id)
			
			player_gestate_hp[SF_id] = player_data[SF_id][TS_HEALTH_VALUES][TS_MAX_HP] / player_gestate_hp_max[SF_id] * player_gestate_hp[SF_id]
			player_gestate_ap[SF_id] = player_data[SF_id][TS_HEALTH_VALUES][TS_MAX_AP] / player_gestate_ap_max[SF_id] * player_gestate_ap[SF_id]
			
			if ( player_gestate_hp[SF_id] < 1.0 )
				player_gestate_hp[SF_id] = 1.0
			
			set_pev(SF_id, pev_health, player_gestate_hp[SF_id])
			set_pev(SF_id, pev_armorvalue, player_gestate_ap[SF_id])
			
			if ( player_gestate_emu_class[SF_id] == CLASS_ONOS )
			{
				new Float:temp_orig[3]
				pev(SF_id, pev_origin, temp_orig)
				if ( trace_hull(temp_orig, HULL_HUMAN, SF_id) != 0 )
				{
					temp_orig[2] -= 18.0
					entity_set_origin(SF_id, temp_orig)
				}
			}
			
			reset_gestate_emu(SF_id)
			
			player_gestating_emu[SF_id] = 0
			player_gestate_emu_class[SF_id] = CLASS_SKULK
			
			player_gestating_emu_msg[SF_id] = 0
		}
	}
	if ( SF_gametime - player_gestate_time_emu[SF_id] >= 1.0 && player_gestating_emu[SF_id] )
	{
		set_pdata_int(SF_id, OLD_CLASS_OFF, player_gestate_emu_class[SF_id] + 2, OLD_CLASS_OFF_LIN)
		
		++player_gestating_emu[SF_id]
	}
}

upgrade_speed( id )
{
	new class = ns_get_class(id)
	new speedbonus
	if ( id == gnome_id[0] || id == gnome_id[1] )
		speedbonus = gnome_speed + ( SPEED_MA / 2 ) * player_data[id][UP_CYBERNETICS]
	else if ( class == CLASS_MARINE || class == CLASS_JETPACK )
		speedbonus = SPEED_MA * player_data[id][UP_CYBERNETICS]
	else if (class == CLASS_HEAVY) 
		speedbonus = SPEED_HA * player_data[id][UP_CYBERNETICS]
	
	ns_set_speedchange(id, speedbonus)
}

upgrade_weldoverbasemax( )
{
	new entity, part
	get_user_aiming(SF_id, entity, part)
	if ( !is_user_connected(entity) )
		return
	
	if ( pev(SF_id, pev_team) != pev(entity, pev_team)
		|| !is_user_alive(entity)
		|| entity_range(SF_id, entity) >= 200.0 )
		return
	
	SF_cur_armor = 0.0
	SF_cur_max_armor = 0.0
	SF_max_basearmor = 0.0
	SF_cur_max_armor = get_max_armor(entity, SF_cur_armor, SF_max_basearmor)
	
	if ( SF_max_basearmor <= SF_cur_armor < SF_cur_max_armor
		&& player_data[SF_id][TEAM] == MARINE )
	{
		SF_cur_armor += 35.0
		if ( SF_cur_armor > SF_cur_max_armor )
			SF_cur_armor = SF_cur_max_armor
		
		set_pev(entity, pev_armorvalue, SF_cur_armor)
		player_data[SF_id][RA_WELDED_OVERMAX] = 0
		if ( !player_data[SF_id][RA_WELDING_OVERMAX] )
		{
			emit_sound(SF_id, CHAN_AUTO, sound_files[sound_welderhit], 0.5, ATTN_NORM, 0, PITCH_NORM)
			emit_sound(SF_id, CHAN_STREAM, sound_files[sound_welderidle], 0.5, ATTN_NORM, 0, PITCH_NORM)
			player_data[SF_id][RA_WELDING_OVERMAX] = 1
		}
	}else if ( player_data[SF_id][RA_WELDING_OVERMAX] )
		player_data[SF_id][RA_WELDED_OVERMAX] = 1
}

upgrade_nanoarmor( id , Float:gametime )
{
	if ( gametime - player_data[id][NANOWELD_TIME] <= 1.0 )
		return
	
	new class = ns_get_class(id)
	new Float:armorvalue
	new Float:maxarmor = get_max_armor(id, armorvalue)
	if ( armorvalue < maxarmor )
	{
		if ( !player_data[id][NA_WELDING_SELF] )
			emit_sound(id, CHAN_STREAM, sound_files[sound_welderidle], 0.5, ATTN_NORM, 0, PITCH_NORM)
		
		player_data[id][NA_WELDING_SELF] = 1
		emit_sound(id, CHAN_AUTO, sound_files[sound_welderstop], 0.5, ATTN_NORM, 0, PITCH_NORM)
	}else if ( player_data[id][NA_WELDING_SELF] )
	{	// as we already have max stop selfweld + sound
		player_data[id][NA_WELDING_SELF] = 0
		emit_sound(id, CHAN_STREAM, sound_files[sound_welderidle], 0.0, ATTN_NORM, SND_STOP, PITCH_NORM)
		return
	}
	
	new nanoarmorvalue
	if ( class == CLASS_MARINE || class == CLASS_JETPACK )
		nanoarmorvalue = NANOARMOR_MA * player_data[id][UP_NANOARMOR]
	else if ( class == CLASS_HEAVY )
		nanoarmorvalue = NANOARMOR_HA * player_data[id][UP_NANOARMOR]
	
	new Float:newarmorvalue = armorvalue + nanoarmorvalue
	if ( newarmorvalue > maxarmor )
		newarmorvalue = maxarmor
	
	set_pev(id, pev_armorvalue, newarmorvalue)
	
	player_data[id][NANOWELD_TIME] = _:gametime
}
new cPT_weapon_is_reloading

upgrade_advancedammopack( id )
{
	cPT_ammo = ns_get_weap_clip(cPT_weapon_entid)
	cPT_reserve_ammo = ns_get_weap_reserve(id, SF_weaponid)
	cPT_weap_ammo_add = floatround(player_data[id][UP_ADVAMMOPACK] * weapon_ammo_adds[SF_weaponid], floatround_floor)
	
	cPT_player_button = pev(id, pev_button)
	
	// fix so that clip will always be displayed as max 250 ammo
	if ( cPT_player_data[id][CPT_RESERVE_AMMO_CORRECTOR] )
	{
		// we have set cPT_reserve_ammo_new to smaller 0 (zero) so make it positiv and do action in next server frame
		if ( cPT_player_data[id][CPT_RESERVE_AMMO_CORRECTOR] > 0 )
		{
			ns_set_weap_reserve(id, SF_weaponid, cPT_player_data[id][CPT_RESERVE_AMMO_CORRECTOR])
			cPT_player_data[id][CPT_RESERVE_AMMO_CORRECTOR] = 0
		}else
			cPT_player_data[id][CPT_RESERVE_AMMO_CORRECTOR] *= -1
	}
	
	// check if we have enough reserve as requested
	if ( cPT_reserve_ammo < cPT_weap_ammo_add )
		cPT_weap_ammo_add = cPT_reserve_ammo
	
	// check if player tries to reload
	if ( !cPT_player_data[id][CPT_STARTED_TO_RELOAD] )
	{
		if ( cPT_player_button & IN_RELOAD )
		{
			// if full ammo + full Advammopack OR no reserve, do not allow to reload
			if ( cPT_ammo >= weapon_resup_ammo[SF_weaponid] + cPT_weap_ammo_add
				|| SF_gametime < player_data[id][AA_RELOAD_WEAPANIM_TIME] )
			{	
				cPT_player_button &= ~IN_RELOAD
				set_pev(id, pev_button, cPT_player_button)
				
				return
			}else if ( cPT_ammo >= weapon_resup_ammo[SF_weaponid]
				&& SF_weaponid == WEAPON_GRENADE_GUN )
			{
				// correct GL reloading
				// NS will only make animations if ammo is < default max
				// so check how many grens we need to remove from clip and add to reserve
				
				player_data[id][AA_GL_RELOTIME_REDUCER] = _:( ( ( cPT_ammo - weapon_resup_ammo[WEAPON_GRENADE_GUN] ) + 1 ) * 1.1 )
				cPT_reserve_ammo += ( cPT_ammo - weapon_resup_ammo[WEAPON_GRENADE_GUN] ) + 1
				cPT_ammo -= ( cPT_ammo - weapon_resup_ammo[WEAPON_GRENADE_GUN] ) + 1
				ns_set_weap_reserve(id, SF_weaponid, cPT_reserve_ammo)
				ns_set_weap_clip(cPT_weapon_entid, cPT_ammo)
			}
			cPT_player_data[id][CPT_STARTED_TO_RELOAD] = 1
		}else
			cPT_player_data[id][CPT_STARTED_TO_RELOAD] = ( cPT_ammo == 0 && cPT_reserve_ammo > 0 )
	}
	
	// check if cur ammo = default value
	// if so trick NS and remove one bullet and add it to reserve
	if ( ( ( SF_weaponid != WEAPON_SHOTGUN
			&& cPT_ammo == weapon_resup_ammo[SF_weaponid] )
		|| ( SF_weaponid == WEAPON_SHOTGUN
			&& cPT_ammo >= weapon_resup_ammo[SF_weaponid] ) )
		&& cPT_reserve_ammo > 0
		&& cPT_player_data[id][CPT_STARTED_TO_RELOAD]
		&& !cPT_player_data[id][CPT_RELOADING_CUR_WEAP] )
	{
		if ( SF_weaponid == WEAPON_SHOTGUN )
		{
			cPT_player_data[id][CPT_SHOTGUN_BULLTES_XTRA_STOLEN] = cPT_weap_ammo_add - 1
			set_weapon_clip(cPT_weapon_entid, -( cPT_player_data[id][CPT_SHOTGUN_BULLTES_XTRA_STOLEN] + 1))
			cPT_player_data[id][CPT_SHOTGUN_BULLTES_STOLEN] = 1
		}else
		{
			--cPT_ammo
			set_weapon_clip(cPT_weapon_entid, -1)
			++cPT_reserve_ammo
			set_weapon_reserve(id, SF_weaponid, 1)
			++cPT_player_data[id][CPT_BULLTES_STOLEN]
		}
	}
	
	
	
	if ( cPT_player_data[id][CPT_STARTED_TO_RELOAD] )
	{
		cPT_weapon_is_reloading = get_pdata_int(cPT_weapon_entid, WEAPON_RELOADING_OFF, WEAPON_RELOADING_OFF_LIN)
		cPT_player_weaponanim = pev(id, pev_weaponanim)
		if ( cPT_weapon_is_reloading
			|| ( SF_weaponid == WEAPON_SHOTGUN		// shotgun does not set reload value
				&& cPT_player_weaponanim == 2 ) )
		{
			if ( !cPT_player_data[id][CPT_RELOADING_CUR_WEAP] )
			{
				cPT_player_data[id][CPT_RELOADING_CUR_WEAP] = SF_weaponid
				cPT_player_data[id][CPT_AMMO_BEFORE_RELOAD] = cPT_ammo
				cPT_player_data[id][CPT_RESERVE_BEFORE_RELOAD] = cPT_reserve_ammo
				
				player_data[id][AA_RELOAD_WEAPANIM_TIME] = _:SF_gametime
				switch ( SF_weaponid )
				{
					case WEAPON_PISTOL:
					{
						player_data[id][AA_RELOAD_WEAPANIM_TIME] += 3.0
					}
					case WEAPON_LMG:
					{
						player_data[id][AA_RELOAD_WEAPANIM_TIME] += 3.5
					}
					case WEAPON_SHOTGUN:
					{
						// shotgun reloads each bullet seperatly
						// so check how many bullets we can remove which will be readded later
						if ( cPT_player_data[id][CPT_SHOTGUN_BULLTES_STOLEN] <= 0 )
						{
							if ( cPT_ammo > cPT_weap_ammo_add )
							{
								cPT_player_data[id][CPT_SHOTGUN_BULLTES_STOLEN] += cPT_weap_ammo_add
							}else
							{
								if ( cPT_ammo > 1 )
									cPT_player_data[id][CPT_SHOTGUN_BULLTES_STOLEN] += cPT_ammo - 1
								
								cPT_player_data[id][CPT_SHOTGUN_BULLTES_TO_STEAL] += cPT_weap_ammo_add - cPT_player_data[id][CPT_SHOTGUN_BULLTES_STOLEN]
							}
							
							if ( ( cPT_weap_ammo_add + weapon_resup_ammo[SF_weaponid] ) - cPT_ammo > 5 )
							{
								cPT_player_data[id][CPT_SHOTGUN_BULLTES_TO_STEAL] += 1;
								cPT_player_data[id][CPT_SHOTGUN_BULLTES_TO_STEAL_2] += 1;
							}
							
							// remove bullets from clip and add it to reserve
							set_weapon_clip(cPT_weapon_entid, -cPT_player_data[id][CPT_SHOTGUN_BULLTES_STOLEN])
						}
						
						player_data[id][AA_RELOAD_WEAPANIM_TIME] += ( 1.2
												+ ( ( cPT_player_data[id][CPT_SHOTGUN_BULLTES_STOLEN] + cPT_player_data[id][CPT_SHOTGUN_BULLTES_TO_STEAL] + ( weapon_resup_ammo[SF_weaponid] - cPT_ammo ) ) * 1.0 )
												+ 1.2 )
					}
					case WEAPON_HMG:
					{
						player_data[id][AA_RELOAD_WEAPANIM_TIME] += 7.0
					}
					case WEAPON_GRENADE_GUN:
					{
						player_data[id][AA_RELOAD_WEAPANIM_TIME] += ( 2.2 + ( ( cPT_player_weaponanim - 3 ) * 1.1 ) + ( cPT_weap_ammo_add * 1.1 ) - player_data[id][AA_GL_RELOTIME_REDUCER] )		// 1 grenade => cPT_player_weaponanim = 4
					}
				}
			}
		}
		
		// check if player's weapon is shotgun
		if ( SF_weaponid == WEAPON_SHOTGUN )
		{
			// check if player started attacking with shotgun
			if ( ( cPT_player_button & IN_ATTACK )
				&& cPT_ammo > 0 )
			{
				reset_advammo_vars(id)
				
				player_data[id][AA_RELOAD_WEAPANIM_TIME] = _:SF_gametime
				
				set_pev(id, pev_weaponanim, 0)
				
				return
			// we reloaded shotgun to max OR reserve ammo is empty
			}else if ( cPT_ammo == weapon_resup_ammo[WEAPON_SHOTGUN] )
			{
				set_pev(id, pev_weaponanim, 4)
				
				// reload is done so far, reset all unneeded vars
				reset_advammo_vars(id)
				
			// shotgun is still reloading
			}else if ( cPT_player_data[id][CPT_RELOADING_CUR_WEAP] )
			{
				// check if we reached MAX DEFAULT AMMO - 1 and if we still have bullets to steal
				// steal bullets if needed
				if ( cPT_ammo == weapon_resup_ammo[SF_weaponid] - 1
					&& cPT_player_data[id][CPT_SHOTGUN_BULLTES_TO_STEAL] >= 1
					&& cPT_reserve_ammo > 0 )
				{
					if ( cPT_ammo > cPT_player_data[id][CPT_SHOTGUN_BULLTES_TO_STEAL] )
						cPT_temp_ammo = cPT_player_data[id][CPT_SHOTGUN_BULLTES_TO_STEAL]
					else
						cPT_temp_ammo = cPT_ammo - 1
					
					// remove bullets from clip and add it to reserve
					cPT_player_data[id][CPT_SHOTGUN_BULLTES_STOLEN] += cPT_temp_ammo
					cPT_player_data[id][CPT_SHOTGUN_BULLTES_TO_STEAL] -= cPT_temp_ammo
					set_weapon_clip(cPT_weapon_entid, -cPT_temp_ammo)
				}
			}
		}else if ( cPT_player_data[id][CPT_RELOADING_CUR_WEAP] )
		{
			// when player has more ammo than normal and reloads, it will be set back to normal and rest is added to reserve
			// so trick our method to think we got ammo and NOT lost some (by switching current reserve and old reserve)
			if ( cPT_ammo < cPT_player_data[id][CPT_AMMO_BEFORE_RELOAD] )
			{
				cPT_player_data[id][CPT_BULLTES_STOLEN] += ( cPT_player_data[id][CPT_AMMO_BEFORE_RELOAD] - cPT_ammo )
				cPT_temp_ammo = cPT_player_data[id][CPT_RESERVE_BEFORE_RELOAD]
				cPT_player_data[id][CPT_RESERVE_BEFORE_RELOAD] = cPT_reserve_ammo
				cPT_reserve_ammo = cPT_temp_ammo
			}
			
			// if ammo is = basic max ammo ( +1 is a fix) AND weapon is not reloading
			// then NS has reloaded that weapon
			if ( ( cPT_ammo == weapon_resup_ammo[SF_weaponid]
					|| cPT_ammo + 1 == weapon_resup_ammo[SF_weaponid] )
				&& !cPT_weapon_is_reloading )
			{
				// check if player has ammo left in reserve and add Advanced Ammopack if so
				if ( cPT_reserve_ammo > 0)
				{
					// check if trying to remove more ammo than player has
					if ( cPT_reserve_ammo < cPT_weap_ammo_add )
						cPT_weap_ammo_add = cPT_reserve_ammo
					
					set_weapon_clip(cPT_weapon_entid, cPT_weap_ammo_add)
					set_weapon_reserve(id, SF_weaponid, -cPT_weap_ammo_add)
					
					// GL is reloading grenade by grenade
					// and animation is not syncronized with actual reload
					// so block fire by setting time when player is able to shoot again
					if ( SF_weaponid == WEAPON_GRENADE_GUN )
						set_pdata_float(id, WEAPRELOTIME_OFF, get_pdata_float(id, WEAPRELOTIME_OFF, WEAPRELOTIME_OFF_LIN) + ( cPT_weap_ammo_add * 1.1 ) - player_data[id][AA_GL_RELOTIME_REDUCER], WEAPRELOTIME_OFF_LIN)
				}
				
				// reload is done so far, reset all unneeded vars
				reset_advammo_vars(id)
			}
		}
	}
	
	if ( SF_gametime > player_data[id][AA_RELOAD_WEAPANIM_TIME] )
	{
		set_pev(id, pev_weaponanim, 0)
		player_data[id][AA_GL_RELOTIME_REDUCER] = _:0.0
	}
}

upgrade_staticfield( )
{
	player_data[SF_id][STATICFIELD_TIME] = _:SF_gametime
	
	// init range + ( levelrange * rangelevelmultiplier )
	SF_staticrange = float(STATICFIELDINITIALRANGE + ( STATICFIELDLEVELRANGE * player_data[SF_id][UP_STATICFIELD] ))
	new static_sound = 0
	for ( SF_targetid = 1; SF_targetid <= g_maxPlayers; ++SF_targetid )
	{
		if( !is_user_connected(SF_targetid) )
			continue
			
		if ( !is_user_alive(SF_targetid) )
			continue
		
		if ( pev(SF_targetid, pev_team) == pev(SF_id, pev_team) )
			continue
		
		if ( entity_range(SF_id, SF_targetid) > SF_staticrange )
			continue
		
		if ( player_data[SF_targetid][TEAM] != MARINE
				&& ( player_data[SF_targetid][TEAM] != ALIEN
					|| get_pdata_float(SF_targetid, CLOAK_OFF, CLOAK_OFF_LIN) <= 0.5	// CLOAK_OFF = 0 means aliens is invisible/cloaked
					|| player_data[SF_targetid][ES_SHIFTING] ) )
			continue
		
		pev(SF_targetid, pev_health, SF_cur_health)
		// add Hunger into calculation
		// hunger can add HP over max but adding does not mean that maxHP is changed too
		if ( SF_cur_health > player_data[SF_targetid][TS_HEALTH_VALUES][TS_MAX_HP] )
			SF_max_health = SF_cur_health
		else
			SF_max_health = player_data[SF_targetid][TS_HEALTH_VALUES][TS_MAX_HP]
		SF_max_health = player_data[SF_targetid][TS_HEALTH_VALUES][TS_MAX_HP]
		pev(SF_targetid, pev_armorvalue, SF_cur_armor)
		SF_max_armor = player_data[SF_targetid][TS_HEALTH_VALUES][TS_MAX_AP]
		
		SF_statichealth = SF_max_health / 100.0 * SF_static_percent[SF_id]
		SF_staticarmor = SF_max_armor / 100.0 * SF_static_percent[SF_id]
		
		if ( SF_cur_health > SF_statichealth )
		{
			if ( SF_statichealth < 1.0 )
				SF_statichealth = 1.0
			
			set_pev(SF_targetid, pev_health, SF_statichealth)
			static_sound = 1
		}
		if ( SF_cur_armor > SF_staticarmor )
		{
			if ( SF_staticarmor < 1.0 )
				SF_staticarmor = 1.0
			
			set_pev(SF_targetid, pev_armorvalue, SF_staticarmor)
			static_sound = 1
		}
	}
	
	if ( static_sound )
		emit_sound(SF_id, CHAN_ITEM, sound_files[sound_elecspark], 0.5, ATTN_NORM, 0, PITCH_NORM)
}

upgrade_thickenedskin( id , Float:gametime )
{
	if ( gametime - player_data[id][TS_LASTREGEN] < 2.0 )
		return
	
	player_data[id][TS_LASTREGEN] = _:gametime
	new Float:healthvalue
	pev(id, pev_health, healthvalue)
	new Float:healthmax = player_data[id][TS_HEALTH_VALUES][TS_MAX_HP]
	if ( healthvalue < player_data[id][TS_HEALTH_VALUES][TS_BASE_HP] || healthvalue >= healthmax )
		return
	
	new Float:newhealthvalue = healthvalue + player_data[id][TS_HEALTH_VALUES][TS_HP_REGEN]
	if ( newhealthvalue > healthmax )
		newhealthvalue = healthmax
	if ( newhealthvalue > 999.0 )
		newhealthvalue = 999.0
	
	if ( !ns_get_mask(id, MASK_SILENCE) )
		emit_sound(id, CHAN_ITEM, sound_files[sound_regen], 0.5, ATTN_NORM, 0, PITCH_NORM)
	
	set_pev(id, pev_health, newhealthvalue)
}

upgrade_metabolize_hive_heal( )
{
	player_data[SF_id][TS_HEALTH_TIME] = _:SF_gametime
	
	pev(SF_id, pev_health, SF_cur_health)
	SF_max_health = player_data[SF_id][TS_HEALTH_VALUES][TS_MAX_HP]
	if ( player_data[SF_id][TS_HEALTH_VALUES][TS_BASE_HP] > SF_cur_health
		|| SF_cur_health >= SF_max_health )
		return
	
	new health_sound
	if ( SF_weaponid == WEAPON_METABOLIZE
		&& SF_player_attacking
		&& SF_gametime - player_data[SF_id][TS_LASTMETABOLIZEREGEN] >= 1.5 )
	{
		player_data[SF_id][TS_LASTMETABOLIZEREGEN] = _:SF_gametime
		SF_cur_health += METABOLIZE_HEAL_RATE
		health_sound = random(3) + 1
	}
	if ( SF_gametime - player_data[SF_id][TS_LASTHIVEREGEN] >= 1.0 )
	{
		player_data[SF_id][TS_LASTHIVEREGEN] = _:SF_gametime
		if ( ( pev(SF_id, pev_team) == pev(Hive_ID, pev_team)
				&& entity_range(SF_id, Hive_ID) <= HIVE_RANGE )
			|| ( pev(SF_id, pev_team) == pev(Hive_ID2, pev_team)
				&& entity_range(SF_id, Hive_ID2) <= HIVE_RANGE ) )
		{
			SF_cur_health += player_data[SF_id][TS_HEALTH_VALUES][TS_HIVEREGEN]
			if ( !health_sound )
				health_sound = sound_regen
		}
	}
	
	if ( !health_sound )
		return
	
	if ( SF_cur_health > SF_max_health )
		SF_cur_health = SF_max_health
	
	set_pev(SF_id, pev_health, SF_cur_health)
	if ( !ns_get_mask(SF_id, MASK_SILENCE) )
		emit_sound(SF_id, CHAN_ITEM, sound_files[health_sound], 0.5, ATTN_NORM, 0, PITCH_NORM)
}

upgrade_unshift( )
{
	set_pev(SF_id, pev_rendermode, 0)
	ns_set_mask(SF_id, MASK_CLOAKING, 1)
	if ( !ns_get_mask(SF_id, MASK_SILENCE) )
		emit_sound(SF_id, CHAN_ITEM, sound_files[sound_cloakend], 0.5, ATTN_NORM, 0, PITCH_NORM)
	
	player_data[SF_id][ES_SHIFTING] = 0
	
	// update HUD
	reset_hud(SF_id)
	show_hud_msg(SF_id, SF_id, player_data[SF_id][LASTXP], player_data[SF_id][CUR_LEVEL], 0, SF_gametime)
}

upgrade_bloodlust( )
{
	if ( SF_class == CLASS_ONOS )
		SF_energy += ( BLOODLUSTSPEED * player_data[SF_id][UP_BLOODLUST] / 3 )
	else
		SF_energy += ( BLOODLUSTSPEED * player_data[SF_id][UP_BLOODLUST] )
	
	if ( SF_energy > 1000.0 )
		SF_energy = 1000.0
	
	set_pev(SF_id, pev_fuser3, SF_energy)
	player_data[SF_id][LASTBLOODLUST] = _:SF_gametime
	SF_got_bloodlust_bonus = 1
}

upgrade_hunger( )
{
	SF_frags = get_user_frags(SF_id)
	if ( player_data[SF_id][H_JUSTKILLED] )		// keep this mask ON untill hungertime runs out
		ns_set_mask(SF_id, MASK_PRIMALSCREAM, 1)
	
	SF_max_health = player_data[SF_id][TS_HEALTH_VALUES][TS_MAX_HP]
	if ( SF_frags > player_data[SF_id][H_LASTFRAGCHECK] )
	{
		emit_sound(SF_id, CHAN_ITEM, sound_files[sound_primalscream], 0.5, ATTN_NORM, 0, PITCH_NORM)
		player_data[SF_id][H_JUSTKILLED] = 1
		player_data[SF_id][H_DURRATION] = _:( SF_gametime + HUNGERINITIALTIME + ( HUNGERLEVELTIME * player_data[SF_id][UP_HUNGER] ) )
		
		SF_hunger_healthadd[SF_id] = SF_max_health / 100.0 * HUNGERHEALTH
		pev(SF_id, pev_health, SF_cur_health)
		
		set_pev(SF_id, pev_health, SF_cur_health + SF_hunger_healthadd[SF_id])
		player_data[SF_id][H_LASTFRAGCHECK] = SF_frags
		ns_set_speedchange(SF_id, ns_get_speedchange(SF_id) + HUNGERSPEED)
	}else if ( SF_gametime >= player_data[SF_id][H_DURRATION]
		&& player_data[SF_id][H_JUSTKILLED] )
	{
		if ( entity_get_float(SF_id, EV_FL_health) > SF_max_health )
			set_pev(SF_id, pev_health, SF_max_health)
		
		emit_sound(SF_id, CHAN_ITEM, sound_files[sound_chargekill], 0.5, ATTN_NORM, 0, PITCH_NORM)
		ns_set_speedchange(SF_id, 0)
		player_data[SF_id][H_JUSTKILLED] = 0
		SF_hunger_healthadd[SF_id] = 0.0
	}
}

upgrade_acidicvengeance( victim )
{
	new Float:origin[3]
	pev(victim, pev_origin, origin)
	
	new victim_team = pev(victim, pev_team)
	new victim_class = ns_get_class(victim)
	if ( victim_class == CLASS_GESTATE )
		victim_class = CLASS_GORGE
	
	emit_sound(victim, CHAN_ITEM, sound_files[xenocide_explode], 1.0, ATTN_NORM, 0, PITCH_NORM)
	playback_event(0, victim, particle_event, 0.0, origin, Float:{0.0, 0.0, 0.0}, 0.0, 0.0, Xenocide_particle_id, 0, 0, 0)
	playback_event(0, victim, particle_event, 0.0, origin, Float:{0.0, 0.0, 0.0}, 0.0, 0.0, AcidHit_particle_id, 0, 0, 0)
	playback_event(0, victim, particle_event, 0.0, origin, Float:{0.0, 0.0, 0.0}, 0.0, 0.0, BileBomb_particle_id, 0, 0, 0)
	
	new Float:health_armor
	new AV_class
	new Float:AV_lvl = float(player_data[victim][UP_ACIDIC_VENGEANCE])
	new Float:AV_health_damage
	new Float:AV_armor_damage
	for ( new id = 1; id <= g_maxPlayers; ++id )
	{
		if ( id == victim )
			continue
		
		if ( !is_user_connected(id) )
			continue
		
		if ( !player_data[id][TEAM] )
			continue
		
		if ( !is_user_alive(id) )
			continue
		
		if ( victim_team == pev(id, pev_team) )
			continue
		
		if ( entity_range(id, victim) > ( 100.0 + victim_class * 50.0 ) )
			continue
		
		AV_class = ns_get_class(id)
		if ( AV_class == CLASS_HEAVY
			|| AV_class == CLASS_ONOS
			|| AV_class == CLASS_FADE )
		{
			AV_health_damage = AV_HA_HP * AV_lvl
			AV_armor_damage = AV_HA_AP * AV_lvl
		}else
		{
			AV_health_damage = AV_MA_HP * AV_lvl
			AV_armor_damage = AV_MA_AP * AV_lvl
		}
		
		// this check is done before: victim_class == CLASS_GESTATE
		if ( victim_class == CLASS_GORGE )
		{
			AV_health_damage *= AV_GORGE_GEST_MULTI
			AV_armor_damage *= AV_GORGE_GEST_MULTI
		}
		
		pev(id, pev_health, health_armor)
		health_armor -= AV_health_damage
		
		if ( health_armor < 1.0 )
		{
			kill_player(id, victim, "nuke")
		}else
		{
			set_pev(id, pev_health, health_armor)
			
			pev(id, pev_armorvalue, health_armor)
			health_armor -= AV_armor_damage
			if ( health_armor < 0.0 )
				health_armor = 0.0
			set_pev(id, pev_armorvalue, health_armor)
		}
	}
}

upgrade_soa_parasite( id , Float:gametime )
{
	switch ( player_data[id][SOA_FRESH_PARASITE] )
	{
		case 1:
		{
			if ( ns_get_mask(id, MASK_PARASITED) )
			{
				player_data[id][SOA_FRESH_PARASITE] = 2
				player_data[id][SOA_INFECTED_BY_MARINE] = 0
				player_data[id][SOA_PARASITE_TIME] = _:gametime
			}
			
		}
		case 2..4:
		{
			if ( player_data[id][SOA_FRESH_PARASITE] == 4 )
				reset_hud(id)
			
			if ( gametime - player_data[id][SOA_PARASITE_TIME] < 1.0 )
				return
			
			new player_chance, chance_mode
			player_data[id][SOA_PARASITE_TIME] = _:gametime
			chance_mode = player_data[player_data[id][SOA_MY_PARASITER]][SOA_PARASITE_CHANCE]
			
			if ( chance_mode > MAX_PARASITE_CHANCE )
				chance_mode = MAX_PARASITE_CHANCE
			
			new team = pev(id, pev_team)
			for ( new player = 1; player <= g_maxPlayers; ++player )
			{
				if ( player == id )
					continue
				
				if ( !is_user_connected(player) )
					continue
				
				player_chance = random(100)
				for ( CoreT_j = 0; CoreT_j < chance_mode; ++CoreT_j )
				{
					if ( rand_para_chance[CoreT_j] != player_chance )
						continue
					
					if ( pev(player, pev_team) != team
						|| !is_user_alive(player)
						|| entity_range(player, id) > SOA_PARASITE_RANGE )
						continue
					
					ns_set_mask(player, MASK_PARASITED, 1)
					player_data[player][SOA_FRESH_PARASITE] = 5
					player_data[player][SOA_INFECTED_BY_MARINE] = id
					
					break
				}
			}
			
			++player_data[id][SOA_FRESH_PARASITE]
		}
	}
}

upgrade_soa_fade( )
{
	if ( SF_weaponid == WEAPON_BLINK )
	{
		if ( SF_player_attacking && !player_data[SF_id][SOA_FADE_BLINKED] )
		{
			player_data[SF_id][SOA_FADE_BLINKED] = 1
		}else if ( player_data[SF_id][SOA_FADE_BLINKED] )
		{
			if ( SF_got_bloodlust_bonus )
			{
				SF_energy_bonus_from_bl = SF_energy - ( BLOODLUSTSPEED * player_data[SF_id][UP_BLOODLUST] )
				SF_energy_lost_with_blink = player_data[SF_id][SOA_FADE_ENERGY] - SF_energy_bonus_from_bl
			}else
				SF_energy_lost_with_blink = player_data[SF_id][SOA_FADE_ENERGY] - SF_energy
			
			SF_energy += SF_energy_lost_with_blink / 100 * ( SOA_BLINK_ENERGY_BONUS * player_data[SF_id][UP_SENSE_OF_ANCIENTS] )
			set_pev(SF_id, pev_fuser3, SF_energy)
			player_data[SF_id][SOA_FADE_BLINKED] = 0
		}
	}
	player_data[SF_id][SOA_FADE_ENERGY] = _:SF_energy
}

upgrade_soa_digesting_player( )
{
	if ( SF_id == player_data[SF_my_digester][SOA_CURRENTLY_DIGESTING] )
		return
	
	pev(SF_my_digester, pev_origin, SF_onos_devour_origin)
	entity_set_origin(SF_id, SF_onos_devour_origin)
	set_pev(SF_id, pev_viewmodel, engfunc(EngFunc_AllocString, ""))
	set_pev(SF_id, pev_weaponmodel, engfunc(EngFunc_AllocString, ""))
	
	if ( SF_gametime - player_data[SF_id][SOA_DIGEST_TIME] < 1.0 )
		return
	
	pev(SF_id, pev_health, SF_cur_health)
	pev(SF_my_digester, pev_health, SF_onos_hp)
	pev(SF_my_digester, pev_armorvalue, SF_onos_ap)
	SF_carapace_bonus = ( ns_get_mask(SF_my_digester, MASK_CARAPACE) ) ? 350 : 0
	if ( SF_onos_hp < SOA_ONOS_BASE_HP )
	{
		if ( SF_onos_hp + SOA_ONOS_HP_ADD <= player_data[SF_my_digester][TS_HEALTH_VALUES][TS_MAX_HP] )
			set_pev(SF_my_digester, pev_health, SF_onos_hp + SOA_ONOS_HP_ADD)
		else
			set_pev(SF_my_digester, pev_health, player_data[SF_my_digester][TS_HEALTH_VALUES][TS_MAX_HP])
	}else if ( SF_onos_ap < ( SOA_ONOS_BASE_AP + SF_carapace_bonus ) )
	{
		if ( SF_onos_ap + SOA_ONOS_HP_ADD <= ( SOA_ONOS_BASE_AP + SF_carapace_bonus ) )
			set_pev(SF_my_digester, pev_armorvalue, SF_onos_ap + SOA_ONOS_HP_ADD)
		else
			set_pev(SF_my_digester, pev_armorvalue, SOA_ONOS_BASE_AP + float(SF_carapace_bonus))
	}
	
	if ( SF_cur_health - SOA_ONOS_HP_REDUCER < 1.0 )
	{
		kill_player(SF_id, SF_my_digester, "devour")
		reset_devour_vars(SF_id)
	}else
		set_pev(SF_id, pev_health, SF_cur_health - SOA_ONOS_HP_REDUCER)
	
	player_data[SF_id][SOA_DIGEST_TIME] = _:SF_gametime
}

upgrade_soa_onos( )
{
	if ( !player_data[SF_id][UP_SENSE_OF_ANCIENTS] )
		return
	
	if ( ns_get_mask(SF_id, MASK_DIGESTING) )
	{
		if ( !player_data[SF_id][SOA_JUST_DEVOURED] )
		{
			player_data[SF_id][SOA_JUST_DEVOURED] = 1
			player_data[SF_id][SOA_NEXTDEVOUR_TIME] = _:SF_gametime
			++player_data[SF_id][SOA_DEVOURING_PLAYERS_NUM]
		}else if ( SF_gametime - player_data[SF_id][SOA_NEXTDEVOUR_TIME] > player_data[SF_id][SOA_DEVOUR_TIME]
			&& player_data[SF_id][SOA_DEVOURING_PLAYERS_NUM] < player_data[SF_id][SOA_MAX_DEVOUR_AMOUNT] + 1 )
		{
			ns_set_mask(SF_id, MASK_DIGESTING, 0)
			player_data[SF_id][SOA_NEXTDEVOUR_TIME] = _:SF_gametime
			player_data[SF_id][SOA_JUST_DEVOURED] = 0
		}
	}else
		player_data[SF_id][SOA_JUST_DEVOURED] = 0
}

upgrade_soa_find_digester( )
{
	if ( SF_my_digester != 0
		|| !ns_get_mask(SF_id, MASK_DIGESTING)		// check if being digested
		|| !(pev(SF_id, pev_effects) & EF_NODRAW) )	// check if player is really being digested or only being another class and devouring someone else
		return
	
	SF_my_digester = get_my_onos(SF_id)
	if ( !player_data[SF_my_digester][UP_SENSE_OF_ANCIENTS] )
		return
	
	player_data[SF_id][SOA_MY_DIGESTER] = SF_my_digester
	player_data[SF_my_digester][SOA_CURRENTLY_DIGESTING] = SF_id
}

calc_lvl_and_xp( id )
{
	new Float:xp = ns_get_exp(id)
	
#if USE_CONFIG_FILE == 0
  #if CUSTOM_LEVELS == 0
	player_data[id][CUR_LEVEL] = floatround(floatsqroot(xp / 25 + 2.21) - 1)
	player_data[id][BASE_LEVEL_XP] = ( player_data[id][CUR_LEVEL] + 2) * ( player_data[id][CUR_LEVEL] - 1) * 25 + 1
	player_data[id][XP_TO_NEXT_LVL] = ( player_data[id][CUR_LEVEL] + 1 )* 50
  #else
	if ( xp < 2701.0 )
	{	// player is below lvl 10
		player_data[id][CUR_LEVEL] = floatround(floatsqroot(xp / 25 + 2.21) - 1)
		player_data[id][BASE_LEVEL_XP] = ( player_data[id][CUR_LEVEL] + 2) * ( player_data[id][CUR_LEVEL] - 1) * 25 + 1
		player_data[id][XP_TO_NEXT_LVL] = ( player_data[id][CUR_LEVEL] + 1 )* 50
	}else if ( xp < 2701.0 + BASE_XP_TO_NEXT_LEVEL + NEXT_LEVEL_XP_MODIFIER )
	{	// activate custom level XP
		player_data[id][CUR_LEVEL] = BASE_MAX_LEVEL
		player_data[id][BASE_LEVEL_XP] = 2701
		player_data[id][XP_TO_NEXT_LVL] = BASE_XP_TO_NEXT_LEVEL + NEXT_LEVEL_XP_MODIFIER
	}else
	{
		/*
		// no optimized code
		player_data[id][CUR_LEVEL] = 10 + floatround( ( floatsqroot( ( xp - 2701.0 ) * 2.0 + NEXT_LEVEL_XP_MODIFIER_x2 * NEXT_LEVEL_XP_MODIFIER_x2 ) - NEXT_LEVEL_XP_MODIFIER_x2 ) / floatsqroot(float(NEXT_LEVEL_XP_MODIFIER)) )
		player_data[id][BASE_LEVEL_XP] = 2701
					+ ( 2 * ( player_data[id][CUR_LEVEL] - 10 ) * BASE_XP_TO_NEXT_LEVEL
					+ NEXT_LEVEL_XP_MODIFIER * ( ( player_data[id][CUR_LEVEL] - 10 ) * ( player_data[id][CUR_LEVEL] - 10 )
									+ ( player_data[id][CUR_LEVEL] - 10 ) ) )
						/ 2
		player_data[id][XP_TO_NEXT_LVL] = ( player_data[id][CUR_LEVEL] - 9 ) * NEXT_LEVEL_XP_MODIFIER
		*/
		
		player_data[id][CUR_LEVEL] = floatround( ( floatsqroot( ( xp - 2701.0 ) * 2.0 + NEXT_LEVEL_XP_MODIFIER_x2 * NEXT_LEVEL_XP_MODIFIER_x2 ) - NEXT_LEVEL_XP_MODIFIER_x2 ) / floatsqroot(float(NEXT_LEVEL_XP_MODIFIER)) )
		player_data[id][BASE_LEVEL_XP] = 2701
					+ ( 2 * player_data[id][CUR_LEVEL] * BASE_XP_TO_NEXT_LEVEL
					+ NEXT_LEVEL_XP_MODIFIER * ( player_data[id][CUR_LEVEL] * player_data[id][CUR_LEVEL]
									+ player_data[id][CUR_LEVEL] ) )
						/ 2
		player_data[id][XP_TO_NEXT_LVL] = ( player_data[id][CUR_LEVEL] + 1 ) * NEXT_LEVEL_XP_MODIFIER
		
		player_data[id][CUR_LEVEL] += BASE_MAX_LEVEL
	}
  #endif
#else
	if ( CUSTOM_LEVELS == 0 )
	{
		player_data[id][CUR_LEVEL] = floatround(floatsqroot(xp / 25 + 2.21) - 1)
		player_data[id][BASE_LEVEL_XP] = ( player_data[id][CUR_LEVEL] + 2) * ( player_data[id][CUR_LEVEL] - 1) * 25 + 1
		player_data[id][XP_TO_NEXT_LVL] = ( player_data[id][CUR_LEVEL] + 1 )* 50
	}else
	{
		if ( xp < 2701.0 )
		{	// player is below lvl 10
			player_data[id][CUR_LEVEL] = floatround(floatsqroot(xp / 25 + 2.21) - 1)
			player_data[id][BASE_LEVEL_XP] = ( player_data[id][CUR_LEVEL] + 2) * ( player_data[id][CUR_LEVEL] - 1) * 25 + 1
			player_data[id][XP_TO_NEXT_LVL] = ( player_data[id][CUR_LEVEL] + 1 )* 50
		}else if ( xp < 2701.0 + NEXT_LEVEL_XP_MODIFIER )
		{	// activate custom level XP
			player_data[id][CUR_LEVEL] = BASE_MAX_LEVEL
			player_data[id][BASE_LEVEL_XP] = 2701
			player_data[id][XP_TO_NEXT_LVL] = NEXT_LEVEL_XP_MODIFIER
		}else
		{
			player_data[id][CUR_LEVEL] = floatround( ( floatsqroot( ( xp - 2701.0 ) * 2.0 + NEXT_LEVEL_XP_MODIFIER_x2 * NEXT_LEVEL_XP_MODIFIER_x2 ) - NEXT_LEVEL_XP_MODIFIER_x2 ) / floatsqroot(float(NEXT_LEVEL_XP_MODIFIER)) )
			player_data[id][BASE_LEVEL_XP] = 2701
						+ ( 2 * player_data[id][CUR_LEVEL] * BASE_XP_TO_NEXT_LEVEL
						+ NEXT_LEVEL_XP_MODIFIER * ( player_data[id][CUR_LEVEL] * player_data[id][CUR_LEVEL]
										+ player_data[id][CUR_LEVEL] ) )
							/ 2
			player_data[id][XP_TO_NEXT_LVL] = ( player_data[id][CUR_LEVEL] + 1 ) * NEXT_LEVEL_XP_MODIFIER
			
			player_data[id][CUR_LEVEL] += BASE_MAX_LEVEL
		}
	}
#endif
	
	return floatround(xp)
}

reset_upgrades_vars( id , ingame = 0 )
{
	player_data[id][TEAM] = 0
	
	player_data[id][EXTRALEVELS] = 0
	player_data[id][POINTS_AVAILABLE] = 0
	player_data[id][LASTXP] = 0
	
	player_data[id][UPGRADE_CHOICE] = -1
	
	player_data[id][UP_CYBERNETICS] = 0
	
	player_data[id][UP_REINFORCEARMOR] = 0
	
	player_data[id][UP_NANOARMOR] = 0
	
	player_data[id][UP_ADVAMMOPACK] = 0
	
	player_data[id][GOT_RESUPPLY] = 0
	player_data[id][GOT_SCAN] = 0
	
	cPT_player_data[id][CPT_WEAPON_IDS][0] = 0
	cPT_player_data[id][CPT_WEAPON_IDS][1] = 0
	cPT_player_data[id][CPT_WEAPON_IDS][2] = 0
	cPT_player_data[id][CPT_WEAPON_IDS][3] = 0
	player_data[id][AA_UPLVL_GOT_FREEAMMO] = 0
	
	player_data[id][UP_STATICFIELD] = 0
	
	player_data[id][UP_URANUIMAMMO] = 0
	player_data[id][WEAPON_IMPULSE_DATA][1] = 0
	player_data[id][WEAPON_IMPULSE_DATA][2] = 0
	player_data[id][WEAPON_IMPULSE_DATA][3] = 0
	player_data[id][WEAPON_IMPULSE_DATA][4] = 0
	
	player_data[id][UP_THICKENED_SKIN] = 0
	player_data[id][TS_HEALTH_VALUES][0] = _:0.0
	player_data[id][TS_HEALTH_VALUES][1] = _:0.0
	player_data[id][TS_HEALTH_VALUES][2] = _:0.0
	player_data[id][TS_HEALTH_VALUES][3] = _:0.0
	player_data[id][TS_HEALTH_VALUES][4] = _:0.0
	player_data[id][TS_HEALTH_VALUES][5] = _:0.0
	
	player_data[id][UP_ETHEREAL_SHIFT] = 0
	player_data[id][ES_SHIFTTIME] = _:0.0
	
	player_data[id][UP_BLOODLUST] = 0
	
	player_data[id][UP_HUNGER] = 0
	SF_hunger_healthadd[id] = 0.0
	player_data[id][H_LASTFRAGCHECK] = 0
	player_data[id][H_JUSTKILLED] = 0
	
	player_data[id][UP_ACIDIC_VENGEANCE] = 0
	
	player_data[id][UP_SENSE_OF_ANCIENTS] = 0
	player_data[id][SOA_PARASITE_CHANCE] = 0
	player_data[id][SOA_MY_PARASITER] = 0
	player_data[id][SOA_FADE_BLINKED] = 0
	player_data[id][SOA_FADE_ENERGY] = _:0.0
	player_data[id][SOA_DEVOUR_TIME_MULTIPLIER] = 1
	player_data[id][SOA_DEVOUR_TIME] = _:SOA_DEVOURTIME_INIT
	player_data[id][SOA_MAX_DEVOUR_AMOUNT] = 0
	player_data[id][SOA_REDEEMED] = 0
	
	reset_gestate_emu(id)
	reset_parasite_vars(id)
	reset_devour_vars(id)
	reset_advammo_vars(id)
	
	if ( !ingame )
	{
		player_data[id][AUTHORSSHOWN] = 0
		player_data[id][INFORMSSHOWN] = 0
		player_data[id][BANNED] = 0
	}
	
	player_data[id][NA_WELDING_SELF] = 0
	player_data[id][RA_WELDING_OVERMAX] = 0
	player_data[id][RA_WELDED_OVERMAX] = 0
	player_data[id][LASTLEVEL] = 0
	
	player_data[id][CUR_LEVEL] = 1		// you start with level 1
	player_data[id][XP_TO_NEXT_LVL] = 100	// level 2 is reached with 100 XP
	player_data[id][BASE_LEVEL_XP] = 0
	
	ns_set_speedchange(id, 0)
	
	emit_sound(id, CHAN_STREAM, sound_files[sound_welderidle], 0.0, ATTN_NORM, SND_STOP, PITCH_NORM)
}

reset_parasite_vars( id )
{
	player_data[id][SOA_FRESH_PARASITE] = 0
	player_data[id][SOA_INFECTED_BY_MARINE] = 0
}

reset_devour_vars( id )
{
	player_data[id][SOA_MY_DIGESTER] = 0
	player_data[id][SOA_DIGEST_TIME] = _:0.0
	player_data[id][SOA_DEVOURING_PLAYERS_NUM] = 0
}

reset_gestate_emu( id )
{
	player_gestating_emu[id] = 0
	player_gestating_emu_msg[id] = 0
	player_gestate_time_emu[id] = 0.0
	player_gestate_emu_class[id] = CLASS_SKULK
	player_gestate_extracheck[id] = 1
	player_gestate_hp[id] = 0.0
	player_gestate_ap[id] = 0.0
	player_gestate_hp_max[id] = 0.0
	player_gestate_ap_max[id] = 0.0
	player_gestate_health_lost[id] = 0.0
	player_gestate_armor_lost[id] = 0.0
	
	player_gestate_died_during_gest[id] = 0
}

reset_advammo_vars( id )
{
	if ( cPT_player_data[id][CPT_RELOADING_CUR_WEAP] == WEAPON_SHOTGUN )
	{
		if ( is_valid_ent(cPT_player_data[id][CPT_WEAPON_IDS][1]) )
		{
			set_weapon_clip(cPT_player_data[id][CPT_WEAPON_IDS][1], cPT_player_data[id][CPT_SHOTGUN_BULLTES_STOLEN] + cPT_player_data[id][CPT_SHOTGUN_BULLTES_XTRA_STOLEN] - cPT_player_data[id][CPT_SHOTGUN_BULLTES_TO_STEAL_2])
			set_weapon_reserve(id, WEAPON_SHOTGUN, cPT_player_data[id][CPT_SHOTGUN_BULLTES_TO_STEAL_2])
		}
		
		cPT_player_data[id][CPT_SHOTGUN_BULLTES_STOLEN] = 0
		cPT_player_data[id][CPT_SHOTGUN_BULLTES_XTRA_STOLEN] = 0
	}
	
	cPT_player_data[id][CPT_SHOTGUN_BULLTES_TO_STEAL] = 0
	cPT_player_data[id][CPT_SHOTGUN_BULLTES_TO_STEAL_2] = 0
	cPT_player_data[id][CPT_BULLTES_STOLEN] = 0
	
	cPT_player_data[id][CPT_STARTED_TO_RELOAD] = 0
	cPT_player_data[id][CPT_RELOADING_CUR_WEAP] = 0
	cPT_player_data[id][CPT_AMMO_BEFORE_RELOAD] = 0
	cPT_player_data[id][CPT_RESERVE_BEFORE_RELOAD] = 0
	cPT_player_data[id][CPT_RESERVE_AMMO_CORRECTOR] = 0
}

reset_hud( id )
{
	set_hudmessage(0, 0, 0, -1.0, 0.89, 0, 0.0, 3600.0, 0.0, 0.0, HUD_CHANNEL)
	show_hudmessage(id, " ")
}

get_base_add_health( id )
{
	new class = ns_get_class(id)
	switch ( class )
	{
		case CLASS_SKULK:
		{
			player_data[id][TS_HEALTH_VALUES][TS_BASE_HP] = _:70.0
			player_data[id][TS_HEALTH_VALUES][TS_ADD_HP] = _:HEALTHSKULK
			player_data[id][TS_HEALTH_VALUES][TS_HIVEREGEN] = _:10.0
			player_data[id][TS_HEALTH_VALUES][TS_HP_REGEN] = _:6.0
			player_data[id][TS_HEALTH_VALUES][TS_MAX_AP] = _:( ns_get_mask(id, MASK_CARAPACE) ? 30.0 : 10.0 )
		}
		case CLASS_GORGE:
		{
			player_data[id][TS_HEALTH_VALUES][TS_BASE_HP] = _:150.0
			player_data[id][TS_HEALTH_VALUES][TS_ADD_HP] = _:HEALTHGORGE
			player_data[id][TS_HEALTH_VALUES][TS_HIVEREGEN] = _:22.0
			player_data[id][TS_HEALTH_VALUES][TS_HP_REGEN] = _:13.0
			player_data[id][TS_HEALTH_VALUES][TS_MAX_AP] = _:( ns_get_mask(id, MASK_CARAPACE) ? 120.0 : 70.0 )
		}
		case CLASS_LERK:
		{
			player_data[id][TS_HEALTH_VALUES][TS_BASE_HP] = _:125.0
			player_data[id][TS_HEALTH_VALUES][TS_ADD_HP] = _:HEALTHLERK
			player_data[id][TS_HEALTH_VALUES][TS_HIVEREGEN] = _:18.0
			player_data[id][TS_HEALTH_VALUES][TS_HP_REGEN] = _:11.0
			player_data[id][TS_HEALTH_VALUES][TS_MAX_AP] = _:( ns_get_mask(id, MASK_CARAPACE) ? 60.0 : 30.0 )
		}
		case CLASS_FADE:
		{
			player_data[id][TS_HEALTH_VALUES][TS_BASE_HP] = _:300.0
			player_data[id][TS_HEALTH_VALUES][TS_ADD_HP] = _:HEALTHFADE
			player_data[id][TS_HEALTH_VALUES][TS_HIVEREGEN] = _:54.0
			player_data[id][TS_HEALTH_VALUES][TS_HP_REGEN] = _:27.0
			player_data[id][TS_HEALTH_VALUES][TS_MAX_AP] = _:( ns_get_mask(id, MASK_CARAPACE) ? 250.0 : 150.0 )
		}
		case CLASS_ONOS:
		{
			player_data[id][TS_HEALTH_VALUES][TS_BASE_HP] = _:700.0
			player_data[id][TS_HEALTH_VALUES][TS_ADD_HP] = _:HEALTHONOS
			player_data[id][TS_HEALTH_VALUES][TS_HIVEREGEN] = _:105.0
			player_data[id][TS_HEALTH_VALUES][TS_HP_REGEN] = _:63.0
			player_data[id][TS_HEALTH_VALUES][TS_MAX_AP] = _:( ns_get_mask(id, MASK_CARAPACE) ? 950.0 : 600.0 )
		}
		case CLASS_GESTATE:
		{
			player_data[id][TS_HEALTH_VALUES][TS_BASE_HP] = _:200.0
			player_data[id][TS_HEALTH_VALUES][TS_ADD_HP] = _:HEALTHGESTATE
			player_data[id][TS_HEALTH_VALUES][TS_HIVEREGEN] = _:20.0
			player_data[id][TS_HEALTH_VALUES][TS_HP_REGEN] = _:18.0
			player_data[id][TS_HEALTH_VALUES][TS_MAX_AP] = _:150.0
		}
		default:
		{
			if ( class == CLASS_DEAD )
				player_data[id][TS_HEALTH_VALUES][TS_BASE_HP] = _:0.0
			else
				player_data[id][TS_HEALTH_VALUES][TS_BASE_HP] = _:100.0
			player_data[id][TS_HEALTH_VALUES][TS_ADD_HP] = _:0.0
			player_data[id][TS_HEALTH_VALUES][TS_HIVEREGEN] = _:0.0
			player_data[id][TS_HEALTH_VALUES][TS_HP_REGEN] = _:0.0
			player_data[id][TS_HEALTH_VALUES][TS_MAX_AP] = _:( class == CLASS_HEAVY ? ( 200.0 + check_armor_upgrade(id) * 30.0 ) : ( 30.0 + check_armor_upgrade(id) * 20.0 ) )
		}
	}
	
	player_data[id][TS_HEALTH_VALUES][TS_ADD_HP] *= player_data[id][UP_THICKENED_SKIN]
	
	player_data[id][TS_HEALTH_VALUES][TS_MAX_HP] = _:(player_data[id][TS_HEALTH_VALUES][TS_BASE_HP] + player_data[id][TS_HEALTH_VALUES][TS_ADD_HP])
}

Float:get_max_armor( id , &Float:armorvalue = 0.0 , &Float:max_basearmor = 0.0 )
{
	new Float:maxarmor
	new class = ns_get_class(id)
	pev(id, pev_armorvalue, armorvalue)
	if ( id == gnome_id[0] || id == gnome_id[1] )
	{
		max_basearmor = float(gnome_base_armor)
		maxarmor = float(gnome_max_armor)
	}else if ( class == CLASS_MARINE || class == CLASS_JETPACK )
	{
		max_basearmor = MAX_BASE_MARINE_AP
		maxarmor = ARMOR_MA * player_data[id][UP_REINFORCEARMOR] + max_basearmor
	}else if ( class == CLASS_HEAVY )
	{
		max_basearmor = MAX_BASE_HEAVY_AP
		maxarmor = ARMOR_HA * player_data[id][UP_REINFORCEARMOR] + max_basearmor
	}
	
	if ( maxarmor > 999.0 )
		maxarmor = 999.0
	
	return maxarmor
}

check_armor_upgrade( id )
{
	new iuser4 = pev(id, pev_iuser4)
	
	return ( iuser4 & MASK_ARMOR3 ) ? 3
		: ( ( iuser4 & MASK_ARMOR2 ) ? 2
		: ( ( iuser4 & MASK_ARMOR1 ) ? 1
		: 0 ) )
}

check_level_player( id )
{
	new xp = calc_lvl_and_xp(id)
	
	if ( !is_user_alive(id) )
		return xp
	
	if ( player_data[id][CUR_LEVEL] > get_pcvar_num(CVAR_maxlevel) <= player_data[id][EXTRALEVELS] + BASE_MAX_LEVEL )
		return xp
	
	new levelsspent = ns_get_points(id)
	
	// when gestated and respawn NS is giving points back, so do a support
	if ( levelsspent < 0 )
	{
		levelsspent += player_data[id][ALIEN_GESTATE_POINTS]
		ns_set_points(id, levelsspent)
		player_data[id][EXTRALEVELS] -= player_data[id][ALIEN_GESTATE_POINTS]	// tell extralevels points that we just got some points back
		player_data[id][ALIEN_GESTATE_POINTS] = 0
	}
	
	if ( 0 <= levelsspent < BASE_MAX_LEVEL )
	{
		player_data[id][POINTS_AVAILABLE] = player_data[id][CUR_LEVEL] - 1 - levelsspent
		if ( player_data[id][CUR_LEVEL] >= 11 )
			player_data[id][POINTS_AVAILABLE] -= ( player_data[id][CUR_LEVEL] - BASE_MAX_LEVEL )
		
		new extralevel = player_data[id][CUR_LEVEL] - BASE_MAX_LEVEL - player_data[id][EXTRALEVELS]
		
		new max_points = ( player_data[id][TEAM] == MARINE ) ? max_marine_points : ( player_data[id][TEAM] == ALIEN ) ? max_alien_points : 0
		if ( extralevel > 0 && player_data[id][EXTRALEVELS] + BASE_MAX_LEVEL < max_points )
		{
			new newlevelsspent = (  extralevel > levelsspent ) ? levelsspent : extralevel
			if ( newlevelsspent > levelsspent )
				newlevelsspent = levelsspent
			player_data[id][EXTRALEVELS] += newlevelsspent
			ns_set_points(id, levelsspent - newlevelsspent)
		}
	}
	
	return xp
}

set_weapon_damage_ammo( id , weapon_id = 0 , mode = 0 )
{
	new Float:bullet_amplifier = ( ( float(player_data[id][UP_URANUIMAMMO] * URANUIMAMMO_BULLET) / 100.0 ) + 1.0 )
	new Float:gren_amplifier = ( ( float(player_data[id][UP_URANUIMAMMO] * URANUIMAMMO_GREN) / 100.0 ) + 1.0 )
	new Float:parasite_amplifier = ( ( float(player_data[id][UP_SENSE_OF_ANCIENTS] * SOA_PARASITE_DMG) / 100.0 ) + 1.0 )
	new Float:healspray_amplifier = ( ( float(player_data[id][UP_SENSE_OF_ANCIENTS] * SOA_HEALSPRAY_DMG) / 100.0 ) + 1.0 )
	new Float:base_dmg, found, Float:amplyfier
	new ammo_to_add
	new classname[64]
	for ( new entid = g_maxPlayers + 1; entid <= max_entities; ++entid )
	{
		if ( !is_valid_ent(entid) )
			continue
		
		if ( pev(entid, pev_owner) != id )
			continue
		
		pev(entid, pev_classname, classname, 63)
		if ( weapon_id == 0 )
		{
			if ( player_data[id][TEAM] == MARINE )
			{
				if ( equal(classname, "weapon_pistol") )
				{
					base_dmg = BASE_DAMAGE_HG
					amplyfier = bullet_amplifier
					ammo_to_add = floatround(player_data[id][UP_ADVAMMOPACK] * ADVAMMOPACK_PISTOL, floatround_floor)
					found = WEAPON_PISTOL
				}else if ( equal(classname, "weapon_machinegun") )
				{
					base_dmg = BASE_DAMAGE_LMG
					amplyfier = bullet_amplifier
					ammo_to_add = floatround(player_data[id][UP_ADVAMMOPACK] * ADVAMMOPACK_LMG, floatround_floor)
					found = WEAPON_LMG
				}else if ( equal(classname, "weapon_heavymachinegun") )
				{
					base_dmg = BASE_DAMAGE_HMG
					amplyfier = bullet_amplifier
					ammo_to_add = floatround(player_data[id][UP_ADVAMMOPACK] * ADVAMMOPACK_HMG, floatround_floor)
					found = WEAPON_HMG
				}else if ( equal(classname, "weapon_shotgun") )
				{
					base_dmg = BASE_DAMAGE_SG
					amplyfier = bullet_amplifier
					ammo_to_add = floatround(player_data[id][UP_ADVAMMOPACK] * ADVAMMOPACK_SHOTGUN, floatround_floor)
					found = WEAPON_SHOTGUN
				}else if ( equal(classname, "weapon_grenadegun") )
				{
					base_dmg = BASE_DAMAGE_GL
					amplyfier = gren_amplifier
					ammo_to_add = floatround(player_data[id][UP_ADVAMMOPACK] * ADVAMMOPACK_GL, floatround_floor)
					found = WEAPON_GRENADE_GUN
				}else if ( equal(classname, "weapon_grenade") )
				{
					base_dmg = BASE_DAMAGE_GREN
					amplyfier = gren_amplifier
					found = WEAPON_GRENADE
				}
			}else
			{
				if ( equali(classname, "weapon_parasite") )
				{
					base_dmg = BASE_DAMAGE_PARA
					found = WEAPON_PARASITE
					amplyfier = parasite_amplifier
				}else if ( equal(classname, "weapon_healingspray") )
				{
					base_dmg = BASE_DAMAGE_HEAL
					found = WEAPON_HEALINGSPRAY
					amplyfier = healspray_amplifier
				}
			}
		}else
		{
			switch ( weapon_id )
			{
				case WEAPON_SHOTGUN:
				{
					if ( equal(classname, "weapon_shotgun") )
					{
						found = WEAPON_SHOTGUN
						base_dmg = BASE_DAMAGE_SG
						amplyfier = bullet_amplifier
						ammo_to_add = floatround(player_data[id][UP_ADVAMMOPACK] * ADVAMMOPACK_SHOTGUN, floatround_floor)
					}
				}
				case WEAPON_HMG:
				{
					if ( equal(classname, "weapon_heavymachinegun") )
					{
						found = WEAPON_HMG
						base_dmg = BASE_DAMAGE_HMG
						amplyfier = bullet_amplifier
						ammo_to_add = floatround(player_data[id][UP_ADVAMMOPACK] * ADVAMMOPACK_HMG, floatround_floor)
					}
				}
				case WEAPON_GRENADE_GUN:
				{
					if ( equal(classname, "weapon_grenadegun") )
					{
						found = WEAPON_GRENADE_GUN
						base_dmg = BASE_DAMAGE_GL
						amplyfier = gren_amplifier
						ammo_to_add = floatround(player_data[id][UP_ADVAMMOPACK] * ADVAMMOPACK_GL, floatround_floor)
					}
				}
				case WEAPON_GRENADE:
				{
					if ( equal(classname, "weapon_grenade") )
					{
						found = WEAPON_GRENADE
						base_dmg = BASE_DAMAGE_GREN
						amplyfier = gren_amplifier
					}
				}
			}
		}
		
		if ( !found )
			continue
		
		if ( id == gnome_id[0] || id == gnome_id[1] )
		{
			if ( !get_pcvar_num(CVAR_gnome_pickonly) )
				base_dmg *= get_pcvar_float(CVAR_gnome_damageadd)
		}
		if ( ( player_data[id][UP_URANUIMAMMO] || player_data[id][UP_SENSE_OF_ANCIENTS] ) && mode != 2 )
			ns_set_weap_dmg(entid, base_dmg * amplyfier)
		
		if ( player_data[id][UP_ADVAMMOPACK]
			&& mode != 1
			&& found != WEAPON_MINE
			&& found != WEAPON_GRENADE )
		{
			if ( found == WEAPON_PISTOL )
			{
				cPT_player_data[id][CPT_WEAPON_IDS][0] = entid
				cPT_player_data[id][CPT_WEAPON_IDS][2] = found
			}else
			{
				cPT_player_data[id][CPT_WEAPON_IDS][1] = entid
				cPT_player_data[id][CPT_WEAPON_IDS][3] = found
			}
			
			set_weapon_clip(entid , ammo_to_add)
			set_weapon_reserve(id, found, ammo_to_add * 2)
		}
		
		found = 0
	}
}

set_weapon_clip( weap_id , ammo_to_add )
{
	ns_set_weap_clip(weap_id, ns_get_weap_clip(weap_id) + ammo_to_add)
}

set_weapon_reserve( id , weapon_type , ammo_to_add )
{
	cPT_reserve_ammo = ns_get_weap_reserve(id, weapon_type) + ammo_to_add
	
	if ( cPT_reserve_ammo > 250 )
	{
		// need to set ammo in second server frame, so make in next frame positiv (saves a check variable)
		cPT_player_data[id][CPT_RESERVE_AMMO_CORRECTOR] += -cPT_reserve_ammo
		
		ns_set_weap_reserve(id, weapon_type, 250)
	}else
		ns_set_weap_reserve(id, weapon_type, cPT_reserve_ammo)
}

get_my_onos( victim_id )
{
	new Float:range = 1000.0
	new my_onos_id
	new Float:temp_range
	for ( new id = 1; id <= g_maxPlayers; ++id )
	{
		if ( !is_user_connected(id) )
			continue
		if ( ns_get_class(id) != CLASS_ONOS )
			continue
		
		if ( ( temp_range = entity_range(id, victim_id) ) >= range )
			continue
		
		range = temp_range
		my_onos_id = id
	}
	
	return my_onos_id
}

free_digested_players( onos_id )
{
	set_pdata_int(onos_id, DIGESTING_PLAYER_OFF, 0, DIGESTING_PLAYER_OFF_LIN)		// the ID of player the onos is digesting right now
	new Float:dummy_vector[3]
	new dummy_flags
	for ( new id = 1; id <= g_maxPlayers; ++id )
	{
		if ( player_data[id][SOA_MY_DIGESTER] != onos_id )
			continue
		if ( entity_get_float(id, EV_FL_health) < 1.0 )
			continue
		
		ns_set_mask(id, MASK_DIGESTING, 0)
		set_pev(id, pev_controller_2, 0)
		set_pev(id, pev_solid, 3)
		set_pev(id, pev_effects, 0)
		dummy_flags = pev(id, pev_flags) &~ FL_ONGROUND | FL_DUCKING
		set_pev(id, pev_flags, dummy_flags)
		set_pev(id, pev_weaponanim, 2)
		set_pev(id, pev_flFallVelocity, 0.0)
		set_pev(id, pev_fuser2, 1000.0)
		set_pev(id, pev_fuser3, 0.0)
		
		dummy_vector[0] = player_data[onos_id][ORIG_BEFORE_REDEEM][0]
		dummy_vector[1] = player_data[onos_id][ORIG_BEFORE_REDEEM][1]
		dummy_vector[2] = player_data[onos_id][ORIG_BEFORE_REDEEM][2]
		entity_set_origin(id, dummy_vector)
		set_pev(id, pev_velocity, Float:{0.0, 0.0, 0.0})	// prevention A) so player will not die after released from onos
		set_task(0.1, "remove_god_after_digest", 500 + id)	// prevention B) so player will not die after released from onos
		set_player_weaponmodel(id)
		player_data[id][SOA_JUST_FREED] = 1
		reset_devour_vars(id)
	}
	reset_devour_vars(onos_id)
}

set_player_weaponmodel( id )
{
	new weapon_list[32], weapon_num, weapon_array, found_max
	get_user_weapons(id, weapon_list, weapon_num)
	for ( new a = 0; a < weapon_num; ++a )
	{
		switch ( weapon_list[a] )
		{
			case WEAPON_KNIFE:
			{
				weapon_array = 0
			}
			case WEAPON_PISTOL:
			{
				weapon_array = 1
			}
			case WEAPON_LMG:
			{
				weapon_array = 2
				found_max = 1
			}
			case WEAPON_SHOTGUN:
			{
				weapon_array = 3
				found_max = 1
			}
			case WEAPON_HMG:
			{
				weapon_array = 4
				found_max = 1
			}
			case WEAPON_GRENADE_GUN:
			{
				weapon_array = 5
				found_max = 1
			}
		}
		
		if ( found_max )
			break
	}
	
	if ( id == gnome_id[0] || id == gnome_id[1] )
	{
		if ( weapon_array == 0 )
			set_pev(id, pev_viewmodel, engfunc(EngFunc_AllocString, viewmodels[12]))
		else
			set_pev(id, pev_viewmodel, engfunc(EngFunc_AllocString, viewmodels[weapon_array]))
		
		if ( weapon_array <= 2 )	// just in case gnome gets a heavy weapon somehow
			set_pev(id, pev_weaponmodel, engfunc(EngFunc_AllocString, weapmodels[6 + weapon_array]))
		else
			set_pev(id, pev_weaponmodel, engfunc(EngFunc_AllocString, weapmodels[weapon_array]))
	}else
	{
		if ( ns_get_class(id) == CLASS_HEAVY )
			set_pev(id, pev_viewmodel, engfunc(EngFunc_AllocString, viewmodels[6 + weapon_array]))
		else
			set_pev(id, pev_viewmodel, engfunc(EngFunc_AllocString, viewmodels[weapon_array]))
	
		set_pev(id, pev_weaponmodel, engfunc(EngFunc_AllocString, weapmodels[weapon_array]))
	}
}

kill_player( victim_id , onos_id , weaponname[] )
{
	set_pev(victim_id, pev_health, 1.0)
	set_pev(victim_id, pev_takedamage, 2.0)
	set_msg_block(DeathMsg_id, BLOCK_ONCE)
	fakedamage(victim_id, "trigger_hurt", 999.0, 0)
	emessage_begin(MSG_ALL, DeathMsg_id)
	ewrite_byte(onos_id)
	ewrite_byte(victim_id)
	ewrite_string(weaponname)
	emessage_end()
	set_pev(onos_id, pev_frags, entity_get_float(onos_id, EV_FL_frags) + 1.0)
	ns_set_score(onos_id, ns_get_score(onos_id) + 1)
	
	emessage_begin(MSG_ALL, ScoreInfo_id)
	ewrite_byte(onos_id)
	ewrite_short(player_data[onos_id][SCOREINFO_DATA][2])
	ewrite_short(player_data[onos_id][SCOREINFO_DATA][3])
	ewrite_short(player_data[onos_id][SCOREINFO_DATA][4])
	ewrite_short(player_data[onos_id][SCOREINFO_DATA][5])
	ewrite_short(player_data[onos_id][SCOREINFO_DATA][6])
	ewrite_short(player_data[onos_id][SCOREINFO_DATA][7])
#if PRE_NS_3_2 == 0
	ewrite_short(player_data[onos_id][SCOREINFO_DATA][8])
	ewrite_short(player_data[onos_id][SCOREINFO_DATA][9])
#endif
	ewrite_string(player_data[onos_id][SCOREINFO_DATA_STRING])
	emessage_end()
	
	give_xtra_xp(onos_id, player_data[victim_id][CUR_LEVEL], player_data[onos_id][CUR_LEVEL], onos_id)
}

gestate_messages( id , hide_weapons , scoreboard_class , iuser3_class )
{
	set_pev(id, pev_iuser3, iuser3_class)
	
	emessage_begin(MSG_ONE, HideWeapon_id, {0, 0, 0}, id)
	ewrite_byte(hide_weapons)
	emessage_end()
	
	emessage_begin(MSG_ONE, Progress_id, {0, 0, 0}, id)
	ewrite_short(id)
	ewrite_byte(3)
	emessage_end()
	
	emessage_begin(MSG_ALL, ScoreInfo_id)
	ewrite_byte(id)
	ewrite_short(player_data[id][SCOREINFO_DATA][2])
	ewrite_short(player_data[id][SCOREINFO_DATA][3])
	ewrite_short(player_data[id][SCOREINFO_DATA][4])
#if PRE_NS_3_2 == 0
	ewrite_short(player_data[id][SCOREINFO_DATA][5])
#endif
	ewrite_byte(scoreboard_class)
#if PRE_NS_3_2 == 0
	ewrite_short(player_data[id][SCOREINFO_DATA][7])
	ewrite_short(player_data[id][SCOREINFO_DATA][8])
	ewrite_short(player_data[id][SCOREINFO_DATA][9])
#else	
	ewrite_short(player_data[id][SCOREINFO_DATA][6])
	ewrite_short(player_data[id][SCOREINFO_DATA][7])
#endif
	ewrite_string(player_data[id][SCOREINFO_DATA_STRING])
	emessage_end()
}

give_xtra_xp( killer , victim_level , killer_level , fake_killer = 0 )
{
	SF_killer_team = pev(killer, pev_team)
	for ( SF_targetid = 1; SF_targetid <= g_maxPlayers; ++SF_targetid )
	{
		if ( !is_user_connected(SF_targetid) )
			continue
			
		if ( SF_killer_team != pev(SF_targetid, pev_team) )
			continue
		
		if ( !is_user_alive(SF_targetid) && fake_killer != killer )
			continue
		
		if ( entity_range(killer, SF_targetid) > 522.0 )
			continue
		
		SF_player_nearby[SF_targetid] = 1
		++SF_players_nearby
	}
	
	if ( victim_level > CoreT_max_level )
		victim_level = CoreT_max_level
	if ( killer_level > CoreT_max_level )
		killer_level = CoreT_max_level
	
	
	SF_xp_to_everyone = float(victim_level * 10 + 50 + SF_players_nearby * 10) / SF_players_nearby

#if PRE_NS_3_2 == 0
	SF_xp_to_everyone_remove = ( victim_level <= 10 ) ? 0.0 : ( float(BASE_MAX_LEVEL * 10 + 50 + SF_players_nearby * 10) / SF_players_nearby )
#else
	SF_xp_by_killer_level = float( ( ( player_data[killer][CUR_LEVEL] > BASE_MAX_LEVEL ) ? BASE_MAX_LEVEL : player_data[killer][CUR_LEVEL] ) * 10 + 60 + SF_players_nearby * 10) / SF_players_nearby
#endif
	
	for ( SF_targetid = 1; SF_targetid <= g_maxPlayers; ++SF_targetid )
	{
		if ( !SF_player_nearby[SF_targetid] )
			continue
		
		if ( !fake_killer )
		{
#if PRE_NS_3_2 == 0
			// current XP = cu_XP + XP by Victim Level - EXP for Victim Lvl 10 ( NS already added Victim Lvl 10 EXP )
			// so only EXP for lvl > 10 is added
			ns_set_exp(SF_targetid, ns_get_exp(SF_targetid) + SF_xp_to_everyone - SF_xp_to_everyone_remove)
#else
			// new XP system = substract xp got by killer lvl and add by victim level
			ns_set_exp(SF_targetid, ns_get_exp(SF_targetid) - SF_xp_by_killer_level + SF_xp_to_everyone)
#endif
		}else
			ns_set_exp(SF_targetid, ns_get_exp(SF_targetid) + SF_xp_to_everyone)
		
		SF_player_nearby[SF_targetid] = 0
	}
	
	SF_players_nearby = 0
}

show_hud_msg( id , vid , xp , level , is_marine , Float:gametime )
{
	player_data[id][HUD_DISP_TIME] = _:gametime
	
	new class = ns_get_class(id)
	CoreT_GL_reload_Shift_text[0] = 0
	if ( player_data[vid][AA_RELOAD_WEAPANIM_TIME] - gametime > 0.0
		&& player_data[vid][CURRENT_WEAPON] == WEAPON_GRENADE_GUN )
	{
		formatex(CoreT_GL_reload_Shift_text, 127, "You are reloading GL with Advanced Ammo^nReload done in %2.1f second%s^n^n^n^n^n^n^n^n^n^n^n^n^n^n^n^n^n^n^n^n^n", player_data[vid][AA_RELOAD_WEAPANIM_TIME] - gametime, ( player_data[vid][AA_RELOAD_WEAPANIM_TIME] - gametime >= 2.0 ) ? "s" : "")		// 21 * ^n
		set_hudmessage(is_marine ? 0 : 160, is_marine ? 75 : 100, is_marine ? 100 : 0, -1.0, is_user_alive(id) ? 0.46 : 0.39, 0, 0.0, 3600.0, 0.0, 0.0, HUD_CHANNEL)
		CoreT_show_GL_reload_Shift_text = 1
	}else if ( player_data[id][ES_SHIFTING] )
	{
		formatex(CoreT_GL_reload_Shift_text, 127, "<< Shifting ( Time: %3.1f ) >>^n^n^n^n^n%s", player_data[id][ES_LASTSHIFT] + player_data[id][ES_SHIFTTIME] - gametime, class == CLASS_GESTATE ? "" : "^n^n")		// 7 * ^n
		set_hudmessage(is_marine ? 0 : 160, is_marine ? 75 : 100, is_marine ? 100 : 0, -1.0, is_user_alive(id) ? 0.753 : 0.683, 0, 0.0, 3600.0, 0.0, 0.0, HUD_CHANNEL)
		CoreT_show_GL_reload_Shift_text = 1
	}else if ( 2 <= player_data[id][SOA_FRESH_PARASITE] < 4
		&& player_data[id][SOA_INFECTED_BY_MARINE] )
	{
		get_user_name(player_data[id][SOA_INFECTED_BY_MARINE], CoreT_player_name, 32)
		formatex(CoreT_GL_reload_Shift_text, 127, "<< Infected by %s: You have been parasited >>^n^n^n^n^n^n^n", CoreT_player_name)		// 7 * ^n
		set_hudmessage(is_marine ? 0 : 160, is_marine ? 75 : 100, is_marine ? 100 : 0, -1.0, is_user_alive(id) ? 0.753 : 0.683, 0, 0.0, 3600.0, 0.0, 0.0, HUD_CHANNEL)
		CoreT_show_GL_reload_Shift_text = 1
	}else
	{
		set_hudmessage(is_marine ? 0 : 160, is_marine ? 75 : 100, is_marine ? 100 : 0, -1.0, is_user_alive(id) ? ( class == CLASS_GESTATE ? 0.851 : 0.89 ) : 0.82, 0, 0.0, 3600.0, 0.0, 0.0, HUD_CHANNEL)
		CoreT_show_GL_reload_Shift_text = 0
	}
	
	CoreT_point_msg[0] = 0
	if ( level > BASE_MAX_LEVEL
		&& player_data[id][POINTS_AVAILABLE] > 0 )
	{
		if ( level > CoreT_max_level )
			level = CoreT_max_level
		CoreT_points_left = level - 1 - ns_get_points(vid) - player_data[vid][EXTRALEVELS]
		if ( CoreT_points_left > 9 )
			formatex(CoreT_point_msg, 9, " (+%i)", CoreT_points_left)
	}
	
	if ( level >= CoreT_max_level )
	{
		show_hudmessage(id, "%sLevel %d: GODLIKE!!!%s", CoreT_GL_reload_Shift_text, CoreT_max_level, CoreT_point_msg)
	}else
	{
		CoreT_percentage = ( ( float(xp) - float(player_data[vid][BASE_LEVEL_XP]) ) * 100.0 ) / float(player_data[vid][XP_TO_NEXT_LVL])
		CoreT_message_set = 0
		
		for ( CoreT_j = 0; CoreT_j < 19; ++CoreT_j )
		{
			if ( level < get_pcvar_num(CVAR_upgrade_levels[CoreT_j]) )
				continue
			
			if ( get_pcvar_num(CVAR_huddisplay) & 1 )
				show_hudmessage(id, "%sLevel %d: %s (%3.1f%%)%s", CoreT_GL_reload_Shift_text, level, is_marine ? marine_rang[CoreT_j] : alien_rang[CoreT_j], CoreT_percentage, CoreT_point_msg)
			else if ( get_pcvar_num(CVAR_huddisplay) & 2 )
				show_hudmessage(id, "%sLevel %d/%d: %s (%3.1f%%)%s", CoreT_GL_reload_Shift_text, level, CoreT_max_level, is_marine ? marine_rang[CoreT_j] : alien_rang[CoreT_j], CoreT_percentage, CoreT_point_msg)
			
			CoreT_message_set = 1
			player_data[id][MESSAGE_DISPLAYING] = 1
			
			break
		}
		
		if ( CoreT_message_set )
			return
		
		if ( get_pcvar_num(CVAR_huddisplay) & 2 )
		{
			for ( CoreT_j = 19; CoreT_j < 29; ++CoreT_j )
			{
				if ( level < 29 - CoreT_j )
					continue
				
				show_hudmessage(id, "%sLevel %d/%d: %s (%3.1f%%)%s", CoreT_GL_reload_Shift_text, level, CoreT_max_level, is_marine ? marine_rang[CoreT_j] : alien_rang[CoreT_j], CoreT_percentage, CoreT_point_msg)
				player_data[id][MESSAGE_DISPLAYING] = 1
			}
		}else if ( get_pcvar_num(CVAR_huddisplay) & 1 && level >= BASE_MAX_LEVEL )
		{
			show_hudmessage(id, "%sLevel %d: %s (%3.1f%%)%s", CoreT_GL_reload_Shift_text, level, is_marine ? marine_rang[19] : alien_rang[19], CoreT_percentage, CoreT_point_msg)
			player_data[id][MESSAGE_DISPLAYING] = 1
		}else if ( CoreT_show_GL_reload_Shift_text )
		{
			show_hudmessage(id, "%s", CoreT_GL_reload_Shift_text)
		}
	}
}

show_NotifyMsg( id )
{
	if ( player_data[id][AUTHORSSHOWN] < get_pcvar_num(CVAR_notify) )
	{
		client_print(id, print_chat, "[ExtraLevels 3] This server is running ExtraLevels 3 v%s by %s", plugin_version, plugin_author)
		if ( is_helper_running != -1 )
			player_data[id][AUTHORSSHOWN] = get_pcvar_num(CVAR_notify)
		else
			player_data[id][AUTHORSSHOWN] += 1
	}
	if ( player_data[id][INFORMSSHOWN] < get_pcvar_num(CVAR_instruct) )
	{
		client_print(id, print_chat, "type /xmenu or xmenu in chat to show a menu of extra upgrades. Type /xhelp for more info.")
		if ( is_helper_running != -1 )
			player_data[id][INFORMSSHOWN] = get_pcvar_num(CVAR_instruct)
		else
			player_data[id][INFORMSSHOWN] += 1
	}
}

//////////////////// Timer Functions ////////////////////

public set_weapon_damage_ammo_timer( timerid_id )
{
	new id = timerid_id - 300
	if ( is_user_connected(id) )
		set_weapon_damage_ammo(id)
}

public check_weapons_after_impulse( parm[] )
{
	// check if player got weapon or impulse been blocked
	new id = parm[0]
	if ( !is_user_connected(id) )
		return
	
	new weapon_id = parm[1]
	new weapon_list[32], weapon_num, found
	get_user_weapons(id, weapon_list, weapon_num)
	
	for ( new a = 0; a < weapon_num; ++a )
	{
		if ( weapon_list[a] != weapon_id )
			continue
		
		if ( !player_data[id][WEAPON_IMPULSE_DATA][parm[2]] )
		{
			found = 1
			player_data[id][WEAPON_IMPULSE_DATA][parm[2]] = 1
			player_data[id][CURRENT_WEAPON] = weapon_id
		}
		
		break
	}
	
	if ( found )
		set_weapon_damage_ammo(id, weapon_id)
}

public remove_god_after_digest( timerid_id )
{
	if ( is_user_connected(timerid_id - 500) )
		set_pev(timerid_id - 500, pev_takedamage, 2.0)
}

//////////////////// These functions are called by Gnome to get/set variables ////////////////////

public EL_get_ammoadd_func( temp_id , num )
{
	new id = get_param(1)
	new weapon_id = get_param(2)
	return floatround(player_data[id][UP_ADVAMMOPACK] * weapon_ammo_adds[weapon_id], floatround_floor)
}

public EL_who_is_gnome_func( temp_id , num )
{
	new gnome_num = get_param(2)
	if ( get_param(3) > 0 )
		gnome_id[gnome_num] = get_param(1)	// id
	else
		gnome_id[gnome_num] = 0
	gnome_speed = get_param(4)
}

//////////////////// These functions are called by other plugins to get/set variables ////////////////////

public EL_get_level_func( temp_id )
{
	new id = get_param(1)
	return player_data[id][CUR_LEVEL]
}

public client_help( id )
{
	client_print(id, print_chat, "client_help")
	help_add("Information", "Allows players to go above Level 10 in Combat, and adds 12 new upgrades (6 for each team)")
	help_add("Usage", "Type in chat:^n/xmenu -> To open the upgrade menu^n/xhelp -> To open a little help menu")
}

public client_advertise( id )
{
	if ( !ns_is_combat() )
		return PLUGIN_HANDLED
	
	return PLUGIN_CONTINUE
}

stock bool:help_add( caption[] , content[] )
{
	if ( is_helper_running == -1 )
		return false
	
	new func = get_func_id("help_add", is_helper_running)
	if ( func == -1 )
		return false
	
	if ( callfunc_begin_i(func, is_helper_running) != 1)
		return false
	
	callfunc_push_str(caption)
	callfunc_push_str(content)
	return callfunc_end() ? true : false
}

//////////////////// This function prevents ExtraLevels 3 from not starting without Gnome ////////////////////

public native_filter( const name[] , index , trap )
{
	if ( !trap )
		return PLUGIN_HANDLED
	
	return PLUGIN_CONTINUE
}

//////////////////// Config File ////////////////////

#if USE_CONFIG_FILE == 1
load_cfg_settings( filename[] )
{
	new got_item[item_list_num]		// mark each checked setting to prevent useless loops
	
	new got_line, i
	new line = 0, temp = 0
	new line_buffer[256]
	got_line = read_file(filename, line, line_buffer, 255, temp)
	if ( got_line <= 0 )
		log_amx("ExtraLevels 3 >> Unable to read from file ^"%s^"", filename)
	
	new buffer[128], found_char
	while ( got_line > 0 )
	{
		if ( !equal(line_buffer, "//", 2) && strlen(line_buffer) != 0  )
		{
			found_char = 0
			for ( i = 0; i < strlen(line_buffer); ++i )
			{
				if ( !isspace(line_buffer[i]) )
				{
					buffer[i] = line_buffer[i]
					found_char = 1
				}else if ( found_char )
				{
					buffer[i] = 0
					break
				}
			}
			replace(line_buffer, 255, buffer, "")
			for ( i = 0; i < item_list_num; ++i )
			{
				if ( !got_item[i]
					&& equali(buffer, item_list[i]) )
				{
					got_item[i] = 1
					if ( item_setting_fl[i] > 0.0 )
						item_setting_fl[i] = str_to_float_my(line_buffer)
					else
						item_setting[i] = str_to_num(line_buffer)
					break
				}
			}
		}
		got_line = read_file(filename, ++line, line_buffer, 255, temp)
	}
}

Float:str_to_float_my( string_to_float[] )
{
	new float_str[32], float_str_pos, found_dot, found_digit, found_digit_after_dot
	for ( new j = 0; j < strlen(string_to_float); ++j )
	{
		if ( isdigit(string_to_float[j]) )
		{
			found_digit = 1
			float_str[float_str_pos] = string_to_float[j]
			++float_str_pos
			if ( found_dot )
				found_digit_after_dot = 1
		}else if ( found_digit && string_to_float[j] == '.' )
		{
			float_str[float_str_pos] = string_to_float[j]
			found_dot = 1
			++float_str_pos
		}else if ( found_dot )
		{
			if ( !found_digit_after_dot )
			{
				float_str_pos = 0
				float_str[float_str_pos] = 0
				found_digit = 0
				found_dot = 0
			}else
				break
		}
	}
	if ( !found_digit_after_dot )
		return 0.0
	
	return floatstr(float_str)
}

set_cfg_settings( )
{
	new i
	CYBERNETICS = item_setting[i]
	REINFORCEARMOR = item_setting[++i]
	NANOARMOR = item_setting[++i]
	ADVAMMOPACK = item_setting[++i]
	STATICFIELD = item_setting[++i]
	WELDOVERBASE = item_setting[++i]
	URANUIMAMMO = item_setting[++i]
	THICKSKIN = item_setting[++i]
	ETHSHIFT = item_setting[++i]
	BLOODLUST = item_setting[++i]
	HUNGER = item_setting[++i]
	ACIDICVENGEANCE = item_setting[++i]
	SENSEOFANCIENTS = item_setting[++i]
	
	CYBERNETICSCOST = item_setting[++i]
	REINFORCEARMORCOST = item_setting[++i]
	NANOARMORCOST = item_setting[++i]
	ADVAMMOPACKCOST = item_setting[++i]
	STATICFIELDCOST = item_setting[++i]
	URANUIMAMMOCOST = item_setting[++i]
	THICKSKINCOST = item_setting[++i]
	ETHSHIFTCOST = item_setting[++i]
	BLOODLUSTCOST = item_setting[++i]
	HUNGERCOST = item_setting[++i]
	ACIDICVENGEANCECOST = item_setting[++i]
	SENSEOFANCIENTSCOST = item_setting[++i]
	
	CYBERNETICSMAX = item_setting[++i]
	REINFORCEARMORMAX = item_setting[++i]
	NANOARMORMAX = item_setting[++i]
	ADVAMMOPACKMAX = item_setting[++i]
	STATICFIELDMAX = item_setting[++i]
	URANUIMAMMOMAX = item_setting[++i]
	THICKENEDSKINMAX = item_setting[++i]
	ETHSHIFTMAX = item_setting[++i]
	BLOODLUSTMAX = item_setting[++i]
	HUNGERMAX = item_setting[++i]
	ACIDICVENGEANCEMAX = item_setting[++i]
	SENSEOFANCIENTSMAX = item_setting[++i]
	
	CYBERNETICSLEVEL = item_setting[++i]
	SPEED_MA = item_setting[++i]
	SPEED_HA = item_setting[++i]
	
	REINFORCEARMORLEVEL = item_setting[++i]
	ARMOR_MA = item_setting[++i]
	ARMOR_HA = item_setting[++i]
	
	NANOARMORLEVEL = item_setting[++i]
	NANOARMOR_MA = item_setting[++i]
	NANOARMOR_HA = item_setting[++i]
	
	ADVAMMOPACKLEVEL = item_setting[++i]
	ADVAMMOPACK_PISTOL = item_setting_fl[++i]
	ADVAMMOPACK_LMG = item_setting_fl[++i]
	ADVAMMOPACK_SHOTGUN = item_setting_fl[++i]
	ADVAMMOPACK_HMG = item_setting_fl[++i]
	ADVAMMOPACK_GL = item_setting_fl[++i]
	
	STATICFIELDLEVEL = item_setting[++i]
	STATICFIELDINITIALRANGE = item_setting[++i]
	STATICFIELDLEVELRANGE = item_setting[++i]
	STATICFIELDNUMERATORLV = item_setting[++i]
	STATICFIELDDENOMENATOR = item_setting[++i]
	MAXSTATICNUMERATOR = item_setting[++i]
	
	URANUIMAMMO_BULLET = item_setting[++i]
	URANUIMAMMO_GREN =item_setting[++i]
	
	THICKENEDSKINLEVEL = item_setting[++i]
	HEALTHSKULK = item_setting_fl[++i]
	HEALTHGORGE = item_setting_fl[++i]
	HEALTHLERK = item_setting_fl[++i]
	HEALTHFADE = item_setting_fl[++i]
	HEALTHONOS = item_setting_fl[++i]
	HEALTHGESTATE = item_setting_fl[++i]
	
	ETHSHIFTLEVEL = item_setting[++i]
	SHIFTINITIAL = item_setting_fl[++i]
	SHIFTLEVEL = item_setting_fl[++i]
	SHIFTCLASSMULTI = item_setting[++i]
	ONOS_SHIFT = item_setting[++i]
	SHIFTDELAY = item_setting_fl[++i]
	
	BLOODLUSTLEVEL = item_setting[++i]
	BLOODLUSTSPEED = item_setting[++i]
	
	HUNGERLEVEL = item_setting[++i]
	HUNGERSPEED = item_setting[++i]
	HUNGERHEALTH = item_setting[++i]
	HUNGERINITIALTIME = item_setting_fl[++i]
	HUNGERLEVELTIME = item_setting_fl[++i]
	
	ACIDICVENGEANCELEVEL = item_setting[++i]
	AV_MA_HP = item_setting_fl[++i]
	AV_MA_AP = item_setting_fl[++i]
	AV_HA_HP = item_setting_fl[++i]
	AV_HA_AP = item_setting_fl[++i]
	AV_GORGE_GEST_MULTI = item_setting_fl[++i]
	
	SOA_PARASITE_INIT = item_setting[++i]
	SOA_PARASITE_ADD = item_setting[++i]
	SOA_PARASITE_DMG = item_setting[++i]
	SOA_HEALSPRAY_DMG = item_setting[++i]
	SOA_GASDAMAGE = item_setting[++i]
	SOA_BLINK_ENERGY_BONUS = item_setting[++i]
	SOA_DEVOUR_ADDER = item_setting[++i]
	SOA_DEVOURTIME_INIT = item_setting_fl[++i]
	SOA_DEVOURTIME_BONUS = item_setting_fl[++i]
	SOA_GESTATE_ARMOR_ADD = item_setting[++i]
	
	CUSTOM_LEVELS = item_setting[++i]
	BASE_XP_TO_NEXT_LEVEL = item_setting[++i]
	NEXT_LEVEL_XP_MODIFIER = item_setting[++i]
	
	// max default upgrades + ( if_available * cost * amount_of_levels )
	max_marine_points = 20
				+ CYBERNETICS * CYBERNETICSCOST * CYBERNETICSMAX
				+ REINFORCEARMOR * REINFORCEARMORCOST * REINFORCEARMORMAX
				+ NANOARMOR * NANOARMORCOST * NANOARMORMAX
				+ ADVAMMOPACK * ADVAMMOPACKCOST * ADVAMMOPACKMAX
				+ STATICFIELD * STATICFIELDCOST * STATICFIELDMAX
				+ URANUIMAMMO * URANUIMAMMOCOST * URANUIMAMMOMAX
	max_alien_points = 17
				+ THICKSKIN * THICKSKINCOST * THICKENEDSKINMAX
				+ ETHSHIFT * ETHSHIFTCOST * ETHSHIFTMAX
				+ BLOODLUST * BLOODLUSTCOST * BLOODLUSTMAX
				+ HUNGER * HUNGERCOST * HUNGERMAX
				+ ACIDICVENGEANCE * ACIDICVENGEANCECOST * ACIDICVENGEANCEMAX
				+ SENSEOFANCIENTS * SENSEOFANCIENTSCOST * SENSEOFANCIENTSMAX
}
#endif

//////////////////// Ban File ////////////////////
load_ban_cfg( filename[] )
{
	new file = fopen(filename, "r")
	new buffer[128]
	new steamid[64]
	new ban_num = 0
	while ( fgets(file, buffer, 127)
		&& ban_num < MAX_BAN_NUM )
	{
		if ( (buffer[0] == '^n')					// empty line
			|| ( (buffer[0] == '/') && (buffer[1] == '/') ) )	// comment
			continue
		
		parse(buffer, steamid, 63)
		copy(banList[ban_num], 63, steamid)
		++ban_num
	}
	fclose (file)
}