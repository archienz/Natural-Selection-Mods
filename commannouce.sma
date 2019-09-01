#include <amxmodx>

public plugin_init() {
	register_plugin("CommVote","0.1","devicenull")
	register_logevent("votedown",5,"2=votedown")
}

public votedown() {
	new logone[256],logtwo[256] //First player info, second player info
	new name[128],authid[35]  //Players name and authid
	new cname[128],cauthid[35]  //Commanders name and authid
	new unum, team[2]   //I don't use these.
	
	read_logargv(0,logone,256)
	read_logargv(4,logtwo,256)
	
	parse_loguser(logone,name,128,unum,authid,35,team,2)
	parse_loguser(logtwo,cname,128,unum,cauthid,35,team,2)
	
	client_print(0,print_chat,"%s (%s) wants to eject %s (%s)",name,authid,cname,cauthid)
}