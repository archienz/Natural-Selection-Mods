#include <amxmodx>
#include <ns2amx>

#define NUMMINES 50                     // maximum of mines at one time 64. will remove a random one if the limit is exceeded
#define LASERLENGTH 500.0              // maximum length for laserbeam  1500
#define MINE_LASER_TIME 2.0             // redraw laser after this amount of time. smaller = more cpu/banwidth-intensive (0.5 - 25.0)

// not recommended to edit anything below unless you know what you're doing
#define MINE_LASER_ON 16.0
#define MINE_LASER_OFF 8.0
#define MINE_CHECKED 4.0
#define MINE_UNKNOWN 0.0

new minestarget[NUMMINES][3]
new minesdefine[NUMMINES]

new bool:inuse[33]
new activemode = 0
new teamcolors[3][3]

new g_lasersprite
new g_maxplayers
public plugin_precache(){
  precache_model("models/w_minebluef.mdl")
  g_lasersprite = precache_model("sprites/laserbeam.spr")
}

public plugin_init(){
  register_plugin("LaserMines","1.0","mE @ psix.info")
  register_cvar("me_lasermines", "1.0",4)

  g_maxplayers = get_maxplayers()
  if(ns_get_build("team_command",0,0) >= 2 && ns_get_build("team_hive",0,0) == 0) activemode = 1
  teamcolors[0]   = { 200,100,  0 }
  if(activemode == 1){
    teamcolors[1] = {   0,170,255 }
    teamcolors[2] = {   0,128,  0 }
  }else{
    teamcolors[1] = { 255,  0,  0 }
    teamcolors[2] = { 200,100,  0 }
  }

  set_task(0.2,"players_view",0,"",0,"b")
}

public players_view(){
  for(new i=1;i<=g_maxplayers;i++){
    if(!is_user_connected(i)) continue
    if(pev(i,pev_button) & IN_USE){
      if(inuse[i] == false){
        inuse[i] = true

        new ent,part
        get_user_aiming(i,ent,part)
        if(!is_entity(ent)) continue                             // looking at an entity
        if(pev(i,pev_team) != pev(ent,pev_team)) continue        // entity is from the same team
        new classname[10]
        pev(ent,pev_classname,classname,9)
        if(!equal(classname,"item_mine")) continue               // check is entity is a mine

        new Float:f[3]
        pev(ent,pev_vuser1,f)
        if(f[0] == MINE_LASER_ON){
          f[0] = MINE_LASER_OFF
          set_pev(ent,pev_vuser1,f)
          client_print(i,print_chat,"Laser turned OFF")
          continue
        }
        if(f[0] == MINE_LASER_OFF){
          f[0] = MINE_LASER_ON
          set_pev(ent,pev_vuser1,f)
          client_print(i,print_chat,"Laser turned ON")
          continue
        }
      }
    }else{
      inuse[i] = false
    }
  }
}

public server_frame(){
  new Float:timer = get_gametime()
  new ent
  while((ent = find_ent_by_class(ent,"item_mine")) > 0){
    new Float:f[3]                           // 0=state,1=last effect,2=arraynum
    pev(ent,pev_vuser1,f)
    new num = floatround(f[2])
    if(f[0] >= MINE_CHECKED){
      if(f[0] != MINE_LASER_ON) continue
      // MINES THINK HERE
      new Float:fstart[3]                          // start is here
      pev(ent,pev_origin,fstart)
      new Float:ftarget[3]                         // target is supposed to be here ( LASERLENGTH units away)
      ftarget[0] = float(minestarget[num][0])
      ftarget[1] = float(minestarget[num][1])
      ftarget[2] = float(minestarget[num][2])
      new Float:target[3]                          // returned target
      new hit = trace_line(ent,fstart,ftarget,target)
      if(hit > 0){
        if(pev(hit,pev_team) != 0){
          fake_touch(ent,hit)
        }
      }
      if(timer-f[1] >= MINE_LASER_TIME){
        new istart[3]
        istart[0] = floatround(fstart[0])
        istart[1] = floatround(fstart[1])
        istart[2] = floatround(fstart[2])
        new itarget[3]
        itarget[0] = floatround(target[0])
        itarget[1] = floatround(target[1])
        itarget[2] = floatround(target[2])
        f[1] = timer
        set_pev(ent,pev_vuser1,f)
        mines_effect(istart,itarget,pev(ent,pev_team))
      }
    }else{
      num = listnum()
      if(num == -1){
        num = random_num(0,NUMMINES-1)
        if(is_entity(minesdefine[num])){
          remove_entity(minesdefine[num])
        }
      }
      // ADD NEW MINE
      minesdefine[num] = ent
      f[0] = MINE_CHECKED
      f[1] = 0.0
      f[2] = float(num)
      set_pev(ent,pev_vuser1,f)

      new Float:origin[3]
      new Float:angles[3]
      pev(ent,pev_origin,origin)
      pev(ent,pev_angles,angles)

      new target[3]
      new Float:ret[3]
      angle_vector(angles,1,ret)
      target[0] = floatround(origin[0] + (ret[0] * LASERLENGTH))
      target[1] = floatround(origin[1] + (ret[1] * LASERLENGTH))
      target[2] = floatround(origin[2] - (ret[2] * LASERLENGTH))
      minestarget[num][0] = target[0]
      minestarget[num][1] = target[1]
      minestarget[num][2] = target[2]
      if(activemode == 1){
        set_pev(ent,pev_max_health,600.0)
        set_pev(ent,pev_health,600.0)
        if(pev(ent,pev_team)==1){
          new Float:MinBox[3]
          new Float:MaxBox[3]
          pev(ent, pev_mins, MinBox)
          pev(ent, pev_maxs, MaxBox)
          new modelstr[64] = "models/w_minebluef.mdl"
          entity_set_model(ent,modelstr)
          set_pev(ent,pev_model,make_string(modelstr))
          set_size(ent, MinBox, MaxBox)
          set_pev(ent,pev_solid,2)
        }
      }
      set_task(4.5,"mines_activate",ent)
    }
  }
}

public mines_activate(id){
  if(is_entity(id)){
    new Float:f[3]
    pev(id,pev_vuser1,f)
    if(f[0] == MINE_CHECKED){
      f[0] = MINE_LASER_ON
      set_pev(id,pev_vuser1,f)
    }
  }
}

listnum(){
  for(new i=0;i<NUMMINES;i++){
    new Float:f[3]
    if(is_entity(minesdefine[i])) pev(minesdefine[i],pev_vuser1,f)
    if(f[0] == MINE_UNKNOWN){
      return i
    }
  }
  return -1
}



mines_effect(start[3],target[3],team){
  message_begin(MSG_ALL,SVC_TEMPENTITY)
  write_byte(0) // TE_BEAMPOINTS)
  write_coord(start[0])
  write_coord(start[1])
  write_coord(start[2])
  write_coord(target[0])
  write_coord(target[1])
  write_coord(target[2])
  write_short(g_lasersprite)
  write_byte(1)			// Starting Frame
  write_byte(5)			// Frame rate
  write_byte(floatround(MINE_LASER_TIME*10.0)+5)          	// Life
  write_byte(2)	                // Line Width
  write_byte(0)			// Noise
  write_byte(teamcolors[team][0])		// Color: Red
  write_byte(teamcolors[team][1])			// Color: Green
  write_byte(teamcolors[team][2])			// Color: Blue
  write_byte(255)	        // Brightness
  write_byte(0)			// Scroll speed
  message_end()

  return PLUGIN_CONTINUE
}
