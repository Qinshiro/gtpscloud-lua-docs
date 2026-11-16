# Additional GTPSCloud Reference

This page organizes the user-supplied `Aditional API.txt` into an English lookup for AI/Codex. The attachment is supplemental community material, not an official GTPSCloud API page. The owner has not confirmed each listed asset or ID individually. Preserve spelling and numeric values when looking up entries, and verify availability on the target build before relying on one.

## Audio assets

The attachment lists 228 WAV filenames and 56 OGG filenames. It demonstrates `player:playAudio("transform.wav")` in `onPlayerEnterWorldCallback`. That example does not prove that every listed filename works with `playAudio`, nor that the assets are present in every server build. Pass a filename from the list as a string; do not prepend an invented path.

```lua
onPlayerEnterWorldCallback(function(world, player)
    if player then player:playAudio("transform.wav") end
end)
```

### WAV filenames

```text
achievement.wav
aibellharp.wav
airy01.wav
airy02.wav
airy03.wav
already_used.wav
arrow_thwip.wav
baa.wav
baabaa.wav
babycry.wav
balloon.wav
barf.wav
beep.wav
belch1.wav
belch2.wav
belch3.wav
belch4.wav
bell.wav
bigboom.wav
bird3.wav
bleep_fail.wav
blip_lock.wav
bloop.wav
blorb.wav
boo_death.wav
boo_evil_laugh.wav
boo_ghost_be_gone.wav
boo_ghost_trap.wav
boo_pke_warning_light.wav
boo_power_node.wav
boo_power_node.wav
boo_proton_glove.wav
boom.wav
bubble_boil.wav
burn.wav
buster.wav
cant_place_tile.wav
cash_register.wav
centaurlegs.wav
ch_slash.wav
ch_start.wav
change_clothes.wav
chicken.wav
choir.wav
chorizobark.wav
clatter.wav
clatter2.wav
click.wav
click_8bit.wav
coin_flip.wav
cracker_bang.wav
cracker_bang_2.wav
cumbia_horns.wav
DiscoFever.wav
death_metal_radio.wav
dialog_cancel.wav
dialog_close.wav
dialog_confirm.wav
dialog_open.wav
disco_head.wav
donthitme.wav
door_open.wav
door_shut.wav
double_chance.wav
droar.wav
drumloop.wav
dry_tick.wav
eat.wav
engine.wav
explode.wav
fart5.wav
fart6.wav
fight_loop.wav
fire.wav
fire_pop.wav
fireball.wav
firework1.wav
firework2.wav
flame_go.wav
forcefield.wav
fr1.wav
fr2.wav
fr3.wav
fr4.wav
fr5.wav
fr6.wav
freeze.wav
friend_beep.wav
friend_logon.wav
galac_mini.wav
gate_close.wav
gate_open.wav
gauntlet_death.wav
gauntlet_spawn.wav
gem_pickup.wav
getpoint.wav
glass_hit.wav
gobble.wav
gong.wav
goose_honk_2.wav
gulp.wav
gunshot.wav
hammer_rubble.wav
harp.wav
heart.wav
hiss2.wav
hiss3.wav
hiss4.wav
hit.wav
hub_open.wav
ionic_pulse.wav
jack_in_the_box.wav
jelly_squelch.wav
jet_engine01.wav
jet_engine02.wav
jump.wav
keypad_hit.wav
knock.wav
LightningGuitar.wav
lala_theme.wav
laser.wav
launch.wav
lb_sfx1.wav
lb_sfx2.wav
levelup.wav
levelup2.wav
lightning.wav
lil_hiss.wav
loser.wav
love_in.wav
machinegun.wav
magic.wav
male_scream.wav
metal_destroy.wav
metal_hit.wav
metalwingz.wav
mlaunch.wav
moo.wav
morty_ears.wav
msg.wav
obelisk.wav
object_collect.wav
object_spawn.wav
object_spawn2.wav
oracle.wav
ouch.wav
owooooo.wav
page_turn.wav
pay_time.wav
peep.wav
piano_nice.wav
pinata_lasso.wav
pinball.wav
plastic_ghost.wav
pop.wav
prayer_wheel.wav
punch.wav
punch_glass.wav
punch_locked.wav
punch_miss.wav
punch_organic.wav
quack.wav
race_end.wav
race_start.wav
rain_loop.wav
ratatat.wav
reality_tear.wav
realitytear.wav
repair.wav
rock_destroy.wav
rock_hit.wav
romanticjazz.wav
scream.wav
secret.wav
sheep_machine_gun2.wav
shotgun.wav
shower.wav
siren.wav
sizzle.wav
slashquick.wav
slot_lose.wav
slot_start.wav
slot_win.wav
snd037.wav
spark.wav
spell1.wav
splash.wav
splat.wav
spray.wav
squirt.wav
squish.wav
squish_undo.wav
startopia_jump_thruster.wav
startopia_jump_thruster_hover.wav
startopia_tool_droid.wav
success.wav
sungate.wav
switch.wav
switch2.wav
swoosh.wav
TechnoBeatbox.wav
teleport.wav
terraform.wav
thanksgiving.wav
thousandSlash.wav
thunderclap.wav
thwoop.wav
tile_created.wav
tile_removed.wav
tip_start.wav
toilet_flush.wav
trampoline.wav
transform.wav
trash.wav
tree_harvest.wav
tree_plant.wav
tsktsk.wav
twinkling_lights.wav
use_lock.wav
use_lock2.wav
weird_hit.wav
wheel.wav
whistle.wav
wind_loop.wav
wing_flap.wav
wood_break.wav
wood_damage.wav
wscream.wav
```

