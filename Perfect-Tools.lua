script_name("Perfect-Tools")
script_author("Trudeau")
script_version("1.0")

require "lib.moonloader" -- поиск библиотеки
local dlstatus = require('moonloader').download_status

local imgui = require 'imgui'
local encoding = require 'encoding'
local ffi = require 'ffi'
encoding.default = 'CP1251'
u8 = encoding.UTF8
local MainWind = imgui.ImBool(false)
local sampev = require 'lib.samp.events'
local rkeys = require 'rkeys'
local fa = require('fAwesome5')
local requests = require 'requests'
local inicfg = require 'inicfg'
local directIni = "moonloader/config\\Perfect-Tools.lua.ini"
local mainIni = inicfg.load({
settings =
    {
        admin_password = '  ',
				admin_lvl = 0,
				acc_password = '  ',
				status_login = false,
				status_adm = false
    }
}, directIni)
local satetIni = inicfg.save(mainIni, dicrectIni)
imgui.ToggleButton = require('imgui_addons').ToggleButton
local fa_glyph_ranges = imgui.ImGlyphRanges({ fa.min_range, fa.max_range })
local main_window_state = imgui.ImBool(true)
local text_buffer = imgui.ImBuffer(mainIni.settings.acc_password, 16)


local buffer = imgui.ImBuffer(mainIni.settings.admin_password, 16)
local combo_select = imgui.ImInt(mainIni.settings.admin_lvl)
arr_str = {"1", "2", "3", "4", "5", "6", "7", "8"}
toggle_status_login = imgui.ImBool(mainIni.settings.status_login)
toggle_status_adm = imgui.ImBool(mainIni.settings.status_adm)

arr_str_name = {"Модер", "ткст", "вфывф", "вфывыф", "вфывф", "вфыв", "фывфыв", "Основатель"}

update_state = false

local script_vers = 2
local script_vers_text = "2.00"

local update_url = "https://raw.githubusercontent.com/Jetler/perfect-tools/main/update.ini" -- тут тоже свою ссылку
local update_path = getWorkingDirectory() .. "/update.ini" -- и тут свою ссылку

local script_url = "https://45.138.72.141/atools/Perfect-Tools.lua" -- тут свою ссылку
local script_path = thisScript().path

function imgui.BeforeDrawFrame()
    if fa_font == nil then
        local font_config = imgui.ImFontConfig() -- to use 'imgui.ImFontConfig.new()' on error
        font_config.MergeMode = true

        fa_font = imgui.GetIO().Fonts:AddFontFromFileTTF('moonloader/resource/fontawesome-webfont.ttf', 13.0, font_config, fa_glyph_ranges)
    end
end

function getserial()
    local ffi = require("ffi")
    ffi.cdef[[
    int __stdcall GetVolumeInformationA(
    const char* lpRootPathName,
    char* lpVolumeNameBuffer,
    uint32_t nVolumeNameSize,
    uint32_t* lpVolumeSerialNumber,
    uint32_t* lpMaximumComponentLength,
    uint32_t* lpFileSystemFlags,
    char* lpFileSystemNameBuffer,
    uint32_t nFileSystemNameSize
    );
    ]]
    local serial = ffi.new("unsigned long[1]", 0)
    ffi.C.GetVolumeInformationA(nil, nil, 0, serial, nil, nil, nil, 0)
    return serial[0]
end


function main()
	while not  isSampAvailable() do wait(100) end

	imgui.Process = false

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

	addkeytochat()
	checkKey()
 	sampRegisterChatCommand("amenu", command_amenu)

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
		if main_window_state.v == false then
			imgui.Process = false
		end
		if isKeyJustPressed(VK_M) and not sampIsChatInputActive() and not sampIsDialogActive() then
			main_window_state.v = not main_window_state.v
			imgui.Process = main_window_state.v
		end
	end

