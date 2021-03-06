pfUI:RegisterModule("gui", function ()
  pfUI.gui = CreateFrame("Frame",nil,UIParent)

  pfUI.gui:RegisterEvent("PLAYER_ENTERING_WORLD");

  pfUI.gui:SetFrameStrata("DIALOG")
  pfUI.gui:SetWidth(480)
  pfUI.gui:SetHeight(420)
  pfUI.gui:Hide()

  pfUI.gui:SetBackdrop(pfUI.backdrop)
  pfUI.gui:SetBackdropColor(0,0,0,.75);
  pfUI.gui:SetPoint("CENTER",0,0)
  pfUI.gui:SetMovable(true)
  pfUI.gui:EnableMouse(true)
  pfUI.gui:SetScript("OnMouseDown",function()
      pfUI.gui:StartMoving()
    end)
  pfUI.gui:SetScript("OnMouseUp",function()
      pfUI.gui:StopMovingOrSizing()
    end)

  function pfUI.gui.SwitchTab(frame)
    local elements = { pfUI.gui.global, pfUI.gui.uf , pfUI.gui.bar, pfUI.gui.panel, pfUI.gui.tooltip,
                       pfUI.gui.castbar, pfUI.gui.thirdparty, pfUI.gui.chat, pfUI.gui.nameplates }

    for _, hide in pairs(elements) do
      hide:Hide()
    end
    frame:Show()
  end

  function pfUI.gui.CreateConfig(parent, caption, category, config)
    -- parent object placement
    if parent.objectCount == nil then
      parent.objectCount = 1
    else
      parent.objectCount = parent.objectCount + 1
    end

    -- basic frame
    local frame = CreateFrame("Frame", nil, parent)
    frame:SetWidth(350)
    frame:SetHeight(25)
    frame:SetBackdrop(pfUI.backdrop_underline)
    frame:SetBackdropBorderColor(1,1,1,.25)
    frame:SetPoint("TOPLEFT", 25, parent.objectCount * -25)

    -- caption
    frame.caption = frame:CreateFontString("Status", "LOW", "GameFontNormal")
    frame.caption:SetFont("Interface\\AddOns\\pfUI\\fonts\\arial.ttf", pfUI_config.global.font_size + 2, "OUTLINE")
    frame.caption:SetAllPoints(frame)
    frame.caption:SetFontObject(GameFontWhite)
    frame.caption:SetJustifyH("LEFT")
    frame.caption:SetText(caption)
    frame.configCategory = category
    frame.configEntry = config

    -- input field
    frame.input = CreateFrame("EditBox", nil, frame)
    frame.input:SetTextColor(.2,1.1,1)
    frame.input:SetJustifyH("RIGHT")

    frame.input:SetWidth(100)
    frame.input:SetHeight(20)
    frame.input:SetPoint("TOPRIGHT" , 0, 0)
    frame.input:SetFontObject(GameFontNormal)
    frame.input:SetAutoFocus(false)
    frame.input:SetText(category[config])
    frame.category = category
    frame.config = config
    frame.input:SetScript("OnEscapePressed", function(self)
      this:ClearFocus()
    end)

    frame.input:SetScript("OnEditFocusLost", function(self)
      this:GetParent().category[this:GetParent().config] = this:GetText()
      pfUI.gui.settingChanged = true
    end)

    return frame
  end

  function pfUI.gui.UnlockFrames()
    local movable = { pfUI.minimap, pfUI.chat.left, pfUI.chat.right,
      pfUI.uf.player, pfUI.uf.target, pfUI.uf.targettarget, pfUI.uf.pet,
      pfUI.bars.shapeshift, pfUI.bars.bottomleft, pfUI.bars.bottomright,
      pfUI.bars.vertical, pfUI.bars.pet, pfUI.bars.bottom, pfUI.panel.minimap,
      pfUI.uf.group[1], pfUI.uf.group[2], pfUI.uf.group[3], pfUI.uf.group[4],
      pfUI.uf.raid[1], pfUI.uf.raid[2], pfUI.uf.raid[3], pfUI.uf.raid[4], pfUI.uf.raid[5],
      pfUI.uf.raid[6], pfUI.uf.raid[7], pfUI.uf.raid[8], pfUI.uf.raid[9], pfUI.uf.raid[10],
      pfUI.uf.raid[11], pfUI.uf.raid[12], pfUI.uf.raid[13], pfUI.uf.raid[14], pfUI.uf.raid[15],
      pfUI.uf.raid[16], pfUI.uf.raid[17], pfUI.uf.raid[18], pfUI.uf.raid[19], pfUI.uf.raid[20],
      pfUI.uf.raid[21], pfUI.uf.raid[22], pfUI.uf.raid[23], pfUI.uf.raid[24], pfUI.uf.raid[25],
      pfUI.uf.raid[26], pfUI.uf.raid[27], pfUI.uf.raid[28], pfUI.uf.raid[29], pfUI.uf.raid[30],
      pfUI.uf.raid[31], pfUI.uf.raid[32], pfUI.uf.raid[33], pfUI.uf.raid[34], pfUI.uf.raid[35],
      pfUI.uf.raid[36], pfUI.uf.raid[37], pfUI.uf.raid[38], pfUI.uf.raid[39], pfUI.uf.raid[40],
      }

    if not pfUI.gitter then
      pfUI.gitter = CreateFrame("Frame", nil, UIParent)
      pfUI.gitter:SetFrameStrata("BACKGROUND")
      pfUI.gitter:SetPoint("TOPLEFT", 0, 0, "TOPLEFT")
      pfUI.gitter:SetPoint("BOTTOMRIGHT", 0, 0, "BOTTOMRIGHT")
      pfUI.gitter:SetBackdrop(pfUI.backdrop_gitter)
      pfUI.gitter:SetBackdropColor(0,0,0,1)
      pfUI.gitter:Hide()
    end

    if pfUI.gitter:IsShown() then
      pfUI.gitter:Hide()
    else
      pfUI.gitter:Show()
    end

    for _,frame in pairs(movable) do
      local frame = frame
      if not frame:IsShown() then
        frame.hideLater = true
      end

      if not frame.drag then
        frame.drag = CreateFrame("Frame", nil, frame)
        frame.drag:SetAllPoints(frame)
        frame.drag:SetFrameStrata("DIALOG")
        frame.drag.bg = frame.drag:CreateTexture()
        frame.drag.bg:SetAllPoints(frame.drag)
        frame.drag.bg:SetTexture(.2,1,.8,1)
        frame.drag:SetAlpha(.25)
      end

      frame.drag:SetScript("OnMouseDown",function()
          frame:StartMoving()
        end)

      frame.drag:SetScript("OnMouseUp",function()
          frame:StopMovingOrSizing()
          _, _, _, xpos, ypos = frame:GetPoint()

          if not pfUI_config.position[frame:GetName()] then
            pfUI_config.position[frame:GetName()] = {}
          end

          pfUI_config.position[frame:GetName()]["xpos"] = xpos
          pfUI_config.position[frame:GetName()]["ypos"] = ypos
        end)

      if pfUI.gitter:IsShown() then
        frame:SetMovable(true)
        frame.drag:EnableMouse(true)
        frame.drag:Show()
        frame:Show()
        pfUI.gui.unlockFrames.text:SetText("Lock Frames")
      else
        frame:SetMovable(false)
        frame.drag:EnableMouse(false)
        frame.drag:Hide()
        if frame.hideLater == true then
          frame:Hide()
        end
        pfUI.gui.unlockFrames.text:SetText("Unlock Frames")
      end
    end
  end

  -- Global Settings
  pfUI.gui.global = CreateFrame("Frame", nil, pfUI.gui)
  pfUI.gui.global:SetWidth(400)
  pfUI.gui.global:SetHeight(420)

  pfUI.gui.global:SetBackdrop(pfUI.backdrop)
  pfUI.gui.global:SetBackdropColor(0,0,0,.50);
  pfUI.gui.global:SetPoint("RIGHT",0,0)

  pfUI.gui.global.switch = CreateFrame("Button", nil, pfUI.gui)
  pfUI.gui.global.switch:ClearAllPoints()
  pfUI.gui.global.switch:SetWidth(80)
  pfUI.gui.global.switch:SetHeight(20)
  pfUI.gui.global.switch:SetPoint("TOPLEFT", 0, 0)
  pfUI.gui.global.switch:SetBackdrop(pfUI.backdrop)
  pfUI.gui.global.switch.text = pfUI.gui.global.switch:CreateFontString("Status", "LOW", "GameFontNormal")
  pfUI.gui.global.switch.text:SetFont("Interface\\AddOns\\pfUI\\fonts\\arial.ttf", pfUI_config.global.font_size, "OUTLINE")
  pfUI.gui.global.switch.text:ClearAllPoints()
  pfUI.gui.global.switch.text:SetAllPoints(pfUI.gui.global.switch)
  pfUI.gui.global.switch.text:SetPoint("CENTER", 0, 0)
  pfUI.gui.global.switch.text:SetFontObject(GameFontWhite)
  pfUI.gui.global.switch.text:SetText("Global")
  pfUI.gui.global.switch:SetScript("OnClick", function()
      pfUI.gui.SwitchTab(pfUI.gui.global)
    end)

  pfUI.gui.global.title = pfUI.gui.global:CreateFontString("Status", "LOW", "GameFontNormal")
  pfUI.gui.global.title:SetFont("Interface\\AddOns\\pfUI\\fonts\\arial.ttf", pfUI_config.global.font_size + 2, "OUTLINE")
  pfUI.gui.global.title:SetPoint("TOP", 0, -10)
  pfUI.gui.global.title:SetFontObject(GameFontWhite)
  pfUI.gui.global.title:SetText("Global Settings")

  -- UnitFrame settings
  pfUI.gui.uf = CreateFrame("Frame", nil, pfUI.gui)
  pfUI.gui.uf:SetWidth(400)
  pfUI.gui.uf:SetHeight(420)

  pfUI.gui.uf:SetBackdrop(pfUI.backdrop)
  pfUI.gui.uf:SetBackdropColor(0,0,0,.50);
  pfUI.gui.uf:SetPoint("RIGHT",0,0)

  pfUI.gui.uf.switch = CreateFrame("Button", nil, pfUI.gui)
  pfUI.gui.uf.switch:ClearAllPoints()
  pfUI.gui.uf.switch:SetWidth(80)
  pfUI.gui.uf.switch:SetHeight(20)
  pfUI.gui.uf.switch:SetPoint("TOPLEFT", 0, -20)
  pfUI.gui.uf.switch:SetBackdrop(pfUI.backdrop)
  pfUI.gui.uf.switch.text = pfUI.gui.uf.switch:CreateFontString("Status", "LOW", "GameFontNormal")
  pfUI.gui.uf.switch.text:SetFont("Interface\\AddOns\\pfUI\\fonts\\arial.ttf", pfUI_config.global.font_size, "OUTLINE")
  pfUI.gui.uf.switch.text:ClearAllPoints()
  pfUI.gui.uf.switch.text:SetAllPoints(pfUI.gui.uf.switch)
  pfUI.gui.uf.switch.text:SetPoint("CENTER", 0, 0)
  pfUI.gui.uf.switch.text:SetFontObject(GameFontWhite)
  pfUI.gui.uf.switch.text:SetText("UnitFrames")
  pfUI.gui.uf.switch:SetScript("OnClick", function()
      pfUI.gui.SwitchTab(pfUI.gui.uf)
    end)

  pfUI.gui.uf.title = pfUI.gui.uf:CreateFontString("Status", "LOW", "GameFontNormal")
  pfUI.gui.uf.title:SetFont("Interface\\AddOns\\pfUI\\fonts\\arial.ttf", pfUI_config.global.font_size + 2, "OUTLINE")
  pfUI.gui.uf.title:SetPoint("TOP", 0, -10)
  pfUI.gui.uf.title:SetFontObject(GameFontWhite)
  pfUI.gui.uf.title:SetText("UnitFrame Settings")

  -- ActionBar settings
  pfUI.gui.bar = CreateFrame("Frame", nil, pfUI.gui)
  pfUI.gui.bar:SetWidth(400)
  pfUI.gui.bar:SetHeight(420)

  pfUI.gui.bar:SetBackdrop(pfUI.backdrop)
  pfUI.gui.bar:SetBackdropColor(0,0,0,.50);
  pfUI.gui.bar:SetPoint("RIGHT",0,0)

  pfUI.gui.bar.switch = CreateFrame("Button", nil, pfUI.gui)
  pfUI.gui.bar.switch:ClearAllPoints()
  pfUI.gui.bar.switch:SetWidth(80)
  pfUI.gui.bar.switch:SetHeight(20)
  pfUI.gui.bar.switch:SetPoint("TOPLEFT", 0, -40)
  pfUI.gui.bar.switch:SetBackdrop(pfUI.backdrop)
  pfUI.gui.bar.switch.text = pfUI.gui.bar.switch:CreateFontString("Status", "LOW", "GameFontNormal")
  pfUI.gui.bar.switch.text:SetFont("Interface\\AddOns\\pfUI\\fonts\\arial.ttf", pfUI_config.global.font_size, "OUTLINE")
  pfUI.gui.bar.switch.text:ClearAllPoints()
  pfUI.gui.bar.switch.text:SetAllPoints(pfUI.gui.bar.switch)
  pfUI.gui.bar.switch.text:SetPoint("CENTER", 0, 0)
  pfUI.gui.bar.switch.text:SetFontObject(GameFontWhite)
  pfUI.gui.bar.switch.text:SetText("ActionBars")
  pfUI.gui.bar.switch:SetScript("OnClick", function()
      pfUI.gui.SwitchTab(pfUI.gui.bar)
    end)

  pfUI.gui.bar.title = pfUI.gui.bar:CreateFontString("Status", "LOW", "GameFontNormal")
  pfUI.gui.bar.title:SetFont("Interface\\AddOns\\pfUI\\fonts\\arial.ttf", pfUI_config.global.font_size + 2, "OUTLINE")
  pfUI.gui.bar.title:SetPoint("TOP", 0, -10)
  pfUI.gui.bar.title:SetFontObject(GameFontWhite)
  pfUI.gui.bar.title:SetText("ActionBar Settings")

  -- Panel settings
  pfUI.gui.panel = CreateFrame("Frame", nil, pfUI.gui)
  pfUI.gui.panel:SetWidth(400)
  pfUI.gui.panel:SetHeight(420)

  pfUI.gui.panel:SetBackdrop(pfUI.backdrop)
  pfUI.gui.panel:SetBackdropColor(0,0,0,.50);
  pfUI.gui.panel:SetPoint("RIGHT",0,0)

  pfUI.gui.panel.switch = CreateFrame("Button", nil, pfUI.gui)
  pfUI.gui.panel.switch:ClearAllPoints()
  pfUI.gui.panel.switch:SetWidth(80)
  pfUI.gui.panel.switch:SetHeight(20)
  pfUI.gui.panel.switch:SetPoint("TOPLEFT", 0, -60)
  pfUI.gui.panel.switch:SetBackdrop(pfUI.backdrop)
  pfUI.gui.panel.switch.text = pfUI.gui.panel.switch:CreateFontString("Status", "LOW", "GameFontNormal")
  pfUI.gui.panel.switch.text:SetFont("Interface\\AddOns\\pfUI\\fonts\\arial.ttf", pfUI_config.global.font_size, "OUTLINE")
  pfUI.gui.panel.switch.text:ClearAllPoints()
  pfUI.gui.panel.switch.text:SetAllPoints(pfUI.gui.panel.switch)
  pfUI.gui.panel.switch.text:SetPoint("CENTER", 0, 0)
  pfUI.gui.panel.switch.text:SetFontObject(GameFontWhite)
  pfUI.gui.panel.switch.text:SetText("Panels")
  pfUI.gui.panel.switch:SetScript("OnClick", function()
      pfUI.gui.SwitchTab(pfUI.gui.panel)
    end)

  pfUI.gui.panel.title = pfUI.gui.panel:CreateFontString("Status", "LOW", "GameFontNormal")
  pfUI.gui.panel.title:SetFont("Interface\\AddOns\\pfUI\\fonts\\arial.ttf", pfUI_config.global.font_size + 2, "OUTLINE")
  pfUI.gui.panel.title:SetPoint("TOP", 0, -10)
  pfUI.gui.panel.title:SetFontObject(GameFontWhite)
  pfUI.gui.panel.title:SetText("Panel Settings")

  -- Tooltip settings
  pfUI.gui.tooltip = CreateFrame("Frame", nil, pfUI.gui)
  pfUI.gui.tooltip:SetWidth(400)
  pfUI.gui.tooltip:SetHeight(420)

  pfUI.gui.tooltip:SetBackdrop(pfUI.backdrop)
  pfUI.gui.tooltip:SetBackdropColor(0,0,0,.50);
  pfUI.gui.tooltip:SetPoint("RIGHT",0,0)

  pfUI.gui.tooltip.switch = CreateFrame("Button", nil, pfUI.gui)
  pfUI.gui.tooltip.switch:ClearAllPoints()
  pfUI.gui.tooltip.switch:SetWidth(80)
  pfUI.gui.tooltip.switch:SetHeight(20)
  pfUI.gui.tooltip.switch:SetPoint("TOPLEFT", 0, -80)
  pfUI.gui.tooltip.switch:SetBackdrop(pfUI.backdrop)
  pfUI.gui.tooltip.switch.text = pfUI.gui.tooltip.switch:CreateFontString("Status", "LOW", "GameFontNormal")
  pfUI.gui.tooltip.switch.text:SetFont("Interface\\AddOns\\pfUI\\fonts\\arial.ttf", pfUI_config.global.font_size, "OUTLINE")
  pfUI.gui.tooltip.switch.text:ClearAllPoints()
  pfUI.gui.tooltip.switch.text:SetAllPoints(pfUI.gui.tooltip.switch)
  pfUI.gui.tooltip.switch.text:SetPoint("CENTER", 0, 0)
  pfUI.gui.tooltip.switch.text:SetFontObject(GameFontWhite)
  pfUI.gui.tooltip.switch.text:SetText("Tooltips")
  pfUI.gui.tooltip.switch:SetScript("OnClick", function()
      pfUI.gui.SwitchTab(pfUI.gui.tooltip)
    end)

  pfUI.gui.tooltip.title = pfUI.gui.tooltip:CreateFontString("Status", "LOW", "GameFontNormal")
  pfUI.gui.tooltip.title:SetFont("Interface\\AddOns\\pfUI\\fonts\\arial.ttf", pfUI_config.global.font_size + 2, "OUTLINE")
  pfUI.gui.tooltip.title:SetPoint("TOP", 0, -10)
  pfUI.gui.tooltip.title:SetFontObject(GameFontWhite)
  pfUI.gui.tooltip.title:SetText("Tooltip Settings")

  -- Castbar settings
  pfUI.gui.castbar = CreateFrame("Frame", nil, pfUI.gui)
  pfUI.gui.castbar:SetWidth(400)
  pfUI.gui.castbar:SetHeight(420)

  pfUI.gui.castbar:SetBackdrop(pfUI.backdrop)
  pfUI.gui.castbar:SetBackdropColor(0,0,0,.50);
  pfUI.gui.castbar:SetPoint("RIGHT",0,0)

  pfUI.gui.castbar.switch = CreateFrame("Button", nil, pfUI.gui)
  pfUI.gui.castbar.switch:ClearAllPoints()
  pfUI.gui.castbar.switch:SetWidth(80)
  pfUI.gui.castbar.switch:SetHeight(20)
  pfUI.gui.castbar.switch:SetPoint("TOPLEFT", 0, -100)
  pfUI.gui.castbar.switch:SetBackdrop(pfUI.backdrop)
  pfUI.gui.castbar.switch.text = pfUI.gui.castbar.switch:CreateFontString("Status", "LOW", "GameFontNormal")
  pfUI.gui.castbar.switch.text:SetFont("Interface\\AddOns\\pfUI\\fonts\\arial.ttf", pfUI_config.global.font_size, "OUTLINE")
  pfUI.gui.castbar.switch.text:ClearAllPoints()
  pfUI.gui.castbar.switch.text:SetAllPoints(pfUI.gui.castbar.switch)
  pfUI.gui.castbar.switch.text:SetPoint("CENTER", 0, 0)
  pfUI.gui.castbar.switch.text:SetFontObject(GameFontWhite)
  pfUI.gui.castbar.switch.text:SetText("Castbar")
  pfUI.gui.castbar.switch:SetScript("OnClick", function()
      pfUI.gui.SwitchTab(pfUI.gui.castbar)
    end)

  pfUI.gui.castbar.title = pfUI.gui.castbar:CreateFontString("Status", "LOW", "GameFontNormal")
  pfUI.gui.castbar.title:SetFont("Interface\\AddOns\\pfUI\\fonts\\arial.ttf", pfUI_config.global.font_size + 2, "OUTLINE")
  pfUI.gui.castbar.title:SetPoint("TOP", 0, -10)
  pfUI.gui.castbar.title:SetFontObject(GameFontWhite)
  pfUI.gui.castbar.title:SetText("Castbar Settings")

    -- chat settings
  pfUI.gui.chat = CreateFrame("Frame", nil, pfUI.gui)
  pfUI.gui.chat:SetWidth(400)
  pfUI.gui.chat:SetHeight(420)

  pfUI.gui.chat:SetBackdrop(pfUI.backdrop)
  pfUI.gui.chat:SetBackdropColor(0,0,0,.50);
  pfUI.gui.chat:SetPoint("RIGHT",0,0)

  pfUI.gui.chat.switch = CreateFrame("Button", nil, pfUI.gui)
  pfUI.gui.chat.switch:ClearAllPoints()
  pfUI.gui.chat.switch:SetWidth(80)
  pfUI.gui.chat.switch:SetHeight(20)
  pfUI.gui.chat.switch:SetPoint("TOPLEFT", 0, -120)
  pfUI.gui.chat.switch:SetBackdrop(pfUI.backdrop)
  pfUI.gui.chat.switch.text = pfUI.gui.chat.switch:CreateFontString("Status", "LOW", "GameFontNormal")
  pfUI.gui.chat.switch.text:SetFont("Interface\\AddOns\\pfUI\\fonts\\arial.ttf", pfUI_config.global.font_size, "OUTLINE")
  pfUI.gui.chat.switch.text:ClearAllPoints()
  pfUI.gui.chat.switch.text:SetAllPoints(pfUI.gui.chat.switch)
  pfUI.gui.chat.switch.text:SetPoint("CENTER", 0, 0)
  pfUI.gui.chat.switch.text:SetFontObject(GameFontWhite)
  pfUI.gui.chat.switch.text:SetText("Chat")
  pfUI.gui.chat.switch:SetScript("OnClick", function()
      pfUI.gui.SwitchTab(pfUI.gui.chat)
    end)

  pfUI.gui.chat.title = pfUI.gui.chat:CreateFontString("Status", "LOW", "GameFontNormal")
  pfUI.gui.chat.title:SetFont("Interface\\AddOns\\pfUI\\fonts\\arial.ttf", pfUI_config.global.font_size + 2, "OUTLINE")
  pfUI.gui.chat.title:SetPoint("TOP", 0, -10)
  pfUI.gui.chat.title:SetFontObject(GameFontWhite)
  pfUI.gui.chat.title:SetText("Chat")

  -- nameplate settings
  pfUI.gui.nameplates = CreateFrame("Frame", nil, pfUI.gui)
  pfUI.gui.nameplates:SetWidth(400)
  pfUI.gui.nameplates:SetHeight(420)

  pfUI.gui.nameplates:SetBackdrop(pfUI.backdrop)
  pfUI.gui.nameplates:SetBackdropColor(0,0,0,.50);
  pfUI.gui.nameplates:SetPoint("RIGHT",0,0)

  pfUI.gui.nameplates.switch = CreateFrame("Button", nil, pfUI.gui)
  pfUI.gui.nameplates.switch:ClearAllPoints()
  pfUI.gui.nameplates.switch:SetWidth(80)
  pfUI.gui.nameplates.switch:SetHeight(20)
  pfUI.gui.nameplates.switch:SetPoint("TOPLEFT", 0, -140)
  pfUI.gui.nameplates.switch:SetBackdrop(pfUI.backdrop)
  pfUI.gui.nameplates.switch.text = pfUI.gui.nameplates.switch:CreateFontString("Status", "LOW", "GameFontNormal")
  pfUI.gui.nameplates.switch.text:SetFont("Interface\\AddOns\\pfUI\\fonts\\arial.ttf", pfUI_config.global.font_size, "OUTLINE")
  pfUI.gui.nameplates.switch.text:ClearAllPoints()
  pfUI.gui.nameplates.switch.text:SetAllPoints(pfUI.gui.nameplates.switch)
  pfUI.gui.nameplates.switch.text:SetPoint("CENTER", 0, 0)
  pfUI.gui.nameplates.switch.text:SetFontObject(GameFontWhite)
  pfUI.gui.nameplates.switch.text:SetText("Nameplates")
  pfUI.gui.nameplates.switch:SetScript("OnClick", function()
      pfUI.gui.SwitchTab(pfUI.gui.nameplates)
    end)

  pfUI.gui.nameplates.title = pfUI.gui.nameplates:CreateFontString("Status", "LOW", "GameFontNormal")
  pfUI.gui.nameplates.title:SetFont("Interface\\AddOns\\pfUI\\fonts\\arial.ttf", pfUI_config.global.font_size + 2, "OUTLINE")
  pfUI.gui.nameplates.title:SetPoint("TOP", 0, -10)
  pfUI.gui.nameplates.title:SetFontObject(GameFontWhite)
  pfUI.gui.nameplates.title:SetText("Nameplates")

  -- Thirdparty settings
  pfUI.gui.thirdparty = CreateFrame("Frame", nil, pfUI.gui)
  pfUI.gui.thirdparty:SetWidth(400)
  pfUI.gui.thirdparty:SetHeight(420)

  pfUI.gui.thirdparty:SetBackdrop(pfUI.backdrop)
  pfUI.gui.thirdparty:SetBackdropColor(0,0,0,.50);
  pfUI.gui.thirdparty:SetPoint("RIGHT",0,0)

  pfUI.gui.thirdparty.switch = CreateFrame("Button", nil, pfUI.gui)
  pfUI.gui.thirdparty.switch:ClearAllPoints()
  pfUI.gui.thirdparty.switch:SetWidth(80)
  pfUI.gui.thirdparty.switch:SetHeight(20)
  pfUI.gui.thirdparty.switch:SetPoint("TOPLEFT", 0, -160)
  pfUI.gui.thirdparty.switch:SetBackdrop(pfUI.backdrop)
  pfUI.gui.thirdparty.switch.text = pfUI.gui.thirdparty.switch:CreateFontString("Status", "LOW", "GameFontNormal")
  pfUI.gui.thirdparty.switch.text:SetFont("Interface\\AddOns\\pfUI\\fonts\\arial.ttf", pfUI_config.global.font_size, "OUTLINE")
  pfUI.gui.thirdparty.switch.text:ClearAllPoints()
  pfUI.gui.thirdparty.switch.text:SetAllPoints(pfUI.gui.thirdparty.switch)
  pfUI.gui.thirdparty.switch.text:SetPoint("CENTER", 0, 0)
  pfUI.gui.thirdparty.switch.text:SetFontObject(GameFontWhite)
  pfUI.gui.thirdparty.switch.text:SetText("Thirdparty")
  pfUI.gui.thirdparty.switch:SetScript("OnClick", function()
      pfUI.gui.SwitchTab(pfUI.gui.thirdparty)
    end)

  pfUI.gui.thirdparty.title = pfUI.gui.thirdparty:CreateFontString("Status", "LOW", "GameFontNormal")
  pfUI.gui.thirdparty.title:SetFont("Interface\\AddOns\\pfUI\\fonts\\arial.ttf", pfUI_config.global.font_size + 2, "OUTLINE")
  pfUI.gui.thirdparty.title:SetPoint("TOP", 0, -10)
  pfUI.gui.thirdparty.title:SetFontObject(GameFontWhite)
  pfUI.gui.thirdparty.title:SetText("Thirdparty Addons")

  -- Reset All
  pfUI.gui.resetAll = CreateFrame("Button", nil, pfUI.gui)
  pfUI.gui.resetAll:ClearAllPoints()
  pfUI.gui.resetAll:SetWidth(80)
  pfUI.gui.resetAll:SetHeight(20)
  pfUI.gui.resetAll:SetPoint("BOTTOMLEFT", 0, 80)
  pfUI.gui.resetAll:SetBackdrop(pfUI.backdrop)
  pfUI.gui.resetAll.text = pfUI.gui.resetAll:CreateFontString("Status", "LOW", "GameFontNormal")
  pfUI.gui.resetAll.text:SetFont("Interface\\AddOns\\pfUI\\fonts\\arial.ttf", pfUI_config.global.font_size, "OUTLINE")
  pfUI.gui.resetAll.text:ClearAllPoints()
  pfUI.gui.resetAll.text:SetAllPoints(pfUI.gui.resetAll)
  pfUI.gui.resetAll.text:SetPoint("CENTER", 0, 0)
  pfUI.gui.resetAll.text:SetFontObject(GameFontWhite)
  pfUI.gui.resetAll.text:SetText("Reset All")
  pfUI.gui.resetAll:SetScript("OnClick", function()
      pfUI_init = {}
      pfUI_config = {}
      pfUI:LoadConfig()
      pfUI.gui.reloadDialog:Show()
    end)

  -- Reset Chat
  pfUI.gui.resetChat = CreateFrame("Button", nil, pfUI.gui)
  pfUI.gui.resetChat:ClearAllPoints()
  pfUI.gui.resetChat:SetWidth(80)
  pfUI.gui.resetChat:SetHeight(20)
  pfUI.gui.resetChat:SetPoint("BOTTOMLEFT", 0, 60)
  pfUI.gui.resetChat:SetBackdrop(pfUI.backdrop)
  pfUI.gui.resetChat.text = pfUI.gui.resetChat:CreateFontString("Status", "LOW", "GameFontNormal")
  pfUI.gui.resetChat.text:SetFont("Interface\\AddOns\\pfUI\\fonts\\arial.ttf", pfUI_config.global.font_size, "OUTLINE")
  pfUI.gui.resetChat.text:ClearAllPoints()
  pfUI.gui.resetChat.text:SetAllPoints(pfUI.gui.resetChat)
  pfUI.gui.resetChat.text:SetPoint("CENTER", 0, 0)
  pfUI.gui.resetChat.text:SetFontObject(GameFontWhite)
  pfUI.gui.resetChat.text:SetText("Reset Chat")
  pfUI.gui.resetChat:SetScript("OnClick", function()
      pfUI_init["chat"] = nil
      pfUI.gui.reloadDialog:Show()
    end)

  -- Reset Frames
  pfUI.gui.resetFrames = CreateFrame("Button", nil, pfUI.gui)
  pfUI.gui.resetFrames:ClearAllPoints()
  pfUI.gui.resetFrames:SetWidth(80)
  pfUI.gui.resetFrames:SetHeight(20)
  pfUI.gui.resetFrames:SetPoint("BOTTOMLEFT", 0, 40)
  pfUI.gui.resetFrames:SetBackdrop(pfUI.backdrop)
  pfUI.gui.resetFrames.text = pfUI.gui.resetFrames:CreateFontString("Status", "LOW", "GameFontNormal")
  pfUI.gui.resetFrames.text:SetFont("Interface\\AddOns\\pfUI\\fonts\\arial.ttf", pfUI_config.global.font_size, "OUTLINE")
  pfUI.gui.resetFrames.text:ClearAllPoints()
  pfUI.gui.resetFrames.text:SetAllPoints(pfUI.gui.resetFrames)
  pfUI.gui.resetFrames.text:SetPoint("CENTER", 0, 0)
  pfUI.gui.resetFrames.text:SetFontObject(GameFontWhite)
  pfUI.gui.resetFrames.text:SetText("Reset Positions")
  pfUI.gui.resetFrames:SetScript("OnClick", function()
      pfUI_config["position"] = {}
      pfUI.gui.reloadDialog:Show()
    end)

  -- Unlock Frames
  pfUI.gui.unlockFrames = CreateFrame("Button", nil, pfUI.gui)
  pfUI.gui.unlockFrames:ClearAllPoints()
  pfUI.gui.unlockFrames:SetWidth(80)
  pfUI.gui.unlockFrames:SetHeight(20)
  pfUI.gui.unlockFrames:SetPoint("BOTTOMLEFT", 0, 20)
  pfUI.gui.unlockFrames:SetBackdrop(pfUI.backdrop)
  pfUI.gui.unlockFrames.text = pfUI.gui.unlockFrames:CreateFontString("Status", "LOW", "GameFontNormal")
  pfUI.gui.unlockFrames.text:SetFont("Interface\\AddOns\\pfUI\\fonts\\arial.ttf", pfUI_config.global.font_size, "OUTLINE")
  pfUI.gui.unlockFrames.text:ClearAllPoints()
  pfUI.gui.unlockFrames.text:SetAllPoints(pfUI.gui.unlockFrames)
  pfUI.gui.unlockFrames.text:SetPoint("CENTER", 0, 0)
  pfUI.gui.unlockFrames.text:SetFontObject(GameFontWhite)
  pfUI.gui.unlockFrames.text:SetText("Unlock Frames")
  pfUI.gui.unlockFrames:SetScript("OnClick", function()
      pfUI.gui.UnlockFrames()
    end)

  -- Hide GUI
  pfUI.gui.hideGUI = CreateFrame("Button", nil, pfUI.gui)
  pfUI.gui.hideGUI:ClearAllPoints()
  pfUI.gui.hideGUI:SetWidth(80)
  pfUI.gui.hideGUI:SetHeight(20)
  pfUI.gui.hideGUI:SetPoint("BOTTOMLEFT", 0, 0)
  pfUI.gui.hideGUI:SetBackdrop(pfUI.backdrop)
  pfUI.gui.hideGUI.text = pfUI.gui.hideGUI:CreateFontString("Status", "LOW", "GameFontNormal")
  pfUI.gui.hideGUI.text:SetFont("Interface\\AddOns\\pfUI\\fonts\\arial.ttf", pfUI_config.global.font_size, "OUTLINE")
  pfUI.gui.hideGUI.text:ClearAllPoints()
  pfUI.gui.hideGUI.text:SetAllPoints(pfUI.gui.hideGUI)
  pfUI.gui.hideGUI.text:SetPoint("CENTER", 0, 0)
  pfUI.gui.hideGUI.text:SetFontObject(GameFontWhite)
  pfUI.gui.hideGUI.text:SetText("Close")
  pfUI.gui.hideGUI:SetScript("OnClick", function()
    if pfUI.gui.settingChanged then
      pfUI.gui.reloadDialog:Show()
    end
    if pfUI.gitter and pfUI.gitter:IsShown() then pfUI.gui:UnlockFrames() end
    pfUI.gui:Hide()
  end)

  -- Switch to default View: global
  pfUI.gui.SwitchTab(pfUI.gui.global)


  pfUI.gui.reloadDialog = CreateFrame("Frame","pfReloadDiag",UIParent)
  pfUI.gui.reloadDialog:SetFrameStrata("TOOLTIP")
  pfUI.gui.reloadDialog:SetWidth(300)
  pfUI.gui.reloadDialog:SetHeight(100)
  pfUI.gui.reloadDialog:Hide()
  tinsert(UISpecialFrames, "pfReloadDiag")

  pfUI.gui.reloadDialog:SetBackdrop(pfUI.backdrop)
  pfUI.gui.reloadDialog:SetPoint("CENTER",0,0)

  pfUI.gui.reloadDialog.text = pfUI.gui.reloadDialog:CreateFontString("Status", "LOW", "GameFontNormal")
  pfUI.gui.reloadDialog.text:SetFontObject(GameFontWhite)
  pfUI.gui.reloadDialog.text:SetPoint("TOP", 0, -15)
  pfUI.gui.reloadDialog.text:SetText("Some settings need to reload the UI to take effect.\nDo you want to reloadUI now?")

  pfUI.gui.reloadDialog.yes = CreateFrame("Button", "pfReloadYes", pfUI.gui.reloadDialog, "UIPanelButtonTemplate")
  pfUI.gui.reloadDialog.yes:SetBackdrop(pfUI.backdrop)
  pfUI.gui.reloadDialog.yes:SetWidth(100)
  pfUI.gui.reloadDialog.yes:SetHeight(20) -- width, height
  pfUI.gui.reloadDialog.yes:SetPoint("BOTTOMLEFT", 20,15)
  pfUI.gui.reloadDialog.yes:SetText("Yes")
  pfUI.gui.reloadDialog.yes:SetScript("OnClick", function()
      pfUI.gui.settingChanged = nil
      ReloadUI();
    end)
  pfUI.gui.reloadDialog.no = CreateFrame("Button", "pfReloadNo", pfUI.gui.reloadDialog, "UIPanelButtonTemplate")
  pfUI.gui.reloadDialog.no:SetWidth(100)
  pfUI.gui.reloadDialog.no:SetHeight(20) -- width, height
  pfUI.gui.reloadDialog.no:SetPoint("BOTTOMRIGHT", -20,15)
  pfUI.gui.reloadDialog.no:SetText("No")
  pfUI.gui.reloadDialog.no:SetScript("OnClick", function()
      pfUI.gui.reloadDialog:Hide()
    end)

  -- global
  pfUI.gui.CreateConfig(pfUI.gui.global, "Fontsize", pfUI_config.global, "font_size")

  -- unitframes
  pfUI.gui.CreateConfig(pfUI.gui.uf, "Animation speed", pfUI_config.unitframes, "animation_speed")
  pfUI.gui.CreateConfig(pfUI.gui.uf, "Show portrait", pfUI_config.unitframes, "portrait")
  pfUI.gui.CreateConfig(pfUI.gui.uf, "Buff size", pfUI_config.unitframes, "buff_size")
  pfUI.gui.CreateConfig(pfUI.gui.uf, "Debuff size", pfUI_config.unitframes, "debuff_size")
  pfUI.gui.CreateConfig(pfUI.gui.uf, "Layout", pfUI_config.unitframes, "layout")
  pfUI.gui.CreateConfig(pfUI.gui.uf, "Player width", pfUI_config.unitframes.player, "width")
  pfUI.gui.CreateConfig(pfUI.gui.uf, "Player height", pfUI_config.unitframes.player, "height")
  pfUI.gui.CreateConfig(pfUI.gui.uf, "Player powerbar height", pfUI_config.unitframes.player, "pheight")
  pfUI.gui.CreateConfig(pfUI.gui.uf, "Target width", pfUI_config.unitframes.target, "width")
  pfUI.gui.CreateConfig(pfUI.gui.uf, "Target height", pfUI_config.unitframes.target, "height")
  pfUI.gui.CreateConfig(pfUI.gui.uf, "Target powerbar height", pfUI_config.unitframes.target, "pheight")
  pfUI.gui.CreateConfig(pfUI.gui.uf, "Click-cast on Raidframe", pfUI_config.unitframes.raid, "clickcast")
  pfUI.gui.CreateConfig(pfUI.gui.uf, "Click-cast on Raidframe (Shift)", pfUI_config.unitframes.raid, "clickcast_shift")
  pfUI.gui.CreateConfig(pfUI.gui.uf, "Click-cast on Raidframe (Alt)", pfUI_config.unitframes.raid, "clickcast_alt")
  pfUI.gui.CreateConfig(pfUI.gui.uf, "Click-cast on Raidframe (Ctrl)", pfUI_config.unitframes.raid, "clickcast_ctrl")

  -- actionbar
  pfUI.gui.CreateConfig(pfUI.gui.bar, "Icon Size", pfUI_config.bars, "icon_size")
  pfUI.gui.CreateConfig(pfUI.gui.bar, "Border", pfUI_config.bars, "border")

  -- panels
  pfUI.gui.CreateConfig(pfUI.gui.panel, "Left Panel: Left", pfUI_config.panel.left, "left")
  pfUI.gui.CreateConfig(pfUI.gui.panel, "Left Panel: Center", pfUI_config.panel.left, "center")
  pfUI.gui.CreateConfig(pfUI.gui.panel, "Left Panel: Right", pfUI_config.panel.left, "right")
  pfUI.gui.CreateConfig(pfUI.gui.panel, "Right Panel: Left", pfUI_config.panel.right, "left")
  pfUI.gui.CreateConfig(pfUI.gui.panel, "Right Panel: Center", pfUI_config.panel.right, "center")
  pfUI.gui.CreateConfig(pfUI.gui.panel, "Right Panel: Right", pfUI_config.panel.right, "right")
  pfUI.gui.CreateConfig(pfUI.gui.panel, "Other Panel: Minimap", pfUI_config.panel.other, "minimap")
  pfUI.gui.CreateConfig(pfUI.gui.panel, "Always show XP and Reputation Bar", pfUI_config.panel.xp, "showalways")

  -- tooltip
  pfUI.gui.CreateConfig(pfUI.gui.tooltip, "Tooltip Position:", pfUI_config.tooltip, "position")

  -- castbar
  pfUI.gui.CreateConfig(pfUI.gui.castbar, "Hide blizzards castbar:", pfUI_config.castbar.player, "hide_blizz")

  -- chat
  pfUI.gui.CreateConfig(pfUI.gui.chat, "Timestamp in chat:", pfUI_config.chat.text, "time")
  pfUI.gui.CreateConfig(pfUI.gui.chat, "Timestamp format:", pfUI_config.chat.text, "timeformat")
  pfUI.gui.CreateConfig(pfUI.gui.chat, "Timestamp brackets:", pfUI_config.chat.text, "timebracket")
  pfUI.gui.CreateConfig(pfUI.gui.chat, "Timestamp color:", pfUI_config.chat.text, "timecolor")

  -- nameplates
  pfUI.gui.CreateConfig(pfUI.gui.nameplates, "Show castbars:", pfUI_config.nameplates, "showcastbar")
  pfUI.gui.CreateConfig(pfUI.gui.nameplates, "Show debuffs:", pfUI_config.nameplates, "showdebuffs")
  pfUI.gui.CreateConfig(pfUI.gui.nameplates, "Enable Clickthrough:", pfUI_config.nameplates, "clickthrough")

  -- thirdparty
  pfUI.gui.CreateConfig(pfUI.gui.thirdparty, "DPSMate:", pfUI_config.thirdparty.dpsmate, "enable")
  pfUI.gui.CreateConfig(pfUI.gui.thirdparty, "WIM:", pfUI_config.thirdparty.wim, "enable")

end)