### OGG filenames

```text
about_theme.ogg
bagpipes.ogg
bar_music.ogg
battle_theme_loop.ogg
blenderbop.ogg
boombox.ogg
campfire.ogg
choir2.ogg
conga_bongos.ogg
cumbia.ogg
dabstep.ogg
death_metal_audio.ogg
digital_rain.ogg
disco.ogg
disco_head.ogg
doctor.ogg
funtime.ogg
get_ready.ogg
globe_music.ogg
harmonipan2022.ogg
hula.ogg
jazz_loop.ogg
jinglebellsmusicbox.ogg
loonysong.ogg
loop_disco.ogg
loopport_dubstep.ogg
love_birds.ogg
mex_trumpet.ogg
mooncakemelody.ogg
music_box.ogg
naughty_princess.ogg
old_timey.ogg
PineappleDisco2022.ogg
paddys_day_loop.ogg
panflutemelody.ogg
party.ogg
pineapple_record_player.ogg
scary1.ogg
signal_jammer.ogg
spooky_organ.ogg
spooky_tiki.ogg
startopia_galactic_nexus_theme.ogg
startopia_theme.ogg
suspended.ogg
theme.ogg
theme3.ogg
theme4.ogg
thriller.ogg
tropic.ogg
tsirhc.ogg
unspeakable.ogg
upbeat.ogg
western.ogg
windchimes.ogg
ykoops.ogg
you_row.ogg
```

## Punch IDs

The source contains a sequential list plus additional notable IDs. Labels are retained as supplied; `(UNKNOWN)` and unnamed entries have not been filled in. These are lookup values, not item IDs or proof of an API parameter that accepts them.

