// This Plugin is a Striped Down Verison Of TIMMI the Savages Map object makers.
// This Plugin will allow you to place 3 whores anywhere in a map
// I have removed the ability to Interact with the girls. Because..
// The models have only one animation.
// My models are very explicit. And I would rather not upload them due to adult content.
// PM me savagetimmi at amxmodx.org or modns.org and I might be willing to give you the full plugin.
// depending on age of course.

#include <amxmodx>
#include <engine>
#include <amxmisc>
#include <fakemeta>
#define HMCHAN_PLAYERINFO 1089

new testent[65] 
			
new Float:temporigin[108][3]
new Float:tempangles[108][3]
new tempmodel[108]
new objectname
new Float:i_origin[3]
new Float:i_angles[3]

public loadobjects() { 
	new vaultdata[512]
	new allowfilepath[251]
  	new mapname[32]
  	new reach
  	get_mapname(mapname,32)
	format(allowfilepath,250,"/addons/amxmodx/configs/%s_objects.cfg", mapname) 
	if(file_exists(allowfilepath)) {
		for (new i = 0 ; i < 106 ; i++) {
			read_file(allowfilepath,i,vaultdata,511,reach)
			new origin1[15], origin2[15], origin3[15],angle1[15], angle2[15], angle3[15], model[2]
			parse(vaultdata,origin1,14,origin2,14,origin3,14,angle1,14,angle2,14,angle3,14,model,2)
			temporigin[i][0] = Float:str_to_num(origin1)
			temporigin[i][1] = Float:str_to_num(origin2)
			temporigin[i][2] = Float:str_to_num(origin3)
			tempangles[i][0] = Float:str_to_num(angle1)
			tempangles[i][1] = Float:str_to_num(angle2)
			tempangles[i][2] = Float:str_to_num(angle3)
			tempmodel[i] = str_to_num(model)
		}
	}
	return PLUGIN_CONTINUE
}

public removeobjects(id) {
	new ent = 0
	ent = find_ent_by_class(-1, "test")	
	if (ent == 0) return PLUGIN_CONTINUE
	if (is_valid_ent(ent)) remove_entity(ent)
	removeobjects(id)
	return PLUGIN_CONTINUE
}

public createobj() {
	for (new i = 0 ; i < 2 ; i ++ ) {
		testent[i] = create_entity("info_target")
		entity_set_string(testent[i], EV_SZ_classname, "test")
		if (tempmodel[i] == 1)entity_set_model(testent[i], "models/dead_ggi1.mdl" )
		if (tempmodel[i] == 2)entity_set_model(testent[i], "models/deag_ggi2.mdl" )
		if (tempmodel[i] == 3)entity_set_model(testent[i], "models/dead_ggi4.mdl" )
		new Float:MinBox[3]
		new Float:MaxBox[3]
		MinBox[0] = -22.0
		MinBox[1] = -22.0
		MinBox[2] = -69.0
		MaxBox[0] = 22.0
		MaxBox[1] = 22.0
		MaxBox[2] = 69.0
		set_pev(testent[i],pev_mins,MinBox)
		set_pev(testent[i],pev_maxs,MaxBox)
		new Float:color[3]
		color[0] = 50.0
		color[1] = 50.0
		color[2] = 50.0
		temporigin[i][2] = temporigin[i][2] - 35.0
		set_pev(testent[i],pev_origin, temporigin[i])
		entity_set_int(testent[i], EV_INT_movetype, MOVETYPE_FLY)
		entity_set_int(testent[i], EV_INT_solid, SOLID_BBOX)
		entity_set_vector(testent[i], EV_VEC_angles, i_angles)
		set_pev(testent[i],pev_v_angle,tempangles[i])
		set_pev(testent[i],pev_angles,tempangles[i])
		set_pev(testent[i],pev_sequence, 1)
		set_pev(testent[i],pev_framerate,1.0)
		entity_set_int(testent[i], EV_INT_fixangle, 1) 
		entity_set_float(testent[i], EV_FL_health, 200.0) 
		set_size(testent[i], Float:{-22.0,-22.0,-70.0}, Float:{22.0,22.0,70.0})
		drop_to_floor(testent[i])
	}
	return PLUGIN_CONTINUE

}

public makemapfile(id) {
  new vaultdata2[512] 
  new allowfilepath[251]
  new mapname[32]
  get_mapname(mapname,32)
  format(allowfilepath,250,"/addons/amxmodx/configs/%s_objects.cfg", mapname) 
  entity_get_vector(id, EV_VEC_origin, i_origin)
  entity_get_vector(id, EV_VEC_v_angle, i_angles)
  format (vaultdata2, 511, "%d %d %d %d %d %d %d", i_origin[0], i_origin[1], i_origin[2], i_angles[0], i_angles[1], i_angles[2], objectname )
  write_file(allowfilepath,vaultdata2,-1)
  set_hudmessage(75,200,200,-1.0,0.86,0,6.0,2.0,0.1,0.5,HMCHAN_PLAYERINFO)
  show_hudmessage(id, "Coordinates and model name written.^n %s.cfg  in the readyroomobj config folder. ^n /ns/addons/amxmodx/configs/readyroomobj/ ", mapname)
  return PLUGIN_CONTINUE 
}

public rrobjects(id) {
	new szMenuBody9[250]
	new keys
	format(szMenuBody9, 249, "Objectlist:")
	add( szMenuBody9, 249, "^n1. Dancer1 " )
	add( szMenuBody9, 249, "^n2. Dancer2 " )
	add( szMenuBody9, 249, "^n3. Dancer3 " )
	add( szMenuBody9, 249, "^n^n0. Exit " )
	keys = (1<<0|1<<1|1<<2|1<<9)
	show_menu( id, keys, szMenuBody9, 5 )
}

public objectlistkey(id, key) {
	switch(key) {
		case 0: tempmodel[0] = 1
		case 1: tempmodel[1] = 2
		case 2: tempmodel[2] = 3
		case 9: return PLUGIN_CONTINUE 
	}
	makemapfile(id)
	return PLUGIN_CONTINUE
}	

public writehandleradv(id) {
	set_hudmessage(75,200,200,-1.0,0.86,0,6.0,2.0,0.1,0.5,HMCHAN_PLAYERINFO)
	show_hudmessage(id, "Where ever you are standing will be the new coordinates^n for the object you pick to place into your map . ")
	rrobjects(id)
	return PLUGIN_CONTINUE
}

public plugin_precache() {
	precache_model("models/flo_bed.mdl")
	
}
		
new ison = 0

public client_connect(id) {
    if (ison == 0) {
        ison = 1
        loadobjects()
        createobj()
    }
    return PLUGIN_CONTINUE
}
        
public client_putinserver(id) {
    if (ison == 0) {
        ison = 1
        loadobjects()
        createobj()
    }
    return PLUGIN_CONTINUE
}
public makeobjs1() {
    if (ison == 0) {
        ison = 1
        loadobjects()
        createobj()
    }
}
public plugin_init() {
	register_concmd("say write", "writehandleradv")
	register_concmd("say makecfg", "writehandleradv")
	register_concmd("say makemapcfg", "writehandleradv")
	register_concmd("say createcfg", "writehandleradv")
	register_concmd("say dancer", "createobj")	
	register_concmd("say backup", "makemapfile")
	register_concmd("say removeobj", "removeobjects")
	set_task(10.0, "makeobjs1", 9999)
	register_menucmd(register_menuid("Objectlist:"), 1023, "objectlistkey" )
	register_plugin("Ready Room Dancers and Objects", "1.0", "Timmi the savage")
}
