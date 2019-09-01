#include <amxmodx>
#include <fakemeta>
#include <ns>

#pragma semicolon	1


#define LOG_TAG			"StickyChambers"
#define VERSION			"1.01"

#define IMPULSE_OC		91
#define IMPULSE_DC		92
#define IMPULSE_SC		93
#define IMPULSE_MC		94
#define HUD_SOUND		0
#define HUD_BUILT		1
#define HUD_SOUND_ALIEN_MORE	40
#define	CHAMBER_SOLID		SOLID_BBOX
#define	CHAMBER_MOVETYPE	MOVETYPE_FLY
#define OC_FIRE_HEIGHT		48.0
#define CLASSNAME_OC		"offensechamber"
#define EVENT_OFFENSECHAMBER	"events/OffenseChamber.sc"

#define SETTECH_IMPULSE		1
#define SETTECH_COST		5

#define	HT_INVALID		0
#define	HT_SET			-1	//already has a hive bound

#define OTHER			0
#define MARINE			1
#define ALIEN			2

#define PITCH			0
#define YAW			1
#define ROLL			2

//MACROS:

#define fm_write_coord(%1)	engfunc(EngFunc_WriteCoord, %1)
#define create_entity(%1)	engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, %1))
#define	angle_to_vector(%1,%2)	engfunc(EngFunc_AngleVectors, %1, %2, {0.0,0.0,0.0}, {0.0,0.0,0.0})
#define	remove_entity_soft(%1)	set_pev(%1, pev_flags, pev(%1, pev_flags) | FL_KILLME)
#define GetAimAngle(%1,%2)	pev(%1, pev_v_angle, %2)

#define get_team(%1)		pev(%1, pev_team)
#define set_team(%1,%2)		set_pev(%1, pev_team, %2)

#define	sin(%1)			floatsin(%1, degrees)
#define	cos(%1)			floatcos(%1, degrees)

#define VectorEqual(%1,%2)	(  (%1[0] == %2[0])\
				&& (%1[1] == %2[1])\
				&& (%1[2] == %2[2]) )

#define VectorAddSelf(%1,%2)	%1[0] += %2[0];\
				%1[1] += %2[1];\
				%1[2] += %2[2]

#define VectorSub(%1,%2,%3)	%3[0] = %1[0] - %2[0];\
				%3[1] = %1[1] - %2[1];\
				%3[2] = %1[2] - %2[2]

#define VectorMul(%1,%2,%3)	%3[0] = %1[0] * %2;\
				%3[1] = %1[1] * %2;\
				%3[2] = %1[2] * %2

#define VectorMulSelf(%1,%2)	%1[0] *= %2;\
				%1[1] *= %2;\
				%1[2] *= %2

#define	IsWorld(%1)		( pev_valid(%1)?(pev(%1, pev_flags) & FL_WORLDBRUSH):1 )


enum _:iUser3Values
{
	AVH_USER3_DEFENSE_CHAMBER = 42,
	AVH_USER3_MOVEMENT_CHAMBER,
	AVH_USER3_OFFENSE_CHAMBER,
	AVH_USER3_SENSORY_CHAMBER
};


new Float:g_kvMin[3] = {-16.0, -16.0,  0.0};	//constant, but not const
new Float:g_kvMax[3] = { 16.0,  16.0, 44.0};

new const g_krSound_ChamberSpawn[2][] = 
{
	"misc/a-build1.wav",
	"misc/a-build2.wav"
};

new g_iMaxPlayers;
new g_pcvarUnchained, g_pcvarMaxDist;
new g_pcvarCost_OC, g_pcvarCost_DC, g_pcvarCost_SC, g_pcvarCost_MC;
new g_iMsgID_PlayHUDNot, g_iMsgID_SetTech;

//-------------------------------------------------------------------------------------------------
//forwarded funcs

public plugin_precache()
{
	precache_sound(g_krSound_ChamberSpawn[0]);
	precache_sound(g_krSound_ChamberSpawn[1]);
}

