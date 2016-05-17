local fusedAddon = LibStub("AceAddon-3.0"):NewAddon("fusedAddon","AceConsole-3.0", "AceEvent-3.0", "AceComm-3.0", "AceSerializer-3.0", "AceHook-3.0", "AceTimer-3.0");

local mainFrame;
local itemsWindow;
local responseWindow;
local childFrame;
local popupFrame;
local popupItems = {};

--Core stuff
local itemBank;
local addonPrefix = "FCPREFIX";
local options;
local currentItem;

local dbProfile;
local dbDefaults = {

    profile = {
      options = {
        numOfResponseButtons = 7,
        responseButtonNames = {"Bis", "Major","Minor", "Reroll", "OffSpec", "Transmog", "Pass"},
        lootCouncilMembers = {UnitName("player")},
      },
      initializeFromDB = false,
    },

};



function fusedAddon:OnInitialize()
  mainFrame = CreateFrame("Frame", nil, UIParent, "FC_MainFrame");
  popupFrame = CreateFrame("Frame", nil, UIParent, "FC_MainLootFrame");
  itemsWindow = CreateFrame("Frame", nil, getglobal("FC_ItemsWindow"));
  getglobal("FC_ItemsWindow"):SetScrollChild(itemsWindow);
  responseWindow = getglobal("FC_responseWindow");
  childFrame = CreateFrame("Frame",nil, responseWindow);
  childFrame:SetSize(800,800);
  responseWindow:SetScrollChild(childFrame);

  itemBank ={};

  self.db = LibStub("AceDB-3.0"):New("FusedAddonDB",dbDefaults, true);
  self.db:RegisterDefaults(dbDefaults);
  dbProfile = self.db.profile;

  local popup = CreateFrame("Frame", "FC_Popup1", popupFrame, "FC_ResponseFrame");
  popup:SetPoint("Topleft");
  popup.buttons = {};
  for i=1, 7 do
    local button = CreateFrame("Button", nil, popup, "UIPanelButtonTemplate");
    button:Hide();
    button:SetPoint("bottomleft", 70 + (95 * (i-1)), 35);
    button:SetSize(80,25);
    table.insert(popup.buttons, button);
  end

  for i=2, 5 do
    popup = CreateFrame("Frame", "FC_Popup" .. i, popupFrame, "FC_ResponseFrame");
    popup:SetPoint("Top","FC_Popup" .. (i-1), "Bottom");
    popup.buttons = {};
    for k=1, 7 do
      local button = CreateFrame("Button", nil, popup, "UIPanelButtonTemplate");
      button:Hide();
      button:SetPoint("bottomleft", 70 + (95 * (k-1)), 35);
      button:SetSize(80,25);
      table.insert(popup.buttons, button);
    end
  end

  getglobal("FC_currentItemFrame"):SetScript("OnEnter", function()
    GameTooltip:SetOwner(getglobal("FC_currentItemFrame"), "ANCHOR_RIGHT")
    if currentItem then
      GameTooltip:SetHyperlink(currentItem["itemLink"]);
      GameTooltip:Show()
    end

  end);
  getglobal("FC_currentItemFrame"):SetScript("OnLeave", function()
    GameTooltip:Hide()
  end);

  local frame = CreateFrame("Frame", "FC_windowFrame1", itemsWindow, "FC_ItemFrame");
  frame:SetPoint("TopLeft",10,-10);
  frame:Hide();

  for i=2, 10 do
    local frame = CreateFrame("Frame", "FC_windowFrame"..i, itemsWindow, "FC_ItemFrame");
    frame:SetPoint("Top","FC_windowFrame" .. (i-1), "Bottom");
    frame:Hide();
  end

  local frame = CreateFrame("Frame", "FC_entry1",childFrame, "FC_ResponseEntry");
  frame:SetPoint("TopLeft",10,-10);
  frame:Hide();

  for i=2, 40 do
    local frame = CreateFrame("Frame", "FC_entry"..i, childFrame, "FC_ResponseEntry");
    frame:SetPoint("Top","FC_entry" .. (i-1), "Bottom");
    frame:Hide();
  end