end
function checkKey()
        response = requests.get('http://45.138.72.141/atools/check.php?code='..getserial())
        if not response.text:match("<body>(.*)</body>"):find("-1") then
            if not response.text:match("<body>(.*)</body>"):find("The duration of the key has expired.") then
                sampAddChatMessage(string.format("{2E8B57}[Perfect-Tools]: {AFAFAF}До окончания лицензии осталось: {2E8B57}%d {AFAFAF}дней",response.text:match("<body>(.*)</body>"), -1), -1)
								sampAddChatMessage(string.format("{2E8B57}[Perfect-Tools]: {AFAFAF}Скрипт успешно загружен. Текущая версия скрипта %sv", thisScript().version), -1)
								sampAddChatMessage("{2E8B57}[Perfect-Tools]: {AFAFAF}Чтобы ознакомиться с функциями нажмите {2E8B57}M {AFAFAF}или {2E8B57}/amenu", -1)
            else
                sampAddChatMessage("{2E8B57}[Perfect-Tools]: {AFAFAF}Лицензия окончилась!", -1)
								thisScript():unload()
            end
        else
            sampAddChatMessage("{2E8B57}[Perfect-Tools]: {AFAFAF}Ваш ключ не найден в базе данных", -1)
						thisScript():unload()
        end
end
function addkeytochat()
    sampAddChatMessage("{2E8B57}[Perfect-Tools]: {AFAFAF}Ваш серийный ключ: {2E8B57}"..getserial(), -1)
end

function command_amenu()
	if not sampIsChatInputActive() and not sampIsDialogActive() then
	main_window_state.v = not main_window_state.v
	imgui.Process = main_window_state.v end
end

function imgui.VerticalSeparator()
    local p = imgui.GetCursorScreenPos()
    imgui.GetWindowDrawList():AddLine(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x, p.y + imgui.GetContentRegionMax().y), imgui.GetColorU32(imgui.GetStyle().Colors[imgui.Col.Separator]))
end


function sampev.onServerMessage(color, text)
	 if string.find(text, string.format("как %s ", arr_str_name[combo_select.v], 1, true)) then
		 sampAddChatMessage("!212", -1)
	 end
	 if string.find(text, string.format("как %s",arr_str_name[combo_select.v], 1, true)) then
		 sampAddChatMessage("!212", -1)
	 end
end



