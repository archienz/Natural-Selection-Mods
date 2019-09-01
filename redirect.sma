#include <amxmodx> 

#define MAX_SERVERS 4 
#define MAX_SERVER_STRING 33 

new numServers = 0 
new serverList[MAX_SERVERS][MAX_SERVER_STRING] 
new serverMax = MAX_SERVERS 

public redirect() 
{ 
    if (read_argc() != 2) 
    { 
        server_print("Usage: amx_redirect <ip:port>") 
        return PLUGIN_HANDLED 
    } 
    else if ((numServers + 1) > serverMax) 
    { 
        server_print("[AMX] Max Number of Redirect Servers Reached.") 
        return PLUGIN_HANDLED 
    } 
    else 
    { 
        new currServer[MAX_SERVER_STRING] 
        read_argv(1,currServer,MAX_SERVER_STRING) 
        /* Check for dups. */ 
        for(new i = 0; i < numServers; i++) 
        { 
            if(equal(currServer,serverList[i])) 
            { 
                server_print("[AMX] Redirect Server %s already exists!",currServer) 
                return PLUGIN_HANDLED 
            } 
        } 

        copy(serverList[numServers],MAX_SERVER_STRING,currServer) 
        server_print("[AMX] Redirect Server added: %s",serverList[numServers]) 
        numServers++ 
        return PLUGIN_HANDLED 
    } 

    return PLUGIN_HANDLED 
} 

public redirect_reload() 
{ 
    numServers = 0 
    server_print("[AMX] Reloading Server Redirect List") 
    server_cmd("exec addons/amx/redirect.cfg") 
    
    return PLUGIN_HANDLED 
} 

redirect_client(id,randomServer) 
{ 
   client_cmd(id,"echo ^"Server is currently full^"") 
        client_cmd(id,"echo ^"Redirecting to %s^";wait;wait;connect %s",serverList[randomServer],serverList[randomServer]) 
} 

public client_connect(id) 
{ 
    new maxplayers 
    new reserved 
    new slotsfree 
    new reserveType 

    if(numServers > 0) 
    { 
        new randomServer 
        if(numServers > 1) 
            randomServer = random_num(0,numServers-1) 
        else 
            randomServer = 0 

        if(cvar_exists("amx_reserved_slots")) 
            reserved = get_cvar_num("amx_reserved_slots") 
        else 
            reserved = 0 
            
        if(cvar_exists("amx_reservation")) 
            reserveType = get_cvar_num("amx_reservation") 
        else 
            reserveType = 0 
                    
        maxplayers = get_maxplayers() 

        new players = get_playersnum() + 1 /* on connection we must add you */ 
        slotsfree = maxplayers - players 
        //if ( ((slotsfree <= 0) || (slotsfree <= reserved)) && ((reserveType == 0) || (reserveType == 3)) ) 
        if ( (reserveType == 0) || (reserveType == 3) ) 
        { 
                if(slotsfree <= 0) 
                   redirect_client(id,randomServer) 
                else if((slotsfree <= reserved) && (!(get_user_flags(id) & ADMIN_RESERVATION))) 
                { 
                   redirect_client(id,randomServer) 
                   return PLUGIN_HANDLED 
                } 
        } 
        else if( ((reserveType == 1) || (reserveType == 2)) ) 
        { 
           if( !(get_user_flags(id) & ADMIN_RESERVATION) ) 
           { 
              if( slotsfree <= 0 ) 
              { 
                 redirect_client(id,randomServer) 
       return PLUGIN_HANDLED 
         } 
      } 
        } 
    } 

    return PLUGIN_CONTINUE 
} 

public plugin_init() 
{ 
    register_cvar("KEEG_Redirect", "0.3.2",FCVAR_SERVER) 
    register_plugin("AMX Redirect","0.3.2","Namralkeeg") 
    register_srvcmd("amx_redirect", "redirect") 
    register_srvcmd("amx_redirect_reload","redirect_reload") 
    server_cmd("exec addons/amx/redirect.cfg") 

    return PLUGIN_CONTINUE 
} 
