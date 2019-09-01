/* AMX/AMXX Plugin
* Admin Weapons for Natural Selection 3.1.2
*  by Girthesniper
* 
*  AIM: gir489
*  MSNM: bartman779@aol.com //I swear this is a MSNM handler.
*  E-Mail: gir489[AT]linuxmail{d()t}0|26 // Replace [AT] with @, {d()t} with . and 0|26 with org.
*
* 
* Description: Give clients weapons and accessories. (Soon will be able to give the admins the ability to set ammo on clients.)
* 
*
* Note: You can only give each team their own weapons. For example, only the aliens can get alien abilities, and vice versa for marines.
*
*
* Testing Notes: This plugin was tested on a Win32 HLDS, using AMX mod X version 1.0.1, with MetaMod-P v1.17.4 p23.
*
*
* Usage: amx_weapon <authid, nick, @team, @all or #userid> <weapon #> 
* Example: amx_weapon Girthesniper 40 ; Gives Girthesniper the Primal Scream ability.
*          amx_weapon @ALL 1 ; Gives every one the marine pistol.
*          amx_weapon Girth 34 ; Gives client "Girthesniper" the devour ability.
*
* Changelog:
*
* 12/2/2004	Attempts at fixing item_ammo, but with no luck. I did happened to fix the item_health bug, though.
*		Fixed misspell of "bite" in weapon_bitegun.
*
* 12/8/2004	Regrouped the alien abilities into a more easily rememberable system.
*		Added weapon_knife.
* 
* 12/11/04	Added forgotten Lerk ability. (Umbra)
*
* 12/13/04	Added item_catalyst (Case 14). Thanks Acrylic!!!!
*
* 12/29/04	Fixed genericammo bug.
*		Added AMXx compatibility for item_genericammo.
*
* 1/1/05		Added define for AMX and AMXX compatibility.
*		Merged the AMX and AMXX version into one .SMA for convenience.
* 		Fixed spelling and grammar errors in the introduction.
*
* 1/12/05	Removed that stupid amx_weaponmsg command.
*		Fixed grammar in the console_prints.
*		Made the console commands say [AMXX] for the AMXX users.
*		Added some more stuff to the introduction to make it more proper.
*
* 3/1/05		Fixed the bug that wouldn't allow AMXx loading.
*		Shortened name in register_plugin, so that it actually shows up in 'amx_plugins'.
*		Redid all of the #if statements.
*		Fixed grammar in 12/2/2004's changes.
*		Changed the version variance, to the date of the release.
*
* 3/8/05		Converted plugin for 3.0 Final use.
*		Removed weapon_knife, due to the release of 3.0 Final not having the "first-spawn" bug.
*
* 3/19/05	Converted plugin for 3.0.1 use.
*		Gave a #define if you want the knife, or not.
*
* 3/25/05	Swapped item_heavyarmor with item_jetpack, to have a more relevant ordering system, that NS has.
*		Changed name to admin_weapons_ns.
*		Added amx_weapons cvar, to make it more relevant to the plugin. (Because, the plugin doesn't just give out one weapon. ;))
*
* 3/26/05	Fixed bug that would screw up the player's name in the console.
*		Changed all marine items (accept for the knife) to ns_give_item, so they could drop the stuff for other d00ds, if they desire.
*		Removed AMX support. (Get with the times!!!)
*
* 3/27/05	Changed the ns_give_items, to give_item, accept for the JetPack and HeavyArmor.
*
* 3/29/05	Fixed Gorge ability not working. (Case 32) {Gorge - HealSpray}
*
* 4/02/05	Changed the syntax for the give numbers, of the LMG, Pistol, and the Knife. They now follow a more relevant setup that NS has.
*		Fixed Lerk ability not working. (Case 62) {Lerk - Spore}
*
* 4/08/05	Converted plugin for 3.0.2 use.
*
* 4/13/05	Fixed version number displaying wrong.
*		Added Weapon/Upgrade combos. They go by UXW. (U = the upgrade's number of order in NS, and the W goes by the weapon's last number in its case number.) {The X is always 0.} [For example: Jetpack with LMG is amx_weapons 101, and shotgun is amx_weapons 104.]
*
* 5/29/05	Removed my YIM address from the commentary, because I never use it.
*		Updated plugin for 3.0.3 use.
*		Fixed some of the comment and case entries not being tabbed correctly.
*		Removed #Knife define.
*		Removed double health case. (Case 12/15) {Is now Case 12.}
*
* 6/11/05	Added case 1337. (Elite Case.) {Thanks goes out to General1337 for the base-code.)
*		Added my E-Mail to the commentary.
*		Updated plugin for 3.0.4 use.
*		Added Testing Notes to the commentary.
*
* 6/12/05	Fixed case 1337. (Elite Case.) {Thanks KCE for the fix.}
*		Added ns_give_res 1337 to the Elite Case.
*		Added set_user_health 1337 to the Elite Case.
*		Added set_user_armor 1337 to the Elite Case.
*		Removed the extra 3 from the score value. It was Eleet, not just leet.
*		Fixed some compiling errors.
*
* 7/09/05	Removed ns_set_res in the Elite Case. It really isn't necessary.
*		Set deaths to 0 in the Elite Case.
*
* 9/22/05	Added DATE #define, so it's easier for me to keep it updated.
*		Fixed up some of the weapon_give code. (Thanks MeatWad)
*		Spaced out the case statements a little better.
*
* 9/24/05            Actually implemented the DATE #define.
*
* 12/10/05	Added ammo for the corresponding weapon.
*		Update plugin for 3.1.2 use.
*/

