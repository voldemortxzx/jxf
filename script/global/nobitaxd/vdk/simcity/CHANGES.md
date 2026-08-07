# SimCity Bot Attack Logic Changes

## Overview
Modified the bot combat logic to attack the **nearest enemy** (whether player or NPC) instead of always prioritizing players.

## Changes Made

### 1. **sim.fight.lua** - Skill Casting Logic
**File**: `d:/test/jxf/script/global/nobitaxd/vdk/simcity/components/sim.fight.lua`

**Before**: Bots would check if player enemy exists first, and only cast skills if player was nearby.

**After**: Bots now:
- Check for ANY enemy around (player or NPC)
- Calculate distances to both player and NPC enemies
- Attack the **closest enemy** regardless of type
- Cast skills at the nearest target

**Key Changes**:
```lua
-- Find the NEAREST enemy (player or NPC) and attack it
local nearestEnemyType = nil  -- "player" or "npc"
local nearestEnemyDist = 9999

-- Check player enemy distance
if foundPlayerEnemy > 0 then
    local playerDist = GetDistanceRadius(...)
    if playerDist < nearestEnemyDist then
        nearestEnemyDist = playerDist
        nearestEnemyType = "player"
    end
end

-- Check NPC enemy distance
if foundNpcEnemy > 0 then
    local npcDist = GetDistanceRadius(...)
    if npcDist < nearestEnemyDist then
        nearestEnemyDist = npcDist
        nearestEnemyType = "npc"
    end
end

-- Attack the nearest enemy
if nearestEnemyType == "player" and foundPlayerEnemy > 0 then
    -- Attack player
elseif nearestEnemyType == "npc" and foundNpcEnemy > 0 then
    -- Attack NPC
end
```

### 2. **sim.movement.lua** - Chase Logic
**File**: `d:/test/jxf/script/global/nobitaxd/vdk/simcity/components/sim.movement.lua`

**Before**: Bots would chase NPC enemies first, and only chase players if no NPC enemies were found.

**After**: Bots now:
- Check both NPC and player enemy distances
- Chase the **nearest enemy** regardless of type
- Prioritize closer targets over enemy type

**Key Changes**:
```lua
-- Check NPC enemy distance
if _e and _e > 0 then
    local _ex, _ey = GetNpcPos(_e)
    _tx = floor(_ex/32)
    _ty = floor(_ey/32)
    _nearestDist = GetDistanceRadius(...)
    _nearestEnemyType = "npc"
end

-- Check player enemy distance
if tbNpc.isPlayerEnemyAround and tbNpc.isPlayerEnemyAround > 0 then
    local _pw, _px, _py = CallPlayerFunction(tbNpc.isPlayerEnemyAround, GetWorldPos)
    if _px then
        local _playerDist = GetDistanceRadius(...)
        if _playerDist < _nearestDist then
            _nearestDist = _playerDist
            _tx = _px
            _ty = _py
            _nearestEnemyType = "player"
        end
    end
end

-- Chase the nearest enemy
if _tx then
    NpcRun(tbNpc.finalIndex, _tx, _ty)
end
```

### 3. **sim.movement.lua** - Combat Trigger Logic
**File**: `d:/test/jxf/script/global/nobitaxd/vdk/simcity/components/sim.movement.lua`

**Before**: Bots had a 25% chance to prioritize attacking players over NPCs when both were nearby.

**After**: Bots now:
- Calculate distances to both player and NPC enemies
- Attack the **nearest enemy** first
- Only attack players if they are closer than NPC enemies

**Key Changes**:
```lua
-- Calculate distances to both enemies
local npcDist = 9999
local playerDist = 9999

if nearestNpcEnemy and nearestNpcEnemy > 0 then
    npcDist = GetDistanceRadius(...)
end

if nearestPlayerEnemy and nearestPlayerEnemy > 0 then
    playerDist = GetDistanceRadius(...)
end

-- Attack the nearest enemy (prioritize closer target)
if npcDist < playerDist and nearestNpcEnemy > 0 then
    -- Attack nearest NPC enemy
    tbNpc.fightSys:TriggerFightWithNPC(simInstance, tbNpc)
elseif nearestPlayerEnemy > 0 then
    -- Attack nearest player enemy
    tbNpc.fightSys:TriggerFightWithPlayer(simInstance, tbNpc)
end
```

### 4. **config.lua** - Configuration Update
**File**: `d:/test/jxf/script/global/nobitaxd/vdk/simcity/config.lua`

Added comment to document the change:
```lua
-- [MODIFIED] Bots now attack nearest enemy (player or NPC) instead of always prioritizing players
```

## Behavior Changes

### Before (Player Priority)
1. Bots would always check for player enemies first
2. ~25% chance to prioritize attacking players over NPCs
3. If player was nearby, bots would attack player even if NPC was closer
4. During combat, bots would chase players if no NPC enemies were found

### After (Nearest Enemy Priority)
1. Bots calculate distances to ALL enemies (player and NPC)
2. Bots attack the **closest enemy** regardless of type
3. If NPC is closer than player, bot attacks NPC first
4. If player is closer than NPC, bot attacks player first
5. During combat, bots chase the nearest enemy

## Benefits
- More realistic combat behavior
- Bots respond to immediate threats (closest enemies)
- More dynamic and unpredictable combat scenarios
- Reduces player frustration from bots always targeting them
- Creates more balanced PvP/PvE interactions

## Testing Recommendations
1. Test in areas with both players and NPCs
2. Verify bots attack closer enemies first
3. Check that bots chase nearest enemy during combat
4. Ensure skill casting targets nearest enemy
5. Test with multiple enemies of different types nearby

## Configuration
The `CHANCE_ATTACK_PLAYER` value in `config.lua` still controls the base probability of bots initiating combat with players, but now it's combined with distance-based targeting to determine the actual target.