function imgui.OnDrawFrame()
	if main_window_state.v then
		local ex, ey = getScreenResolution()
		imgui.SetNextWindowPos(imgui.ImVec2(ex / 4, ey / 4), imgui.Cond.FirstUseEver)
		imgui.SetNextWindowSize(imgui.ImVec2(800, 400), imgui.Cond.FirstUseEver)
		imgui.Begin(u8"Perfect-Tools", main_window_state, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.AlwaysUseWindowPadding)
		imgui.BeginChild("ImguiWindow", imgui.ImVec2(200, 350), true)
		if imgui.Button(fa.ICON_USER_CIRCLE .. u8" Основное", imgui.ImVec2(170, 28)) then
			menu = 1
		end

		if imgui.Button(fa.ICON_THUMBTACK .. u8" Темы / цвета", imgui.ImVec2(170, 28)) then
			menu = 2
		end
		if imgui.Button(fa.ICON_KEYBOARD .. u8" Назначение клавиш", imgui.ImVec2(170, 28)) then
			menu = 3
		end
		if imgui.Button(fa.ICON_ID_CARD .. u8" Админ-раздел", imgui.ImVec2(170, 28)) then
			menu = 4
		end

		imgui.Button(fa.ICON_VIDEO .. u8" Слежка (Recon)", imgui.ImVec2(170, 28))
		imgui.Button(fa.ICON_CHECK_SQUARE .. u8" Чекеры", imgui.ImVec2(170, 28))
		imgui.Button(fa.ICON_FAST_FORWARD .. u8" Формы с адм чата", imgui.ImVec2(170, 28))
		imgui.Button(fa.ICON_ARCHIVE .. u8" Мероприятия", imgui.ImVec2(170, 28))
		if imgui.Button(fa.ICON_QUESTION_CIRCLE .. u8" Информация", imgui.ImVec2(170, 28)) then
			menu = 9
		end
		imgui.EndChild()
		imgui.SameLine()
		if menu == 1 then
			local _, id = sampGetPlayerIdByCharHandle(playerPed)
			imgui.BeginChild("NextWindow", imgui.ImVec2(550, 350), true)
			imgui.Text(string.format(u8"Ваш ник: %s[%d]",sampGetPlayerNickname(id), id))
			imgui.Text(u8"Ваш LVL администрирования: ")
			imgui.SameLine()
			imgui.PushItemWidth(45)
			imgui.SetCursorPosY(35)
			imgui.SetCursorPosX(195)
			if imgui.Combo("##", combo_select, arr_str) then
				mainIni.settings.admin_lvl = combo_select.v
				inicfg.save(mainIni, directIni)
			end
			imgui.SetCursorPosY(70)
			imgui.Separator()
			imgui.SetCursorPosX(16)
			imgui.SetCursorPosY(85)
			imgui.Text(u8"Пароль от аккаунта: ")
			imgui.SetCursorPosX(150)
			imgui.SetCursorPosY(83)
			imgui.PushItemWidth(120)
			if imgui.InputText("   ", text_buffer) then
				mainIni.settings.acc_password = text_buffer.v
				inicfg.save(mainIni, directIni)
			end
			imgui.SameLine()
			imgui.SetCursorPosX(18)
			imgui.SetCursorPosY(117)
			imgui.Text(u8"Админ пароль: ")
			imgui.SetCursorPosX(150)
			imgui.SetCursorPosY(117)
			imgui.PushItemWidth(120)
			if imgui.InputText("    ", buffer) then
				mainIni.settings.admin_password = buffer.v
				inicfg.save(mainIni, directIni)
			end
			imgui.SetCursorPosX(275)
			imgui.SetCursorPosY(10)
			imgui.VerticalSeparator()
			imgui.SameLine()
			imgui.SetCursorPosY(13)
			imgui.SetCursorPosX(330)
			imgui.Text(u8"Авто-логин")
			imgui.SetCursorPosY(15)
			imgui.SetCursorPosX(290)
			if imgui.ToggleButton("##1", toggle_status_login) then
				mainIni.settings.status_login = toggle_status_login.v
				inicfg.save(mainIni, directIni)
			end

			imgui.SetCursorPosY(48)
			imgui.SetCursorPosX(330)
			imgui.Text(u8"Авто-логин под адм")
			imgui.SetCursorPosY(45)
			imgui.SetCursorPosX(290)
			if imgui.ToggleButton("##2", toggle_status_adm) then
				mainIni.settings.status_adm = toggle_status_adm.v
				inicfg.save(mainIni, directIni)
			end
			imgui.EndChild()
		end
		if menu == 9 then
			imgui.BeginChild("NextWindow9", imgui.ImVec2(550, 350), true)
			imgui.SetCursorPosY(325)
			imgui.SetCursorPosX(230)
			imgui.Text("© PERFECT-GAMES")
			imgui.SameLine()
			imgui.SetCursorPosY(15)
			imgui.SetCursorPosX(200)
			imgui.Text(fa.ICON_ADDRESS_BOOK .. u8" Автор скрипта: Trudeau")
			imgui.SameLine()
			imgui.SetCursorPosY(40)
			imgui.SetCursorPosX(200)
			imgui.Text(fa.ICON_BOOKMARK .. u8" Специально для проекта\n\t\tArizona Perfect")

			imgui.SetCursorPosY(130)
			imgui.SetCursorPosX(200)
			if imgui.Button(u8"Груупа проекта", imgui.ImVec2(170, 28) ) then -- размер указал потомучто так привычней
				local url = "https://vk.com/azrp.samp"
       os.execute(url)
			 sampAddChatMessage("{2E8B57}[Perfect-Tools]: {AFAFAF}Оффициальная группа вконтакте проекта - https://vk.com/azrp.samp", color)
		 end
		 imgui.SetCursorPosY(170)
		 imgui.SetCursorPosX(200)
		 if imgui.Button(u8"Разработчик", imgui.ImVec2(170, 28) ) then -- размер указал потомучто так привычней
			 local url = "https://vk.com/dev_pawn"
			 os.execute(url)
			sampAddChatMessage("{2E8B57}[Perfect-Tools]: {AFAFAF}Страница разработчика - vk.com/dev_pawn", color)
		end
			imgui.EndChild()
		end
	imgui.End()
	end
end

