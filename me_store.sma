////////////////////////////////////////////////////////////////////////////////
//                            Information                                     //
////////////////////////////////////////////////////////////////////////////////
/*
Store (v6.2 - 26.08.06)
By: mE @ PsiX.org

What does this plugin do?
  The idea of this very useful plugin is based on -Asylum-Skitzo's "EquipStore".
  The commander can store the equipment (JPs,HAs and weapons) inside of the PTL / AL by simply
  dropping them in range of the PTL / AL. Also, when marines drop their weapons manually,
  they get stored, too. The marines can retrieve the items by pressing their USE-key on the
  store and select the desired item from a menu.
  As an optional addition, this plugin can also be used similar to [WHO]Them's Phase EQ
  plugin. Medpacks and ammopacks get stored inside the armory and can be requested via
  the radio commands.
  So this is a 2-in-1 plugin:
    o EquipStore / Equipment Store  (inspired by -Asylum-Skitzo)
    o Phase EQ                      (inspired by [WHO]Them)

Author
  Mail           : mE @ PsiX.org
  WWW            : www.PsiX.org
  Other projects : PsiX.org CMS, NSBrowser.org, Unchain, GorgeRecycle, LaserMines

Thanks to
  o NSmod.org for such a great NS modding community forum
  o -Asylum-Skitzo and [WHO]Them for their great original plugins
  o WhitePanther for his continous support and beta-testing
  o Steve_Dudenhoeffer, CheesyPeteza and everybody else who helped me or by who's code I got "inspired" ;)                                                                        //
  o Everybody who ever said "thanks" for all my effort :)
*/
////////////////////////////////////////////////////////////////////////////////
//                          Basic Configuration                               //
////////////////////////////////////////////////////////////////////////////////

/* BITMASK (1 + 2)
1 - enable Equipment Store
2 - enable Phase EQ
4 - enable Auto Equipment (requires Equipment Store) (! TO BE IMPLEMENTED !)
*/
#define MODE_PLUGIN 3

////////////////////////////////////////////////////////////////////////////////
//                        Detailed Configuration                              //
//                    (keep for recommended settings)                         //
////////////////////////////////////////////////////////////////////////////////

/* INT (1)
0 - keep items if no stores remain
1 - vanish items if no stores remain
2 - drop items if the last store is destroyed (! TO BE IMPLEMENTED !)
*/
#define MODE_LOSE 1

/* BITMASK (1 + 2 + 4 + 8)
1 - enable phase-effect
2 - enable laser beam
4 - enable laser circle
8 - enable sound
*/
#define MODE_EFFECT 15

/* BITMASK (1 + 2 + 4)
1 - inform players about this plugin (Ignored if HELPER = 1)
2 - inform commander if an item is empty
4 - enable "say /store" to see remaining items
*/
#define MODE_INFO 7

/* INT (10)
# - Minimum health (in %) a store needs to operate
*/
#define MIN_HEALTH_PERCENT 10

/* FLOAT (512.0)
# - Maximum range to pick up items
*/
#define RANGE_PICKUP 512.0

/* FLOAT (128.0)
# - Maximum range to USE stores
*/
#define RANGE_USE 128.0

/* FLOAT (256.0)
# - Range between player and armory required to be allowed to request
    (to avoid marines requesting med-/ammopacks while standing next to an armory)
*/
#define RANGE_REQUEST 256.0

/* FLOAT (1.0) (! TO BE IMPLEMENTED !)
# - Delay between requesting med-/ammopacks and actual delivery
    (to avoid marines getting instant health in battles)
*/
#define DELAY_REQUEST_DELIVERY 1.0

/* FLOAT (5.0)
# - Delay in seconds between requesting medpacks
    (to avoid marines becoming invulnerable due to spam)
*/
#define DELAY_REQUEST_MEDPACK 5.0

/* FLOAT (0.5)
# - Delay in second between choosing multiple items from store
    (to avoid spamming the floor with items)
*/
#define DELAY_CHOOSE 1.0

/* INT (99)
-1 - No limit
#  - Limit store to this amount of items per type
*/
#define MAX_PER_TYPE 99

/* INT (50)
# - Remember ammo for this amount of weapons
    (Remember ammo of last 50 weapons stored to make sure we're not getting
    unlimited ammo from the store)
*/
#define MAX_REMEMBER_AMMO  50

/*
INT (1)
0 - Do use default helper output
1 - Use the "Helper" plugin! (recommended)
*/
#define HELPER 1

