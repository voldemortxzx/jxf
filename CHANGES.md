# SimCity Bot AI Changes

## TongKim Bot Respawn and Combat Fix (2026-08-07)

### Issue
TongKim mode bots were not respawning after death. After dying, bots would not move or fight anymore. Additionally, bots were not attacking NPC enemies after the nearest enemy logic change. Server errors occurred:
- `error: attempt to call field 'SweepStaleGhosts' (a nil value)`
- `error: attempt to perform arithmetic on global '_mx' (a nil value)`

### Root Causes
1. **Missing RetrySpawn function**: The `Respawn` function in `sim.entity.lua` was calling `SimCore:RetrySpawn` to handle failed spawns, but this function didn't exist in the codebase.

2. **Typo in RetrySpawn**: The `RetrySpawn` function had a typo `tbNpc.lastPos.nY2` instead of `tbNpc.lastPos.nY32`, causing incorrect respawn positions.

3. **isPlayerFighting check blocking NPC combat**: The `TriggerFightWithNPC` function had a condition `if tbNpc.isPlayerFighting == 0` that prevented it from triggering unless the bot was already in player fighting mode. This blocked the nearest enemy targeting logic from working.

4. **Missing SweepStaleGhosts function**: The `main.lua` file was calling `SimCitizen:SweepStaleGhosts()` and `SimTheoSau:SweepStaleGhosts()` but these functions didn't exist.

5. **_mx/_my variable scope bug**: In `sim.movement.lua`, the chase logic was using `_mx` and `_my` variables before they were defined, causing arithmetic errors.

### Solutions

#### Fix 1: Added RetrySpawn function
Added the missing `SimCore:RetrySpawn` function to `sim.core.lua` that:
1. Checks if the bot has exceeded the maximum retry count (`SIMBOT_RESPAWN_MAX_RETRIES`)
2. If retries exceeded, removes the bot from the system
3. If retries remaining, attempts to respawn the bot at its last known position
4. If spawn fails again, schedules another retry after `SIMBOT_RESPAWN_RETRY_TICKS`

Also added a check in `SimCore:OnTimer` to call `RetrySpawn` when the retry tick is reached.

#### Fix 2: Fixed typo in RetrySpawn
Changed `tbNpc.lastPos.nY2` to `tbNpc.lastPos.nY32` on line 237 of `sim.core.lua`.

#### Fix 3: Removed isPlayerFighting check from TriggerFightWithNPC
Removed the `if tbNpc.isPlayerFighting == 0` check from both `TriggerFightWithNPC` functions (in `SimFight.Citizen` and `SimFight.KeoXe`) to allow bots to attack NPC enemies directly without requiring player fighting mode first.

#### Fix 4: Added SweepStaleGhosts function
Added the `SimCore:SweepStaleGhosts` function to `sim.core.lua` to cleanup stale ghost fighters that have no finalIndex and are in a broken state.

#### Fix 5: Fixed _mx/_my variable scope bug
In `sim.movement.lua`, moved the `GetNpcPos(tbNpc.finalIndex)` call to BEFORE the distance calculations, so `_mx` and `_my` are defined before being used.

### Files Modified
- `script/global/nobitaxd/vdk/simcity/components/sim.core.lua`
  - Added `SimCore:RetrySpawn` function
  - Added retry spawn check at the beginning of `SimCore:OnTimer`
  - Fixed typo: `nY2` → `nY32`
  - Added `SimCore:SweepStaleGhosts` function

- `script/global/nobitaxd/vdk/simcity/components/sim.fight.lua`
  - Removed `isPlayerFighting` check from `SimFight.Citizen:TriggerFightWithNPC`
  - Removed `isPlayerFighting` check from `SimFight.KeoXe:TriggerFightWithNPC`

- `script/global/nobitaxd/vdk/simcity/components/sim.movement.lua`
  - Fixed variable scope bug: moved `GetNpcPos(tbNpc.finalIndex)` call before distance calculations

### Configuration
- `SIMBOT_RESPAWN_RETRY_TICKS` - Time between spawn retry attempts (~5 seconds)
- `SIMBOT_RESPAWN_MAX_RETRIES` - Maximum number of spawn retry attempts (3)

## Nearest Enemy Attack Logic

### Issue
Bots were always prioritizing attacking players over NPCs, even when NPCs were closer.

### Solution
Modified the combat logic to attack the nearest enemy (player or NPC) instead of always prioritizing players.

### Files Modified
- `script/global/nobitaxd/vdk/simcity/components/sim.fight.lua`
  - Modified `execCastNormalSkill` to calculate distances to both player and NPC enemies
  - Attack the closest enemy regardless of type

- `script/global/nobitaxd/vdk/simcity/components/sim.movement.lua`
  - Modified combat trigger logic to check if ANY enemy exists before deciding target
  - Added explicit handling for cases where only one enemy type exists

### Configuration
- `CHANCE_ATTACK_PLAYER = 1` - Still used for attack chance calculation
- `RADIUS_FIGHT_PLAYER = 20` - Player detection radius
- `RADIUS_FIGHT_NPC = 8` - NPC detection radius

## Previous Fixes

### Bot Movement and Combat Trigger Fix
Fixed a bug where bots weren't moving and fighting after the nearest enemy logic change. The combat trigger logic was checking distance to player and NPC separately, which caused bots to not engage combat when only one enemy type was present.

### SimBot Healing and Stuck Detection Fix
Added missing configuration variables for SimBot healing and stuck detection:
- `SIMBOT_HEAL_PERCENT` - Percentage of HP restored per heal tick
- `SIMBOT_HEAL_INTERVAL` - Interval between heal attempts
- `SIMBOT_STUCK_ENABLED` - Enable stuck detection
- `SIMBOT_STUCK_CHECK_TICKS` - Check interval for stuck bots
- `SIMBOT_STUCK_MAX_RETRIES` - Maximum position reset attempts before respawn