| ID | Label in source |
| ---: | --- |
| 0 | Punch |
| 1 | Cyclopean Visor |
| 2 | Heart Bow |
| 3 | Tommy Gun |
| 4 | Elvish Longbow |
| 5 | Saw-off Shotgun |
| 6 | Dragon Hand |
| 7 | Reanimator Remote |
| 8 | Death Ray |
| 9 | Six-shooter |
| 10 | Focused Eyes |
| 11 | Ice Dragon Hand |
| 12 | Pet Laser |
| 13 | Atomic Shadow Scythe |
| 14 | Pet Leprechaun |
| 15 | Battle Trout |
| 16 | Fiesta Dragon |
| 17 | Squirt Gun |
| 18 | Keytar |
| 19 | Flamethrower |
| 20 | Legendbot -009 |
| 21 | Dragon of Legend |
| 22 | Zeus s Lightning Bolt |
| 23 | Violet Protodrake Leash |
| 24 | Ring of Force |
| 25 | Ice Calf Leash |
| 26 | Magnifying Glass Leash |
| 27 | Cursed Rod |
| 28 | Ecto Flamethrower |
| 29 | Carrot Sword |
| 30 | Claw Glove |
| 31 | Unicorn Bracelet |
| 32 | Black Crystal Dragon |
| 33 | Mighty Snow Rod |
| 34 | Teeny Tank |
| 35 | Crystal Glaive |
| 36 | Heavenly Scythe |
| 37 | Heartbreaker Hammer |
| 38 | Diamond Dragon |
| 39 | Burning Eyes |
| 40 | Diamond Horns |
| 41 | Marshmallow Basket |
| 42 | Flame Scythe |
| 43 | Legendary Katana |
| 44 | Electric Bow |
| 45 | Pineapple Launcher |
| 46 | Demonic Arm |
| 47 | The Gungnir |
| 48 | Pineapples |
| 49 | Poseidon s Trident |
| 50 | Wizard Staff |
| 51 | BLYoshi s Free Dirt |
| 52 | Football |
| 53 | Tenis Ball |
| 54 | Baseball |
| 55 | Basketball |
| 56 | Green Flame |
| 57 | Fire Hose |
| 58 | Soul Orb |
| 59 | Strawberry Slime |
| 60 | Axe of Winter |
| 61 | Snowman |
| 62 | Green T-Shirt Launcher |
| 63 | Black T-Shirt Launcher |
| 64 | Party Blaster |
| 65 | Serpent Staff |
| 66 | Spring Bouquet |
| 67 | Lollipop |
| 68 | Toy Lock-Bot |
| 69 | Neutron Gun |
| 70 | Claw Scratch |
| 71 | Solsascarf |
| 72 | Skull Launcher |
| 73 | AK-8087 |
| 74 | Fiesta Hand |
| 75 | Diamond Horn |
| 76 | Adventurer s Whip |
| 77 | Burning Hands |
| 78 | Balloon Launcher |
| 79 | (UNKNOWN) |
| 80 | Rayman s Fist |
| 665 | Crystal Infused Sword |
| 90 | Apocalypse Scythe |
| 650 | Unknown |
| 690 | (unnamed) |
| 692 | Swordfish |
| 695 | Mystic Fox |
| 387 | Gungnir |
| 872 | Sonic Buster Sword |
| 705 | Jade Hat |
| 715 | Pegasus Spear |
| 717 | Blue Thingy |
| 725 | Green Scimitar |
| 729 | Beowulf Sword |
| 730 | Sonic Katana |

## Playmod / Mod IDs

The attachment calls this section “Playmods IDs.” Use its values as candidate playmod/mod identifiers only where the documented method expects one, such as `player:hasMod(modID)` or `player:getMod(modID)`. It does not establish a separate Mod ID namespace. Repeated labels and unnamed entries are preserved.

| ID | Label in source |
| ---: | --- |
| -1000 | Chat Cooldown |
| -1100 | Envious |
| -1001 | Daily Reward Cooldown |
| 0 | Silenced |
| -1 | Ninja Stealth |
| -3 | Ghost in the shell |
| -4 | (unnamed in source) |
| -7 | (unnamed in source) |
| -8 | (unnamed in source) |
| -9 | Slimed! |
| -10 | Silenced |
| -11 | (unnamed in source) |
| -13 | Egged! |
| -15 | Megaphone! |
| -16 | (unnamed in source) |
| -17 | Soaked! |
| -18 | Rock |
| -19 | WinterFest Crown! |
| -20 | WinterFest Crown! |
| -21 | WinterFest Crown! |
| -22 | WinterFest Crown! |
| -23 | Lucky in Love |
| -24 | In The Spotlight |
| -25 | Irradiated |
| -26 | No Locks |
| -30 | Feelin' Blue |
| -31 | Placing Ban |
| -32 | Breaking Ban |
| -33 | Mind Control! |
| -35 | 1 Hit |
| -36 | 1 Hit Cooldown |
| -37 | Gem Rain |
| -38 | Gem Rain Cooldown |
| -39 | Super-Duper! |
| -42 | (unnamed in source) |
| -43 | Recently Name-Changed |
| -44 | Recovering |
| -45 | Malpractice |
| -46 | Calm Nerves |
| -47 | Food: Spicey Skills |
| -48 | Food: Surgery XP |
| -49 | Malady: Lupus! |
| -50 | Malady: Chaos Infection! |
| -51 | Malady: Fatty Liver! |
| -52 | Malady: Moldy Guts! |
| -53 | Malady: Ecto Bones! |
| -54 | Malady: Brainworms! |
| -55 | Malady: Broken Heart! |
| -56 | Malady: Chicken Feet! |
| -57 | Malady: Grumbleteeth! |
| -58 | Malady: Gem Cuts! |
| -59 | Malady: Torn Punching Muscle! |
| -60 | (unnamed in source) |
| -61 | (unnamed in source) |
| -62 | (unnamed in source) |
| -63 | (unnamed in source) |
| -65 | Lucky! |
| -66 | Golden Luck! |
| -67 | Black Luck! |
| -68 | Tired Basket! |
| -69 | (unnamed in source) |
| -70 | Coin Cooldown |
| -71 | (unnamed in source) |
| -72 | (unnamed in source) |
| -73 | (unnamed in source) |
| -75 | Ban |
| -76 | Ninja Stealth |
| -78 | High-Jump: Sprite |
| -79 | Low-Jump: Sprite |
| -80 | Double-Jump: Sprite |
| -81 | Frozen |
| -82 | (unnamed in source) |
| -83 | Time Skip Cooldown |
| -84 | Caffeinated |
| -87 | Saucy! |
| -88 | Food: Extra XP |
| -89 | Energy Ball: Tier 1 |
| -90 | Energy Ball: Tier 2 |
| -91 | Energy Ball: Tier 3 |
| -92 | Energy Ball: Tier 4 |
| -93 | Curse |
| -94 | Food: Breaking Gems |
| -96 | Transmutation Test! |
| -97 | Cheat Active: Autofarm Ĝ |
| -98 | Cheat Active: Auto-BFG Ĝ |
| -99 | Cheat Active: Auto-Spam Ĝ |
| -100 | Cheat Active: Auto-Pull Ĝ |
| -101 | Cheat Active: Auto-Plant Ĝ |
| -102 | Cheat Active: Auto-Fish Ĝ |
| -103 | Cheat Active: Antibounce Ĝ |
| -104 | Cheat Active: Mod Fly Ĝ |
| -105 | Cheat Active: Super Speed Ĝ |
| -106 | Cheat Active: Gravity Ĝ |
| -107 | Cheat Active: Fast Drop Ĝ |
| -108 | Cheat Active: Fast Trash Ĝ |
| -109 | Cheat Active: No-Gem-Drop Ĝ |
| -110 | Spikeproof |
| -111 | Cheater Role Ĝ |
| -112 | Cheat Active: No-Particles Ĝ |
| -113 | Cheat Active: Lock-Autofarm Ĝ |
| -114 | Infected |
| -115 | g-Virus Immunity |
| -116 | Floating! |
| -117 | Food: Sparkling Gems |
| -118 | Food: Triple XP |
| -119 | Trawlerman's Friend |
| -120 | Food: Fishing Skill |
| -121 | Glorious |
| -500 | Ninja Warp |
| -501 | Super Rayman |
| -502 | Ghost Command |
| -503 | Antighost |

