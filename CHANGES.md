# SimCity Bot AI Changes

## TongKim Bot Respawn Fix

### Issue
TongKim mode bots were not respawning after death. After dying, bots would not move or fight anymore.

### Root Cause
The `Respawn` function in `sim.entity.lua` was calling `SimCore:RetrySpawn` to handle failed spawns, but this function didn't exist in the codebase. When a bot's spawn failed (e.g., due to map being full of NPC slots), the bot would be left in a broken state with `finalIndex == nil` but still being ticked every frame.

### Solution
Added the missing `SimCore:RetrySpawn` function to `sim.core.lua` that:
1. Checks if the bot has exceeded the maximum retry count (`SIMBOT_RESPAWN_MAX_RETRIES`)
2. If retries exceeded, removes the bot from the system
3. If retries remaining, attempts to respawn the bot at its last known position
4. If spawn fails again, schedules another retry after `SIMBOT_RESPAWN_RETRY_TICKS`

Also added a check in `SimCore:OnTimer` to call `RetrySpawn` when the retry tick is reached.

### Files Modified
- `script/global/nobitaxd/vdk/simcity/components/sim.core.lua`
  - Added `SimCore:RetrySpawn` function
  - Added retry spawn check at the beginning of `SimCore:OnTimer`

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
