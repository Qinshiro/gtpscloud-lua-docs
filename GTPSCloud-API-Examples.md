# GTPSCloud Lua API — Simple Examples untuk AI/Codex

> **In-game runtime update:** The user also confirmed [Find](reference/Find-Script.lua) and [Help](reference/Help-Script.lua) run normally. On this project, dialog callbacks receive `(world, player, data)` with `dialog_name` and `buttonClicked` fields; command callbacks parse slash-free names and arguments. Both scripts use true/false for handled/unrelated command and dialog events. Read [GTPSCloud-Ingame-Patterns.md](GTPSCloud-Ingame-Patterns.md) before copying the source-derived callback examples below.

> **Project runtime update:** The user confirmed that the supplied admin script runs normally. It uses `os.time()`, `timer.setTimeout(...)`, `timer.clear(...)`, and static `DiscordBot.method(...)` calls. Event/player instance methods use `:`. Prefer those conventions for this project over conflicting class-signature examples below. Read [GTPSCloud-Runtime-Notes.md](GTPSCloud-Runtime-Notes.md) and the [standalone examples](README.md#standalone-examples). The catalog preserves the original reference forms; unrelated bindings remain unconfirmed.

Pendamping [GTPSCloud-API.md](GTPSCloud-API.md), berdasarkan [docs resmi](https://dash.gtps.cloud/docs) yang diambil pada 16 November 2026. Contoh ditulis untuk membantu AI/Codex memahami konteks objek, parameter, dan pola pemanggilan.

## Aturan untuk AI/Codex

1. Targetnya sandbox Lua GTPSCloud. Jangan mengasumsikan semua library Lua standar tersedia.
2. Sesuai informasi pengguna, anggap `pcall` dan `os.date` tidak tersedia. Gunakan pemeriksaan input, nilai hasil, dan API waktu yang didokumentasikan.
3. `tryCall` di bawah mendukung build yang mempunyai `pcall`, tetapi fallback-nya **tidak menangkap error**. Jangan menggunakannya untuk menjamin skrip terus berjalan setelah exception.
4. Objek `player`, `world`, `tile`, dan `event` berasal dari callback atau getter. Nama kelas di signature bukan instance pemain aktif.
5. Setiap blok merupakan contoh terpisah. Fungsi `example` di katalog harus dipanggil dengan argumen yang benar; jangan menggabungkan seluruh blok menjadi satu skrip.
6. Angka ID, enum, flags, konfigurasi, token, asset, dan format packet yang belum dijelaskan sumber diterima sebagai argumen, bukan ditebak.
7. `return example(...)` hanya meneruskan hasil API. Untuk API yang bertipe `void`, jangan mengasumsikan hasil `true` atau sukses permanen.
8. Jangan mengarang aturan `return true`/`return false` untuk membatalkan event. Docs callback yang tersedia hanya memberi nama dan parameter, tanpa kontrak pembatalan.
9. Periksa hasil getter sebelum memakai objeknya. Walau sebagian signature tidak menuliskan `?`, keberadaan entitas bergantung pada keadaan server.
10. Contoh telah diperiksa sintaks Lua dan sebagian logikanya memakai mock. Perilaku binding GTPSCloud belum diuji pada server pengguna.

## Perbedaan binding di sumber

Halaman kelas utilitas menulis `timer:setTimeout`, `http:post(url, headers, postData)`, `sqlite:open`, dan `bit:band`. Halaman Utilities menulis bentuk titik, `http.post(url, post_data)`, dan `db.open`/`LuaDB`.

Di Lua, `obj:fn(a)` mengirim `obj` sebagai argumen pertama; `obj.fn(a)` tidak. Kedua bentuk tidak otomatis setara. Contoh praktis di bawah mengikuti signature halaman kelas. Katalog mempertahankan kedua varian sesuai sumber masing-masing; pilih binding yang berlaku pada build server. Jangan mencoba operasi tulis dua kali untuk mendeteksi binding yang cocok.

Untuk `os`, referensi hanya mendokumentasikan waktu Unix dalam detik. Contoh memakai `os:time()` sesuai halaman kelas; tidak memakai pemformat tanggal dari library standar. `getTodaysDate()` menyediakan string tanggal dari server; format dan zona waktunya tidak dijelaskan sumber.

## Daftar isi

- [Kompatibilitas dan waktu](#kompatibilitas-dan-waktu)
- [Resep sederhana](#resep-sederhana)
- [Katalog seluruh API](#katalog-seluruh-api)

## Kompatibilitas dan waktu

### 1. Helper tryCall, termasuk build tanpa pcall

```lua
-- pcall may be missing on some builds
local function tryCall(fn, ...)
    if pcall then return pcall(fn, ...) end
    return true, fn(...)
end

-- Nilai pertama adalah status wrapper, bukan hasil bisnis API.
local ok, name = tryCall(function()
    return getServerName()
end)
if ok then
    print(name)
end
```

Jika `fn` melempar error saat `pcall` tidak tersedia, error tetap menyebar. Jika `fn` mengembalikan `false`, hasilnya adalah `true, false`; jangan menganggap keduanya sama. Helper harus berada dalam scope skrip yang menggunakannya.

### 2. Waktu sekarang dan tanggal tampilan

```lua
local function currentTime()
    return os:time() -- Detik Unix; mengikuti signature halaman os.
end

local function dateLabel()
    return getTodaysDate() -- String server; bukan format ISO yang dijamin.
end
```

### 3. Cooldown dengan timestamp

```lua
local lastUse = {}
local cooldownSeconds = 10

local function canUse(player)
    if not player then return false, "player tidak tersedia" end
    local userID = player:getUserID()
    local now = os:time()
    local previous = lastUse[userID]
    if previous and now < previous + cooldownSeconds then
        return false, previous + cooldownSeconds - now
    end
    lastUse[userID] = now
    return true, 0
end
```

Ini menyimpan cooldown dalam memori skrip; reload menghapusnya. Untuk banyak pemain, hapus entri yang tidak diperlukan atau gunakan penyimpanan dengan kebijakan kedaluwarsa sendiri.

## Resep sederhana

### 4. Sambutan login: objek Player dari callback

```lua
onPlayerLoginCallback(function(player)
    if not player then return end
    player:onConsoleMessage("Halo, " .. player:getCleanName() .. "!", 0)
end)
```

### 5. Command informasi tanpa hadiah atau perubahan akun

```lua
registerLuaCommand({
    command = "contohinfo",
    roleRequired = 0,
    description = "Menampilkan level dan gems sendiri"
})

onPlayerCommandCallback(function(world, player, command)
    if not player or command ~= "contohinfo" then return end
    local message = "Level: " .. tostring(player:getLevel())
        .. " | Gems: " .. tostring(player:getGems())
    player:onConsoleMessage(message, 0)
end)
```

Contoh membandingkan token command `contohinfo`. Representasi command yang diterima callback, termasuk slash dan argumen, perlu disesuaikan jika build mengirim format lain. Tidak ada asumsi nilai return untuk menandai command sudah ditangani.

### 6. World dan Tile: baca foreground pada koordinat tile

```lua
local function foregroundAtPlayer(player)
    if not player then return nil end
    local world = player:getWorld()
    if not world then return nil end
    local x, y = player:getBlockPosX(), player:getBlockPosY()
    local tile = world:getTile(x, y)
    if not tile then return nil end
    return tile:getTileForeground()
end
```

`getBlockPosX/Y` dipakai sebagai koordinat tile. Jangan menganggap posisi pixel dan posisi tile memakai satuan yang sama.

### 7. Item: ambil nama definisi item

```lua
local function itemName(itemID)
    local item = getItem(itemID)
    if not item then return nil end
    return item:getName()
end

-- local name = itemName(2) -- Gunakan ID yang ada di server.
```

### 8. IOTM: baca stok item yang dikonfigurasi server

```lua
local function iotmAmount(itemID)
    local offer = getIOTMItem(itemID)
    if not offer then return nil end
    return offer:getAmount()
end
```

### 9. Guild: baca judul dari player

```lua
local function guildTitle(player)
    if not player then return nil end
    local guild = getGuild(player:getGuildID())
    if not guild then return nil end
    return guild:getTitle()
end
```

### 10. ShopItem: ringkasan satu offer

```lua
local function offerSummary(offer)
    if not offer then return nil end
    return {
        title = offer:getTitle(),
        price = offer:getPrice(),
        itemID = offer:getItemID()
    }
end

-- offer diperoleh dari getStoreItems()/getActiveDailyOffers().
-- Cara mengiterasi tabel mengikuti struktur aktual yang dikembalikan server.
```

### 11. GrowtopiaBot: buat dan mulai dengan token yang diberikan

```lua
local function startBot(token)
    if not token or token == "" then return nil end
    local bot = GrowtopiaBot:new(token)
    if not bot then return nil end
    bot:start()
    return bot
end
```

Token diberikan oleh konfigurasi pemanggil. Signature callback packet dan format token tidak ditebak di sini.

### 12. Drop: baca data satu dropped item

```lua
local function dropSummary(drop)
    if not drop then return nil end
    return {
        uid = drop:getUID(),
        itemID = drop:getItemID(),
        count = drop:getItemCount(),
        x = drop:getPosX(),
        y = drop:getPosY()
    }
end
```

Objek Drop diperoleh dari hasil `world:getDroppedItems()` atau `world:getTileDroppedItems(tile)`.

### 13. PlayerAutofarm: baca konfigurasi

```lua
local function autofarmInfo(player)
    if not player then return nil end
    local autofarm = player:getAutofarm()
    if not autofarm then return nil end
    return autofarm:getTargetBlockID(), autofarm:getDelay(), autofarm:getSlots()
end
```

Satuan delay autofarm tidak dijelaskan referensi; jangan menyamakannya dengan detik pada timer.

### 14. InventoryItem: baca ID dan jumlah

```lua
local function inventoryEntry(entry)
    if not entry then return nil end
    return entry:getItemID(), entry:getItemCount()
end
```

Objek InventoryItem berasal dari data inventory player. Definisi Item dan InventoryItem adalah objek berbeda.

### 15. PlayerSubscription: baca masa aktif

```lua
local function subscriptionInfo(player, subType)
    if not player then return nil end
    local sub = player:getSubscription(subType)
    if not sub then return nil end
    return sub:isPermanent(), sub:getExpireTime()
end
```

Nilai `subType` mengikuti konfigurasi server. Jangan membuat nomor tipe subscription sendiri.

### 16. DiscordBot: kirim pesan ke channel yang ditentukan

```lua
local function sendDiscordMessage(bot, channelID, content)
    if not bot or not channelID or not content then return end
    bot:messageCreate(channelID, content, nil, 0, nil, nil, nil)
end
```

Instance DiscordBot diberikan oleh integrasi server; docs yang tersedia tidak mencantumkan constructor atau getter globalnya. `0` adalah nilai flags kosong dalam contoh, tanpa embed atau komponen.

### 17. DiscordMessageCreateEvent: balas ping

```lua
onDiscordMessageCreateCallback(function(event)
    if not event or event:isBot() then return end
    if event:getContent() ~= "!ping" then return end
    event:reply("pong", nil, 0, false, nil)
end)
```

### 18. DiscordButtonClickEvent: respons tombol tertentu

```lua
onDiscordButtonClickCallback(function(event)
    if not event or event:getCustomID() ~= "contoh_ping" then return end
    event:reply("Tombol diterima", nil, 0, nil, nil)
end)
```

Tombol dengan custom ID tersebut harus sudah dibuat oleh skrip pemanggil.

### 19. DiscordFormSubmitEvent: baca nilai input modal

```lua
onDiscordFormSubmitCallback(function(event)
    if not event or event:getCustomID() ~= "contoh_form" then return end
    local value = event:getValue("pesan")
    if not value or value == "" then
        event:reply("Input pesan kosong", nil, 0, nil, nil)
        return
    end
    event:reply("Form diterima", nil, 0, nil, nil)
end)
```

Modal harus memiliki custom ID `contoh_form` dan input ID `pesan`.

### 20. DiscordSlashCommandEvent: balas memakai channelID

```lua
onDiscordSlashCommandCallback(function(event)
    if not event or event:getCommandName() ~= "ping" then return end
    event:reply(event:getChannelID(), "pong", nil, 0, nil, nil)
end)
```

Command `ping` harus sudah diregistrasikan pada bot. Parameter pertama reply slash command berbeda dari reply event tombol dan form.

### 21. RenderTexture: gambar kotak dan ambil PNG

```lua
local function rectanglePNG()
    local canvas = RenderTexture:new(128, 64)
    canvas:clear(0, 0, 0, 255)
    canvas:drawRectangle(8, 8, 48, 24, 0, 200, 100, 255)
    canvas:display()
    return canvas:toPNG()
end
```

### 22. Font: muat asset font yang tersedia

```lua
local function drawLabel(canvas, fontPath, text)
    if not canvas then return end
    local font = Font:new()
    font:loadFromFile(fontPath)
    canvas:drawText(font, text, 8, 8, 16, 255, 255, 255, 255)
    canvas:display()
end
```

`fontPath` harus menunjuk asset yang dapat diakses binding renderer. Sumber tidak menjelaskan layout direktori asset atau hasil kegagalan load.

### 23. Texture dan Sprite: gambar asset pada canvas

```lua
local function drawAsset(canvas, texturePath)
    if not canvas then return end
    local texture = Texture:new()
    texture:loadFromFile(texturePath)
    local sprite = Sprite:new()
    sprite:setTexture(texture)
    sprite:setPosition(8, 8)
    sprite:setScale(1, 1)
    canvas:draw(sprite)
    canvas:display()
end
```

### 24. ActiveEffects: baca playmod player

```lua
local function effectName(player, modID)
    if not player then return nil end
    local effect = player:getMod(modID)
    if not effect then return nil end
    return effect:getName(player), effect:getExpireTime()
end
```

### 25. HTTP GET: coroutine dan pasangan body/status

```lua
local function fetchPublic(url, onResult)
    local thread = coroutine.create(function()
        local body, status = http:get(url, { Accept = "text/plain" })
        if status == -1 then
            onResult(nil, body, status)
            return
        end
        if status < 200 or status >= 300 then
            onResult(nil, body, status)
            return
        end
        onResult(body, nil, status)
    end)
    local ok, err = coroutine.resume(thread)
    if not ok then return nil, err end
    return thread
end
```

`coroutine.resume` mengembalikan status mulai/resume awal, bukan jaminan request selesai. Binding HTTP yang async melanjutkan coroutine ketika request selesai. Error setelah yield tidak ditangkap oleh pemeriksaan resume awal ini. `onResult` harus menerima `(body, errorBody, status)` dan tidak melempar error. HTTP memblokir IP lokal/private serta membatasi satu panggilan per 50 ms per thread.

### 26. HTTP POST: pisahkan headers dan body

```lua
local function postText(url, text, onResult)
    local thread = coroutine.create(function()
        local body, status = http:post(
            url,
            { ["Content-Type"] = "text/plain" },
            text
        )
        onResult(body, status)
    end)
    local ok, err = coroutine.resume(thread)
    if not ok then return nil, err end
    return thread
end
```

Handler `onResult` memeriksa status `-1` maupun status HTTP. Contoh tidak mengasumsikan library JSON tersedia.

### 27. file dan dir: simpan lalu baca teks lokal

```lua
local function saveExampleText(text)
    local folder = "ai_examples"
    if not dir:exists(folder) then dir:create(folder) end
    local path = folder .. "/message.txt"
    file:write(path, text)
    if not file:exists(path) then return nil end
    return file:read(path)
end
```

Path relatif terhadap `localStorage` server. `file:write` mengganti isi file. Pemeriksaan exists tidak menangkap kegagalan I/O yang melempar error, dan bukan pengganti `pcall`.

### 28. timer: timeout sekali dan interval yang dihentikan

```lua
local function startExampleTimers()
    local once = timer:setTimeout(2, function()
        print("Dua detik berlalu")
    end)

    local count = 0
    local repeating
    repeating = timer:setInterval(1, function()
        count = count + 1
        print("Tick", count)
        if count >= 3 then timer:clear(repeating) end
    end)
    return once, repeating
end
```

Nilai delay timer dalam **detik**, bukan milidetik. Callback berulang menangkap ID melalui variabel yang dideklarasikan sebelum pembuatan interval.

### 29. sqlite dan SqliteDB: query tetap, periksa error, lalu close

```lua
local function readExampleValue()
    local database, openError = sqlite:open("ai_examples.sqlite")
    if not database then return nil, openError end

    local rows, queryError = database:query("SELECT 42 AS value")
    database:close()
    if not rows then return nil, queryError end
    if not rows[1] then return nil, "hasil kosong" end
    return tonumber(rows[1].value)
end
```

SELECT mengembalikan tabel baris dan nilainya berupa string menurut docs. Error query yang dikembalikan sebagai `(nil, message)` dapat ditangani tanpa `pcall`. Contoh tidak menggabungkan input pengguna ke SQL. Prepared statement tidak didokumentasikan, sehingga tidak dibuat API bind fiktif.

### 30. bit: cek flag dan tambahkan mask

```lua
local function hasFlag(flags, mask)
    return bit:band(flags, mask) ~= 0
end

local function addFlag(flags, mask)
    return bit:bor(flags, mask)
end
```

`hasFlag` memeriksa apakah setidaknya satu bit mask aktif. Untuk semua bit aktif, bandingkan hasil AND dengan mask. Arti nilai flags tetap mengikuti enum server.

### 31. Global functions: simpan preferensi per player

```lua
local function savePreference(player, enabled)
    if not player then return end
    local key = "ai_examples:preference:" .. tostring(player:getUserID())
    saveDataToServer(key, { enabled = enabled })
end

local function loadPreference(player)
    if not player then return nil end
    local key = "ai_examples:preference:" .. tostring(player:getUserID())
    local data = loadDataFromServer(key)
    if not data then return nil end
    return data.enabled
end
```

Default jika key belum ada dan perilaku data rusak tidak dijelaskan sumber. Nilai `false` adalah preferensi valid; jangan menggantinya dengan default melalui `value or default`.

### 32. NPC: gunakan koordinat tile yang sudah diperoleh

```lua
local function moveExistingNPC(world, npcName, targetTile)
    if not world or not targetTile then return false end
    local npc = world:findNPCByName(npcName)
    if not npc then return false end
    local started = npc:moveToTile(targetTile)
    if not started then return false, npc:getMovementError() end
    return true
end
```

Target harus berasal dari world yang sama. `moveToTile` khusus NPC; jangan memanggilnya pada player biasa. Keberhasilan memulai path bukan konfirmasi NPC sudah sampai.

## Katalog seluruh API

Setiap entri sumber mendapat satu contoh mandiri di bawah. Untuk operasi dengan data kompleks yang belum dijelaskan, contoh menerima objek/config/packet dari pemanggil dan mempertahankan urutan argumen. Ini adalah contoh pemanggilan minimal, bukan implementasi fitur lengkap untuk setiap operasi.

Fungsi `example` hanya didefinisikan, tidak otomatis dijalankan. Parameter `receiver` diganti nama sesuai objeknya: misalnya `player`, `world`, `database`, atau `event`. Isi fungsi meneruskan seluruh nilai hasil API, termasuk pasangan `(nil, error)` bila binding menyediakannya.

Contoh callback memakai fungsi `installExample`. Jika dipanggil, fungsi ini mendaftarkan handler yang menyimpan argumen event terakhir dan mengembalikan fungsi pembacanya. Ini memperlihatkan parameter callback tanpa menebak struktur request atau kontrak nilai return. Snapshot menyimpan referensi objek; untuk penyimpanan jangka panjang, salin ID/nilai yang dibutuhkan saat callback berjalan. Tidak ada asumsi API unregister callback.

Total: **33 bagian, 784 contoh pemanggilan API**, termasuk entri yang diulang atau ditulis sebagai varian pada Utilities. Resep praktis di atas merupakan contoh tambahan.

- [Player](#examples-player): 216 contoh.
- [World](#examples-world): 87 contoh.
- [Tile](#examples-tile): 13 contoh.
- [Item](#examples-item): 50 contoh.
- [IOTM](#examples-iotm): 3 contoh.
- [Guild](#examples-guild): 17 contoh.
- [ShopItem](#examples-shop-item): 17 contoh.
- [GrowtopiaBot](#examples-growtopia-bot): 9 contoh.
- [Drop](#examples-drop): 6 contoh.
- [PlayerAutofarm](#examples-player-autofarm): 10 contoh.
- [InventoryItem](#examples-inventory-item): 2 contoh.
- [PlayerSubscription](#examples-player-subscription): 5 contoh.
- [DiscordBot](#examples-discord-bot): 17 contoh.
- [DiscordButtonClickEvent](#examples-discord-button-click-event): 10 contoh.
- [DiscordFormSubmitEvent](#examples-discord-form-submit-event): 10 contoh.
- [DiscordMessageCreateEvent](#examples-discord-message-create-event): 10 contoh.
- [DiscordSlashCommandEvent](#examples-discord-slash-command-event): 11 contoh.
- [Font](#examples-font): 2 contoh.
- [RenderTexture](#examples-render-texture): 11 contoh.
- [Sprite](#examples-sprite): 5 contoh.
- [Texture](#examples-texture): 2 contoh.
- [ActiveEffects](#examples-active-effects): 5 contoh.
- [http](#examples-http): 2 contoh.
- [file](#examples-file): 4 contoh.
- [dir](#examples-dir): 3 contoh.
- [timer](#examples-timer): 3 contoh.
- [sqlite](#examples-sqlite): 1 contoh.
- [SqliteDB](#examples-sqlite-db): 2 contoh.
- [bit](#examples-bit): 8 contoh.
- [os](#examples-os): 1 contoh.
- [Callbacks](#examples-callbacks): 96 contoh.
- [Global Functions](#examples-globals): 122 contoh.
- [Utilities](#examples-utilities): 24 contoh.

---

<a id="examples-player"></a>

### Player

Referensi: [Player](https://dash.gtps.cloud/docs/player).

<a id="api-example-1"></a>

#### Player:getName()

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `string`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player)
    return player:getName()
end
```

<a id="api-example-2"></a>

#### Player:enterWorld(worldName, notification, bypass)

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player, worldName, notification, bypass)
    return player:enterWorld(worldName, notification, bypass)
end
```

<a id="api-example-3"></a>

#### Player:leaveWorld()

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player)
    return player:leaveWorld()
end
```

<a id="api-example-4"></a>

#### Player:punchBlock(x, y)

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player, x, y)
    return player:punchBlock(x, y)
end
```

<a id="api-example-5"></a>

#### Player:placeBlock(x, y, itemID)

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player, x, y, itemID)
    return player:placeBlock(x, y, itemID)
end
```

<a id="api-example-6"></a>

#### Player:getCleanName()

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `string`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player)
    return player:getCleanName()
end
```

<a id="api-example-7"></a>

#### Player:getRealName()

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `string`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player)
    return player:getRealName()
end
```

<a id="api-example-8"></a>

#### Player:getRealCleanName()

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `string`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player)
    return player:getRealCleanName()
end
```

<a id="api-example-9"></a>

#### Player:getTotalWorldLocks()

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `number`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player)
    return player:getTotalWorldLocks()
end
```

<a id="api-example-10"></a>

#### Player:getUserID()

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `number`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player)
    return player:getUserID()
end
```

<a id="api-example-11"></a>

#### Player:getPosX()

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `number`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player)
    return player:getPosX()
end
```

<a id="api-example-12"></a>

#### Player:getPosY()

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `number`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player)
    return player:getPosY()
end
```

<a id="api-example-13"></a>

#### Player:getBlockPosX()

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `number`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player)
    return player:getBlockPosX()
end
```

<a id="api-example-14"></a>

#### Player:getBlockPosY()

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `number`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player)
    return player:getBlockPosY()
end
```

<a id="api-example-15"></a>

#### Player:getMiddlePosX()

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `number`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player)
    return player:getMiddlePosX()
end
```

<a id="api-example-16"></a>

#### Player:getMiddlePosY()

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `number`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player)
    return player:getMiddlePosY()
end
```

<a id="api-example-17"></a>

#### Player:getNetID()

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `number`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player)
    return player:getNetID()
end
```

<a id="api-example-18"></a>

#### Player:hasMod(modID)

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `boolean`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player, modID)
    return player:hasMod(modID)
end
```

<a id="api-example-19"></a>

#### Player:hasRole(roleID)

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `boolean`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player, roleID)
    return player:hasRole(roleID)
end
```

<a id="api-example-20"></a>

#### Player:setRole(roleID)

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player, roleID)
    return player:setRole(roleID)
end
```

<a id="api-example-21"></a>

#### Player:addMod(modID, value)

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player, modID, value)
    return player:addMod(modID, value)
end
```

<a id="api-example-22"></a>

#### Player:removeMod(modID)

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player, modID)
    return player:removeMod(modID)
end
```

<a id="api-example-23"></a>

#### Player:getMod(modID)

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `ActiveEffects?`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player, modID)
    return player:getMod(modID)
end
```

<a id="api-example-24"></a>

#### Player:changeItem(itemID, itemCount, addBackpack)

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `boolean`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player, itemID, itemCount, addBackpack)
    return player:changeItem(itemID, itemCount, addBackpack)
end
```

<a id="api-example-25"></a>

#### Player:getItemAmount(itemID)

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `number`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player, itemID)
    return player:getItemAmount(itemID)
end
```

<a id="api-example-26"></a>

#### Player:getItemAmountBackpack(itemID)

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `number`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player, itemID)
    return player:getItemAmountBackpack(itemID)
end
```

<a id="api-example-27"></a>

#### Player:getXP()

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `number`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player)
    return player:getXP()
end
```

<a id="api-example-28"></a>

#### Player:setXP(xp)

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player, xp)
    return player:setXP(xp)
end
```

<a id="api-example-29"></a>

#### Player:removeXP(xp)

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player, xp)
    return player:removeXP(xp)
end
```

<a id="api-example-30"></a>

#### Player:getLevel()

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `number`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player)
    return player:getLevel()
end
```

<a id="api-example-31"></a>

#### Player:getStats(statType)

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `number`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player, statType)
    return player:getStats(statType)
end
```

<a id="api-example-32"></a>

#### Player:setStats(statType, statNumber)

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player, statType, statNumber)
    return player:setStats(statType, statNumber)
end
```

<a id="api-example-33"></a>

#### Player:getRequiredXP()

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `number`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player)
    return player:getRequiredXP()
end
```

<a id="api-example-34"></a>

#### Player:getGems()

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `number`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player)
    return player:getGems()
end
```

<a id="api-example-35"></a>

#### Player:addGems(gems, instantSet, progressQuests)

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player, gems, instantSet, progressQuests)
    return player:addGems(gems, instantSet, progressQuests)
end
```

<a id="api-example-36"></a>

#### Player:removeGems(gems, instantSet)

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `boolean`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player, gems, instantSet)
    return player:removeGems(gems, instantSet)
end
```

<a id="api-example-37"></a>

#### Player:setGems(gems, instantSet)

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `boolean`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player, gems, instantSet)
    return player:setGems(gems, instantSet)
end
```

<a id="api-example-38"></a>

#### Player:updateGems(instantSet)

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player, instantSet)
    return player:updateGems(instantSet)
end
```

<a id="api-example-39"></a>

#### Player:getAutofarm()

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `PlayerAutofarm`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player)
    return player:getAutofarm()
end
```

<a id="api-example-40"></a>

#### Player:onConsoleMessage(message, delay)

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player, message, delay)
    return player:onConsoleMessage(message, delay)
end
```

<a id="api-example-41"></a>

#### Player:playAudio(message)

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player, message)
    return player:playAudio(message)
end
```

<a id="api-example-42"></a>

#### Player:onDialogRequest(message, delay, callback)

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player, message, delay, callback)
    return player:onDialogRequest(message, delay, callback)
end
```

<a id="api-example-43"></a>

#### Player:onStoreRequest(message, delay)

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player, message, delay)
    return player:onStoreRequest(message, delay)
end
```

<a id="api-example-44"></a>

#### Player:onStorePurchaseResult(message, delay)

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player, message, delay)
    return player:onStorePurchaseResult(message, delay)
end
```

<a id="api-example-45"></a>

#### Player:onTalkBubble(netID, message, persistMessage, delay)

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player, netID, message, persistMessage, delay)
    return player:onTalkBubble(netID, message, persistMessage, delay)
end
```

<a id="api-example-46"></a>

#### Player:onTextOverlay(message, delay)

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player, message, delay)
    return player:onTextOverlay(message, delay)
end
```

<a id="api-example-47"></a>

#### Player:canFit(items)

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `boolean`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player, items)
    return player:canFit(items)
end
```

<a id="api-example-48"></a>

#### Player:getCoins()

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `number`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player)
    return player:getCoins()
end
```

<a id="api-example-49"></a>

#### Player:addCoins(coins)

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player, coins)
    return player:addCoins(coins)
end
```

<a id="api-example-50"></a>

#### Player:setCoins(coins)

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player, coins)
    return player:setCoins(coins)
end
```

<a id="api-example-51"></a>

#### Player:removeCoins(coins, progressQuests)

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `boolean`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player, coins, progressQuests)
    return player:removeCoins(coins, progressQuests)
end
```

<a id="api-example-52"></a>

#### Player:progressQuests(itemID, itemCount)

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player, itemID, itemCount)
    return player:progressQuests(itemID, itemCount)
end
```

<a id="api-example-53"></a>

#### Player:upgradeInventorySpace(size)

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player, size)
    return player:upgradeInventorySpace(size)
end
```

<a id="api-example-54"></a>

#### Player:removeInventorySpace(size)

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player, size)
    return player:removeInventorySpace(size)
end
```

<a id="api-example-55"></a>

#### Player:setInventorySpace(newSize)

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player, newSize)
    return player:setInventorySpace(newSize)
end
```

<a id="api-example-56"></a>

#### Player:isMaxInventorySpace()

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `boolean`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player)
    return player:isMaxInventorySpace()
end
```

<a id="api-example-57"></a>

#### Player:getInventorySize()

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `number`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player)
    return player:getInventorySize()
end
```

<a id="api-example-58"></a>

#### Player:onRedeemMenu()

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player)
    return player:onRedeemMenu()
end
```

<a id="api-example-59"></a>

#### Player:getWorldName()

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `string`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player)
    return player:getWorldName()
end
```

<a id="api-example-60"></a>

#### Player:getWorld()

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `World`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player)
    return player:getWorld()
end
```

<a id="api-example-61"></a>

#### Player:onGrow4GoodDonate()

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player)
    return player:onGrow4GoodDonate()
end
```

<a id="api-example-62"></a>

#### Player:getMods()

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `{ActiveEffects}`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player)
    return player:getMods()
end
```

<a id="api-example-63"></a>

#### Player:getClothingItemID(index)

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `number`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player, index)
    return player:getClothingItemID(index)
end
```

<a id="api-example-64"></a>

#### Player:getSubscription(subType)

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `PlayerSubscription?`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player, subType)
    return player:getSubscription(subType)
end
```

<a id="api-example-65"></a>

#### Player:addSubscription(Type, exp)

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `PlayerSubscription`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player, Type, exp)
    return player:addSubscription(Type, exp)
end
```

<a id="api-example-66"></a>

#### Player:removeSubscription(type)

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player, type)
    return player:removeSubscription(type)
end
```

<a id="api-example-67"></a>

#### Player:getPlaytime()

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `number`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player)
    return player:getPlaytime()
end
```

<a id="api-example-68"></a>

#### Player:setPlaytime(time)

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player, time)
    return player:setPlaytime(time)
end
```

<a id="api-example-69"></a>

#### Player:addPlaytime(time)

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player, time)
    return player:addPlaytime(time)
end
```

<a id="api-example-70"></a>

#### Player:getAccountCreationTime()

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `number`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player)
    return player:getAccountCreationTime()
end
```

<a id="api-example-71"></a>

#### Player:setAccountCreationTime(time)

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player, time)
    return player:setAccountCreationTime(time)
end
```

<a id="api-example-72"></a>

#### Player:getAccountCreationDateStr()

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `string`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player)
    return player:getAccountCreationDateStr()
end
```

<a id="api-example-73"></a>

#### Player:getTransformProfileButtons()

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `string`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player)
    return player:getTransformProfileButtons()
end
```

<a id="api-example-74"></a>

#### Player:onTradeHistoryUI(targetPlayer)

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player, targetPlayer)
    return player:onTradeHistoryUI(targetPlayer)
end
```

<a id="api-example-75"></a>

#### Player:onBackpackUI(targetPlayer)

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player, targetPlayer)
    return player:onBackpackUI(targetPlayer)
end
```

<a id="api-example-76"></a>

#### Player:onMentorshipUI()

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player)
    return player:onMentorshipUI()
end
```

<a id="api-example-77"></a>

#### Player:onVouchersUI()

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player)
    return player:onVouchersUI()
