/*
This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
*/

/*
 * Votemap after Crash 1.0
 * by Manuel Mausz <manuel at mausz dot at>
 *
 * Start a map vote after server crash (for Natural-Selection).
 *
 * Tested with Crab's Map Manager. Should work with almost any mapvote
 * plugin which has a console command or function exported to start the vote.
 */

#include <amxmodx>

// Time (seconds) before a message about the server crash and the upcoming
// map vote will occur. The timer starts after loading the plugin.
#define TIME_CRASHINFO 30

// Time (seconds) before the map vote command will be executed. The timer
// starts after loading the plugin.
#define TIME_MAPVOTE   50

// Command type.
//   0 = console command (rcon command)
//   1 = plugin function name
#define CMD_TYPE       0

// Plugin name which contains the function to be executed. This will only be only
// used if command type is set to 1.
#define CMD_PLUGIN   "Nextmap Chooser"

// Command or function name to be executed. Depends on command type (see above)
#define CMD_NAME     "amx_startmapvote"
//#define CMD_NAME   "voteNextmap"

new g_firstmap[32];
new g_found    = 0;
new g_pluginid = -1;
new g_funcid   = -1

public plugin_init()
{
  register_plugin( "Votemap after Crash", "1.0", "manuel" );
  register_cvar( "amx_firstmap", "" );

  get_cvar_string( "amx_firstmap", g_firstmap, 31 );
  if ( equal( g_firstmap, "" ) )
  {
    get_mapname( g_firstmap, 31 );
    set_cvar_string( "amx_firstmap", g_firstmap );

    check_command();
    set_task( float(TIME_CRASHINFO), "print_crashinfo" );
    set_task( float(TIME_MAPVOTE), "start_mapvote" );
  }
}

public check_command()
{
  new cmd_type = CMD_TYPE;
  if ( !cmd_type )
  {
    new flags = read_flags( "abcdefghijklmnopqrstuvwxyz" );
    new cmds  = get_concmdsnum( flags, 0 );

    new info[128], cmd[32], eflags;
    for (new i = 0; i < cmds; i++)
    {
      get_concmd( i, cmd, 31, eflags, info, 127, flags, 0 );
      if ( equal( cmd, CMD_NAME ))
        g_found = 1;
    }
  }
  else
  {
    new plugins = get_pluginsnum();

    new name[32], version[32], author[32], filename[32], status[32];
    for (new i = 0; i < plugins; i++)
    {
      get_plugin(i, filename, 31, name, 31, version, 31, author, 31, status, 31);
      if ( equal( name, CMD_PLUGIN ) )
      {
        g_pluginid = i;
        g_funcid   = get_func_id( CMD_NAME, g_pluginid );
        if (g_funcid >= 0)
          g_found = 1;
      }
    }
  }

  return PLUGIN_CONTINUE;
}

public print_crashinfo()
{
  if ( g_found )
    client_print( 0, print_chat, "The server just crashed. A map vote will start soon." );

  return PLUGIN_HANDLED;
}

public start_mapvote()
{
  if ( g_found )
  {
    new cmd_type = CMD_TYPE;
    if ( !cmd_type )
      server_cmd( CMD_NAME );
    else
    {
      new status = callfunc_begin_i( g_funcid, g_pluginid );
      if (status == 1)
        callfunc_end();
    }
  }

  return PLUGIN_HANDLED;
}

