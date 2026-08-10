-- SkyWeb_v1.1.lua
-- SA-MP Web Browser by Shaolin Skywalker (Full Version)

script_name("SkyWeb")
script_author("Shaolin Skywalker")
script_version("1.1")

local imgui = require 'imgui'
local encoding = require 'encoding'
encoding.default = 'CP1251'
u8 = encoding.UTF8

local sw, sh = getScreenResolution()
local main_menu = imgui.ImBool(false)

-- Версия и GitHub репозиторий
local SCRIPT_VERSION = "1.1"
local GITHUB_REPO = "shukillua/skyweb"

-- Конфиг директория
local CONFIG_DIR = "moonloader/config/skyweb/"

-- Функция создания директории
local function ensureConfigDir()
    local config_exists = os.rename("moonloader/config", "moonloader/config") 
    if not config_exists then
        os.execute('mkdir "moonloader/config"')
    end
    
    local skyweb_exists = os.rename(CONFIG_DIR, CONFIG_DIR)
    if not skyweb_exists then
        os.execute('mkdir "' .. CONFIG_DIR:sub(1, -2) .. '"')
    end
end

-- Стандартные ссылки
local links = {
    {name = "YouTube", url = "https://www.youtube.com"},
    {name = "VK", url = "https://vk.com"},
    {name = "Telegram", url = "https://web.telegram.org"},
    {name = "Discord", url = "https://discord.com"},
}

-- Предустановленные ссылки
local preset_links = {
    {name = "GitHub", url = "https://www.github.com"},
    {name = "Twitch", url = "https://www.twitch.tv"},
    {name = "Steam", url = "https://store.steampowered.com"},
    {name = "Spotify", url = "https://open.spotify.com"},
    {name = "WhatsApp", url = "https://web.whatsapp.com"},
    {name = "Reddit", url = "https://www.reddit.com"},
    {name = "Wikipedia", url = "https://www.wikipedia.org"},
    {name = "RuTube", url = "https://rutube.ru"},
    {name = "Yandex", url = "https://ya.ru"},
    {name = "SoundCloud", url = "https://soundcloud.com"},
}

local user_links = {}

-- Цвета
local color_themes = {
    {name = "Классический (Темный)", r = 0.10, g = 0.09, b = 0.12, is_dark = true},
    {name = "Темно-Зеленый", r = 0.05, g = 0.35, b = 0.05, is_dark = true},
    {name = "Темно-Красный", r = 0.35, g = 0.05, b = 0.05, is_dark = true},
    {name = "Темно-Синий", r = 0.05, g = 0.05, b = 0.35, is_dark = true},
    {name = "Темно-Фиолетовый", r = 0.25, g = 0.05, b = 0.35, is_dark = true},
    {name = "Темно-Оранжевый", r = 0.35, g = 0.15, b = 0.05, is_dark = true},
    {name = "Темно-Бирюзовый", r = 0.05, g = 0.35, b = 0.30, is_dark = true},
    {name = "Темно-Розовый", r = 0.35, g = 0.05, b = 0.20, is_dark = true},
    {name = "Темно-Золотой", r = 0.35, g = 0.25, b = 0.05, is_dark = true},
    {name = "Темный Киберпанк", r = 0.20, g = 0.05, b = 0.40, is_dark = true},
    {name = "Светлый (Классический)", r = 0.90, g = 0.88, b = 0.85, is_dark = false},
    {name = "Светло-Зеленый", r = 0.85, g = 0.95, b = 0.85, is_dark = false},
    {name = "Светло-Красный", r = 0.95, g = 0.85, b = 0.85, is_dark = false},
    {name = "Светло-Синий", r = 0.85, g = 0.90, b = 0.95, is_dark = false},
    {name = "Светло-Фиолетовый", r = 0.90, g = 0.85, b = 0.95, is_dark = false},
    {name = "Светло-Оранжевый", r = 0.95, g = 0.88, b = 0.80, is_dark = false},
    {name = "Светло-Бирюзовый", r = 0.80, g = 0.95, b = 0.92, is_dark = false},
    {name = "Светло-Розовый", r = 0.95, g = 0.85, b = 0.90, is_dark = false},
    {name = "Светло-Золотой", r = 0.95, g = 0.90, b = 0.80, is_dark = false},
    {name = "Светлый Киберпанк", r = 0.85, g = 0.80, b = 0.95, is_dark = false},
}

