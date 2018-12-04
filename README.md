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

 - Charge - `ATK` increased by hex distance from tile before movement
 - Terrain affinity - `TDF = 1` for the given terrain
 - Repair - Can restore 2 `HP` on a friendly unit
 - Amphibian - Ground + Swimming
 - Camouflage - `STL` set to remaining `MP` at the end of turn
 - Kamikaze - Dies when attacking
 - Siege - Cannot attack if any `MP` was spent during the turn, cannot counter-strike
 - Medusa gaze - Any attacked unit immediately turns neutral (no counter-strike)
 - Weak start - Produced with 1 `HP`
 - Attack health - `ATK = ATK + HP`
 - Max count X - Cannot produce another unit if the player already owns X or more (can still capture)
 - Capturing - Unit can capture buildings and units

| Tier | Type           | `CYC` | `HP` | `MP` | `ATK` | `RNG` | `DEF` | `VIS` | `STL` | Special |
| ---- | -------------- | ----- | ---- | ---- | ----- | ----- | ----- | ----- | ----- | ------- |
| | **Ground** |
| 0 | Wolf           | 4     | 2    | 3    | 3     | 1     | 0     | 3     | 0     | Capturing |
| 1 | Spider         | 4     | 2    | 4    | 1     | 1     | 0     | 3     | 1     | Capturing, Desert affinity |
| 1 | Monkey         | 4     | 1    | 2    | 0     | 0     | 2     | 1     | 0     | Capturing, Repair, Mountain affinity, Hill affinity, Max count 2 |
| 2 | Bombardier ant | 6     | 3    | 2    | 2     | 4     | 0     | 1     | 0     | Siege |
| 2 | Chamois        | 6     | 4    | 4    | 1     | 1     | 0     | 2     | 0     | Charge, Mountain affinity, Hill affinity |
| 3 | Bull           | 10    | 6    | 3    | 2     | 1     | 1     | 2     | 0     | Charge |
| 4 | Hog            | 9     | 10   | 3    | 0     | 1     | 0     | 2     | 0     | Weak start, Attack health, Max count 1 |
| | **Flying** |
| 0 | Bat            | 5     | 2    | 8    | 0     | 0     | 0     | 4     | 0     | Max count 1 |
| 2 | Bumblebee      | 4     | 1    | 5    | 6     | 1     | 0     | 1     | 0     | Kamikaze, Siege |
| 2 | Mosquito       | 5     | 2    | 3    | 3     | 1     | 0     | 3     | 1     | - |
| 4 | Eagle          | 10    | 5    | 3    | 3     | 1     | 1     | 4     | 0     | - |
| | **Swimming** |
| 1 | Octopus        | 6     | 4    | 3    | 4     | 1     | 0     | 3     | 1     | - |
| 2 | Squid          | 10    | 2    | 3    | 4     | 4     | 2     | 1     | 0     | Siege, Max count 2 |
| 3 | Swordfish      | 9     | 4    | 6    | 0     | 1     | 1     | 2     | 1     | Charge, Max count 1 |
| | **Amphibian** |
| 1 | Frog           | 2     | 1    | 1    | 0     | 0     | 3     | 1     | 0     | - |
| 2 | Snake          | 5     | 3    | 3    | 2     | 1     | 0     | 3     | 0     | Capturing, Camouflage |
| 4 | Medusa         | 15    | 4    | 3    | 1     | 2     | 2     | 3     | 0     | Medusa gaze, Max count 1 |

### Basic building types ###

| Type        | Special |
| ----------- | ------- |
| Temple-tron | Captured = owner defeated, Effects of Shrine, Effects of Factoreon |
| Factoreon   | Produces ground units |
| Dock        | Produces swimming and amphibian units |
| Eyrie       | Produces flying units |
| Forge       | Increases available production tier by 1 when owned |
| Fortress    | Units on fortress tile get +1 ATK, +1 DEF, +1 VIS |
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

 1. Strike
 2. Counter-strike

#### Strike ####

During this phase, `AU` deals some damage to `DU`. The amount of damage is subtracted from the HP of `DU`, and is:

    DMG = max(0, AU.ATK - DU.DEF)

At least one point of damage is always dealt.

#### Counter-strike ####

During this phase, `DU` deals some damage back to to `AU`. This phase only happens if:

    AU.RNG + AU.VIS >= dst(AU, DU) - DU.STL (visibility)
    DU.RNG >= dst(AU, DU) (range)
    DU.ATK > 0 (can attack)
    DU.HP > 0 (did not die)
    !DU.defended (did not defend this turn)

This phase will not take place if `DU` was destroyed during the previous phase (fourth condition) or if `DU` already defended against an attack (last condition). The amount of damage is subtracted from the HP of `AU`, and is:

    DMG = max(0, DU.ATK - AU.DEF)

Unlike the fisrt phase, it is possible that the defending damage is zero. `DU.defended` is reset at the beginning of `DU`'s owner's turn.

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

 - [fog of war](#fog-of-war) is cleared on them
 - provide one [cycle](#cycles) at the beginning of their owner's turn

### Cycles ###

Cycles are the currency of the game. They are used to build units or purchase upgrades.

At the beginning of the game, each player has 10 cycles. At the beginning of a player's turn, they receive as 1 cycle for each tile they [own](#land-ownership).

Units can be produced in factories. Starting the production takes `CYC` cycles.

### Sacrifices ###

As the action of their Temple-tron, a player can perform a ritualistic sacrifice. The effects of the sacrifice depend on their faction's [god](#gods). They may sacrifice:

 - a unit - if it can perform an action this turn, but has not yet (i.e. not units that have just been produced, nor units that have moved / attacked / ...)
 - a turn - if they have performed no other actions during that turn
 - money - 100 cycles

### Gods ###

Active abilities have a 30 point charge-up.

 - Sacrificing **unit** - gain `max(floor(CYC / 2), cyclesDestroyed)` points

| Faction | God | Characteristic / effect |
| ------- | --- | -------------- |
| Juggernauts | Ares | Destruction |
| | - passive | +1 `ATK` on siege and charge units |
| | - active | Siege units are no longer have siege modifier. Charge adds twice as much damage. |
| Harlequins | Dionysus | Trickery, Confusion?, Charm? |
| | - passive | All flying units can capture |
| | - active | All units can capture |
| Zephyrs | Hermes | Teleportation / transport |
| | - passive | All units have desert and hill affinity |
| | - active | Every unit gains +1 max `MP` |
| Reapers | Hades | Death? Stasis? |
| | - passive | Monkeys, Bats, Frogs have 4 `DEF` |
| | - active | Thorn defense (any damage cancelled by `DEF` is dealt back to the attacker) |

## TODO ##

 - sacrifices
 - fix camera turning
 - factions
 - neutral units captured
 - main menu
 
 
 
 - multiplayer hahaaa
 - larger tiles (outline against same colour???)
 - fullscreen
 - moved / acted indicator
 - model
   - AI?
 - audio
   . create sfx