////////////////////////////////////////////////////////////////////////////////
//      NO need to edit anything below unless you know what you're doing      //
////////////////////////////////////////////////////////////////////////////////

#if MODE_PLUGIN & 4
  #if !(MODE_PLUGIN & 1)
    #include <MODE_PLUGIN 4 requires MODE_PLUGIN 1>
  #endif
#endif

#include <amxmodx>
#include <ns>
#include <engine>
#include <fakemeta>
#if HELPER == 1
  #include <helper>
#endif

#define PLUGIN_VERSION "6.2"

new g_ammo[MAX_REMEMBER_AMMO][3]    // itemtype,primary ammo,secondary ammo
new g_ammo_num
new bool:g_ingame = false


#if MODE_PLUGIN & 1
  new g_item_min = 0
  #if MODE_PLUGIN & 2
    #define PLUGIN_NAME "Store & Phase EQ"
    new g_item_max = 11
  #else
    #define PLUGIN_NAME "Store"
    new g_item_max = 9
  #endif
#else
  #define PLUGIN_NAME "Phase EQ"
  new g_item_min = 9
  new g_item_max = 11
#endif


new g_item_count[11]
new g_item_class[11][] = {
  "item_jetpack",
  "item_heavyarmor",
  "weapon_shotgun",
  "weapon_heavymachinegun",
  "weapon_grenadegun",
  "weapon_machinegun",
  "weapon_pistol",
  "weapon_welder",
  "weapon_mine",
  "item_health",
  "item_genericammo"
}
new g_item_name[11][] = {
  "JetPack",
  "HeavyArmor",
  "ShotGun",
  "HeavyMachineGun",
  "GrenadeLauncher",
  "LightMachineGun",
  "Pistol",
  "Welder",
  "Minepack",
  "Medpack",
  "Ammopack"
}
new g_item_store[11] = {
  28,
  28,
  27,
  27,
  27,
  27,
  27,
  27,
  27,
  41,
  41
}

#if MODE_PLUGIN & 1
  new ua_entuse[33] = { -1,... }
#endif

#if MODE_PLUGIN & 2
  new Float:ua_medtime[33]
#endif

new bool:ua_connected[33]
new Float:ua_storetime[33]

new g_maxplayerindex
new g_maxplayers
new g_maxentities
#if MODE_EFFECT & 1
  new g_teleportevent
#endif
#if MODE_EFFECT & 2 || MODE_EFFECT & 4
  new g_lasersprite
  new g_teamcolors[3][3]                     // team colors (used for lasereffects)

  public plugin_precache(){
    g_lasersprite = precache_model("sprites/laserbeam.spr")
  }
#endif

public plugin_init(){
  register_plugin(PLUGIN_NAME,PLUGIN_VERSION,"mE @ PsiX.org")
  register_cvar("me_store",PLUGIN_VERSION,FCVAR_SERVER)

  if(ns_is_combat() || (ns_get_build("team_command",0) >= 2 && ns_get_build("team_hive",0) == 0) || (ns_get_build("team_command",0) == 0 && ns_get_build("team_hive",0) >= 2)){
    pause("ad")
    return
  }
  
  #if MODE_EFFECT & 1
    g_teleportevent = precache_event(1,"events/Teleport.sc")
  #endif
  
  g_maxplayers = get_maxplayers()
  g_maxentities = get_global_int(GL_maxEntities)

  register_forward(FM_RemoveEntity,"entity_remove")
  register_forward(FM_SetModel,"entity_setmodel")
    
  #if MODE_PLUGIN & 1
    register_menucmd(register_menuid("[Store] Choose"),MENU_KEY_1|MENU_KEY_2|MENU_KEY_3|MENU_KEY_4|MENU_KEY_5|MENU_KEY_6|MENU_KEY_7|MENU_KEY_8,"menu_choose")
  #endif
  #if MODE_PLUGIN & 2
    register_impulse(10,"request_medpack")
    register_impulse(11,"request_ammopack")
  #endif
  #if MODE_INFO & 4
    register_clcmd("say /store","say_store")
    register_clcmd("say_team /store","say_store")
  #endif

  register_event("Countdown","round_start", "ac")
  register_event("GameStatus","round_end", "ab", "1=2" )

  #if MODE_EFFECT & 2 || MODE_EFFECT & 4
    g_teamcolors[0] = { 255,255,255 }
    g_teamcolors[1] = {   0,170,255 }
    g_teamcolors[2] = { 200,100,  0 }
  #endif
  return
}

