fusedAddon = LibStub("AceAddon-3.0"):NewAddon("fusedAddon","AceConsole-3.0", "AceEvent-3.0", "AceComm-3.0", "AceSerializer-3.0", "AceHook-3.0", "AceTimer-3.0");

local mainFrame;
local itemsWindow;
local responseW
local currentItem;
local eleigableLooters;
local timerCount;
local timer;
local popupFrame;
local popupItems = {};

--Core stuff
local itemBank;
local addonPrefix = "FCPREFIX";
local options;

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

function fusedAddon:createPopupFrame()
  local tempMainFrame = CreateFrame("Frame", nil, UIParent, "FC_MainLootFrame");

  local tempFrame = CreateFrame("Frame", "FC_Popup1", tempMainFrame, "FC_ResponseFrame");
  tempFrame:SetPoint("Topleft");
  tempFrame.buttons = {};
  for i=1, 7 do
    local button = CreateFrame("Button", nil, tempFrame, "UIPanelButtonTemplate");
    button:Hide();
    button:SetPoint("bottomleft", 70 + (95 * (i - 1)), 35);
    button:SetSize(80,25);
    table.insert(tempFrame.buttons, button);
  end

  for i=2, 5 do
    tempFrame = CreateFrame("Frame", "FC_Popup" .. i, tempMainFrame, "FC_ResponseFrame");
    tempFrame:SetPoint("Top","FC_Popup" .. (i-1), "Bottom");
    tempFrame.buttons = {};
    for k=1, 7 do
      local button = CreateFrame("Button", nil, tempFrame, "UIPanelButtonTemplate");
      button:Hide();
      button:SetPoint("bottomleft", 70 + (95 * (k-1)), 35);
      button:SetSize(80,25);
      table.insert(tempFrame.buttons, button);
    end
  end

  return tempMainFrame;
end
function fusedAddon:createItemsWindow()
  local itemsWindow = getglobal("FC_ItemsWindow");
  local itemsWindowChild = CreateFrame("Frame", nil, itemsWindow);
  itemsWindow:SetScrollChild(itemsWindowChild);

  local frame = CreateFrame("Frame", "FC_windowFrame1", itemsWindowChild, "FC_ItemFrame");
  frame:SetPoint("TopLeft",10,-10);
  frame:Hide();

  for i=2, 10 do
    local frame = CreateFrame("Frame", "FC_windowFrame"..i, itemsWindowChild, "FC_ItemFrame");
    frame:SetPoint("Top","FC_windowFrame" .. (i-1), "Bottom");
    frame:Hide();
  end
  return itemsWindow;
end

function fusedAddon:createResponseWindow()
  local tempFrame = getglobal("FC_responseWindow");
  local childFrame = CreateFrame("Frame",nil, tempFrame);
  childFrame:SetSize(800,800);
  tempFrame:SetScrollChild(childFrame);
  local frame = CreateFrame("Frame", "FC_entry1",childFrame, "FC_ResponseEntry");
  frame:SetPoint("TopLeft",10,-10);
  frame:Hide();

  for i=2, 40 do
    local frame = CreateFrame("Frame", "FC_entry"..i, childFrame, "FC_ResponseEntry");
    frame:SetPoint("Top","FC_entry" .. (i-1), "Bottom");
    frame:Hide();
  end
  return tempFrame;
end

function fusedAddon:createMainFrame()
  local tempMain = CreateFrame("Frame", nil, UIParent, "FC_MainFrame");

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
  return tempMain;
end
function fusedAddon:OnInitialize()
  mainFrame = fusedAddon:createMainFrame();

  popupFrame = fusedAddon:createPopupFrame();

  itemsWindow = fusedAddon:createItemsWindow();

  responseWindow = fusedAddon:createResponseWindow();

  itemBank ={};

  self.db = LibStub("AceDB-3.0"):New("FusedAddonDB",dbDefaults, true);
  self.db:RegisterDefaults(dbDefaults);
  dbProfile = self.db.profile;
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
			fusedAddon:popupUpdate();
        end
        local ack = {cmd="ack", id=0};
        local serializedAck = fusedAddon:Serialize(ack);
        fusedAddon:SendCommMessage(addonPrefix, serializedAck, "WHISPER", sender);
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
      elseif payload["cmd"] =="ack" then
        local index = 0;
        for i =1, #elegableLooters do
          if eleigableLooters == sender then
            index = i;
          end
        end
        if index > 0 then
			print("removing " .. sender)
          table.remove(eleigableLooterse, index);
        end
        
      end -- end if cmd == ......
      fusedAddon:update();
    end -- end succes deserialize


  end -- matching prefix

end

function fusedAddon:OnDisable()

end


function fusedAddon:popupUpdate()
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

end



local function updateEntrys()
  for i=1, 40 do
    getglobal("FC_entry" .. i):Hide();
    getglobal("FC_entry" .. i .. "ItemFrame"):Hide();
    getglobal("FC_entry" .. i .. "ItemFrameDuo1"):Hide();
    getglobal("FC_entry" .. i .. "ItemFrameDuo2"):Hide();
    getglobal("FC_entry" .. i .."NoteFrameNoteTexture"):SetTexture("Interface\\CHATFRAME\\UI-ChatIcon-Chat-Disabled");
    getglobal("FC_entry" .. i .. "VoteButton"):SetText("Vote");
  end
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