#include <amxmodx>
#include <amxmisc>
#include <ns>
#include <fun>

#define DATE "12.10.05"

public plugin_init() {
  register_plugin("Admin Weapons",DATE,"Girthesniper")
  register_concmd("amx_weapon","admin_weapon",ADMIN_LEVEL_B,"<authid, nick, @all, @team, or #userid> <weapon #>") 
  register_concmd("amx_weapons","admin_weapon",ADMIN_LEVEL_B,"<authid, nick, @all, @team, or #userid> <weapon #>") 
}

public admin_weapon(id,level,cid) 
{ 
   if ( !cmd_access(id,level,cid,3) ) 
   	return PLUGIN_HANDLED 

   new arg1[32],arg2[8],weapon 
   read_argv(1,arg1,31) 
   read_argv(2,arg2,7) 
   weapon = str_to_num(arg2) 

   if ( equali(arg1,"@all") ) 
   { 
      new plist[32],pnum 
      get_players(plist,pnum,"a") 
      if (pnum==0) 
      { 
	console_print(id,"[AMXX] This client is invalid.")
	return PLUGIN_HANDLED 
      } 
      for (new i=0; i<pnum; i++) 
            if ( !give_weapon(plist[i],weapon) ) 
            {
		 console_print(id,"[AMXX] Gave all players weapon %d.",weapon)
            }
      console_print(id,"[AMXX] Gave all players the weapon %d.",weapon)
   } 
   else if ( arg1[0]=='@' ) 
   { 
      new plist[32],pnum 
      get_players(plist,pnum,"ae",arg1[1]) 
      if ( pnum==0 ) 
      {
	console_print(id,"[AMXX] No clients in such team.")
	return PLUGIN_HANDLED 
      } 
      for (new i=0; i<pnum; i++)
      give_weapon(plist[i],weapon)
      console_print(id,"[AMXX] Gave all %s weapon %d.",arg1[1],weapon)
   } 
   else 
   { 
      new pName[32] 
      new player = cmd_target(id,arg1,6) 
      if (!player) return PLUGIN_HANDLED 
      give_weapon(player,weapon) 
      get_user_name(player,pName,31)
      console_print(id,"[AMXX] Gave %s the weapon %d.",arg1[1],weapon)
   }
   return PLUGIN_HANDLED 
}
give_weapon(id,weapon)
{
   switch (weapon)
   {
      //Marine weaponary
      case 1:{
	 give_item(id,"weapon_machinegun")
	 ns_set_weap_reserve(id,WEAPON_LMG,250)
      }
      case 2:{
	 give_item(id,"weapon_pistol")
	 ns_set_weap_reserve(id,WEAPON_PISTOL,30)
      }
      case 3:{ 
	 give_item(id,"weapon_knife")
      }
      case 4:{
	 give_item(id,"weapon_shotgun")
	 ns_set_weap_reserve(id,WEAPON_SHOTGUN,40)
      } 
      case 5:{ 
	 give_item(id,"weapon_heavymachinegun")
	 ns_set_weap_reserve(id,WEAPON_HMG,250)
      }
      case 6:{
	 give_item(id,"weapon_grenadegun")
	 ns_set_weap_reserve(id,WEAPON_GRENADE_GUN,30)
      }
      case 7:{
	 give_item(id,"weapon_grenade")
      }
      case 8:{
	 give_item(id,"weapon_mine")
      }
      case 9:{
	 give_item(id,"weapon_welder")
      }
      //Marine equipment
      case 10:{
	 ns_give_item(id,"item_jetpack")
      }
      case 11:{
	 ns_give_item(id,"item_heavyarmor")
      }
      case 12:{
	 ns_give_item(id,"item_health")
      }
      case 13:{
	 ns_give_item(id,"item_genericammo")
      }
      case 14:{
	 give_item(id,"item_catalyst")
      }
      //Skulk abilities
      case 21:{
	 give_item(id,"weapon_bitegun")
      }
      case 22:{
	 give_item(id,"weapon_parasite")
      }
      case 23:{
	 give_item(id,"weapon_leap")
      }
      case 24:{
	 give_item(id,"weapon_divinewind")
      }
      //Gorge abilities
      case 31:{
	 give_item(id,"weapon_spit")
      }
      case 32:{
	 give_item(id,"weapon_healingspray")
      }
      case 33:{
	 give_item(id,"weapon_bilebombgun")
      }
      case 34:{
	 give_item(id,"weapon_webspinner")
      }
      //Lerk abilities
      case 41:{
	 give_item(id,"weapon_bite2gun")
      }
      case 42:{
	 give_item(id,"weapon_sporegun")
      }
      case 43:{
	 give_item(id,"weapon_umbra")
      }
      case 44:{
	 give_item(id,"weapon_primalscreem")
      }
      //Fade abilities
      case 51:{
	 give_item(id,"weapon_swipe")
      }
      case 52:{
	 give_item(id,"weapon_blink")
      }
      case 53:{
	 give_item(id,"weapon_metabolize")
      }
      case 54:{
	 give_item(id,"weapon_acidrocketgun")
      }
      //Onos abilities
      case 61:{
	 give_item(id,"weapon_claws")
      }
      case 62:{
	 give_item(id,"weapon_devour")
      }
      case 63:{
	 give_item(id,"weapon_stomp")
      }
      case 64:{
	 give_item(id,"weapon_charge")
      }
      //Combo-Cases for Jetpack
      case 101:{
	 give_item(id,"weapon_machinegun")
	 give_item(id,"weapon_mine")
	 give_item(id,"weapon_grenade")
	 give_item(id,"weapon_welder")
	 give_item(id,"item_jetpack")
	 ns_set_weap_reserve(id,WEAPON_PISTOL,30)
	 ns_set_weap_reserve(id,WEAPON_LMG,250)
      }
      case 104:{
	 give_item(id,"weapon_shotgun")
	 give_item(id,"weapon_mine")
	 give_item(id,"weapon_grenade")
	 give_item(id,"weapon_welder")
	 give_item(id,"item_jetpack")
	 ns_set_weap_reserve(id,WEAPON_PISTOL,30)
	 ns_set_weap_reserve(id,WEAPON_SHOTGUN,40)
      }
      case 105:{
	 give_item(id,"weapon_heavymachinegun")
	 give_item(id,"weapon_mine")
	 give_item(id,"weapon_grenade")
	 give_item(id,"weapon_welder")
	 give_item(id,"item_jetpack")
	 ns_set_weap_reserve(id,WEAPON_PISTOL,30)
	 ns_set_weap_reserve(id,WEAPON_HMG,250)
      }
      case 106:{
	 give_item(id,"weapon_grenadegun")
	 give_item(id,"weapon_mine")
	 give_item(id,"weapon_grenade")
	 give_item(id,"weapon_welder")
	 give_item(id,"item_jetpack")
	 ns_set_weap_reserve(id,WEAPON_PISTOL,30)
	 ns_set_weap_reserve(id,WEAPON_GRENADE_GUN,40)
      }
      //Combo-Cases for HeavyArmor
      case 201:{
	 give_item(id,"weapon_machinegun")
	 give_item(id,"weapon_mine")
	 give_item(id,"weapon_grenade")
	 give_item(id,"weapon_welder")
	 give_item(id,"item_heavyarmor")
	 ns_set_weap_reserve(id,WEAPON_PISTOL,30)
	 ns_set_weap_reserve(id,WEAPON_LMG,250)
      }
      case 204:{
	 give_item(id,"weapon_shotgun")
	 give_item(id,"weapon_mine")
	 give_item(id,"weapon_grenade")
	 give_item(id,"weapon_welder")
	 give_item(id,"item_heavyarmor")
	 ns_set_weap_reserve(id,WEAPON_PISTOL,30)
	 ns_set_weap_reserve(id,WEAPON_SHOTGUN,30)
      }
      case 205:{
	 give_item(id,"weapon_heavymachinegun")
	 give_item(id,"weapon_mine")
	 give_item(id,"weapon_grenade")
	 give_item(id,"weapon_welder")
	 give_item(id,"item_heavyarmor")
	 ns_set_weap_reserve(id,WEAPON_PISTOL,30)
	 ns_set_weap_reserve(id,WEAPON_HMG,250)
      }
      case 206:{
	 give_item(id,"weapon_grenadegun")
	 give_item(id,"weapon_mine")
	 give_item(id,"weapon_grenade")
	 give_item(id,"weapon_welder")
	 give_item(id,"item_heavyarmor")
	 ns_set_weap_reserve(id,WEAPON_PISTOL,30)
	 ns_set_weap_reserve(id,WEAPON_GRENADE_GUN,40)
      }
      case 1337:{
	 new weapon_list[32]
	 new weapon_num, i
	 get_user_weapons(id, weapon_list,weapon_num)
	 new weapon_name[33]
	 for(i = 0; i < weapon_num; i++)
 	 {
	 get_weaponname(weapon_list[i], weapon_name,32) 
  	 if(equal(weapon_name,"weapon_machinegun"))
   	 ns_set_weap_dmg(weapon_list[i],float(1337))
  	 else if(equal(weapon_name,"weapon_pistol"))
   	 ns_set_weap_dmg(weapon_list[i],float(1337))
  	 else if(equal(weapon_name,"weapon_knife"))
   	 ns_set_weap_dmg(weapon_list[i],float(1337))
 	 }
 	 ns_set_points(id,13)
	 ns_set_speedchange(id,1337)
	 ns_set_score(id,1337)
	 ns_set_deaths(id, 0)
	 set_user_health(1, 1337)
	 set_user_armor(1, 1337)
      }
      default: return false 
   } 
   return true
}