-- int8_t  1 バイトの符号付き整数 
-- int16_t  2 バイトの符号付き整数 
-- int32_t  4 バイトの符号付き整数 
-- int64_t  8 バイトの符号付き整数 
-- intptr_t  ポインタと同じサイズの符号付き整数 
-- uint8_t  1 バイトの符号なし整数 
-- uint16_t  2 バイトの符号なし整数 
-- uint32_t  4 バイトの符号なし整数 
-- uint64_t  8 バイトの符号なし整数 
-- uintptr_t  ポインタと同じサイズの符号なし整数 

return {
	VERSIONSIZE = 16,
	CODESIZE = 8,
	
	DEFAULT_VOICE = "000-sineNormal.ptvoice",
	
	MAX_TUNEUNITSTRUCT = 50,
	MAX_TUNEGROUPNUM   = 7,
	MAX_TUNEUNITNAME   = 16,
	MAX_TUNEWOICENAME  = 16,
	
	EVENTKIND = {
		NULL       =  0,
		
		ON         =  1,
		KEY        =  2,
		PAN_VOLUME =  3,
		VELOCITY   =  4,
		VOLUME     =  5,
		PORTAMENT  =  6,
		BEATCLOCK  =  7,
		BEATTEMPO  =  8,
		BEATNUM    =  9,
		REPEAT     = 10,
		LAST       = 11,
		VOICENO    = 12,
		GROUPNO    = 13,
		TUNING     = 14,
		PAN_TIME   = 15,
	},
	
	EVENTDEFAULT = {
		VOLUME     =    104,
		VELOCITY   =    104,
		PAN_VOLUME =     64,
		PAN_TIME   =     64,
		PORTAMENT  =      0,
		VOICENO    =      0,
		GROUPNO    =      0,
		KEY        = 0x6000,
		BASICKEY   = 0x4500,
		TUNING     =    1.0,
		
		BEATNUM    =      4,
		BEATTEMPO  =    120,
		BEATCLOCK  =    480,
	},
	
	PTV_VOICEFLAG = {
		WAVELOOP   = 0x00000001,
		SMOOTH     = 0x00000002,
		BEATFIT    = 0x00000004,
		UNCOVERED  = 0xfffffff8,
	},
	
	PTV_DATAFLAG = {
		WAVE       = 0x00000001,
		ENVELOPE   = 0x00000002,
		UNCOVERED  = 0xfffffffc,
	},
	
	DELAYUNIT = {
		Beat   = 0,
		Meas   = 1,
		Second = 2,
	},
	
	WOICETYPE = {
		None = 0,
		PCM  = 1,
		PTV  = 2,
		PTN  = 3,
		OGGV = 4,
	},
	
	VOICETYPE = {
		Coodinate = 0,
		Overtone  = 1,
		Noise     = 2,
		Sampling  = 3,
		OggVorbis = 4,
	},
	
	CODE_TUNE = {
		x2x = "PTTUNE--20050608",
		x3x = "PTTUNE--20060115",
		x4x = "PTTUNE--20060930",
		v5  = "PTTUNE--20071119",
	},
	
	CODE_PROJ = {
		x1x = "PTCOLLAGE-050227",
		x2x = "PTCOLLAGE-050608",
		x3x = "PTCOLLAGE-060115",
		x4x = "PTCOLLAGE-060930",
		v5  = "PTCOLLAGE-071119",
	},
	
	CODE = {
		x1x_PROJ     = "PROJECT=",
		x1x_EVEN     = "EVENT===",
		x1x_UNIT     = "UNIT====",
		x1x_END      = "END=====",
		x1x_PCM      = "matePCM=",
		
		x3x_pxtnUNIT = "pxtnUNIT",
		x4x_evenMAST = "evenMAST",
		x4x_evenUNIT = "evenUNIT",
		
		antiOPER     = "antiOPER", -- anti operation(edit)
		
		num_UNIT     = "num UNIT",
		MasterV5     = "MasterV5",
		Event_V5     = "Event V5",
		matePCM      = "matePCM ",
		matePTV      = "matePTV ",
		matePTN      = "matePTN ",
		mateOGGV     = "mateOGGV",
		effeDELA     = "effeDELA",
		effeOVER     = "effeOVER",
		textNAME     = "textNAME",
		textCOMM     = "textCOMM",
		assiUNIT     = "assiUNIT",
		assiWOIC     = "assiWOIC",
		pxtoneND     = "pxtoneND",
	},
	
	FMTVER = {
		UNKNOWN = 1,
		x1x = 2,
		x2x = 3,
		x3x = 4,
		x4x = 5,
		v5  = 6
	},
	
	ERR = {
		OK                   = 1,
		ERR_VOID             = 2,
		ERR_INIT             = 3,
		ERR_FATAL            = 4,

		ERR_anti_opreation   = 5,

		ERR_deny_beatclock   = 6,

		ERR_desc_w           = 7,
		ERR_desc_r           = 8,
		ERR_desc_broken      = 9,

		ERR_fmt_new          = 10,
		ERR_fmt_unknown      = 11,

		ERR_inv_code         = 12,
		ERR_inv_data         = 13,

		ERR_memory           = 14,

		ERR_moo_init         = 15,

		ERR_ogg              = 16,
		ERR_ogg_no_supported = 17,

		ERR_param            = 18,

		ERR_pcm_convert      = 19,
		ERR_pcm_unknown      = 20,

		ERR_ptn_build        = 21,
		ERR_ptn_init         = 22,

		ERR_ptv_no_supported = 23,

		ERR_too_much_event   = 24,

		ERR_woice_full       = 25,

		ERR_x1x_ignore       = 26,

		ERR_x3x_add_tuning   = 27,
		ERR_x3x_key          = 28,
	},
	
	SEEK = {
		SET = 1,
		CUR = 2,
		END = 3,	-- end だと予約語で死ぬので大文字で＞＜
	},
	
	WAVETYPE = {
		None    = 0,
		Sine    = 1,
		Saw     = 2,
		Rect    = 3,
		Random  = 4,
		Saw2    = 5,
		Rect2   = 6,

		Tri     = 7,
		Random2 = 8,
		Rect3   = 9,
		Rect4   = 10,
		Rect8   = 11,
		Rect16  = 12,
		Saw3    = 13,
		Saw4    = 14,
		Saw6    = 15,
		Saw8    = 16,
	}
}