#if HELPER == 1
  public client_help(id){
    #if MODE_PLUGIN & 1
      #if MODE_PLUGIN & 2
        help_add("Information","The commander can store the equipment inside of^nthe buildings (stores) and marines can use them to obtain the stored items.^nAlso marines can use their menu to request health and ammo^nand it will be delivered automatically")
        help_add("Equipment","- JP and HA stored inside the ProtoTypeLab^n- Weapons stored inside the ArmsLab^n- Med- and Ammopacks inside the PhaseGate")
      #else
        help_add("Information","The commander can store the equipment inside of^nthe buildings (stores) and marines can use them to obtain the store equipment")
        help_add("Equipment","- JP and HA stored inside the ProtoTypeLab^n- Weapons stored inside the ArmsLab")
      #endif

      help_add("Usage","You can obtain the items by pressing your USE-key^non the store and select the desired item from a menu")
    #else
      help_add("Information","The commander can store med- and ammopacks^ninside the PG by simply dropping them in range.^nPlayer can then use their menu to request health/ammo^nand it will be delivered automatically")
    #endif
    
    #if MODE_INFO & 4
      help_add("Commands","Say /store to see remaining items")
    #endif
  }

  public client_advertise(id){
    if(pev(id,pev_team) == 1) return PLUGIN_CONTINUE
    return PLUGIN_HANDLED
  }
#endif

////////////////////////////////////////////////////////////////////////////////
//                                CLIENT ACTIONS                              //
////////////////////////////////////////////////////////////////////////////////

#if HELPER == 0
  #if MODE_INFO & 1
    public client_changeteam(id,newteam,oldteam){
      if(newteam == 1 && g_ingame){
        remove_task(id+100)
        set_task(2.0,"say_info",id+100)
      }
    }
  #endif
#endif

#if MODE_PLUGIN & 1
  public client_changeclass(id,newclass,oldclass){
    if(ua_entuse[id]){
      menu_hide(id)
    }
    if(newclass == CLASS_MARINE || newclass == CLASS_JETPACK || newclass == CLASS_HEAVY){
      ua_entuse[id] = 0
    }else{
      ua_entuse[id] = -1
    }
  }

  public client_PreThink(id){
    if(ua_entuse[id] == -1) return PLUGIN_CONTINUE
    if(entity_get_int(id,EV_INT_button) & IN_USE){
      if(ua_entuse[id]){
        new ent,dummy
        get_user_aiming(id,ent,dummy)
        if(ent != ua_entuse[id]){
          ua_entuse[id] = 0
          menu_hide(id)
          return PLUGIN_CONTINUE
        }
        if(!ehp(ent) || entity_range(ent,id) > RANGE_USE){
          ua_entuse[id] = 0
          menu_hide(id)
        }
      }else{
        new ent,dummy
        get_user_aiming(id,ent,dummy)
        if(!is_valid_ent(ent)){
          return PLUGIN_CONTINUE
        }
        if(!is_built(ent)){
          return PLUGIN_CONTINUE
        }
        if(!ehp(ent)){
          return PLUGIN_CONTINUE
        }
        if(entity_range(ent,id) > RANGE_USE){
          return PLUGIN_CONTINUE
        }
        new found
        new type = entity_get_int(ent,EV_INT_iuser3)
        for(new i=g_item_min;i<g_item_max;i++){
          if(g_item_store[i] != type) continue
          if(type == 41) continue                  // dont allow using of PGs
          found = 1
          break
        }
        if(!found){
          return PLUGIN_CONTINUE
        }
        ua_entuse[id] = ent
        menu_show(id)
        client_cmd(id,"spk common/wpn_select.wav")
      }
    }else{
      if(ua_entuse[id]){
        ua_entuse[id] = 0
        menu_hide(id)
      }
    }
    return PLUGIN_CONTINUE
  }
#endif

public client_disconnect(id){
  #if MODE_PLUGIN & 1
    ua_entuse[id] = -1
  #endif
  ua_connected[id] = false
  remove_task(id+100)
  remove_task(id+200)
  
  if(id == g_maxplayerindex){
    new maxid
    for(new i=1;i<=g_maxplayerindex;i++){
      if(!ua_connected[i]) continue
      if(id == i) continue
      maxid = i
    }
    g_maxplayerindex = maxid
  }
}

