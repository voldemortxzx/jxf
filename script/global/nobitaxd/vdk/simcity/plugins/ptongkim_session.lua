SimCityTongKimSession = SimCityTongKimSession or {
    sessions = {},
    nextSessionId = 0,
}

function SimCityTongKimSession:Get(mapId)
    local session = self.sessions[mapId]
    if not session then
        self.nextSessionId = (self.nextSessionId or 0) + 1
        session = {
            mapId = mapId,
            players = {},
            playerCount = 0,
            botIds = {[1] = {}, [2] = {}},
            active = 1,
            emptySince = nil,
            sessionId = self.nextSessionId,
        }
        self.sessions[mapId] = session
    end
    return session
end

function SimCityTongKimSession:OnPlayerEnter(mapId, playerId, nowTick)
    local session = self:Get(mapId)
    session.active = 1
    if not session.players[playerId] then
        session.playerCount = (session.playerCount or 0) + 1
    end
    session.players[playerId] = 1
    session.emptySince = nil
    return session
end

function SimCityTongKimSession:OnPlayerLeave(mapId, playerId, nowTick)
    local session = self.sessions[mapId]
    if not session then
        return nil
    end

    if session.players[playerId] then
        session.players[playerId] = nil
        session.playerCount = (session.playerCount or 1) - 1
        if session.playerCount < 0 then session.playerCount = 0 end
        if session.playerCount == 0 then
            session.emptySince = nowTick
        end
    end
    return session
end

function SimCityTongKimSession:ShouldCleanup(mapId, nowTick)
    local session = self.sessions[mapId]
    if not session or not session.emptySince then
        return 0
    end

    local emptyTicks = TONGKIM_BOT_EMPTY_TICKS or (60 * REFRESH_RATE)
    if nowTick - session.emptySince >= emptyTicks then
        return 1
    end
    return 0
end

function SimCityTongKimSession:CountCamp(mapId, camp)
    local session = self.sessions[mapId]
    local tracked = session and session.botIds and session.botIds[camp]
    local valid = {}
    local count = 0

    if not tracked or not SimCitizen or not SimCitizen.fighterList then
        return 0
    end

    for listId, _ in tracked do
        local fighter = SimCitizen.fighterList[listId]
        if fighter and fighter.nMapId == mapId and fighter.camp == camp
            and fighter.tongkimSessionId == session.sessionId
            and fighter.tongkimManaged == 1 and fighter.isCombatBot == 1 then
            valid[listId] = 1
            count = count + 1
        end
    end

    session.botIds[camp] = valid
    return count
end

function SimCityTongKimSession:Reconcile(mapId)
    local session = self.sessions[mapId]
    local createdCount = 0
    local target = TONGKIM_BOT_TARGET_PER_CAMP or 100
    local batchSize = TONGKIM_BOT_BATCH_SIZE or 10

    if TONGKIM_AUTO_BOTS_ENABLED ~= 1 or not session or session.active ~= 1 then
        return 0
    end
    if not SimCityChienTranh or not SimCityChienTranh.SpawnOne then
        return 0
    end

    for camp = 1, 2 do
        local missing = target - self:CountCamp(mapId, camp)
        local createNow = missing
        if createNow > batchSize then createNow = batchSize end

        for slot = 1, createNow do
            local listId = SimCityChienTranh:SpawnOne(mapId, camp, session.sessionId)
            if listId then
                session.botIds[camp][listId] = 1
                createdCount = createdCount + 1
            end
        end
    end
    return createdCount
end

function SimCityTongKimSession:SyncPresence(mapId, playerCount, nowTick)
    local session = self.sessions[mapId]
    if not session then return nil end
    if playerCount == nil then playerCount = 0 end
    if playerCount > 0 then
        session.emptySince = nil
    elseif session.emptySince == nil then
        session.emptySince = nowTick
    end
    session.playerCount = playerCount
    return session
end

function SimCityTongKimSession:Cleanup(mapId, reason)
    local session = self.sessions[mapId]
    if not session then return 0 end
    local removedCount = 0
    for camp = 1, 2 do
        local tracked = session.botIds[camp]
        if tracked then
            for listId, _ in tracked do
                local fighter = SimCitizen and SimCitizen.fighterList
                    and SimCitizen.fighterList[listId]
                if fighter and fighter.tongkimSessionId == session.sessionId
                    and SimCitizen.Remove then
                    SimCitizen:Remove(listId)
                    removedCount = removedCount + 1
                end
            end
        end
        session.botIds[camp] = {}
    end
    session.cleanupReason = reason
    return removedCount
end

function SimCityTongKimSession:Tick(mapId, playerCount, nowTick)
    local session = self.sessions[mapId]
    if not session or session.active ~= 1 then return 0 end
    self:SyncPresence(mapId, playerCount, nowTick)
    if session.playerCount > 0 then
        return self:Reconcile(mapId)
    end
    if self:ShouldCleanup(mapId, nowTick) == 1 then
        self:Cleanup(mapId, "empty_timeout")
        session.emptySince = nil
    end
    return 0
end

function SimCityTongKimSession:End(mapId, reason)
    local session = self.sessions[mapId]
    if not session then
        return nil
    end

    self:Cleanup(mapId, reason)
    session.active = 0
    session.endReason = reason
    self.sessions[mapId] = nil
    return session
end
