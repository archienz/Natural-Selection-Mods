#include <amxmodx>
#include <amxmisc>
#include <engine>

#define BUGSPOTS_MAX	200
#define EXPLODE_RADIUS	175.0

new bugspots[BUGSPOTS_MAX + 32][3]
new bugspotsnum=0
new bugsnum=0
new lastorigin[33][3]
new blood
new Float:nadeorigin[33][3]

public plugin_init()
{
	register_plugin("Bug Mod","1.4","GHW_Chronic")
	register_concmd("amx_bugmod","toggle",ADMIN_LEVEL_D,"<1/On 0/Off>")
	register_concmd("amx_bugmod_spawnspeed","speedset",ADMIN_LEVEL_D,"Speed Bugs Spawn (Defaulted to 5) <speed>")
	register_event("ResetHUD","newround","b")

	new modname[32]
	get_modname(modname,31)
	if(equali(modname,"cstrike") || equali(modname,"czero"))
	{
		register_event("CurWeapon","shot_fired","be","1=1","2!4","2!6","2!9","2!25","2!29","3>0")
		register_event("SendAudio","nade_thrown","bc","2=%!MRAD_FIREINHOLE")
	}
	else
	{
		register_event("CurWeapon","shot_fired","be","1=1")
	}

	register_cvar("bugmod_spawnspeed","5")
	register_cvar("bugmod_max_bugs","50")
	register_cvar("bugmod_toggle","1")
	register_cvar("bugmod_runspeed","2")

	set_task(0.2,"prethink",0,"",0,"b")
	bugspotsnum=33
}

public plugin_precache()
{
	blood = precache_model("sprites/blood.spr")
	precache_model("models/GHW_Bug/roach.mdl")
	precache_sound("GHW_Bug/rch_walk.wav")
	precache_sound("GHW_Bug/rch_smash.wav")
	precache_sound("GHW_Bug/rch_die.wav")
}

public toggle(id,level,cid)
{
	if(!cmd_access(id,level,cid,2))
	{
		return PLUGIN_HANDLED
	}
	new arg1[32]
	read_argv(1,arg1,31)
	if(equali(arg1,"on") || equali(arg1,"1"))
	{
		set_cvar_num("bugmod_toggle",1)
		console_print(id,"Bugmod Enabled")
	}
	else
	{
		new i = find_ent_by_class(33,"GHW_Bug")
		while(i)
		{
			remove_entity(i)
			i = find_ent_by_class(i,"GHW_Bug")
		}
		bugsnum=0
		set_cvar_num("bugmod_toggle",0)
		console_print(id,"Bugmod Disabled")
	}
	return PLUGIN_HANDLED
}

public speedset(id,level,cid)
{
	if(!cmd_access(id,level,cid,2))
	{
		return PLUGIN_HANDLED
	}
	new arg1[32]
	read_argv(1,arg1,31)
	if(equali(arg1,"0") || str_to_num(arg1)<0)
	{
		new i = find_ent_by_class(33,"GHW_Bug")
		while(i)
		{
			remove_entity(i)
			new i = find_ent_by_class(i,"GHW_Bug")
		}
		bugsnum=0
		set_cvar_num("bugmod_toggle",0)
		console_print(id,"Bugmod Disabled")
		return PLUGIN_HANDLED
	}
	if(str_to_num(arg1)==0)
	{
		console_print(id,"Invalid Number.")
		return PLUGIN_HANDLED
	}
	set_cvar_num("bugmod_spawnspeed",str_to_num(arg1))
	console_print(id,"Bugs now spawn at a speed of %d",str_to_num(arg1))
	return PLUGIN_HANDLED
}

