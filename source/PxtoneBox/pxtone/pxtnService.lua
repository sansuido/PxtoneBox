
local	CONST = import(".pxtnConst")
local	PxtnDescriptor = import(".pxtnDescriptor")
local	PxtnMaster = import(".pxtnMaster")
local	PxtnEvelist = import(".pxtnEvelist")
local	PxtnDelay = import(".pxtnDelay")
local	PxtnUnit = import(".pxtnUnit")
local	PxtnWoice = import(".pxtnWoice")
local	PxtnOverDrive = import(".pxtnOverDrive")

local	PxtnService = {}
PxtnService = class("PxtnService")


local	sound_mate = {
	[  1] = {"AcoPiano"},		-- アコースティックピアノ
	[  2] = {"BrightPiano"},	-- ブライトピアノ
	[  3] = {"EleGranPiano"},	-- エレクトリックグランドピアノ
	[  4] = {"H-tonkPiano"},	-- ホンキートンクピアノ
	[  5] = {"ElePiano"},		-- エレクトリックピアノ
	[  6] = {"ElePiano2"},		-- エレクトリックピアノ2
	[  7] = {"Harpsichord"},	-- ハープシコード
	[  8] = {"Clavi"},			-- クラビネット
	[  9] = {"Celesta"},		-- チェレスタ
	[ 10] = {"Glockenspiel"},	-- グロッケンシュピール
	[ 11] = {"MusicalBox"},		-- オルゴール
	[ 12] = {"Vibraphone"},		-- ヴィブラフォン
	[ 13] = {"Marimba"},		-- マリンバ
	[ 14] = {"Xylophone"},		-- シロフォン
	[ 15] = {"TubularBell"},	-- チューブラーベル
	[ 16] = {"Dulcimer"},		-- ダルシマー
	[ 17] = {"DrawbarOrg"},		-- ドローバーオルガン
	[ 18] = {"PercuseOrg"},		-- パーカッシブオルガン
	[ 19] = {"RockOrgan"},		-- ロックオルガン
	[ 20] = {"ChurchOrg"},		-- チャーチオルガン
	[ 21] = {"ReedOrg"},		-- リードオルガン
	[ 22] = {"Accord"},			-- アコーディオン
	[ 23] = {"Harmonica"},		-- ハーモニカ
	[ 24] = {"TangoAccord"},	-- タンゴアコーディオン
	[ 25] = {"AcoGtr(ny)"},		-- アコースティックギター（ナイロン弦）
	[ 26] = {"AcoGtr(st)"},		-- アコースティックギター（スチール弦）
	[ 27] = {"EleGtr(jazz)"},	-- ジャズギター
	[ 28] = {"EleGtr(cl)"},		-- クリーンギター
	[ 29] = {"EleGtr(mu)"},		-- ミュートギター
	[ 30] = {"OverGtr"},		-- オーバードライブギター
	[ 31] = {"DistGtr"},		-- ディストーションギター
	[ 32] = {"GtrHarmonics"},	-- ギターハーモニクス
	[ 33] = {"AcoBass"},		-- アコースティックベース
	[ 34] = {"EleBass(fi)"},	-- フィンガー・ベース
	[ 35] = {"EleBass(pi)"},	-- ピック・ベース
	[ 36] = {"FretlessBass"},	-- フレットレスベース
	[ 37] = {"SlapBass1"},		-- スラップベース1
	[ 38] = {"SlapBass2"},		-- スラップベース2
	[ 39] = {"SynthBass1"},		-- シンセベース1
	[ 40] = {"SynthBass2"},		-- シンセベース2
	[ 41] = {"Violin"},			-- ヴァイオリン
	[ 42] = {"Viola"},			-- ヴィオラ
	[ 43] = {"Cello"},			-- チェロ
	[ 44] = {"DoubleBass"},		-- コントラバス
	[ 45] = {"TremoloStr"},		-- トレモロ
	[ 46] = {"PizzicatoStr"},	-- ピッチカート
	[ 47] = {"OrcheHarp"},		-- ハープ
	[ 48] = {"Timpani"},		-- ティンパニ
	[ 49] = {"StrEnsemble1"},	-- ストリングアンサンブル1
	[ 50] = {"StrEnsemble2"},	-- ストリングアンサンブル2
	[ 51] = {"SynthStr1"},		-- シンセストリングス1
	[ 52] = {"SynthStr2"},		-- シンセストリングス2
	[ 53] = {"VoiceAahs"},		-- 声「あー」
	[ 54] = {"VoiceOohs"},		-- 声「うー」
	[ 55] = {"SynthVoice"},		-- シンセヴォイス
	[ 56] = {"OrchestraHit"},	-- オーケストラヒット
	[ 57] = {"Trumpet"},		-- トランペット
	[ 58] = {"Trombone"},		-- トロンボーン
	[ 59] = {"Tuba"},			-- チューバ
	[ 60] = {"MutedTrumpet"},	-- ミュートトランペット
	[ 61] = {"FrenchHorn"},		-- フレンチ・ホルン
	[ 62] = {"BrassSection"},	-- ブラスセクション
	[ 63] = {"SynthBrass1"},	-- シンセブラス1
	[ 64] = {"SynthBrass2"},	-- シンセブラス2
	[ 65] = {"SopranoSax"},		-- ソプラノサックス
	[ 66] = {"AltoSax"},		-- アルトサックス
	[ 67] = {"TenorSax"},		-- テナーサックス
	[ 68] = {"BaritoneSax"},	-- バリトンサックス
	[ 69] = {"Oboe"},			-- オーボエ
	[ 70] = {"EnglishHorn"},	-- イングリッシュホルン
	[ 71] = {"Bassoon"},		-- ファゴット
	[ 72] = {"Clarinet"},		-- クラリネット
	[ 73] = {"Piccolo"},		-- ピッコロ
	[ 74] = {"Flute"},			-- フルート
	[ 75] = {"Recorder"},		-- リコーダー
	[ 76] = {"PanFlute"},		-- パンフルート
	[ 77] = {"BlownBottle"},	-- ブロウンボトル（吹きガラス瓶）
	[ 78] = {"Shakuhachi"},		-- 尺八
	[ 79] = {"Whistle"},		-- 口笛
	[ 80] = {"Ocarina"},		-- オカリナ
	[ 81] = {"Lead1(squar)"},	-- 矩形波
	[ 82] = {"Lead2(saw)"},		-- ノコギリ波
	[ 83] = {"Lead3(calli)"},	-- カリオペ
	[ 84] = {"Lead4(chiff)"},	-- チフ
	[ 85] = {"Lead5(chara)"},	-- チャランゴ
	[ 86] = {"Lead6(voice)"},	-- 声
	[ 87] = {"Lead7(fifth)"},	-- フィフスズ
	[ 88] = {"Lead8(bass)"},	-- バス+リード
	[ 89] = {"Pad1(fanta)"},	-- ファンタジア
	[ 90] = {"Pad2(warm)"},		-- ウォーム
	[ 91] = {"Pad3(poly)"},		-- ポリシンセ
	[ 92] = {"Pad4(choir)"},	-- クワイア
	[ 93] = {"Pad5(bowed)"},	-- ボウ
	[ 94] = {"Pad6(metal)"},	-- メタリック
	[ 95] = {"Pad7(halo)"},		-- ハロー
	[ 96] = {"Pad8(sweep)"},	-- スウィープ
	[ 97] = {"FX1(rain)"},		-- 雨
	[ 98] = {"FX2(s-track)"},	-- サウンドトラック
	[ 99] = {"FX3(crystal)"},	-- クリスタル
	[100] = {"FX4(atmos)"},		-- アトモスフィア
	[101] = {"FX5(bright)"},	-- ブライトネス
	[102] = {"FX6(goblins)"},	-- ゴブリン
	[103] = {"FX7(echoes)"},	-- エコー
	[104] = {"FX8(sci-fi)"},	-- サイファイ
	[105] = {"Sitar"},			-- シタール
	[106] = {"Banjo"},			-- バンジョー
	[107] = {"Shamisen"},		-- 三味線
	[108] = {"Koto"},			-- 琴
	[109] = {"Kalimba"},		-- カリンバ
	[110] = {"Bagpipe"},		-- バグパイプ
	[111] = {"Fiddle"},			-- フィドル
	[112] = {"Shanai"},			-- シャハナーイ
	[113] = {"TinkleBell"},		-- ティンクルベル
	[114] = {"Agogo"},			-- アゴゴ
	[115] = {"SteelDrums"},		-- スチールドラム
	[116] = {"Woodblock"},		-- ウッドブロック
	[117] = {"TaikoDrum"},		-- 太鼓
	[118] = {"MelodicTom"},		-- メロディックタム
	[119] = {"SynthDrum"},		-- シンセドラム
	[120] = {"ReCymbal"},		-- 逆シンバル
	[121] = {"GtrFretNoise"},	-- ギターフレットノイズ
	[122] = {"BreathNoise"},	-- ブレスノイズ
	[123] = {"Seashore"},		-- 海岸
	[124] = {"BirdTweet"},		-- 鳥の囀り
	[125] = {"Telephone"},		-- 電話のベル
	[126] = {"Helicopter"},		-- ヘリコプター
	[127] = {"Applause"},		-- 拍手
	[128] = {"Gunshot"},		-- 銃声
}

