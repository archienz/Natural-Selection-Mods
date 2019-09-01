#include <amxmodx>
#include <engine>
#include <ns>

public plugin_init()
{
	register_plugin("AMXX ReLocate", "1.0", "Cheap_Suit")
	if(!ns_is_combat())
		{
		register_cvar("amx_relocate", "1")
	}
	else
		{
		register_cvar("amx_relocate", "0")
	}
}

public client_PreThink(id)
{
	if(get_cvar_num("amx_relocate") <= 0) return PLUGIN_CONTINUE
	if(check_class(id) != true) return PLUGIN_CONTINUE

	if(client_weapon(id) == WEAPON_WELDER) 
		{
		if(get_user_button(id) & IN_USE && get_user_button(id) & IN_ATTACK)
			{
			new Structure, bodyPart, Float:distance
			distance = get_user_aiming(id, Structure, bodyPart)
			if(Structure <= 0 || distance > 75.0) 
				{
				return PLUGIN_HANDLED
			}

			new Classname[33]
			entity_get_string(Structure, EV_SZ_classname, Classname, 32)
			
			if(equal(Classname, "team_armory")) 
				{
				entity_set_follow(Structure, id)
			}
			else if(equal(Classname, "team_advarmory")) 
				{
				entity_set_follow(Structure, id)
			}
			else if(equal(Classname, "team_armslab")) 
				{
				entity_set_follow(Structure, id)
			}
			else if(equal(Classname, "team_observatory"))
				{
				entity_set_follow(Structure, id)
			}
			else if(equal(Classname, "team_prototypelab")) 
				{
				entity_set_follow(Structure, id)
			}
			else if(equal(Classname, "team_turretfactory")) 
				{
				entity_set_follow(Structure, id)
			}
			else if(equal(Classname, "turret")) 
				{
				entity_set_follow(Structure, id)
			}
		}
	}
	return PLUGIN_CONTINUE
}

stock bool:check_class(id)
{
	new class = ns_get_class(id)
	if(class == CLASS_MARINE || 
	   class == CLASS_JETPACK || 
	   class == CLASS_HEAVY)
		{
		return true
	}
	return false
}

stock client_weapon(id)
{
	new clip, ammo
	return get_user_weapon(id, clip, ammo)
}

stock entity_set_follow(entity, id)
{
	if(!is_valid_ent(entity) || !is_valid_ent(id)) return
		
	new Float:entity_origin[3], Float:origin[3], Float:Aim[3]
	entity_get_vector(entity, EV_VEC_origin, entity_origin)
	entity_get_vector(id, EV_VEC_origin, origin)
	
	VelocityByAim(id, 64, Aim)
	
	new Float:diff[3]
	diff[0] = (origin[0] += Aim[0]) - entity_origin[0]
	diff[1] = (origin[1] += Aim[1]) - entity_origin[1]
	diff[2] = origin[2] - entity_origin[2]
	
	new Float:length = floatsqroot(floatpower(diff[0], 2.0) + floatpower(diff[1], 2.0) + floatpower(diff[2], 2.0))
	
	new Float:Velocity[3], Float:speed = 100.0
	Velocity[0] = diff[0] * (speed / length)
	Velocity[1] = diff[1] * (speed / length)
	Velocity[2] = diff[2] * (speed / length)
	
	entity_set_vector(entity, EV_VEC_velocity, Velocity)
	return
}