public plugin_init()
{
	if (ns_is_combat())
	{
		register_plugin("Sticky Chambers (OFF)", VERSION, "Darkns");
	}
	else
	{
		register_plugin("Sticky Chambers (ON)", VERSION, "Darkns");
		
		g_pcvarMaxDist = register_cvar("sc_maxdist", "120.0");
		g_pcvarUnchained = register_cvar("sc_unchained", "0");
		
		if (get_pcvar_num(g_pcvarUnchained))
		{
			g_pcvarCost_OC = register_cvar("sc_cost_oc", "10");
			g_pcvarCost_DC = register_cvar("sc_cost_dc", "12");
			g_pcvarCost_SC = register_cvar("sc_cost_sc", "15");
			g_pcvarCost_MC = register_cvar("sc_cost_mc", "10");
		}
		else
		{
			g_pcvarCost_OC = register_cvar("sc_cost_oc", "10");
			g_pcvarCost_DC = register_cvar("sc_cost_dc", "10");
			g_pcvarCost_SC = register_cvar("sc_cost_sc", "10");
			g_pcvarCost_MC = register_cvar("sc_cost_mc", "10");
		}
		
		g_iMsgID_PlayHUDNot = get_user_msgid("PlayHUDNot");
		g_iMsgID_SetTech = get_user_msgid("SetTech");
		
		register_forward(FM_CmdStart, "fmhook_CmdStart");
		register_forward(FM_Think, "fmhook_Think");
		register_forward(FM_Touch, "fmhook_Touch");
		
		register_message(g_iMsgID_SetTech, "msghook_SetTech");
		
		g_iMaxPlayers = global_get(glb_maxClients);	//because FakeMeta is just that cool
	}
}

public fmhook_Touch(eEnt, eOther)
{
	if (pev_valid(eEnt) && IsWorld(eOther) && (AVH_USER3_DEFENSE_CHAMBER <= pev(eEnt, pev_iuser3) <= AVH_USER3_SENSORY_CHAMBER) )
	{
		//otherwise this would not allow the chamber to cloak
		return FMRES_SUPERCEDE;
	}
	
	return FMRES_IGNORED;
}

//(const edict_t *player, const struct usercmd_s *cmd, unsigned int random_seed);
public fmhook_CmdStart(ePlayer, ucHandle)	//, iRandomSeed)
{
	if (pev_valid(ePlayer) && !is_user_bot(ePlayer) && (get_teamtype(ePlayer) == ALIEN) )	//check for gorge later
	{
		static iImpulse;
		iImpulse = get_uc(ucHandle, UserCmd:UC_Impulse);
		
		if (IMPULSE_OC <= iImpulse <= IMPULSE_MC)
		{
			CreateChamber(ePlayer, iImpulse);
			set_uc(ucHandle, UserCmd:UC_Impulse, 0);
		}
	}
	
	return FMRES_IGNORED;
}

public fmhook_Think(eEnt)
{
	if (pev_valid(eEnt) && (AVH_USER3_DEFENSE_CHAMBER <= pev(eEnt, pev_iuser3) <= AVH_USER3_SENSORY_CHAMBER))	//it's a chamber
	{
		if (!ValidPlacement(eEnt))
		{
			remove_entity_soft(eEnt);
			return FMRES_SUPERCEDE;
		}
	}
	
	return FMRES_IGNORED;
}

public msghook_SetTech(iMsgID, iDestType, eTarget)
{
	static iImpulse;
	iImpulse = get_msg_arg_int(SETTECH_IMPULSE);
	
	if (IMPULSE_OC <= iImpulse <= IMPULSE_MC)
	{
		static iCost;
		switch (iImpulse)
		{
			case IMPULSE_OC:
				iCost = get_pcvar_num(g_pcvarCost_OC);
			case IMPULSE_DC:
				iCost = get_pcvar_num(g_pcvarCost_DC);
			case IMPULSE_SC:
				iCost = get_pcvar_num(g_pcvarCost_SC);
			case IMPULSE_MC:
				iCost = get_pcvar_num(g_pcvarCost_MC);
		}
		
		set_msg_arg_int(SETTECH_COST, ARG_SHORT, iCost);
		
		return BLOCK_SET;
	}
	
	return BLOCK_NOT;
}

//-------------------------------------------------------------------------------------------------
//stock/util functions