local	percussion_mate = {
	
	[ 22] = {"MC-500Beep1"},
	[ 23] = {"MC-500Beep2"},
	[ 24] = {"ConcertSD"},
	[ 25] = {"SnareRoll"},
	[ 26] = {"FingerSnap2"},
	[ 27] = {"HighQ"},
	[ 28] = {"Slap"},
	[ 29] = {"ScratchPush"},
	[ 30] = {"ScratchPull"},
	[ 31] = {"Sticks"},
	[ 32] = {"SquareClick"},
	[ 33] = {"MetronClick"},
	[ 34] = {"MetronBell"},
	[ 35] = {"BassDrum2"},		-- バスドラム2
	[ 36] = {"BassDrum1"},		-- バスドラム1
	[ 37] = {"SideStick"},		-- サイドスティック
	[ 38] = {"SnareDrum1"},		-- スネアドラム1
	[ 39] = {"HandClap"},		-- 手拍子
	[ 40] = {"SnareDrum2"},		-- スネアドラム2
	[ 41] = {"LowTom2"},		-- ロートム2
	[ 42] = {"ClosedHihat"},	-- クローズハイハット
	[ 43] = {"LowTom1"},		-- ロートム1
	[ 44] = {"PedalHihat"},		-- ペダルハイハット
	[ 45] = {"MidTom2"},		-- ミドルトム2
	[ 46] = {"OpenHihat"},		-- オープンハイハット
	[ 47] = {"MidTom1"},		-- ミドルトム1
	[ 48] = {"HighTom2"},		-- ハイトム2
	[ 49] = {"CrashCymbal1"},	-- クラッシュシンバル1
	[ 50] = {"HighTom1"},		-- ハイトム1
	[ 51] = {"RideCymbal1"},	-- ライドシンバル1
	[ 52] = {"ChinaCymbal"},	-- チャイニーズシンバル
	[ 53] = {"RideBell"},		-- ライドベル
	[ 54] = {"Tambourine"},		-- タンバリン
	[ 55] = {"SplashCymbal"},	-- スプラッシュシンバル
	[ 56] = {"Cowbell"},		-- カウベル
	[ 57] = {"CrashCymbal2"},	-- クラッシュシンバル2
	[ 58] = {"VibraSlap"},		-- ヴィブラスラップ
	[ 59] = {"RideCymbal2"},	-- ライドシンバル2
	[ 60] = {"HighBongo"},		-- ハイボンゴ
	[ 61] = {"LowBongo"},		-- ローボンゴ
	[ 62] = {"MuteHiConga"},	-- ミュートハイコンガ
	[ 63] = {"OpenHiConga"},	-- オープンハイコンガ
	[ 64] = {"LowConga"},		-- ローコンガ
	[ 65] = {"HighTimbale"},	-- ハイティンバル
	[ 66] = {"LowTimbale"},		-- ローティンバル
	[ 67] = {"HighAgogo"},		-- ハイアゴゴ
	[ 68] = {"LowAgogo"},		-- ローアゴゴ
	[ 69] = {"Cabasa"},			-- カバサ
	[ 70] = {"Maracas"},		-- マラカス
	[ 71] = {"ShortWhistle"},	-- ショートホイッスル
	[ 72] = {"LongWhistle"},	-- ロングホイッスル
	[ 73] = {"ShortGuiro"},		-- ショートギロ
	[ 74] = {"LongGuiro"},		-- ロングギロ
	[ 75] = {"Claves"},			-- クラベス
	[ 76] = {"HiWoodBlock"},	-- ハイウッドブロック
	[ 77] = {"LowWoodBlock"},	-- ローウッドブロック
	[ 78] = {"MuteCuica"},		-- ミュートクイーカ
	[ 79] = {"OpenCuica"},		-- オープンクイーカ
	[ 80] = {"MuteTriangle"},	-- ミュートトライアングル
	[ 81] = {"OpenTriangle"},	-- オープントライアングル
	[ 82] = {"Shaker"},
	[ 83] = {"JingleBell"},
	[ 84] = {"BellTree"},
	[ 85] = {"Castanets"},
	[ 86] = {"MuteSurdo"},
	[ 87] = {"OpenSurdo"},
	[ 88] = {"Applause2"},
}