local current_color_index = 1

-- Сохранение/загрузка цвета
local function saveColor()
    ensureConfigDir()
    local file = io.open(CONFIG_DIR .. "skyweb_color.txt", "w")
    if file then
        file:write(current_color_index)
        file:close()
        return true
    end
    return false
end

local function loadColor()
    ensureConfigDir()
    local file = io.open(CONFIG_DIR .. "skyweb_color.txt", "r")
    if file then
        local color = file:read("*all")
        if color and color ~= "" then
            local num = tonumber(color)
            if num and num >= 1 and num <= #color_themes then
                current_color_index = num
            end
        end
        file:close()
        return true
    end
    return false
end

-- Применение цвета
function applyColor(theme_id)
    imgui.SwitchContext()
    local style = imgui.GetStyle()
    local colors = style.Colors
    local clr = imgui.Col
    local ImVec4 = imgui.ImVec4
    
    local theme = color_themes[theme_id]
    if not theme then return end
    
    style.WindowRounding = 10
    style.FrameRounding = 6.0
    style.ItemSpacing = imgui.ImVec2(9.0, 3.0)
    style.WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
    style.ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
    
    local base_r, base_g, base_b = theme.r, theme.g, theme.b
    local is_dark = theme.is_dark
    
    if is_dark then
        colors[clr.Text] = ImVec4(0.80, 0.80, 0.83, 1.00)
        colors[clr.WindowBg] = ImVec4(base_r * 0.6, base_g * 0.6, base_b * 0.6, 1.00)
        colors[clr.Border] = ImVec4(base_r * 2, base_g * 2, base_b * 2, 0.88)
        colors[clr.FrameBg] = ImVec4(base_r, base_g, base_b, 1.00)
        colors[clr.FrameBgHovered] = ImVec4(base_r * 2, base_g * 2, base_b * 2, 1.00)
        colors[clr.TitleBg] = ImVec4(base_r, base_g, base_b, 1.00)
        colors[clr.TitleBgActive] = ImVec4(base_r * 0.7, base_g * 0.7, base_b * 0.7, 1.00)
        colors[clr.Button] = ImVec4(base_r, base_g, base_b, 1.00)
        colors[clr.ButtonHovered] = ImVec4(base_r * 2, base_g * 2, base_b * 2, 1.00)
        colors[clr.ButtonActive] = ImVec4(base_r * 3, base_g * 3, base_b * 3, 1.00)
        colors[clr.CloseButton] = ImVec4(0.40, 0.39, 0.38, 0.16)
        colors[clr.CloseButtonHovered] = ImVec4(0.40, 0.39, 0.38, 0.39)
    else
        colors[clr.Text] = ImVec4(0.10, 0.10, 0.13, 1.00)
        colors[clr.WindowBg] = ImVec4(base_r, base_g, base_b, 1.00)
        colors[clr.Border] = ImVec4(0.50, 0.50, 0.50, 0.50)
        colors[clr.FrameBg] = ImVec4(base_r * 1.1, base_g * 1.1, base_b * 1.1, 1.00)
        colors[clr.FrameBgHovered] = ImVec4(base_r * 0.9, base_g * 0.9, base_b * 0.9, 1.00)
        colors[clr.TitleBg] = ImVec4(base_r * 1.2, base_g * 1.2, base_b * 1.2, 1.00)
        colors[clr.TitleBgActive] = ImVec4(base_r * 1.1, base_g * 1.1, base_b * 1.1, 1.00)
        colors[clr.Button] = ImVec4(base_r * 1.1, base_g * 1.1, base_b * 1.1, 1.00)
        colors[clr.ButtonHovered] = ImVec4(base_r * 0.9, base_g * 0.9, base_b * 0.9, 1.00)
        colors[clr.ButtonActive] = ImVec4(base_r * 0.8, base_g * 0.8, base_b * 0.8, 1.00)
        colors[clr.CloseButton] = ImVec4(0.60, 0.59, 0.58, 0.30)
        colors[clr.CloseButtonHovered] = ImVec4(0.60, 0.59, 0.58, 0.60)
    end
end

