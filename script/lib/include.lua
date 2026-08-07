--Creator:yfeng
--Date:2004-8-31
--Comm:Include����ģ��
function Include(path)
	local info = getinfo(1,"S")
	local source = info.source
	
	-- Remove '@' prefix if present (from dofile/loadfile)
	if strsub(source, 1, 1) == "@" then
		source = strsub(source, 2)
	end
	
	-- Debug logging
	print("[Include] Loading: " .. path .. " from: " .. source)
	
	if(strfind(path,"\\")) then --·ʾ
		local pos = strfind(source,"\\script")
		if(pos) then
			local realpath = strsub(source,2,pos-1)..path
			print("[Include] Real path: " .. realpath)
			local result = dofile(realpath)
			print("[Include] Result: " .. tostring(result))
			return result
		end
		print("[Include] ERROR: Could not find '\\script' in source")
		return nil
	end
	local s,e = strfind(source,".*\\")
	if(not e or not s) then
		print("[Include] ERROR: Could not find end of path in source")
		return nil
	end
	local realpath = strsub(source,2,e)..path
	print("[Include] Real path: " .. realpath)
	local result = dofile(realpath)
	print("[Include] Result: " .. tostring(result))
	return result
end

