/* AMX Mod script. 
* 
* (c) Copyright 2002-2003, f117bomb 
* This file is provided as is (no warranties). 
*/   

#include <amxmodx> 
#include <amxmisc>
#include <fun> 

/* 
* Makes user turn into a rocket and explode in the air with visual effects 
* Usage: amx_rocket <authid, nick, @team or #userid> 
* 
*/ 

new  m_blueflare2,mflash,gmsgDamage,white,smoke,rocket_z[33] 

/********************************** ROCKET FUNCTIONS *****************************/ 
public rocket_liftoff(svictim[])   { 
    new victim = svictim[0] 
     
    set_user_gravity(victim,-0.50) 
    client_cmd(victim,"+jump;wait;wait;-jump") 
    emit_sound(victim, CHAN_VOICE, "weapons/rocket1.wav", 1.0, 0.5, 0, PITCH_NORM) 
    rocket_effects(svictim) 
     
    return PLUGIN_CONTINUE 
} 

public rocket_effects(svictim[])   { 
    new victim = svictim[0] 
     
    if ( is_user_alive(victim) )   { 
        new vorigin[3] 
        get_user_origin(victim,vorigin)     
                 
        message_begin(MSG_ONE, gmsgDamage, {0,0,0}, victim) 
        write_byte(30) // dmg_save 
        write_byte(30) // dmg_take 
        write_long(1<<16) // visibleDamageBits 
        write_coord(vorigin[0]) // damageOrigin.x 
        write_coord(vorigin[1]) // damageOrigin.y 
        write_coord(vorigin[2]) // damageOrigin.z 
        message_end()     
         
        if(rocket_z[victim] == vorigin[2])     
            rocket_explode(svictim)         
         
        rocket_z[victim] = vorigin[2]     
         
        //Draw Trail and effects 
             
        //TE_SPRITETRAIL - line of moving glow sprites with gravity, fadeout, and collisions 
        message_begin( MSG_BROADCAST, SVC_TEMPENTITY ) 
        write_byte( 15 ) 
        write_coord( vorigin[0]) // coord, coord, coord (start) 
        write_coord( vorigin[1]) 
        write_coord( vorigin[2]) 
        write_coord( vorigin[0]) // coord, coord, coord (end) 
        write_coord( vorigin[1]) 
        write_coord( vorigin[2] - 30) 
        write_short( m_blueflare2 ) // short (sprite index) 
        write_byte( 5 ) // byte (count) 
        write_byte( 1 ) // byte (life in 0.1's) 
        write_byte( 1 )  // byte (scale in 0.1's) 
        write_byte( 10 ) // byte (velocity along vector in 10's) 
        write_byte( 5 )  // byte (randomness of velocity in 10's) 
        message_end() 
         
        //TE_SPRITE - additive sprite, plays 1 cycle 
        message_begin( MSG_BROADCAST,SVC_TEMPENTITY) 
        write_byte( 17 ) 
        write_coord(vorigin[0])  // coord, coord, coord (position) 
        write_coord(vorigin[1])   
        write_coord(vorigin[2] - 30) 
        write_short( mflash ) // short (sprite index) 
        write_byte( 15 ) // byte (scale in 0.1's)   
        write_byte( 255 ) // byte (brightness) 
        message_end() 
         
        set_task(0.2, "rocket_effects" , 0 , svictim, 2) 
    } 
     
    return PLUGIN_CONTINUE     
} 