end

function fusedAddon:OnEnable()
  self:RegisterComm(addonPrefix, "CommHandler");
  self:RegisterChatCommand("fc", function(input)
    local args= {strsplit(" ", input)};

    if args[1] ~= nil then
      if args[1] == "test" then


        self:test({GetInventoryItemLink("player",16),
          GetInventoryItemLink("player",2),
          GetInventoryItemLink("player",3),
          GetInventoryItemLink("player",9),
          GetInventoryItemLink("player",5),
          GetInventoryItemLink("player",6),
          GetInventoryItemLink("player",7),
          GetInventoryItemLink("player",8)

        });
      end

    else
      print("No cmd was entered");
    end



  end);


  local options = {
    name ="FusedCouncil",
    type="group",
    -- can have set and get defined to get from DB
    args = {
      global = {
        order =1,
        name = "General config",
        type ="group",

        args = {
          help = {
            order=0,
            type = "description",
            name = "FusedCouncil is an in game loot distribution system."

          },

          buttons = {
            order =1,
            type = "group",
            guiInline = true,
            name = "Response Buttons",
            args = {
              help = {
                order =0,
                type="description",
                name = "Allows the configuration of response buttons"

              },
              numButtons = {
                type = "range",
                width = 'full',
                order = 1,
                name = "Amount of buttons to display:",
                min = 1,
                max = 7,
                step = 1,
                set = function(info, val)  dbProfile.options.numOfResponseButtons = val end,
                get = function(info) return dbProfile.options.numOfResponseButtons end,
              },
              button1 = {
                type = "input",
                name = "button1",

                order = 2,
                set = function(info, val) dbProfile.options.responseButtonNames[1] = val end,
                get  = function(info, val) return dbProfile.options.responseButtonNames[1] end,
              },
              button2 = {
                type = "input",
                name = "button2",
                order = 3,
                hidden = function () return dbProfile.options.numOfResponseButtons < 2 end,
                set = function(info, val) dbProfile.options.responseButtonNames[2] = val end,
                get  = function(info, val) return dbProfile.options.responseButtonNames[2] end,

              },
              button3 = {
                type = "input",
                name = "button3",

                order = 4,
                hidden = function () return dbProfile.options.numOfResponseButtons < 3 end,
                set = function(info, val) dbProfile.options.responseButtonNames[3] = val end,
                get  = function(info, val) return dbProfile.options.responseButtonNames[3] end,

              },
              button4 = {
                type = "input",
                name = "button4",

                order = 5,
                hidden = function () return dbProfile.options.numOfResponseButtons < 4 end,
                set = function(info, val) dbProfile.options.responseButtonNames[4] = val end,
                get  = function(info, val) return dbProfile.options.responseButtonNames[4] end,
              },
              button5 = {
                type = "input",
                name = "button5",
                order = 6,
                hidden = function () return dbProfile.options.numOfResponseButtons < 5 end,
                set = function(info, val) dbProfile.options.responseButtonNames[5] = val end,
                get  = function(info, val) return dbProfile.options.responseButtonNames[5] end,
              },
              button6 = {
                type = "input",
                name = "button6",
                order = 7,
                hidden = function () return dbProfile.options.numOfResponseButtons < 6 end,
                set = function(info, val) dbProfile.options.responseButtonNames[6] = val end,
                get  = function(info, val) return dbProfile.options.responseButtonNames[6] end,
              },
              button7 = {
                type = "input",
                name = "button7",
                order = 8,
                hidden = function () return dbProfile.options.numOfResponseButtons < 7 end,
                set = function(info, val) dbProfile.options.responseButtonNames[7] = val end,
                get  = function(info, val) return dbProfile.options.responseButtonNames[7] end,
              },
            },
          },
          lootCouncilGroup = {
            order =2,
            type = "group",
            guiInline = true,
            name = "Loot Council",
            args = {
              help = {
                order =0,
                type="description",
                name = "Allows the configuration of the members on council"

              },
              councilInput = {
                type = "input",
                name = "Loot Council Member",
                order = 1,
                width = "full",
                set = function(info, val)
                  -- get string convert to array store array
                  -- { multple values } instantly creates an array with those values
                  dbProfile.options.lootCouncilMembers = {strsplit(",", val)};
                end,
                get  = function(info, val)
                  -- take stored array convert to string and return string
                  local tempString = "";
                  for i=1, #dbProfile.options.lootCouncilMembers do
                    if i == 1 then
                      tempString = dbProfile.options.lootCouncilMembers[i];
                    else
                      tempString = tempString .. "," .. dbProfile.options.lootCouncilMembers[i];
                    end

                  end

                  return tempString;
                end,
              },

            },
          },
          resetDB = {
            type = "execute",
            name = "reset salved DB",
            func = function() fusedCouncil:clearForNextUse(); end,


          },
          resetProfile = {
            type = "execute",
            name = "reset defaults",
            func = function() fusedCouncil.db:ResetProfile(); end,


          },

        },
      },
    },

  };

  LibStub("AceConfig-3.0"):RegisterOptionsTable("FusedCouncil Options", options);
  LibStub("AceConfigDialog-3.0"):AddToBlizOptions("FusedCouncil Options", "FusedCouncil", nil, 'global');