public client_putinserver(id){
  ua_connected[id] = true
  if(id > g_maxplayerindex){
    g_maxplayerindex = id
  }
}
#if MODE_PLUGIN & 4
  public client_spawn(id){
    if(ua_entuse[id] == -1) return PLUGIN_CONTINUE
    
    new item = -1
    if(g_item_count[2] > 0){
      item = 2
    }
    if(g_item_count[3] > 0){
      item = 3
    }
    if(item == -1) return PLUGIN_CONTINUE
    for(new ent=g_maxentities;ent>g_maxplayers;ent--){
      if(!is_valid_ent(ent)) continue
      if(entity_get_int(id,EV_INT_iuser3) != g_item_store[item]) continue
      if(!is_built(ent)) continue
      if(!ehp(ent)) continue
      if(entity_range(id,ent) > RANGE_PICKUP) continue
      
      #if MODE_INFO & 2
        if(!g_item_count[item]){
          for(new i=1;i<=g_maxplayerindex;i++){
            if(!ua_connected[i]) continue
            if(ns_get_class(i) != CLASS_COMMANDER) continue
            client_print(i,print_chat,"[Store] No more %ss remaining",g_item_name[item])
          }
        }
      #endif
      store_give(id,item)
      break
    }
    return PLUGIN_CONTINUE
  }
#endif

////////////////////////////////////////////////////////////////////////////////
//                              ACTUAL STORING                                //
////////////////////////////////////////////////////////////////////////////////

stock store_add(ent){
  if(ent <= g_maxplayers) return 0
  if(task_exists(ent+1000)) return 0

  set_task(0.5,"store_check",ent+1000)
  return 1
}

public store_check(ent){                                                        // check a certain entity to be picked up
  ent -= 1000
  if(!is_valid_ent(ent)) return -1                                              // will re-check if the entity can't be stored temporarily
  if(entity_get_int(ent,EV_INT_movetype) == MOVETYPE_FOLLOW){                   // stop checking it this entity isn't supposed to be stored anyway
    return 0
  }
  new classname[33]
  entity_get_string(ent,EV_SZ_classname,classname,32)
  new item = -1
  for(new i=g_item_min;i<g_item_max;i++){
    if(equal(classname,g_item_class[i])){
      item = i
      break
    }
  }
  if(item == -1){                                                               // item not supposed to be stored
    return 0
  }
  /*
  if(g_item_count[item] >= MAX_PER_TYPE){         // store size exceeded
    set_task(5.0,"store_check",ent+1000)
    return 0
  }
  */

  new s_count
  new s_ent[50]
  for(new i=g_maxentities;i>g_maxplayers;i--){
    if(!is_valid_ent(i)) continue
    if(!ehp(i)) continue
    if(g_item_store[item] != 41 && !is_built(i)) continue
    if(entity_get_int(i,EV_INT_iuser3) != g_item_store[item]) continue
    s_ent[s_count++] = i
    if(s_count == 50) break
  }
  if(!s_count){                                                          // no active store found
    set_task(10.0,"store_check",ent+1000)
    return 0
  }
  new found
  new Float:minrange = RANGE_PICKUP
  for(new i=0;i<s_count;i++){
    new Float:r = entity_range(ent,s_ent[i])
    if(r < minrange){
      found = s_ent[i]
      #if MODE_EFFECT > 0
        minrange = r
      #else
        break
      #endif
    }
  }
  if(!found){                                                                   // no stores in range
    set_task(10.0,"store_check",ent+1000)
    return 0
  }
  #if MODE_EFFECT & 2 || MODE_EFFECT & 4
    effect_laser(ent,found,1)
  #endif
  #if MODE_EFFECT & 8
    emit_sound(ent,CHAN_AUTO,"misc/phasein.wav",1.0,ATTN_NORM,0,PITCH_NORM)
  #endif

  g_item_count[item]++

  if(item < 9 && item != 5 && g_item_count[item] == MAX_PER_TYPE){
    for(new i=1;i<=g_maxplayerindex;i++){
      if(!ua_connected[i]) continue
      if(ns_get_class(i) == CLASS_COMMANDER) client_print(i,print_chat,"[Store] Limit of %d %ss reached",MAX_PER_TYPE,g_item_name[item])
    }
  }
  #if MAX_REMEMBER_AMMO > 0
    if(item < 9){
      g_ammo[g_ammo_num][0] = item
      g_ammo[g_ammo_num][1] = ns_get_weap_clip(ent)
      g_ammo[g_ammo_num][2] = 0
      g_ammo_num = (g_ammo_num + 1) % MAX_REMEMBER_AMMO
    }
  #endif
  
  remove_entity(ent)
  return 1
}