## In-game button colors

These are decimal values with color labels from the attachment. Some values appear under multiple labels, and some labels may be approximate. The attachment does not establish which API or dialog directive accepts them.

| Decimal | Source label |
| ---: | --- |
| 16711680 | Pure Red |
| 16711935 | Hot Magenta / Fuchsia |
| 16729344 | Bright Red |
| 14423100 | Crimson |
| 13369344 | Dark Red |
| 16744703 | Light Pink |
| 16761035 | Hot Pink |
| 15597568 | Deep Pink |
| 13938487 | Medium Violet Red |
| 16032864 | Rose |
| 16753920 | Orange |
| 16744192 | Dark Orange |
| 16729344 | Orange Red |
| 13959039 | Coral |
| 16766720 | Gold |
| 14329120 | Goldenrod |
| 11119017 | Dark Goldenrod |
| 9127187 | Peru / Brown Orange |
| 9127187 | Chocolate |
| 6697728 | Saddle Brown |
| 9127187 | Sienna |
| 8087790 | Burlywood |
| 13882323 | Tan |
| 16032864 | Sandy Brown |
| 16776960 | Pure Yellow |
| 16766720 | Gold |
| 16113331 | Khaki |
| 15787699 | Light Goldenrod |
| 16777184 | Light Yellow |
| 16437065 | Lemon Chiffon |
| 16119260 | Pale Goldenrod |
| 13434880 | Olive |
| 11529966 | Dark Khaki |
| 80543231 | GT Gold / Yellow (preset lama) |
| 65280 | Pure Green |
| 32768 | Green |
| 2263842 | Lime Green |
| 3050327 | Medium Spring Green |
| 3978097 | Spring Green |
| 49151 | Chartreuse |
| 8388352 | Lawn Green |
| 100043231 | GT Green (preset lama) |
| 2263842 | Medium Sea Green |
| 3050327 | Sea Green |
| 5737262 | Light Sea Green |
| 35723 | Dark Cyan / Teal |
| 3447003 | GT Teal (preset lama) |
| 64154 | Medium Aquamarine |
| 2142890 | Aquamarine |
| 9498256 | Pale Green |
| 10025880 | Light Green |
| 14423100 | Yellow Green |
| 3329330 | Olive Drab |
| 65535 | Pure Cyan / Aqua |
| 65535 | Cyan |
| 35723 | Dark Cyan |
| 6266528 | Turquoise |
| 4251856 | Medium Turquoise |
| 11591910 | Pale Turquoise |
| 52945 | Light Sea Green |
| 2003199 | Deep Sky Blue |
| 49151 | Dodger Blue |
| 255 | Pure Blue |
| 255 | Blue |
| 8900331 | Medium Blue |
| 139 | Dark Blue |
| 4915330 | Navy |
| 9699539 | Midnight Blue |
| 11591910 | Light Blue |
| 11393254 | Powder Blue |
| 9419919 | Light Steel Blue |
| 4286945 | Steel Blue |
| 2003199 | Deep Sky Blue |
| 8900331 | Royal Blue |
| 5793266 | GT Blue (preset lama) |
| 16711935 | Magenta |
| 14381203 | Medium Orchid |
| 14524637 | Medium Purple |
| 9662683 | Blue Violet |
| 9055202 | Dark Violet |
| 8388736 | Purple |
| 9109643 | Dark Magenta |
| 14381203 | Orchid |
| 15631086 | Plum |
| 16751052 | Violet |
| 13828244 | Thistle |
| 10066329 | GT Purple Gray (preset lama) |
| 12632256 | Light Purple / Grayish |
| 16777215 | Pure White |
| 16119285 | Snow |
| 16316671 | Ghost White |
| 16119260 | White Smoke |
| 15658734 | Gainsboro |
| 14737632 | Light Gray |
| 12632256 | Silver |
| 11184810 | Dark Gray |
| 8421504 | Gray |
| 6908265 | Dim Gray |
| 4473924 | Dark Slate Gray |
| 0 | Black |
| 3355443 | Almost Black |
| 5592405 | Charcoal |
| 16711935 | Neon Magenta |
| 65280 | Neon Green |
| 65535 | Neon Cyan |
| 16776960 | Neon Yellow |
| 16711680 | Neon Red |
| 255 | Neon Blue |
| 16744703 | Neon Pink |
| 8388352 | Neon Lime |
| 49151 | Neon Sky |
| 14381203 | Neon Purple |
| 16761035 | Soft Pink |
| 16764159 | Soft Peach |
| 16777113 | Soft Yellow |
| 14423100 | Soft Green |
| 11591910 | Soft Blue |
| 15631086 | Soft Purple |
| 16766720 | Soft Gold |
| 16032864 | Soft Coral |
| 14737632 | Soft Gray |
| 9419919 | Soft Steel |