-- Открытие URL
function openUrl(url)
    if not url or url == "" then 
        sampAddChatMessage("{FF0000}[SkyWeb] Неверный URL!", -1)
        return 
    end
    
    url = url:gsub('"', '\\"')
    if not url:match("^https?://") then 
        url = "https://" .. url 
    end
    
    sampAddChatMessage("{FFFF00}[SkyWeb] Открываю: " .. url, -1)
    pcall(function()
        os.execute(string.format('start "" "%s"', url))
    end)
end

-- Сохранение/загрузка ссылок
local function saveUserLinks()
    ensureConfigDir()
    local file = io.open(CONFIG_DIR .. "skyweb_links.txt", "w")
    if file then
        for _, link in ipairs(user_links) do
            file:write(link.name .. "|||" .. link.url .. "\n")
        end
        file:close()
        return true
    end
    return false
end

local function loadUserLinks()
    ensureConfigDir()
    local file = io.open(CONFIG_DIR .. "skyweb_links.txt", "r")
    if file then
        for line in file:lines() do
            local name, url = line:match("(.+)|||(.+)")
            if name and url then
                table.insert(user_links, {name = name, url = url})
            end
        end
        file:close()
        return true
    end
    return false
end

-- Переменные для контекстного меню
local context_open = false
local context_index = nil
local context_x = 0
local context_y = 0

-- Переменные для редактирования
local edit_mode = false
local edit_index = nil
local edit_name = ""
local edit_url = ""

-- Переменные для подтверждения удаления
local delete_confirm_open = false
local delete_index = nil

-- Функции контекстного меню
function openContext(index, x, y)
    context_index = index
    context_x = x
    context_y = y
    context_open = true
end

function closeContext()
    context_open = false
    context_index = nil
end

-- Функции редактирования
function startEdit(index)
    if index and index >= 1 and index <= #user_links then
        edit_mode = true
        edit_index = index
        edit_name = user_links[index].name
        edit_url = user_links[index].url
        closeContext()
        sampAddChatMessage("{FFFF00}[SkyWeb] Редактирование: " .. user_links[index].name, -1)
        sampAddChatMessage("{FFFF00}[SkyWeb] Введите /ename [новое имя] или /eurl [новый URL]", -1)
        sampAddChatMessage("{FFFF00}[SkyWeb] Для сохранения введите /esave", -1)
    end
end

function saveEdit()
    if edit_mode and edit_index then
        if edit_name ~= "" and edit_url ~= "" then
            local name_exists = false
            for i, link in ipairs(user_links) do
                if i ~= edit_index and link.name == edit_name then
                    name_exists = true
                    break
                end
            end
            
            if name_exists then
                sampAddChatMessage("{FF0000}[SkyWeb] Ошибка: Ссылка с таким именем уже существует!", -1)
                return
            end
            
            user_links[edit_index].name = edit_name
            user_links[edit_index].url = edit_url
            saveUserLinks()
            sampAddChatMessage("{00FF00}[SkyWeb] Ссылка успешно обновлена!", -1)
            
            edit_mode = false
            edit_index = nil
            edit_name = ""
            edit_url = ""
        else
            sampAddChatMessage("{FF0000}[SkyWeb] Ошибка: Название и URL не могут быть пустыми!", -1)
        end
    else
        sampAddChatMessage("{FF0000}[SkyWeb] Нет активного редактирования!", -1)
    end
end

function cancelEdit()
    if edit_mode then
        edit_mode = false
        edit_index = nil
        edit_name = ""
        edit_url = ""
        sampAddChatMessage("{FFFF00}[SkyWeb] Редактирование отменено", -1)
    end
end

-- Функции для удаления с подтверждением
function confirmDelete(index)
    if index and index >= 1 and index <= #user_links then
        delete_index = index
        closeContext()
        delete_confirm_open = true
    end
end

function executeDelete()
    if delete_index and delete_index >= 1 and delete_index <= #user_links then
        local name = user_links[delete_index].name
        table.remove(user_links, delete_index)
        saveUserLinks()
        sampAddChatMessage("{00FF00}[SkyWeb] Ссылка удалена: " .. name, -1)
        delete_confirm_open = false
        delete_index = nil
        if edit_mode and edit_index == delete_index then
            cancelEdit()
        end
    end