stock store_want(id,item){
  if(g_item_count[item]){
    #if MODE_EFFECT & 1
      effect_pg(id)
    #endif
    #if MODE_EFFECT & 8
      effect_sound(id)
    #endif
    store_give(id,item)

    ua_storetime[id] = get_gametime() + DELAY_CHOOSE
    client_print(id,print_chat,"[Store] %s applied",g_item_name[item])
    #if MODE_INFO & 2
      if(!g_item_count[item]){
        for(new i=1;i<=g_maxplayerindex;i++){
          if(!ua_connected[i]) continue
          if(ns_get_class(i) != CLASS_COMMANDER) continue
          client_print(i,print_chat,"[Store] No more %ss remaining",g_item_name[item])
        }
      }
    #endif
  }else{
    client_print(id,print_chat,"[Store] %s not available!",g_item_name[item])
  }
  return 0
}

stock store_give(id,item){
  if(equal(g_item_class[item],"item_jetpack")){ // jp
    if(ns_get_mask(id,MASK_HEAVYARMOR)){
      new Float:armor
      if(ns_get_mask(id,MASK_ARMOR3)){
        armor = 90.0
      }else if(ns_get_mask(id,MASK_ARMOR2)){
        armor = 70.0
      }else if(ns_get_mask(id,MASK_ARMOR1)){
        armor = 50.0
      }else{
        armor = 30.0
      }
      entity_set_float(id,EV_FL_armorvalue,armor)
      ns_set_mask(id,MASK_HEAVYARMOR,0)
    }
    ns_set_mask(id,MASK_JETPACK,1)
    emit_sound(id,CHAN_AUTO,"items/pickup_jetpack.wav",VOL_NORM,ATTN_NORM,0,PITCH_NORM)
    ns_set_jpfuel(id,100.0)
  }else if(equal(g_item_class[item],"item_heavyarmor")){  // heavy
    ns_set_mask(id,MASK_JETPACK,0)
    ns_set_mask(id,MASK_HEAVYARMOR,1)
    emit_sound(id,CHAN_AUTO,"items/pickup_heavy.wav",VOL_NORM,ATTN_NORM,0,PITCH_NORM)
    new Float:armor
    if(ns_get_mask(id,MASK_ARMOR3)){
      armor = 290.0
    }else if(ns_get_mask(id,MASK_ARMOR2)){
      armor = 260.0
    }else if(ns_get_mask(id,MASK_ARMOR1)){
      armor = 230.0
    }else{
      armor = 200.0
    }
    entity_set_float(id,EV_FL_armorvalue,armor)
    new clip,ammo
    new weapon = get_user_weapon(id,clip,ammo)
    if (weapon==WEAPON_PISTOL){
      entity_set_string(id,EV_SZ_viewmodel,"models/v_hg_hv.mdl")
    }else if(weapon==WEAPON_GRENADE_GUN){
      entity_set_string(id,EV_SZ_viewmodel,"models/v_gg_hv.mdl")
    }else if(weapon==WEAPON_GRENADE){
      entity_set_string(id,EV_SZ_viewmodel,"models/v_gr_hv.mdl")
    }else if(weapon==WEAPON_HMG){
      entity_set_string(id,EV_SZ_viewmodel,"models/v_hmg_hv.mdl")
    }else if(weapon==WEAPON_KNIFE){
      entity_set_string(id,EV_SZ_viewmodel,"models/v_kn_hv.mdl")
    }else if(weapon==WEAPON_LMG){
      entity_set_string(id,EV_SZ_viewmodel,"models/v_mg_hv.mdl")
    }else if(weapon==WEAPON_MINE){
      entity_set_string(id,EV_SZ_viewmodel,"models/v_mine_hv.mdl")
    }else if(weapon==WEAPON_SHOTGUN){
      entity_set_string(id,EV_SZ_viewmodel,"models/v_sg_hv.mdl")
    }else if(weapon==WEAPON_WELDER){
      entity_set_string(id,EV_SZ_viewmodel,"models/v_welder_hv.mdl")
    }
  }else if(equal(g_item_class[item],"item_health")){  // health
    new Float:health = entity_get_float(id,EV_FL_health) + 50.0
    new Float:maxhealth = entity_get_float(id,EV_FL_max_health)
    if(maxhealth < 100.0) maxhealth = 100.0
    if(health > maxhealth){
      health = maxhealth
    }
    entity_set_float(id,EV_FL_health,health)
    emit_sound(id,CHAN_AUTO,"items/health.wav",VOL_NORM,ATTN_NORM,0,PITCH_NORM)

    g_item_count[item]--
    return 1
  //}else if(item == 10){  // ammo

  }else{
    new entity = create_entity(g_item_class[item])
    if(!is_valid_ent(entity)) return 0

    new Float:origin[3]
    entity_get_vector(id,EV_VEC_origin,origin)
    for(new i=0;i<MAX_REMEMBER_AMMO;i++){
      if(g_ammo[i][0] == item){
        ns_set_weap_clip(entity,g_ammo[i][1])
        g_ammo[i][0] = 0
        g_ammo[i][1] = 0
        g_ammo[i][2] = 0
        break
      }
    }
    entity_set_origin(entity,origin)
    entity_set_int(entity,EV_INT_team,entity_get_int(id,EV_INT_team))
    //DispatchKeyValue(entity,"lifetime","-1")
    DispatchSpawn(entity)

    fake_touch(id,entity)
    store_add(entity)
  }
  g_item_count[item]--
  return 1
}