public bug_check(id)
{
	if(!is_user_alive(id) || !is_user_connected(id))
	{
		return PLUGIN_HANDLED
	}
	new origin[3]
	get_user_origin(id,origin)
	if(abs(origin[0]-lastorigin[id][0])<=100 && abs(origin[1]-lastorigin[id][1])<=100)
	{
		set_task(30.0,"bug_check",id)
		return PLUGIN_HANDLED
	}
	if(bugspotsnum>=199)
	{
		return PLUGIN_HANDLED
	}
	lastorigin[id][0]=origin[0]
	lastorigin[id][1]=origin[1]
	lastorigin[id][2]=origin[2]
	bugspots[bugspotsnum][0]=origin[0]
	bugspots[bugspotsnum][1]=origin[1]
	bugspots[bugspotsnum][2]=origin[2]
	set_task(5.0,"spawn_bug",bugspotsnum)
	bugspotsnum++
	set_task(30.0,"bug_check",id)
	return PLUGIN_HANDLED
}

public newround(id)
{
	if(!is_user_alive(id) || !is_user_connected(id))
	{
		return PLUGIN_CONTINUE
	}
	remove_task(id)
	set_task(30.0,"bug_check",id)
	return PLUGIN_CONTINUE
}

public spawn_bug(id)
{
	if(!get_cvar_num("bugmod_toggle") || bugsnum>=get_cvar_num("bugmod_max_bugs"))
	{
		set_task(25.0/get_cvar_float("bugmod_spawnspeed"),"spawn_bug",id)
		return PLUGIN_HANDLED
	}
	new ent = create_entity("info_target")

	entity_set_string(ent,EV_SZ_classname,"GHW_Bug")

	entity_set_model(ent,"models/GHW_Bug/roach.mdl")

	new Float:origin[3]
	origin[0] = float(bugspots[id][0])
	origin[1] = float(bugspots[id][1])
	origin[2] = float(bugspots[id][2])
	entity_set_origin(ent,origin)

	entity_set_int(ent, EV_INT_solid,SOLID_BBOX)
	entity_set_int(ent,EV_INT_movetype,MOVETYPE_PUSHSTEP)
	entity_set_edict(ent,EV_ENT_owner,33)

	entity_set_float(ent,EV_FL_framerate,1.0)
	entity_set_int(ent,EV_INT_sequence,0)

	new Float:mina[3]
	mina[0]=-2.1
	mina[1]=-2.1
	mina[2]=-1.1
	new Float:maxa[3]
	maxa[0]=2.1
	maxa[1]=2.1
	maxa[2]=1.1
	entity_set_size(ent,mina,maxa)
	//entity_set_float(ent,EV_FL_health,1.0)
	//entity_set_float(ent,EV_FL_takedamage,1.0)  

	bugsnum++
	set_task(25.0/get_cvar_float("bugmod_spawnspeed"),"spawn_bug",id)
	return PLUGIN_HANDLED
}

public prethink()
{
	new i = find_ent_by_class(33,"GHW_Bug")
	while(i)
	{
		new Float:num = get_cvar_float("bugmod_runspeed") / 2.0
		new Float:velocity[3]
		entity_get_vector(i,EV_VEC_velocity,velocity)
		if(velocity[0]<=15.0*num) velocity[0]=random_float(-200.0*num,200.0*num)
		if(velocity[1]<=15.0*num) velocity[1]=random_float(-200.0*num,200.0*num)
		if(random_num(0,10)==1) velocity[2]=float(random_num(10,75))
		entity_set_vector(i,EV_VEC_velocity,velocity)
		if(random_num(0,25)==1) emit_sound(i,CHAN_VOICE,"GHW_Bug/rch_walk.wav",1.0,ATTN_NORM,0,PITCH_NORM)

		new Float:angles[3]
		entity_get_vector(i,EV_VEC_angles,angles)
		if(random_num(0,5)==1) angles[1] += random_float(-10.0*num,10.0*num)
		if(angles[1]>180) angles[1] -= 360
		if(angles[1]<-180) angles[1] += 360
		entity_set_vector(i,EV_VEC_angles,angles)

		i = find_ent_by_class(i,"GHW_Bug")
	}
	return PLUGIN_CONTINUE
}


