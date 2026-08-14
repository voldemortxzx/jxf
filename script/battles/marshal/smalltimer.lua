IncludeLib("BATTLE");
Include("\\script\\battles\\battlehead.lua")
Include("\\script\\battles\\marshal\\head.lua")
Include("\\script\\event\\jiefang_jieri\\200904\\qianqiu_yinglie\\sj_announce.lua")		-- ��Ż֮ǧ��Ӣ��
Include("\\script\\missions\\basemission\\lib.lua")
Include("\\script\\battles\\songjingtetan_position.lua")
Include("\\script\\activitysys\\config\\32\\talkdailytask.lua")
Include("\\script\\battles\\marshal\\simTK.lua")
tbIndex = {}	-- ѡ�е������Index
tbPoint = {}	-- ��ǰ��ѡ������꼯��
tbNpc = 
{
	[1] = 
	{
		nNpcId = 1685,  --npc Id
		nLevel = 95,		-- �ȼ�
--		nSeries = 1,		-- ����
		bNoRevive = 1,			-- ������
		szName = "��c Th�m",		-- ����
		nIsboss = 1,
		nCurCamp = 1,	--��Ӫ 1�� 2��
	},
	[2] = 
	{
		nNpcId = 1686,  --npc Id
		nLevel = 95,		-- �ȼ�
--		nSeries = 1,		-- ����
		bNoRevive = 1,			-- ������
		szName = "��c Th�m",		-- ����
		nIsboss = 1,
		nCurCamp = 2,	--��Ӫ 1�� 2��
	}
}  


function SelectPosition(nRandomCount)
	for i=1,4 do
		tbIndex[i] = random(1,nRandomCount)
		local bFlag = 1
		for j=1,i-1 do
			if tbIndex[j] == tbIndex[i] then
				bFlag = 0
				break
			end
		end
		if bFlag == 0 then
			i = i - 1
		end
	end
end

function AddTeTan(nNowTimeCount)
	if tbAppearTime[nNowTimeCount - RUNGAME_TIME] == 1 then
		local nrandomCount = 0
		-- �ж���ǰ��ͼ��Id
		local nNowMapId = BT_GetGameData(GAME_MAPID)
		if nNowMapId == 380 then
			tbPoint = tbPoint_map380
			nrandomCount = 10
		elseif nNowMapId == 383 then
			tbPoint = tbPoint_map383
			nrandomCount = 20
		else
			return
		end
		s_area = BT_GetGameData(GAME_CAMP1AREA) 	-- GAME_CAMP1AREA �� GAME_CAMP1AREA ��
		j_area = BT_GetGameData(GAME_CAMP2AREA)
		
		Msg2MSAll(MISSIONID, "��c Th�m m�i �� ti�n v�o chi�n tr��ng r�i, m�i ng��i nhanh ch�ng h�nh ��ng!");
		
		SelectPosition(nrandomCount)
		local tbPosition_s = tbPoint[s_area]
		local tbPosition_j = tbPoint[j_area]
		for i=1,4 do
			local nIndex = tbIndex[i]
			tbNpc.szName = "��c Th�m"
			basemission_CallNpc(tbNpc[1], nNowMapId, tbPosition_s[nIndex].x * 32, tbPosition_s[nIndex].y * 32)
			local msg = format("T�ng th�m T�ng Kim ��c Th�m: X = %d Y = %d",tbPosition_s[nIndex].x,tbPosition_s[nIndex].y)
			WriteLog(msg)
			tbNpc.szName = "��c Th�m"
			basemission_CallNpc(tbNpc[2], nNowMapId, tbPosition_j[nIndex].x * 32, tbPosition_j[nIndex].y * 32)
			local msg = format("T�ng th�m Kim ��c Th�m : X = %d Y = %d",tbPosition_j[nIndex].x,tbPosition_j[nIndex].y)
			WriteLog(msg)
		end
	end
end