////////////////////////////////////////////////////////////////////////////////
//                               ENTITY FUNCTIONS                             //
////////////////////////////////////////////////////////////////////////////////

public entity_setmodel(ent,model[]){
  if(equal(model,"models/w_",9)){
    store_add(ent)
  }
}

public entity_remove(ent){
  if(task_exists(ent+1000)){
    remove_task(ent+1000)
  }
  #if MODE_LOSE != 0
    new found
    new type = entity_get_int(ent,EV_INT_iuser3)
    for(new i=g_item_min;i<g_item_max;i++){
      if(g_item_store[i] != type) continue
      found = 1
      break
    }
    if(!found){
      return
    }
    new s_count
    for(new i=g_maxentities;i>g_maxplayers;i--){
      if(!is_valid_ent(i)) continue
      if(!ehp(i)) continue
      if(type != 41 && !is_built(i)) continue
      if(entity_get_int(i,EV_INT_iuser3) != type) continue
      if(i == ent) continue
    
      s_count++
    }
    if(s_count) return
    
    #if MODE_LOSE == 1
      for(new i=g_item_min;i<g_item_max;i++){
        if(g_item_store[i] != type) continue
        
        g_item_count[i] = 0
      }
    #endif
    #if MODE_LOSE == 2
      // create ent
      for(new i=g_item_min;i<g_item_max;i++){
        if(g_item_store[i] != type) continue
        // save count to ent
        g_item_count[i] = 0
      }
      // place ent
    #endif
    return
  #endif
}
////////////////////////////////////////////////////////////////////////////////
//                               CLIENT COMMANDS                              //
////////////////////////////////////////////////////////////////////////////////

public say_info(id){
  id -= 100
  client_print(id,print_chat,"[Store] Equipment Store v%s enabled. Equipment is stored inside of the PTL/AL",PLUGIN_VERSION)
  #if MODE_INFO & 4
    client_print(id,print_chat,"[Store] Say /store to see the amount of items stored")
  #endif
}

#if MODE_INFO & 4
  public say_store(id){
    if(entity_get_int(id,EV_INT_team)==1 && g_ingame){
      new output[128]
      for(new i=g_item_min;i<g_item_max;i++){
        if(!g_item_count[i]) continue
        format(output,127,"%s: %s %d ",output,g_item_name[i],g_item_count[i])
      }
      if(equal(output,"")) output = ": <none>"
      client_print(id,print_chat,"[Store] Equipment remaining%s",output)
    }
  }
#endif

#if MODE_PLUGIN & 2
  public request_medpack(id){                                                    // requesting medpack
    if(entity_get_int(id,EV_INT_team)!= 1 || entity_get_int(id,EV_INT_deadflag)!=0 || ns_get_mask(id,MASK_DIGESTING) != 0 || !g_ingame) return PLUGIN_CONTINUE
    new item = -1
    for(new i=g_item_min;i<g_item_max;i++){
      if(!equal(g_item_class[i],"item_health")) continue
      item = i
      break
    }
    if(item == -1) return PLUGIN_CONTINUE
    if(need_health(id,item)){
      if(g_item_count[item]){
        if(ua_medtime[id] <= get_gametime()){
          ua_medtime[id]=get_gametime()+DELAY_REQUEST_MEDPACK
          store_want(id,item)
        }else{
          client_print(id,print_chat,"[Store] Medpack not available right now! Wait %.1f seconds between requesting medpacks!",ua_medtime[id]-get_gametime())
        }
        return PLUGIN_HANDLED
      }else{
        return PLUGIN_CONTINUE
      }
    }
    return PLUGIN_HANDLED
  }

  public request_ammopack(id){                                                   // requesting ammopack
    if(entity_get_int(id,EV_INT_team)!= 1 || entity_get_int(id,EV_INT_deadflag)!=0 || ns_get_mask(id,MASK_DIGESTING) != 0 || !g_ingame) return PLUGIN_CONTINUE
    new item = -1
    for(new i=g_item_min;i<g_item_max;i++){
      if(!equal(g_item_class[i],"item_genericammo")) continue
      item = i
      break
    }
    if(item == -1) return PLUGIN_CONTINUE
    if(need_ammo(id)){
      if(g_item_count[item]){
        store_want(id,item)
        return PLUGIN_HANDLED
      }else{
        return PLUGIN_CONTINUE
      }
    }
    return PLUGIN_HANDLED
  }
