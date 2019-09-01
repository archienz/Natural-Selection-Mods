/* Plugin generated by AMXX-Studio */

#include <amxmodx>
#include <amxmisc>
#include <fun>
#include <ns>

#define PLUGIN "God Mode For Bots"
#define VERSION "1.0"
#define AUTHOR "Masked Carrot"
new gGodMode = 0

public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	register_concmd("gmfb","cmd_gmfb",ADMIN_ADMIN,"<on/off>")
}
public client_spawn(id)
{
	if (gGodMode && is_user_bot(id))
	{
		set_user_godmode(id,1)
		set_user_rendering(id, kRenderFxGlowShell, 255, 0, 0, kRenderNormal, 16)
	}
	else
		set_user_godmode(id)
}
public cmd_gmfb(id,level,cid)
{
	if (!cmd_access(id, level, cid, 2))
		return PLUGIN_HANDLED
	new arg[4]
	
	read_argv(1,arg,3)
	if (equal(arg,"1") || equali(arg,"on"))
	{
		new msg[255]
		format (msg,254,"WARNING: God Mode For Bots has been Activated.^n Run for your lives!!!")
		set_hudmessage(255,255)
		show_hudmessage(0,msg)
		gGodMode = 1
	}
	else if(equal(arg,"1") || equali(arg,"off"))
	{
		new bots[32]
		new botcount
		get_players(bots,botcount,"d")
		for (new i=0; i<botcount; i++)
		{
			set_user_godmode(bots[i])
			set_user_rendering(bots[i])
		}
		new msg[255]
		format (msg,254,"Attention: God Mode For Bots has been De-Activated.^n You can relax now.")
		set_hudmessage(255,255)
		show_hudmessage(0,msg)
		gGodMode = 0
	}
	return PLUGIN_HANDLED
}
		

	