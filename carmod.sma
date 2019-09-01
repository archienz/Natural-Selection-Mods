#include <amxmodx> 
#include <amxmisc> 
#include <engine>
#include <fun>
#define MAX_SPAWNS 20
new carout[33]
new incar[33]
public loadSettings() {
	new szFilename[64]
	get_cvar_string("rp_carsfile",szFilename,63)

	if (!file_exists(szFilename)) {
		write_file(szFilename,"; CAR SPAWNS HERE",-1)
		server_print("[AMXX] No ^"%s^" was found, so it has been created.", szFilename)
		return PLUGIN_HANDLED
	}

	new szText[256]
	new a, g_aNum, pos = 0

	while ( g_aNum < MAX_SPAWNS && read_file(szFilename,pos++,szText,255,a) )
	{         
		if ( szText[0] == ';' ) continue
		server_cmd(szText)
		++g_aNum
	}
	server_print("[AMXX] Loaded %i spawns", g_aNum )
	return PLUGIN_HANDLED
}
public lock(id) {
	if(incar[id] || !carout[id]) {
		client_print(id,print_chat,"[CarMod] You must be outside your car to lock")
		return PLUGIN_HANDLED
	}
	new origin[3]
	get_user_origin(id,origin)

	new authid[33]
	get_user_authid(id,authid,32)
	entity_set_string(carout[id],EV_SZ_target,authid)
	return PLUGIN_HANDLED
}
public overhear(a,distance,Speech[])
{
	new OriginA[3], OriginB[3]
	get_user_origin(a,OriginA)
	new players[32], num
	get_players(players,num,"ac")
	for(new b = 0; b < num;b++)
	{
		if(a!=players[b])
		{
			get_user_origin(players[b],OriginB)
			if(distance == -1) {
				client_print(players[b],print_chat,Speech)
			}
			else
			{
				if(get_distance(OriginA,OriginB) <= distance) {
					client_print(players[b],print_chat,Speech)
				}
			}
		}
	}
	return PLUGIN_HANDLED
}
public makecar(id) {
	new item[32], orig1[6], orig2[6], orig3[6], angles1[6], Float:origin[3]
	read_argv(1, item, 31)
	read_argv(2, orig1, 5)
	read_argv(3, orig2, 5)
	read_argv(4, orig3, 5)
	read_argv(5, angles1, 5)

	origin[0] = float(str_to_num(orig1))
	origin[1] = float(str_to_num(orig2))
	origin[2] = float(str_to_num(orig3))
	new Float:angles2 = float(str_to_num(angles1))

	new car = create_entity("info_target")

	if(!car) {
		client_print(id,print_chat,"CAR WAS not created. Error.^n")
		return PLUGIN_HANDLED
	}

	new Float:minbox[3] = { -2.5, -2.5, -2.5 }
	new Float:maxbox[3] = { 2.5, 2.5, -2.5 }
	new Float:angles[3] = { 0.0, 0.0, 0.0 }
	angles[1] = angles2

	entity_set_vector(car,EV_VEC_mins,minbox)
	entity_set_vector(car,EV_VEC_maxs,maxbox)
	entity_set_vector(car,EV_VEC_angles,angles)

	entity_set_float(car,EV_FL_dmg,0.0)
	entity_set_float(car,EV_FL_dmg_take,0.0)
	entity_set_float(car,EV_FL_max_health,99999.0)
	entity_set_float(car,EV_FL_health,99999.0)

	entity_set_int(car,EV_INT_solid,SOLID_TRIGGER)
	entity_set_int(car,EV_INT_movetype,MOVETYPE_NONE)

	entity_set_string(car,EV_SZ_targetname,item)
	entity_set_string(car,EV_SZ_classname,"item_car")

	new damodel[64]
	format(damodel,63,"models/player/%s/%s.mdl", item, item)

	entity_set_model(car,damodel)
	entity_set_origin(car,origin)

	return PLUGIN_HANDLED
}
public plugin_precache()
{
	precache_model("models/player/pietrekcar/pietrekcar.mdl")
	precache_sound("phone/1.wav")
	precache_sound("ambience/rd_warehouse.wav")
}
public plugin_init()
{
	register_touch("item_car","player","setcar")
	register_touch("player","player","crash")

	register_clcmd("say /getout","uncar")
	register_clcmd("say /honk","honk")
	register_clcmd("say /lock","lock")
	
	register_srvcmd("amx_makecar","makecar")

	register_cvar("rp_carsfile", "carsfile.ini")

	register_concmd("amx_createcar","purposedrop")

	register_event("DeathMsg","death_msg","a")

	set_task(5.0,"loadSettings")
}
new Float:oldspeed[33]
new Float:oldfric[33]
new oldmodel[33][33]
new carmodel[33][33]
new allow[33]