public rocket_explode(svictim[])   { 
    new victim = svictim[0] 
             
    if ( is_user_alive(victim) )   {   /*If user is alive create effects and user_kill */ 
        new vec1[3] 
        get_user_origin(victim,vec1) 
         
        // blast circles 
        message_begin( MSG_BROADCAST,SVC_TEMPENTITY,vec1) 
        write_byte( 21 ) 
        write_coord(vec1[0]) 
        write_coord(vec1[1]) 
        write_coord(vec1[2] - 10) 
        write_coord(vec1[0]) 
        write_coord(vec1[1]) 
        write_coord(vec1[2] + 1910) 
        write_short( white ) 
        write_byte( 0 ) // startframe 
        write_byte( 0 ) // framerate 
        write_byte( 2 ) // life 
        write_byte( 16 ) // width 
        write_byte( 0 ) // noise 
        write_byte( 188 ) // r 
        write_byte( 220 ) // g 
        write_byte( 255 ) // b 
        write_byte( 255 ) //brightness 
        write_byte( 0 ) // speed 
        message_end() 
         
        //Explosion2 
        message_begin( MSG_BROADCAST,SVC_TEMPENTITY) 
        write_byte( 12 ) 
        write_coord(vec1[0]) 
        write_coord(vec1[1]) 
        write_coord(vec1[2]) 
        write_byte( 188 ) // byte (scale in 0.1's) 
        write_byte( 10 ) // byte (framerate) 
        message_end() 
         
        //Smoke 
        message_begin( MSG_BROADCAST,SVC_TEMPENTITY,vec1) 
        write_byte( 5 ) 
        write_coord(vec1[0]) 
        write_coord(vec1[1]) 
        write_coord(vec1[2]) 
        write_short( smoke ) 
        write_byte( 2 ) 
        write_byte( 10 ) 
        message_end()     
         
        user_kill(victim,1) 
    } 
             
     
    //stop_sound 
    emit_sound(victim, CHAN_VOICE, "weapons/rocket1.wav", 0.0, 0.0, (1<<5), PITCH_NORM) 
     
    set_user_maxspeed(victim,1.0)     
    set_user_gravity(victim,1.00) 

    return PLUGIN_CONTINUE 
} 


public rocket_player(id,level,cid) { 
    if (!cmd_access(id,level,cid,2)) 
        return PLUGIN_HANDLED 
    new arg[32],arg2[3] 
    read_argv(1,arg,31) 
    read_argv(2,arg2,2)      
    if (arg[0]=='@') { 
        new players[32], inum , name[32] 
        get_players(players,inum,"ae",arg[1]) 
        if (inum==0){ 
            console_print(id,"No clients in such team") 
            return PLUGIN_HANDLED 
        } 
        for(new a=0;a<inum;++a){ 
            if (get_user_flags(players[a])&ADMIN_IMMUNITY){ 
                get_user_name(players[a],name,31) 
                console_print(id,"Skipping ^"%s^" because client has immunity",name) 
                continue 
            } 
            new sPlayer[2] 
            sPlayer[0] = players[a] 
            emit_sound(players[a],CHAN_WEAPON ,"weapons/rocketfire1.wav", 1.0, ATTN_NORM, 0, PITCH_NORM) 
            set_user_maxspeed(players[a],0.01)                                 
            set_task(1.2, "rocket_liftoff" , 0 , sPlayer, 2) 
        } 
    } 
    else { 
        new player = cmd_target(id,arg,5) 
        if (!player) 
            return PLUGIN_HANDLED 
        new sPlayer[2] 
        sPlayer[0] = player 
        emit_sound(player,CHAN_WEAPON ,"weapons/rocketfire1.wav", 1.0, ATTN_NORM, 0, PITCH_NORM) 
        set_user_maxspeed(player,0.01)                                 
        set_task(1.2, "rocket_liftoff" , 0 , sPlayer, 2) 
         
        new playername[32] 
        get_user_name(player,playername,31) 
        console_print(id,"Client ^"%s^" has been set to explode...",playername) 
    } 
     
    return PLUGIN_HANDLED 
}   

public plugin_precache()   {   
    mflash = precache_model("sprites/muzzleflash.spr") 
    m_blueflare2 = precache_model( "sprites/blueflare2.spr") 
    smoke = precache_model("sprites/steam1.spr") 
    white = precache_model("sprites/white.spr") 
    precache_sound("weapons/rocketfire1.wav") 
    precache_sound("weapons/rocket1.wav") 
     
    return PLUGIN_CONTINUE 
} 

public plugin_init() {   
   register_plugin("Admin Rocket","1.3","f117bomb")   
   register_concmd("amx_rocket","rocket_player",ADMIN_SLAY,"<authid, nick, @team or #userid>")   
   gmsgDamage = get_user_msgid("Damage") 
    
   return PLUGIN_CONTINUE   
}