end

function fusedAddon:CommHandler(prefix, message, distrubtuion, sender)
  if prefix == addonPrefix then
    local success, payload = self:Deserialize(message);


    if success then
      if payload["cmd"] == "itemBank" then
        if sender == UnitName("player") or true then

          for i=1, #payload["itemBank"] do
            -- query them all

            options= payload["options"];
            table.insert(popupItems, payload["itemBank"][i]);
          end

        end

      elseif payload["cmd"] == "response" then


        local item = fusedAddon:findItem(payload["response"]["itemLink"]);
        table.insert(item["responses"], payload["response"]);
        
      elseif payload["cmd"] == "vote" then
      print(payload["vote"]["item"]["itemLink"])
        local item = fusedAddon:findItem(payload["vote"]["item"]["itemLink"]);
            if item then
                for i=1, #item["responses"]do
                  if item["responses"][i]["player"]["name"] == payload["vote"]["to"] then
                    table.insert(item["responses"][i]["votes"], payload["vote"]["from"]);
                  end
                end
            end
      elseif payload["cmd"] == "unvote" then
        local item = fusedAddon:findItem(payload["vote"]["item"]["itemLink"]);
        print(payload["vote"]["item"]["itemName"])
        local index;
            if item then
                for i=1, #item["responses"]do
                print(item["responses"][i]["player"]["name"] .. " " .. payload["vote"]["to"])
                  if item["responses"][i]["player"]["name"] == payload["vote"]["to"] then
                      for k=1, #item["responses"][i]["votes"] do
                        if item["responses"][i]["votes"][k] == payload["vote"]["from"] then
                          index =k;
                          print(k)
                        end
                      end
                       if index then
                 table.remove(item["responses"][i]["votes"], index);
                end
                  end
               
                end
                
            end
      end
      fusedAddon:update();
    end


  end

end

function fusedAddon:OnDisable()

end

