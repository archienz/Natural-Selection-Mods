#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <engine>
#include <ns>
#include <fun>

#define PLUGIN "Handheldsiege"
#define VERSION "0.9"
#define AUTHOR "Schnitzelmaker"

#define MARINE 1
#define ALIEN  2
#define NOTEAM 0
#define DEAD  3

new g_Pistol,g_Parasite,g_Siege
new gWhiteSprite
new gmsgShake,gmsgDeathMsg
new max_entities

public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	g_Pistol=precache_event(1,"events/Pistol.sc");
	g_Parasite=precache_event(1,"events/ParasiteGun.sc");
	g_Siege=precache_event(1,"events/SiegeHit.sc");
	
	gmsgShake = get_user_msgid("ScreenShake") 
	gmsgDeathMsg = get_user_msgid("DeathMsg")
	
	max_entities = get_global_int(GL_maxEntities)
	
	register_cvar("siegeweapons_enable","1",FCVAR_SERVER) //enable(1)/disable(0) siegeweapons
	register_cvar("siegeweapons_range","350") //range of damge of siegeweapons
	register_cvar("siegeweapons_damage","300.0") //amount of damage of siegeweapons
	register_cvar("siegeweapons_selfdamage","1") //enable(1)/disable(0) damage self if in damagerange
	register_cvar("siegeweapons_playeronly","0") //enable(1)/disable(0) if siegeweapons only damage players
	register_cvar("siegeweapons_wallblock","1") //enable(1)/disable(0) damage through walls
	register_cvar("siegeweapons_recoil","300.0") //recoil of player,who fire weapon
	register_cvar("siegeweapons_recoilenemy","0.0") //amount of recoil players in damagerange
	register_cvar("siegeweapons_getxp","1") //is xp allowed in combat
	register_cvar("siegeweapons_amountxp","10") //amount of xp in combat
	register_cvar("siegeweapons_ignorelist","team_hive;team_command;team_infportal;team_armory;team_advarmory")
	//ignore these buildings from damage
	
	register_forward(FM_PlaybackEvent, "FM_PlaybackEvent_hook")
}
	
public plugin_precache(){
	gWhiteSprite = precache_model("sprites/white.spr")
}

public get_team(id){
  new class = ns_get_class(id);
  if((class == CLASS_MARINE) || (class == CLASS_JETPACK) || (class == CLASS_HEAVY))
    return MARINE;
  else if (class == CLASS_NOTEAM)
   return NOTEAM;
  else if (class == CLASS_DEAD)
   return DEAD;
  return ALIEN;
}

