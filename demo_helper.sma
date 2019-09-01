/*
Demo Helper - v2.0

IF YOU'RE NOT AN DEVELOPER, IGNORE THIS FILE

This plugin is intended to show the new features of the Helper and serves no
other (useful) purpose.
*/
////////////////////////////////////////////////////////////////////////////////
//                           Configuration                                    //
////////////////////////////////////////////////////////////////////////////////
/*
INT (0)
0 - Do use default helper output
1 - Use the "Helper" plugin! (recommended)
*/
#define HELPER 1                                                                // It's recommended to use a define named exactly(!) like this to give server ops a consistent configuration

////////////////////////////////////////////////////////////////////////////////
//      NO need to edit anything below unless you know what you're doing      //
////////////////////////////////////////////////////////////////////////////////
#include <amxmodx>
#include <fakemeta>

#if HELPER == 1                                                                 // make sure we only include the helper if we actually want to use it! server ops may not have this file and therefor do not wish to include it, although it doesn't harm if the Helper is disabled
  #include <helper>
#else
  #define help_add set_localinfo                                                // hax hax, this will allow us to use help_add although we did not include the helper
#endif                                                                          // it will replace all help_adds with set_localinfos. this doesn't do any harm as the forwards aren't called anyway
                                                                                // this way is recommended as it requires the least work

public plugin_init(){
  register_plugin("Demo Helper","2.0","mE @ PsiX.org")
  register_cvar("demo_enable","1")
}

public client_help(id){                                                       // this forward will be called if the client selects this plugin when he said /help
  help_add("Information","This plugin serves no purpose and should not be used at all :-P")
  if(get_cvar_num("demo_enable")){
    if(pev(id,pev_team) == 1){                                                // you can nest your conditions as you wish and add help texts as you need to
      help_add("Usage","If you jump twice while holding down your use-key, nothing special will happen.")
    }else{
      help_add("Usage","This plugin only affects marines")
    }
  }else{
    help_add("Usage","Plugin currently disabled")
  }                                                                           // if you return PLUGIN_HANDLED, nothing will be displayed at all
}

public client_advertise(id){                                                  // this forward will be called for every client when the round starts (or a client joins later on)
  if(get_cvar_num("demo_enable")) return PLUGIN_CONTINUE                      // all you have to do is to return PLUGIN_HANDLED if you don't want to show that this plugin is running or
  return PLUGIN_HANDLED                                                       // return anything else (or even nothing at all) to append this plugin to the list of game-altering plugins.
}                                                                             // you can make the return depend on the client if you only want to inform certain clients (like only team 1 or only admins)