function OnTimer()
	t = GetMissionV(MS_TIMER1) + 1;--��������ͳ�Ƶ�ǰ��ʱ�������˶��ٴ���
	SetMissionV(MS_TIMER1, t)
	
	--Storm �ӽ�������
	local add_time = 60 * FRAME2TIME / TIMER_1
	storm_addm_mspointex(1, MISSIONID, (t - RUNGAME_TIME) / add_time)

	local lsf_level = BT_GetGameData(GAME_LEVEL)
	if (lsf_level == 1) then
		resultstr = "Khu v�c S� c�p "
	elseif (lsf_level == 2) then
		resultstr = "Khu v�c Trung c�p "
	elseif (lsf_level == 3) then
		resultstr = "Khu v�c Cao c�p "
	end
	
	if (t == RUNGAME_TIME) then --���������ʽ��սʱ�̣���ֹͣ��������ʽ����ս���׶�
		RunMission(MISSIONID)
		AddGlobalCountNews(resultstr.."Th�i gian b�o danh T�ng Kim (ph��ng th�c b�o v� Nguy�n So�i) �� k�t th�c. Chi�n ��u ch�nh th�c b�t ��u", 2);
		Msg2MSAll(MISSIONID, "T�ng Kim ch�nh th�c khai chi�n! C�c chi�n s�! X�ng l�n!");
		WriteLog("marshal battle is entering fight state. now member count="..GetMSPlayerCount(MISSIONID, 1)..":"..GetMSPlayerCount(MISSIONID, 2))
		-- �ճ�����ˢ�¶Ի�NPC
		%tbTalkDailyTask:AddTalkNpc(BT_GetGameData(GAME_MAPID), BT_GetGameData(GAME_MAPID));
	end

	if (t < RUNGAME_TIME and mod(t, 18) == 0) then
		RestTime = (RUNGAME_TIME - t) * TIMER_1 / FRAME2TIME
		RestMin, RestSec = GetMinAndSec(RestTime);
		if (RestSec == 0) then
			str1 = resultstr.."<#>T�ng Kim �ang trong giai �o�n b�o danh. C�c hi�p kh�ch mu�n tham gia h�y nhanh ch�ng ��n T��ng D��ng ho�c Chu Ti�n tr�n �� b�o danh! (ho�c d�ng T�ng Kim Chi�u th�) .Th�i gian b�o danh c�n l�i l�:"..RestMin.." ph�t. �i�u ki�n tham gia: C�p kh�ng �t h�n 40, ph� b�o danh 2 v�n l��ng. Sau khi khai chi�n n�u nh� v�n ch�a ��n gi�i h�n cao nh�t th� v�n c� th� b�o danh v�o ti�p";
			str2 = "<#>C�ch th�i gian khai chi�n ch� c�n:"..RestMin.."ph�t"
		else
			str1 = resultstr.."<#>T�ng Kim �ang trong giai �o�n b�o danh. C�c hi�p kh�ch mu�n tham gia h�y nhanh ch�ng ��n T��ng D��ng ho�c Chu Ti�n tr�n �� b�o danh! (ho�c d�ng  T�ng Kim Chi�u th�) .Th�i gian b�o danh c�n l�i l�:"..RestMin.."ph�t"..RestSec.." gi�y. �i�u ki�n tham gia: C�p kh�ng �t h�n 40, ph� b�o danh 2 v�n l��ng. Sau khi khai chi�n n�u nh� v�n ch�a ��n gi�i h�n cao nh�t th� v�n c� th� b�o danh v�o ti�p";
			str2 = "<#>C�ch th�i gian khai chi�n ch� c�n:"..RestMin.."ph�t"..RestSec.." gi�y"
		end
		AddGlobalCountNews(str1, 2);
		Msg2MSAll(MISSIONID,str2);		--֪ͨ������ҿ�սʣ��ʱ��
	end
	
	-- off dac tham
	-- (DOI 2026-06-18) SPAWN BOT TRUOC KHAI CHIEN cho dep: 60 giay truoc RUNGAME_TIME.
	--   Doi so 60 (giay) de bot xuat hien som/muon hon. Spawn qua som -> bot danh nhau truoc khai chien.
	-- [FIX] truoc day CHI ap dung cho lsf_level==3 (Cao cap) -- So cap/Trung cap khong duoc bot fill
	-- qua duong nay (co the da duoc bot fill boi 1 nguon khac ngoai workspace nay, vd script/simcity.lua
	-- goi qua RemoteExc, ma ta khong co quyen truy cap/sua). Bo gioi han cap do de dam bao gioi han
	-- TONGKIM_MAX_BOTS_PER_SIDE (config.lua) ap dung DONG NHAT cho ca 3 cap do.
	if (t == 1) then
		simTK:add_npc_simcity(BT_GetGameData(GAME_MAPID))
	end
	--if (t >= RUNGAME_TIME) then
	--	AddTeTan(t)  -- �����ν���̽
		
		if (t == RUNGAME_TIME) then --��ʽ��ս�ĵ�һ�δ���ʱ������ս��Npc�����ɹ�������
			if lsf_level == 3 then
				--sf_buildfightnpcdata() --tat NPC trong map TongKim
				-- elseif lsf_level == 3 then				
				-- (DOI) simTK:add_npc_simcity da chuyen len block PRE-SPAWN (truoc khai chien) o tren
			end
		else
			--����ս���Сʱ��˫���ܻ��֣�����С��һ������Ԫ˧
			if (t == BOSS_TIME) then
				if (GetMissionV(MS_TOTALPOINT_S) < GetMissionV(MS_TOTALPOINT_J)) then
					marshal_down(1)
					SetMissionV(MS_MARSHAL, 1)
				elseif(GetMissionV(MS_TOTALPOINT_S) > GetMissionV(MS_TOTALPOINT_J)) then
					marshal_down(2)
					SetMissionV(MS_MARSHAL, 2)
				elseif(GetMissionV(MS_TOTALPOINT_S) == GetMissionV(MS_TOTALPOINT_J)) then
					marshal_down(2)
					marshal_down(1)
					SetMissionV(MS_MARSHAL, 3)
				end
			end

			if (t == BOSS_TIME2) then	--�����20����ʱ����һ����Ԫ˧����
				mar = GetMissionV(MS_MARSHAL)
				if (mar == 1) then
					marshal_down(2)
				elseif (mar == 2) then
					marshal_down(1)
				end
			end
			
			--bt_pop2signmap()	--���ں�Ӫ��fight=0��������ͻر�����
			
			--ÿһ����ͨ�浱ǰ˫�����֣���npc
			if (mod(t, 3) == 0 ) then
				if lsf_level == 3 then
					sf_callfightnpc(t - RUNGAME_TIME, VANISHGAME_TIME - RUNGAME_TIME)	-- ����ս��Npc
				end
				local bs, bj = 0, 0; if GetBotPoints then bs, bj = GetBotPoints(SubWorld) end
				msstr = "C�ng c�o: hi�n gi� t�ng t�ch l�y c�a 2 phe l� "..(GetMissionV(MS_TOTALPOINT_S)+bs)..":"..(GetMissionV(MS_TOTALPOINT_J)+bj);
				Msg2MSAll(MISSIONID, msstr)
			end
			
			bt_announce(lsf_level, t);
			TB_QIANQIU_YINGLIE0904:announce(lsf_level, t);
		end
	--end
