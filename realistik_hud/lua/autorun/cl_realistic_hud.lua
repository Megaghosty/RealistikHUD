-- Désactiver le HUD par défaut
local hideHUDElements = {
    ["CHudHealth"] = true,
    ["CHudBattery"] = true,
    ["CHudAmmo"] = true,
    ["CHudSecondaryAmmo"] = true
}

hook.Add("HUDShouldDraw", "HideDefaultHUD", function(name)
    if hideHUDElements[name] then
        return false
    end
end)

-- Définir une police personnalisée pour le HUD avec un style militaire/debug
surface.CreateFont("HUDMilitaryFont", {
    font = "DebugFixed",
    size = 18,
    weight = 800,
    antialias = true
})

surface.CreateFont("HUDTitleFont", {
    font = "DebugFixed",
    size = 24,
    weight = 1000,
    antialias = true
})

-- Fonction pour dessiner un fond avec un dégradé
local function DrawGradientBox(x, y, w, h, color1, color2)
    local gradient = surface.GetTextureID("gui/gradient")
    surface.SetDrawColor(color1)
    surface.SetTexture(gradient)
    surface.DrawTexturedRect(x, y, w, h)

    surface.SetDrawColor(color2)
    surface.DrawTexturedRectRotated(x + w / 2, y + h / 2, w, h, 180)
end

-- Fonction pour dessiner le rythme cardiaque (ECG réaliste)
local function DrawHeartbeat(scrW, scrH, health)
    local centerX = 20
    local centerY = scrH - 100
    local width = 300
    local height = 50
    local healthRatio = health / 100

    local lineColor = Color(255 * (1 - healthRatio), 255 * healthRatio, 0, 255)

    DrawGradientBox(centerX, centerY - height / 2, width, height, Color(20, 20, 20, 200), Color(10, 10, 10, 200))
    surface.SetDrawColor(0, 255, 0, 255)
    surface.DrawOutlinedRect(centerX, centerY - height / 2, width, height)

    surface.SetDrawColor(lineColor)
    local points = {}
    local scrollOffset = CurTime() * 100

    local beep = false
    for i = 0, width, 2 do
        local x = centerX + i
        local phase = (i + scrollOffset) % 100
        local y = centerY

        if phase < 15 then
            y = y - math.sin(phase / 15 * math.pi) * (height / 6 * healthRatio)
        elseif phase < 30 then
            y = y
        elseif phase < 40 then
            y = y - (height / 2 * healthRatio)
            if i == math.floor(width / 2) and health < 40 then
                beep = true
            end
        elseif phase < 50 then
            y = y + (height / 3 * healthRatio)
        elseif phase < 70 then
            y = y + math.sin((phase - 50) / 20 * math.pi) * (height / 8 * healthRatio)
        else
            y = y
        end

        table.insert(points, {x = x, y = y})
    end

    for i = 1, #points - 1 do
        surface.DrawLine(points[i].x, points[i].y, points[i + 1].x, points[i + 1].y)
    end

    if beep then
        surface.PlaySound("buttons/blip1.wav")
    end
end

-- Fonction pour dessiner les munitions sous forme de chargeur
local function DrawAmmoBar(scrW, scrH, ammo, maxAmmo, ammoType)
    local barX = scrW - 100
    local barY = scrH - 300
    local barWidth = 60
    local barHeight = 200
    local bulletHeight = 10 -- Hauteur d'une balle
    local bulletSpacing = 2 -- Espacement entre les balles
    local maxBullets = math.floor(barHeight / (bulletHeight + bulletSpacing)) -- Nombre maximum de balles affichables

    -- Déterminer la couleur en fonction du type de munition
    local ammoColor = Color(255, 215, 0, 255) -- Par défaut : jaune
    if ammoType == "SMG1" then
        ammoColor = Color(0, 255, 0, 255) -- Vert pour les munitions SMG
    elseif ammoType == "AR2" then
        ammoColor = Color(0, 0, 255, 255) -- Bleu pour les munitions AR2
    elseif ammoType == "Buckshot" then
        ammoColor = Color(255, 0, 0, 255) -- Rouge pour les munitions de fusil à pompe
    elseif ammoType == "Pistol" then
        ammoColor = Color(255, 255, 255, 255) -- Blanc pour les munitions de pistolet
    end

    DrawGradientBox(barX, barY, barWidth, barHeight, Color(20, 20, 20, 200), Color(10, 10, 10, 200))
    surface.SetDrawColor(0, 255, 0, 255)
    surface.DrawOutlinedRect(barX, barY, barWidth, barHeight)

    -- Dessiner les balles restantes
    for i = 1, math.min(ammo, maxBullets) do
        local bulletY = barY + barHeight - (i * (bulletHeight + bulletSpacing))
        draw.RoundedBox(2, barX + 10, bulletY, barWidth - 20, bulletHeight, ammoColor)
    end
end