public shot_fired(id)
{
	new ent,trash
	get_user_aiming(id,ent,trash)
	if(ent)
	{
		new classname[32]
		entity_get_string(ent,EV_SZ_classname,classname,31)
		if(equali(classname,"GHW_Bug"))
		{
			emit_sound(ent,CHAN_VOICE,"GHW_Bug/rch_die.wav",1.0,ATTN_NORM,0,PITCH_NORM)
			bugsnum--
			new Float:origin[3]
			entity_get_vector(ent,EV_VEC_origin,origin)
			message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
			write_byte(115)
			write_coord(floatround(origin[0]))
			write_coord(floatround(origin[1]))
			write_coord(floatround(origin[2]))
			write_short(blood)
			write_short(blood)
			write_byte(229)
			write_byte(10)
			message_end()
			remove_entity(ent)
		}
	}
	return PLUGIN_CONTINUE
}

public pfn_touch(ptr,ptd)
{
	if(ptr<=32 && ptr>0 && ptd>32)
	{
		new classname[32]
		entity_get_string(ptd,EV_SZ_classname,classname,31)
		if(equali(classname,"GHW_Bug"))
		{
			new Float:origin[3]
			entity_get_vector(ptd,EV_VEC_origin,origin)
			emit_sound(ptd,CHAN_VOICE,"GHW_Bug/rch_smash.wav",1.0,ATTN_NORM,0,PITCH_NORM)
			bugsnum--
			message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
			write_byte(115)
			write_coord(floatround(origin[0]))
			write_coord(floatround(origin[1]))
			write_coord(floatround(origin[2]))
			write_short(blood)
			write_short(blood)
			write_byte(229)
			write_byte(10)
			message_end()
			remove_entity(ptd)
		}
	}
	return PLUGIN_CONTINUE
}

public nade_thrown(id)
{
	new weaponmodel[32]
	entity_get_string(id,EV_SZ_weaponmodel,weaponmodel,31)
	if(containi(weaponmodel,"he")!=-1 || containi(weaponmodel,"gren")!=-1)
	{
		set_task(0.1,"Find_nade",id)
	}
	return PLUGIN_CONTINUE
}

public Find_nade(id)
{
	new Float:idorigin[3]
	entity_get_vector(id,EV_VEC_origin,idorigin)

	new ent = find_ent_in_sphere(32,idorigin,200.0)

	new model[32]
	while(ent)
	{
		entity_get_string(ent,EV_SZ_model,model,31)
		if(containi(model,"he")!=-1 || containi(model,"gren")!=-1)
		{
			new param[1]
			param[0]=id
			set_task(0.1,"get_nade_origin",ent,param,1,"b")
			break;
		}
		ent = find_ent_in_sphere(ent,idorigin,200.0)
	}
	return PLUGIN_CONTINUE
}

public get_nade_origin(param[1],ent)
{
	new model[32]
	entity_get_string(ent,EV_SZ_model,model,31)
	if(!is_valid_ent(ent) || equali(model,""))
	{
		remove_task(ent)
		nade_blow_up(param[0])
		return PLUGIN_CONTINUE
	}
	entity_get_vector(ent,EV_VEC_origin,nadeorigin[param[0]])
	return PLUGIN_CONTINUE
}

public nade_blow_up(id)
{
	new ent = find_ent_in_sphere(32,nadeorigin[id],EXPLODE_RADIUS)
	new classname[32]
	while(ent)
	{
		entity_get_string(ent,EV_SZ_classname,classname,31)
		if(equali(classname,"GHW_BUG"))
		{
			emit_sound(ent,CHAN_VOICE,"GHW_Bug/rch_die.wav",1.0,ATTN_NORM,0,PITCH_NORM)
			bugsnum--
			new Float:origin[3]
			entity_get_vector(ent,EV_VEC_origin,origin)
			message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
			write_byte(115)
			write_coord(floatround(origin[0]))
			write_coord(floatround(origin[1]))
			write_coord(floatround(origin[2]))
			write_short(blood)
			write_short(blood)
			write_byte(229)
			write_byte(10)
			message_end()
			remove_entity(ent)
		}
		ent = find_ent_in_sphere(ent,nadeorigin[id],EXPLODE_RADIUS)
	}
	return PLUGIN_CONTINUE
}