end

function sf_callfightnpc(usedtime, totaltime) 
	if (usedtime > totaltime) then
		return
	end
	local mapfile = GetMapInfoFile(BT_GetGameData(GAME_MAPID))
	s_area = BT_GetGameData(GAME_CAMP1AREA);
	j_area = BT_GetGameData(GAME_CAMP2AREA);
	for i = 2, 5 do 
		if (GetMissionV(MS_NPCCOUNT1_S + i - 1) > 0) then
			prenpccount = floor((usedtime - 1) / totaltime * GetMissionV(MS_NPCCOUNT1_S + i - 1))
			npccount = floor(usedtime / totaltime * GetMissionV(MS_NPCCOUNT1_S + i - 1))
			nowadd = npccount - prenpccount;
			if (nowadd > 0) then
				print("call song npc count= "..nowadd.."rank="..i)
				npcfile = GetIniFileData(mapfile, "Area_"..s_area, tbNPCPOS[random(2)]);
				bt_addrandfightnpc(npcfile, GetMissionV(MS_TRANK1_S + i - 1), GetMissionV(MS_RANK1LVL_S + i - 1), 1, nowadd, tabFILE_NPCDEATH[i], 1)
			end
		end
	end
	
	for i = 2, 5 do 
		if (GetMissionV(MS_NPCCOUNT1_J + i - 1) > 0) then
			prenpccount = floor((usedtime - 1) / totaltime * GetMissionV(MS_NPCCOUNT1_J + i - 1))
			npccount = floor(usedtime / totaltime * GetMissionV(MS_NPCCOUNT1_J + i - 1))
			nowadd = npccount - prenpccount
			if (nowadd > 0) then
				print("call jing npc count= "..nowadd.."rank="..i)
				npcfile = GetIniFileData(mapfile, "Area_"..j_area, tbNPCPOS[random(2)]);
				bt_addrandfightnpc(npcfile, GetMissionV(MS_TRANK1_J + i - 1), GetMissionV(MS_RANK1LVL_J + i - 1), 2, nowadd, tabFILE_NPCDEATH[i], 1)
			end
		end
	end