end
local function updateItemsWindow()
  for i=1, 10 do
    getglobal("FC_windowFrame"..i):Hide();
  end
  
  for i=1, #itemBank do
    itemsWindow:GetScrollChild():SetSize(70, 55 * i);
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
function fusedAddon:update()


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
    
    updateEntrys();

  else
    getglobal("FC_CurrentItemLabel"):SetText("Current Item Label");
    getglobal("FC_CurrentItemIlvlLabel"):SetText("ilvl: 865");
    getglobal("FC_CurrentItemTypeLabel"):SetText("Item Type");
    getglobal("FC_currentItemFrameTexture"):SetTexture();

  end
  
  updateItemsWindow();
  

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
  for i=1, 40 do
    if GetMasterLootCandidate(i) then
      eleigableLooters ={};
      table.insert(eleigableLooters, GetMasterLootCandidate(i));
    end
  end
  -- send off list
  local payload = {cmd="itemBank", itemBank= itemBank , options = dbProfile.options};
  local serializedPayload = fusedAddon:Serialize(payload);
  fusedAddon:SendCommMessage(addonPrefix,serializedPayload, "RAID");
  timer = self:ScheduleRepeatingTimer(function() 
    timerCount = timerCount +1;
    for i=1, #eleigableLooters do
      fusedAddon:SendCommMessage(addonPrefix,serializedPayload, "WHISPER", eleigableLooters[i]);
    end
    if timerCount == 4 then
      self:CancelTimer(timer);
    end
  
  
  
  end, 2);

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
function fusedAddon:sort( sortFunc)
  local table = currentItem["responses"];
  -- if the table is alreaded sorted isSorted will stay true
  local isSorted = true;

  if optionsTable == nil then
    for i=1, #table-1 do
      local j=i;
      while j > 0 and sortFunc(table[j], table[j+1]) do
        isSorted = false;
        local temp = table[j];
        table[j] = table[j+1];
        table[j+1] = temp;
        j=j-1;
      end
    end

  else

    for i=1, #table-1 do
      local j=i;
      while j > 0 and sortFunc(table[j], table[j+1], optionsTable) do
        isSorted = false;
        local temp = table[j];
        table[j] = table[j+1];
        table[j+1] = temp;
        j=j-1;
      end
    end
  end
  -- if it was already sorted reverse the list
  if isSorted then
    for i=1, #table/2 do
      local temp = table[i];
      table[i] = table[#table - (i-1)]
      table[#table - (i-1)] = temp;
    end
  end

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


FC_Utils ={
  nameCompare = function(response1, response2)
    return response1["player"]["name"] > response2["player"]["name"];

  end;

  ilvlCompare = function(response1, response2)
    return response1["player"]["ilvl"] > response2["player"]["ilvl"];
  end;

  scoreCompare = function(response1, response2)
    return response1["player"]["score"] > response2["player"]["score"];
  end;

  itemCompare = function(response1, response2)
    local response1ilvl;
    local response2ilvl;
    if #response1["currentItems"] > 1 then
      local itemlvl1 = select(4,GetItemInfo(response1["currentItems"][1]));
      local itemlvl2 = select(4,GetItemInfo(response1["currentItems"][2]));
      if itemlvl1 == nil or itemlvl2 == nil then
        response1ilvl = 0;
      else
        response1ilvl = itemlvl1 /itemlvl2;
      end

    else
      response1ilvl = select(4,GetItemInfo(response1["currentItems"][1])) or  0;
    end

    if #response2["currentItems"] > 1 then
      local itemlvl1 = select(4,GetItemInfo(response1["currentItems"][1]));
      local itemlvl2 = select(4,GetItemInfo(response1["currentItems"][2]));
      if itemlvl1 == nil or itemlvl2 == nil then
        response2ilvl = 0;
      else
        response2ilvl = itemlvl1 /itemlvl2;
      end

    else
      response2ilvl = select(4,GetItemInfo(response1["currentItems"][1])) or  0;
    end

    return response1ilvl > response2ilvl;

  end;

  rankCompare = function(response1, response2)
    -- possible break, api function returns nil if target is in loading screen
    local playerRank1 = select(3, GetGuildInfo(response1["player"]["name"]));
    local playerRank2 = select(3, GetGuildInfo(response2["player"]["name"]));
    -- GM is rank 0 lowest rank should be highest num
    print(playerRank1.. " " ..playerRank2)
    return playerRank1 < playerRank2;

  end;

  responseCompare = function(response1, response2)
    -- prob need to do options here?
    local index1 = options.numOfResponseButtons;
    local index2 = options.numOfResponseButtons;
    for i=1, options.numOfResponseButtons do
      if response1["response"] == options.responseButtonNames[i] then
        index1 = i;
      end
      if response2["response"] == options.responseButtonNames[i] then
        index2 = i;
      end
    end
    return index1 < index2;
  end;

  noteCompare = function(response1, response2)
    return response1["note"] ~= "" and response2["note"] == "";
  end;

  votesCompare = function(response1,response2)
    return #response1["votes"] > #response2["votes"];
  end;

  tableContains = function(table,element)
    local flag  = false;
    for i=1, #table do
      if table[i] == element then
        flag = true;
      end
    end
    return flag;
  end;

};














































--local tempFrame = CreateFrame("Frame", nil, responseWindow, "FC_ResponseEntry");

































-- will need for later

































--currentItemTexture:SetTexture("Interface\\ICONS\\inv_sword_2h_felfireraid_d_01");