## Project role and title IDs

The attachment includes one project-specific `Roles` table and one `Titles` table. These values are configuration examples for the owner's server, not GTPSCloud constants. Keep role and title maps local to a feature to avoid collisions with other scripts. Use `player:hasRole(roleID)` and documented title methods only with values confirmed for the server. The source lists the following values:

```lua
local Roles = {
    ROLE_NONE = 0, ROLE_VIP = 1, ROLE_SUPER_VIP = 2,
    ROLE_MODERATOR = 3, ROLE_ADMIN = 4,
    ROLE_COMMUNITY_MANAGER = 5, ROLE_CREATOR = 6,
    ROLE_GOD = 7, ROLE_DEVELOPER = 51
}
local Titles = {
    BLUE_NAME = 2, MENTOR = 4, G4G = 6, DR = 9,
    PARTY_ANIMAL = 10, VERIFIED = 11, OF_LEGENDS = 12,
    TIKTOK = 13, IMMORTAL = 14, OWNER = 20
}
```

## Time and date formatting

The attachment's `FormatDate` code uses `os.time()` with a configured UTC+7 offset and manually calculates calendar fields because `os.date()` is unavailable. `GMT+7 (WIB)` is a configuration choice in that example, not a guaranteed server timezone. Its moon phase and progress output are custom calculations, not GTPSCloud API functions.

For a Unix timestamp or cooldown, use `os.time()` directly. For a Discord formatted timestamp, build a Discord markup string:

```lua
local now = os.time()
local discordDate = "<t:" .. tostring(now) .. ":f>"
```

To calculate a fixed-offset date without `os.date`, use numeric Unix time and explicit calendar logic. The full supplied `FormatDate` example supports `now`, `day`, `date`, `month`, `year`, `full`, `moon`, `calendar`, and `progress` in Indonesian or English. It is a standalone user-supplied module, not a built-in GTPSCloud function. Its fixed offset does not account for daylight saving time or named timezones.
