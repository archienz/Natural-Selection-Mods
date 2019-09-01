// A *All In One* Plugin For Natural-Selection.
// Made by XunTric 

#include <amxmodx> 
#include <amxmisc> 
#include <ns> 

public plugin_init() 
{ 
    register_plugin("NS Small *All In One*", "1.1", "XunTric") 
    register_concmd("amx_res", "cmdres", ADMIN_KICK, "<name> <resources to give> *Alien Players Only*")
    register_concmd("amx_kills", "cmdkills", ADMIN_KICK, "<name> <kills to give>")
    register_concmd("amx_exp", "cmdexp", ADMIN_KICK, "<name> <exp to give> *Co maps only*") 
    register_concmd("amx_deaths", "cmddeaths", ADMIN_KICK, "<name> <deaths to give>")
    register_concmd("amx_points", "cmdpoints", ADMIN_KICK, "<name> <points to give>")
    register_concmd("amx_hmg", "hmg", ADMIN_KICK, "<name> Gives a player a HMG *Marine Only*")
    register_concmd("amx_gl", "gl", ADMIN_KICK, "<name> Gives a player a GL (Granade Luncher) *Marine Only*")
    register_concmd("amx_shotgun", "shotgun", ADMIN_KICK, "<name> Gives a player a shotgun *Marine Only*")
    register_concmd("amx_welder", "welder", ADMIN_KICK, "<name> Gives a player a welder *Marine Only*")
    register_concmd("amx_jetpack", "jetpack", ADMIN_KICK, "<name> Gives a player a jetpack *Marine Only*")
    register_concmd("amx_ha", "ha", ADMIN_KICK, "<name> Gives a player a HA (heavy armor) *Marine Only*")
    register_concmd("amx_mine", "mine", ADMIN_KICK, "<name> Gives a player a mine *Marine Only*")
} 

//Give Resources

public cmdres(id,level,cid) 
{ 
    if (!cmd_access(id,level,cid,3)) 
         return PLUGIN_HANDLED 

    new arg1[32], arg2[32] 
    read_argv(1,arg1,31) 
    read_argv(2,arg2,31) 

    new player = cmd_target(id,arg1,2) 

    if(!player) 
         return PLUGIN_HANDLED 

    ns_set_res(player,ns_get_res(player) + str_to_num(arg2)) 
    client_print(player, print_chat, "The admin gave you %i resources",str_to_num(arg2)) 
    return PLUGIN_HANDLED 
} 

//Change Kills

public cmdkills(id,level,cid)
{ 
    if (!cmd_access(id,level,cid,3)) 
         return PLUGIN_HANDLED 

    new arg1[32], arg2[32] 
    read_argv(1,arg1,31) 
    read_argv(2,arg2,31) 

    new player = cmd_target(id,arg1,2) 

    if(!player) 
         return PLUGIN_HANDLED 

    ns_set_score(player,ns_get_score(player) + str_to_num(arg2)) 
    client_print(player, print_chat, "The admin gave you %i kill scores",str_to_num(arg2)) 
    return PLUGIN_HANDLED 
} 

//Change Exp

public cmdexp(id,level,cid)
{ 
    if (!cmd_access(id,level,cid,3)) 
         return PLUGIN_HANDLED 

    new arg1[32], arg2[32] 
    read_argv(1,arg1,31) 
    read_argv(2,arg2,31) 

    new player = cmd_target(id,arg1,2) 

    if(!player) 
         return PLUGIN_HANDLED 

    ns_set_exp(player,ns_get_exp(player) + str_to_num(arg2)) 
    client_print(player, print_chat, "The admin gave you %i exp",str_to_num(arg2)) 
    return PLUGIN_HANDLED 
} 

//Set Deaths

public cmddeaths(id,level,cid) 
{ 
    if (!cmd_access(id,level,cid,3)) 
         return PLUGIN_HANDLED 

    new arg1[32], arg2[32] 
    read_argv(1,arg1,31) 
    read_argv(2,arg2,31) 

    new player = cmd_target(id,arg1,2) 

    if(!player) 
         return PLUGIN_HANDLED 

    ns_set_deaths(player,ns_get_deaths(player) + str_to_num(arg2)) 
    client_print(player, print_chat, "The admin gave you %i death scores",str_to_num(arg2)) 
    return PLUGIN_HANDLED 
} 

//Set Points