#endif

////////////////////////////////////////////////////////////////////////////////
//                                MENU ACTIONS                                //
////////////////////////////////////////////////////////////////////////////////
#if MODE_PLUGIN & 1

  public menu_choose(id,key){
    if(!is_valid_ent(ua_entuse[id])) return PLUGIN_HANDLED
    menu_show(id)
    if(ua_storetime[id] > get_gametime()) return PLUGIN_HANDLED
    new n
    new type = entity_get_int(ua_entuse[id],EV_INT_iuser3)
    for(new i=g_item_min;i<g_item_max;i++){
      if(g_item_store[i] != type) continue
      if(n++ != key) continue

      store_want(id,i)
      return PLUGIN_HANDLED
    }
    return PLUGIN_HANDLED
  }

  public menu_hide(id){
    remove_task(id+200)
    show_menu(id,MENU_KEY_8,"^n^n",1)
  }

  public menu_show(id){
    if(id > 200) id -= 200
    if(is_valid_ent(ua_entuse[id])){
      new type = entity_get_int(ua_entuse[id],EV_INT_iuser3)
      
      new menu_msg[256]
      format(menu_msg,255,"[Store] Choose item:^n")
      new keys = (1<<8),n
      for(new i=g_item_min;i<g_item_max;i++){
        if(g_item_store[i] != type) continue
        
        new bool:go = (g_item_count[i] > 0)
        if(go && type == 28){ // type PTL
          if(ns_get_mask(id,MASK_HEAVYARMOR) || ns_get_mask(id,MASK_JETPACK)) go = false
        }
        if(go) keys |= (1<<n)
        format(menu_msg,255,"%s^n%d.  %02d  %s",menu_msg,++n,g_item_count[i],g_item_name[i])
      }
      show_menu(id,keys,menu_msg,6)
      set_task(5.5,"menu_show",id+200)
    }
  }
  
#endif
////////////////////////////////////////////////////////////////////////////////
//                                MESSAGES                                    //
////////////////////////////////////////////////////////////////////////////////

public round_start(){
  if(!g_ingame){
    for(new i=g_item_min;i<g_item_max;i++){
      g_item_count[i] = 0
    }
    for(new i=0;i<MAX_REMEMBER_AMMO;i++){
      g_ammo[i][0] = 0
      g_ammo[i][1] = 0
      g_ammo[i][2] = 0
    }
    g_ammo_num = 0
    g_ingame = true
    #if HELPER == 0
      #if MODE_INFO & 1
        team_print(1,print_chat,"Equipment Store enabled!")
      #endif
    #endif
  }
}

public round_end(){
  if(g_ingame){
    g_ingame = false
    for(new i=g_item_min;i<g_item_max;i++){
      g_item_count[i] = 0
    }
    for(new i=0;i<MAX_REMEMBER_AMMO;i++){
      g_ammo[i][0] = 0
      g_ammo[i][1] = 0
      g_ammo[i][2] = 0
    }
    g_ammo_num = 0
  }
}

////////////////////////////////////////////////////////////////////////////////
//                             SPECIAL EFFECTS                                //
////////////////////////////////////////////////////////////////////////////////

#if MODE_EFFECT & 1
  stock effect_pg(id){
    new Float:origin[3]
    entity_get_vector(id,EV_VEC_origin,origin)
    origin[2] += 16.0
    playback_event(0,id,g_teleportevent,0.0,origin,Float:{0.0,0.0,0.0},0.0,0.0,0,0,0,0)
  }
#endif

#if MODE_EFFECT & 8
  stock effect_sound(id){         // phasein
    emit_sound(id,CHAN_ITEM,"misc/transport.wav",1.0,ATTN_NORM,0,PITCH_NORM)
  }
#endif