function PxtnService:ctor(...)
	
	self.m_master = PxtnMaster:create()
	self.m_evels = PxtnEvelist:create()
	
	self.m_delays = {}
	self.m_ovdrvs = {}
	self.m_woices = {}
	self.m_units = {}
	
	self.m_ptn_bldr = nil
	self.m_sampled_proc = nil
	self.m_sampled_user = nil
	
	self.m_name = ""
	self.m_comment = ""
	self.m_unit_max = CONST.MAX_TUNEUNITSTRUCT
	self.m_group_num = CONST.MAX_TUNEGROUPNUM
end


function PxtnService:io_Read_Delay(desc)
	local	err = CONST.ERR.ERR_VOID
	local	delay = PxtnDelay:create()
	err = delay:read(desc)
	if err == CONST.ERR.OK then
		table.insert(self.m_delays, delay)
	end
	return err
end


function PxtnService:io_Read_OverDrive(desc)
	local	err = CONST.ERR.ERR_VOID
	local	overDrive = PxtnOverDrive:create()
	err = overDrive:read(desc)
	if err == CONST.ERR.OK then
		table.insert(self.m_ovdrvs, overDrive)
	end
	return err
end


function PxtnService:io_Read_OldUnit(desc, ver)
	local	err = CONST.ERR.ERR_VOID
	local	unit = PxtnUnit:create()
	local	group = 0
	
	if ver == 3 then
		err, group = unit:read_v3x(desc)
		if err ~= CONST.ERR.OK then return err end
	else
		return CONST.ERR.ERR_fmt_unlnown
	end
	
	if group >= self.m_group_num then group = self.m_group_num - 1 end
	table.insert(self.m_units, unit)
	
	return err
