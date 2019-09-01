#include <amxmodx>


public plugin_int(){
	register_plugin("Magic 8ball","1.17","Melanie Maye")
	register_concmd("say","handle_say")
}

public handle_say(id){
	new Text[200]
	read_args(Text,199)
	remove_quotes(Text)
	trim(Text)
	if(equali(Text,"8ball",5)){
		new name[33]
		get_user_name(id,name,32)
		replace(Text,299,"8ball","")
		format(Text,299,"%s : ((%s ))",name,Text)
		new ball_display[100]
		get_display(ball_display)
		set_hudmessage( 255, 0, 0, -1.0, -1.0, 0, 6.0, 5.0, 0.5, 1.5, 4 )
   		show_hudmessage(0, "Question: %s^n Answer: %s", Text,ball_display)
	}
	return PLUGIN_CONTINUE
		
}

public get_display(str[]){
	new ran = random_num(0,19)
	switch(ran){
	case 0: format(str,strlen(str),"Indeed.")
	case 1: format(str,strlen(str),"Yes")
	case 2: format(str,strlen(str),"Outlook Good")
	case 3: format(str,strlen(str),"Most definitely")
	case 4: format(str,strlen(str),"99.999% chance")
	case 5: format(str,strlen(str),"In all likely hood, Yes")
	case 6: format(str,strlen(str),"Time will tell")
	case 7: format(str,strlen(str),"Outlook vague; try again")
	case 8: format(str,strlen(str),"You do not need to know at this point in time")
	case 9: format(str,strlen(str),"Signs point to no")
	case 10: format(str,strlen(str),"It is Woody's opinion that No, that will not happen")
	case 11: format(str,strlen(str),"Sorry Sucka: NO")
	case 12: format(str,strlen(str),"NO")
	case 13: format(str,strlen(str),"Definitely not")
	case 14: format(str,strlen(str),"Woody deems it probable")
	case 15: format(str,strlen(str),"Yes, that is true. So has the 8ball decreed")
	case 16: format(str,strlen(str),"Personally? No chance in hell")
	case 17: format(str,strlen(str),"Seems logical, my  money is on yes")
	case 18: format(str,strlen(str),"Maybe")
	case 19: format(str,strlen(str),"Woody rubs his, oops i mean the magic 8ball. Their answer is, Nope")
	}
	return PLUGIN_HANDLED;
}
