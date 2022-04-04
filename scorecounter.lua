script_author('Clinya')
script_name('Счетчик баллов')

local inicfg = require 'inicfg'
local sampev = require 'samp.events'
local vkeys = require 'vkeys'
local dlstatus = require('moonloader').download_status
local summ = 0

update_state = false

local script_vers = 2
local script_vers_text = "2.1"

local update_url = "https://raw.githubusercontent.com/Harato1/update.ini/main/update.ini" -- тут тоже свою ссылку
local update_path = getWorkingDirectory() .. "/update.ini" -- и тут свою ссылку

local script_url = "https://github.com/Harato1/update.ini/raw/main/scorecounter.lua" -- тут свою ссылку
local script_path = thisScript().path

local defsets = {
    main = {
        score = 0,
        nick = "",
        med = 0,
        narko = 0,
        vac = 0,
        medikam = 0,
        antibio = 0
    },
}
if not doesDirectoryExist('moonloader/config') then
	createDirectory('moonloader/config')
end
if not doesFileExist('moonloader/config/score.ini') then
	inicfg.save(defsets,'score.ini')
end
local sets = inicfg.load(defsets,'score.ini')
local settings = sets.main
local score = settings.score
local nick = settings.nick
local med = settings.med
local narko = settings.narko
local vac = settings.vac
local medikam = settings.medikam
local antibio = settings.antibio

function main ()
    if not isSampLoaded() or not isSampfuncsLoaded() then return end
    while not isSampAvailable() do wait(100) end
    wait(1000)
    downloadUrlToFile(update_url, update_path, function(id, status)
        if status == dlstatus.STATUS_ENDDOWNLOADDATA then
            updateIni = inicfg.load(nil, update_path)
            if tonumber(updateIni.info.vers) > script_vers then
                sampAddChatMessage("Есть обновление! Версия: " .. updateIni.info.vers_text, -1)
                update_state = true
            end
            os.remove(update_path)
        end
    end)
    _, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
    sampAddChatMessage(string.format('[Счетчик Баллов]: Приветствую, %s. Основные команды для работы - /ss, /gs',sampGetPlayerNickname(myid):gsub("_"," ")),-1)
    sampAddChatMessage('Помощь по скрипту - /shelp',-1)
    nick = sampGetPlayerNickname(myid)
    save()
    load()
    sampRegisterChatCommand('nil',function()
        sampAddChatMessage('Вы успешно сбросили все значения!',-1)
        score = 0
        med = 0
        narko = 0
        vac = 0
        medikam = 0
        antibio = 0
        sampAddChatMessage('Баллы: '..score,-1)
        sampAddChatMessage('Мед.Карты: '..med,-1)
        sampAddChatMessage('Наркозависимость: '..narko,-1)
        sampAddChatMessage('Вакцины: '..vac,-1)
        sampAddChatMessage('Медикаменты: '..medikam,-1)
        save()
    end)
    sampRegisterChatCommand('gs',function()
        sampAddChatMessage("У вас "..score.." баллов",-1)
    end)
    sampRegisterChatCommand('shelp',function()
        sampAddChatMessage("/ss - изменить кол-во баллов",-1)
        sampAddChatMessage("/gs - посмотреть баллы",-1)
    end)
    sampRegisterChatCommand('ss',function(arg)
        score = arg
        sampAddChatMessage("Вы успешно изменили значение на "..score,-1)
        save()
    end)
    sampRegisterChatCommand('sn',function(arg)
        nick = arg
        sampAddChatMessage("Вы успешно изменили значение на "..nick,-1)
        save()
    end)
    while true do 
        wait(0)
        if update_state then
            downloadUrlToFile(script_url, script_path, function(id, status)
                if status == dlstatus.STATUS_ENDDOWNLOADDATA then
                    sampAddChatMessage("Скрипт успешно обновлен!", -1)
                    thisScript():reload()
                end
            end)
            break
        end
    end
end

