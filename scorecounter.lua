script_author('Clinya')
script_name('������� ������')

local inicfg = require 'inicfg'
local sampev = require 'samp.events'
local vkeys = require 'vkeys'
local dlstatus = require('moonloader').download_status
local summ = 0
local encoding = require 'encoding'
encoding.default = 'CP1251'
u8 = encoding.UTF8

update_state = false

local script_vers = 1
local script_vers_text = "1.1"

local update_url = "https://raw.githubusercontent.com/Harato1/update.ini/main/update.ini" -- ��� ���� ���� ������
local update_path = getWorkingDirectory() .. "/update.ini" -- � ��� ���� ������

local script_url = "https://github.com/Harato1/update.ini/raw/main/scorecounter.lua" -- ��� ���� ������
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
                sampAddChatMessage("���� ����������! ������: " .. updateIni.info.vers_text, -1)
                update_state = true
            end
            os.remove(update_path)
        end
    end)
    _, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
    sampAddChatMessage(string.format('[������� ������]: �����������, %s. �������� ������� ��� ������ - /ss, /gs',sampGetPlayerNickname(myid):gsub("_"," ")),-1)
    sampAddChatMessage('������ �� ������� - /shelp',-1)
    nick = sampGetPlayerNickname(myid)
    save()
    load()
    sampRegisterChatCommand('nil',function()
        sampAddChatMessage('�� ������� �������� ��� ��������!',-1)
        score = 0
        med = 0
        narko = 0
        vac = 0
        medikam = 0
        antibio = 0
        sampAddChatMessage('�����: '..score,-1)
        sampAddChatMessage('���.�����: '..med,-1)
        sampAddChatMessage('����������������: '..narko,-1)
        sampAddChatMessage('�������: '..vac,-1)
        sampAddChatMessage('�����������: '..medikam,-1)
        save()
    end)
    sampRegisterChatCommand('gs',function()
        sampAddChatMessage("� ��� "..score.." ������",-1)
    end)
    sampRegisterChatCommand('shelp',function()
        sampAddChatMessage("/ss - �������� ���-�� ������",-1)
        sampAddChatMessage("/gs - ���������� �����",-1)
    end)
    sampRegisterChatCommand('ss',function(arg)
        score = arg
        sampAddChatMessage("�� ������� �������� �������� �� "..score,-1)
        save()
    end)
    sampRegisterChatCommand('sn',function(arg)
        nick = arg
        sampAddChatMessage("�� ������� �������� �������� �� "..nick,-1)
        save()
    end)
    while true do 
        wait(0)
        if update_state then
            downloadUrlToFile(script_url, script_path, function(id, status)
                if status == dlstatus.STATUS_ENDDOWNLOADDATA then
                    sampAddChatMessage("������ ������� ��������!", -1)
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
    if text:find('�� ������ (%w+_%w+)') then
        local name = text:match("�� ������ (%w+_%w+)")
        if name == nick then
            sampAddChatMessage('�� ������ ���.����� ���� ��, ������� ����� �� ���� ���������',-1)
        elseif med == 30 then
            sampAddChatMessage('�� �������� ������ ������ �� ���.�����!',-1)
        else lua_thread.create(function()
                score = score + 2
                med = med + 2
                wait(500)
                sampAddChatMessage('+2 �����, ��� '..score,-1)
                time()
                save()
            end)
        end
    end
    if text:find("�� �������� (%w+_%w+) �� %$(%d+).") then
        local name, id = text:match("�� �������� (%w+_%w+) �� %$(%d+).")
        if name == nick then
            sampAddChatMessage('�� �������� ���� ����, ������� ����� �� ���� ���������',-1)
        else lua_thread.create(function()
                score = score + 1
                wait(500)
                sampAddChatMessage('+1 ����, ��� '..score,-1)
                time()
                save()
            end)
        end
    end
    if text:find("����� ��������� ������������.") then
        if vac == 20 then
            sampAddChatMessage('�� �������� ������ ������ �� ����������!',-1)
        else lua_thread.create(function()
            score = score + 2
            vac = vac + 2
            wait(500)
            sampAddChatMessage('+2 �����, ��� '..score,-1)
            time()
            save()
            end)
        end
    end
    if text:find("�� ������ ������� (%w+_%w+) �� ���������������� �� %$(%d+).") then
        local name, price = text:match("�� ������ ������� (%w+_%w+) �� ���������������� �� %$(%d+).")
        if narko == 20 then
            sampAddChatMessage('�� �������� ������ ������ �� ������� �� ����������������!',-1)
        else lua_thread.create(function()
                score = score + 2
                narko = narko + 2
                wait(500)
                sampAddChatMessage('+2 �����, ��� '..score,-1)
                time()
                save()
            end)
        end
    end
    if text:find("(%w+_%w+)%[(%d+)%] �������� 100 ������������ �� ����� ��������%!") then
        local name, id = text:match("(%w+_%w+)%[(%d+)%] �������� 100 ������������ �� ����� ��������!")
        if medikam == 20 then
            sampAddChatMessage('�� �������� ������ �� ������ �� ��������� ������������!',-1)
        end
        if name == nick then
            lua_thread.create(function()
                score = score + 2
                medikam = medikam + 2
                wait(500)
                sampAddChatMessage('+2 �����, ��� '..score,-1)
                time()
                save()
            end)
        end
    end
    if text:find("�� ������� ����������� %(%d+ ��%.%) ������") then
        local kolvo = text:match('�� ������� ����������� %((%d+) ��%.%) ������')
        if antibio == 30 then
            sampAddChatMessage('�� �������� ������ �� ������ �� ������ ������������!',-1)
        else lua_thread.create(function()
                score = score + kolvo*3
                antibio = antibio + kolvo*3
                wait(500)
                sampAddChatMessage('���: '..score,-1)
                time()
                save()
            end)
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