public crash(entid, id) {
	if(allow[entid] == 1 || allow[id] == 1) return PLUGIN_HANDLED
	if(incar[id] && incar[entid]) {
		set_user_health(entid,0)
		set_user_health(id,0)
		emit_sound(id, CHAN_ITEM, "ambience/rd_warehouse.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
		//drop_car(id)
		//drop_car(entid)
		return PLUGIN_HANDLED
	}
	if(incar[id]) {
		new hp = get_user_health(entid)
		new hp2 = get_user_health(id)
		set_user_health(entid,(hp - 50))
		set_user_health(id,(hp2 - 10))
		emit_sound(id, CHAN_ITEM, "ambience/rd_warehouse.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
		//if(get_user_health(id) <= 0) drop_car(id)
		allow[id] = 1
		set_task(10.0,"allowhim",id)
		return PLUGIN_HANDLED
	}
	if(incar[entid]) {
		new hp = get_user_health(id)
		new hp2 = get_user_health(entid)
		set_user_health(id,(hp - 50))
		set_user_health(entid,(hp2 - 10))
		emit_sound(entid, CHAN_ITEM, "ambience/rd_warehouse.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
		//if(get_user_health(entid) <= 0) drop_car(entid)
		allow[entid] = 1
		set_task(10.0,"allowhim",entid)
		return PLUGIN_HANDLED
	}
	return PLUGIN_HANDLED
}
public honk(id) {
	if(incar[id] != 1) return PLUGIN_HANDLED
	emit_sound(id, CHAN_ITEM, "phone/1.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
	return PLUGIN_HANDLED
}
public client_PreThink(id)
{
	if(incar[id] != 0)
	{
		new bufferstop = entity_get_int(id,EV_INT_button)

		if(bufferstop != 0) {
			entity_set_int(id,EV_INT_button,bufferstop & ~IN_ATTACK & ~IN_ATTACK2 & ~IN_ALT1 & ~IN_USE)
		}

		if((bufferstop & IN_JUMP) && (entity_get_int(id,EV_INT_flags) & ~FL_ONGROUND & ~FL_DUCKING)) {
			entity_set_int(id,EV_INT_button,entity_get_int(id,EV_INT_button) & ~IN_JUMP)
		}
		return PLUGIN_CONTINUE
	}
	return PLUGIN_CONTINUE
}

public setcar(entid,id) {
	if(allow[id] != 0) return PLUGIN_HANDLED
	if(incar[id] != 0) return PLUGIN_HANDLED

	new locked[33], authid[33]
	entity_get_string(entid,EV_SZ_target,locked,32)
	get_user_authid(id,authid,32)
	if(equal(locked,"") || equal(locked,authid)) {}
	else return PLUGIN_HANDLED

	new name[64]
	get_user_name(id,name,63)
	new message[300]
	format(message,299,"[CarMod] %s has gotten into his car and started the engine.",name)
	overhear(id,300,message)
	client_print(id,print_chat,"[CarMod] You have gotten into your car and started the engine.")
	get_user_info(id,"model",oldmodel[id], 32)

	new itemstr[32]
	entity_get_string(entid,EV_SZ_targetname,itemstr,31)

	carmodel[id] = itemstr
	set_user_info(id,"model",itemstr)
	oldspeed[id] = get_user_maxspeed(id)
	oldfric[id] = entity_get_float(id,EV_FL_friction)
	set_user_maxspeed(id, 1000.0)
	entity_set_float(id,EV_FL_friction,0.3)
	set_user_footsteps(id,1)
	incar[id] = 1
	carout[id] = 0
	emit_sound(id, CHAN_ITEM, "items/gunpickup2.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
	remove_entity(entid)
	return PLUGIN_HANDLED
}
public uncar(id) {
	if(incar[id] != 1) return PLUGIN_HANDLED
	new name[64]
	get_user_name(id,name,63)
	new message[300]
	format(message,299,"[CarMod] %s has turned off his engine and got out of the car.",name)
	overhear(id,300,message)
	client_print(id,print_chat,"[CarMod] You have turned off your engine and got out of the car.")
	set_user_maxspeed(id,oldspeed[id])
	entity_set_float(id,EV_FL_friction,oldfric[id])
	car_drop(id)
	set_user_info(id,"model",oldmodel[id])
	incar[id] = 0
	set_user_footsteps(id,0)
	return PLUGIN_HANDLED
}
public purposedrop(id)
{
	if(!is_user_alive(id)) return PLUGIN_HANDLED
	if(!access(id,ADMIN_RESERVATION)) return PLUGIN_HANDLED

	new itemname[64], save1[6], szFilename[64]
	read_argv(1, itemname, 31)
	read_argv(2, save1, 5)
	if(!access(id,ADMIN_RESERVATION)) {
		client_print(id,print_console,"You do not have access to this command.")
		return PLUGIN_HANDLED
	}
	if(equal(itemname, "") || equal(save1, "")) {
		client_print(id,print_console,"Usage: amx_createcar <model> <save 1/0>")
		return PLUGIN_HANDLED
	}

	new save = str_to_num(save1)
	new origin[3], Float:originF[3]
	get_user_origin(id,origin)

	originF[0] = float(origin[0])
	originF[1] = float(origin[1])
	originF[2] = float(origin[2])

	new car = create_entity("info_target")

	if(!car) {
		client_print(id,print_chat,"CAR WAS not created. Error.^n")
		return PLUGIN_HANDLED
	}

	new Float:minbox[3] = { -2.5, -2.5, -2.5 }
	new Float:maxbox[3] = { 2.5, 2.5, -2.5 }
	new Float:angles[3] = { 0.0, 0.0, 0.0 }

	new Float:pangles[3]
	entity_get_vector(id,EV_VEC_angles,pangles)
	angles[1] = pangles[1]
	entity_set_vector(car,EV_VEC_mins,minbox)
	entity_set_vector(car,EV_VEC_maxs,maxbox)
	entity_set_vector(car,EV_VEC_angles,angles)

	entity_set_float(car,EV_FL_dmg,0.0)
	entity_set_float(car,EV_FL_dmg_take,0.0)
	entity_set_float(car,EV_FL_max_health,99999.0)
	entity_set_float(car,EV_FL_health,99999.0)

	entity_set_int(car,EV_INT_solid,SOLID_TRIGGER)
	entity_set_int(car,EV_INT_movetype,MOVETYPE_NONE)

	entity_set_string(car,EV_SZ_targetname,itemname)
	entity_set_string(car,EV_SZ_classname,"item_car")

	new damodel[64]
	format(damodel,63,"models/player/%s/%s.mdl", itemname, itemname)

	entity_set_model(car,damodel)
	entity_set_origin(car,originF)
	if(save == 1 || equal(save1, "1")) {
		get_cvar_string("rp_carsfile",szFilename,63)
		if (!file_exists(szFilename)) return PLUGIN_HANDLED

		new message[64]
		format(message, 63, "amx_makecar %s %i %i %i 0", itemname, origin[0], origin[1], origin[2])
		write_file(szFilename,message,-1)
	}
	allow[id] = 1
	set_task(10.0,"allowhim",id)
	return PLUGIN_HANDLED
}
public car_drop(id)
{
	//if(!is_user_alive(id)) return PLUGIN_HANDLED
	if(incar[id] != 1) return PLUGIN_HANDLED

	new origin[3],Float:pangles[3],Float:originF[3]
	get_user_origin(id,origin)

	originF[0] = float(origin[0])
	originF[1] = float(origin[1])
	originF[2] = float(origin[2])

	new car = create_entity("info_target")

	if(!car) {
		client_print(id,print_chat,"CAR WAS not created. Error.^n")
		return PLUGIN_HANDLED
	}

	new Float:minbox[3] = { -2.5, -2.5, -2.5 }
	new Float:maxbox[3] = { 2.5, 2.5, -2.5 }
	new Float:angles[3] = { 0.0, 0.0, 0.0 }
	entity_get_vector(id,EV_VEC_angles,pangles)
	angles[1] = pangles[1]

	entity_set_vector(car,EV_VEC_mins,minbox)
	entity_set_vector(car,EV_VEC_maxs,maxbox)
	entity_set_vector(car,EV_VEC_angles,angles)

	entity_set_float(car,EV_FL_dmg,0.0)
	entity_set_float(car,EV_FL_dmg_take,0.0)
	entity_set_float(car,EV_FL_max_health,99999.0)
	entity_set_float(car,EV_FL_health,99999.0)

	entity_set_int(car,EV_INT_solid,SOLID_TRIGGER)
	entity_set_int(car,EV_INT_movetype,MOVETYPE_NONE)

	entity_set_string(car,EV_SZ_targetname,carmodel[id])
	entity_set_string(car,EV_SZ_classname,"item_car")

	new damodel[64]
	format(damodel,63,"models/player/%s/%s.mdl", carmodel[id], carmodel[id])

	entity_set_model(car,damodel)
	entity_set_origin(car,originF)

	carout[id] = car
	allow[id] = 1
	set_task(10.0,"allowhim",id)
	return PLUGIN_HANDLED
}
public allowhim(id) {
	allow[id] = 0
}
public client_infochanged(id)
{
	if(incar[id] == 1) {
		set_user_info(id,"model",carmodel[id])
		return PLUGIN_HANDLED
	}
	return PLUGIN_HANDLED
}
public client_disconnect(id) {

	if(incar[id] == 1) {
		car_drop(id)
		incar[id] = 0
	}
	if(carout[id]) {
		entity_set_string(carout[id],EV_SZ_target,"")
		carout[id] = 0
	}
	return PLUGIN_CONTINUE
}
public death_msg() {
	new id = read_data(2)
	if(incar[id] == 1) {
		set_user_maxspeed(id,oldspeed[id])
		entity_set_float(id,EV_FL_friction,oldfric[id])
		set_user_info(id,"model",oldmodel[id])
		car_drop(id)
		incar[id] = 0
		set_user_footsteps(id,0)
	}
	return PLUGIN_CONTINUE
}