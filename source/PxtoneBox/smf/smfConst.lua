
return {
	
	EVENTTYPE = {
		NULL  = 0,
		MIDI  = 1,
		SYSEX = 2,
		META  = 3
	},
	
	MIDIKIND = {
		NULL = 0x00,
		OFF  = 0x80,
		ON   = 0x90,
		CC   = 0xb0,
		PC   = 0xc0,
	},
	
	ERR = {
		OK                   = 1,
		ERR_VOID             = 2,
		ERR_INIT             = 3,
		ERR_FATAL            = 4,
		
		ERR_desc_w           = 7,
		ERR_desc_r           = 8,
		ERR_desc_broken      = 9,
		
		ERR_fmt_new          = 10,
		ERR_fmt_unknown      = 11,
	},
	
	SEEK = {
		SET = 1,
		CUR = 2,
		END = 3,	-- end だと予約語で死ぬので大文字で＞＜
	},
}

