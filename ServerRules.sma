#include <amxmodx>

#include <file>

public plugin_init()  {
	register_plugin("Display rules on connect","1.00","[TeamHoward]PapaSmurf") 
	register_cvar("mp_displaytime","15.0",4)
	register_cvar("mp_red","255.0",4)
	register_cvar("mp_green","0.0",4)
	register_cvar("mp_blue","0.0",4)
	register_clcmd("say /rules","rules")
	register_clcmd("say_team /rules","rules")
}

public client_putinserver(id) {
set_task(10.0,"rules",id)
}

public rules(id)  {
	new line[80], len, Lines = 0
	new rulesTable[1280]
	new Float:displaytime = get_cvar_float("mp_displaytime")
	new red = get_cvar_num("mp_red")
	new green = get_cvar_num("mp_green")
	new blue = get_cvar_num("mp_blue")
	while (read_file("rules.txt", Lines++, line, 79, len))  {
		//thanks CheesyPeteza!
		format(line, 79,"%s^n",line)
		add(rulesTable,1279,line)
	}
	//thanks again CheesyPeteza!
	set_hudmessage(red,green,blue, 0.50, 0.06, 2, 0.02,displaytime, 0.01, 0.1, 4)
	show_hudmessage(id,rulesTable)
	return PLUGIN_HANDLED
}