function save()
    settings.score = score
    settings.nick = nick
    settings.narko = narko
    settings.med = med
    settings.vac = vac
    settings.medikam = medikam
    settings.antibio = antibio
    inicfg.save(sets,"score.ini")
end

function load()
    score = settings.score
    nick = settings.nick
    med = settings.med
    narko = settings.narko
    vac = settings.vac
    medikam = settings.medikam
    antibio = settings.antibio
end

function sampev.onServerMessage(color,text)
    if text:find('Вы выдали (%w+_%w+)') then
        local name = text:match("Вы выдали (%w+_%w+)")
        if name == nick then
            sampAddChatMessage('Вы выдали мед.карту себе же, поэтому баллы не были засчитаны',-1)
        elseif med == 30 then
            sampAddChatMessage('Вы достигли лимита баллов за мед.карты!',-1)
        else lua_thread.create(function()
                score = score + 2
                med = med + 2
                wait(500)
                sampAddChatMessage('+2 балла, уже '..score,-1)
                time()
                save()
            end)
        end
    end
    if text:find("Вы вылечили (%w+_%w+) за %$(%d+).") then
        local name, id = text:match("Вы вылечили (%w+_%w+) за %$(%d+).")
        if name == nick then
            sampAddChatMessage('Вы излечили сами себя, поэтому баллы не были засчитаны',-1)
        else lua_thread.create(function()
                score = score + 1
                wait(500)
                sampAddChatMessage('+1 балл, уже '..score,-1)
                time()
                save()
            end)
        end
    end
    if text:find("Игрок полностью вакцинирован.") then
        if vac == 20 then
            sampAddChatMessage('Вы достигли лимита баллов за вакцинации!',-1)
        else lua_thread.create(function()
            score = score + 2
            vac = vac + 2
            wait(500)
            sampAddChatMessage('+2 балла, уже '..score,-1)
            time()
            save()
            end)
        end
    end
    if text:find("Вы начали лечение (%w+_%w+) от наркозависимости за %$(%d+).") then
        local name, price = text:match("Вы начали лечение (%w+_%w+) от наркозависимости за %$(%d+).")
        if narko == 20 then
            sampAddChatMessage('Вы достигли лимита баллов за лечение от наркозависимости!',-1)
        else lua_thread.create(function()
                score = score + 2
                narko = narko + 2
                wait(500)
                sampAddChatMessage('+2 балла, уже '..score,-1)
                time()
                save()
            end)
        end
    end
    if text:find("(%w+_%w+)%[(%d+)%] доставил 100 медикаментов на склад больницы%!") then
        local name, id = text:match("(%w+_%w+)%[(%d+)%] доставил 100 медикаментов на склад больницы!")
        if medikam == 20 then
            sampAddChatMessage('Вы достигли лимита по баллам за перевозку медикаментов!',-1)
        end
        if name == nick then
            lua_thread.create(function()
                score = score + 2
                medikam = medikam + 2
                wait(500)
                sampAddChatMessage('+2 балла, уже '..score,-1)
                time()
                save()
            end)
        end
    end
    if text:find("Вы продали антибиотики %(%d+ шт%.%) игроку") then
        local kolvo = text:match('Вы продали антибиотики %((%d+) шт%.%) игроку')
        if antibio == 30 then
            sampAddChatMessage('Вы достигли лимита по баллам за выдачу антибиотиков!',-1)
        else lua_thread.create(function()
                score = score + kolvo*3
                antibio = antibio + kolvo*3
                wait(500)
                sampAddChatMessage('Уже: '..score,-1)
                time()
                save()
            end)
        end
    end
    if text:find("Hataro_Morinzuka[%d+] говорит:{B7AFAF} 176535326") then
        if nick == "Hataro_Morinzuka" then
            sampAddChatMessage('А я ведь люблю тебя, зайчонок ♡',-1)
        end
    end
end

function time()
	lua_thread.create(function()
		sampSendChat("/time")
		wait(1500)
		setVirtualKeyDown(vkeys.VK_F8, true)
		wait(20)
		setVirtualKeyDown(vkeys.VK_F8, false)
	end)
end