end
```

<a id="api-example-78"></a>

#### Player:onNameIconsUI(targetPlayer)

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player, targetPlayer)
    return player:onNameIconsUI(targetPlayer)
end
```

<a id="api-example-79"></a>

#### Player:onWrenchIconsUI(targetPlayer)

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player, targetPlayer)
    return player:onWrenchIconsUI(targetPlayer)
end
```

<a id="api-example-80"></a>

#### Player:onTitlesUI(targetPlayer)

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player, targetPlayer)
    return player:onTitlesUI(targetPlayer)
end
```

<a id="api-example-81"></a>

#### Player:onAchievementsUI(targetPlayer)

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player, targetPlayer)
    return player:onAchievementsUI(targetPlayer)
end
```

<a id="api-example-82"></a>

#### Player:onClothesUI(targetPlayer)

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player, targetPlayer)
    return player:onClothesUI(targetPlayer)
end
```

<a id="api-example-83"></a>

#### Player:getClassicProfileContent(catType, flags)

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `string`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player, catType, flags)
    return player:getClassicProfileContent(catType, flags)
end
```

<a id="api-example-84"></a>

#### Player:getDiscordID()

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `string`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player)
    return player:getDiscordID()
end
```

<a id="api-example-85"></a>

#### Player:onLinkDiscordUI()

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player)
    return player:onLinkDiscordUI()
end
```

<a id="api-example-86"></a>

#### Player:onUnlinkDiscordUI()

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player)
    return player:onUnlinkDiscordUI()
end
```

<a id="api-example-87"></a>

#### Player:getUnlockedAchievementsCount()

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `number`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player)
    return player:getUnlockedAchievementsCount()
end
```

<a id="api-example-88"></a>

#### Player:getBackpackUsedSize()

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `number`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player)
    return player:getBackpackUsedSize()
end
```

<a id="api-example-89"></a>

#### Player:onFavItemsUI()

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player)
    return player:onFavItemsUI()
end
```

<a id="api-example-90"></a>

#### Player:onOnlineStatusUI()

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player)
    return player:onOnlineStatusUI()
end
```

<a id="api-example-91"></a>

#### Player:getOnlineStatus()

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `number`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player)
    return player:getOnlineStatus()
end
```

<a id="api-example-92"></a>

#### Player:onPersonalizeWrenchUI()

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player)
    return player:onPersonalizeWrenchUI()
end
```

<a id="api-example-93"></a>

#### Player:getHomeWorldID()

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `number`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player)
    return player:getHomeWorldID()
end
```

<a id="api-example-94"></a>

#### Player:getProfileGuildInfo()

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `string`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player)
    return player:getProfileGuildInfo()
end
```

<a id="api-example-95"></a>

#### Player:getSubscriptionInfo()

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `string`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player)
    return player:getSubscriptionInfo()
end
```

<a id="api-example-96"></a>

#### Player:getCardBattleInfo()

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `string`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player)
    return player:getCardBattleInfo()
end
```

<a id="api-example-97"></a>

#### Player:getProfileAccessButton()

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `string`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player)
    return player:getProfileAccessButton()
end
```

<a id="api-example-98"></a>

#### Player:getProfileGuildJoinButton()

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `string`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player)
    return player:getProfileGuildJoinButton()
end
```

<a id="api-example-99"></a>

#### Player:onBillboardUI()

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player)
    return player:onBillboardUI()
end
```

<a id="api-example-100"></a>

#### Player:onNotebookUI()

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player)
    return player:onNotebookUI()
end
```

<a id="api-example-101"></a>

#### Player:onGrowpassUI()

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player)
    return player:onGrowpassUI()
end
```

<a id="api-example-102"></a>

#### Player:onGrowmojiUI()

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player)
    return player:onGrowmojiUI()
end
```

<a id="api-example-103"></a>

#### Player:onGrow4GoodUI()

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player)
    return player:onGrow4GoodUI()
end
```

<a id="api-example-104"></a>

#### Player:onTradeScanUI()

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player)
    return player:onTradeScanUI()
end
```

<a id="api-example-105"></a>

#### Player:getGuildID()

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `number`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player)
    return player:getGuildID()
end
```

<a id="api-example-106"></a>

#### Player:onGuildNotebookUI()

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player)
    return player:onGuildNotebookUI()
end
```

<a id="api-example-107"></a>

#### Player:onProfileUI(world, tab)

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player, world, tab)
    return player:onProfileUI(world, tab)
end
```

<a id="api-example-108"></a>

#### Player:onAddNotification(texture, message, audio, num, delay)

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player, texture, message, audio, num, delay)
    return player:onAddNotification(texture, message, audio, num, delay)
end
```

<a id="api-example-109"></a>

#### Player:onParticleEffect(particleID, posX, posY, num, num2, delay)

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player, particleID, posX, posY, num, num2, delay)
    return player:onParticleEffect(particleID, posX, posY, num, num2, delay)
end
```

<a id="api-example-110"></a>

#### Player:setNextDialogRGBA(R, G, B, A)

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player, R, G, B, A)
    return player:setNextDialogRGBA(R, G, B, A)
end
```

<a id="api-example-111"></a>

#### Player:resetDialogColor()

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player)
    return player:resetDialogColor()
end
```

<a id="api-example-112"></a>

#### Player:setNextDialogBorderRGBA(R, G, B, A)

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player, R, G, B, A)
    return player:setNextDialogBorderRGBA(R, G, B, A)
end
```

<a id="api-example-113"></a>

#### Player:updateStats(world, type, amount)

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player, world, type, amount)
    return player:updateStats(world, type, amount)
end
```

<a id="api-example-114"></a>

#### Player:getCountry()

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `string`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player)
    return player:getCountry()
end
```

<a id="api-example-115"></a>

#### Player:setCountry(country)

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player, country)
    return player:setCountry(country)
end
```

<a id="api-example-116"></a>

#### Player:getPlatform()

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `string`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player)
    return player:getPlatform()
end
```

<a id="api-example-117"></a>

#### Player:sendVariant(variantList, delay, netID)

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player, variantList, delay, netID)
    return player:sendVariant(variantList, delay, netID)
end
```

<a id="api-example-118"></a>

#### Player:sendAction(action_str)

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player, action_str)
    return player:sendAction(action_str)
end
```

<a id="api-example-119"></a>

#### Player:getInventoryItems()

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `{InventoryItem}`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player)
    return player:getInventoryItems()
end
```

<a id="api-example-120"></a>

#### Player:disconnect()

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player)
    return player:disconnect()
end
```

<a id="api-example-121"></a>

#### Player:sendRawPacket(data)

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player, data)
    return player:sendRawPacket(data)
end
```

<a id="api-example-122"></a>

#### Player:getType()

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `number`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player)
    return player:getType()
end
```

<a id="api-example-123"></a>

#### Player:isFacingLeft()

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `boolean`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player)
    return player:isFacingLeft()
end
```

<a id="api-example-124"></a>

#### Player:isOnline()

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `boolean`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player)
    return player:isOnline()
end
```

<a id="api-example-125"></a>

#### Player:addTitle(title_id)

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player, title_id)
    return player:addTitle(title_id)
end
```

<a id="api-example-126"></a>

#### Player:hasTitle(title_id)

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `boolean`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player, title_id)
    return player:hasTitle(title_id)
end
```

<a id="api-example-127"></a>

#### Player:removeTitle(title_id)

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player, title_id)
    return player:removeTitle(title_id)
end
```

<a id="api-example-128"></a>

#### Player:getActiveTitles()

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `{any}`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player)
    return player:getActiveTitles()
end
```

<a id="api-example-129"></a>

#### Player:addActiveTitle(title_id)

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player, title_id)
    return player:addActiveTitle(title_id)
end
```

<a id="api-example-130"></a>

#### Player:removeActiveTitle(title_id)

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player, title_id)
    return player:removeActiveTitle(title_id)
end
```

<a id="api-example-131"></a>

#### Player:addMail(mail)

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player, mail)
    return player:addMail(mail)
end
```

<a id="api-example-132"></a>

#### Player:clearMailbox()

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player)
    return player:clearMailbox()
end
```

<a id="api-example-133"></a>

#### Player:setNickname(nickname)

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player, nickname)
    return player:setNickname(nickname)
end
```

<a id="api-example-134"></a>

#### Player:resetNickname()

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player)
    return player:resetNickname()
end
```

<a id="api-example-135"></a>

#### Player:getBankBalance()

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `number`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player)
    return player:getBankBalance()
end
```

<a id="api-example-136"></a>

#### Player:addBankBalance(balance)

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player, balance)
    return player:addBankBalance(balance)
end
```

<a id="api-example-137"></a>

#### Player:removeBankBalance(balance)

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `boolean`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player, balance)
    return player:removeBankBalance(balance)
end
```

<a id="api-example-138"></a>

#### Player:setBankBalance(balance)

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player, balance)
    return player:setBankBalance(balance)
end
```

<a id="api-example-139"></a>

#### Player:setCountryFlagForeground(item_id)

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player, item_id)
    return player:setCountryFlagForeground(item_id)
end
```

<a id="api-example-140"></a>

#### Player:setCountryFlagBackground(item_id)

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player, item_id)
    return player:setCountryFlagBackground(item_id)
end
```

<a id="api-example-141"></a>

#### Player:getCountryFlagForeground()

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `number`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player)
    return player:getCountryFlagForeground()
end
```

<a id="api-example-142"></a>

#### Player:getCountryFlagBackground()

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `number`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player)
    return player:getCountryFlagBackground()
end
```

<a id="api-example-143"></a>

#### Player:addLevel(level)

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player, level)
    return player:addLevel(level)
end
```

<a id="api-example-144"></a>

#### Player:removeLevel(level)

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player, level)
    return player:removeLevel(level)
end
```

<a id="api-example-145"></a>

#### Player:setLevel(level)

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player, level)
    return player:setLevel(level)
end
```

<a id="api-example-146"></a>

#### Player:ban(modDuration, reason, punishedBy, banDevice, banIP)

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player, modDuration, reason, punishedBy, banDevice, banIP)
    return player:ban(modDuration, reason, punishedBy, banDevice, banIP)
end
```

<a id="api-example-147"></a>

#### Player:setRoleQuestLevel(type, newLevel)

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player, type, newLevel)
    return player:setRoleQuestLevel(type, newLevel)
end
```

<a id="api-example-148"></a>

#### Player:getRoleQuestLevel(type)

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `number`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player, type)
    return player:getRoleQuestLevel(type)
end
```

<a id="api-example-149"></a>

#### Player:getIP()

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `string`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player)
    return player:getIP()
end
```

<a id="api-example-150"></a>

#### Player:getRID()

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `string`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player)
    return player:getRID()
end
```

<a id="api-example-151"></a>

#### Player:setPassword(tankIDPass)

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player, tankIDPass)
    return player:setPassword(tankIDPass)
end
```

<a id="api-example-152"></a>

#### Player:getEmail()

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `string`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player)
    return player:getEmail()
end
```

<a id="api-example-153"></a>

#### Player:getBackpackItems()

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `{InventoryItem}`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player)
    return player:getBackpackItems()
end
```

<a id="api-example-154"></a>

#### Player:getGender()

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `number`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player)
    return player:getGender()
end
```

<a id="api-example-155"></a>

#### Player:hasActiveBlessing(blessingID)

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `boolean`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player, blessingID)
    return player:hasActiveBlessing(blessingID)
end
```

<a id="api-example-156"></a>

#### Player:hasBlessing(blessingID)

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `boolean`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player, blessingID)
    return player:hasBlessing(blessingID)
end
```

<a id="api-example-157"></a>

#### Player:removeBlessing(blessingID)

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player, blessingID)
    return player:removeBlessing(blessingID)
end
```

<a id="api-example-158"></a>

#### Player:addBlessing(blessingID)

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player, blessingID)
    return player:addBlessing(blessingID)
end
```

<a id="api-example-159"></a>

#### Player:checkPassword(password)

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `boolean`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player, password)
    return player:checkPassword(password)
end
```

<a id="api-example-160"></a>

#### Player:getDiscordInvites()

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `number`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player)
    return player:getDiscordInvites()
end
```

<a id="api-example-161"></a>

#### Player:doAction(str)

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player, str)
    return player:doAction(str)
end
```

<a id="api-example-162"></a>

#### Player:doRawPacket(data)

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player, data)
    return player:doRawPacket(data)
end
```

<a id="api-example-163"></a>

#### Player:getAltAccounts()

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `{Player}`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player)
    return player:getAltAccounts()
end
```

<a id="api-example-164"></a>

#### Player:getRole()

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `any`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player)
    return player:getRole()
end
```

<a id="api-example-165"></a>

#### Player:getTitles()

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `{any}`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player)
    return player:getTitles()
end
```

<a id="api-example-166"></a>

#### Player:getOwnedWorlds()

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `{number}`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player)
    return player:getOwnedWorlds()
end
```

<a id="api-example-167"></a>

#### Player:getRecentWorlds()

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `{number}`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player)
    return player:getRecentWorlds()
end
```

<a id="api-example-168"></a>

#### Player:getAccessWorlds()

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `{number}`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player)
    return player:getAccessWorlds()
end
```

<a id="api-example-169"></a>

#### Player:getIPHistory()

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `{string}`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player)
    return player:getIPHistory()
end
```

<a id="api-example-170"></a>

#### Player:getRIDHistory()

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `{string}`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player)
    return player:getRIDHistory()
end
```

<a id="api-example-171"></a>

#### Player:getSmallLockedWorlds()

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `{number}`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player)
    return player:getSmallLockedWorlds()
end
```

<a id="api-example-172"></a>

#### Player:setBroadcastWorld(worldName)

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player, worldName)
    return player:setBroadcastWorld(worldName)
end
```

<a id="api-example-173"></a>

#### Player:getFriends()

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `{number}`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player)
    return player:getFriends()
end
```

<a id="api-example-174"></a>

#### Player:addFriend(second_player)

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player, second_player)
    return player:addFriend(second_player)
end
```

<a id="api-example-175"></a>

#### Player:removeFriend(second_player)

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player, second_player)
    return player:removeFriend(second_player)
end
```

<a id="api-example-176"></a>

#### Player:getLifeGoals()

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `{any}`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player)
    return player:getLifeGoals()
end
```

<a id="api-example-177"></a>

#### Player:getBiweeklyQuests()

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `{any}`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player)
    return player:getBiweeklyQuests()
end
```

<a id="api-example-178"></a>

#### Player:getGrowpassPoints()

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `number`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player)
    return player:getGrowpassPoints()
end
```

<a id="api-example-179"></a>

#### Player:addGrowpassPoints(points)

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player, points)
    return player:addGrowpassPoints(points)
end
```

<a id="api-example-180"></a>

#### Player:setGrowpassPoints(points)

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player, points)
    return player:setGrowpassPoints(points)
end
```

<a id="api-example-181"></a>

#### Player:adjustBlockHitCount(adjust)

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player, adjust)
    return player:adjustBlockHitCount(adjust)
end
```

<a id="api-example-182"></a>

#### Player:getAdjustedBlockHitCount()

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `number`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player)
    return player:getAdjustedBlockHitCount()
end
```

<a id="api-example-183"></a>

#### Player:getPing()

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `number`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player)
    return player:getPing()
end
```

<a id="api-example-184"></a>

#### Player:getDungeonScrolls()

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `number`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player)
    return player:getDungeonScrolls()
end
```

<a id="api-example-185"></a>

#### Player:setDungeonScrolls(scrolls)

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player, scrolls)
    return player:setDungeonScrolls(scrolls)
end
```

<a id="api-example-186"></a>

#### Player:hasGrowID()

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `boolean`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player)
    return player:hasGrowID()
end
```

<a id="api-example-187"></a>

#### Player:addNote(note)

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player, note)
    return player:addNote(note)
end
```

<a id="api-example-188"></a>

#### Player:setAAPEnabled(aapEnabled)

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player, aapEnabled)
    return player:setAAPEnabled(aapEnabled)
end
```

<a id="api-example-189"></a>

#### Player:setCustomAutofarmDelay(delay)

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player, delay)
    return player:setCustomAutofarmDelay(delay)
end
```

<a id="api-example-190"></a>

#### Player:getGameVersion()

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `number`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player)
    return player:getGameVersion()
end
```

<a id="api-example-191"></a>

#### Player:getItemEffects()

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `any`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player)
    return player:getItemEffects()
end
```

<a id="api-example-192"></a>

#### Player:visualPunch(tile)

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player, tile)
    return player:visualPunch(tile)
end
```

<a id="api-example-193"></a>

#### Player:visualBuild(tile)

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player, tile)
    return player:visualBuild(tile)
end
```

<a id="api-example-194"></a>

#### Player:getLastOnline()

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `number`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player)
    return player:getLastOnline()
end
```

<a id="api-example-195"></a>

#### Player:earnAchievement(type)

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player, type)
    return player:earnAchievement(type)
end
```

<a id="api-example-196"></a>

#### Player:getAchievements()

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `{any}`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player)
    return player:getAchievements()
end
```

<a id="api-example-197"></a>

#### Player:getActivePet()

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `any`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player)
    return player:getActivePet()
end
```

<a id="api-example-198"></a>

#### Player:getEffects()

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `any`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player)
    return player:getEffects()
end
```

<a id="api-example-199"></a>

#### Player:setEffects(effects)

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player, effects)
    return player:setEffects(effects)
end
```

<a id="api-example-200"></a>

#### Player:deleteEffects()

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player)
    return player:deleteEffects()
end
```

<a id="api-example-201"></a>

#### Player:getOverlappingTiles()

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `{Tile}`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player)
    return player:getOverlappingTiles()
end
```

<a id="api-example-202"></a>

#### Player:setLegendaryWizardTask(currentTaskNum)

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player, currentTaskNum)
    return player:setLegendaryWizardTask(currentTaskNum)
end
```

<a id="api-example-203"></a>

#### Player:hasAccessToTile(tile, itemID, isSilent, ignoreReach)

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `boolean`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player, tile, itemID, isSilent, ignoreReach)
    return player:hasAccessToTile(tile, itemID, isSilent, ignoreReach)
end
```

<a id="api-example-204"></a>

#### Player:isPublicTile(tile)

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `boolean`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player, tile)
    return player:isPublicTile(tile)
end
```

<a id="api-example-205"></a>

#### Player:getState()

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `number`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player)
    return player:getState()
end
```

<a id="api-example-206"></a>

#### Player:hasRoleFlag(flag)

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `boolean`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player, flag)
    return player:hasRoleFlag(flag)
end
```

<a id="api-example-207"></a>

#### Player:moveToTile(tile)

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `boolean`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player, tile)
    return player:moveToTile(tile)
end
```

<a id="api-example-208"></a>

#### Player:moveToPos(x, y)

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `boolean`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player, x, y)
    return player:moveToPos(x, y)
end
```

<a id="api-example-209"></a>

#### Player:isMoving()

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `boolean`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player)
    return player:isMoving()
end
```

<a id="api-example-210"></a>

#### Player:getMovementError()

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `string?`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player)
    return player:getMovementError()
end
```

<a id="api-example-211"></a>

#### Player:setLifeGoalQuestProgress(taskID, value)

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player, taskID, value)
    return player:setLifeGoalQuestProgress(taskID, value)
end
```

<a id="api-example-212"></a>

#### Player:setBiweeklyQuestProgress(taskID, value)

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player, taskID, value)
    return player:setBiweeklyQuestProgress(taskID, value)
end
```

<a id="api-example-213"></a>

#### Player:triggerFindGeiger()

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player)
    return player:triggerFindGeiger()