end

function marshal_down(camp)
	local mapfile = GetMapInfoFile(BT_GetGameData(GAME_MAPID))
	s_area = BT_GetGameData(GAME_CAMP1AREA);
	j_area = BT_GetGameData(GAME_CAMP2AREA);
	if (camp == 1) then
		enterpos = GetIniFileData(mapfile, "Area_"..s_area, "generalpos");
		x,y = bt_str2xydata(enterpos)	
		npcidx_s = AddNpc(GetMissionV(MS_TRANK1_S + 6 - 1), GetMissionV(MS_RANK1LVL_S + 6 - 1), SubWorld, x*32, y*32, 1, "Nguy�n So�i", 1)
		SetNpcCurCamp(npcidx_s, 1)
		--if simTK then simTK:markMarshal(BT_GetGameData(GAME_MAPID), 1, x, y, npcidx_s) end   -- [2026-06-28] dang ky boss -> sim bot phe Tong ve thu
		SetNpcDeathScript(npcidx_s, tabFILE_NPCDEATH[6])
		Msg2MSAll(MISSIONID, "<color=0x00FFFF>T�ng Kim chi�n b�o: Nguy�n So�i �� xu�t hi�n")
	else
		enterpos = GetIniFileData(mapfile, "Area_"..j_area, "generalpos");
		x,y = bt_str2xydata(enterpos)	
		npcidx_j = AddNpc(GetMissionV(MS_TRANK1_J + 6 - 1), GetMissionV(MS_RANK1LVL_J + 6 - 1), SubWorld, x*32, y*32, 1, "Nguy�n So�i", 1)
		SetNpcCurCamp(npcidx_j, 2)
		--if simTK then simTK:markMarshal(BT_GetGameData(GAME_MAPID), 2, x, y, npcidx_j) end   -- [2026-06-28] dang ky boss -> sim bot phe Kim ve thu
		SetNpcDeathScript(npcidx_j, tabFILE_NPCDEATH[6])
		Msg2MSAll(MISSIONID, "<color=0x9BFF9B>T�ng Kim chi�n b�o: Nguy�n So�i �� xu�t hi�n")
	end		
end