-- Fonction pour dessiner le sélecteur de tir amélioré
local function DrawFireModeSelector(scrW, scrH, fireModes, currentFireMode)
    local selectorX = scrW - 200
    local selectorY = scrH - 350
    local selectorWidth = 150
    local selectorHeight = 20 + (#fireModes * 30)
    local modeSpacing = 30

    DrawGradientBox(selectorX, selectorY, selectorWidth, selectorHeight, Color(20, 20, 20, 200), Color(10, 10, 10, 200))
    surface.SetDrawColor(0, 255, 0, 255)
    surface.DrawOutlinedRect(selectorX, selectorY, selectorWidth, selectorHeight)

    for i, mode in ipairs(fireModes) do
        local modeY = selectorY + 10 + (i - 1) * modeSpacing
        local color = (mode == currentFireMode) and Color(0, 255, 0, 255) or Color(255, 255, 255, 255)
        draw.SimpleText("• " .. mode, "HUDMilitaryFont", selectorX + 10, modeY, color, TEXT_ALIGN_LEFT)
    end

    draw.SimpleText("Mode de tir", "HUDTitleFont", selectorX, selectorY - 25, Color(0, 255, 0, 255), TEXT_ALIGN_LEFT)
end

-- Fonction pour dessiner la boussole
local function DrawCompass(ply, scrW, scrH)
    local directions = {"N", "NE", "E", "SE", "S", "SW", "W", "NW"}
    local compassWidth = 400
    local compassHeight = 30
    local centerX = scrW / 2
    local centerY = 40
    local playerYaw = ply:EyeAngles().y

    DrawGradientBox(centerX - compassWidth / 2, centerY - compassHeight / 2, compassWidth, compassHeight, Color(20, 20, 20, 200), Color(10, 10, 10, 200))
    surface.SetDrawColor(0, 255, 0, 255)
    surface.DrawOutlinedRect(centerX - compassWidth / 2, centerY - compassHeight / 2, compassWidth, compassHeight)

    for i = 1, #directions do
        local angle = (i - 1) * 45
        local relativeAngle = math.AngleDifference(angle, playerYaw)
        local position = (relativeAngle / 90) * (compassWidth / 2)

        if math.abs(position) <= compassWidth / 2 then
            draw.SimpleText(directions[i], "HUDMilitaryFont", centerX + position, centerY, Color(0, 255, 0, 255), TEXT_ALIGN_CENTER)
        end
    end
end

-- Fonction pour dessiner l'armure
local function DrawArmor(scrW, scrH, armor)
    local hudWidth, hudHeight = 200, 40
    local armorX = 20
    local armorY = scrH - hudHeight - 120

    DrawGradientBox(armorX, armorY, hudWidth, hudHeight, Color(20, 20, 20, 200), Color(10, 10, 10, 200))
    surface.SetDrawColor(0, 255, 0, 255)
    surface.DrawOutlinedRect(armorX, armorY, hudWidth, hudHeight)
    draw.SimpleText("ARMURE: " .. armor, "HUDMilitaryFont", armorX + 10, armorY + 10, Color(0, 255, 0, 255), TEXT_ALIGN_LEFT)
end

-- Fonction pour obtenir les modes de tir disponibles
local function GetFireModes(weapon)
    if not IsValid(weapon) then return {"N/A"}, "N/A" end

    local success, fireModes = pcall(function()
        if weapon.GetFireModes then
            return weapon:GetFireModes()
        elseif weapon.FireModes then
            return weapon.FireModes
        end
    end)

    local success2, currentMode = pcall(function()
        if weapon.GetFireModeName then
            return weapon:GetFireModeName()
        elseif weapon.FireMode then
            return weapon.FireMode
        end
    end)

    if success and success2 and fireModes and currentMode then
        return fireModes, currentMode
    end

    if weapon.Primary and weapon.Primary.Automatic ~= nil then
        local modes = {}
        if weapon.Primary.Burst then table.insert(modes, "Burst") end
        table.insert(modes, weapon.Primary.Automatic and "Automatique" or "Semi-auto")
        return modes, weapon.Primary.Automatic and "Automatique" or "Semi-auto"
    end

    return {"N/A"}, "N/A"
end

-- Dessiner le HUD personnalisé
hook.Add("HUDPaint", "RealisticHUD", function()
    local ply = LocalPlayer()
    if not IsValid(ply) or not ply:Alive() then return end

    local scrW, scrH = ScrW(), ScrH()
    local health = math.Clamp(ply:Health(), 0, ply:GetMaxHealth())
    local armor = math.Clamp(ply:Armor(), 0, 100)
    local weapon = ply:GetActiveWeapon()
    local ammo = IsValid(weapon) and weapon:Clip1() or -1
    local maxAmmo = IsValid(weapon) and weapon:GetMaxClip1() or -1
    local ammoType = IsValid(weapon) and weapon:GetPrimaryAmmoType() or "N/A"
    local fireModes, currentFireMode = GetFireModes(weapon)

    DrawCompass(ply, scrW, scrH)
    DrawHeartbeat(scrW, scrH, health)
    DrawArmor(scrW, scrH, armor)

    if IsValid(weapon) and ammo >= 0 and maxAmmo > 0 then
        DrawAmmoBar(scrW, scrH, ammo, maxAmmo, game.GetAmmoName(ammoType))
    end

    if IsValid(weapon) then
        DrawFireModeSelector(scrW, scrH, fireModes, currentFireMode)
    end
end)