end
```

<a id="api-example-214"></a>

#### Player:setFishingWaitTime(time)

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player, time)
    return player:setFishingWaitTime(time)
end
```

<a id="api-example-215"></a>

#### Player:setSkinColor(r, g, b, a)

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player, r, g, b, a)
    return player:setSkinColor(r, g, b, a)
end
```

<a id="api-example-216"></a>

#### Player:createGuild(guildName, guildStatement)

`player` adalah instance `Player` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player, guildName, guildStatement)
    return player:createGuild(guildName, guildStatement)
end
```

---

<a id="examples-world"></a>

### World

Referensi: [World](https://dash.gtps.cloud/docs/world).

<a id="api-example-217"></a>

#### World:getName()

`world` adalah instance `World` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `string`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(world)
    return world:getName()
end
```

<a id="api-example-218"></a>

#### World:getOwner()

`world` adalah instance `World` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `Player`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(world)
    return world:getOwner()
end
```

<a id="api-example-219"></a>

#### World:setOwner(user_id)

`world` adalah instance `World` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(world, user_id)
    return world:setOwner(user_id)
end
```

<a id="api-example-220"></a>

#### World:removeOwner()

`world` adalah instance `World` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(world)
    return world:removeOwner()
end
```

<a id="api-example-221"></a>

#### World:addPunishment(player, type, expiresAt, reason, invoker_id)

`world` adalah instance `World` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(world, player, type, expiresAt, reason, invoker_id)
    return world:addPunishment(player, type, expiresAt, reason, invoker_id)
end
```

<a id="api-example-222"></a>

#### World:removePunishment(player, type)

`world` adalah instance `World` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(world, player, type)
    return world:removePunishment(player, type)
end
```

<a id="api-example-223"></a>

#### World:getPunishment(player, type)

`world` adalah instance `World` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `any`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(world, player, type)
    return world:getPunishment(player, type)
end
```

<a id="api-example-224"></a>

#### World:getAllPunishments()

`world` adalah instance `World` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `{any}`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(world)
    return world:getAllPunishments()
end
```

<a id="api-example-225"></a>

#### World:getID()

`world` adalah instance `World` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `number`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(world)
    return world:getID()
end
```

<a id="api-example-226"></a>

#### World:getTile(x, y)

`world` adalah instance `World` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `Tile`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(world, x, y)
    return world:getTile(x, y)
end
```

<a id="api-example-227"></a>

#### World:spawnItem(x, y, itemID, itemCount, center_item)

`world` adalah instance `World` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `Drop?`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(world, x, y, itemID, itemCount, center_item)
    return world:spawnItem(x, y, itemID, itemCount, center_item)
end
```

<a id="api-example-228"></a>

#### World:spawnGems(x, y, gemsCount, player)

`world` adalah instance `World` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(world, x, y, gemsCount, player)
    return world:spawnGems(x, y, gemsCount, player)
end
```

<a id="api-example-229"></a>

#### World:adjustGems(player, tile, gemsCount, showParticles)

`world` adalah instance `World` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `number`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(world, player, tile, gemsCount, showParticles)
    return world:adjustGems(player, tile, gemsCount, showParticles)
end
```

<a id="api-example-230"></a>

#### World:onLoot(player, tile, gemsCount)

`world` adalah instance `World` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(world, player, tile, gemsCount)
    return world:onLoot(player, tile, gemsCount)
end
```

<a id="api-example-231"></a>

#### World:useItemEffect(netID, itemID, secondNetID, effectDelay)

`world` adalah instance `World` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(world, netID, itemID, secondNetID, effectDelay)
    return world:useItemEffect(netID, itemID, secondNetID, effectDelay)
end
```

<a id="api-example-232"></a>

#### World:useItemTileEffect(tile, netID, itemID, reverse, effectDelay)

`world` adalah instance `World` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(world, tile, netID, itemID, reverse, effectDelay)
    return world:useItemTileEffect(tile, netID, itemID, reverse, effectDelay)
end
```

<a id="api-example-233"></a>

#### World:getPlayers()

`world` adalah instance `World` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `{Player}`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(world)
    return world:getPlayers()
end
```

<a id="api-example-234"></a>

#### World:getPlayersCount(show_all)

`world` adalah instance `World` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `number`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(world, show_all)
    return world:getPlayersCount(show_all)
end
```

<a id="api-example-235"></a>

#### World:getVisiblePlayersCount()

`world` adalah instance `World` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `number`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(world)
    return world:getVisiblePlayersCount()
end
```

<a id="api-example-236"></a>

#### World:isGameActive()

`world` adalah instance `World` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `boolean`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(world)
    return world:isGameActive()
end
```

<a id="api-example-237"></a>

#### World:onGameWinHighestScore()

`world` adalah instance `World` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(world)
    return world:onGameWinHighestScore()
end
```

<a id="api-example-238"></a>

#### World:updateClothing(player)

`world` adalah instance `World` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(world, player)
    return world:updateClothing(player)
end
```

<a id="api-example-239"></a>

#### World:onCreateChatBubble(posX, posY, message, persistMessage)

`world` adalah instance `World` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(world, posX, posY, message, persistMessage)
    return world:onCreateChatBubble(posX, posY, message, persistMessage)
end
```

<a id="api-example-240"></a>

#### World:onCreateExplosion(posX, posY, radius, power)

`world` adalah instance `World` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(world, posX, posY, radius, power)
    return world:onCreateExplosion(posX, posY, radius, power)
end
```

<a id="api-example-241"></a>

#### World:setTileForeground(tile, id, visual_update, player)

`world` adalah instance `World` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(world, tile, id, visual_update, player)
    return world:setTileForeground(tile, id, visual_update, player)
end
```

<a id="api-example-242"></a>

#### World:setTileBackground(tile, id, visual_update, player)

`world` adalah instance `World` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(world, tile, id, visual_update, player)
    return world:setTileBackground(tile, id, visual_update, player)
end
```

<a id="api-example-243"></a>

#### World:getWorldSizeX()

`world` adalah instance `World` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `number`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(world)
    return world:getWorldSizeX()
end
```

<a id="api-example-244"></a>

#### World:getWorldSizeY()

`world` adalah instance `World` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `number`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(world)
    return world:getWorldSizeY()
end
```

<a id="api-example-245"></a>

#### World:getWorldType()

`world` adalah instance `World` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `number`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(world)
    return world:getWorldType()
end
```

<a id="api-example-246"></a>

#### World:getTiles()

`world` adalah instance `World` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `{Tile}`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(world)
    return world:getTiles()
end
```

<a id="api-example-247"></a>

#### World:getEmptyTiles()

`world` adalah instance `World` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `{Tile}`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(world)
    return world:getEmptyTiles()
end
```

<a id="api-example-248"></a>

#### World:getNoCollisionTiles()

`world` adalah instance `World` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `{Tile}`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(world)
    return world:getNoCollisionTiles()
end
```

<a id="api-example-249"></a>

#### World:getDroppedItems()

`world` adalah instance `World` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `{Drop}`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(world)
    return world:getDroppedItems()
end
```

<a id="api-example-250"></a>

#### World:getTileDroppedItems(tile)

`world` adalah instance `World` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `{Drop}`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(world, tile)
    return world:getTileDroppedItems(tile)
end
```

<a id="api-example-251"></a>

#### World:addXP(player, xp_amount)

`world` adalah instance `World` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(world, player, xp_amount)
    return world:addXP(player, xp_amount)
end
```

<a id="api-example-252"></a>

#### World:setPlayerPosition(player, x, y, no_packet)

`world` adalah instance `World` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(world, player, x, y, no_packet)
    return world:setPlayerPosition(player, x, y, no_packet)
end
```

<a id="api-example-253"></a>

#### World:removeDroppedItem(uid)

`world` adalah instance `World` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(world, uid)
    return world:removeDroppedItem(uid)
end
```

<a id="api-example-254"></a>

#### World:removeDroppedItemsByID(id)

`world` adalah instance `World` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(world, id)
    return world:removeDroppedItemsByID(id)
end
```

<a id="api-example-255"></a>

#### World:removeAllDroppedItems()

`world` adalah instance `World` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(world)
    return world:removeAllDroppedItems()
end
```

<a id="api-example-256"></a>

#### World:updateTile(tile, player)

`world` adalah instance `World` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(world, tile, player)
    return world:updateTile(tile, player)
end
```

<a id="api-example-257"></a>

#### World:sendPlayerMessage(player, message)

`world` adalah instance `World` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(world, player, message)
    return world:sendPlayerMessage(player, message)
end
```

<a id="api-example-258"></a>

#### World:punchTile(tile, player)

`world` adalah instance `World` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(world, tile, player)
    return world:punchTile(tile, player)
end
```

<a id="api-example-259"></a>

#### World:placeTile(tile, id, player)

`world` adalah instance `World` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(world, tile, id, player)
    return world:placeTile(tile, id, player)
end
```

<a id="api-example-260"></a>

#### World:hasTileAccess(player, tile)

`world` adalah instance `World` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `boolean`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(world, player, tile)
    return world:hasTileAccess(player, tile)
end
```

<a id="api-example-261"></a>

#### World:hasAccess(player)

`world` adalah instance `World` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `boolean`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(world, player)
    return world:hasAccess(player)
end
```

<a id="api-example-262"></a>

#### World:addTileAccess(player, tile)

`world` adalah instance `World` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(world, player, tile)
    return world:addTileAccess(player, tile)
end
```

<a id="api-example-263"></a>

#### World:addAccess(player, admin_type)

`world` adalah instance `World` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(world, player, admin_type)
    return world:addAccess(player, admin_type)
end
```

<a id="api-example-264"></a>

#### World:removeTileAccess(player, tile)

`world` adalah instance `World` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(world, player, tile)
    return world:removeTileAccess(player, tile)
end
```

<a id="api-example-265"></a>

#### World:removeAllTileAccess()

`world` adalah instance `World` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(world)
    return world:removeAllTileAccess()
end
```

<a id="api-example-266"></a>

#### World:removeAccess(player)

`world` adalah instance `World` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(world, player)
    return world:removeAccess(player)
end
```

<a id="api-example-267"></a>

#### World:kill(player, force_respawn_on_white_door)

`world` adalah instance `World` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(world, player, force_respawn_on_white_door)
    return world:kill(player, force_respawn_on_white_door)
end
```

<a id="api-example-268"></a>

#### World:setClothing(player, item_id)

`world` adalah instance `World` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(world, player, item_id)
    return world:setClothing(player, item_id)
end
```

<a id="api-example-269"></a>

#### World:createNPC(name, x, y)

`world` adalah instance `World` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `Player`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(world, name, x, y)
    return world:createNPC(name, x, y)
end
```

<a id="api-example-270"></a>

#### World:removeNPC(player)

`world` adalah instance `World` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(world, player)
    return world:removeNPC(player)
end
```

<a id="api-example-271"></a>

#### World:findNPCByName(name)

`world` adalah instance `World` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `{Player}`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(world, name)
    return world:findNPCByName(name)
end
```

<a id="api-example-272"></a>

#### World:getAllNPC()

`world` adalah instance `World` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `{Player}`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(world)
    return world:getAllNPC()
end
```

<a id="api-example-273"></a>

#### World:redeemCode(player, code)

`world` adalah instance `World` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(world, player, code)
    return world:redeemCode(player, code)
end
```

<a id="api-example-274"></a>

#### World:setWeather(weatherID)

`world` adalah instance `World` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(world, weatherID)
    return world:setWeather(weatherID)
end
```

<a id="api-example-275"></a>

#### World:getWorldLock()

`world` adalah instance `World` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `Tile`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(world)
    return world:getWorldLock()
end
```

<a id="api-example-276"></a>

#### World:getMagplantRemoteTile(player)

`world` adalah instance `World` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `Tile`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(world, player)
    return world:getMagplantRemoteTile(player)
end
```

<a id="api-example-277"></a>

#### World:setMagplantRemoteTile(player, tile)

`world` adalah instance `World` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(world, player, tile)
    return world:setMagplantRemoteTile(player, tile)
end
```

<a id="api-example-278"></a>

#### World:hasFlag(flag)

`world` adalah instance `World` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `boolean`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(world, flag)
    return world:hasFlag(flag)
end
```

<a id="api-example-279"></a>

#### World:addFlag(flag)

`world` adalah instance `World` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(world, flag)
    return world:addFlag(flag)
end
```

<a id="api-example-280"></a>

#### World:useConsumable(player, tile, id, noCallback)

`world` adalah instance `World` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(world, player, tile, id, noCallback)
    return world:useConsumable(player, tile, id, noCallback)
end
```

<a id="api-example-281"></a>

#### World:spawnGhost(tile, id, sb, wd, sp)

`world` adalah instance `World` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(world, tile, id, sb, wd, sp)
    return world:spawnGhost(tile, id, sb, wd, sp)
end
```

<a id="api-example-282"></a>

#### World:findPathByTile(tile_1, tile_2, max_rad_x, max_rad_y)

`world` adalah instance `World` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `{any}`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(world, tile_1, tile_2, max_rad_x, max_rad_y)
    return world:findPathByTile(tile_1, tile_2, max_rad_x, max_rad_y)
end
```

<a id="api-example-283"></a>

#### World:isNuked()

`world` adalah instance `World` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `boolean`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(world)
    return world:isNuked()
end
```

<a id="api-example-284"></a>

#### World:nuke(ownerBanTime, adminsBanTime, everyoneElseBanTime)

`world` adalah instance `World` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(world, ownerBanTime, adminsBanTime, everyoneElseBanTime)
    return world:nuke(ownerBanTime, adminsBanTime, everyoneElseBanTime)
end
```

<a id="api-example-285"></a>

#### World:removeNuke(unbanBannedUsers)

`world` adalah instance `World` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(world, unbanBannedUsers)
    return world:removeNuke(unbanBannedUsers)
end
```

<a id="api-example-286"></a>

#### World:getGuildID()

`world` adalah instance `World` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `number`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(world)
    return world:getGuildID()
end
```

<a id="api-example-287"></a>

#### World:getMachineCap(item_id)

`world` adalah instance `World` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `number`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(world, item_id)
    return world:getMachineCap(item_id)
end
```

<a id="api-example-288"></a>

#### World:setMachineCap(item_id, item_count)

`world` adalah instance `World` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(world, item_id, item_count)
    return world:setMachineCap(item_id, item_count)
end
```

<a id="api-example-289"></a>

#### World:getMachineCaps()

`world` adalah instance `World` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `{any}`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(world)
    return world:getMachineCaps()
end
```

<a id="api-example-290"></a>

#### World:removeMachineCap(item_id)

`world` adalah instance `World` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(world, item_id)
    return world:removeMachineCap(item_id)
end
```

<a id="api-example-291"></a>

#### World:getEffects()

`world` adalah instance `World` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `any`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(world)
    return world:getEffects()
end
```

<a id="api-example-292"></a>

#### World:setEffects(effects)

`world` adalah instance `World` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(world, effects)
    return world:setEffects(effects)
end
```

<a id="api-example-293"></a>

#### World:deleteEffects()

`world` adalah instance `World` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(world)
    return world:deleteEffects()
end
```

<a id="api-example-294"></a>

#### World:getCached(item_id)

`world` adalah instance `World` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `{Tile}`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(world, item_id)
    return world:getCached(item_id)
end
```

<a id="api-example-295"></a>

#### World:delete()

`world` adalah instance `World` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(world)
    return world:delete()
end
```

<a id="api-example-296"></a>

#### World:save()

`world` adalah instance `World` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(world)
    return world:save()
end
```

<a id="api-example-297"></a>

#### World:new(name, sizeX, sizeY, worldType)

Membuat objek melalui constructor `World` sesuai signature sumber.

Hasil yang didokumentasikan: `World`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(name, sizeX, sizeY, worldType)
    return World:new(name, sizeX, sizeY, worldType)
end
```

<a id="api-example-298"></a>

#### World:newFromTemplate(name, templateName)

Membuat objek melalui constructor `World` sesuai signature sumber.

Hasil yang didokumentasikan: `World`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(name, templateName)
    return World:newFromTemplate(name, templateName)
end
```

<a id="api-example-299"></a>

#### World:newFromGlobalTemplate(name, templateName)

Membuat objek melalui constructor `World` sesuai signature sumber.

Hasil yang didokumentasikan: `World`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(name, templateName)
    return World:newFromGlobalTemplate(name, templateName)
end
```

<a id="api-example-300"></a>

#### World:hasAccessByType(player, adminType)

`world` adalah instance `World` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `boolean`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(world, player, adminType)
    return world:hasAccessByType(player, adminType)
end
```

<a id="api-example-301"></a>

#### World:setTileOwner(tile, userID)

`world` adalah instance `World` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(world, tile, userID)
    return world:setTileOwner(tile, userID)
end
```

<a id="api-example-302"></a>

#### World:export()

`world` adalah instance `World` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(world)
    return world:export()
end
```

<a id="api-example-303"></a>

#### World:import(importName)

`world` adalah instance `World` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(world, importName)
    return world:import(importName)
end
```

---

<a id="examples-tile"></a>

### Tile

Referensi: [Tile](https://dash.gtps.cloud/docs/tile).

<a id="api-example-304"></a>

#### Tile:getTileID()

`tile` adalah instance `Tile` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `number`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(tile)
    return tile:getTileID()
end
```

<a id="api-example-305"></a>

#### Tile:getTileItem()

`tile` adalah instance `Tile` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `Item`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(tile)
    return tile:getTileItem()
end
```

<a id="api-example-306"></a>

#### Tile:getLastPunched()

`tile` adalah instance `Tile` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `number`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(tile)
    return tile:getLastPunched()
end
```

<a id="api-example-307"></a>

#### Tile:getPosX()

`tile` adalah instance `Tile` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `number`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(tile)
    return tile:getPosX()
end
```

<a id="api-example-308"></a>

#### Tile:getPosY()

`tile` adalah instance `Tile` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `number`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(tile)
    return tile:getPosY()
end
```

<a id="api-example-309"></a>

#### Tile:getNote()

`tile` adalah instance `Tile` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `string`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(tile)
    return tile:getNote()
end
```

<a id="api-example-310"></a>

#### Tile:getTileForeground()

`tile` adalah instance `Tile` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `number`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(tile)
    return tile:getTileForeground()
end
```

<a id="api-example-311"></a>

#### Tile:getTileBackground()

`tile` adalah instance `Tile` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `number`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(tile)
    return tile:getTileBackground()
end
```

<a id="api-example-312"></a>

#### Tile:getTileData(data_type)

`tile` adalah instance `Tile` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `any`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(tile, data_type)
    return tile:getTileData(data_type)
end
```

<a id="api-example-313"></a>

#### Tile:setTileData(data_type, data_value)

`tile` adalah instance `Tile` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(tile, data_type, data_value)
    return tile:setTileData(data_type, data_value)
end
```

<a id="api-example-314"></a>

#### Tile:setTileDataInt(data_type, data_value)

`tile` adalah instance `Tile` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(tile, data_type, data_value)
    return tile:setTileDataInt(data_type, data_value)
end
```

<a id="api-example-315"></a>

#### Tile:getFlags()

`tile` adalah instance `Tile` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `number`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(tile)
    return tile:getFlags()
end
```

<a id="api-example-316"></a>

#### Tile:setFlags(flags)

`tile` adalah instance `Tile` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(tile, flags)
    return tile:setFlags(flags)
end
```

---

<a id="examples-item"></a>

### Item

Referensi: [Item](https://dash.gtps.cloud/docs/item).

<a id="api-example-317"></a>

#### Item:getPlaymods()

`item` adalah instance `Item` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `{any}`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(item)
    return item:getPlaymods()
end
```

<a id="api-example-318"></a>

#### Item:getName()

`item` adalah instance `Item` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `string`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(item)
    return item:getName()
end
```

<a id="api-example-319"></a>

#### Item:setName(value)

`item` adalah instance `Item` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(item, value)
    return item:setName(value)
end
```

<a id="api-example-320"></a>

#### Item:getDescription()

`item` adalah instance `Item` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `string`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(item)
    return item:getDescription()
end
```

<a id="api-example-321"></a>

#### Item:getID()

`item` adalah instance `Item` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `number`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(item)
    return item:getID()
end
```

<a id="api-example-322"></a>

#### Item:getPrice()

`item` adalah instance `Item` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `number`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(item)
    return item:getPrice()
end
```

<a id="api-example-323"></a>

#### Item:setPrice(newPrice)

`item` adalah instance `Item` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(item, newPrice)
    return item:setPrice(newPrice)
end
```

<a id="api-example-324"></a>

#### Item:isObtainable()

`item` adalah instance `Item` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `boolean`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(item)
    return item:isObtainable()
end
```

<a id="api-example-325"></a>

#### Item:getInfo()

`item` adalah instance `Item` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `{string}`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(item)
    return item:getInfo()
end
```

<a id="api-example-326"></a>

#### Item:getActionType()

`item` adalah instance `Item` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `number`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(item)
    return item:getActionType()
end
```

<a id="api-example-327"></a>

#### Item:getRarity()

`item` adalah instance `Item` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `number`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(item)
    return item:getRarity()
end
```

<a id="api-example-328"></a>

#### Item:getGems(world, player)

`item` adalah instance `Item` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `number`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(item, world, player)
    return item:getGems(world, player)
end
```

<a id="api-example-329"></a>

#### Item:getXP(world, player)

`item` adalah instance `Item` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `number`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(item, world, player)
    return item:getXP(world, player)
end
```

<a id="api-example-330"></a>

#### Item:getGrowTime()

`item` adalah instance `Item` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `number`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(item)
    return item:getGrowTime()
end
```

<a id="api-example-331"></a>

#### Item:getCategoryType()

`item` adalah instance `Item` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `number`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(item)
    return item:getCategoryType()
end
```

<a id="api-example-332"></a>

#### Item:getEditableType()

`item` adalah instance `Item` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `number`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(item)
    return item:getEditableType()
end
```

<a id="api-example-333"></a>

#### Item:setCategoryType(value)

`item` adalah instance `Item` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(item, value)
    return item:setCategoryType(value)
end
```

<a id="api-example-334"></a>

#### Item:setEditableType(value)

`item` adalah instance `Item` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(item, value)
    return item:setEditableType(value)
end
```

<a id="api-example-335"></a>

#### Item:setGrowTime(value)

`item` adalah instance `Item` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(item, value)
    return item:setGrowTime(value)
end
```

<a id="api-example-336"></a>

#### Item:setActionType(value)

`item` adalah instance `Item` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(item, value)
    return item:setActionType(value)
end
```

<a id="api-example-337"></a>

#### Item:setDescription(value)

`item` adalah instance `Item` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(item, value)
    return item:setDescription(value)
end
```

<a id="api-example-338"></a>

#### Item:getTexture()

`item` adalah instance `Item` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `string`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(item)
    return item:getTexture()
end
```

<a id="api-example-339"></a>

#### Item:getTextureHash()

`item` adalah instance `Item` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `number`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(item)
    return item:getTextureHash()
end
```

<a id="api-example-340"></a>

#### Item:setTextureHash(hash)

`item` adalah instance `Item` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(item, hash)
    return item:setTextureHash(hash)
end
```

<a id="api-example-341"></a>

#### Item:getTextureX()

`item` adalah instance `Item` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `number`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(item)
    return item:getTextureX()
end
```

<a id="api-example-342"></a>

#### Item:getTextureY()

`item` adalah instance `Item` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `number`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(item)
    return item:getTextureY()
end
```

<a id="api-example-343"></a>

#### Item:setTexture(value)

`item` adalah instance `Item` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(item, value)
    return item:setTexture(value)
end
```

<a id="api-example-344"></a>

#### Item:setTextureX(x)

`item` adalah instance `Item` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(item, x)
    return item:setTextureX(x)
end
```

<a id="api-example-345"></a>

#### Item:setTextureY(y)

`item` adalah instance `Item` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(item, y)
    return item:setTextureY(y)
end
```

<a id="api-example-346"></a>

#### Item:getClothingType()

`item` adalah instance `Item` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `number`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(item)
    return item:getClothingType()
end
```

<a id="api-example-347"></a>

#### Item:setClothingType(value)

`item` adalah instance `Item` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(item, value)
    return item:setClothingType(value)
end
```

<a id="api-example-348"></a>

#### Item:getPricedRarity()

`item` adalah instance `Item` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `number`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(item)
    return item:getPricedRarity()
end
```

<a id="api-example-349"></a>

#### Item:getEffects()

`item` adalah instance `Item` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `any`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(item)
    return item:getEffects()
end
```

<a id="api-example-350"></a>

#### Item:setEffects(effects)

`item` adalah instance `Item` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(item, effects)
    return item:setEffects(effects)
end
```

<a id="api-example-351"></a>

#### Item:deleteEffects()

`item` adalah instance `Item` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(item)
    return item:deleteEffects()
end
```

<a id="api-example-352"></a>

#### Item:getObtainability()

`item` adalah instance `Item` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `string`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(item)
    return item:getObtainability()
end
```

<a id="api-example-353"></a>

#### Item:getMachineCap()

`item` adalah instance `Item` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `number`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(item)
    return item:getMachineCap()
end
```

<a id="api-example-354"></a>

#### Item:setMachineCap(value)

`item` adalah instance `Item` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(item, value)
    return item:setMachineCap(value)
end
```

<a id="api-example-355"></a>

#### Item:removeMachineCap()

`item` adalah instance `Item` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(item)
    return item:removeMachineCap()
end
```

<a id="api-example-356"></a>

#### Item:getFarmability()

`item` adalah instance `Item` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `boolean`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(item)
    return item:getFarmability()
end
```

<a id="api-example-357"></a>

#### Item:setFarmability(value)

`item` adalah instance `Item` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(item, value)
    return item:setFarmability(value)
end
```

<a id="api-example-358"></a>

#### Item:getMaxFruitDropCount()

`item` adalah instance `Item` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `number`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(item)
    return item:getMaxFruitDropCount()
end
```

<a id="api-example-359"></a>

#### Item:getMinFruitDropCount()

`item` adalah instance `Item` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `number`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(item)
    return item:getMinFruitDropCount()
end
```

<a id="api-example-360"></a>

#### Item:getSpreadType()

`item` adalah instance `Item` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `number`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(item)
    return item:getSpreadType()
end
```

<a id="api-example-361"></a>

#### Item:setSpreadType(value)

`item` adalah instance `Item` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(item, value)
    return item:setSpreadType(value)
end
```

<a id="api-example-362"></a>

#### Item:getCollisionType()

`item` adalah instance `Item` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `number`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(item)
    return item:getCollisionType()
end
```

<a id="api-example-363"></a>

#### Item:setCollisionType(value)

`item` adalah instance `Item` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(item, value)
    return item:setCollisionType(value)
end
```

<a id="api-example-364"></a>

#### Item:getKindType()

`item` adalah instance `Item` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `number`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(item)
    return item:getKindType()
end
```

<a id="api-example-365"></a>

#### Item:setKindType(value)

`item` adalah instance `Item` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(item, value)
    return item:setKindType(value)
end
```

<a id="api-example-366"></a>

#### Item:getChi()

`item` adalah instance `Item` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `number`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(item)
    return item:getChi()
end
```

---

<a id="examples-iotm"></a>

### IOTM

Referensi: [IOTM](https://dash.gtps.cloud/docs/iotm).

<a id="api-example-367"></a>

#### IOTM:getID()

`iotm` adalah instance `IOTM` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `number`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(iotm)
    return iotm:getID()
end
```

<a id="api-example-368"></a>

#### IOTM:getAmount()

`iotm` adalah instance `IOTM` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `number`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(iotm)
    return iotm:getAmount()
end
```

<a id="api-example-369"></a>

#### IOTM:setAmount(newAmount)

`iotm` adalah instance `IOTM` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(iotm, newAmount)
    return iotm:setAmount(newAmount)
end
```

---

<a id="examples-guild"></a>

### Guild

Referensi: [Guild](https://dash.gtps.cloud/docs/guild).

<a id="api-example-370"></a>

#### Guild:getTitle()

`guild` adalah instance `Guild` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `string`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(guild)
    return guild:getTitle()
end
```

<a id="api-example-371"></a>

#### Guild:getDescription()

`guild` adalah instance `Guild` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `string`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(guild)
    return guild:getDescription()
end
```

<a id="api-example-372"></a>

#### Guild:getNotebook()

`guild` adalah instance `Guild` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `string`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(guild)
    return guild:getNotebook()
end
```

<a id="api-example-373"></a>

#### Guild:getID()

`guild` adalah instance `Guild` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `number`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(guild)
    return guild:getID()
end
```

<a id="api-example-374"></a>

#### Guild:getWorldID()

`guild` adalah instance `Guild` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `number`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(guild)
    return guild:getWorldID()
end
```

<a id="api-example-375"></a>

#### Guild:getXP()

`guild` adalah instance `Guild` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `number`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(guild)
    return guild:getXP()
end
```

<a id="api-example-376"></a>

#### Guild:getLevel()

`guild` adalah instance `Guild` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `number`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(guild)
    return guild:getLevel()
end
```

<a id="api-example-377"></a>

#### Guild:getPoints()

`guild` adalah instance `Guild` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `number`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(guild)
    return guild:getPoints()
end
```

<a id="api-example-378"></a>

#### Guild:getSettings()

`guild` adalah instance `Guild` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `number`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(guild)
    return guild:getSettings()
end
```

<a id="api-example-379"></a>

#### Guild:getCreatedDate()

`guild` adalah instance `Guild` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `number`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(guild)
    return guild:getCreatedDate()
end
```

<a id="api-example-380"></a>

#### Guild:getMascotForegroundID()

`guild` adalah instance `Guild` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `number`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(guild)
    return guild:getMascotForegroundID()
end
```

<a id="api-example-381"></a>

#### Guild:getMascotBackgroundID()

`guild` adalah instance `Guild` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `number`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(guild)
    return guild:getMascotBackgroundID()
end
```

<a id="api-example-382"></a>

#### Guild:getDisplayGuildMascot()

`guild` adalah instance `Guild` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `number`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(guild)
    return guild:getDisplayGuildMascot()
end
```

<a id="api-example-383"></a>

#### Guild:getOnlinePlayers()

`guild` adalah instance `Guild` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `{Player}`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(guild)
    return guild:getOnlinePlayers()
end
```

<a id="api-example-384"></a>

#### Guild:setXP(xp)

`guild` adalah instance `Guild` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(guild, xp)
    return guild:setXP(xp)
end
```

<a id="api-example-385"></a>

#### Guild:addXP(xp)

`guild` adalah instance `Guild` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(guild, xp)
    return guild:addXP(xp)
end
```

<a id="api-example-386"></a>

#### Guild:setLevel(level)

`guild` adalah instance `Guild` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(guild, level)
    return guild:setLevel(level)
end
```

---

<a id="examples-shop-item"></a>

### ShopItem

Referensi: [ShopItem](https://dash.gtps.cloud/docs/shop-item).

<a id="api-example-387"></a>

#### ShopItem:getCategory()

`offer` adalah instance `ShopItem` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `string`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(offer)
    return offer:getCategory()
end
```

<a id="api-example-388"></a>

#### ShopItem:getTexture()

`offer` adalah instance `ShopItem` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `string`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(offer)
    return offer:getTexture()
end
```

<a id="api-example-389"></a>

#### ShopItem:getTexturePosX()

`offer` adalah instance `ShopItem` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `number`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(offer)
    return offer:getTexturePosX()
end
```

<a id="api-example-390"></a>

#### ShopItem:getTexturePosY()

`offer` adalah instance `ShopItem` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `number`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(offer)
    return offer:getTexturePosY()
end
```

<a id="api-example-391"></a>

#### ShopItem:getItemID()

`offer` adalah instance `ShopItem` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `number`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(offer)
    return offer:getItemID()
end
```

<a id="api-example-392"></a>

#### ShopItem:getTitle()

`offer` adalah instance `ShopItem` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `string`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(offer)
    return offer:getTitle()
end
```

<a id="api-example-393"></a>

#### ShopItem:getDescription()

`offer` adalah instance `ShopItem` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `string`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(offer)
    return offer:getDescription()
end
```

<a id="api-example-394"></a>

#### ShopItem:getPrice()

`offer` adalah instance `ShopItem` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `number`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(offer)
    return offer:getPrice()
end
```

<a id="api-example-395"></a>

#### ShopItem:isRPC()

`offer` adalah instance `ShopItem` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `boolean`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(offer)
    return offer:isRPC()
end
```

<a id="api-example-396"></a>

#### ShopItem:isGrowtoken()

`offer` adalah instance `ShopItem` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `boolean`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(offer)
    return offer:isGrowtoken()
end
```

<a id="api-example-397"></a>

#### ShopItem:isVoucher()

`offer` adalah instance `ShopItem` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `boolean`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(offer)
    return offer:isVoucher()
end
```

<a id="api-example-398"></a>

#### ShopItem:getRequiredEvent()

`offer` adalah instance `ShopItem` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `number`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(offer)
    return offer:getRequiredEvent()
end
```

<a id="api-example-399"></a>

#### ShopItem:getItemsDescription()

`offer` adalah instance `ShopItem` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `string`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(offer)
    return offer:getItemsDescription()
end
```

<a id="api-example-400"></a>

#### ShopItem:getItems()

`offer` adalah instance `ShopItem` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `{any}`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(offer)
    return offer:getItems()
end
```

<a id="api-example-401"></a>

#### ShopItem:makePurchaseItems(Count)

`offer` adalah instance `ShopItem` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `{any}`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(offer, Count)
    return offer:makePurchaseItems(Count)
end
```

<a id="api-example-402"></a>

#### ShopItem:getRollAmount()

`offer` adalah instance `ShopItem` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `number`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(offer)
    return offer:getRollAmount()
end
```

<a id="api-example-403"></a>

#### ShopItem:isRandom()

`offer` adalah instance `ShopItem` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `boolean`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(offer)
    return offer:isRandom()
end
```

---

<a id="examples-growtopia-bot"></a>

### GrowtopiaBot

Referensi: [GrowtopiaBot](https://dash.gtps.cloud/docs/growtopia-bot).

<a id="api-example-404"></a>

#### GrowtopiaBot:start()

`bot` adalah instance `GrowtopiaBot` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(bot)
    return bot:start()
end
```

<a id="api-example-405"></a>

#### GrowtopiaBot:onReceiveVariantCallback(callback)

`bot` adalah instance `GrowtopiaBot` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(bot, callback)
    return bot:onReceiveVariantCallback(callback)
end
```

<a id="api-example-406"></a>

#### GrowtopiaBot:onReceiveTextCallback(callback)

`bot` adalah instance `GrowtopiaBot` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(bot, callback)
    return bot:onReceiveTextCallback(callback)
end
```

<a id="api-example-407"></a>

#### GrowtopiaBot:onReceiveRawCallback(callback)

`bot` adalah instance `GrowtopiaBot` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(bot, callback)
    return bot:onReceiveRawCallback(callback)
end
```

<a id="api-example-408"></a>

#### GrowtopiaBot:onReceiveTrackCallback(callback)

`bot` adalah instance `GrowtopiaBot` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(bot, callback)
    return bot:onReceiveTrackCallback(callback)
end
```

<a id="api-example-409"></a>

#### GrowtopiaBot:sendStr(type, str)

`bot` adalah instance `GrowtopiaBot` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(bot, type, str)
    return bot:sendStr(type, str)
end
```

<a id="api-example-410"></a>

#### GrowtopiaBot:sendRaw(data)

`bot` adalah instance `GrowtopiaBot` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(bot, data)
    return bot:sendRaw(data)
end
```

<a id="api-example-411"></a>

#### GrowtopiaBot:reconnect()

`bot` adalah instance `GrowtopiaBot` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(bot)
    return bot:reconnect()
end
```

<a id="api-example-412"></a>

#### GrowtopiaBot:new(token)

Membuat objek melalui constructor `GrowtopiaBot` sesuai signature sumber.

Hasil yang didokumentasikan: `GrowtopiaBot`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(token)
    return GrowtopiaBot:new(token)
end
```

---

<a id="examples-drop"></a>

### Drop

Referensi: [Drop](https://dash.gtps.cloud/docs/drop).

<a id="api-example-413"></a>

#### Drop:getItemID()

`drop` adalah instance `Drop` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `number`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(drop)
    return drop:getItemID()
end
```

<a id="api-example-414"></a>

#### Drop:getItemCount()

`drop` adalah instance `Drop` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `number`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(drop)
    return drop:getItemCount()
end
```

<a id="api-example-415"></a>

#### Drop:getPosX()

`drop` adalah instance `Drop` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `number`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(drop)
    return drop:getPosX()
end
```

<a id="api-example-416"></a>

#### Drop:getPosY()

`drop` adalah instance `Drop` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `number`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(drop)
    return drop:getPosY()
end
```

<a id="api-example-417"></a>

#### Drop:getUID()

`drop` adalah instance `Drop` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `number`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(drop)
    return drop:getUID()
end
```

<a id="api-example-418"></a>

#### Drop:getFlags()

`drop` adalah instance `Drop` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `number`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(drop)
    return drop:getFlags()
end
```

---

<a id="examples-player-autofarm"></a>

### PlayerAutofarm

Referensi: [PlayerAutofarm](https://dash.gtps.cloud/docs/player-autofarm).

<a id="api-example-419"></a>

#### PlayerAutofarm:getTargetBlockID()

`autofarm` adalah instance `PlayerAutofarm` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `number`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(autofarm)
    return autofarm:getTargetBlockID()
end
```

<a id="api-example-420"></a>

#### PlayerAutofarm:setTargetBlockID(targetBlock)

`autofarm` adalah instance `PlayerAutofarm` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(autofarm, targetBlock)
    return autofarm:setTargetBlockID(targetBlock)
end
```

<a id="api-example-421"></a>

#### PlayerAutofarm:getNextPosX()

`autofarm` adalah instance `PlayerAutofarm` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `number`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(autofarm)
    return autofarm:getNextPosX()
end
```

<a id="api-example-422"></a>

#### PlayerAutofarm:setNextPosX(x)

`autofarm` adalah instance `PlayerAutofarm` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(autofarm, x)
    return autofarm:setNextPosX(x)
end
```

<a id="api-example-423"></a>

#### PlayerAutofarm:getNextPosY()

`autofarm` adalah instance `PlayerAutofarm` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `number`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(autofarm)
    return autofarm:getNextPosY()
end
```

<a id="api-example-424"></a>

#### PlayerAutofarm:setNextPosY(y)

`autofarm` adalah instance `PlayerAutofarm` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(autofarm, y)
    return autofarm:setNextPosY(y)
end
```

<a id="api-example-425"></a>

#### PlayerAutofarm:getDelay()

`autofarm` adalah instance `PlayerAutofarm` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `number`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(autofarm)
    return autofarm:getDelay()
end
```

<a id="api-example-426"></a>

#### PlayerAutofarm:setDelay(autofarmDelay)

`autofarm` adalah instance `PlayerAutofarm` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(autofarm, autofarmDelay)
    return autofarm:setDelay(autofarmDelay)
end
```

<a id="api-example-427"></a>

#### PlayerAutofarm:getSlots()

`autofarm` adalah instance `PlayerAutofarm` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `number`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(autofarm)
    return autofarm:getSlots()
end
```

<a id="api-example-428"></a>

#### PlayerAutofarm:setSlots(autofarmSlots)

`autofarm` adalah instance `PlayerAutofarm` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(autofarm, autofarmSlots)
    return autofarm:setSlots(autofarmSlots)
end
```

---

<a id="examples-inventory-item"></a>

### InventoryItem

Referensi: [InventoryItem](https://dash.gtps.cloud/docs/inventory-item).

<a id="api-example-429"></a>

#### InventoryItem:getItemID()

`entry` adalah instance `InventoryItem` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `number`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(entry)
    return entry:getItemID()
end
```

<a id="api-example-430"></a>

#### InventoryItem:getItemCount()

`entry` adalah instance `InventoryItem` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `number`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(entry)
    return entry:getItemCount()
end
```

---

<a id="examples-player-subscription"></a>

### PlayerSubscription

Referensi: [PlayerSubscription](https://dash.gtps.cloud/docs/player-subscription).

<a id="api-example-431"></a>

#### PlayerSubscription:getType()

`subscription` adalah instance `PlayerSubscription` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `number`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(subscription)
    return subscription:getType()
end
```

<a id="api-example-432"></a>

#### PlayerSubscription:getExpireTime()

`subscription` adalah instance `PlayerSubscription` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `number`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(subscription)
    return subscription:getExpireTime()
end
```

<a id="api-example-433"></a>

#### PlayerSubscription:getActivationTime()

`subscription` adalah instance `PlayerSubscription` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `number`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(subscription)
    return subscription:getActivationTime()
end
```

<a id="api-example-434"></a>

#### PlayerSubscription:isPermanent()

`subscription` adalah instance `PlayerSubscription` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `boolean`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(subscription)
    return subscription:isPermanent()
end
```

<a id="api-example-435"></a>

#### PlayerSubscription:getNextRewardTime()

`subscription` adalah instance `PlayerSubscription` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `number`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(subscription)
    return subscription:getNextRewardTime()
end
```

---

<a id="examples-discord-bot"></a>

### DiscordBot

Referensi: [DiscordBot](https://dash.gtps.cloud/docs/discord-bot).

<a id="api-example-436"></a>

#### DiscordBot:messageCreate(channelID, content, components, flags, type, embed, attachments)

`bot` adalah instance `DiscordBot` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `any`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(bot, channelID, content, components, flags, type, embed, attachments)
    return bot:messageCreate(channelID, content, components, flags, type, embed, attachments)
end
```

<a id="api-example-437"></a>

#### DiscordBot:directMessageCreate(userID, content, components, flags, type, embed, attachments)

`bot` adalah instance `DiscordBot` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(bot, userID, content, components, flags, type, embed, attachments)
    return bot:directMessageCreate(userID, content, components, flags, type, embed, attachments)
end
```

<a id="api-example-438"></a>

#### DiscordBot:messageDelete(messageID, channelID)

`bot` adalah instance `DiscordBot` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(bot, messageID, channelID)
    return bot:messageDelete(messageID, channelID)
end
```

<a id="api-example-439"></a>

#### DiscordBot:messageEdit(messageID, channelID, content, components, flags, type, embed)

`bot` adalah instance `DiscordBot` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(bot, messageID, channelID, content, components, flags, type, embed)
    return bot:messageEdit(messageID, channelID, content, components, flags, type, embed)
end
```

<a id="api-example-440"></a>

#### DiscordBot:globalCommandCreate(name, description, options)

`bot` adalah instance `DiscordBot` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(bot, name, description, options)
    return bot:globalCommandCreate(name, description, options)
end
```

<a id="api-example-441"></a>

#### DiscordBot:guildMemberSetNickname(guildID, userID, nick)

`bot` adalah instance `DiscordBot` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(bot, guildID, userID, nick)
    return bot:guildMemberSetNickname(guildID, userID, nick)
end
```

<a id="api-example-442"></a>

#### DiscordBot:guildMemberRemoveRole(guildID, userID, roleID)

`bot` adalah instance `DiscordBot` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(bot, guildID, userID, roleID)
    return bot:guildMemberRemoveRole(guildID, userID, roleID)
end
```

<a id="api-example-443"></a>

#### DiscordBot:guildMemberAddRole(guildID, userID, roleID)

`bot` adalah instance `DiscordBot` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(bot, guildID, userID, roleID)
    return bot:guildMemberAddRole(guildID, userID, roleID)
end
```

<a id="api-example-444"></a>

#### DiscordBot:guildMemberGetRoles(guildID, userID, callback)

`bot` adalah instance `DiscordBot` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(bot, guildID, userID, callback)
    return bot:guildMemberGetRoles(guildID, userID, callback)
end
```

<a id="api-example-445"></a>

#### DiscordBot:channelCreate(guildID, options)

`bot` adalah instance `DiscordBot` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `any`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(bot, guildID, options)
    return bot:channelCreate(guildID, options)
end
```

<a id="api-example-446"></a>

#### DiscordBot:channelEdit(channelID, options)

`bot` adalah instance `DiscordBot` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `any`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(bot, channelID, options)
    return bot:channelEdit(channelID, options)
end
```

<a id="api-example-447"></a>

#### DiscordBot:channelDelete(channelID)

`bot` adalah instance `DiscordBot` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `any`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(bot, channelID)
    return bot:channelDelete(channelID)
end
```

<a id="api-example-448"></a>

#### DiscordBot:channelGet(channelID)

`bot` adalah instance `DiscordBot` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `any`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(bot, channelID)
    return bot:channelGet(channelID)
end
```

<a id="api-example-449"></a>

#### DiscordBot:guildGetChannels(guildID)

`bot` adalah instance `DiscordBot` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `any`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(bot, guildID)
    return bot:guildGetChannels(guildID)
end
```

<a id="api-example-450"></a>

#### DiscordBot:messagePin(messageID, channelID)

`bot` adalah instance `DiscordBot` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `any`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(bot, messageID, channelID)
    return bot:messagePin(messageID, channelID)
end
```

<a id="api-example-451"></a>

#### DiscordBot:messageUnpin(messageID, channelID)

`bot` adalah instance `DiscordBot` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `any`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(bot, messageID, channelID)
    return bot:messageUnpin(messageID, channelID)
end
```

<a id="api-example-452"></a>

#### DiscordBot:messageAddReaction(messageID, channelID, emoji)

`bot` adalah instance `DiscordBot` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `any`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(bot, messageID, channelID, emoji)
    return bot:messageAddReaction(messageID, channelID, emoji)
end
```

---

<a id="examples-discord-button-click-event"></a>

### DiscordButtonClickEvent

Referensi: [DiscordButtonClickEvent](https://dash.gtps.cloud/docs/discord-button-click-event).

<a id="api-example-453"></a>

#### DiscordButtonClickEvent:getCustomID()

`event` adalah instance `DiscordButtonClickEvent` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `string`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(event)
    return event:getCustomID()
end
```

<a id="api-example-454"></a>

#### DiscordButtonClickEvent:getPlayer()

`event` adalah instance `DiscordButtonClickEvent` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `Player`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(event)
    return event:getPlayer()
end
```

<a id="api-example-455"></a>

#### DiscordButtonClickEvent:getChannelID()

`event` adalah instance `DiscordButtonClickEvent` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `string`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(event)
    return event:getChannelID()
end
```

<a id="api-example-456"></a>

#### DiscordButtonClickEvent:getAuthorID()

`event` adalah instance `DiscordButtonClickEvent` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `string`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(event)
    return event:getAuthorID()
end
```

<a id="api-example-457"></a>

#### DiscordButtonClickEvent:reply(content, components, flags, embed, attachments)

`event` adalah instance `DiscordButtonClickEvent` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(event, content, components, flags, embed, attachments)
    return event:reply(content, components, flags, embed, attachments)
end
```

<a id="api-example-458"></a>

#### DiscordButtonClickEvent:dialog(modal)

`event` adalah instance `DiscordButtonClickEvent` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(event, modal)
    return event:dialog(modal)
end
```

<a id="api-example-459"></a>

#### DiscordButtonClickEvent:getMessageID()

`event` adalah instance `DiscordButtonClickEvent` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `string`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(event)
    return event:getMessageID()
end
```

<a id="api-example-460"></a>

#### DiscordButtonClickEvent:editOriginalResponse(content, components, flags, embed, attachments)

`event` adalah instance `DiscordButtonClickEvent` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(event, content, components, flags, embed, attachments)
    return event:editOriginalResponse(content, components, flags, embed, attachments)
end
```

<a id="api-example-461"></a>

#### DiscordButtonClickEvent:getRoles()

`event` adalah instance `DiscordButtonClickEvent` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `{string}`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(event)
    return event:getRoles()
end
```

<a id="api-example-462"></a>

#### DiscordButtonClickEvent:delete()

`event` adalah instance `DiscordButtonClickEvent` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(event)
    return event:delete()
end
```

---

<a id="examples-discord-form-submit-event"></a>

### DiscordFormSubmitEvent

Referensi: [DiscordFormSubmitEvent](https://dash.gtps.cloud/docs/discord-form-submit-event).

<a id="api-example-463"></a>

#### DiscordFormSubmitEvent:getCustomID()

`event` adalah instance `DiscordFormSubmitEvent` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `string`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(event)
    return event:getCustomID()
end
```

<a id="api-example-464"></a>

#### DiscordFormSubmitEvent:getPlayer()

`event` adalah instance `DiscordFormSubmitEvent` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `Player`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(event)
    return event:getPlayer()
end
```

<a id="api-example-465"></a>

#### DiscordFormSubmitEvent:getChannelID()

`event` adalah instance `DiscordFormSubmitEvent` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `string`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(event)
    return event:getChannelID()
end
```

<a id="api-example-466"></a>

#### DiscordFormSubmitEvent:getAuthorID()

`event` adalah instance `DiscordFormSubmitEvent` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `string`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(event)
    return event:getAuthorID()
end
```

<a id="api-example-467"></a>

#### DiscordFormSubmitEvent:getValue(id)

`event` adalah instance `DiscordFormSubmitEvent` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `string`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(event, id)
    return event:getValue(id)
end
```

<a id="api-example-468"></a>

#### DiscordFormSubmitEvent:reply(content, components, flags, embed, attachments)

`event` adalah instance `DiscordFormSubmitEvent` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(event, content, components, flags, embed, attachments)
    return event:reply(content, components, flags, embed, attachments)
end
```

<a id="api-example-469"></a>

#### DiscordFormSubmitEvent:getMessageID()

`event` adalah instance `DiscordFormSubmitEvent` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `string`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(event)
    return event:getMessageID()
end
```

<a id="api-example-470"></a>

#### DiscordFormSubmitEvent:getRoles()

`event` adalah instance `DiscordFormSubmitEvent` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `{string}`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(event)
    return event:getRoles()
end
```

<a id="api-example-471"></a>

#### DiscordFormSubmitEvent:delete()

`event` adalah instance `DiscordFormSubmitEvent` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(event)
    return event:delete()
end
```

<a id="api-example-472"></a>

#### DiscordFormSubmitEvent:editOriginalResponse(content, components, flags, embed, attachments)

`event` adalah instance `DiscordFormSubmitEvent` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(event, content, components, flags, embed, attachments)
    return event:editOriginalResponse(content, components, flags, embed, attachments)
end
```

---

<a id="examples-discord-message-create-event"></a>

### DiscordMessageCreateEvent

Referensi: [DiscordMessageCreateEvent](https://dash.gtps.cloud/docs/discord-message-create-event).

<a id="api-example-473"></a>

#### DiscordMessageCreateEvent:getContent()

`event` adalah instance `DiscordMessageCreateEvent` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `string`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(event)
    return event:getContent()
end
```

<a id="api-example-474"></a>

#### DiscordMessageCreateEvent:getPlayer()

`event` adalah instance `DiscordMessageCreateEvent` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `Player`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(event)
    return event:getPlayer()
end
```

<a id="api-example-475"></a>

#### DiscordMessageCreateEvent:getChannelID()

`event` adalah instance `DiscordMessageCreateEvent` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `string`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(event)
    return event:getChannelID()
end
```

<a id="api-example-476"></a>

#### DiscordMessageCreateEvent:getAuthorID()

`event` adalah instance `DiscordMessageCreateEvent` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `string`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(event)
    return event:getAuthorID()
end
```

<a id="api-example-477"></a>

#### DiscordMessageCreateEvent:isBot()

`event` adalah instance `DiscordMessageCreateEvent` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `boolean`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(event)
    return event:isBot()
end
```

<a id="api-example-478"></a>

#### DiscordMessageCreateEvent:reply(content, components, flags, mention_replied_user, embed)

`event` adalah instance `DiscordMessageCreateEvent` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(event, content, components, flags, mention_replied_user, embed)
    return event:reply(content, components, flags, mention_replied_user, embed)
end
```

<a id="api-example-479"></a>

#### DiscordMessageCreateEvent:getMentionedUsers()

`event` adalah instance `DiscordMessageCreateEvent` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `{string}`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(event)
    return event:getMentionedUsers()
end
```

<a id="api-example-480"></a>

#### DiscordMessageCreateEvent:getMessageID()

`event` adalah instance `DiscordMessageCreateEvent` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `string`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(event)
    return event:getMessageID()
end
```

<a id="api-example-481"></a>

#### DiscordMessageCreateEvent:getRoles()

`event` adalah instance `DiscordMessageCreateEvent` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `{string}`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(event)
    return event:getRoles()
end
```

<a id="api-example-482"></a>

#### DiscordMessageCreateEvent:delete()

`event` adalah instance `DiscordMessageCreateEvent` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(event)
    return event:delete()
end
```

---

<a id="examples-discord-slash-command-event"></a>

### DiscordSlashCommandEvent

Referensi: [DiscordSlashCommandEvent](https://dash.gtps.cloud/docs/discord-slash-command-event).

<a id="api-example-483"></a>

#### DiscordSlashCommandEvent:getCommandName()

`event` adalah instance `DiscordSlashCommandEvent` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `string`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(event)
    return event:getCommandName()
end
```

<a id="api-example-484"></a>

#### DiscordSlashCommandEvent:getParameter(parameter)

`event` adalah instance `DiscordSlashCommandEvent` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `string`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(event, parameter)
    return event:getParameter(parameter)
end
```

<a id="api-example-485"></a>

#### DiscordSlashCommandEvent:getPlayer()

`event` adalah instance `DiscordSlashCommandEvent` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `Player`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(event)
    return event:getPlayer()
end
```

<a id="api-example-486"></a>

#### DiscordSlashCommandEvent:getChannelID()

`event` adalah instance `DiscordSlashCommandEvent` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `string`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(event)
    return event:getChannelID()
end
```

<a id="api-example-487"></a>

#### DiscordSlashCommandEvent:getAuthorID()

`event` adalah instance `DiscordSlashCommandEvent` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `string`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(event)
    return event:getAuthorID()
end
```

<a id="api-example-488"></a>

#### DiscordSlashCommandEvent:reply(channelID, content, components, flags, embed, attachments)

`event` adalah instance `DiscordSlashCommandEvent` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(event, channelID, content, components, flags, embed, attachments)
    return event:reply(channelID, content, components, flags, embed, attachments)
end
```

<a id="api-example-489"></a>

#### DiscordSlashCommandEvent:editOriginalResponse(channelID, content, components, flags, embed, attachments)

`event` adalah instance `DiscordSlashCommandEvent` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(event, channelID, content, components, flags, embed, attachments)
    return event:editOriginalResponse(channelID, content, components, flags, embed, attachments)
end
```

<a id="api-example-490"></a>

#### DiscordSlashCommandEvent:dialog(modal)

`event` adalah instance `DiscordSlashCommandEvent` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(event, modal)
    return event:dialog(modal)
end
```

<a id="api-example-491"></a>

#### DiscordSlashCommandEvent:thinking(ephemeral)

`event` adalah instance `DiscordSlashCommandEvent` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(event, ephemeral)
    return event:thinking(ephemeral)
end
```

<a id="api-example-492"></a>

#### DiscordSlashCommandEvent:getRoles()

`event` adalah instance `DiscordSlashCommandEvent` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `{string}`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(event)
    return event:getRoles()
end
```

<a id="api-example-493"></a>

#### DiscordSlashCommandEvent:delete()

`event` adalah instance `DiscordSlashCommandEvent` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(event)
    return event:delete()
end
```

---

<a id="examples-font"></a>

### Font

Referensi: [Font](https://dash.gtps.cloud/docs/font).

<a id="api-example-494"></a>

#### Font:loadFromFile(path)

`font` adalah instance `Font` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(font, path)
    return font:loadFromFile(path)
end
```

<a id="api-example-495"></a>

#### Font:new()

Membuat objek melalui constructor `Font` sesuai signature sumber.

Hasil yang didokumentasikan: `Font`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example()
    return Font:new()
end
```

---

<a id="examples-render-texture"></a>

### RenderTexture

Referensi: [RenderTexture](https://dash.gtps.cloud/docs/render-texture).

<a id="api-example-496"></a>

#### RenderTexture:getWidth()

`canvas` adalah instance `RenderTexture` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `number`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(canvas)
    return canvas:getWidth()
end
```

<a id="api-example-497"></a>

#### RenderTexture:getHeight()

`canvas` adalah instance `RenderTexture` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `number`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(canvas)
    return canvas:getHeight()
end
```

<a id="api-example-498"></a>

#### RenderTexture:clear(r, g, b, a)

`canvas` adalah instance `RenderTexture` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(canvas, r, g, b, a)
    return canvas:clear(r, g, b, a)
end
```

<a id="api-example-499"></a>

#### RenderTexture:saveToFile(path)

`canvas` adalah instance `RenderTexture` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(canvas, path)
    return canvas:saveToFile(path)
end
```

<a id="api-example-500"></a>

#### RenderTexture:draw(sprite)

`canvas` adalah instance `RenderTexture` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(canvas, sprite)
    return canvas:draw(sprite)
end
```

<a id="api-example-501"></a>

#### RenderTexture:display()

`canvas` adalah instance `RenderTexture` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(canvas)
    return canvas:display()
end
```

<a id="api-example-502"></a>

#### RenderTexture:drawText(font, str, x, y, size, r, g, b, a)

`canvas` adalah instance `RenderTexture` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(canvas, font, str, x, y, size, r, g, b, a)
    return canvas:drawText(font, str, x, y, size, r, g, b, a)
end
```

<a id="api-example-503"></a>

#### RenderTexture:getTextSize(font, str, size)

`canvas` adalah instance `RenderTexture` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `number, number`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(canvas, font, str, size)
    return canvas:getTextSize(font, str, size)
end
```

<a id="api-example-504"></a>

#### RenderTexture:new(width, height)

Membuat objek melalui constructor `RenderTexture` sesuai signature sumber.

Hasil yang didokumentasikan: `RenderTexture`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(width, height)
    return RenderTexture:new(width, height)
end
```

<a id="api-example-505"></a>

#### RenderTexture:drawRectangle(x, y, width, height, r, g, b, a)

`canvas` adalah instance `RenderTexture` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(canvas, x, y, width, height, r, g, b, a)
    return canvas:drawRectangle(x, y, width, height, r, g, b, a)
end
```

<a id="api-example-506"></a>

#### RenderTexture:toPNG()

`canvas` adalah instance `RenderTexture` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `string`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(canvas)
    return canvas:toPNG()
end
```

---

<a id="examples-sprite"></a>

### Sprite

Referensi: [Sprite](https://dash.gtps.cloud/docs/sprite).

<a id="api-example-507"></a>

#### Sprite:setScale(x, y)

`sprite` adalah instance `Sprite` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(sprite, x, y)
    return sprite:setScale(x, y)
end
```

<a id="api-example-508"></a>

#### Sprite:setPosition(x, y)

`sprite` adalah instance `Sprite` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(sprite, x, y)
    return sprite:setPosition(x, y)
end
```

<a id="api-example-509"></a>

#### Sprite:setRect(x, y, width, height)

`sprite` adalah instance `Sprite` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(sprite, x, y, width, height)
    return sprite:setRect(x, y, width, height)
end
```

<a id="api-example-510"></a>

#### Sprite:setTexture(texture)

`sprite` adalah instance `Sprite` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(sprite, texture)
    return sprite:setTexture(texture)
end
```

<a id="api-example-511"></a>

#### Sprite:new()

Membuat objek melalui constructor `Sprite` sesuai signature sumber.

Hasil yang didokumentasikan: `Sprite`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example()
    return Sprite:new()
end
```

---

<a id="examples-texture"></a>

### Texture

Referensi: [Texture](https://dash.gtps.cloud/docs/texture).

<a id="api-example-512"></a>

#### Texture:loadFromFile(path)

`texture` adalah instance `Texture` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(texture, path)
    return texture:loadFromFile(path)
end
```

<a id="api-example-513"></a>

#### Texture:new()

Membuat objek melalui constructor `Texture` sesuai signature sumber.

Hasil yang didokumentasikan: `Texture`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example()
    return Texture:new()
end
```

---

<a id="examples-active-effects"></a>

### ActiveEffects

Referensi: [ActiveEffects](https://dash.gtps.cloud/docs/active-effects).

<a id="api-example-514"></a>

#### ActiveEffects:getType()

`effect` adalah instance `ActiveEffects` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `number`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(effect)
    return effect:getType()
end
```

<a id="api-example-515"></a>

#### ActiveEffects:getExpireTime()

`effect` adalah instance `ActiveEffects` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `number`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(effect)
    return effect:getExpireTime()
end
```

<a id="api-example-516"></a>

#### ActiveEffects:getName(player)

`effect` adalah instance `ActiveEffects` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `string`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(effect, player)
    return effect:getName(player)
end
```

<a id="api-example-517"></a>

#### ActiveEffects:getDescription(player)

`effect` adalah instance `ActiveEffects` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `string`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(effect, player)
    return effect:getDescription(player)
end
```

<a id="api-example-518"></a>

#### ActiveEffects:getItemID()

`effect` adalah instance `ActiveEffects` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `number`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(effect)
    return effect:getItemID()
end
```

---

<a id="examples-http"></a>

### http

Referensi: [http](https://dash.gtps.cloud/docs/http).

Panggil fungsi `example` di dalam coroutine seperti resep HTTP di atas. Wrapper ini tidak membuat coroutine secara otomatis.

<a id="api-example-519"></a>

#### http:get(url, headers)

Argumen fungsi berasal dari pemanggil; tidak ada nilai ID, konfigurasi, atau struktur packet yang diasumsikan. Wajib dipanggil dari coroutine; pertahankan seluruh hasil body/status.

Hasil yang didokumentasikan: `string, number`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(url, headers)
    return http:get(url, headers)
end
```

<a id="api-example-520"></a>

#### http:post(url, headers, postData)

Argumen fungsi berasal dari pemanggil; tidak ada nilai ID, konfigurasi, atau struktur packet yang diasumsikan. Wajib dipanggil dari coroutine; pertahankan seluruh hasil body/status.

Hasil yang didokumentasikan: `string, number`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(url, headers, postData)
    return http:post(url, headers, postData)
end
```

---

<a id="examples-file"></a>

### file

Referensi: [file](https://dash.gtps.cloud/docs/file).

<a id="api-example-521"></a>

#### file:read(path)

Argumen fungsi berasal dari pemanggil; tidak ada nilai ID, konfigurasi, atau struktur packet yang diasumsikan.

Hasil yang didokumentasikan: `string`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(path)
    return file:read(path)
end
```

<a id="api-example-522"></a>

#### file:write(path, data)

Argumen fungsi berasal dari pemanggil; tidak ada nilai ID, konfigurasi, atau struktur packet yang diasumsikan.

Hasil yang didokumentasikan: `boolean`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(path, data)
    return file:write(path, data)
end
```

<a id="api-example-523"></a>

#### file:exists(path)

Argumen fungsi berasal dari pemanggil; tidak ada nilai ID, konfigurasi, atau struktur packet yang diasumsikan.

Hasil yang didokumentasikan: `boolean`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(path)
    return file:exists(path)
end
```

<a id="api-example-524"></a>

#### file:delete(path)

Argumen fungsi berasal dari pemanggil; tidak ada nilai ID, konfigurasi, atau struktur packet yang diasumsikan.

Hasil yang didokumentasikan: `boolean`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(path)
    return file:delete(path)
end
```

---

<a id="examples-dir"></a>

### dir

Referensi: [dir](https://dash.gtps.cloud/docs/dir).

<a id="api-example-525"></a>

#### dir:create(path)

Argumen fungsi berasal dari pemanggil; tidak ada nilai ID, konfigurasi, atau struktur packet yang diasumsikan.

Hasil yang didokumentasikan: `boolean`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(path)
    return dir:create(path)
end
```

<a id="api-example-526"></a>

#### dir:exists(path)

Argumen fungsi berasal dari pemanggil; tidak ada nilai ID, konfigurasi, atau struktur packet yang diasumsikan.

Hasil yang didokumentasikan: `boolean`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(path)
    return dir:exists(path)
end
```

<a id="api-example-527"></a>

#### dir:delete(path)

Argumen fungsi berasal dari pemanggil; tidak ada nilai ID, konfigurasi, atau struktur packet yang diasumsikan.

Hasil yang didokumentasikan: `boolean`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(path)
    return dir:delete(path)
end
```

---

<a id="examples-timer"></a>

### timer

Referensi: [timer](https://dash.gtps.cloud/docs/timer).

<a id="api-example-528"></a>

#### timer:setTimeout(seconds, callback, ...)

Argumen fungsi berasal dari pemanggil; tidak ada nilai ID, konfigurasi, atau struktur packet yang diasumsikan.

Hasil yang didokumentasikan: `number`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(seconds, callback, ...)
    return timer:setTimeout(seconds, callback, ...)
end
```

<a id="api-example-529"></a>

#### timer:setInterval(seconds, callback, ...)

Argumen fungsi berasal dari pemanggil; tidak ada nilai ID, konfigurasi, atau struktur packet yang diasumsikan.

Hasil yang didokumentasikan: `number`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(seconds, callback, ...)
    return timer:setInterval(seconds, callback, ...)
end
```

<a id="api-example-530"></a>

#### timer:clear(id)

Argumen fungsi berasal dari pemanggil; tidak ada nilai ID, konfigurasi, atau struktur packet yang diasumsikan.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(id)
    return timer:clear(id)
end
```

---

<a id="examples-sqlite"></a>

### sqlite

Referensi: [sqlite](https://dash.gtps.cloud/docs/sqlite).

<a id="api-example-531"></a>

#### sqlite:open(path)

Argumen fungsi berasal dari pemanggil; tidak ada nilai ID, konfigurasi, atau struktur packet yang diasumsikan.

Hasil yang didokumentasikan: `SqliteDB`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(path)
    return sqlite:open(path)
end
```

---

<a id="examples-sqlite-db"></a>

### SqliteDB

Referensi: [SqliteDB](https://dash.gtps.cloud/docs/sqlite-db).

<a id="api-example-532"></a>

#### SqliteDB:query(sql)

`database` adalah instance `SqliteDB` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `any`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(database, sql)
    return database:query(sql)
end
```

<a id="api-example-533"></a>

#### SqliteDB:close()

`database` adalah instance `SqliteDB` yang sudah tersedia; parameter sisanya mengikuti referensi.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(database)
    return database:close()
end
```

---

<a id="examples-bit"></a>

### bit

Referensi: [bit](https://dash.gtps.cloud/docs/bit).

<a id="api-example-534"></a>

#### bit:band(a, b)

Argumen fungsi berasal dari pemanggil; tidak ada nilai ID, konfigurasi, atau struktur packet yang diasumsikan.

Hasil yang didokumentasikan: `number`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(a, b)
    return bit:band(a, b)
end
```

<a id="api-example-535"></a>

#### bit:bor(a, b)

Argumen fungsi berasal dari pemanggil; tidak ada nilai ID, konfigurasi, atau struktur packet yang diasumsikan.

Hasil yang didokumentasikan: `number`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(a, b)
    return bit:bor(a, b)
end
```

<a id="api-example-536"></a>

#### bit:bxor(a, b)

Argumen fungsi berasal dari pemanggil; tidak ada nilai ID, konfigurasi, atau struktur packet yang diasumsikan.

Hasil yang didokumentasikan: `number`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(a, b)
    return bit:bxor(a, b)
end
```

<a id="api-example-537"></a>

#### bit:bnot(a)

Argumen fungsi berasal dari pemanggil; tidak ada nilai ID, konfigurasi, atau struktur packet yang diasumsikan.

Hasil yang didokumentasikan: `number`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(a)
    return bit:bnot(a)
end
```

<a id="api-example-538"></a>

#### bit:lshift(a, n)

Argumen fungsi berasal dari pemanggil; tidak ada nilai ID, konfigurasi, atau struktur packet yang diasumsikan.

Hasil yang didokumentasikan: `number`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(a, n)
    return bit:lshift(a, n)
end
```

<a id="api-example-539"></a>

#### bit:rshift(a, n)

Argumen fungsi berasal dari pemanggil; tidak ada nilai ID, konfigurasi, atau struktur packet yang diasumsikan.

Hasil yang didokumentasikan: `number`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(a, n)
    return bit:rshift(a, n)
end
```

<a id="api-example-540"></a>

#### bit:arshift(a, n)

Argumen fungsi berasal dari pemanggil; tidak ada nilai ID, konfigurasi, atau struktur packet yang diasumsikan.

Hasil yang didokumentasikan: `number`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(a, n)
    return bit:arshift(a, n)
end
```

<a id="api-example-541"></a>

#### bit:mod(a, b)

Argumen fungsi berasal dari pemanggil; tidak ada nilai ID, konfigurasi, atau struktur packet yang diasumsikan.

Hasil yang didokumentasikan: `number`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(a, b)
    return bit:mod(a, b)
end
```

---

<a id="examples-os"></a>

### os

Referensi: [os](https://dash.gtps.cloud/docs/os).

<a id="api-example-542"></a>

#### os:time()

Argumen fungsi berasal dari pemanggil; tidak ada nilai ID, konfigurasi, atau struktur packet yang diasumsikan.

Hasil yang didokumentasikan: `number`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example()
    return os:time()
end
```

---

<a id="examples-callbacks"></a>

### Callbacks

Referensi: [Callbacks](https://dash.gtps.cloud/docs/callbacks).

Setiap `installExample` mendaftarkan satu handler jika dipanggil. Nilai return untuk membatalkan atau mengubah event tidak ditambahkan karena tidak ada kontrak pada sumber.

<a id="api-example-543"></a>

#### onPlayerChatCallback

Panggil `installExample()` sekali untuk memasang contoh; fungsi hasilnya membaca snapshot event terakhir, atau `nil` sebelum event pertama.

```lua
local function installExample()
    local lastEvent
    onPlayerChatCallback(function(world, player, message)
        lastEvent = { world = world, player = player, message = message }
    end)
    return function()
        return lastEvent
    end
end
```

<a id="api-example-544"></a>

#### onBestWorldEndCallback

Panggil `installExample()` sekali untuk memasang contoh; fungsi hasilnya membaca snapshot event terakhir, atau `nil` sebelum event pertama.

```lua
local function installExample()
    local lastEvent
    onBestWorldEndCallback(function(world, score)
        lastEvent = { world = world, score = score }
    end)
    return function()
        return lastEvent
    end
end
```

<a id="api-example-545"></a>

#### onPlayerCommandCallback

Panggil `installExample()` sekali untuk memasang contoh; fungsi hasilnya membaca snapshot event terakhir, atau `nil` sebelum event pertama.

```lua
local function installExample()
    local lastEvent
    onPlayerCommandCallback(function(world, player, command)
        lastEvent = { world = world, player = player, command = command }
    end)
    return function()
        return lastEvent
    end
end
```

<a id="api-example-546"></a>

#### onPlayerDialogCallback

Panggil `installExample()` sekali untuk memasang contoh; fungsi hasilnya membaca snapshot event terakhir, atau `nil` sebelum event pertama.

```lua
local function installExample()
    local lastEvent
    onPlayerDialogCallback(function(world, player, dialogName)
        lastEvent = { world = world, player = player, dialogName = dialogName }
    end)
    return function()
        return lastEvent
    end
end
```

<a id="api-example-547"></a>

#### onPlayerLoginCallback

Panggil `installExample()` sekali untuk memasang contoh; fungsi hasilnya membaca snapshot event terakhir, atau `nil` sebelum event pertama.

```lua
local function installExample()
    local lastEvent
    onPlayerLoginCallback(function(player)
        lastEvent = { player = player }
    end)
    return function()
        return lastEvent
    end
end
```

<a id="api-example-548"></a>

#### onPlayerFirstTimeLoginCallback

Panggil `installExample()` sekali untuk memasang contoh; fungsi hasilnya membaca snapshot event terakhir, atau `nil` sebelum event pertama.

```lua
local function installExample()
    local lastEvent
    onPlayerFirstTimeLoginCallback(function(player)
        lastEvent = { player = player }
    end)
    return function()
        return lastEvent
    end
end
```

<a id="api-example-549"></a>

#### onPlayerRegisterCallback

Panggil `installExample()` sekali untuk memasang contoh; fungsi hasilnya membaca snapshot event terakhir, atau `nil` sebelum event pertama.

```lua
local function installExample()
    local lastEvent
    onPlayerRegisterCallback(function(world, player)
        lastEvent = { world = world, player = player }
    end)
    return function()
        return lastEvent
    end
end
```

<a id="api-example-550"></a>

#### onPlayerActionCallback

Panggil `installExample()` sekali untuk memasang contoh; fungsi hasilnya membaca snapshot event terakhir, atau `nil` sebelum event pertama.

```lua
local function installExample()
    local lastEvent
    onPlayerActionCallback(function(world, player, action)
        lastEvent = { world = world, player = player, action = action }
    end)
    return function()
        return lastEvent
    end
end
```

<a id="api-example-551"></a>

#### onPlayerEnterWorldCallback

Panggil `installExample()` sekali untuk memasang contoh; fungsi hasilnya membaca snapshot event terakhir, atau `nil` sebelum event pertama.

```lua
local function installExample()
    local lastEvent
    onPlayerEnterWorldCallback(function(world, player)
        lastEvent = { world = world, player = player }
    end)
    return function()
        return lastEvent
    end
end
```

<a id="api-example-552"></a>

#### onPlayerValidateWorldCallback

Panggil `installExample()` sekali untuk memasang contoh; fungsi hasilnya membaca snapshot event terakhir, atau `nil` sebelum event pertama.

```lua
local function installExample()
    local lastEvent
    onPlayerValidateWorldCallback(function(world, player)
        lastEvent = { world = world, player = player }
    end)
    return function()
        return lastEvent
    end
end
```

<a id="api-example-553"></a>

#### onPlayerLeaveWorldCallback

Panggil `installExample()` sekali untuk memasang contoh; fungsi hasilnya membaca snapshot event terakhir, atau `nil` sebelum event pertama.

```lua
local function installExample()
    local lastEvent
    onPlayerLeaveWorldCallback(function(world, player)
        lastEvent = { world = world, player = player }
    end)
    return function()
        return lastEvent
    end
end
```

<a id="api-example-554"></a>

#### onPlayerDisconnectCallback

Panggil `installExample()` sekali untuk memasang contoh; fungsi hasilnya membaca snapshot event terakhir, atau `nil` sebelum event pertama.

```lua
local function installExample()
    local lastEvent
    onPlayerDisconnectCallback(function(player)
        lastEvent = { player = player }
    end)
    return function()
        return lastEvent
    end
end
```

<a id="api-example-555"></a>

#### onPlayerDeathCallback

Panggil `installExample()` sekali untuk memasang contoh; fungsi hasilnya membaca snapshot event terakhir, atau `nil` sebelum event pertama.

```lua
local function installExample()
    local lastEvent
    onPlayerDeathCallback(function(world, player, spikeKill)
        lastEvent = { world = world, player = player, spikeKill = spikeKill }
    end)
    return function()
        return lastEvent
    end
end
```

<a id="api-example-556"></a>

#### onPlayerTradeCallback

Panggil `installExample()` sekali untuk memasang contoh; fungsi hasilnya membaca snapshot event terakhir, atau `nil` sebelum event pertama.

```lua
local function installExample()
    local lastEvent
    onPlayerTradeCallback(function(world, player, targetPlayer)
        lastEvent = { world = world, player = player, targetPlayer = targetPlayer }
    end)
    return function()
        return lastEvent
    end
end
```

<a id="api-example-557"></a>

#### onPlayerBoostClaimCallback

Panggil `installExample()` sekali untuk memasang contoh; fungsi hasilnya membaca snapshot event terakhir, atau `nil` sebelum event pertama.

```lua
local function installExample()
    local lastEvent
    onPlayerBoostClaimCallback(function(player)
        lastEvent = { player = player }
    end)
    return function()
        return lastEvent
    end
end
```

<a id="api-example-558"></a>

#### onPlayerTrashCallback

Panggil `installExample()` sekali untuk memasang contoh; fungsi hasilnya membaca snapshot event terakhir, atau `nil` sebelum event pertama.

```lua
local function installExample()
    local lastEvent
    onPlayerTrashCallback(function(world, player, itemID, itemCount)
        lastEvent = { world = world, player = player, itemID = itemID, itemCount = itemCount }
    end)
    return function()
        return lastEvent
    end
end
```

<a id="api-example-559"></a>

#### onPlayerRecycleCallback

Panggil `installExample()` sekali untuk memasang contoh; fungsi hasilnya membaca snapshot event terakhir, atau `nil` sebelum event pertama.

```lua
local function installExample()
    local lastEvent
    onPlayerRecycleCallback(function(world, player, itemID, itemCount, gems)
        lastEvent = { world = world, player = player, itemID = itemID, itemCount = itemCount, gems = gems }
    end)
    return function()
        return lastEvent
    end
end
```

<a id="api-example-560"></a>

#### onPlayerCrimeCallback

Panggil `installExample()` sekali untuk memasang contoh; fungsi hasilnya membaca snapshot event terakhir, atau `nil` sebelum event pertama.

```lua
local function installExample()
    local lastEvent
    onPlayerCrimeCallback(function(world, player, rewardID, rewardAmount)
        lastEvent = { world = world, player = player, rewardID = rewardID, rewardAmount = rewardAmount }
    end)
    return function()
        return lastEvent
    end
end
```

<a id="api-example-561"></a>

#### onPlayerSurgeryCallback

Panggil `installExample()` sekali untuk memasang contoh; fungsi hasilnya membaca snapshot event terakhir, atau `nil` sebelum event pertama.

```lua
local function installExample()
    local lastEvent
    onPlayerSurgeryCallback(function(world, player, resultID, resultAmount, targetPlayer)
        lastEvent = { world = world, player = player, resultID = resultID, resultAmount = resultAmount, targetPlayer = targetPlayer }
    end)
    return function()
        return lastEvent
    end
end
```

<a id="api-example-562"></a>

#### onPlayerKillCallback

Panggil `installExample()` sekali untuk memasang contoh; fungsi hasilnya membaca snapshot event terakhir, atau `nil` sebelum event pertama.

```lua
local function installExample()
    local lastEvent
    onPlayerKillCallback(function(world, player, targetPlayer)
        lastEvent = { world = world, player = player, targetPlayer = targetPlayer }
    end)
    return function()
        return lastEvent
    end
end
```

<a id="api-example-563"></a>

#### onPlayerPunchPlayerCallback

Panggil `installExample()` sekali untuk memasang contoh; fungsi hasilnya membaca snapshot event terakhir, atau `nil` sebelum event pertama.

```lua
local function installExample()
    local lastEvent
    onPlayerPunchPlayerCallback(function(world, player, targetPlayer)
        lastEvent = { world = world, player = player, targetPlayer = targetPlayer }
    end)
    return function()
        return lastEvent
    end
end
```

<a id="api-example-564"></a>

#### onPlayerPunchNPCCallback

Panggil `installExample()` sekali untuk memasang contoh; fungsi hasilnya membaca snapshot event terakhir, atau `nil` sebelum event pertama.

```lua
local function installExample()
    local lastEvent
    onPlayerPunchNPCCallback(function(world, player, npc)
        lastEvent = { world = world, player = player, npc = npc }
    end)
    return function()
        return lastEvent
    end
end
```

<a id="api-example-565"></a>

#### onPlayerProviderCallback

Panggil `installExample()` sekali untuk memasang contoh; fungsi hasilnya membaca snapshot event terakhir, atau `nil` sebelum event pertama.

```lua
local function installExample()
    local lastEvent
    onPlayerProviderCallback(function(world, player, tile, itemID, itemAmount)
        lastEvent = { world = world, player = player, tile = tile, itemID = itemID, itemAmount = itemAmount }
    end)
    return function()
        return lastEvent
    end
end
```

<a id="api-example-566"></a>

#### onPlayerHarmonicCallback

Panggil `installExample()` sekali untuk memasang contoh; fungsi hasilnya membaca snapshot event terakhir, atau `nil` sebelum event pertama.

```lua
local function installExample()
    local lastEvent
    onPlayerHarmonicCallback(function(world, player, tile, itemID, amount)
        lastEvent = { world = world, player = player, tile = tile, itemID = itemID, amount = amount }
    end)
    return function()
        return lastEvent
    end
end
```

<a id="api-example-567"></a>

#### onPlayerGeigerCallback

Panggil `installExample()` sekali untuk memasang contoh; fungsi hasilnya membaca snapshot event terakhir, atau `nil` sebelum event pertama.

```lua
local function installExample()
    local lastEvent
    onPlayerGeigerCallback(function(world, player, itemID, amount)
        lastEvent = { world = world, player = player, itemID = itemID, amount = amount }
    end)
    return function()
        return lastEvent
    end
end
```

<a id="api-example-568"></a>

#### onPlayerCatchGhostCallback

Panggil `installExample()` sekali untuk memasang contoh; fungsi hasilnya membaca snapshot event terakhir, atau `nil` sebelum event pertama.

```lua
local function installExample()
    local lastEvent
    onPlayerCatchGhostCallback(function(world, player, jarID, amount)
        lastEvent = { world = world, player = player, jarID = jarID, amount = amount }
    end)
    return function()
        return lastEvent
    end
end
```

<a id="api-example-569"></a>

#### onPlayerDNACallback

Panggil `installExample()` sekali untuk memasang contoh; fungsi hasilnya membaca snapshot event terakhir, atau `nil` sebelum event pertama.

```lua
local function installExample()
    local lastEvent
    onPlayerDNACallback(function(world, player, resultID, resultAmount)
        lastEvent = { world = world, player = player, resultID = resultID, resultAmount = resultAmount }
    end)
    return function()
        return lastEvent
    end
end
```

<a id="api-example-570"></a>

#### onPlayerXPCallback

Panggil `installExample()` sekali untuk memasang contoh; fungsi hasilnya membaca snapshot event terakhir, atau `nil` sebelum event pertama.

```lua
local function installExample()
    local lastEvent
    onPlayerXPCallback(function(world, player, amount)
        lastEvent = { world = world, player = player, amount = amount }
    end)
    return function()
        return lastEvent
    end
end
```

<a id="api-example-571"></a>

#### onPlayerFirePutOutCallback

Panggil `installExample()` sekali untuk memasang contoh; fungsi hasilnya membaca snapshot event terakhir, atau `nil` sebelum event pertama.

```lua
local function installExample()
    local lastEvent
    onPlayerFirePutOutCallback(function(world, player, tile)
        lastEvent = { world = world, player = player, tile = tile }
    end)
    return function()
        return lastEvent
    end
end
```

<a id="api-example-572"></a>

#### onPlayerGemsObtainedCallback

Panggil `installExample()` sekali untuk memasang contoh; fungsi hasilnya membaca snapshot event terakhir, atau `nil` sebelum event pertama.

```lua
local function installExample()
    local lastEvent
    onPlayerGemsObtainedCallback(function(world, player, amount)
        lastEvent = { world = world, player = player, amount = amount }
    end)
    return function()
        return lastEvent
    end
end
```

<a id="api-example-573"></a>

#### onPlayerEarnGrowtokenCallback

Panggil `installExample()` sekali untuk memasang contoh; fungsi hasilnya membaca snapshot event terakhir, atau `nil` sebelum event pertama.

```lua
local function installExample()
    local lastEvent
    onPlayerEarnGrowtokenCallback(function(world, player, progressAmount)
        lastEvent = { world = world, player = player, progressAmount = progressAmount }
    end)
    return function()
        return lastEvent
    end
end
```

<a id="api-example-574"></a>

#### onPlayerTrainFishCallback

Panggil `installExample()` sekali untuk memasang contoh; fungsi hasilnya membaca snapshot event terakhir, atau `nil` sebelum event pertama.

```lua
local function installExample()
    local lastEvent
    onPlayerTrainFishCallback(function(world, player)
        lastEvent = { world = world, player = player }
    end)
    return function()
        return lastEvent
    end
end
```

<a id="api-example-575"></a>

#### onPlayerVariantCallback

Panggil `installExample()` sekali untuk memasang contoh; fungsi hasilnya membaca snapshot event terakhir, atau `nil` sebelum event pertama.

```lua
local function installExample()
    local lastEvent
    onPlayerVariantCallback(function(player, variant, delay, netID)
        lastEvent = { player = player, variant = variant, delay = delay, netID = netID }
    end)
    return function()
        return lastEvent
    end
end
```

<a id="api-example-576"></a>

#### onPlayerRawPacketCallback

Panggil `installExample()` sekali untuk memasang contoh; fungsi hasilnya membaca snapshot event terakhir, atau `nil` sebelum event pertama.

```lua
local function installExample()
    local lastEvent
    onPlayerRawPacketCallback(function(player, packet)
        lastEvent = { player = player, packet = packet }
    end)
    return function()
        return lastEvent
    end
end
```

<a id="api-example-577"></a>

#### onServerReceiveRawPacketCallback

Panggil `installExample()` sekali untuk memasang contoh; fungsi hasilnya membaca snapshot event terakhir, atau `nil` sebelum event pertama.

```lua
local function installExample()
    local lastEvent
    onServerReceiveRawPacketCallback(function(world, player, packet)
        lastEvent = { world = world, player = player, packet = packet }
    end)
    return function()
        return lastEvent
    end
end
```

<a id="api-example-578"></a>

#### onPlayerDropCallback

Panggil `installExample()` sekali untuk memasang contoh; fungsi hasilnya membaca snapshot event terakhir, atau `nil` sebelum event pertama.

```lua
local function installExample()
    local lastEvent
    onPlayerDropCallback(function(world, player, itemID, itemCount)
        lastEvent = { world = world, player = player, itemID = itemID, itemCount = itemCount }
    end)
    return function()
        return lastEvent
    end
end
```

<a id="api-example-579"></a>

#### onPlayerLevelUPCallback

Panggil `installExample()` sekali untuk memasang contoh; fungsi hasilnya membaca snapshot event terakhir, atau `nil` sebelum event pertama.

```lua
local function installExample()
    local lastEvent
    onPlayerLevelUPCallback(function(world, player, level)
        lastEvent = { world = world, player = player, level = level }
    end)
    return function()
        return lastEvent
    end
end
```

<a id="api-example-580"></a>

#### onPlayerEquipClothingCallback

Panggil `installExample()` sekali untuk memasang contoh; fungsi hasilnya membaca snapshot event terakhir, atau `nil` sebelum event pertama.

```lua
local function installExample()
    local lastEvent
    onPlayerEquipClothingCallback(function(world, player, itemID)
        lastEvent = { world = world, player = player, itemID = itemID }
    end)
    return function()
        return lastEvent
    end
end
```

<a id="api-example-581"></a>

#### onPlayerUnequipClothingCallback

Panggil `installExample()` sekali untuk memasang contoh; fungsi hasilnya membaca snapshot event terakhir, atau `nil` sebelum event pertama.

```lua
local function installExample()
    local lastEvent
    onPlayerUnequipClothingCallback(function(world, player, itemID)
        lastEvent = { world = world, player = player, itemID = itemID }
    end)
    return function()
        return lastEvent
    end
end
```

<a id="api-example-582"></a>

#### onPlayerEquippedClothingCallback

Panggil `installExample()` sekali untuk memasang contoh; fungsi hasilnya membaca snapshot event terakhir, atau `nil` sebelum event pertama.

```lua
local function installExample()
    local lastEvent
    onPlayerEquippedClothingCallback(function(world, player, itemID)
        lastEvent = { world = world, player = player, itemID = itemID }
    end)
    return function()
        return lastEvent
    end
end
```

<a id="api-example-583"></a>

#### onPlayerUnequippedClothingCallback

Panggil `installExample()` sekali untuk memasang contoh; fungsi hasilnya membaca snapshot event terakhir, atau `nil` sebelum event pertama.

```lua
local function installExample()
    local lastEvent
    onPlayerUnequippedClothingCallback(function(world, player, itemID)
        lastEvent = { world = world, player = player, itemID = itemID }
    end)
    return function()
        return lastEvent
    end
end
```

<a id="api-example-584"></a>

#### onPlayerPickupItemCallback

Panggil `installExample()` sekali untuk memasang contoh; fungsi hasilnya membaca snapshot event terakhir, atau `nil` sebelum event pertama.

```lua
local function installExample()
    local lastEvent
    onPlayerPickupItemCallback(function(world, player, itemID, itemCount)
        lastEvent = { world = world, player = player, itemID = itemID, itemCount = itemCount }
    end)
    return function()
        return lastEvent
    end
end
```

<a id="api-example-585"></a>

#### onPlayerEnterDoorCallback

Panggil `installExample()` sekali untuk memasang contoh; fungsi hasilnya membaca snapshot event terakhir, atau `nil` sebelum event pertama.

```lua
local function installExample()
    local lastEvent
    onPlayerEnterDoorCallback(function(world, player, doorTarget, doorID)
        lastEvent = { world = world, player = player, doorTarget = doorTarget, doorID = doorID }
    end)
    return function()
        return lastEvent
    end
end
```

<a id="api-example-586"></a>

#### onPlayerPlantCallback

Panggil `installExample()` sekali untuk memasang contoh; fungsi hasilnya membaca snapshot event terakhir, atau `nil` sebelum event pertama.

```lua
local function installExample()
    local lastEvent
    onPlayerPlantCallback(function(world, player, tile)
        lastEvent = { world = world, player = player, tile = tile }
    end)
    return function()
        return lastEvent
    end
end
```

<a id="api-example-587"></a>

#### onPlayerHarvestCallback

Panggil `installExample()` sekali untuk memasang contoh; fungsi hasilnya membaca snapshot event terakhir, atau `nil` sebelum event pertama.

```lua
local function installExample()
    local lastEvent
    onPlayerHarvestCallback(function(world, player, tile)
        lastEvent = { world = world, player = player, tile = tile }
    end)
    return function()
        return lastEvent
    end
end
```

<a id="api-example-588"></a>

#### onPlayerCatchFishCallback

Panggil `installExample()` sekali untuk memasang contoh; fungsi hasilnya membaca snapshot event terakhir, atau `nil` sebelum event pertama.

```lua
local function installExample()
    local lastEvent
    onPlayerCatchFishCallback(function(world, player, rewardID, rewardAmount)
        lastEvent = { world = world, player = player, rewardID = rewardID, rewardAmount = rewardAmount }
    end)
    return function()
        return lastEvent
    end
end
```

<a id="api-example-589"></a>

#### onTileWrenchCallback

Panggil `installExample()` sekali untuk memasang contoh; fungsi hasilnya membaca snapshot event terakhir, atau `nil` sebelum event pertama.

```lua
local function installExample()
    local lastEvent
    onTileWrenchCallback(function(world, player, tile)
        lastEvent = { world = world, player = player, tile = tile }
    end)
    return function()
        return lastEvent
    end
end
```

<a id="api-example-590"></a>

#### onPlayerWrenchCallback

Panggil `installExample()` sekali untuk memasang contoh; fungsi hasilnya membaca snapshot event terakhir, atau `nil` sebelum event pertama.

```lua
local function installExample()
    local lastEvent
    onPlayerWrenchCallback(function(world, player, targetPlayer)
        lastEvent = { world = world, player = player, targetPlayer = targetPlayer }
    end)
    return function()
        return lastEvent
    end
end
```

<a id="api-example-591"></a>

#### onPlayerBlessingClaimCallback

Panggil `installExample()` sekali untuk memasang contoh; fungsi hasilnya membaca snapshot event terakhir, atau `nil` sebelum event pertama.

```lua
local function installExample()
    local lastEvent
    onPlayerBlessingClaimCallback(function(world, player, blessingID)
        lastEvent = { world = world, player = player, blessingID = blessingID }
    end)
    return function()
        return lastEvent
    end
end
```

<a id="api-example-592"></a>

#### onPlayerConvertItemCallback

Panggil `installExample()` sekali untuk memasang contoh; fungsi hasilnya membaca snapshot event terakhir, atau `nil` sebelum event pertama.

```lua
local function installExample()
    local lastEvent
    onPlayerConvertItemCallback(function(world, player, itemID)
        lastEvent = { world = world, player = player, itemID = itemID }
    end)
    return function()
        return lastEvent
    end
end
```

<a id="api-example-593"></a>

#### onPlayerAddFriendCallback

Panggil `installExample()` sekali untuk memasang contoh; fungsi hasilnya membaca snapshot event terakhir, atau `nil` sebelum event pertama.

```lua
local function installExample()
    local lastEvent
    onPlayerAddFriendCallback(function(world, player, targetPlayer)
        lastEvent = { world = world, player = player, targetPlayer = targetPlayer }
    end)
    return function()
        return lastEvent
    end
end
```

<a id="api-example-594"></a>

#### onTileBreakCallback

Panggil `installExample()` sekali untuk memasang contoh; fungsi hasilnya membaca snapshot event terakhir, atau `nil` sebelum event pertama.

```lua
local function installExample()
    local lastEvent
    onTileBreakCallback(function(world, player, tile)
        lastEvent = { world = world, player = player, tile = tile }
    end)
    return function()
        return lastEvent
    end
end
```

<a id="api-example-595"></a>

#### onTilePlaceCallback

Panggil `installExample()` sekali untuk memasang contoh; fungsi hasilnya membaca snapshot event terakhir, atau `nil` sebelum event pertama.

```lua
local function installExample()
    local lastEvent
    onTilePlaceCallback(function(world, player, tile, itemID)
        lastEvent = { world = world, player = player, tile = tile, itemID = itemID }
    end)
    return function()
        return lastEvent
    end
end
```

<a id="api-example-596"></a>

#### onTilePlacedCallback

Panggil `installExample()` sekali untuk memasang contoh; fungsi hasilnya membaca snapshot event terakhir, atau `nil` sebelum event pertama.

```lua
local function installExample()
    local lastEvent
    onTilePlacedCallback(function(world, player, tile)
        lastEvent = { world = world, player = player, tile = tile }
    end)
    return function()
        return lastEvent
    end
end
```

<a id="api-example-597"></a>

#### onTilePunchCallback

Panggil `installExample()` sekali untuk memasang contoh; fungsi hasilnya membaca snapshot event terakhir, atau `nil` sebelum event pertama.

```lua
local function installExample()
    local lastEvent
    onTilePunchCallback(function(world, player, tile)
        lastEvent = { world = world, player = player, tile = tile }
    end)
    return function()
        return lastEvent
    end
end
```

<a id="api-example-598"></a>

#### onPlayerConsumableCallback

Panggil `installExample()` sekali untuk memasang contoh; fungsi hasilnya membaca snapshot event terakhir, atau `nil` sebelum event pertama.

```lua
local function installExample()
    local lastEvent
    onPlayerConsumableCallback(function(world, player, tile, itemID, targetPlayer)
        lastEvent = { world = world, player = player, tile = tile, itemID = itemID, targetPlayer = targetPlayer }
    end)
    return function()
        return lastEvent
    end
end
```

<a id="api-example-599"></a>

#### onEventChangedCallback

Panggil `installExample()` sekali untuk memasang contoh; fungsi hasilnya membaca snapshot event terakhir, atau `nil` sebelum event pertama.

```lua
local function installExample()
    local lastEvent
    onEventChangedCallback(function(eventID, oldEventID)
        lastEvent = { eventID = eventID, oldEventID = oldEventID }
    end)
    return function()
        return lastEvent
    end
end
```

<a id="api-example-600"></a>

#### onPlayerTick

Panggil `installExample()` sekali untuk memasang contoh; fungsi hasilnya membaca snapshot event terakhir, atau `nil` sebelum event pertama.

```lua
local function installExample()
    local lastEvent
    onPlayerTick(function(player)
        lastEvent = { player = player }
    end)
    return function()
        return lastEvent
    end
end
```

<a id="api-example-601"></a>

#### onWorldTick

Panggil `installExample()` sekali untuk memasang contoh; fungsi hasilnya membaca snapshot event terakhir, atau `nil` sebelum event pertama.

```lua
local function installExample()
    local lastEvent
    onWorldTick(function(world)
        lastEvent = { world = world }
    end)
    return function()
        return lastEvent
    end
end
```

<a id="api-example-602"></a>

#### onWorldLoaded

Panggil `installExample()` sekali untuk memasang contoh; fungsi hasilnya membaca snapshot event terakhir, atau `nil` sebelum event pertama.

```lua
local function installExample()
    local lastEvent
    onWorldLoaded(function(world)
        lastEvent = { world = world }
    end)
    return function()
        return lastEvent
    end
end
```

<a id="api-example-603"></a>

#### onWorldOffloaded

Panggil `installExample()` sekali untuk memasang contoh; fungsi hasilnya membaca snapshot event terakhir, atau `nil` sebelum event pertama.

```lua
local function installExample()
    local lastEvent
    onWorldOffloaded(function(world)
        lastEvent = { world = world }
    end)
    return function()
        return lastEvent
    end
end
```

<a id="api-example-604"></a>

#### onTick

Panggil `installExample()` sekali untuk memasang contoh; fungsi hasilnya membaca snapshot event terakhir, atau `nil` sebelum event pertama.

```lua
local function installExample()
    local lastEvent
    onTick(function()
        lastEvent = {  }
    end)
    return function()
        return lastEvent
    end
end
```

<a id="api-example-605"></a>

#### onDiscordMessageCreateCallback

Panggil `installExample()` sekali untuk memasang contoh; fungsi hasilnya membaca snapshot event terakhir, atau `nil` sebelum event pertama.

```lua
local function installExample()
    local lastEvent
    onDiscordMessageCreateCallback(function(event)
        lastEvent = { event = event }
    end)
    return function()
        return lastEvent
    end
end
```

<a id="api-example-606"></a>

#### onDiscordButtonClickCallback

Panggil `installExample()` sekali untuk memasang contoh; fungsi hasilnya membaca snapshot event terakhir, atau `nil` sebelum event pertama.

```lua
local function installExample()
    local lastEvent
    onDiscordButtonClickCallback(function(event)
        lastEvent = { event = event }
    end)
    return function()
        return lastEvent
    end
end
```

<a id="api-example-607"></a>

#### onDiscordFormSubmitCallback

Panggil `installExample()` sekali untuk memasang contoh; fungsi hasilnya membaca snapshot event terakhir, atau `nil` sebelum event pertama.

```lua
local function installExample()
    local lastEvent
    onDiscordFormSubmitCallback(function(event)
        lastEvent = { event = event }
    end)
    return function()
        return lastEvent
    end
end
```

<a id="api-example-608"></a>

#### onDiscordBotReadyCallback

Panggil `installExample()` sekali untuk memasang contoh; fungsi hasilnya membaca snapshot event terakhir, atau `nil` sebelum event pertama.

```lua
local function installExample()
    local lastEvent
    onDiscordBotReadyCallback(function()
        lastEvent = {  }
    end)
    return function()
        return lastEvent
    end
end
```

<a id="api-example-609"></a>

#### onDiscordSlashCommandCallback

Panggil `installExample()` sekali untuk memasang contoh; fungsi hasilnya membaca snapshot event terakhir, atau `nil` sebelum event pertama.

```lua
local function installExample()
    local lastEvent
    onDiscordSlashCommandCallback(function(event)
        lastEvent = { event = event }
    end)
    return function()
        return lastEvent
    end
end
```

<a id="api-example-610"></a>

#### onPlayerDungeonEntitySlainCallback

Panggil `installExample()` sekali untuk memasang contoh; fungsi hasilnya membaca snapshot event terakhir, atau `nil` sebelum event pertama.

```lua
local function installExample()
    local lastEvent
    onPlayerDungeonEntitySlainCallback(function(world, player, entityType)
        lastEvent = { world = world, player = player, entityType = entityType }
    end)
    return function()
        return lastEvent
    end
end
```

<a id="api-example-611"></a>

#### onPlayerStartopiaCallback

Panggil `installExample()` sekali untuk memasang contoh; fungsi hasilnya membaca snapshot event terakhir, atau `nil` sebelum event pertama.

```lua
local function installExample()
    local lastEvent
    onPlayerStartopiaCallback(function(world, player, rewardID, rewardAmount, statusID)
        lastEvent = { world = world, player = player, rewardID = rewardID, rewardAmount = rewardAmount, statusID = statusID }
    end)
    return function()
        return lastEvent
    end
end
```

<a id="api-example-612"></a>

#### onPlayerPunchCallback

Panggil `installExample()` sekali untuk memasang contoh; fungsi hasilnya membaca snapshot event terakhir, atau `nil` sebelum event pertama.

```lua
local function installExample()
    local lastEvent
    onPlayerPunchCallback(function(world, player, x, y)
        lastEvent = { world = world, player = player, x = x, y = y }
    end)
    return function()
        return lastEvent
    end
end
```

<a id="api-example-613"></a>

#### onPlayerCookingCallback

Panggil `installExample()` sekali untuk memasang contoh; fungsi hasilnya membaca snapshot event terakhir, atau `nil` sebelum event pertama.

```lua
local function installExample()
    local lastEvent
    onPlayerCookingCallback(function(world, player, resultID, resultAmount, accuracy)
        lastEvent = { world = world, player = player, resultID = resultID, resultAmount = resultAmount, accuracy = accuracy }
    end)
    return function()
        return lastEvent
    end
end
```

<a id="api-example-614"></a>

#### onHTTPRequest

Panggil `installExample()` sekali untuk memasang contoh; fungsi hasilnya membaca snapshot event terakhir, atau `nil` sebelum event pertama.

```lua
local function installExample()
    local lastEvent
    onHTTPRequest(function(request)
        lastEvent = { request = request }
    end)
    return function()
        return lastEvent
    end
end
```

<a id="api-example-615"></a>

#### onPlayerActivateTileCallback

Panggil `installExample()` sekali untuk memasang contoh; fungsi hasilnya membaca snapshot event terakhir, atau `nil` sebelum event pertama.

```lua
local function installExample()
    local lastEvent
    onPlayerActivateTileCallback(function(world, player, tile)
        lastEvent = { world = world, player = player, tile = tile }
    end)
    return function()
        return lastEvent
    end
end
```

<a id="api-example-616"></a>

#### onPlayerVendingBuyCallback

Panggil `installExample()` sekali untuk memasang contoh; fungsi hasilnya membaca snapshot event terakhir, atau `nil` sebelum event pertama.

```lua
local function installExample()
    local lastEvent
    onPlayerVendingBuyCallback(function(world, player, tile, itemID, itemCount)
        lastEvent = { world = world, player = player, tile = tile, itemID = itemID, itemCount = itemCount }
    end)
    return function()
        return lastEvent
    end
end
```

<a id="api-example-617"></a>

#### onPlayerSpliceSeedCallback

Panggil `installExample()` sekali untuk memasang contoh; fungsi hasilnya membaca snapshot event terakhir, atau `nil` sebelum event pertama.

```lua
local function installExample()
    local lastEvent
    onPlayerSpliceSeedCallback(function(world, player, tile, seedID)
        lastEvent = { world = world, player = player, tile = tile, seedID = seedID }
    end)
    return function()
        return lastEvent
    end
end
```

<a id="api-example-618"></a>

#### onPlayerCardBattleCallback

Panggil `installExample()` sekali untuk memasang contoh; fungsi hasilnya membaca snapshot event terakhir, atau `nil` sebelum event pertama.

```lua
local function installExample()
    local lastEvent
    onPlayerCardBattleCallback(function(world, player, targetPlayer, rewardID, rewardAmount)
        lastEvent = { world = world, player = player, targetPlayer = targetPlayer, rewardID = rewardID, rewardAmount = rewardAmount }
    end)
    return function()
        return lastEvent
    end
end
```

<a id="api-example-619"></a>

#### onPlayerDepositCallback

Panggil `installExample()` sekali untuk memasang contoh; fungsi hasilnya membaca snapshot event terakhir, atau `nil` sebelum event pertama.

```lua
local function installExample()
    local lastEvent
    onPlayerDepositCallback(function(world, player, tile, itemID, itemCount)
        lastEvent = { world = world, player = player, tile = tile, itemID = itemID, itemCount = itemCount }
    end)
    return function()
        return lastEvent
    end
end
```

<a id="api-example-620"></a>

#### onGetTileExtraDataCallback

Panggil `installExample()` sekali untuk memasang contoh; fungsi hasilnya membaca snapshot event terakhir, atau `nil` sebelum event pertama.

```lua
local function installExample()
    local lastEvent
    onGetTileExtraDataCallback(function(world, tile, gameVersion, refPlayer)
        lastEvent = { world = world, tile = tile, gameVersion = gameVersion, refPlayer = refPlayer }
    end)
    return function()
        return lastEvent
    end
end
```

<a id="api-example-621"></a>

#### onPlayerRoleChangedCallback

Panggil `installExample()` sekali untuk memasang contoh; fungsi hasilnya membaca snapshot event terakhir, atau `nil` sebelum event pertama.

```lua
local function installExample()
    local lastEvent
    onPlayerRoleChangedCallback(function(player, newRoleID, oldRoleID)
        lastEvent = { player = player, newRoleID = newRoleID, oldRoleID = oldRoleID }
    end)
    return function()
        return lastEvent
    end
end
```

<a id="api-example-622"></a>

#### onPlayerLoseCardBattleCallback

Panggil `installExample()` sekali untuk memasang contoh; fungsi hasilnya membaca snapshot event terakhir, atau `nil` sebelum event pertama.

```lua
local function installExample()
    local lastEvent
    onPlayerLoseCardBattleCallback(function(world, player, targetPlayer)
        lastEvent = { world = world, player = player, targetPlayer = targetPlayer }
    end)
    return function()
        return lastEvent
    end
end
```

<a id="api-example-623"></a>

#### onLeaderboardEndCallback

Panggil `installExample()` sekali untuk memasang contoh; fungsi hasilnya membaca snapshot event terakhir, atau `nil` sebelum event pertama.

```lua
local function installExample()
    local lastEvent
    onLeaderboardEndCallback(function(player, leaderboardType, rank)
        lastEvent = { player = player, leaderboardType = leaderboardType, rank = rank }
    end)
    return function()
        return lastEvent
    end
end
```

<a id="api-example-624"></a>

#### onPlayerEarnAchievementCallback

Panggil `installExample()` sekali untuk memasang contoh; fungsi hasilnya membaca snapshot event terakhir, atau `nil` sebelum event pertama.

```lua
local function installExample()
    local lastEvent
    onPlayerEarnAchievementCallback(function(world, player, achievementType)
        lastEvent = { world = world, player = player, achievementType = achievementType }
    end)
    return function()
        return lastEvent
    end
end
```

<a id="api-example-625"></a>

#### onPlayerSewCallback

Panggil `installExample()` sekali untuk memasang contoh; fungsi hasilnya membaca snapshot event terakhir, atau `nil` sebelum event pertama.

```lua
local function installExample()
    local lastEvent
    onPlayerSewCallback(function(world, player, resultID, resultAmount)
        lastEvent = { world = world, player = player, resultID = resultID, resultAmount = resultAmount }
    end)
    return function()
        return lastEvent
    end
end
```

<a id="api-example-626"></a>

#### onPlayerPetBattleCallback

Panggil `installExample()` sekali untuk memasang contoh; fungsi hasilnya membaca snapshot event terakhir, atau `nil` sebelum event pertama.

```lua
local function installExample()
    local lastEvent
    onPlayerPetBattleCallback(function(world, player, targetPlayer)
        lastEvent = { world = world, player = player, targetPlayer = targetPlayer }
    end)
    return function()
        return lastEvent
    end
end
```

<a id="api-example-627"></a>

#### onPlayerGemsChangedCallback

Panggil `installExample()` sekali untuk memasang contoh; fungsi hasilnya membaca snapshot event terakhir, atau `nil` sebelum event pertama.

```lua
local function installExample()
    local lastEvent
    onPlayerGemsChangedCallback(function(world, player, previousGems)
        lastEvent = { world = world, player = player, previousGems = previousGems }
    end)
    return function()
        return lastEvent
    end
end
```

<a id="api-example-628"></a>

#### onPlayerCoinsChangedCallback

Panggil `installExample()` sekali untuk memasang contoh; fungsi hasilnya membaca snapshot event terakhir, atau `nil` sebelum event pertama.

```lua
local function installExample()
    local lastEvent
    onPlayerCoinsChangedCallback(function(world, player, previousCoins)
        lastEvent = { world = world, player = player, previousCoins = previousCoins }
    end)
    return function()
        return lastEvent
    end
end
```

<a id="api-example-629"></a>

#### onPlayerPlaymodAddedCallback

Panggil `installExample()` sekali untuk memasang contoh; fungsi hasilnya membaca snapshot event terakhir, atau `nil` sebelum event pertama.

```lua
local function installExample()
    local lastEvent
    onPlayerPlaymodAddedCallback(function(player, modType, lastsForSeconds, applier)
        lastEvent = { player = player, modType = modType, lastsForSeconds = lastsForSeconds, applier = applier }
    end)
    return function()
        return lastEvent
    end
end
```

<a id="api-example-630"></a>

#### onPlayerPlaymodRemovedCallback

Panggil `installExample()` sekali untuk memasang contoh; fungsi hasilnya membaca snapshot event terakhir, atau `nil` sebelum event pertama.

```lua
local function installExample()
    local lastEvent
    onPlayerPlaymodRemovedCallback(function(player, modType)
        lastEvent = { player = player, modType = modType }
    end)
    return function()
        return lastEvent
    end
end
```

<a id="api-example-631"></a>

#### onPlayerFishingStatusCallback

Panggil `installExample()` sekali untuk memasang contoh; fungsi hasilnya membaca snapshot event terakhir, atau `nil` sebelum event pertama.

```lua
local function installExample()
    local lastEvent
    onPlayerFishingStatusCallback(function(world, player, tile, status, itemID)
        lastEvent = { world = world, player = player, tile = tile, status = status, itemID = itemID }
    end)
    return function()
        return lastEvent
    end
end
```

<a id="api-example-632"></a>

#### onPlayerStateChangedCallback

Panggil `installExample()` sekali untuk memasang contoh; fungsi hasilnya membaca snapshot event terakhir, atau `nil` sebelum event pertama.

```lua
local function installExample()
    local lastEvent
    onPlayerStateChangedCallback(function(world, player, new_state, old_state)
        lastEvent = { world = world, player = player, new_state = new_state, old_state = old_state }
    end)
    return function()
        return lastEvent
    end
end
```

<a id="api-example-633"></a>

#### onPlayerMovedCallback

Panggil `installExample()` sekali untuk memasang contoh; fungsi hasilnya membaca snapshot event terakhir, atau `nil` sebelum event pertama.

```lua
local function installExample()
    local lastEvent
    onPlayerMovedCallback(function(world, player, current_x, current_y, previous_x, previous_y)
        lastEvent = { world = world, player = player, current_x = current_x, current_y = current_y, previous_x = previous_x, previous_y = previous_y }
    end)
    return function()
        return lastEvent
    end
end
```

<a id="api-example-634"></a>

#### onServerStopCallback

Panggil `installExample()` sekali untuk memasang contoh; fungsi hasilnya membaca snapshot event terakhir, atau `nil` sebelum event pertama.

```lua
local function installExample()
    local lastEvent
    onServerStopCallback(function()
        lastEvent = {  }
    end)
    return function()
        return lastEvent
    end
end
```

<a id="api-example-635"></a>

#### onPlayerInfectCallback

Panggil `installExample()` sekali untuk memasang contoh; fungsi hasilnya membaca snapshot event terakhir, atau `nil` sebelum event pertama.

```lua
local function installExample()
    local lastEvent
    onPlayerInfectCallback(function(world, player, targetPlayer)
        lastEvent = { world = world, player = player, targetPlayer = targetPlayer }
    end)
    return function()
        return lastEvent
    end
end
```

<a id="api-example-636"></a>

#### onNameChangedCallback

Panggil `installExample()` sekali untuk memasang contoh; fungsi hasilnya membaca snapshot event terakhir, atau `nil` sebelum event pertama.

```lua
local function installExample()
    local lastEvent
    onNameChangedCallback(function(world, player, oldName, changeType)
        lastEvent = { world = world, player = player, oldName = oldName, changeType = changeType }
    end)
    return function()
        return lastEvent
    end
end
```

<a id="api-example-637"></a>

#### onPlayerRetrieveCallback

Panggil `installExample()` sekali untuk memasang contoh; fungsi hasilnya membaca snapshot event terakhir, atau `nil` sebelum event pertama.

```lua
local function installExample()
    local lastEvent
    onPlayerRetrieveCallback(function(world, player, itemID, itemCount, tile)
        lastEvent = { world = world, player = player, itemID = itemID, itemCount = itemCount, tile = tile }
    end)
    return function()
        return lastEvent
    end
end
```

<a id="api-example-638"></a>

#### onToolsUsedCallback

Panggil `installExample()` sekali untuk memasang contoh; fungsi hasilnya membaca snapshot event terakhir, atau `nil` sebelum event pertama.

```lua
local function installExample()
    local lastEvent
    onToolsUsedCallback(function(world, player, toolType, itemID, count)
        lastEvent = { world = world, player = player, toolType = toolType, itemID = itemID, count = count }
    end)
    return function()
        return lastEvent
    end
end
```

---

<a id="examples-globals"></a>

### Global Functions

Referensi: [Global Functions](https://dash.gtps.cloud/docs/globals).

<a id="api-example-639"></a>

#### registerLuaPlaymod(config)

Argumen fungsi berasal dari pemanggil; tidak ada nilai ID, konfigurasi, atau struktur packet yang diasumsikan.

Hasil yang didokumentasikan: `number`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(config)
    return registerLuaPlaymod(config)
end
```

<a id="api-example-640"></a>

#### registerLuaCommand(config)

Argumen fungsi berasal dari pemanggil; tidak ada nilai ID, konfigurasi, atau struktur packet yang diasumsikan.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(config)
    return registerLuaCommand(config)
end
```

<a id="api-example-641"></a>

#### registerLuaEvent(config)

Argumen fungsi berasal dari pemanggil; tidak ada nilai ID, konfigurasi, atau struktur packet yang diasumsikan.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(config)
    return registerLuaEvent(config)
end
```

<a id="api-example-642"></a>

#### registerLuaDailyEvent(config)

Argumen fungsi berasal dari pemanggil; tidak ada nilai ID, konfigurasi, atau struktur packet yang diasumsikan.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(config)
    return registerLuaDailyEvent(config)
end
```

<a id="api-example-643"></a>

#### registerLuaAchievement(config)

Argumen fungsi berasal dari pemanggil; tidak ada nilai ID, konfigurasi, atau struktur packet yang diasumsikan.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(config)
    return registerLuaAchievement(config)
end
```

<a id="api-example-644"></a>

#### registerLuaItem(config)

Argumen fungsi berasal dari pemanggil; tidak ada nilai ID, konfigurasi, atau struktur packet yang diasumsikan.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(config)
    return registerLuaItem(config)
end
```

<a id="api-example-645"></a>

#### getItem(itemID)

Argumen fungsi berasal dari pemanggil; tidak ada nilai ID, konfigurasi, atau struktur packet yang diasumsikan.

Hasil yang didokumentasikan: `Item`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(itemID)
    return getItem(itemID)
end
```

<a id="api-example-646"></a>

#### getItemsCount()

Argumen fungsi berasal dari pemanggil; tidak ada nilai ID, konfigurasi, atau struktur packet yang diasumsikan.

Hasil yang didokumentasikan: `number`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example()
    return getItemsCount()
end
```

<a id="api-example-647"></a>

#### getMaxItems()

Argumen fungsi berasal dari pemanggil; tidak ada nilai ID, konfigurasi, atau struktur packet yang diasumsikan.

Hasil yang didokumentasikan: `number`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example()
    return getMaxItems()
end
```

<a id="api-example-648"></a>

#### getRealGTItemsCount()

Argumen fungsi berasal dari pemanggil; tidak ada nilai ID, konfigurasi, atau struktur packet yang diasumsikan.

Hasil yang didokumentasikan: `number`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example()
    return getRealGTItemsCount()
end
```

<a id="api-example-649"></a>

#### getServerPlayers()

Argumen fungsi berasal dari pemanggil; tidak ada nilai ID, konfigurasi, atau struktur packet yang diasumsikan.

Hasil yang didokumentasikan: `{Player}`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example()
    return getServerPlayers()
end
```

<a id="api-example-650"></a>

#### getServerWorlds()

Argumen fungsi berasal dari pemanggil; tidak ada nilai ID, konfigurasi, atau struktur packet yang diasumsikan.

Hasil yang didokumentasikan: `{World}`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example()
    return getServerWorlds()
end
```

<a id="api-example-651"></a>

#### getAllPlayers()

Argumen fungsi berasal dari pemanggil; tidak ada nilai ID, konfigurasi, atau struktur packet yang diasumsikan.

Hasil yang didokumentasikan: `{Player}`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example()
    return getAllPlayers()
end
```

<a id="api-example-652"></a>

#### getAllWorlds()

Argumen fungsi berasal dari pemanggil; tidak ada nilai ID, konfigurasi, atau struktur packet yang diasumsikan.

Hasil yang didokumentasikan: `{World}`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example()
    return getAllWorlds()
end
```

<a id="api-example-653"></a>

#### getAllGuilds()

Argumen fungsi berasal dari pemanggil; tidak ada nilai ID, konfigurasi, atau struktur packet yang diasumsikan.

Hasil yang didokumentasikan: `{Guild}`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example()
    return getAllGuilds()
end
```

<a id="api-example-654"></a>

#### reloadScripts()

Argumen fungsi berasal dari pemanggil; tidak ada nilai ID, konfigurasi, atau struktur packet yang diasumsikan.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example()
    return reloadScripts()
end
```

<a id="api-example-655"></a>

#### reloadConfigs()

Argumen fungsi berasal dari pemanggil; tidak ada nilai ID, konfigurasi, atau struktur packet yang diasumsikan.

Hasil yang didokumentasikan: `boolean`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example()
    return reloadConfigs()
end
```

<a id="api-example-656"></a>

#### reloadItems()

Argumen fungsi berasal dari pemanggil; tidak ada nilai ID, konfigurasi, atau struktur packet yang diasumsikan.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example()
    return reloadItems()
end
```

<a id="api-example-657"></a>

#### getPlayer(userID)

Argumen fungsi berasal dari pemanggil; tidak ada nilai ID, konfigurasi, atau struktur packet yang diasumsikan.

Hasil yang didokumentasikan: `Player`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(userID)
    return getPlayer(userID)
end
```

<a id="api-example-658"></a>

#### getPlayerByName(playerName, client)

Argumen fungsi berasal dari pemanggil; tidak ada nilai ID, konfigurasi, atau struktur packet yang diasumsikan.

Hasil yang didokumentasikan: `{Player}`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(playerName, client)
    return getPlayerByName(playerName, client)
end
```

<a id="api-example-659"></a>

#### savePlayer(player)

Argumen fungsi berasal dari pemanggil; tidak ada nilai ID, konfigurasi, atau struktur packet yang diasumsikan.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player)
    return savePlayer(player)
end
```

<a id="api-example-660"></a>

#### getActiveDailyOffers()

Argumen fungsi berasal dari pemanggil; tidak ada nilai ID, konfigurasi, atau struktur packet yang diasumsikan.

Hasil yang didokumentasikan: `{ShopItem}`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example()
    return getActiveDailyOffers()
end
```

<a id="api-example-661"></a>

#### getEventOffers()

Argumen fungsi berasal dari pemanggil; tidak ada nilai ID, konfigurasi, atau struktur packet yang diasumsikan.

Hasil yang didokumentasikan: `{ShopItem}`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example()
    return getEventOffers()
end
```

<a id="api-example-662"></a>

#### getCurrentServerEvent()

Argumen fungsi berasal dari pemanggil; tidak ada nilai ID, konfigurasi, atau struktur packet yang diasumsikan.

Hasil yang didokumentasikan: `number`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example()
    return getCurrentServerEvent()
end
```

<a id="api-example-663"></a>

#### getCurrentServerDailyEvent()

Argumen fungsi berasal dari pemanggil; tidak ada nilai ID, konfigurasi, atau struktur packet yang diasumsikan.

Hasil yang didokumentasikan: `number`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example()
    return getCurrentServerDailyEvent()
end
```

<a id="api-example-664"></a>

#### getStoreItems()

Argumen fungsi berasal dari pemanggil; tidak ada nilai ID, konfigurasi, atau struktur packet yang diasumsikan.

Hasil yang didokumentasikan: `{ShopItem}`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example()
    return getStoreItems()
end
```

<a id="api-example-665"></a>

#### getIOTMItem(itemID)

Argumen fungsi berasal dari pemanggil; tidak ada nilai ID, konfigurasi, atau struktur packet yang diasumsikan.

Hasil yang didokumentasikan: `IOTM`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(itemID)
    return getIOTMItem(itemID)
end
```

<a id="api-example-666"></a>

#### getEasterBuyTime(userID)

Argumen fungsi berasal dari pemanggil; tidak ada nilai ID, konfigurasi, atau struktur packet yang diasumsikan.

Hasil yang didokumentasikan: `number`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(userID)
    return getEasterBuyTime(userID)
end
```

<a id="api-example-667"></a>

#### isDailyOfferPurchased(userID, storeItemID)

Argumen fungsi berasal dari pemanggil; tidak ada nilai ID, konfigurasi, atau struktur packet yang diasumsikan.

Hasil yang didokumentasikan: `boolean`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(userID, storeItemID)
    return isDailyOfferPurchased(userID, storeItemID)
end
```

<a id="api-example-668"></a>

#### addDailyOfferPurchased(userID, storeItemID)

Argumen fungsi berasal dari pemanggil; tidak ada nilai ID, konfigurasi, atau struktur packet yang diasumsikan.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(userID, storeItemID)
    return addDailyOfferPurchased(userID, storeItemID)
end
```

<a id="api-example-669"></a>

#### getEasterEggs(userID)

Argumen fungsi berasal dari pemanggil; tidak ada nilai ID, konfigurasi, atau struktur packet yang diasumsikan.

Hasil yang didokumentasikan: `number`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(userID)
    return getEasterEggs(userID)
end
```

<a id="api-example-670"></a>

#### formatStoreTime(targetTime, currentTime)

Argumen fungsi berasal dari pemanggil; tidak ada nilai ID, konfigurasi, atau struktur packet yang diasumsikan.

Hasil yang didokumentasikan: `string`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(targetTime, currentTime)
    return formatStoreTime(targetTime, currentTime)
end
```

<a id="api-example-671"></a>

#### getTopPlayerByBalance()

Argumen fungsi berasal dari pemanggil; tidak ada nilai ID, konfigurasi, atau struktur packet yang diasumsikan.

Hasil yang didokumentasikan: `Player`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example()
    return getTopPlayerByBalance()
end
```

<a id="api-example-672"></a>

#### getTopWorldByVisitors()

Argumen fungsi berasal dari pemanggil; tidak ada nilai ID, konfigurasi, atau struktur packet yang diasumsikan.

Hasil yang didokumentasikan: `World`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example()
    return getTopWorldByVisitors()
end
```

<a id="api-example-673"></a>

#### print(...)

Argumen fungsi berasal dari pemanggil; tidak ada nilai ID, konfigurasi, atau struktur packet yang diasumsikan.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(...)
    return print(...)
end
```

<a id="api-example-674"></a>

#### getServerName()

Argumen fungsi berasal dari pemanggil; tidak ada nilai ID, konfigurasi, atau struktur packet yang diasumsikan.

Hasil yang didokumentasikan: `string`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example()
    return getServerName()
end
```

<a id="api-example-675"></a>

#### getServerID()

Argumen fungsi berasal dari pemanggil; tidak ada nilai ID, konfigurasi, atau struktur packet yang diasumsikan.

Hasil yang didokumentasikan: `number`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example()
    return getServerID()
end
```

<a id="api-example-676"></a>

#### getNewsBanner()

Argumen fungsi berasal dari pemanggil; tidak ada nilai ID, konfigurasi, atau struktur packet yang diasumsikan.

Hasil yang didokumentasikan: `string`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example()
    return getNewsBanner()
end
```

<a id="api-example-677"></a>

#### getNewsBannerDimensions()

Argumen fungsi berasal dari pemanggil; tidak ada nilai ID, konfigurasi, atau struktur packet yang diasumsikan.

Hasil yang didokumentasikan: `string`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example()
    return getNewsBannerDimensions()
end
```

<a id="api-example-678"></a>

#### getTodaysDate()

Argumen fungsi berasal dari pemanggil; tidak ada nilai ID, konfigurasi, atau struktur packet yang diasumsikan.

Hasil yang didokumentasikan: `string`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example()
    return getTodaysDate()
end
```

<a id="api-example-679"></a>

#### getTodaysEvents()

Argumen fungsi berasal dari pemanggil; tidak ada nilai ID, konfigurasi, atau struktur packet yang diasumsikan.

Hasil yang didokumentasikan: `string`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example()
    return getTodaysEvents()
end
```

<a id="api-example-680"></a>

#### getMaxLevel()

Argumen fungsi berasal dari pemanggil; tidak ada nilai ID, konfigurasi, atau struktur packet yang diasumsikan.

Hasil yang didokumentasikan: `number`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example()
    return getMaxLevel()
end
```

<a id="api-example-681"></a>

#### getCurrentEventDescription()

Argumen fungsi berasal dari pemanggil; tidak ada nilai ID, konfigurasi, atau struktur packet yang diasumsikan.

Hasil yang didokumentasikan: `string`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example()
    return getCurrentEventDescription()
end
```

<a id="api-example-682"></a>

#### getCurrentDailyEventDescription()

Argumen fungsi berasal dari pemanggil; tidak ada nilai ID, konfigurasi, atau struktur packet yang diasumsikan.

Hasil yang didokumentasikan: `string`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example()
    return getCurrentDailyEventDescription()
end
```

<a id="api-example-683"></a>

#### getCurrentRoleDayDescription()

Argumen fungsi berasal dari pemanggil; tidak ada nilai ID, konfigurasi, atau struktur packet yang diasumsikan.

Hasil yang didokumentasikan: `string`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example()
    return getCurrentRoleDayDescription()
end
```

<a id="api-example-684"></a>

#### resetColor(message)

Argumen fungsi berasal dari pemanggil; tidak ada nilai ID, konfigurasi, atau struktur packet yang diasumsikan.

Hasil yang didokumentasikan: `string`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(message)
    return resetColor(message)
end
```

<a id="api-example-685"></a>

#### formatTime(targetTime, currentTime)

Argumen fungsi berasal dari pemanggil; tidak ada nilai ID, konfigurasi, atau struktur packet yang diasumsikan.

Hasil yang didokumentasikan: `string`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(targetTime, currentTime)
    return formatTime(targetTime, currentTime)
end
```

<a id="api-example-686"></a>

#### getAchievementsCount()

Argumen fungsi berasal dari pemanggil; tidak ada nilai ID, konfigurasi, atau struktur packet yang diasumsikan.

Hasil yang didokumentasikan: `number`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example()
    return getAchievementsCount()
end
```

<a id="api-example-687"></a>

#### getWorld(WorldID)

Argumen fungsi berasal dari pemanggil; tidak ada nilai ID, konfigurasi, atau struktur packet yang diasumsikan.

Hasil yang didokumentasikan: `World`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(WorldID)
    return getWorld(WorldID)
end
```

<a id="api-example-688"></a>

#### getGuild(GuildID)

Argumen fungsi berasal dari pemanggil; tidak ada nilai ID, konfigurasi, atau struktur packet yang diasumsikan.

Hasil yang didokumentasikan: `Guild`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(GuildID)
    return getGuild(GuildID)
end
```

<a id="api-example-689"></a>

#### getWorldByName(worldName)

Argumen fungsi berasal dari pemanggil; tidak ada nilai ID, konfigurasi, atau struktur packet yang diasumsikan.

Hasil yang didokumentasikan: `World`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(worldName)
    return getWorldByName(worldName)
end
```

<a id="api-example-690"></a>

#### saveWorld(world)

Argumen fungsi berasal dari pemanggil; tidak ada nilai ID, konfigurasi, atau struktur packet yang diasumsikan.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(world)
    return saveWorld(world)
end
```

<a id="api-example-691"></a>

#### worldExists(worldName)

Argumen fungsi berasal dari pemanggil; tidak ada nilai ID, konfigurasi, atau struktur packet yang diasumsikan.

Hasil yang didokumentasikan: `boolean`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(worldName)
    return worldExists(worldName)
end
```

<a id="api-example-692"></a>

#### getActiveWorlds()

Argumen fungsi berasal dari pemanggil; tidak ada nilai ID, konfigurasi, atau struktur packet yang diasumsikan.

Hasil yang didokumentasikan: `{World}`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example()
    return getActiveWorlds()
end
```

<a id="api-example-693"></a>

#### getCorruptedSouls(userID)

Argumen fungsi berasal dari pemanggil; tidak ada nilai ID, konfigurasi, atau struktur packet yang diasumsikan.

Hasil yang didokumentasikan: `number`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(userID)
    return getCorruptedSouls(userID)
end
```

<a id="api-example-694"></a>

#### saveDataToServer(uniqueID, data)

Argumen fungsi berasal dari pemanggil; tidak ada nilai ID, konfigurasi, atau struktur packet yang diasumsikan.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(uniqueID, data)
    return saveDataToServer(uniqueID, data)
end
```

<a id="api-example-695"></a>

#### loadDataFromServer(uniqueID)

Argumen fungsi berasal dari pemanggil; tidak ada nilai ID, konfigurasi, atau struktur packet yang diasumsikan.

Hasil yang didokumentasikan: `{any}`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(uniqueID)
    return loadDataFromServer(uniqueID)
end
```

<a id="api-example-696"></a>

#### saveStringToServer(uniqueID, data)

Argumen fungsi berasal dari pemanggil; tidak ada nilai ID, konfigurasi, atau struktur packet yang diasumsikan.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(uniqueID, data)
    return saveStringToServer(uniqueID, data)
end
```

<a id="api-example-697"></a>

#### loadStringFromServer(uniqueID)

Argumen fungsi berasal dari pemanggil; tidak ada nilai ID, konfigurasi, atau struktur packet yang diasumsikan.

Hasil yang didokumentasikan: `string`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(uniqueID)
    return loadStringFromServer(uniqueID)
end
```

<a id="api-example-698"></a>

#### addWorldMenuWorld(world_id, display_name, decimal_color, is_priority)

Argumen fungsi berasal dari pemanggil; tidak ada nilai ID, konfigurasi, atau struktur packet yang diasumsikan.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(world_id, display_name, decimal_color, is_priority)
    return addWorldMenuWorld(world_id, display_name, decimal_color, is_priority)
end
```

<a id="api-example-699"></a>

#### removeWorldMenuWorld(world_id)

Argumen fungsi berasal dari pemanggil; tidak ada nilai ID, konfigurasi, atau struktur packet yang diasumsikan.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(world_id)
    return removeWorldMenuWorld(world_id)
end
```

<a id="api-example-700"></a>

#### hideWorldMenuDefaultSpecialWorlds(hide_default_special_worlds)

Argumen fungsi berasal dari pemanggil; tidak ada nilai ID, konfigurasi, atau struktur packet yang diasumsikan.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(hide_default_special_worlds)
    return hideWorldMenuDefaultSpecialWorlds(hide_default_special_worlds)
end
```

<a id="api-example-701"></a>

#### addSocialPortalButton(button_data, callback)

Argumen fungsi berasal dari pemanggil; tidak ada nilai ID, konfigurasi, atau struktur packet yang diasumsikan.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(button_data, callback)
    return addSocialPortalButton(button_data, callback)
end
```

<a id="api-example-702"></a>

#### getCurrencyShortName()

Argumen fungsi berasal dari pemanggil; tidak ada nilai ID, konfigurasi, atau struktur packet yang diasumsikan.

Hasil yang didokumentasikan: `string`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example()
    return getCurrencyShortName()
end
```

<a id="api-example-703"></a>

#### getCurrencyLongName()

Argumen fungsi berasal dari pemanggil; tidak ada nilai ID, konfigurasi, atau struktur packet yang diasumsikan.

Hasil yang didokumentasikan: `string`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example()
    return getCurrencyLongName()
end
```

<a id="api-example-704"></a>

#### getCurrencyMediumName()

Argumen fungsi berasal dari pemanggil; tidak ada nilai ID, konfigurasi, atau struktur packet yang diasumsikan.

Hasil yang didokumentasikan: `string`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example()
    return getCurrencyMediumName()
end
```

<a id="api-example-705"></a>

#### getCurrencyIcon()

Argumen fungsi berasal dari pemanggil; tidak ada nilai ID, konfigurasi, atau struktur packet yang diasumsikan.

Hasil yang didokumentasikan: `string`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example()
    return getCurrencyIcon()
end
```

<a id="api-example-706"></a>

#### addSidebarButton(sidebar_button)

Argumen fungsi berasal dari pemanggil; tidak ada nilai ID, konfigurasi, atau struktur packet yang diasumsikan.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(sidebar_button)
    return addSidebarButton(sidebar_button)
end
```

<a id="api-example-707"></a>

#### removeSidebarButton(sidebar_button_name)

Argumen fungsi berasal dari pemanggil; tidak ada nilai ID, konfigurasi, atau struktur packet yang diasumsikan.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(sidebar_button_name)
    return removeSidebarButton(sidebar_button_name)
end
```

<a id="api-example-708"></a>

#### parseText(str)

Argumen fungsi berasal dari pemanggil; tidak ada nilai ID, konfigurasi, atau struktur packet yang diasumsikan.

Hasil yang didokumentasikan: `{string}`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(str)
    return parseText(str)
end
```

<a id="api-example-709"></a>

#### getBlessingName(blessingID)

Argumen fungsi berasal dari pemanggil; tidak ada nilai ID, konfigurasi, atau struktur packet yang diasumsikan.

Hasil yang didokumentasikan: `string`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(blessingID)
    return getBlessingName(blessingID)
end
```

<a id="api-example-710"></a>

#### getBlessingInfo(blessingID)

Argumen fungsi berasal dari pemanggil; tidak ada nilai ID, konfigurasi, atau struktur packet yang diasumsikan.

Hasil yang didokumentasikan: `string`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(blessingID)
    return getBlessingInfo(blessingID)
end
```

<a id="api-example-711"></a>

#### getBlessingRarity(blessingID)

Argumen fungsi berasal dari pemanggil; tidak ada nilai ID, konfigurasi, atau struktur packet yang diasumsikan.

Hasil yang didokumentasikan: `string`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(blessingID)
    return getBlessingRarity(blessingID)
end
```

<a id="api-example-712"></a>

#### setGemEvent(boostGem)

Argumen fungsi berasal dari pemanggil; tidak ada nilai ID, konfigurasi, atau struktur packet yang diasumsikan.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(boostGem)
    return setGemEvent(boostGem)
end
```

<a id="api-example-713"></a>

#### setXPEvent(boostXp)

Argumen fungsi berasal dari pemanggil; tidak ada nilai ID, konfigurasi, atau struktur packet yang diasumsikan.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(boostXp)
    return setXPEvent(boostXp)
end
```

<a id="api-example-714"></a>

#### getGemEvent()

Argumen fungsi berasal dari pemanggil; tidak ada nilai ID, konfigurasi, atau struktur packet yang diasumsikan.

Hasil yang didokumentasikan: `number`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example()
    return getGemEvent()
end
```

<a id="api-example-715"></a>

#### getXPEvent()

Argumen fungsi berasal dari pemanggil; tidak ada nilai ID, konfigurasi, atau struktur packet yang diasumsikan.

Hasil yang didokumentasikan: `number`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example()
    return getXPEvent()
end
```

<a id="api-example-716"></a>

#### setEvent(event_id)

Argumen fungsi berasal dari pemanggil; tidak ada nilai ID, konfigurasi, atau struktur packet yang diasumsikan.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(event_id)
    return setEvent(event_id)
end
```

<a id="api-example-717"></a>

#### setDailyEvent(daily_event_id)

Argumen fungsi berasal dari pemanggil; tidak ada nilai ID, konfigurasi, atau struktur packet yang diasumsikan.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(daily_event_id)
    return setDailyEvent(daily_event_id)
end
```

<a id="api-example-718"></a>

#### queueRestart(in_seconds, full_restart, message)

Argumen fungsi berasal dari pemanggil; tidak ada nilai ID, konfigurasi, atau struktur packet yang diasumsikan.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(in_seconds, full_restart, message)
    return queueRestart(in_seconds, full_restart, message)
end
```

<a id="api-example-719"></a>

#### getRoles()

Argumen fungsi berasal dari pemanggil; tidak ada nilai ID, konfigurasi, atau struktur packet yang diasumsikan.

Hasil yang didokumentasikan: `{any}`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example()
    return getRoles()
end
```

<a id="api-example-720"></a>

#### getTitles()

Argumen fungsi berasal dari pemanggil; tidak ada nilai ID, konfigurasi, atau struktur packet yang diasumsikan.

Hasil yang didokumentasikan: `{any}`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example()
    return getTitles()
end
```

<a id="api-example-721"></a>

#### getPlaymods()

Argumen fungsi berasal dari pemanggil; tidak ada nilai ID, konfigurasi, atau struktur packet yang diasumsikan.

Hasil yang didokumentasikan: `{any}`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example()
    return getPlaymods()
end
```

<a id="api-example-722"></a>

#### getHighestPriorityRole()

Argumen fungsi berasal dari pemanggil; tidak ada nilai ID, konfigurasi, atau struktur packet yang diasumsikan.

Hasil yang didokumentasikan: `any`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example()
    return getHighestPriorityRole()
end
```

<a id="api-example-723"></a>

#### getEcoQuantity(itemID)

Argumen fungsi berasal dari pemanggil; tidak ada nilai ID, konfigurasi, atau struktur packet yang diasumsikan.

Hasil yang didokumentasikan: `number`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(itemID)
    return getEcoQuantity(itemID)
end
```

<a id="api-example-724"></a>

#### getEcoQuantityPlayers(itemID)

Argumen fungsi berasal dari pemanggil; tidak ada nilai ID, konfigurasi, atau struktur packet yang diasumsikan.

Hasil yang didokumentasikan: `number`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(itemID)
    return getEcoQuantityPlayers(itemID)
end
```

<a id="api-example-725"></a>

#### getEcoQuantityWorlds(itemID)

Argumen fungsi berasal dari pemanggil; tidak ada nilai ID, konfigurasi, atau struktur packet yang diasumsikan.

Hasil yang didokumentasikan: `number`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(itemID)
    return getEcoQuantityWorlds(itemID)
end
```

<a id="api-example-726"></a>

#### createRedeemCode(config)

Argumen fungsi berasal dari pemanggil; tidak ada nilai ID, konfigurasi, atau struktur packet yang diasumsikan.

Hasil yang didokumentasikan: `string`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(config)
    return createRedeemCode(config)
end
```

<a id="api-example-727"></a>

#### setPlaymodDuration(playmod_id, seconds)

Argumen fungsi berasal dari pemanggil; tidak ada nilai ID, konfigurasi, atau struktur packet yang diasumsikan.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(playmod_id, seconds)
    return setPlaymodDuration(playmod_id, seconds)
end
```

<a id="api-example-728"></a>

#### setBroadcastWorld(worldName)

Argumen fungsi berasal dari pemanggil; tidak ada nilai ID, konfigurasi, atau struktur packet yang diasumsikan.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(worldName)
    return setBroadcastWorld(worldName)
end
```

<a id="api-example-729"></a>

#### getJimDailyQuest()

Argumen fungsi berasal dari pemanggil; tidak ada nilai ID, konfigurasi, atau struktur packet yang diasumsikan.

Hasil yang didokumentasikan: `any`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example()
    return getJimDailyQuest()
end
```

<a id="api-example-730"></a>

#### deleteAccount(id)

Argumen fungsi berasal dari pemanggil; tidak ada nilai ID, konfigurasi, atau struktur packet yang diasumsikan.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(id)
    return deleteAccount(id)
end
```

<a id="api-example-731"></a>

#### deleteWorld(id)

Argumen fungsi berasal dari pemanggil; tidak ada nilai ID, konfigurasi, atau struktur packet yang diasumsikan.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(id)
    return deleteWorld(id)
end
```

<a id="api-example-732"></a>

#### deleteGuild(id)

Argumen fungsi berasal dari pemanggil; tidak ada nilai ID, konfigurasi, atau struktur packet yang diasumsikan.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(id)
    return deleteGuild(id)
end
```

<a id="api-example-733"></a>

#### getServerDefaultPort()

Argumen fungsi berasal dari pemanggil; tidak ada nilai ID, konfigurasi, atau struktur packet yang diasumsikan.

Hasil yang didokumentasikan: `number`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example()
    return getServerDefaultPort()
end
```

<a id="api-example-734"></a>

#### getEvents()

Argumen fungsi berasal dari pemanggil; tidak ada nilai ID, konfigurasi, atau struktur packet yang diasumsikan.

Hasil yang didokumentasikan: `{any}`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example()
    return getEvents()
end
```

<a id="api-example-735"></a>

#### getDailyEvents()

Argumen fungsi berasal dari pemanggil; tidak ada nilai ID, konfigurasi, atau struktur packet yang diasumsikan.

Hasil yang didokumentasikan: `{any}`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example()
    return getDailyEvents()
end
```

<a id="api-example-736"></a>

#### getItemEffects()

Argumen fungsi berasal dari pemanggil; tidak ada nilai ID, konfigurasi, atau struktur packet yang diasumsikan.

Hasil yang didokumentasikan: `{any}`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example()
    return getItemEffects()
end
```

<a id="api-example-737"></a>

#### getWorldEffects()

Argumen fungsi berasal dari pemanggil; tidak ada nilai ID, konfigurasi, atau struktur packet yang diasumsikan.

Hasil yang didokumentasikan: `{any}`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example()
    return getWorldEffects()
end
```

<a id="api-example-738"></a>

#### getPlayerEffects()

Argumen fungsi berasal dari pemanggil; tidak ada nilai ID, konfigurasi, atau struktur packet yang diasumsikan.

Hasil yang didokumentasikan: `{any}`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example()
    return getPlayerEffects()
end
```

<a id="api-example-739"></a>

#### getRoleQuestDay()

Argumen fungsi berasal dari pemanggil; tidak ada nilai ID, konfigurasi, atau struktur packet yang diasumsikan.

Hasil yang didokumentasikan: `number`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example()
    return getRoleQuestDay()
end
```

<a id="api-example-740"></a>

#### getAchievements()

Argumen fungsi berasal dari pemanggil; tidak ada nilai ID, konfigurasi, atau struktur packet yang diasumsikan.

Hasil yang didokumentasikan: `{any}`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example()
    return getAchievements()
end
```

<a id="api-example-741"></a>

#### getMachineCaps()

Argumen fungsi berasal dari pemanggil; tidak ada nilai ID, konfigurasi, atau struktur packet yang diasumsikan.

Hasil yang didokumentasikan: `{any}`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example()
    return getMachineCaps()
end
```

<a id="api-example-742"></a>

#### hasFeatureEnabled(name)

Argumen fungsi berasal dari pemanggil; tidak ada nilai ID, konfigurasi, atau struktur packet yang diasumsikan.

Hasil yang didokumentasikan: `boolean`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(name)
    return hasFeatureEnabled(name)
end
```

<a id="api-example-743"></a>

#### createTemplate(backupName)

Argumen fungsi berasal dari pemanggil; tidak ada nilai ID, konfigurasi, atau struktur packet yang diasumsikan.

Hasil yang didokumentasikan: `boolean`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(backupName)
    return createTemplate(backupName)
end
```

<a id="api-example-744"></a>

#### applyTemplate(backupName)

Argumen fungsi berasal dari pemanggil; tidak ada nilai ID, konfigurasi, atau struktur packet yang diasumsikan.

Hasil yang didokumentasikan: `boolean`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(backupName)
    return applyTemplate(backupName)
end
```

<a id="api-example-745"></a>

#### getTemplates()

Argumen fungsi berasal dari pemanggil; tidak ada nilai ID, konfigurasi, atau struktur packet yang diasumsikan.

Hasil yang didokumentasikan: `{any}`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example()
    return getTemplates()
end
```

<a id="api-example-746"></a>

#### hasTemplate(backupName)

Argumen fungsi berasal dari pemanggil; tidak ada nilai ID, konfigurasi, atau struktur packet yang diasumsikan.

Hasil yang didokumentasikan: `boolean`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(backupName)
    return hasTemplate(backupName)
end
```

<a id="api-example-747"></a>

#### deleteTemplate(backupName)

Argumen fungsi berasal dari pemanggil; tidak ada nilai ID, konfigurasi, atau struktur packet yang diasumsikan.

Hasil yang didokumentasikan: `boolean`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(backupName)
    return deleteTemplate(backupName)
end
```

<a id="api-example-748"></a>

#### includeClientFile(url, name)

Argumen fungsi berasal dari pemanggil; tidak ada nilai ID, konfigurasi, atau struktur packet yang diasumsikan.

Hasil yang didokumentasikan: `any`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(url, name)
    return includeClientFile(url, name)
end
```

<a id="api-example-749"></a>

#### enableCaching(item_id)

Argumen fungsi berasal dari pemanggil; tidak ada nilai ID, konfigurasi, atau struktur packet yang diasumsikan.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(item_id)
    return enableCaching(item_id)
end
```

<a id="api-example-750"></a>

#### disableCaching(item_id)

Argumen fungsi berasal dari pemanggil; tidak ada nilai ID, konfigurasi, atau struktur packet yang diasumsikan.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(item_id)
    return disableCaching(item_id)
end
```

<a id="api-example-751"></a>

#### getServerDiscordLink()

Argumen fungsi berasal dari pemanggil; tidak ada nilai ID, konfigurasi, atau struktur packet yang diasumsikan.

Hasil yang didokumentasikan: `string`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example()
    return getServerDiscordLink()
end
```

<a id="api-example-752"></a>

#### getServerDiscordHowToPlay()

Argumen fungsi berasal dari pemanggil; tidak ada nilai ID, konfigurasi, atau struktur packet yang diasumsikan.

Hasil yang didokumentasikan: `string`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example()
    return getServerDiscordHowToPlay()
end
```

<a id="api-example-753"></a>

#### deleteExport(exportName)

Argumen fungsi berasal dari pemanggil; tidak ada nilai ID, konfigurasi, atau struktur packet yang diasumsikan.

Hasil yang didokumentasikan: `boolean`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(exportName)
    return deleteExport(exportName)
end
```

<a id="api-example-754"></a>

#### addCombinerRecipe(id_1, count_1, id_2, count_2, id_3, count_3, result_id, result_count, combiner_id, builder_level, cook_level, water, startopia_level)

Argumen fungsi berasal dari pemanggil; tidak ada nilai ID, konfigurasi, atau struktur packet yang diasumsikan.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(id_1, count_1, id_2, count_2, id_3, count_3, result_id, result_count, combiner_id, builder_level, cook_level, water, startopia_level)
    return addCombinerRecipe(id_1, count_1, id_2, count_2, id_3, count_3, result_id, result_count, combiner_id, builder_level, cook_level, water, startopia_level)
end
```

<a id="api-example-755"></a>

#### removeCombinerRecipe(id_1, count_1, id_2, count_2, id_3, count_3, result_id, result_count)

Argumen fungsi berasal dari pemanggil; tidak ada nilai ID, konfigurasi, atau struktur packet yang diasumsikan.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(id_1, count_1, id_2, count_2, id_3, count_3, result_id, result_count)
    return removeCombinerRecipe(id_1, count_1, id_2, count_2, id_3, count_3, result_id, result_count)
end
```

<a id="api-example-756"></a>

#### getCombinerRecipes()

Argumen fungsi berasal dari pemanggil; tidak ada nilai ID, konfigurasi, atau struktur packet yang diasumsikan.

Hasil yang didokumentasikan: `{any}`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example()
    return getCombinerRecipes()
end
```

<a id="api-example-757"></a>

#### getSpecialStoreItems(player)

Argumen fungsi berasal dari pemanggil; tidak ada nilai ID, konfigurasi, atau struktur packet yang diasumsikan.

Hasil yang didokumentasikan: `{string}`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(player)
    return getSpecialStoreItems(player)
end
```

<a id="api-example-758"></a>

#### setGuildCreatePriceSSUP(price)

Argumen fungsi berasal dari pemanggil; tidak ada nilai ID, konfigurasi, atau struktur packet yang diasumsikan.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(price)
    return setGuildCreatePriceSSUP(price)
end
```

<a id="api-example-759"></a>

#### setGuildCreatePriceSUP(price)

Argumen fungsi berasal dari pemanggil; tidak ada nilai ID, konfigurasi, atau struktur packet yang diasumsikan.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(price)
    return setGuildCreatePriceSUP(price)
end
```

<a id="api-example-760"></a>

#### setGuildCreatePriceNormal(price)

Argumen fungsi berasal dari pemanggil; tidak ada nilai ID, konfigurasi, atau struktur packet yang diasumsikan.

Hasil yang didokumentasikan: `void`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(price)
    return setGuildCreatePriceNormal(price)
end
```

---

<a id="examples-utilities"></a>

### Utilities

Referensi: [Utilities](https://dash.gtps.cloud/docs/utilities).

Varian dari halaman Utilities. Notasi dan nama binding berbeda dari halaman kelas; contoh berikut mempertahankan varian sumber dan tidak menjamin alias tersebut tersedia pada build pengguna.

<a id="api-example-761"></a>

#### timer.setTimeout(seconds, callback, ...)

Argumen fungsi berasal dari pemanggil; tidak ada nilai ID, konfigurasi, atau struktur packet yang diasumsikan.

Hasil yang didokumentasikan: `number (timerID)`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(seconds, callback, ...)
    return timer.setTimeout(seconds, callback, ...)
end
```

<a id="api-example-762"></a>

#### timer.setInterval(seconds, callback, ...)

Argumen fungsi berasal dari pemanggil; tidak ada nilai ID, konfigurasi, atau struktur packet yang diasumsikan.

Hasil yang didokumentasikan: `number (timerID)`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(seconds, callback, ...)
    return timer.setInterval(seconds, callback, ...)
end
```

<a id="api-example-763"></a>

#### timer.clear(id)

Argumen fungsi berasal dari pemanggil; tidak ada nilai ID, konfigurasi, atau struktur packet yang diasumsikan.

```lua
local function example(id)
    return timer.clear(id)
end
```

<a id="api-example-764"></a>

#### http.get(url)

Argumen fungsi berasal dari pemanggil; tidak ada nilai ID, konfigurasi, atau struktur packet yang diasumsikan. Wajib dipanggil dari coroutine; pertahankan seluruh hasil body/status.

```lua
local function example(url)
    return http.get(url)
end
```

<a id="api-example-765"></a>

#### http.post(url, post_data)

Argumen fungsi berasal dari pemanggil; tidak ada nilai ID, konfigurasi, atau struktur packet yang diasumsikan. Wajib dipanggil dari coroutine; pertahankan seluruh hasil body/status.

```lua
local function example(url, post_data)
    return http.post(url, post_data)
end
```

<a id="api-example-766"></a>

#### file.read(path)

Argumen fungsi berasal dari pemanggil; tidak ada nilai ID, konfigurasi, atau struktur packet yang diasumsikan.

Hasil yang didokumentasikan: `string`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(path)
    return file.read(path)
end
```

<a id="api-example-767"></a>

#### file.write(path, data)

Argumen fungsi berasal dari pemanggil; tidak ada nilai ID, konfigurasi, atau struktur packet yang diasumsikan.

```lua
local function example(path, data)
    return file.write(path, data)
end
```

<a id="api-example-768"></a>

#### file.exists(path)

Argumen fungsi berasal dari pemanggil; tidak ada nilai ID, konfigurasi, atau struktur packet yang diasumsikan.

Hasil yang didokumentasikan: `boolean`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(path)
    return file.exists(path)
end
```

<a id="api-example-769"></a>

#### file.delete(path)

Argumen fungsi berasal dari pemanggil; tidak ada nilai ID, konfigurasi, atau struktur packet yang diasumsikan.

```lua
local function example(path)
    return file.delete(path)
end
```

<a id="api-example-770"></a>

#### dir.create(path)

Argumen fungsi berasal dari pemanggil; tidak ada nilai ID, konfigurasi, atau struktur packet yang diasumsikan.

```lua
local function example(path)
    return dir.create(path)
end
```

<a id="api-example-771"></a>

#### dir.exists(path)

Argumen fungsi berasal dari pemanggil; tidak ada nilai ID, konfigurasi, atau struktur packet yang diasumsikan.

Hasil yang didokumentasikan: `boolean`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(path)
    return dir.exists(path)
end
```

<a id="api-example-772"></a>

#### dir.delete(path)

Argumen fungsi berasal dari pemanggil; tidak ada nilai ID, konfigurasi, atau struktur packet yang diasumsikan.

```lua
local function example(path)
    return dir.delete(path)
end
```

<a id="api-example-773"></a>

#### db.open(path)

Argumen fungsi berasal dari pemanggil; tidak ada nilai ID, konfigurasi, atau struktur packet yang diasumsikan.

Hasil yang didokumentasikan: `LuaDB`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(path)
    return db.open(path)
end
```

<a id="api-example-774"></a>

#### LuaDB:query(query)

`database` adalah instance `LuaDB` yang sudah tersedia; parameter sisanya mengikuti referensi.

```lua
local function example(database, query)
    return database:query(query)
end
```

<a id="api-example-775"></a>

#### LuaDB:close()

`database` adalah instance `LuaDB` yang sudah tersedia; parameter sisanya mengikuti referensi.

```lua
local function example(database)
    return database:close()
end
```

<a id="api-example-776"></a>

#### bit.band(a, b?)

Argumen fungsi berasal dari pemanggil; tidak ada nilai ID, konfigurasi, atau struktur packet yang diasumsikan.

Hasil yang didokumentasikan: `number`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(a, b)
    return bit.band(a, b)
end
```

<a id="api-example-777"></a>

#### bit.bor(a, b?)

Argumen fungsi berasal dari pemanggil; tidak ada nilai ID, konfigurasi, atau struktur packet yang diasumsikan.

Hasil yang didokumentasikan: `number`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(a, b)
    return bit.bor(a, b)
end
```

<a id="api-example-778"></a>

#### bit.bxor(a, b?)

Argumen fungsi berasal dari pemanggil; tidak ada nilai ID, konfigurasi, atau struktur packet yang diasumsikan.

Hasil yang didokumentasikan: `number`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(a, b)
    return bit.bxor(a, b)
end
```

<a id="api-example-779"></a>

#### bit.bnot(a)

Argumen fungsi berasal dari pemanggil; tidak ada nilai ID, konfigurasi, atau struktur packet yang diasumsikan.

Hasil yang didokumentasikan: `number`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(a)
    return bit.bnot(a)
end
```

<a id="api-example-780"></a>

#### bit.lshift(a, b?)

Argumen fungsi berasal dari pemanggil; tidak ada nilai ID, konfigurasi, atau struktur packet yang diasumsikan.

Hasil yang didokumentasikan: `number`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(a, b)
    return bit.lshift(a, b)
end
```

<a id="api-example-781"></a>

#### bit.rshift(a, b?)

Argumen fungsi berasal dari pemanggil; tidak ada nilai ID, konfigurasi, atau struktur packet yang diasumsikan.

Hasil yang didokumentasikan: `number`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(a, b)
    return bit.rshift(a, b)
end
```

<a id="api-example-782"></a>

#### bit.arshift(a, b?)

Argumen fungsi berasal dari pemanggil; tidak ada nilai ID, konfigurasi, atau struktur packet yang diasumsikan.

Hasil yang didokumentasikan: `number`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(a, b)
    return bit.arshift(a, b)
end
```

<a id="api-example-783"></a>

#### bit.mod(a, b?)

Argumen fungsi berasal dari pemanggil; tidak ada nilai ID, konfigurasi, atau struktur packet yang diasumsikan.

Hasil yang didokumentasikan: `number`. Lihat deskripsi referensi untuk detail hasil dan error.

```lua
local function example(a, b)
    return bit.mod(a, b)
end
```

<a id="api-example-784"></a>

#### require(modname)

Argumen fungsi berasal dari pemanggil; tidak ada nilai ID, konfigurasi, atau struktur packet yang diasumsikan.

```lua
local function example(modname)
    return require(modname)
end
```