#if MODE_EFFECT & 2 || MODE_EFFECT & 4
  stock effect_laser(startent,targetent,team){
    new Float:start[3]
    entity_get_vector(startent,EV_VEC_origin,start)
    new istart[3]
    istart[0] = floatround(start[0])
    istart[1] = floatround(start[1])
    istart[2] = floatround(start[2])+1


    #if MODE_EFFECT & 2
      //message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
      message_begin(MSG_PVS,SVC_TEMPENTITY,istart)
      write_byte(1) 	// TE_BEAMENTPOINTS
      write_short(targetent)    // start ent
      write_coord(istart[0])
      write_coord(istart[1])
      write_coord(istart[2])
      write_short(g_lasersprite)// laserbeam sprite
      write_byte(0)		// starting frame
      write_byte(0)   	// frame rate
      write_byte(2)		// life in 0.1s
      write_byte(10)		// line width in 0.1u
      write_byte(0)		// noise in 0.1u
      write_byte(g_teamcolors[team][0])	// r
      write_byte(g_teamcolors[team][1])	// g
      write_byte(g_teamcolors[team][2])	        // b
      write_byte(150)	// brightness
      write_byte(3)  	// scroll speed
      message_end()
    #endif
    
    #if MODE_EFFECT & 4
      //message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
      message_begin(MSG_PVS,SVC_TEMPENTITY,istart)
      write_byte(19)	// TE_BEAMTORS
      write_coord(istart[0])
      write_coord(istart[1])
      write_coord(istart[2])
      write_coord(istart[0])
      write_coord(istart[1])
      write_coord(istart[2]+200)
      write_short(g_lasersprite)// laserbeam sprite
      write_byte(0)		// starting frame
      write_byte(0)   	// frame rate
      write_byte(5)		// life in 0.1s
      write_byte(1)		// line width in 0.1u
      write_byte(0)		// noise in 0.1u
      write_byte(g_teamcolors[team][0])	// r
      write_byte(g_teamcolors[team][1])	        // g
      write_byte(g_teamcolors[team][2])	        // b
      write_byte(150)	// brightness
      write_byte(3)  	// scroll speed
      message_end()
    #endif
  }
#endif

////////////////////////////////////////////////////////////////////////////////
//                                  HELPERS                                   //
////////////////////////////////////////////////////////////////////////////////

#if MODE_PLUGIN & 2
  stock need_health(id,item){                                                   // check if player needs medpack + not in range of armory
    for(new ent=g_maxentities;ent>g_maxplayers;ent--){
      if(!is_valid_ent(ent)) continue
      new type = entity_get_int(ent,EV_INT_iuser3)
      if(type != 25 && type != 26) continue
      if(entity_range(id,ent) < RANGE_REQUEST){
        client_print(id,print_chat,"[Store] Can't apply medpacks while being in range of an Armory")
        return 0
      }
    }
    new health = floatround(entity_get_float(id,EV_FL_health))
    if(g_item_count[item] == 0) return 1
    if(g_item_count[item] >  0 && health <= 85) return 1
    if(g_item_count[item] >  5 && health <= 90) return 1
    if(g_item_count[item] > 10 && health <= 95) return 1
    if(g_item_count[item] > 30 && health < 100) return 1
    client_print(id,print_chat,"[Store] Can't apply medpacks while having enough health (%dhp %d medpacks)",health,g_item_count[item])
    return 0
  }

  stock need_ammo(id){                                                      // check if player is not in range of armory
    for(new ent=g_maxentities;ent>g_maxplayers;ent--){
      if(!is_valid_ent(ent)) continue
      new type = entity_get_int(ent,EV_INT_iuser3)
      if(type != 25 && type != 26) continue
      if(entity_range(id,ent) < RANGE_REQUEST){
        client_print(id,print_chat,"[Store] Can't apply ammopacks while being in range of an Armory")
        return 0
      }
    }
    return 1
  }
#endif

stock is_built(ent){
  return (entity_get_int(ent,EV_INT_sequence) != 0)
}

stock ehp(ent){
  if(ns_get_mask(ent,MASK_RECYCLING)) return 0
  new Float:maxhealth = entity_get_float(ent,EV_FL_max_health)
  if(maxhealth == 0.0) return 0
  if((100*entity_get_float(ent,EV_FL_health)/maxhealth) < MIN_HEALTH_PERCENT) return 0
  return 1
}

stock team_print(team,type,message[64]){
  format(message,63,"[Store] %s",message)
  for(new i=1;i<=g_maxplayerindex;i++){
    if(!ua_connected[i]) continue
    if(entity_get_int(i,EV_INT_team) != team) continue
    client_print(i,type,message)
  }
}
