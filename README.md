# Ludum Dare 43 #
### Theme: Sacrifices must be made ###

**TBS: Temple-Based Sacrifice**

 - [setting](#setting)
 - [TBS combat](#tbs-combat)
 - [fog of war](#fog-of-war)
 - [basic unit types](#basic-unit-types)
 - [basic building types](#basic-building-types)
 - [unit-vs-unit combat](#unit-vs-unit-combat)
 - [unit movement](#unit-movement)
 - [terrain difficulty](#terrain-difficulty)
 - [land ownership](#land-ownership)
 - [cycles](#cycles)
 - [sacrifices](#sacrifices)
 - [gods](#gods)

### Setting ###

The game is set on a Earth in the distant future (21XX). Various powerful factions have turned back to their roots and worship [gods](#gods) of Ancient Greek times. Due to the surge in believers, the gods have awoken to the new times and provide their worshippers with benefits – in return for ritualistic [sacrifices](#sacrifices).

### TBS combat ###

The combat is turn-based, on a hex grid. Players take turns one after the other. During a player's turn, they may take an action with each unit and building they owned at the start of that turn (i.e. not the ones that were produced or captured during the turn).

A unit action in general consists of:
 - [movement](#unit-movement)
 - [attack / defense](#unit-vs-unit-combat) / capture / support

### Fog of war ###

The map is covered with a fog of war which reveals the terrain and building types, but not units, building ownership, or [land ownership](#land-ownership). Fog of war is cleared where a player's unit can see (`VIS` range), where they own a building, where they own land ([land ownership](#land-ownership)).

### Basic unit types ###

 - `CYC` [Cycles](#cycles) to produce
 - `HP` [Max health points](#unit-vs-unit-combat)
 - `MP` [Max movement points](#unit-movement)
 - `ATK` [Attack](#unit-vs-unit-combat)
 - `RNG` [Attack range](#unit-vs-unit-combat)
 - `DEF` [Defense](#unit-vs-unit-combat)
 - `VIS` Vision
 - `STL` Stealth

Special attributes:

 - Charge - `ATK` increased by `MP` spent before the attack
 - Terrain affinity - `TDF = 1` for the given terrain
 - Flying
 - Swimming
 - Repair - Can restore 2 `HP` on a friendly unit

| Type           | `CYC` | `HP` | `MP` | `ATK` | `RNG` | `DEF` | `VIS` | `STL` | Special |
| -------------- | ----- | ---- | ---- | ----- | ----- | ----- | ----- | ----- | ------- |
| Bull           | 6     | 5    | 3    | 2*    | 1     | 1     | 2     | 0     | Charge |
| Chamois        | 6     | 5    | 3    | 0*    | 1     | 1     | 2     | 0     | Charge, Mountain affinity |
| Bombardier ant | 5     | 3    | 2    | 2     | 3     | 0     | 4     | 0     | - |
| Bat            | 8     | 4    | 5    | 2     | 1     | 0     | 4     | 0     | Flying |
| Monkey         | 4     | 3    | 3    | 0     | 0     | 0     | 3     | 0     | Repair |

### Basic building types ###

| Type        | Special |
| ----------- | ------- |
| Temple-tron | Captured = owner defeated + effects of Shrine |
| Factory     | Produces units |
| Upgrade (?) | Provides 1 technological advance (for the rest of the game) |
| Fortress    | Units on fortress tile get +1 DEF, +1 VIS, +1 STL |
| Shrine      | Provides [ownership](#land-ownership) of nearby land |

### Unit-vs-unit combat ###

Unit-vs-unit combat depends on the stats:

 - `ATK` Attack
 - `RNG` Attack range
 - `DEF` Defense
 - `VIS` Vision
 - `STL` Stealth

Additional functions:

 - `dst(a,b)` Shortest distance in hex tiles between `a` and `b`
 - `max(a,b)` Larger number of `a` and `b`

The attacking unit (`AU`) can attack the defending unit (`DU`) during the `AU` owner's turn if the following conditions are met:

    AU.RNG + AU.VIS >= dst(AU, DU) - DU.STL (visibility)
    AU.RNG >= dst(AU, DU) (range)
    AU.ATK > 0 (can attack)

The attack consists of two phases:

 1. `AU` damage to `DU`
 2. `DU` damage to `AU`

#### `AU` damage to `DU` ####

During this phase, `AU` deals some damage to `DU`. The amount of damage is subtracted from the HP of `DU`, and is:

    DMG = max(1, `AU`.ATK - `DU`.DEF)

#### `DU` damage to `AU` ####

During this phase, `DU` deals some damage back to to `AU`. This phase only happens if:

    DU.RNG >= dst(AU, DU) (range)
    DU.ATK > 0 (can attack)
    DU.HP > 0 (did not die)

This phase will not take place if `DU` was destroyed during the previous phase (last condition). The amount of damage is subtracted from the HP of `AU`, and is:

    DMG = `DU`.ATK - `AU`.DEF

### Unit movement ###

A unit (`U`) can move at the beginning of its action. The distance it can move depends on:

 - `MP` Movement points
 - `SLW` Slowdown modifier
 - Occupancy of tiles
 - [`TDF` Terrain difficulty](#terrain-difficulty)

At the beginning of `U`'s action, the `MP` of `U` is set to:

    U.MP = U.MAX_MP - U.SLW

From the starting position of `U`, A* is used to determine the reachable tiles. The neighbours of a tile are the six tiles that touch it on a side. The cost of moving from tile `AT` to tile `BT` is:

    if occupied by enemy:
      COST = inf
    else:
      COST = max(AT.TDF, BT.TDF)

`U` can then move to any tile where:

    TOTAL_COST <= U.MP
    not occupied

Note that `U` can move through tiles occupied by friendly units, but never ones that are occupied by enemy units. `U` can never end on a previously occupied tile. After movement, `TOTAL_COST` is subtracted from `U.MP` and `U` continues to the [next phase of its action](#tbs-combat).

### Terrain difficulty ###

 - `TDF_G` = `TDF` for non-flying, non-swimming units
 - `VIS_G` = `VIS` modifier for non-flying, non-swimming units
 - `TDF_F` = `TDF` for flying units
 - `TDF_S` = `TDF` for swimming units

| Terrain  | `TDF_G` | `VIS_G` | `TDF_F` | `TDF_S` |
| -------- | ------- | ------- | ------- | ------- |
| Plain    | 1       | 0       | 1       | inf     |
| Desert   | 2       | 0       | 1       | inf     |
| Hill     | 2       | 1       | 1       | inf     |
| Mountain | 3       | 2       | 2       | inf     |
| Water    | inf     | -       | 1       | 1       |
| Void     | inf     | -       | 1       | inf     |

### Land ownership ###

Players can own land based on Shrines they have captured. The range of ownership around a Shrine is the tile of the Shrine itself and any neighboring tiles. Void tiles cannot be owned.

Any owned tiles:

 - can be [sacrificed](#sacrifices)
 - [fog of war](#fog-of-war) is cleared on them
 - provide one [cycle](#cycles) at the beginning of their owner's turn

### Cycles ###

Cycles are the currency of the game. They are used to build units or purchase upgrades.

At the beginning of the game, each player has 10 cycles. At the beginning of a player's turn, they receive as 1 cycle for each tile they [own](#land-ownership).

Units can be produced in factories. Starting the production takes `CYC` cycles.

### Sacrifices ###

As the action of their Temple-tron, a player can perform a ritualistic sacrifice. The effects of the sacrifice depend on their faction's [god](#gods). They may sacrifice:

 - a unit - if it can perform an action this turn, but has not yet (i.e. not units that have just been produced, nor units that have moved / attacked / ...)
 - a tile - if they own that tile
 - a turn - if they have performed no other actions during that turn
 - money - 100 cycles

### Gods ###

| Faction | God | Characteristic / effect |
| ------- | --- | -------------- |
| Juggernauts | Ares | Destruction |
| | - passive | bonus to attack? |
| | - sacrifice **unit** | +2 `ATK` on another unit for 1 turn |
| | - sacrifice **tile** | AoE attack (4 `ATK`, 2-wide hex area) |
| | - sacrifice **turn** | ? |
| | - sacrifice **money** | ? |
| Harlequins | Dionysus | Trickery, Confusion?, Charm? |
| | - passive | bonus to stealth? |
| | - sacrifice **unit** | +2 `STL` on another unit for 1 turn |
| | - sacrifice **tile** | ? |
| | - sacrifice **turn** | ? |
| | - sacrifice **money** | ? |
| Zephyrs | Hermes | Teleportation / transport |
| | - passive | bonus to movement? |
| | - sacrifice **unit** | +2 `MP` on another unit for 1 turn |
| | - sacrifice **tile** | ? |
| | - sacrifice **turn** | ? |
| | - sacrifice **money** | ? |
| Reapers | Hades | Death? Stasis? |
| | - passive | units always hit back (even when just killed) |
| | - sacrifice **unit** | +2 `DEF` on another unit for 1 turn |
| | - sacrifice **tile** | ? |
| | - sacrifice **turn** | ? |
| | - sacrifice **money** | ? |

## TODO ##

 - model / view architecture
   - model - game, map, units, etc, with no link to the view
     - easily extendable to AIs, local MP or even MP-over-server
   - view - animations, sprites, visual effects ...
 - model
   x hex grid map
   - tiles
     - contains buildings, units, terrain type
   - AI
   - balancing
     - unit types, stats
     - QA
     - AI simulation?
 - view
   x hex grid calculations
   - display grid, tiles, units and buildings
   . highlight tiles, units
   - display possible actions for units
     - visualise terrain difficulty
   - UI