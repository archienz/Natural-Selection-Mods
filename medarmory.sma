#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <engine>
#include <ns>
#include <fun>

#define PLUGIN "Medarmory Pro rework"
#define VERSION "1.1"
#define AUTHOR "Schnitzelmaker"

/*
Version:
1.0  : First Release
1.0a : New cvar "amx_armorycombat", to enable/disable in combat
1.1  : New cvars "amx_armoryammo", to enable/disable ammo refill
       How many ammo get to a weapon can change with defines
       "amx_armoryrefill",to enable/disable that health/ammo cost some amount.
       The number say how many refill the amount each armorytime.
*/

#define Medtimer 2.0
#define Maxarmorys 33
#define maxamount 200 //Max Amount of refill the armory

#define MaxammoLMG 250
#define MaxammoHMG 250
#define MaxammoSG  40
#define MaxammoGL  30
#define MaxammoPistol 30

//How many amount give every ammo refill
#define AmountLMG 10
#define AmountHMG 10
#define AmountSG  2
#define AmountGL  1
#define AmountPistol  5

new g_maxplayers,max_entities
new armoryamount[Maxarmorys][2]

public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR)
	g_maxplayers = get_maxplayers()
	max_entities = get_global_int(GL_maxEntities)

	register_cvar("amx_armoryrange" , "400.0")	//Max distance between player and amory to heal him
	register_cvar("amx_armoryhealth", "5.0")	//How many hp heal every 2 sec
	register_cvar("amx_armoryarmor" , "3.0")	//How many armor heal every 2 sec
	register_cvar("amx_armoryadvonly" , "1")	//Heal Armor only by AdvArmory(1 = yes, 0 = no)
	
	register_cvar("amx_armoryammo" , "1")		//Give the armory alo ammo
	register_cvar("amx_armoryrefill" , "3")		//How many refill the armory(0=unlimite,>0 = amount of refill each armorytimer)
	
	register_cvar("amx_armoryelec" , "0")		//Electrify  builded Armory
	register_cvar("amx_armoryrtelec" , "0")		//Electrify  builded Resourcetowers
	register_cvar("amx_armorytfelec" , "0")		//Electrify  builded Turretfactorys
	register_cvar("amx_armoryturretselec" , "0")	//Electrify  builded Turrets
	
	register_cvar("amx_armoryglow" , "0")		//Glow weapons
	register_cvar("amx_armorymine" , "0")		//Invisible Mines
	
	register_cvar("amx_armorycombat" , "0")		//Allow in combat
	
	for (new i = 0;i<= Maxarmorys-1;i++)
		armoryamount[i][0] = maxamount
	
	set_task(Medtimer,"Medfunction",1358,_,_,"b")
}