end


function PxtnService:io_assiWOIC_w(desc, index)
	local	woice = self.m_woices[index]
	local	res = true
	local	size = 2 + 2 + #woice:get_write_name()
	
	if res then res = desc:w_asfile(size, 4, "integer") end
	if res then res = desc:w_asfile(index - 1, 2, "integer") end
	if res then res = desc:w_asfile(0, 2, "integer") end
	if res then res = desc:w_asfile(woice:get_write_name()) end
	
	return res
end


function PxtnService:io_assiWOIC_r(desc)
	local	size, woice_index, rrr = desc:r({4, 2, 2}, "integer")
	if size == nil then return CONST.ERR.ERR_desc_r end
	local	name = desc:r(CONST.MAX_TUNEUNITNAME)
	if name == nil then return CONST.ERR.ERR_desc_r end
	
	self.m_woices[woice_index + 1]:set_name(name)
	
	return CONST.ERR.OK
end


function PxtnService:io_assiUNIT_w(desc, index)
	local	unit = self.m_units[index]
	local	res = true
	local	size = 2 + 2 + #unit:get_write_name()
	
	if res then res = desc:w_asfile(size, 4, "integer") end
	if res then res = desc:w_asfile(index - 1, 2, "integer") end
	if res then res = desc:w_asfile(0, 2, "integer") end
	if res then res = desc:w_asfile(unit:get_write_name()) end
	
	return res
end