public cmdpoints(id,level,cid) 
{ 
    if (!cmd_access(id,level,cid,3)) 
         return PLUGIN_HANDLED 

    new arg1[32], arg2[32] 
    read_argv(1,arg1,31) 
    read_argv(2,arg2,31) 

    new player = cmd_target(id,arg1,2) 

    if(!player) 
         return PLUGIN_HANDLED 

    ns_set_score(player,ns_get_score(player) + str_to_num(arg2)) 
    client_print(player, print_chat, "The admin gave you %i points",str_to_num(arg2)) 
    return PLUGIN_HANDLED
}

//Give HMG

public hmg(id,level,cid) 
{    
    if (!cmd_access(id,level,cid,2)) 
         return PLUGIN_HANDLED 

    new arg[32] 
    read_argv(1,arg,31) 

    new player = cmd_target(id,arg,2) 

    if(!player) 
         return PLUGIN_HANDLED 

    new name[64]; 
    get_user_name(player,name,63);

    ns_give_item(player, "weapon_heavymachinegun")
    client_print(player, print_chat, "The admin gave you a HMG")
    return PLUGIN_HANDLED
}

//Give GL

public gl(id,level,cid) 
{    
    if (!cmd_access(id,level,cid,2)) 
         return PLUGIN_HANDLED 

    new arg[32] 
    read_argv(1,arg,31) 

    new player = cmd_target(id,arg,2) 

    if(!player) 
         return PLUGIN_HANDLED 

    new name[64]; 
    get_user_name(player,name,63);

    ns_give_item(player, "weapon_grenadegun")
    client_print(player, print_chat, "The admin gave you a GL")
    return PLUGIN_HANDLED
}

//Give Shotgun

public shotgun(id,level,cid) 
{    
    if (!cmd_access(id,level,cid,2)) 
         return PLUGIN_HANDLED 

    new arg[32] 
    read_argv(1,arg,31) 

    new player = cmd_target(id,arg,2) 

    if(!player) 
         return PLUGIN_HANDLED 

    new name[64]; 
    get_user_name(player,name,63);

    ns_give_item(player, "weapon_shotgun")
    client_print(player, print_chat, "The admin gave you a shotgun")
    return PLUGIN_HANDLED
}

//Give Jetpack

public jetpack(id,level,cid) 
{    
    if (!cmd_access(id,level,cid,2)) 
         return PLUGIN_HANDLED 

    new arg[32] 
    read_argv(1,arg,31) 

    new player = cmd_target(id,arg,2) 

    if(!player) 
         return PLUGIN_HANDLED 

    new name[64]; 
    get_user_name(player,name,63);

    ns_give_item(player, "item_jetpack")
    client_print(player, print_chat, "The admin gave you a jetpack")
    return PLUGIN_HANDLED
}

//Give Heavy Armor

public ha(id,level,cid) 
{    
    if (!cmd_access(id,level,cid,2)) 
         return PLUGIN_HANDLED 

    new arg[32] 
    read_argv(1,arg,31) 

    new player = cmd_target(id,arg,2) 

    if(!player) 
         return PLUGIN_HANDLED 

    new name[64]; 
    get_user_name(player,name,63);

    ns_give_item(player, "item_heavyarmor")
    client_print(player, print_chat, "The admin gave you a heavy armor")
    return PLUGIN_HANDLED
}

//Give Welder

public welder(id,level,cid) 
{    
    if (!cmd_access(id,level,cid,2)) 
         return PLUGIN_HANDLED 

    new arg[32] 
    read_argv(1,arg,31) 

    new player = cmd_target(id,arg,2) 

    if(!player) 
         return PLUGIN_HANDLED 

    new name[64]; 
    get_user_name(player,name,63);

    ns_give_item(player, "weapon_welder")
    client_print(player, print_chat, "The admin gave you a welder")
    return PLUGIN_HANDLED
}

//Give Mine

public mine(id,level,cid) 
{    
    if (!cmd_access(id,level,cid,2)) 
         return PLUGIN_HANDLED 

    new arg[32] 
    read_argv(1,arg,31) 

    new player = cmd_target(id,arg,2) 

    if(!player) 
         return PLUGIN_HANDLED 

    new name[64]; 
    get_user_name(player,name,63);

    ns_give_item(player, "weapon_mine")
    client_print(player, print_chat, "The admin gave you a mine")
    return PLUGIN_HANDLED
}