CreateChamber(&ePlayer, &iImpulse)	//referenced, 'cause we don't need it creating new vars
{
	static iTeam;
	iTeam = get_team(ePlayer);
	
	static eTraitHive;
	if (iImpulse != IMPULSE_OC)
	{
		eTraitHive = GetTraitHive(iTeam, iImpulse);	//we only need this for non-OCs
		if (eTraitHive == HT_INVALID)
			return;
	}
	
	static Float:oPlayer[3], Float:aView[3], Float:vAim[3];
	GetAimOrigin(ePlayer, oPlayer);
	GetAimAngle(ePlayer, aView);
	angle_to_vector(aView, vAim);
	
	static Float:fMaxDist;
	fMaxDist = get_pcvar_float(g_pcvarMaxDist);
	
	static Float:oFar[3];
	VectorMul(vAim,fMaxDist,oFar);
	VectorAddSelf(oFar,oPlayer);
	
	static trHit;
	engfunc(EngFunc_TraceLine, oPlayer, oFar, 0, ePlayer, trHit);
	static eHit;
	static Float:oChamber[3], Float:vNormal[3];
	eHit = get_tr2(trHit, TraceResult:TR_pHit);
	get_tr2(trHit, TraceResult:TR_vecEndPos, oChamber);
	get_tr2(trHit, TraceResult:TR_vecPlaneNormal, vNormal);
	
	if (VectorEqual(oChamber, oFar) || !IsWorld(eHit))
		return;
	
	static Float:fChamberCost;
	switch (iImpulse)
	{
		case IMPULSE_OC:
			fChamberCost = get_pcvar_float(g_pcvarCost_OC);
		case IMPULSE_DC:
			fChamberCost = get_pcvar_float(g_pcvarCost_DC);
		case IMPULSE_SC:
			fChamberCost = get_pcvar_float(g_pcvarCost_SC);
		case IMPULSE_MC:
			fChamberCost = get_pcvar_float(g_pcvarCost_MC);
	}
	
	static Float:fRes;
	fRes = ns_get_res(ePlayer) - fChamberCost;
	if ( (fRes < 0.0) || (ns_get_class(ePlayer) != CLASS_GORGE) )	//not a gorgeh!
	{
		message_begin(MSG_ONE, g_iMsgID_PlayHUDNot, {0,0,0}, ePlayer);
		write_byte(HUD_SOUND);
		write_byte(HUD_SOUND_ALIEN_MORE);
		write_coord(0);
		write_coord(0);
		message_end();
		return;
	}	//ns_set_res( ) is down further
	
	static eChamber;
	switch (iImpulse)
	{
		case IMPULSE_OC:
			eChamber = create_entity("offensechamber");
		case IMPULSE_DC:
			eChamber = create_entity("defensechamber");
		case IMPULSE_SC:
			eChamber = create_entity("sensorychamber");
		case IMPULSE_MC:
			eChamber = create_entity("movementchamber");
	}
	
	if (!pev_valid(eChamber))
	{
		log_amx("[%s] failed to create chamber for impulse %i", LOG_TAG, iImpulse);
		return;
	}
	
	dllfunc(DLLFunc_Spawn, eChamber);
	
	static Float:aChamber[3];
	vector_to_angle(vNormal, aChamber);
	
	aChamber[PITCH] -= 90.0;
	set_pev(eChamber, pev_angles, aChamber);
	
	MakeBBox(eChamber, vNormal, g_kvMin, g_kvMax);
	
	
	//this moves the chamber's origin 1u along the normal so it doesn't get stuck...
	VectorAddSelf(oChamber,vNormal);
	
	set_pev(eChamber, pev_origin, oChamber);
	set_pev(eChamber, pev_movetype, CHAMBER_MOVETYPE);
	set_pev(eChamber, pev_solid, CHAMBER_SOLID);
	ns_set_struct_owner(eChamber, ePlayer);
	set_team(eChamber, iTeam);
	
	if (iImpulse == IMPULSE_OC)
	{
		static Float:vOffset[3];
		VectorMul(vNormal,OC_FIRE_HEIGHT,vOffset);
		set_pev(eChamber, pev_view_ofs, vOffset);	//Where the spikes should originate. (I wish I knew about this a while ago)
	}
	else
	{
		if (eTraitHive != HT_SET)	//it's not HT_SET, and it wasn't HT_INVALID, so eTraitHive is the hive we want
			ns_set_hive_trait(eTraitHive, iImpulse);
	}
	
	SendHUDEvent(iImpulse, iTeam, oChamber);
	emit_sound(ePlayer, CHAN_AUTO, g_krSound_ChamberSpawn[random_num(0,1)], VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
	
	ns_set_res(ePlayer, fRes);
	
	return;
}

SendHUDEvent(&iImpulse, &iTeam, Float:oChamber[3])
{
	static i;
	for (i = 1; i <= g_iMaxPlayers; i++)
	{
		if (pev_valid(i) && (get_team(i) == iTeam))
		{
			message_begin(MSG_ONE, g_iMsgID_PlayHUDNot, {0,0,0}, i);
			write_byte(HUD_BUILT);
			write_byte(iImpulse);
			fm_write_coord(oChamber[0]);
			fm_write_coord(oChamber[1]);
			message_end();
		}
	}
}

GetTraitHive(&iTeam, &iTrait)
{
	if (get_pcvar_num(g_pcvarUnchained))
		return HT_SET;
	
	static iBuiltHives;
	iBuiltHives = ns_get_build("team_hive",1,0);
	static eFreeHive = 0;
	static iHiveNum;
	for (iHiveNum = 1; iHiveNum <= iBuiltHives; iHiveNum++)
	{
		static eHive;
		eHive = ns_get_build("team_hive", 1, iHiveNum);
		if (get_team(eHive) == iTeam)
		{
			static iHiveTrait;
			iHiveTrait = ns_get_hive_trait(eHive);
			if (iHiveTrait == iTrait)
				return HT_SET;
			else if (!iHiveTrait)
				eFreeHive = eHive;
		}
	}
	
	if (eFreeHive)
		return eFreeHive;
	
	return HT_INVALID;
}

ValidPlacement(&eChamber)
{
	static Float:aChamber[3], Float:vChamber[3];
	pev(eChamber, pev_angles, aChamber);
	aChamber[PITCH] -= 90.0;
	aChamber[YAW] -= 180.0;
	angle_to_vector(aChamber, vChamber);
	
	VectorMulSelf(vChamber,8.0);
	static Float:oChamber[3];
	pev(eChamber, pev_origin, oChamber);
	
	static Float:oTraceTo[3];
	VectorSub(oChamber,vChamber,oTraceTo);
	
	static Float:oHit[3];
	static eHit;
	static trHit;
	engfunc(EngFunc_TraceLine, oChamber, oTraceTo, 0, eChamber, trHit);
	eHit = get_tr2(trHit, TraceResult:TR_pHit);
	get_tr2(trHit, TraceResult:TR_vecEndPos, oHit);
	
	if (VectorEqual(oHit, oTraceTo) || !IsWorld(eHit))
		return 0;
	
	return 1;
}

get_teamtype(&eEnt)
{
	static iTeam;
	iTeam = get_team(eEnt);
	switch (iTeam)
	{
		case 1:
			return MARINE;
		case 2:
			return ALIEN;
		case 3:
			return MARINE;
		case 4:
			return ALIEN;
	}
	return OTHER;
}

MakeBBox(&eEnt, Float:vNorm[3], Float:vBBMin[3], Float:vBBMax[3])
{
	static Float:rvBasePoints[8][3];
	static i;
	for (i = 0; i < 8; i++)
	{
		rvBasePoints[i][0] = ((i>>2) % 2)?vBBMin[0]:vBBMax[0];
		rvBasePoints[i][1] = ((i>>1) % 2)?vBBMin[1]:vBBMax[1];
		rvBasePoints[i][2] = (i % 2)?vBBMin[2]:vBBMax[2];
	}
	
	static Float:aEnt[3];
	vector_to_angle(vNorm, aEnt);
	aEnt[PITCH] -= 90.0;
	aEnt[YAW] -= 180.0;
	
	static Float:fPitchSin;
	fPitchSin = sin(aEnt[PITCH]);
	static Float:fPitchCos;
	fPitchCos = cos(aEnt[PITCH]);
	static Float:fYawSin;
	fYawSin = sin(aEnt[YAW]);
	static Float:fYawCos;
	fYawCos = cos(aEnt[YAW]);
	
	//pitch
	static Float:rPointsPostPitch[8][3];
	for (i = 0; i < 8; i++)
	{
		rPointsPostPitch[i][0] = (rvBasePoints[i][0] *  fPitchCos) + (rvBasePoints[i][2] * fPitchSin);
		rPointsPostPitch[i][1] =  rvBasePoints[i][1];
		rPointsPostPitch[i][2] = (rvBasePoints[i][0] * -fPitchSin) + (rvBasePoints[i][2] * fPitchCos);
	}
	
	//yaw
	static Float:rPointsPostYaw[8][3];
	for (i = 0; i < 8; i++)
	{
		rPointsPostYaw[i][0] = (rPointsPostPitch[i][0] *  fYawCos) + (rPointsPostPitch[i][1] * fYawSin);
		rPointsPostYaw[i][1] = (rPointsPostPitch[i][0] * -fYawSin) + (rPointsPostPitch[i][1] * fYawCos);
		rPointsPostYaw[i][2] =  rPointsPostPitch[i][2];
	}
	
	static Float:vMin[3];
	vMin = Float:{ 8192.0,  8192.0,  8192.0};
	static Float:vMax[3];
	vMax = Float:{-8192.0, -8192.0, -8192.0};
	
	for (i = 0; i < 8; i++)
	{
		static j;
		for (j = 0; j < 3; j++)
		{
			if (vMax[j] < rPointsPostYaw[i][j])
				vMax[j] = rPointsPostYaw[i][j];
			else if (vMin[j] > rPointsPostYaw[i][j])
				vMin[j] = rPointsPostYaw[i][j];
		}
	}
	
	set_pev(eEnt, pev_mins, vMin);
	set_pev(eEnt, pev_maxs, vMax);
	
	static Float:vSize[3];
	VectorSub(vMax,vMin,vSize);
	set_pev(eEnt, pev_size, vSize);
}

GetAimOrigin(&ePlayer, Float:oAim[3])
{
	pev(ePlayer, pev_origin, oAim);
	
	static Float:vOffset[3];
	pev(ePlayer, pev_view_ofs, vOffset);
	VectorAddSelf(oAim, vOffset);
}
