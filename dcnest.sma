/* DC Nest Block - 1.0
 * -
 * This plugin halts operation of defense chambers when there
 * there are no building or operational hives.  This prevents
 * the all-too-common 'end of round hiding' on an average pub.
 *
 * This plugin auto disables itself in tournament mode.
 * (mp_tournamentmode > 0)
 */
 
#include <amxmodx>
#include <engine>
#include <ns>

#define SOLID_BBOX 2

public plugin_modules()
{
  require_module("engine");
  require_module("ns");
}

public plugin_init()
{
  register_plugin("DC Nest Block","1.0","Steve Dudenhoeffer");
  if (!ns_is_combat())
    register_think("defensechamber","dc_think");
}

public dc_think(id)
{
  if (ns_get_build("team_hive",1,0) <= 0 && !get_cvar_num("mp_tournamentmode"))
  {
    // quickly check to make sure no hives are being built (get_build doesn't detect this properly...)
    new hive=0;
    new found=0;
    while ((hive=find_ent_by_class(hive,"team_hive"))!=0)
      if (entity_get_int(hive,EV_INT_solid)==SOLID_BBOX) found=1;

    if (found) // There is a building hive, let this defense chamber operate
      return PLUGIN_CONTINUE
    entity_set_float(id,EV_FL_nextthink,halflife_time() + 2.0); // incase the hive goes back up, this line lets the DC think at a later time
    return PLUGIN_HANDLED;
  }
  return PLUGIN_CONTINUE;
}