//public FM_PlaybackEvent_hook( flags , ent_id , event_id , Float:delay , Float:Origin[3] )
//void PlaybackEvent( int flags, const edict_t * pInvoker, unsigned short eventindex, float delay, float *origin, float *angles, float fparam1, float fparam2, int iparam1, int iparam2, int bparam1, int bparam2) {
public FM_PlaybackEvent_hook(flags, entid, eventid, Float:delay, Float:Origin[3], Float:Angles[3], Float:fparam1, Float:fparam2, iparam1, iparam2, bparam2) 
{
	if(get_cvar_num("siegeweapons_enable") != 0){
		if((eventid == g_Pistol) || (eventid == g_Parasite)) { //pistol shot or parasite
		
		new owner = entity_get_edict(entid, EV_INT_iuser4)
		
		new Float:owner_origin[3],Float:vReturn[3],Float:vector[3],Float:owner_viewofs[3]
		
		entity_get_vector(owner,EV_VEC_origin,owner_origin)
		entity_get_vector(owner,EV_VEC_view_ofs,owner_viewofs)
		get_global_vector ( GL_v_forward, vector )
		
		new Float:Start[3],Float:End[3]
		Start[0] = owner_origin[0] + owner_viewofs[0]
		Start[1] = owner_origin[1] + owner_viewofs[1]
		Start[2] = owner_origin[2] + owner_viewofs[2]
		
		End[0] = owner_origin[0] + owner_viewofs[0] + vector[0] * 9999.0
		End[1] = owner_origin[1] + owner_viewofs[1] + vector[1] * 9999.0
		End[2] = owner_origin[2] + owner_viewofs[2] + vector[2] * 9999.0
		
		trace_line ( owner ,Start , End , vReturn )
		
		playback_event( 0, entid, g_Siege, 0.0, vReturn, Angles, 0.0, 0.0, 0, 0, 0, 0 )
		
		if( gWhiteSprite != 0 ) { //only if sprite got precached
			message_begin( MSG_BROADCAST, SVC_TEMPENTITY);
			write_byte(21) 	
			write_coord( floatround(vReturn[0]) );// coord coord coord (center position) 
			write_coord( floatround(vReturn[1]) );
			write_coord( floatround(vReturn[2]) );
	
			write_coord( 0 );// coord coord coord (axis and radius) 
			write_coord( 0 );
			write_coord( get_cvar_num("siegeweapons_range") * 2 );
					
			write_short( gWhiteSprite );// short (sprite index) 
			write_byte( 0 ); // byte (starting frame) 
			write_byte( 0 ); // byte (frame rate in 0.1's) 
			write_byte( 1 );// byte (life in 0.1's) 
			write_byte( 20 ); // byte (line width in 0.1's) 
			write_byte( 0 );// byte (noise amplitude in 0.01's) 
	
			write_byte( 255 );// byte,byte,byte (color)
			write_byte( 255 );
			write_byte( 255 );
			write_byte( 255 );// byte (brightness)
			write_byte( 0 );// byte (scroll speed in 0.1's)
			message_end();
		}
		
		new Float:PlayerVelocity[3],Float:PlayeraVelocity[3],Float:Power
		entity_get_vector(owner,EV_VEC_velocity,PlayerVelocity)
		entity_get_vector(owner,EV_VEC_avelocity,PlayeraVelocity)
		
		if (entity_get_int(owner, EV_INT_flags) & FL_DUCKING)
			Power = get_cvar_float("siegeweapons_recoil") * -0.5
		else Power = get_cvar_float("siegeweapons_recoil") * -1.0	
		
		new Float:new_PlayerVelocity[3],Float:new_PlayeraVelocity[3]
		new_PlayerVelocity[0] = PlayerVelocity[0] + vector[0] * Power
		new_PlayerVelocity[1] = PlayerVelocity[1] + vector[1] * Power
		new_PlayerVelocity[2] = PlayerVelocity[2] + vector[2] * Power
		
		new_PlayeraVelocity[0] = PlayeraVelocity[0] + vector[0] * Power
		new_PlayeraVelocity[1] = PlayeraVelocity[1] + vector[1] * Power
		new_PlayeraVelocity[2] = PlayeraVelocity[2] + vector[2] * Power
		
		entity_set_vector(owner,EV_VEC_velocity,new_PlayerVelocity)
		entity_set_vector(owner,EV_VEC_avelocity,new_PlayeraVelocity)
			
		new owner_team = entity_get_int(owner, EV_INT_team)
		new weapon[32]
		if (get_team(owner) == MARINE)
			weapon = "pistol"
		else if (get_team(owner) == ALIEN)
			weapon = "parasite"
						
		new maxobjects
		if (get_cvar_num("siegeweapons_playeronly") == 1)
			maxobjects = get_maxplayers()
		else maxobjects = max_entities
		for(new i = 1 ;i <= maxobjects; i++){
			if (is_valid_ent(i)){
				new ff = get_cvar_num("mp_friendlyfire")
				new i_team = entity_get_int(i, EV_INT_team)
				new Float:id_origin[3]
				entity_get_vector(i,EV_VEC_origin,id_origin)		
				if (vector_distance(id_origin, vReturn) <= get_cvar_num("siegeweapons_range")){	
					//if (i <= get_maxplayers() && owner_team != i_team || i <= get_maxplayers() && ff){
					//	}
					if (owner_team != i_team || ff || i == owner && get_cvar_num("siegeweapons_selfdamage") == 1){
						new classname[32]
						entity_get_string(i,EV_SZ_classname,classname,31)
						if (!is_building( classname ) && i > get_maxplayers())
							continue
						if (i <= get_maxplayers() && !is_user_alive(i))
							continue
						
						//Fix wall- and mine-bug
						if (equal( classname,"item_mine" ) && (entity_get_edict(i, EV_ENT_owner) != 0 )) 
							continue
						if (equal( classname,"func_wall" )) 
							continue
						
						new copybuffer[512] = ""
						get_cvar_string("siegeweapons_ignorelist",copybuffer,511)
						
						if (contain(copybuffer,classname) != -1)
							continue
						
						if (get_cvar_num("siegeweapons_wallblock") == 1){
							new Float:endorigin[3]
							
							new hitid = trace_line(0,vReturn,id_origin,endorigin)
							
							//Fix bug,were ent is at same position with another ent(like resourcetowers)
							if (hitid != i && hitid > 0){
								new Float:nearhit[3]
								entity_get_vector(hitid,EV_VEC_origin,nearhit)
								if (vector_distance(id_origin, nearhit) <= 10.0)
									hitid = i
							}
							if (hitid == i){
								if (get_cvar_float("siegeweapons_recoilenemy") != 0.0 && i != owner){
									new Float:recoilpower = get_cvar_float("siegeweapons_recoilenemy")
									new Float:new_EnemyVelocity[3],Float:EnemyVelocity[3]
									EnemyVelocity[0]= id_origin[0] - vReturn[0] 
									EnemyVelocity[1]= id_origin[1] - vReturn[1]
									EnemyVelocity[2]= id_origin[2] - vReturn[2]
									
									if (EnemyVelocity[0] > 0)
										new_EnemyVelocity[0] = recoilpower
									else if (EnemyVelocity[0] == 0)
										new_EnemyVelocity[0] = 0.0
									else new_EnemyVelocity[0] = recoilpower * -1.0
									if (EnemyVelocity[1] > 0)
										new_EnemyVelocity[1] = recoilpower
									else if (EnemyVelocity[1] == 0)
										new_EnemyVelocity[1] = 0.0
									else new_EnemyVelocity[1] = recoilpower * -1.0
									if (EnemyVelocity[2] > 0)
										new_EnemyVelocity[2] = recoilpower
									else if (EnemyVelocity[2] == 0)
										new_EnemyVelocity[2] = 0.0
									else new_EnemyVelocity[2] = recoilpower * -1.0
									
									entity_set_vector(i, EV_VEC_velocity, new_EnemyVelocity)
									}
								message_begin(MSG_ONE,gmsgShake,{0,0,0},i) 
								write_short( 1<<14 )// shake amount
								write_short( 1<<14 )// shake lasts this long
								write_short( 1<<14 )// shake noise frequency
								message_end()
								kill_player(i,owner,weapon)
								}
							}
						else kill_player(i,owner,weapon)
						}
					}
				}
			}
		}
	}
}

