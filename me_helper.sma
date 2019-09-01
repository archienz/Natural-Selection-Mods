////////////////////////////////////////////////////////////////////////////////
//                            Information                                     //
////////////////////////////////////////////////////////////////////////////////
/*
Helper (v2.0 - 25.06.06)
By: mE @ PsiX.org

Description:
  This plugin provides an consistent help interface for all plugins that alter
  the gameplay and need to inform the client about this. Clients simply have to
  type /help in chat mode to open up a menu which lists all plugins detected.
  It also allows plugins to "advertise", ie showing up a message on round start
  to inform clients that the gameplay has been changed.

Installation:
  Place the help.inc (included in the zip) into the "include" folder and then
  install this plugin just like any other. Plugins supporting "Helper" should
  have a define named "HELPER" within their configuration section which has to
  be set to "1" and recompiled in order to work.
*/
////////////////////////////////////////////////////////////////////////////////
//      NO need to edit anything below unless you know what you're doing      //
////////////////////////////////////////////////////////////////////////////////
#include <amxmodx>
#include <fakemeta>

#define PLUGIN_NAME "Helper"
#define PLUGIN_VERSION "2.0"
#define PLUGIN_AUTHOR "mE @ PsiX.org"


new bool:g_ingame
new bool:g_advertised
new g_maxplayers

new g_menu = -1
new g_active
new ua_menu[33]

public plugin_init(){
  register_plugin(PLUGIN_NAME,PLUGIN_VERSION,PLUGIN_AUTHOR)
  register_cvar("me_helper",PLUGIN_VERSION,FCVAR_SERVER)
  
  register_clcmd("say /help","help_request")
  register_clcmd("say_team /help","help_request")

  register_event("Countdown", "round_start", "ac")
  register_event("GameStatus","round_end", "ab", "1=2" )
  
  g_maxplayers = get_maxplayers()
  for(new id=1;id<=g_maxplayers;id++){
    ua_menu[id] = -1
  }
  set_task(0.1,"plugin_loadup")
}

public plugin_end(){
  /*
  if(g_menu != -1) menu_destroy(g_menu)

  for(new id=1;id<=g_maxplayers;id++){
    if(ua_menu[id] != -1) menu_destroy(ua_menu[id])
  }
  */
}

public plugin_loadup(){
  g_menu = menu_create("Helper","help_select")
  
  new num
  new plugin = is_plugin_loaded(PLUGIN_NAME)
  if(plugin != -1){
    if(plugin_add(plugin)) num++
  }
  new plugins = get_pluginsnum()
  for(new i=0;i<plugins;i++){
    if(i == plugin) continue
    if(plugin_add(i)) num++
  }
  if(num){
    menu_setprop(g_menu,MPROP_EXIT,MEXIT_ALL)
    menu_setprop(g_menu,MPROP_PADMENU,MENUPAD_PAGE)
    
    server_print("[Help] %d/%d plugins implemented help",num,plugins)
  }else{
    //menu_destroy(g_menu)
    g_menu = -1
  }
}

public plugin_add(plugin){
  new func = get_func_id("client_help",plugin)
  if(func == -1) return 0
  if(callfunc_begin_i(func,plugin) != 1) return 0
  callfunc_push_int(0)
  if(callfunc_end() == PLUGIN_HANDLED) return 0

  new dummy[2]
  new pname[33]
  get_plugin(plugin,dummy,1,pname,32,dummy,1,dummy,1,dummy,1)
  dummy[0] = plugin
  menu_additem(g_menu,pname,dummy)
  return 1
}

public help_add(caption[],content[]){
  if(!g_active) return 0
  
  new msg[512]
  format(msg,511,"%s^n%s^n",caption,content)
  replace_all(msg,511,"^n","^n  ")
  menu_additem(ua_menu[g_active],msg,"") // (1<<26)
  //menu_addblank(ua_menu[g_active],0)
  return 1
}

public client_help(id){
  help_add("Information","This plugin provides an consistent help interface for all plugins that alter the gameplay.")
  help_add("Usage","Say /help (just like you did) and select the desired plugin to show further information")
}

public client_changeteam(id,newteam,oldteam){
  remove_task(id)
  if(g_advertised && newteam){
    set_task(0.5,"advertise",id)
  }
}

