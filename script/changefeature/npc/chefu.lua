-- ����Ի�
CurStation = 1;
Include("\\script\\global\\station.lua")

function main(sel)
	
	local mapid = SubWorldIdx2ID(SubWorld);
	local tbOpp = {"Nh�ng n�i �� �i qua/WayPointFun", "Nh�ng th�nh th� �� �i qua/StationFun", "Tu Luy?n C?c/GotoTuLuyenCoc", };

	tinsert(tbOpp, "Kh�ng c�n ��u/OnCancel");
	Say("Xa phu: Mu�n �i ��n n�i n�o?", getn(tbOpp), tbOpp);
end;

function OnCancel()
end;