end

function cancelDelete()
    delete_confirm_open = false
    delete_index = nil
end

-- Команда открытия меню
function cmd_imgui()
    main_menu.v = not main_menu.v
    imgui.Process = main_menu.v
    if not main_menu.v then
        closeContext()
        delete_confirm_open = false
    end
end

-- Окна
local add_window = imgui.ImBool(false)
local settings_window = imgui.ImBool(false)
local custom_name = ""
local custom_url = ""
local show_custom = false

-- Рендер
function imgui.OnDrawFrame()
    if not main_menu.v then
        imgui.Process = false
        return
    end
    
    applyColor(current_color_index)
    
    local windowHeight = 300
    if #user_links > 0 then
        windowHeight = windowHeight + 40 + math.ceil(#user_links / 2) * 35
    end
    if edit_mode then
        windowHeight = windowHeight + 110
    end
    
    imgui.SetNextWindowSize(imgui.ImVec2(300, windowHeight), imgui.Cond.FirstUseEver)
    imgui.SetNextWindowPos(imgui.ImVec2(sw/2, sh/2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
    imgui.Begin(u8"SkyWeb", main_menu, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse)

    if color_themes[current_color_index].is_dark then
        imgui.Text(u8("by Shaolin Skywalker"))
    else
        imgui.TextColored(imgui.ImVec4(0.1, 0.1, 0.1, 1.0), u8("by Shaolin Skywalker"))
    end
    imgui.Separator()
    
    if imgui.Button(u8("Настройки"), imgui.ImVec2(290, 28)) then
        settings_window.v = true
    end
    imgui.Separator()
    
    if color_themes[current_color_index].is_dark then
        imgui.Text(u8("Быстрые ссылки:"))
    else
        imgui.TextColored(imgui.ImVec4(0.1, 0.1, 0.1, 1.0), u8("Быстрые ссылки:"))
    end
    imgui.Separator()
    
    for i, link in ipairs(links) do
        if i % 2 == 1 then
            if imgui.Button(u8(link.name), imgui.ImVec2(140, 28)) then
                openUrl(link.url)
            end
            if i < #links then imgui.SameLine() end
        else
            if imgui.Button(u8(link.name), imgui.ImVec2(140, 28)) then
                openUrl(link.url)
            end
        end
    end
    
    if #user_links > 0 then
        imgui.Separator()
        if color_themes[current_color_index].is_dark then
            imgui.Text(u8("Мои ссылки:"))
        else
            imgui.TextColored(imgui.ImVec4(0.1, 0.1, 0.1, 1.0), u8("Мои ссылки:"))
        end
        imgui.Separator()
        
        for i, link in ipairs(user_links) do
            if i % 2 == 1 then
                if imgui.Button(u8(link.name), imgui.ImVec2(140, 28)) then
                    openUrl(link.url)
                end
                if i < #user_links then 
                    imgui.SameLine() 
                end
            else
                if imgui.Button(u8(link.name), imgui.ImVec2(140, 28)) then
                    openUrl(link.url)
                end
            end
            
            -- Обработка ПКМ для контекстного меню
            if imgui.IsItemHovered() and imgui.IsMouseClicked(1) then
                local mouse_pos = imgui.GetMousePos()
                openContext(i, mouse_pos.x, mouse_pos.y)
            end
        end
    end
    
    imgui.Separator()
    
    if imgui.Button(u8("Добавить ссылку"), imgui.ImVec2(290, 28)) then
        add_window.v = true
        show_custom = false
        custom_name = ""
        custom_url = ""
    end
    
    -- Контекстное меню
    if context_open and context_index then
        applyColor(current_color_index)
        imgui.SetNextWindowPos(imgui.ImVec2(context_x, context_y), imgui.Cond.FirstUseEver)
        imgui.SetNextWindowSize(imgui.ImVec2(180, 80), imgui.Cond.FirstUseEver)
        imgui.Begin(u8"##context_menu", context_open, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoTitleBar)
        
        if imgui.Button(u8("Редактировать"), imgui.ImVec2(160, 28)) then
            startEdit(context_index)
        end
        
        if imgui.Button(u8("Удалить"), imgui.ImVec2(160, 28)) then
            confirmDelete(context_index)
        end
        
        imgui.End()
        
        if imgui.IsMouseClicked(0) or imgui.IsMouseClicked(1) then
            local mouse_pos = imgui.GetMousePos()
            if mouse_pos.x < context_x or mouse_pos.x > context_x + 180 or 
               mouse_pos.y < context_y or mouse_pos.y > context_y + 80 then
                closeContext()
            end
        end
    end
    
    -- Окно подтверждения удаления
    if delete_confirm_open then
        applyColor(current_color_index)
        imgui.SetNextWindowSize(imgui.ImVec2(280, 120), imgui.Cond.FirstUseEver)
        imgui.SetNextWindowPos(imgui.ImVec2(sw/2, sh/2 + 60), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.Begin(u8"Подтверждение удаления", delete_confirm_open, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse)
        
        if color_themes[current_color_index].is_dark then
            imgui.TextColored(imgui.ImVec4(1.0, 0.6, 0.6, 1.0), u8("Вы уверены что хотите удалить ссылку?"))
        else
            imgui.TextColored(imgui.ImVec4(0.8, 0.2, 0.2, 1.0), u8("Вы уверены что хотите удалить ссылку?"))
        end
        
        if delete_index and delete_index >= 1 and delete_index <= #user_links then
            if color_themes[current_color_index].is_dark then
                imgui.TextColored(imgui.ImVec4(1.0, 0.8, 0.2, 1.0), u8(user_links[delete_index].name))
            else
                imgui.TextColored(imgui.ImVec4(0.8, 0.4, 0.0, 1.0), u8(user_links[delete_index].name))
            end
        end
        
        imgui.Separator()
        
        imgui.SetCursorPosX(40)
        if imgui.Button(u8("Удалить"), imgui.ImVec2(90, 28)) then
            executeDelete()
        end
        imgui.SameLine()
        if imgui.Button(u8("Отмена"), imgui.ImVec2(90, 28)) then
            cancelDelete()
        end
        
        imgui.End()
    end
    
    if edit_mode then
        imgui.Separator()
        if color_themes[current_color_index].is_dark then
            imgui.TextColored(imgui.ImVec4(1.0, 0.8, 0.2, 1.0), u8("Редактирование ссылки:"))
        else
            imgui.TextColored(imgui.ImVec4(0.8, 0.4, 0.0, 1.0), u8("Редактирование ссылки:"))
        end
        if color_themes[current_color_index].is_dark then
            imgui.Text(u8("Имя: " .. edit_name))
            imgui.Text(u8("URL: " .. edit_url))
        else
            imgui.TextColored(imgui.ImVec4(0.1, 0.1, 0.1, 1.0), u8("Имя: " .. edit_name))
            imgui.TextColored(imgui.ImVec4(0.1, 0.1, 0.1, 1.0), u8("URL: " .. edit_url))
        end
        
        if imgui.Button(u8("Сохранить"), imgui.ImVec2(140, 28)) then
            saveEdit()
        end
        imgui.SameLine()
        if imgui.Button(u8("Отмена"), imgui.ImVec2(140, 28)) then
            cancelEdit()
        end
        
        if color_themes[current_color_index].is_dark then
            imgui.TextColored(imgui.ImVec4(0.6, 0.8, 1.0, 1.0), u8("Команды в чате:"))
            imgui.TextColored(imgui.ImVec4(0.6, 1.0, 0.6, 1.0), u8("/ename [новое имя]"))
            imgui.TextColored(imgui.ImVec4(0.6, 1.0, 0.6, 1.0), u8("/eurl [новый URL]"))
            imgui.TextColored(imgui.ImVec4(1.0, 0.8, 0.2, 1.0), u8("/esave - сохранить изменения"))
            imgui.TextColored(imgui.ImVec4(1.0, 0.8, 0.2, 1.0), u8("/ecancel - отменить"))
        else
            imgui.TextColored(imgui.ImVec4(0.2, 0.3, 0.5, 1.0), u8("Команды в чате:"))
            imgui.TextColored(imgui.ImVec4(0.0, 0.5, 0.0, 1.0), u8("/ename [новое имя]"))
            imgui.TextColored(imgui.ImVec4(0.0, 0.5, 0.0, 1.0), u8("/eurl [новый URL]"))
            imgui.TextColored(imgui.ImVec4(0.8, 0.4, 0.0, 1.0), u8("/esave - сохранить изменения"))
            imgui.TextColored(imgui.ImVec4(0.8, 0.4, 0.0, 1.0), u8("/ecancel - отменить"))
        end
    end
    
    imgui.End()
    
    -- Окно добавления ссылки
    if add_window.v then
        applyColor(current_color_index)
        imgui.SetNextWindowSize(imgui.ImVec2(320, 430), imgui.Cond.FirstUseEver)
        imgui.SetNextWindowPos(imgui.ImVec2(sw/2, sh/2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.Begin(u8"Добавить ссылку", add_window, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse)
        
        if color_themes[current_color_index].is_dark then
            imgui.Text(u8("Готовые ссылки:"))
        else
            imgui.TextColored(imgui.ImVec4(0.1, 0.1, 0.1, 1.0), u8("Готовые ссылки:"))
        end
        imgui.Separator()
        
        for i, preset in ipairs(preset_links) do
            if i % 2 == 1 then
                if imgui.Button(u8(preset.name), imgui.ImVec2(140, 28)) then
                    local exists = false
                    for _, link in ipairs(user_links) do
                        if link.name == preset.name then exists = true; break end
                    end
                    if not exists then
                        table.insert(user_links, {name = preset.name, url = preset.url})
                        saveUserLinks()
                        add_window.v = false
                    else
                        sampAddChatMessage("{FF0000}[SkyWeb] Такая ссылка уже есть!", -1)
                    end
                end
                if i < #preset_links then imgui.SameLine() end
            else
                if imgui.Button(u8(preset.name), imgui.ImVec2(140, 28)) then
                    local exists = false
                    for _, link in ipairs(user_links) do
                        if link.name == preset.name then exists = true; break end
                    end
                    if not exists then
                        table.insert(user_links, {name = preset.name, url = preset.url})
                        saveUserLinks()
                        add_window.v = false
                    else
                        sampAddChatMessage("{FF0000}[SkyWeb] Такая ссылка уже есть!", -1)
                    end
                end
            end
        end
        
        imgui.Separator()
        
        if not show_custom then
            if imgui.Button(u8("Своя ссылка"), imgui.ImVec2(290, 30)) then
                show_custom = true
                sampAddChatMessage("{FFFF00}[SkyWeb] Введите в чат: /sname [название]", -1)
                sampAddChatMessage("{FFFF00}[SkyWeb] Затем: /surl [ссылка]", -1)
            end
        else
            if color_themes[current_color_index].is_dark then
                imgui.Text(u8("Название: " .. custom_name))
                imgui.Text(u8("URL: " .. custom_url))
            else
                imgui.TextColored(imgui.ImVec4(0.1, 0.1, 0.1, 1.0), u8("Название: " .. custom_name))
                imgui.TextColored(imgui.ImVec4(0.1, 0.1, 0.1, 1.0), u8("URL: " .. custom_url))
            end
            
            if imgui.Button(u8("Добавить"), imgui.ImVec2(140, 28)) then
                if custom_name ~= "" and custom_url ~= "" then
                    local exists = false
                    for _, link in ipairs(user_links) do
                        if link.name == custom_name then exists = true; break end
                    end
                    if not exists then
                        if not custom_url:match("^https?://") then
                            custom_url = "https://" .. custom_url
                        end
                        table.insert(user_links, {name = custom_name, url = custom_url})
                        saveUserLinks()
                        sampAddChatMessage("{00FF00}[SkyWeb] Ссылка добавлена!", -1)
                        add_window.v = false
                    else
                        sampAddChatMessage("{FF0000}[SkyWeb] Такая ссылка уже есть!", -1)
                    end
                else
                    sampAddChatMessage("{FF0000}[SkyWeb] Заполните все поля!", -1)
                end
            end
            
            imgui.SameLine()
            
            if imgui.Button(u8("Отмена"), imgui.ImVec2(140, 28)) then
                show_custom = false
                custom_name = ""
                custom_url = ""
            end
        end
        
        imgui.Separator()
        imgui.SetCursorPosX(95)
        if imgui.Button(u8("Закрыть"), imgui.ImVec2(130, 30)) then
            add_window.v = false
            show_custom = false
            custom_name = ""
            custom_url = ""
        end
        
        imgui.End()
    end
    
    -- Окно настроек
    if settings_window.v then
        applyColor(current_color_index)
        imgui.SetNextWindowSize(imgui.ImVec2(340, 430), imgui.Cond.FirstUseEver)
        imgui.SetNextWindowPos(imgui.ImVec2(sw/2, sh/2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.Begin(u8"Настройки SkyWeb", settings_window, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse)
        
        if color_themes[current_color_index].is_dark then
            imgui.TextColored(imgui.ImVec4(0.8, 0.6, 1.0, 1.0), u8("SkyWeb v" .. SCRIPT_VERSION))
        else
            imgui.TextColored(imgui.ImVec4(0.3, 0.1, 0.5, 1.0), u8("SkyWeb v" .. SCRIPT_VERSION))
        end
        imgui.Separator()
        
        if color_themes[current_color_index].is_dark then
            imgui.TextColored(imgui.ImVec4(0.6, 0.8, 1.0, 1.0), u8("Настройки интерфейса:"))
        else
            imgui.TextColored(imgui.ImVec4(0.2, 0.3, 0.5, 1.0), u8("Настройки интерфейса:"))
        end
        
        local theme_name = color_themes[current_color_index].name
        if imgui.Button(u8("Сменить тему: " .. theme_name), imgui.ImVec2(310, 28)) then
            current_color_index = current_color_index + 1
            if current_color_index > #color_themes then
                current_color_index = 1
            end
            saveColor()
        end
        
        imgui.Spacing()
        imgui.Separator()
        
        if color_themes[current_color_index].is_dark then
            imgui.TextColored(imgui.ImVec4(0.6, 0.8, 1.0, 1.0), u8("Текущая тема: " .. (color_themes[current_color_index].is_dark and "Темная" or "Светлая")))
        else
            imgui.TextColored(imgui.ImVec4(0.8, 0.6, 0.2, 1.0), u8("Текущая тема: " .. (color_themes[current_color_index].is_dark and "Темная" or "Светлая")))
        end
        imgui.TextWrapped(u8("Доступно 20 тем: 10 темных и 10 светлых"))
        
        imgui.Separator()
        
        if color_themes[current_color_index].is_dark then
            imgui.TextColored(imgui.ImVec4(0.6, 1.0, 0.6, 1.0), u8("Управление ссылками:"))
        else
            imgui.TextColored(imgui.ImVec4(0.0, 0.5, 0.0, 1.0), u8("Управление ссылками:"))
        end
        imgui.TextWrapped(u8("Нажмите ПКМ на ссылку для вызова меню."))
        imgui.TextWrapped(u8("Доступные действия: Редактировать, Удалить"))
        imgui.TextWrapped(u8("Для редактирования используйте команды:"))
        if color_themes[current_color_index].is_dark then
            imgui.TextColored(imgui.ImVec4(0.6, 0.8, 1.0, 1.0), u8("/ename [новое имя]"))
            imgui.TextColored(imgui.ImVec4(0.6, 0.8, 1.0, 1.0), u8("/eurl [новый URL]"))
            imgui.TextColored(imgui.ImVec4(1.0, 0.8, 0.2, 1.0), u8("/esave - сохранить"))
            imgui.TextColored(imgui.ImVec4(1.0, 0.8, 0.2, 1.0), u8("/ecancel - отменить"))
        else
            imgui.TextColored(imgui.ImVec4(0.2, 0.3, 0.5, 1.0), u8("/ename [новое имя]"))
            imgui.TextColored(imgui.ImVec4(0.2, 0.3, 0.5, 1.0), u8("/eurl [новый URL]"))
            imgui.TextColored(imgui.ImVec4(0.8, 0.4, 0.0, 1.0), u8("/esave - сохранить"))
            imgui.TextColored(imgui.ImVec4(0.8, 0.4, 0.0, 1.0), u8("/ecancel - отменить"))
        end
        
        imgui.Separator()
        
        if color_themes[current_color_index].is_dark then
            imgui.TextColored(imgui.ImVec4(0.6, 0.8, 1.0, 1.0), u8("Ссылки:"))
        else
            imgui.TextColored(imgui.ImVec4(0.2, 0.3, 0.5, 1.0), u8("Ссылки:"))
        end
        
        if imgui.Button(u8("Страница скрипта на GitHub"), imgui.ImVec2(310, 28)) then
            openUrl("https://github.com/" .. GITHUB_REPO)
        end
        
        if imgui.Button(u8("Связь с автором"), imgui.ImVec2(310, 28)) then
            openUrl("https://guns.lol/shukillua")
        end
        
        imgui.Separator()
        
        imgui.TextWrapped(u8("Скрипт для быстрого открытия веб-страниц в SA-MP."))
        imgui.Spacing()
        
        if color_themes[current_color_index].is_dark then
            imgui.TextColored(imgui.ImVec4(0.6, 0.8, 1.0, 1.0), u8("Команды:"))
        else
            imgui.TextColored(imgui.ImVec4(0.2, 0.3, 0.5, 1.0), u8("Команды:"))
        end
        imgui.BulletText(u8("/skyweb - Открыть меню"))
        imgui.BulletText(u8("/sw - Открыть меню"))
        imgui.BulletText(u8("/sname [название] - Имя ссылки"))
        imgui.BulletText(u8("/surl [ссылка] - URL ссылки"))
        
        imgui.Separator()
        
        imgui.SetCursorPosX(110)
        if imgui.Button(u8("Закрыть"), imgui.ImVec2(120, 30)) then
            settings_window.v = false
        end
        
        imgui.End()
    end
end

-- Главная функция
function main()
    repeat wait(100) until isSampAvailable()
    wait(1000)
    
    ensureConfigDir()
    loadUserLinks()
    loadColor()
    applyColor(current_color_index)
    
    sampAddChatMessage("{00FFFF}[SkyWeb v" .. SCRIPT_VERSION .. "] {00FAAA} Скрипт активирован, для открытия - /skyweb. by Shaolin Skywalker", -1)
    
    sampRegisterChatCommand("skyweb", cmd_imgui)
    sampRegisterChatCommand("sw", cmd_imgui)
    
    -- Команды для добавления ссылок
    sampRegisterChatCommand("sname", function(arg)
        if arg and arg ~= "" then
            custom_name = arg
            sampAddChatMessage("{00FF00}[SkyWeb] Название: " .. custom_name, -1)
        end
    end)
    
    sampRegisterChatCommand("surl", function(arg)
        if arg and arg ~= "" then
            custom_url = arg
            sampAddChatMessage("{00FF00}[SkyWeb] URL: " .. custom_url, -1)
        end
    end)
    
    -- Команды для редактирования ссылок
    sampRegisterChatCommand("ename", function(arg)
        if arg and arg ~= "" then
            if edit_mode then
                local name_exists = false
                for i, link in ipairs(user_links) do
                    if i ~= edit_index and link.name == arg then
                        name_exists = true
                        break
                    end
                end
                
                if name_exists then
                    sampAddChatMessage("{FF0000}[SkyWeb] Ошибка: Ссылка с таким именем уже существует!", -1)
                else
                    edit_name = arg
                    sampAddChatMessage("{00FF00}[SkyWeb] Имя изменено на: " .. edit_name, -1)
                end
            else
                sampAddChatMessage("{FF0000}[SkyWeb] Нет активного редактирования! Нажмите ПКМ на ссылку и выберите 'Редактировать'.", -1)
            end
        else
            sampAddChatMessage("{FFFF00}[SkyWeb] Использование: /ename [новое имя]", -1)
        end
    end)
    
    sampRegisterChatCommand("eurl", function(arg)
        if arg and arg ~= "" then
            if edit_mode then
                edit_url = arg
                sampAddChatMessage("{00FF00}[SkyWeb] URL изменен на: " .. edit_url, -1)
            else
                sampAddChatMessage("{FF0000}[SkyWeb] Нет активного редактирования! Нажмите ПКМ на ссылку и выберите 'Редактировать'.", -1)
            end
        else
            sampAddChatMessage("{FFFF00}[SkyWeb] Использование: /eurl [новый URL]", -1)
        end
    end)
    
    sampRegisterChatCommand("esave", function()
        saveEdit()
    end)
    
    sampRegisterChatCommand("ecancel", function()
        cancelEdit()
    end)
    
    while true do
        wait(1000)
    end
end