public client_disconnect(id){
  remove_task(id)
  if(ua_menu[id] != -1){
    //menu_destroy(ua_menu[id])
    ua_menu[id] = -1
  }
}

public round_start(){
  if(!g_ingame){
    g_ingame = true
    set_task(2.0,"advertise",123)
  }
}

public round_end(){
  if(g_ingame){
    g_ingame = false
    g_advertised = false
    remove_task(123)
  }
}

public advertise(id){
  new limit
  if(id == 123){
    id = 1
    limit = g_maxplayers
    g_advertised = true
  }else{
    limit = id
  }
  if(g_menu == -1) return
  new plugins = menu_items(g_menu)

  for(;id<=limit;id++){
    if(!is_user_connected(id)) continue
    
    new msg[256] = "[Help] Say /help. Game-Altering plugin:"
    new num
    for(new i=0;i<plugins;i++){
      new plugin
      new pname[33]
      new cmd[2]
      menu_item_getinfo(g_menu,i,plugin,cmd,1,pname,32,plugin)
      plugin = cmd[0]
      
      new func = get_func_id("client_advertise",plugin)
      if(func == -1) continue
      if(callfunc_begin_i(func,plugin) != 1) continue
      callfunc_push_int(id)
      if(callfunc_end() == PLUGIN_HANDLED) continue
      
      if(num++){
        format(msg,255,"%s, %s",msg,pname)
      }else{
        format(msg,255,"%s %s",msg,pname)
      }
    }
    if(num){
      client_print(id,print_chat,msg)
    }else{
      client_print(id,print_chat,"[Help] Say /help. No game-altering plugins loaded")
    }
  }
  return
}

public help_request(id){                                                        // client requests help
  if(g_menu == -1){                                                             // empty menu
    client_print(id,print_chat,"[Help] No help available")
    return PLUGIN_CONTINUE
  }
  if(ua_menu[id] != -1){                                                        // client is already viewing plugin's help
    //menu_destroy(ua_menu[id])                                                   // clear old menu
    ua_menu[id] = -1
  }
  menu_display(id,g_menu,0)
  return PLUGIN_CONTINUE
}

public help_select(id,menu,item){                                               // client selects <something> in the menu
  if(menu == ua_menu[id]){                                                      // selected something in a plugin's submenu
    if(item == MENU_EXIT){
      //menu_destroy(ua_menu[id])                                               // clear menu
      ua_menu[id] = -1
      help_request(id)                                                          // display main menu
    }else{
      menu_display(id,ua_menu[id],0)                                            // redisplay plugin's menu (as this was an invalid choice)
    }
    return PLUGIN_HANDLED
  }
  if(menu != g_menu){
    client_print(0,print_chat,"help_select(%d,%d,%d) called!?!?!?!?!?!?!?",id,menu,item)
    return PLUGIN_HANDLED
  }
  if(item == MENU_EXIT){                                                        // client selected exit
    return PLUGIN_HANDLED
  }
  new plugin
  new pname[33]
  new cmd[2]
  menu_item_getinfo(menu,item,plugin,cmd,1,pname,32,plugin)

  plugin      = cmd[0]
  g_active    = id
  ua_menu[id] = menu_create(pname,"help_select")
  
  new dummy[2]
  new pversion[33]
  new pauthor[33]
  get_plugin(plugin,dummy,1,dummy,1,pversion,32,pauthor,32,dummy,1)
  new msg[64]
  format(msg,63,"v%s by %s",pversion,pauthor)
  help_add("Plugin",msg)
  
  new func    = get_func_id("client_help",plugin)
  if(func == -1){
    help_add("Error","No Helper defined")
  }else{
    if(callfunc_begin_i(func,plugin) != 1){
      help_add("Error","Internal error while requesting help")
    }else{
      callfunc_push_int(id)
      if(callfunc_end() == PLUGIN_HANDLED){
        //menu_destroy(ua_menu[id])
        g_active = 0
        ua_menu[id] = -1
        return PLUGIN_HANDLED
      }
    }
  }
  g_active = 0
  menu_setprop(ua_menu[id],MPROP_EXIT,MEXIT_ALL)
  menu_setprop(ua_menu[id],MPROP_PADMENU,MENUPAD_PAGE)
  menu_setprop(ua_menu[id],MPROP_EXITNAME,"Index")
  menu_display(id,ua_menu[id],0)

  return PLUGIN_HANDLED
}
