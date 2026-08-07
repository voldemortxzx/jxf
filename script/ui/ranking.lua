function expranking_string(data)   
    local f = openfile(".\\logs\\expranking.txt", "w")
    if f then
        write(f, data)
        closefile(f)
        Msg2Player("CËp NhËt XÕp H¹ng Thµnh C«ng!")
    else
        Msg2Player("CËp NhËt XÕp H¹ng ThÊt B¹i!")
    end
end