public Medfunction(){
	if (ns_is_combat() && get_cvar_num("amx_armorycombat") || !ns_is_combat()){
		new armory,advarmory 
		armory = ns_get_build("team_armory",1)
		if (!armory)
			advarmory = ns_get_build("team_advarmory",1)
		if (armory > 0 || advarmory > 0){
			for (new ent=g_maxplayers+1;ent<=max_entities;ent++){
				if(is_valid_ent(ent)){
					new Classname[32]
					entity_get_string(ent,EV_SZ_classname,Classname,31)
					new building = entity_get_int(ent,EV_INT_iuser3)
					new Float:fuser
					pev(ent,pev_fuser1,fuser)
					//if (get_cvar_num("amx_armoryrtelec") && equal(Classname,"resourcetower") && fuser >= 1000 && !ns_get_mask(ent,MASK_ELECTRICITY)) 
					if (get_cvar_num("amx_armoryrtelec") && building == 35 && fuser >= 1000 && !ns_get_mask(ent,MASK_ELECTRICITY)) 
						ns_set_mask(ent,MASK_ELECTRICITY,1)
					//if (get_cvar_num("amx_armorytfelec") && equal(Classname,"team_turretfactory") && fuser >= 1000 && !ns_get_mask(ent,MASK_ELECTRICITY)) 
					if (get_cvar_num("amx_armorytfelec") && building == 24 && fuser >= 1000 && !ns_get_mask(ent,MASK_ELECTRICITY)) 
						ns_set_mask(ent,MASK_ELECTRICITY,1)
					//if (get_cvar_num("amx_armoryturretselec") && equal(Classname,"turret") && fuser >= 1000 && !ns_get_mask(ent,MASK_ELECTRICITY)) 
					if (get_cvar_num("amx_armoryturretselec") && building == 33 && fuser >= 1000 && !ns_get_mask(ent,MASK_ELECTRICITY)) 
						ns_set_mask(ent,MASK_ELECTRICITY,1)
					if (get_cvar_num("amx_armoryglow") && !entity_get_edict(ent, EV_ENT_owner)){
						if (equal(Classname , "weapon_welder") ){
							set_rendering(ent,kRenderFxGlowShell,188,220,255,kRenderNormal,25)
							}
						else if (equal(Classname , "weapon_heavymachinegun")){
							set_rendering(ent,kRenderFxGlowShell,255,0,0,kRenderNormal,25)
							}
						else if (equal(Classname , "weapon_grenadegun")){
							set_rendering(ent,kRenderFxGlowShell,0,255,0,kRenderNormal,25)
							}
						else if (equal(Classname , "weapon_shotgun")){
							set_rendering(ent,kRenderFxGlowShell,125,255,200,kRenderNormal,25)
							}
						else if (equal(Classname , "weapon_mine")){
							set_rendering(ent,kRenderFxGlowShell,20,20,130,kRenderNormal,25)
							}
						else if (equal(Classname , "item_heavyarmor")){
							set_rendering(ent,kRenderFxGlowShell,10,100,200,kRenderNormal,25)
							}
						else if (equal(Classname , "item_jetpack")){
							set_rendering(ent,kRenderFxGlowShell,0,0,255,kRenderNormal,25)
							}
						}
					if (get_cvar_num("amx_armorymine") && equal(Classname , "item_mine")){
						set_rendering(ent,kRenderFxNone,0,0,0,kRenderTransAlpha,75)
						}
					//if (equal(Classname,"team_armory") && fuser >= 1000 || equal(Classname,"team_advarmory")){
					if (building ==  25 && fuser >= 1000 || building == 26){
						if (get_cvar_num("amx_armoryelec") && !ns_get_mask(ent,MASK_ELECTRICITY))
							ns_set_mask(ent,MASK_ELECTRICITY,1)
						
						new refill = get_cvar_num("amx_armoryrefill")
						new armory,found
						for (new l = 0;l<= Maxarmorys-1;l++){
							if (!is_valid_ent(armoryamount[l][1]))
								armoryamount[l][1] = 0
							if (armoryamount[l][1] == ent){
								armory = l
								found = 1
								}
							else if (armoryamount[l][1] == 0 && !found)
								armory = l
							}
						
						new newamount = armoryamount[armory][0] + refill
						if (refill && newamount < maxamount)
							armoryamount[armory][0] = newamount
						
						//client_print(0,print_chat,"refill:%d,%d,%d",armoryamount[armory][0],newamount,maxamount)
						
						new armoryteam = pev(ent,pev_team)
						if (armoryamount[armory][0] > 0 && refill || !refill){
							for (new i = 1;i<=g_maxplayers;i++){
								new class = ns_get_class(i)
								if (is_user_connected(i) && is_user_alive(i) && !ns_get_mask(i,MASK_DIGESTING) && class != CLASS_COMMANDER && pev(i,pev_team) == armoryteam){
									if (entity_range(ent,i) <= get_cvar_float("amx_armoryrange")){
										new Float:health,Float:armor,Float:maxarmor,Float:healrate = 1.0
										pev(i,pev_health,health)
										pev(i,pev_armorvalue,armor)
										maxarmor = get_maxarmor(i)
										if (equal(Classname,"team_advarmory"))
											healrate = 2.0
										if (class == CLASS_HEAVY)
											healrate = healrate * 2.0
										//client_print(0,print_chat,"test:%f,%f,%f",health,armor,healrate)
										if (health < 100.0){
											new Float:new_health = health + get_cvar_float("amx_armoryhealth") * healrate
											if (new_health > 100.0)
												new_health = 100.0
											set_pev(i,pev_health,new_health)
											if (refill)
												armoryamount[armory][0]--
											}
										else if (equal(Classname,"team_advarmory") || !get_cvar_num("amx_armoryadvonly")){
											if (armor < maxarmor){
												new Float:new_armor = armor + get_cvar_float("amx_armoryarmor") * healrate
												if (new_armor > maxarmor)
													new_armor = maxarmor
												set_pev(i,pev_armorvalue,new_armor)
												if (refill)
													armoryamount[armory][0]--
												}
											}
										if (get_cvar_num("amx_armoryammo")){
											new newreserve,reserve
											if (ns_has_weapon(i,WEAPON_PISTOL)){
												reserve = ns_get_weap_reserve(i,WEAPON_PISTOL)
												if (reserve < MaxammoPistol){
													newreserve =  reserve + AmountPistol
													if (newreserve > MaxammoPistol)
														newreserve = MaxammoPistol
													ns_set_weap_reserve(i,WEAPON_PISTOL,newreserve)
													if (refill)
														armoryamount[armory][0]--
													}
												}
											if (ns_has_weapon(i,WEAPON_LMG)){
												reserve = ns_get_weap_reserve(i,WEAPON_LMG)
												if (reserve < MaxammoLMG){
													newreserve =  reserve + AmountLMG
													if (newreserve > MaxammoLMG)
														newreserve = MaxammoLMG
													ns_set_weap_reserve(i,WEAPON_LMG,newreserve)
													if (refill)
														armoryamount[armory][0]--
													}
												}
											if (ns_has_weapon(i,WEAPON_HMG)){
												reserve = ns_get_weap_reserve(i,WEAPON_HMG)
												if (reserve < MaxammoHMG){
													newreserve =  reserve + AmountHMG
													if (newreserve > MaxammoHMG)
														newreserve = MaxammoHMG
													ns_set_weap_reserve(i,WEAPON_HMG,newreserve)
													if (refill)
														armoryamount[armory][0]--
													}
												}
											if (ns_has_weapon(i,WEAPON_SHOTGUN)){
												reserve = ns_get_weap_reserve(i,WEAPON_SHOTGUN)
												if (reserve < MaxammoSG){
													newreserve =  reserve + AmountSG
													if (newreserve > MaxammoSG)
														newreserve = MaxammoSG
													ns_set_weap_reserve(i,WEAPON_SHOTGUN,newreserve)
													if (refill)
														armoryamount[armory][0]--
													}
												}
											if (ns_has_weapon(i,WEAPON_GRENADE_GUN)){
												reserve = ns_get_weap_reserve(i,WEAPON_GRENADE_GUN)
												if (reserve < MaxammoGL){
													newreserve =  reserve + AmountGL
													if (newreserve > MaxammoGL)
														newreserve = MaxammoGL
													ns_set_weap_reserve(i,WEAPON_GRENADE_GUN,newreserve)
													if (refill)
														armoryamount[armory][0]--
													}
												}
											}
									}
								}
							}
						}
					}
				}
			}
		}
	}
}
	
Float:get_maxarmor(id){
	new class = ns_get_class(id)
	new Float:maxarmor = 30.0
	if ((class == CLASS_MARINE) || (class == CLASS_JETPACK)){
		maxarmor = 30.0
		if (ns_get_mask(id,MASK_ARMOR1))
			maxarmor = 50.0
		else if (ns_get_mask(id,MASK_ARMOR2))
			maxarmor = 70.0
		else if (ns_get_mask(id,MASK_ARMOR3))
			maxarmor = 90.0
		}
	else if (class == CLASS_HEAVY){
		maxarmor = 200.0
		if (ns_get_mask(id,MASK_ARMOR1))
			maxarmor = 230.0
		else if (ns_get_mask(id,MASK_ARMOR2))
			maxarmor = 260.0
		else if (ns_get_mask(id,MASK_ARMOR3))
			maxarmor = 290.0
		}
	
	return maxarmor
}