kill_player(id,killer = 0,weapon[]){
	
	set_msg_block(gmsgDeathMsg,BLOCK_ONCE)
	fakedamage(id,"trigger_hurt",float(get_cvar_num("siegeweapons_damage")),0)
	set_msg_block(gmsgDeathMsg,BLOCK_NOT)
	
	if (entity_get_float(id,EV_FL_health) <= 0.0 && id <= get_maxplayers()){
		if (killer){
			message_begin( MSG_ALL, gmsgDeathMsg)
			write_byte(killer)
			write_byte(id)
			write_string(weapon)
			message_end()
			new frags = 1
			new id_team = entity_get_int(id, EV_INT_team)
			new killer_team = entity_get_int(killer, EV_INT_team)
			if (killer == id || killer_team == id_team)
				frags = -1
			set_user_frags(killer, get_user_frags(killer) + frags)
			if (get_cvar_num("siegeweapons_getxp") == 1 && ns_is_combat() && killer != id)
				ns_set_exp(killer,ns_get_exp(killer)+get_cvar_num("siegeweapons_amountxp"))
		}
	}
	return PLUGIN_HANDLED
}

stock bool:is_building( classname[])
{
	//if ( equal( classname,"player" ) ) 
	//	return true
	if ( equal( classname,"item_mine" ) ) 
		return true
	else if ( equal( classname,"team_command" ) ) 
		return true
	else if ( equal( classname,"team_armory" ) )
		return true
	else if ( equal( classname,"team_advarmory" ) )
		return true
	else if ( equal( classname,"phasegate" ) )
		return true
	else if ( equal( classname,"resourcetower" ) )
		return true
	else if ( equal( classname,"team_turretfactory" ) ) 
		return true
	else if ( equal( classname,"team_armslab" ) ) 
		return true
	else if ( equal( classname,"team_prototypelab" ) ) 
		return true
	else if ( equal( classname,"team_observatory" ) )
		return true
	else if ( equal( classname,"turret" ) )
		return true
	else if ( equal( classname,"siegeturret" ) )
		return true
	else if ( equal( classname,"alienresourcetower" ) )
		return true
	else if ( equal( classname,"offensechamber" ) )
		return true
	else if ( equal( classname,"defensechamber" ) )
		return true
	else if ( equal( classname,"sensorychamber" ) )
		return true		
	else if ( equal( classname,"movementchamber" ) )
		return true		
	else if ( equal( classname,"team_hive" ) )
		return true		
	else if ( equal( classname,"func_breakable" ) )	//breakable objects included
		return true		
	
	return false
}