function PxtnService:io_assiUNIT_r(desc)
	local	size, unit_index, rrr = desc:r({4, 2, 2}, "integer")
	if size == nil then return CONST.ERR.ERR_desc_r end
	local	name = desc:r(CONST.MAX_TUNEUNITNAME)
	if name == nil then return CONST.ERR.ERR_desc_r end
	
	self.m_units[unit_index + 1]:set_name(name)
	
	return CONST.ERR.OK
end


function PxtnService:io_UNIT_num_w(desc)
	local	res = true
	
	local	size = 2 + 2
	
	if res then res = desc:w_asfile(size, 4, "integer") end
	if res then res = desc:w_asfile(#self.m_units, 2, "integer") end
	if res then res = desc:w_asfile(0, 2, "integer") end
	
	return res
end


function PxtnService:io_UNIT_num_r(desc)
	local	size, num, rrr = desc:r({4, 2, 2}, "integer")
	if size == nil then return CONST.ERR.ERR_desc_r end
	if rrr ~= 0 then return CONST.ERR.ERR_fmt_unknown end
	
	return CONST.ERR.OK, num
end


function PxtnService:io_Read_Woice(desc, code)
	
	local	err = CONST.ERR.ERR_VOID
	local	woice = PxtnWoice:create()
	
	if     code == CONST.CODE.matePCM  then
		err = woice:io_matePCM_r(desc)
		if err ~= CONST.ERR.OK then return err end
	
	elseif code == CONST.CODE.matePTV  then
		err = woice:io_matePTV_r(desc)
		if err ~= CONST.ERR.OK then return err end
		
	elseif code == CONST.CODE.matePTN  then
		err = woice:io_matePTN_r(desc)
		if err ~= CONST.ERR.OK then return err end
		
	elseif code == CONST.CODE.mateOGGV then
		err = woice:io_mateOGGV_r(desc)
		if err ~= CONST.ERR.OK then return err end
		
	else
		return CONST.ERR.ERR_fmt_unknown
	end
	
	table.insert(self.m_woices, woice)
	
	return CONST.ERR.OK
end


function PxtnService:readTuneItems(desc, b_tune)
	local	err = CONST.ERR.ERR_VOID
	local	count = 0
	local	rough = 1
	if b_tune then rough = 10 end
	
	while true do
		local	size
		local	code = desc:r(CONST.CODESIZE)
		if code == nil then
			err = CONST.ERR.ERR_desc_r
			break
		end
		
		-- new
		if     code == CONST.CODE.antiOPER then
			return CONST.ERR.ERR_anti_opreation
		
		elseif code == CONST.CODE.num_UNIT then
			local	num
			err, num = self:io_UNIT_num_r(desc)
			if err ~= CONST.ERR.OK then return err end
			for i = 1, num do
				table.insert(self.m_units, PxtnUnit:create())
			end
		
		elseif code == CONST.CODE.MasterV5 then
			err = self.m_master:io_r_v5(desc, rough)
			if err ~= CONST.ERR.OK then return err end
			
		elseif code == CONST.CODE.Event_V5 then
			err = self.m_evels:io_Read(desc, rough)
			if err ~= CONST.ERR.OK then return err end
		
		elseif code == CONST.CODE.matePCM or
			   code == CONST.CODE.matePTV or
			   code == CONST.CODE.matePTN or
			   code == CONST.CODE.mateOGGV then
			
			err = self:io_Read_Woice(desc, code)
			if err ~= CONST.ERR.OK then return err end
			
		elseif code == CONST.CODE.effeDELA then
			err = self:io_Read_Delay(desc)
			if err ~= CONST.ERR.OK then return err end
		
		elseif code == CONST.CODE.effeOVER then
			err = self:io_Read_OverDrive(desc)
			if err ~= CONST.ERR.OK then return err end
		
		elseif code == CONST.CODE.textNAME then
			local	size = desc:r(4, "integer")
			if size == nil then return CONST.ERR.pxtnERR_desc_r end
			self.m_name = desc:r(size)
		
		elseif code == CONST.CODE.textCOMM then
			local	size = desc:r(4, "integer")
			if size == nil then return CONST.ERR.pxtnERR_desc_r end
			self.m_comment = desc:r(size)
		
		elseif code == CONST.CODE.assiWOIC then
			err = self:io_assiWOIC_r(desc)
			if err ~= CONST.ERR.OK then return err end
		
		elseif code == CONST.CODE.assiUNIT then
			err = self:io_assiUNIT_r(desc)
			if err ~= CONST.ERR.OK then return err end
		
		elseif code == CONST.CODE.pxtoneND then
			err = CONST.ERR.OK
			break
		
		-- old
		elseif code == CONST.CODE.x4x_evenMAST then
			err = self.m_master:io_r_x4x(desc, rough)
			if err ~= CONST.ERR.OK then return err end
		
		elseif code == CONST.CODE.x4x_evenUNIT then
			err = self.m_evels:io_Unit_Read_x4x_EVENT(desc, false, true, rough)
			if err ~= CONST.ERR.OK then return err end
			
		elseif code == CONST.CODE.x3x_pxtnUNIT then
			err = self:io_Read_OldUnit(desc, 3)
			if err ~= CONST.ERR.OK then return err end
		
		else
			return CONST.ERR.ERR_FATAL
		end
	end
	
	return err, count
end


function PxtnService:readVersion(desc)
	-- バージョン読込
	local	fmt_ver
	local	exe_ver = nil
	local	b_tune = false
	
	local	version = desc:r(CONST.VERSIONSIZE)
	if version == nil then return CONST.ERR.ERR_desc_r end
	
	if     version == CONST.CODE_PROJ.x1x then
		fmt_ver =        CONST.FMTVER.x1x
		exe_ver = 0
		
	elseif version == CONST.CODE_PROJ.x2x then
		fmt_ver =        CONST.FMTVER.x2x
		exe_ver = 0
		
	elseif version == CONST.CODE_PROJ.x3x then
		fmt_ver =        CONST.FMTVER.x3x
		
	elseif version == CONST.CODE_PROJ.x4x then
		fmt_ver =        CONST.FMTVER.x4x
		
	elseif version == CONST.CODE_PROJ.v5  then
		fmt_ver =        CONST.FMTVER.v5
		
	elseif version == CONST.CODE_TUNE.x2x then
		fmt_ver =        CONST.FMTVER.x2x
		exe_ver = 0
		b_tune = true
		
	elseif version == CONST.CODE_TUNE.x3x then
		fmt_ver =        CONST.FMTVER.x3x
		b_tune = true
		
	elseif version == CONST.CODE_TUNE.x4x then
		fmt_ver =        CONST.FMTVER.x4x
		b_tune = true
		
	elseif version == CONST.CODE_TUNE.v5  then
		fmt_ver =        CONST.FMTVER.v5
		b_tune = true
	else
		return CONST.ERR.ERR_fmt_unknown
	end
	
	if exe_ver == nil then
		-- バージョンを取得
		exe_ver = desc:r(2, "integer")
		if exe_ver == nil then return CONST.ERR.ERR_desc_r end
		-- ダミー
		if desc:r(2) == nil then return CONST.ERR.ERR_desc_r end
	end
	
	return CONST.ERR.OK, fmt_ver, exe_ver, b_tune
end


function PxtnService:x3x_SetVoiceNames()
	
	for i, woice in ipairs(self.m_woices) do
		woice.m_name = string.format("voice_%02d", i - 1)
	end
end

function PxtnService:pre_count_event(desc)
	
	local	err = CONST.ERR.ERR_VOID
	local	fmt_ver, exe_ver, b_tune
	local	count = 0
	
	-- バージョン
	err, fmt_ver, exe_ver, b_tune = self:readVersion(desc)
	if err ~= CONST.ERR.OK then return err end
	
	if fmt_ver == CONST.FMTVER.x1x then
		return CONST.ERR.OK, 10000
	end
	
	while true do
		local	size
		local	code = desc:r(CONST.CODESIZE)
		if code == nil then break end
		
		if     code == CONST.CODE.Event_V5 then
			count = count + self.m_evels:io_Read_EventNum(desc)
			
		elseif code == CONST.CODE.MasterV5 then
			count = count + self.m_master:io_r_v5_EventNum(desc)
		
		elseif code == CONST.CODE.x4x_evenMAST then
			count = count + self.m_master:io_r_x4x_EventNum(desc)
		
		elseif code == CONST.CODE.x4x_evenUNIT then
			local	bl, res_count = self.m_evels:io_Read_x4x_EventNum(desc)
			if bl ~= CONST.ERR.OK then return bl end
			count = count + res_count
		
		elseif code == CONST.CODE.pxtoneND then
			err = CONST.ERR.OK
			
			if fmt_ver <= CONST.FMTVER.x3x then
				count = count + CONST.MAX_TUNEUNITSTRUCT * 4
			end
			
			break
		
		elseif code == CONST.CODE.antiOPER     or 
			   code == CONST.CODE.num_UNIT     or
			   code == CONST.CODE.x3x_pxtnUNIT or
			   code == CONST.CODE.matePCM      or
			   code == CONST.CODE.matePTV      or
			   code == CONST.CODE.matePTN      or
			   code == CONST.CODE.mateOGGV     or
			   code == CONST.CODE.effeDELA     or
			   code == CONST.CODE.effeOVER     or
			   code == CONST.CODE.textNAME     or
			   code == CONST.CODE.textCOMM     or
			   code == CONST.CODE.assiUNIT     or
			   code == CONST.CODE.assiWOIC then
			
			local	size = desc:r(4, "integer")
			if size == nil or desc:seek(CONST.SEEK.CUR, size) == false then
				return CONST.ERR.ERR_desc_r
			end
		else
			return CONST.ERR.ERR_FATAL
		end
	end
	return err, count
end


function PxtnService:read(desc)
	
	local	err
	local	fmt_ver, exe_ver, b_tune, event_num
	
	-- luaだとバッファ確保いらんのでコメンツアウト
--	do
--		desc:seek(CONST.SEEK.SET, 0)
--		err, event_num = self:pre_count_event(desc)
--		if err ~= CONST.ERR.OK then return err end
--	end
	
	-- 読込処理？
	do
		desc:seek(CONST.SEEK.SET, 0)
		-- ■バージョン
		err, fmt_ver, exe_ver, b_tune = self:readVersion(desc)
		if err ~= CONST.ERR.OK then return err end
		
		-- ■アイテム読込
		err = self:readTuneItems(desc, b_tune)
		if err ~= CONST.ERR.OK then return err end
		
		if fmt_ver <= CONST.FMTVER.x3x or b_tune then
			self:x3x_SetVoiceNames()
		end
	end
end


function PxtnService:write(desc, callback)
	local	res = true
	local	exe_ver = 931
	local	rrr = 0
	local	rough = 1
	local	err = CONST.ERR.ERR_VOID
	
	local	check_size = desc:get_size()
	
	local	check_callback = function()
		if res then
			if type(callback) == "function" then
				callback(desc:get_size() - check_size)
			end
			check_size = desc:get_size()
		end
	end
	
	--format version
	if res then res = desc:w_asfile(CONST.CODE_PROJ.v5) end
	
	check_callback()
	
	-- exe version
	if res then res = desc:w_asfile(exe_ver, 2, "integer") end
	if res then res = desc:w_asfile(rrr, 2, "integer") end
	
	check_callback()
	
	-- master
	if res then res = desc:w_asfile(CONST.CODE.MasterV5) end
	if res then res = self.m_master:io_w_v5(desc, rough) end
	
	check_callback()
	
	-- event
	if res then res = desc:w_asfile(CONST.CODE.Event_V5) end
	check_callback()
	if res then res = self.m_evels:io_Write(desc, rough, callback) end
	-- event内で計測してるのでスキップ
	check_size = desc:get_size()
	
	-- name
	if #self.m_name > 0 then
		if res then res = desc:w_asfile(CONST.CODE.textNAME) end
		if res then res = desc:w_asfile(#self.m_name, 4, "integer") end
		if res then res = desc:w_asfile(self.m_name) end
	end
	
	check_callback()
	
	-- comment
	if #self.m_comment > 0 then
		if res then res = desc:w_asfile(CONST.CODE.textCOMM) end
		if res then res = desc:w_asfile(#self.m_comment, 4, "integer") end
		if res then res = desc:w_asfile(self.m_comment) end
	end
	
	check_callback()
	
	-- delay
	for i, delay in ipairs(self.m_delays) do
		if res then res = desc:w_asfile(CONST.CODE.effeDELA) end
		if res then res = delay:write(desc) end
		if res == false then break end
	end
	
	check_callback()
	
	-- overdrive
	for i, overdvive in ipairs(self.m_ovdrvs) do
		if res then res = desc:w_asfile(CONST.CODE.effeOVER) end
		if res then res = overdvive:write(desc) end
		if res == false then break end
	end
	
	check_callback()
	
	-- woice
	for i, woice in ipairs(self.m_woices) do
		
		if     woice:get_type() == CONST.WOICETYPE.PCM then
			
			if res then res = desc:w_asfile(CONST.CODE.matePCM) end
			if res then res = woice:io_matePCM_w(desc) end
			
		elseif woice:get_type() == CONST.WOICETYPE.PTV then
			
			if res then res = desc:w_asfile(CONST.CODE.matePTV) end
			if res then res = woice:io_matePTV_w(desc) end
			
		elseif woice:get_type() == CONST.WOICETYPE.PTN then
		
			if res then res = desc:w_asfile(CONST.CODE.matePTN) end
			if res then res = woice:io_matePTN_w(desc) end
			
		elseif woice:get_type() == CONST.WOICETYPE.OGGV then
		
			if res then res = desc:w_asfile(CONST.CODE.mateOGGV) end
			if res then res = woice:io_mateOGGV_w(desc) end
		else
			res = false
		end
		
		if #woice:get_name() > 1 then
			if res then res = desc:w_asfile(CONST.CODE.assiWOIC) end
			if res then res = self:io_assiWOIC_w(desc, i) end
		end
		
		check_callback()
	end
	
	-- unit
	if res then res = desc:w_asfile(CONST.CODE.num_UNIT) end
	if res then res = self:io_UNIT_num_w(desc, i) end
	
	check_callback()
	
	for i, unit in ipairs(self.m_units) do
		if #unit:get_name() > 1 then
			if res then res = desc:w_asfile(CONST.CODE.assiUNIT) end
			if res then res = self:io_assiUNIT_w(desc, i) end
		end
		
		check_callback()
	end
	
	-- end
	if res then res = desc:w_asfile(CONST.CODE.pxtoneND) end
	if res then res = desc:w_asfile(0, 4, "integer") end
	
	check_callback()
	
	return res
end


function PxtnService:io_Read_SMF_Unit(units)
	local	default_desc = PxtnDescriptor:create()
	default_desc:set_file_r("/PxtoneBox/pxtone/" .. CONST.DEFAULT_VOICE, true)
	local	voice_num = nil
	
	local	name = ""
	for i, unit in ipairs(units) do
		local	channel_name = string.format("ch:%02d", (unit.ch or 0) + 1)
		if voice_num ~= unit.voice_num then
			voice_num = unit.voice_num
			
			if unit.sound_key then
				local	key = unit.sound_key + 1
				local	header = string.format("%03d-", key)
				
				if sound_mate[key] then
					name = header .. sound_mate[key][1]
				else
					name = header .. channel_name
				end
			elseif unit.percussion_key then
				local	key = unit.percussion_key
				local	header = string.format("%03d+", key)
				
				if percussion_mate[key] then
					name = header .. percussion_mate[key][1]
				else
					name = header .. channel_name
				end
			else
				name = channel_name
			end
			
			default_desc:seek(CONST.SEEK.SET, 0)
			local	woice = PxtnWoice:create()
			
			local	err = woice:ptv_Read(default_desc)
			
			if err == CONST.ERR.OK then
				woice:set_name(name)
				table.insert(self.m_woices, woice)
			end
			
		end
		
		table.insert(self.m_units, PxtnUnit:create())
		if self.m_units[i] then
			self.m_units[i]:set_name(name)
		end
		
		-- ボイスを配る
		self.m_evels:linear_Add_i(0, i - 1, CONST.EVENTKIND.VOICENO, voice_num)
	end
	
	default_desc:commit()
end



function PxtnService:read_SMF(smf)
	
	-- テンポのセット
	if smf.m_tempo then
		self.m_master.m_beat_tempo = smf.m_tempo
	end
	
	-- 名称のセット
	if smf.m_name then
		self.m_name = smf.m_name
	end
	
	local	units = self.m_evels:io_Read_SMF(smf)
	
	if units then self:io_Read_SMF_Unit(units) end
	
end


return PxtnService