function apply_custom_style()
	imgui.SwitchContext()
	local style = imgui.GetStyle()
	local colors = style.Colors
	local clr = imgui.Col
	local ImVec4 = imgui.ImVec4
	local ImVec2 = imgui.ImVec2

	 style.WindowPadding = ImVec2(15, 15)
	 style.WindowRounding = 15.0
	 style.FramePadding = ImVec2(5, 5)
	 style.ItemSpacing = ImVec2(12, 8)
	 style.ItemInnerSpacing = ImVec2(8, 6)
	 style.IndentSpacing = 25.0
	 style.ScrollbarSize = 15.0
	 style.ScrollbarRounding = 15.0
	 style.GrabMinSize = 15.0
	 style.GrabRounding = 7.0
	 style.ChildWindowRounding = 8.0
	 style.FrameRounding = 6.0


	 colors[clr.Text] = ImVec4(0.95, 0.96, 0.98, 1.00)
	 colors[clr.TextDisabled] = ImVec4(0.36, 0.42, 0.47, 1.00)
	 colors[clr.WindowBg] = ImVec4(0.11, 0.15, 0.17, 1.00)
	 colors[clr.ChildWindowBg] = ImVec4(0.15, 0.18, 0.22, 1.00)
	 colors[clr.PopupBg] = ImVec4(0.08, 0.08, 0.08, 0.94)
	 colors[clr.Border] = ImVec4(0.43, 0.43, 0.50, 0.50)
	 colors[clr.BorderShadow] = ImVec4(0.00, 0.00, 0.00, 0.00)
	 colors[clr.FrameBg] = ImVec4(0.20, 0.25, 0.29, 1.00)
	 colors[clr.FrameBgHovered] = ImVec4(0.12, 0.20, 0.28, 1.00)
	 colors[clr.FrameBgActive] = ImVec4(0.09, 0.12, 0.14, 1.00)
	 colors[clr.TitleBg] = ImVec4(0.9, 0.12, 0.14, 0.65)
	 colors[clr.TitleBgCollapsed] = ImVec4(0.00, 0.00, 0.00, 0.51)
	 colors[clr.TitleBgActive] = ImVec4(0.08, 0.10, 0.12, 1.00)
	 colors[clr.MenuBarBg] = ImVec4(0.15, 0.18, 0.22, 1.00)
	 colors[clr.ScrollbarBg] = ImVec4(0.02, 0.02, 0.02, 0.39)
	 colors[clr.ScrollbarGrab] = ImVec4(0.20, 0.25, 0.29, 1.00)
	 colors[clr.ScrollbarGrabHovered] = ImVec4(0.18, 0.22, 0.25, 1.00)
	 colors[clr.ScrollbarGrabActive] = ImVec4(0.09, 0.21, 0.31, 1.00)
	 colors[clr.ComboBg] = ImVec4(0.20, 0.25, 0.29, 1.00)
	 colors[clr.CheckMark] = ImVec4(0.28, 0.56, 1.00, 1.00)
	 colors[clr.SliderGrab] = ImVec4(0.28, 0.56, 1.00, 1.00)
	 colors[clr.SliderGrabActive] = ImVec4(0.37, 0.61, 1.00, 1.00)
	 colors[clr.Button] = ImVec4(0.20, 0.25, 0.29, 1.00)
	 colors[clr.ButtonHovered] = ImVec4(0.28, 0.56, 1.00, 1.00)
	 colors[clr.ButtonActive] = ImVec4(0.06, 0.53, 0.98, 1.00)
	 colors[clr.Header] = ImVec4(0.20, 0.25, 0.29, 0.55)
	 colors[clr.HeaderHovered] = ImVec4(0.26, 0.59, 0.98, 0.80)
	 colors[clr.HeaderActive] = ImVec4(0.26, 0.59, 0.98, 1.00)
	 colors[clr.ResizeGrip] = ImVec4(0.26, 0.59, 0.98, 0.25)
	 colors[clr.ResizeGripHovered] = ImVec4(0.26, 0.59, 0.98, 0.67)
	 colors[clr.ResizeGripActive] = ImVec4(0.06, 0.05, 0.07, 1.00)
	 colors[clr.CloseButton] = ImVec4(0.40, 0.39, 0.38, 0.16)
	 colors[clr.CloseButtonHovered] = ImVec4(0.40, 0.39, 0.38, 0.39)
	 colors[clr.CloseButtonActive] = ImVec4(0.40, 0.39, 0.38, 1.00)
	 colors[clr.PlotLines] = ImVec4(0.61, 0.61, 0.61, 1.00)
	 colors[clr.PlotLinesHovered] = ImVec4(1.00, 0.43, 0.35, 1.00)
	 colors[clr.PlotHistogram] = ImVec4(0.90, 0.70, 0.00, 1.00)
	 colors[clr.PlotHistogramHovered] = ImVec4(1.00, 0.60, 0.00, 1.00)
	 colors[clr.TextSelectedBg] = ImVec4(0.25, 1.00, 0.00, 0.43)
	 colors[clr.ModalWindowDarkening] = ImVec4(1.00, 0.98, 0.95, 0.73)
end

apply_custom_style()
