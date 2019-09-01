//NS Team Devour Version 1.0
//[SHN] Hoobs

#include <amxmodx>
#include <amxmisc>
#include <string>
#include <ns2amx>
#include <ns>
#include <ns_const>
#include <fun>
#include <engine>

new eatable[33]
new targetable[101]

public plugin_init() {
	register_plugin("teamDevour","1.0","[SHN]Hoobs")
	register_concmd("sacrifice","prep_sacrifice")
	register_touch("player", "player", "devour_other")
	register_cvar("sv_devour","1",FCVAR_SERVER|FCVAR_SPONLY)
	register_cvar("sv_maxhpskulk","100",FCVAR_SERVER|FCVAR_SPONLY)
	register_cvar("sv_maxhpgorge","250",FCVAR_SERVER|FCVAR_SPONLY)
	register_cvar("sv_maxhplerk","200",FCVAR_SERVER|FCVAR_SPONLY)
	register_cvar("sv_maxhpfade","400",FCVAR_SERVER|FCVAR_SPONLY)
	register_cvar("sv_maxhponos","1200",FCVAR_SERVER|FCVAR_SPONLY)
	register_concmd("eatlist","printEats")	
	
	return PLUGIN_CONTINUE
}

public client_putinserver(id){ 
    eatable[id] = 0
} 

public printEats(id){
	new i
	new tEatable[101]
	new tUserName[101]
	if (ns_get_class(id) > 5){
		client_print(id,print_chat,"You must be an alien to consume others.")
		return PLUGIN_HANDLED
	}
		
	for (i=1; i<=32; i++) 
		{ 
   			if (eatable[i] == 1){
	   			get_user_name(i,tUserName,100)
	   			format(tEatable,100,"%s is consumeable",tUserName)
   				client_print(i,print_chat,tEatable)
			}
		} 
	return PLUGIN_HANDLED
}

public prep_sacrifice(id){ 
	if (get_cvar_num("sv_devour") == 1){
		if (ns_get_class(id) <= 5){
		    if(eatable[id] == 0) { 
				eatable[id] = 1 
				client_print(id,print_chat,"You can now be eaten by other aliens.")
				get_user_name(id,targetable,101)
				team_announce
			} 
		else{
			client_print(id,print_chat,"You can no longer be eaten by other aliens.")
			eatable[id] = 0 
			}
		}else client_print(id,print_chat,"You must be an alien to devour.")
	}else client_print(id,print_chat,"Consuming is currently disabled.")
	
	return PLUGIN_HANDLED
} 

public team_announce(){
	new i
	new tMsgStr[101]
	
	for (i=1; i<=32; i++) 
		{ 
   			if (ns_get_class(i) <= 5){
	   			format(tMsgStr,100,"%s has volunteered to be consumed.",targetable)
   				client_print(i,print_chat,tMsgStr)
			}
		} 
		
	return PLUGIN_CONTINUE
}

public devour_other(id,cid){
	if (get_cvar_num("sv_devour") == 1){
		if (eatable[cid] == 1){
			
			if (ns_get_class(id) <= 5){
				
				new youSize
				new otherSize
				new maxHP
				
				switch (ns_get_class(id)){
					case CLASS_SKULK: {
						youSize = 1
						maxHP = get_cvar_num("sv_maxhpskulk")
					}
					case CLASS_GORGE: {
						youSize = 2
						maxHP = get_cvar_num("sv_maxhpgorge")
					}
					case CLASS_LERK: {
						youSize = 2
						maxHP = get_cvar_num("sv_maxhplerk")
					}
					case CLASS_FADE: {
						youSize = 3
						maxHP = get_cvar_num("sv_maxhpfade")
					}
					case CLASS_ONOS: {
						youSize = 4
						maxHP = get_cvar_num("sv_maxhponos")
					}
				}
				
				switch (ns_get_class(cid)){
					case CLASS_SKULK: otherSize = 1
					case CLASS_GORGE: otherSize = 2
					case CLASS_LERK: otherSize = 2
					case CLASS_FADE: otherSize = 3
					case CLASS_ONOS: otherSize = 4
				}
							
				if (youSize >= otherSize){
					new youName[32]
					new otherName[32]
					
					get_user_name(id,youName,31)
					get_user_name(cid,otherName,31)
					
					new youHealth = get_user_health(id)
					new otherHealth = get_user_health(cid)
					
					if (otherHealth < 0){
						otherHealth = 0
					}
				
					set_user_health(id,youHealth + otherHealth )
					
					if (get_user_health(id) > maxHP){
						set_user_health(id,maxHP)
					}
					
					user_silentkill(cid)
					
					new msgStr[101]
					format(msgStr,100, "You just consumed %s.", otherName)
					client_print(id,print_chat,msgStr)
					format(msgStr,100, "You were just consumed by %s.", youName)
					client_print(cid,print_chat,msgStr)
					
					eatable[cid] = 0
				}else client_print(id,print_chat,"That player is too big to eat.")
			}
		}
	}
	
	return PLUGIN_HANDLED
}