function fusedAddon:update()
  if #popupItems > 0 then
    popupFrame:Show();
    -- clear old
    for i=1, 5 do
      getglobal("FC_Popup" .. i):Hide();
      getglobal("FC_Popup" .. i.. "NoteBox"):SetText("");
    end
    if #popupItems <= 5 then
      for i=1, #popupItems do
        fusedAddon:populatePopup(i, popupItems[i]);
      end
    else
      for i=1, 5 do
        fusedAddon:populatePopup(i, popupItems[i]);
      end
    end
  else
    popupFrame:Hide();
  end -- end of popup stuff

  -- main window stuff
  if not currentItem and #itemBank > 0 then
    currentItem = itemBank[1];
  end

  if #itemBank == 0 then
    currentItem = nil;
  end

  if currentItem then
    getglobal("FC_CurrentItemLabel"):SetText(currentItem["itemLink"]);
    getglobal("FC_CurrentItemIlvlLabel"):SetText("ilvl: " .. currentItem["itemLevel"]);
    getglobal("FC_CurrentItemTypeLabel"):SetText(currentItem["itemSubType"] .. " " .. _G[currentItem["itemEquipLoc"]] );

    getglobal("FC_currentItemFrameTexture"):SetTexture(currentItem["itemTexture"]);
    for i=1, 40 do
      getglobal("FC_entry" .. i):Hide();
      getglobal("FC_entry" .. i .. "ItemFrame"):Hide();
      getglobal("FC_entry" .. i .. "ItemFrameDuo1"):Hide();
      getglobal("FC_entry" .. i .. "ItemFrameDuo2"):Hide();
      getglobal("FC_entry" .. i .."NoteFrameNoteTexture"):SetTexture("Interface\\CHATFRAME\\UI-ChatIcon-Chat-Disabled");
      getglobal("FC_entry" .. i .. "VoteButton"):SetText("Vote");
    end
    for i=1, #currentItem["responses"] do
      getglobal("FC_entry" .. i):Show();
      
      local votesFrame = getglobal("FC_entry" .. i .. "VotesFrame");
      votesFrame:SetScript("OnEnter", function()
          GameTooltip:SetOwner(votesFrame, "ANCHOR_RIGHT")
          if currentItem then
            local votes ="";
            
            for k=1, #currentItem["responses"][i]["votes"] do
              if k > 1 then
              votes = votes .. ", " .. currentItem["responses"][i]["votes"][k];
              else
              votes = votes ..currentItem["responses"][i]["votes"][k];
              end
              
            end
            GameTooltip:SetText(votes);
            GameTooltip:Show()
          end

        end);
        votesFrame:SetScript("OnLeave", function()
          GameTooltip:Hide()
        end);
      
        getglobal("FC_entry" .. i .. "VotesFrameVotesString"):SetText(#currentItem["responses"][i]["votes"]);
        
        
      for k=1, #currentItem["responses"][i]["votes"] do
        if currentItem["responses"][i]["votes"][k] == UnitName("player") then
          getglobal("FC_entry" .. i .. "VoteButton"):SetText("Unvote");

        end

      end

      getglobal("FC_entry" .. i .. "VoteButton"):SetScript("OnClick", function(self)
        if self:GetText() == "Vote" then
          if not fusedAddon:hasVoteFrom(currentItem, UnitName("player")) then
            local payload = {cmd="vote", vote = {from = UnitName("player"), to = currentItem["responses"][i]["player"]["name"], item = currentItem }};
            local serializedPayload = fusedAddon:Serialize(payload);
            fusedAddon:SendCommMessage(addonPrefix,serializedPayload, "RAID");
            
          end
        else
          local payload = {cmd="unvote", vote = {from = UnitName("player"), to = currentItem["responses"][i]["player"]["name"], item = currentItem }};
          local serializedPayload = fusedAddon:Serialize(payload);
          fusedAddon:SendCommMessage(addonPrefix,serializedPayload, "RAID");
        end


      end);


      getglobal("FC_entry" .. i .."NoteFrame");
      if currentItem["responses"][i]["note"] ~= "" then
        local noteFrame = getglobal("FC_entry" .. i .."NoteFrame");
        getglobal("FC_entry" .. i .."NoteFrameNoteTexture"):SetTexture("Interface\\CHATFRAME\\UI-ChatIcon-Chat-Up");

        noteFrame:SetScript("OnEnter", function()
          GameTooltip:SetOwner(noteFrame, "ANCHOR_RIGHT")
          if currentItem then
            GameTooltip:SetText(currentItem["responses"][i]["note"]);
            GameTooltip:Show()
          end

        end);
        noteFrame:SetScript("OnLeave", function()
          GameTooltip:Hide()
        end);


      end




      getglobal("FC_entry" .. i .. "ClassIcon"):SetTexture("Interface\\GLUES\\CHARACTERCREATE\\UI-CHARACTERCREATE-CLASSES");
      print(currentItem["responses"][i]["player"]["class"]);
      local coords = CLASS_ICON_TCOORDS[currentItem["responses"][i]["player"]["class"]];
      getglobal("FC_entry" .. i .. "ClassIcon"):SetTexCoord(unpack(coords));

      getglobal("FC_entry" .. i .. "CharName"):SetText(currentItem["responses"][i]["player"]["name"]);
      getglobal("FC_entry" .. i .. "Ilvl"):SetText(currentItem["responses"][i]["player"]["ilvl"]);
      getglobal("FC_entry" .. i .. "Score"):SetText(currentItem["responses"][i]["player"]["score"]);
      getglobal("FC_entry" .. i .. "Rank"):SetText(currentItem["responses"][i]["player"]["guildRank"]);
      getglobal("FC_entry" .. i .. "Response"):SetText(currentItem["responses"][i]["response"]);

      if #currentItem["responses"][i]["currentItems"] == 1 then
        local itemFrame = getglobal("FC_entry" .. i .. "ItemFrame");
        itemFrame:Show();
        getglobal("FC_entry" .. i .. "ItemFrameTexture"):SetTexture(currentItem["responses"][i]["currentItems"][1]["itemTexture"]);


        itemFrame:SetScript("OnEnter", function()
          GameTooltip:SetOwner(itemFrame, "ANCHOR_RIGHT")
          if currentItem then
            GameTooltip:SetHyperlink(currentItem["responses"][i]["currentItems"][1]["itemLink"]);
            GameTooltip:Show()
          end

        end);
        itemFrame:SetScript("OnLeave", function()
          GameTooltip:Hide()
        end);
      elseif #currentItem["responses"][i]["currentItems"] == 2 then
        local itemFrame = getglobal("FC_entry" .. i .. "ItemFrameDuo1");
        itemFrame:Show();
        getglobal("FC_entry" .. i .. "ItemFrameDuo1Texture"):SetTexture(currentItem["responses"][i]["currentItems"][1]["itemTexture"]);


        itemFrame:SetScript("OnEnter", function()
          GameTooltip:SetOwner(itemFrame, "ANCHOR_RIGHT")
          if currentItem then
            GameTooltip:SetHyperlink(currentItem["responses"][i]["currentItems"][1]["itemLink"]);
            GameTooltip:Show()
          end

        end);
        itemFrame:SetScript("OnLeave", function()
          GameTooltip:Hide()
        end);

        itemFrame = getglobal("FC_entry" .. i .. "ItemFrameDuo2");
        itemFrame:Show();
        getglobal("FC_entry" .. i .. "ItemFrameDuo2Texture"):SetTexture(currentItem["responses"][i]["currentItems"][2]["itemTexture"]);


        itemFrame:SetScript("OnEnter", function()
          GameTooltip:SetOwner(itemFrame, "ANCHOR_RIGHT")
          if currentItem then
            GameTooltip:SetHyperlink(currentItem["responses"][i]["currentItems"][2]["itemLink"]);
            GameTooltip:Show()
          end

        end);
        itemFrame:SetScript("OnLeave", function()
          GameTooltip:Hide()
        end);




      else
        getglobal("FC_entry" .. i .. "ItemFrameTexture"):SetTexture("Interface\\InventoryItems\\WowUnknownItem01");

      end

    end
  else
    getglobal("FC_CurrentItemLabel"):SetText("Current Item Label");
    getglobal("FC_CurrentItemIlvlLabel"):SetText("ilvl: 865");
    getglobal("FC_CurrentItemTypeLabel"):SetText("Item Type");
    getglobal("FC_currentItemFrameTexture"):SetTexture();

  end
  for i=1, 10 do
    getglobal("FC_windowFrame"..i):Hide();
  end
  for i=1, #itemBank do
    itemsWindow:SetSize(70, 55 * i);
    getglobal("FC_windowFrame"..i .. "Texture"):SetTexture(itemBank[i]["itemTexture"]);
    local frame = getglobal("FC_windowFrame"..i);
    frame:Show();
    frame:SetScript("OnEnter", function()
      GameTooltip:SetOwner(frame, "ANCHOR_RIGHT")
      GameTooltip:SetHyperlink(itemBank[i]["itemLink"]);
      GameTooltip:Show()
    end);
    frame:SetScript("OnLeave", function()
      GameTooltip:Hide()
    end);

    frame:SetScript("OnMouseDown", function()
      currentItem = itemBank[i];
      fusedAddon:update();
    end);

  end

end

function fusedAddon:hasVoteFrom(item, player)
  for i=1, #item["responses"] do
    for k=1, #item["responses"][i]["votes"] do
      if item["responses"][i]["votes"][k] == player then
        return true;
      end
    end
  end
  return false;
end
function fusedAddon:populatePopup(index, item)

  getglobal("FC_Popup" .. index):Show();
  getglobal("FC_Popup" .. index.. "ItemLabel"):SetText(item["itemLink"]);
  getglobal("FC_Popup" .. index.. "IlvlLabel"):SetText("ilvl: " .. item["itemLevel"]);
  getglobal("FC_Popup" .. index.. "ItemTypeLabel"):SetText(item["itemSubType"] .. " " .. _G[item["itemEquipLoc"]] );
  getglobal("FC_Popup" .. index .. "IconFrame" .."Texture"):SetTexture(item["itemTexture"]);
  local frame = getglobal("FC_Popup" .. index .. "IconFrame");
  frame:SetScript("OnEnter", function()
    GameTooltip:SetOwner(frame, "ANCHOR_RIGHT")
    GameTooltip:SetHyperlink(item["itemLink"]);
    GameTooltip:Show()
  end);
  frame:SetScript("OnLeave", function()
    GameTooltip:Hide()
  end);

  for i=1, options["numOfResponseButtons"] do

    local button = getglobal("FC_Popup" .. index).buttons[i];
    button:Show();
    button:SetText(options["responseButtonNames"][i]);
    button:SetScript("OnClick", function()

        local response ={
          type="response",
          itemLink = item["itemLink"],
          player = {type="player",
            name = UnitName("player"),
            ilvl = math.floor(select(2, GetAverageItemLevel())+0.5),
            score = 0,
            guildRank = select(2, GetGuildInfo("player")) or "No Guild",
            class = select(2, UnitClass("player"))
          },
          response = options["responseButtonNames"][i],
          note = getglobal("FC_Popup" .. index .. "NoteBox"):GetText(),
          currentItems = fusedAddon:getPlayersCurrentItem(item),
          votes ={}
        };
        -- popup clean up
        table.remove(popupItems, index);
        for k=1, 7 do
          frame:GetParent().buttons[k]:Hide();
        end
        frame:GetParent():Hide();
        local payload = {cmd="response", response= response };
        local serializedPayload = fusedAddon:Serialize(payload);
        fusedAddon:SendCommMessage(addonPrefix,serializedPayload, "RAID");
        fusedAddon:update();

    end);
  end
end

local INVTYPE_Slots = {
  INVTYPE_HEAD        = "HeadSlot",
  INVTYPE_NECK        = "NeckSlot",
  INVTYPE_SHOULDER      = "ShoulderSlot",
  INVTYPE_CLOAK       = "BackSlot",
  INVTYPE_CHEST       = "ChestSlot",
  INVTYPE_WRIST       = "WristSlot",
  INVTYPE_HAND        = "HandsSlot",
  INVTYPE_WAIST       = "WaistSlot",
  INVTYPE_LEGS        = "LegsSlot",
  INVTYPE_FEET        = "FeetSlot",
  INVTYPE_SHIELD        = "SecondaryHandSlot",
  INVTYPE_ROBE        = "ChestSlot",
  INVTYPE_2HWEAPON      = {"MainHandSlot","SecondaryHandSlot"},
  INVTYPE_WEAPONMAINHAND  = "MainHandSlot",
  INVTYPE_WEAPONOFFHAND = {"SecondaryHandSlot",["or"] = "MainHandSlot"},
  INVTYPE_WEAPON        = {"MainHandSlot","SecondaryHandSlot"},
  INVTYPE_THROWN        = {"SecondaryHandSlot", ["or"] = "MainHandSlot"},
  INVTYPE_RANGED        = {"SecondaryHandSlot", ["or"] = "MainHandSlot"},
  INVTYPE_RANGEDRIGHT   = {"SecondaryHandSlot", ["or"] = "MainHandSlot"},
  INVTYPE_FINGER        = {"Finger0Slot","Finger1Slot"},
  INVTYPE_HOLDABLE      = {"SecondaryHandSlot", ["or"] = "MainHandSlot"},
  INVTYPE_TRINKET       = {"TRINKET0SLOT", "TRINKET1SLOT"}
}


function fusedAddon:getPlayersCurrentItem(item)
  local itemTable = {};
  local itemLink1, itemLink2;
  local slot = INVTYPE_Slots[item["itemEquipLoc"]];
  if not slot then
    return nil;
  end
  itemLink1 = GetInventoryItemLink("player", GetInventorySlotInfo(slot[1] or slot));

  if not itemLink1 and slot["or"] then
    itemLink1 = GetInventoryItemLink("player", GetInventorySlotInfo(slot['or']));
  end

  if slot[2] then
    itemLink2 = GetInventoryItemLink("player", GetInventorySlotInfo(slot[2]));
  end

  local itemName, _ , itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture = GetItemInfo(itemLink1);
  local item1 = {
    type = "item",
    itemName = itemName,
    itemLink = itemLink1,
    itemRarity = itemRarity,
    itemLevel = itemLevel,
    itemMinLevel = itemMinLevel,
    itemType = itemType,
    itemSubType = itemSubType,
    itemStackCount = itemStackCount,
    itemEquipLoc = itemEquipLoc,
    itemTexture = itemTexture,
    responses = {}
  };
  table.insert(itemTable, item1 );
  if itemLink2 then
    local itemName, _ , itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture = GetItemInfo(itemLink2);
    local item2 = {
      type = "item",
      itemName = itemName,
      itemLink = itemLink2,
      itemRarity = itemRarity,
      itemLevel = itemLevel,
      itemMinLevel = itemMinLevel,
      itemType = itemType,
      itemSubType = itemSubType,
      itemStackCount = itemStackCount,
      itemEquipLoc = itemEquipLoc,
      itemTexture = itemTexture,
      responses = {}
    };
    table.insert(itemTable, item2 );
  end






  return itemTable;
end
function fusedAddon:test(itemTable)
  mainFrame:Show();
  for i=1, #itemTable do
    local item = fusedAddon:findItem(itemTable[i]);
    if item then
      item["itemStackCount"] = item["itemStackCount"] +1;
    else
      fusedAddon:addItem(itemTable[i]);
    end

  end

  -- send off list
  local payload = {cmd="itemBank", itemBank= itemBank , options = dbProfile.options};
  local serializedPayload = fusedAddon:Serialize(payload);
  fusedAddon:SendCommMessage(addonPrefix,serializedPayload, "RAID");


  fusedAddon:update();
end

function fusedAddon:findItem(itemLink)
  for i=1, #itemBank do
    if itemBank[i]["itemLink"] == itemLink then
      return itemBank[i];
    end
  end

  return nil;
end

function fusedAddon:addItem(itemLink)
  local itemName, _ , itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture = GetItemInfo(itemLink);
  local item = {
    type = "item",
    itemName = itemName,
    itemLink = itemLink,
    itemRarity = itemRarity,
    itemLevel = itemLevel,
    itemMinLevel = itemMinLevel,
    itemType = itemType,
    itemSubType = itemSubType,
    itemStackCount = itemStackCount,
    itemEquipLoc = itemEquipLoc,
    itemTexture = itemTexture,
    responses = {}
  };
  table.insert(itemBank, item);



end





--local tempFrame = CreateFrame("Frame", nil, responseWindow, "FC_ResponseEntry");

-- will need for later

--currentItemTexture:SetTexture("Interface\\ICONS\\inv_sword_2h_felfireraid_d_01");
