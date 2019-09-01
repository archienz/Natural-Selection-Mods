#include <amxmodx>
#include <ns>
#include <engine>
#include <fakemeta>

// me_gorgerecycle.sma 2.3.1
// made by mE @ psix.info

#define REC_ACCESS ADMIN_KICK  // admin access that is required to remove other players structures
#define REC_RESOWN 1           // 0 to give res to recycler / 1 to give res to owner


new g_buildextname[5][9]  = { "Defense",       "Movement",       "Offense",       "Sensory",       "Resource" }
new g_maxplayerindex
new gmsg_PlayHUDNot

new ua_choice[33]
new bool:ua_connected[33]

public plugin_init(){
  register_plugin("GorgeRecycle","2.3.2","mE @ psix.info")
  register_cvar("me_gorgerecycle", "2.3.2",4)
  
  if(!ns_is_combat()){
    register_clcmd("say /rec","recycle_menu")
    register_clcmd("say_team /rec","recycle_menu")
    
    gmsg_PlayHUDNot = get_user_msgid("PlayHUDNot")
    
    register_menucmd(register_menuid("Confirm Recycling"),MENU_KEY_1|MENU_KEY_2,"recycle_select")
  }
}

public client_putinserver(id){
  ua_connected[id] = true
  if(id > g_maxplayerindex) g_maxplayerindex = id
}

public client_disconnected(id){
  ua_connected[id] = false
  if(id == g_maxplayerindex){
    for(new i=g_maxplayerindex-1;i>0;i--){
      if(!ua_connected[i]) continue
      g_maxplayerindex = i
      break
    }
  }
}

public recycle_menu(id){
  if(ns_get_class(id) != CLASS_GORGE && !(get_user_flags(id) & REC_ACCESS)){
    client_print(id,print_chat,"[GorgeRecycle] Recycling only allowed for gorges")
    return PLUGIN_CONTINUE
  }
  new ent,access
  get_user_aiming(id,ent,access)
  if(!is_valid_ent(ent)){
    client_print(id,print_chat,"[GorgeRecycle] Point at the desired chamber and retry")
    return PLUGIN_CONTINUE
  }
  new iuser = pev(ent,pev_iuser3)-42
  if(iuser < 0 || iuser > 4){
    client_print(id,print_chat,"[GorgeRecycle] You can only recycle chambers")
    return PLUGIN_CONTINUE
  }
  new sname[32]
  format(sname,31,"%s Chamber",g_buildextname[iuser])
  new owner  = ns_get_struct_owner(ent)
  if(!is_user_connected(owner)) owner = 0
  if(!(get_user_flags(id) & REC_ACCESS) && owner != id && owner != 0){
    client_print(id,print_chat,"[GorgeRecycle] You're not the owner of this %s",sname)
    return PLUGIN_CONTINUE
  }
  new Float:dist = entity_range(id,ent)
  if(dist > 200.0){
    client_print(id,print_chat,"[GorgeRecycle] You're too far away from this %s",sname)
    return PLUGIN_CONTINUE
  }
  
  ua_choice[id]=ent
  new Float:costs
  if(iuser == 4){
    costs = 15.0
  }else{
    costs = 10.0
  }
  new Float:dres = costs/2.0
  if(pev(ua_choice[id],pev_sequence)==0) dres = costs

  new ownerstring[33]
  if(owner == id){
    ownerstring = "your"
  }else if(owner == 0){
    ownerstring = "this"
  }else{
    get_user_name(owner,ownerstring,32)
    format(ownerstring,32,"%s's",ownerstring)
  }
  new keys = MENU_KEY_1|MENU_KEY_2
  new menu_msg[256]
  format(menu_msg,255,"Confirm Recycling: ^n^nPlease confirm recycling of %s^n%s%s^n+%.1f res^n^n1.  Yes^n2.  No",ownerstring,(pev(ua_choice[id],pev_sequence)==0)?"unbuilt ":"",sname,dres)
  show_menu(id,keys,menu_msg,5)
  
  return PLUGIN_CONTINUE
}

public recycle_select(id,key){
  new ent = ua_choice[id]
  if(!is_valid_ent(ent)) return PLUGIN_HANDLED
  new iuser = pev(ent,pev_iuser3)-42
  if(iuser < 0 || iuser > 4) return PLUGIN_HANDLED
  new sname[32]
  format(sname,31,"%s Chamber",g_buildextname[iuser])
  if(key==0){
    server_print("[GorgeRecycle] Recycling %s",sname)
    new Float:costs
    if(iuser == 4){
      costs = 15.0
    }else{
      costs = 10.0
    }
    new Float:dres = (costs/2.0)
    if(pev(ent,pev_sequence)==0) dres = costs

    #if REC_RESOWN == 0
      ns_set_res(id,ns_get_res(id)+dres)
    #else
      new owner = ns_get_struct_owner(ent)
      if(!is_user_connected(owner)) owner = 0
      if(owner){                                                                // if owner exists
        ns_set_res(owner,ns_get_res(owner)+dres)
      }else{                                                                    // distrubute res for the whole team otherwise
        new aliens
        for(new i=1;i<=g_maxplayerindex;i++){
          if(!ua_connected[i]) continue
          if(pev(i,pev_team)==2) aliens++
        }
        if(aliens == 0) return PLUGIN_HANDLED                                   // just in case - although this should never happen :)
        if(aliens > 1) client_print(id,print_chat,"[GorgeRecycle] Distributing %.1f res to %i aliens because owner is unknown",dres,aliens)
        dres = dres / aliens
        for(new i=1;i<=g_maxplayerindex;i++){
          if(!ua_connected[i]) continue
          if(pev(i,pev_team)!=2) continue
          ns_set_res(i,ns_get_res(i)+dres)
        }
      }
    #endif
    set_msg_block(gmsg_PlayHUDNot,BLOCK_ONCE)                                   // this _should_ prevent the "structure is under attack" sound to be player
    fakedamage(ent,"trigger_hurt",10000.0,1)                                    // KILL the chamber
    client_print(id,print_chat,"[GorgeRecycle] Received %.1f resources for recycling %s",dres,sname)
  }else{
    client_print(id,print_chat,"[GorgeRecycle] Canceled recycling of %s",sname)
  }
  return PLUGIN_HANDLED
}
