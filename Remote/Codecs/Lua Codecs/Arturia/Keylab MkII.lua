-- Reason ReMote Codec for Arturia Keylab MkII User section (encoders, sliders and buttons).
-- NOTE: Keylab DAW mode must be set to Standard MCU. DAW controls are also available when in User mode as they output from separate port.
-- Version 1.2
-- V1.0 Timothy Rylatt - 15/11/2020
-- V1.2 Changes Ciathyza 14/02/2022

----------------------------------------------- Global Properties -------------------------------------------------

-- Position of first analog control in the items table.
gFirstAnalogIndex = 28

-- "Analogs" indicates non-encoder analog controls and refers to sliders on the Keylab MkII.
gNumberOfAnalogs = 27

-- Acceptable difference between the first reported value from a control and the machine state for the 2 to be considered synchronized.
gStartupLiveband = 3

-- Stores current position/value of control on hardware.
gAnalogPhysicalState = {}

-- Stores value of connected software item.
gAnalogMachineState  = {}

-- Difference between physical state of control and software value (positive numbers indicate physical value is greater,
-- nil indicates mismatch assumption due to unknown physical state at startup).
gAnalogMismatch      = {}

-- Stores timestamp of last time knob/slider was moved on hardware.
gLastAnalogMoveTime  = {}

-- Number of milliseconds to wait for a sent slider or knob value to be echoed back before reevaluating synchronization.
gSentValueSettleTime = {}

-- Converts CC numbers to slider/knob numbers.
gAnalogCCLookup =
{
	[21] = 1,
	[22] = 2,
	[23] = 3,
	[24] = 4,
	[25] = 5,
	[26] = 6,
	[27] = 7,
	[28] = 8,
	[29] = 9, -- Sliders 1-9
	[48] = 10,
	[49] = 11,
	[50] = 12,
	[51] = 13,
	[52] = 14,
	[53] = 15,
	[54] = 16,
	[55] = 17,
	[56] = 18, -- Sliders 10-18
	[75] = 19,
	[76] = 20,
	[77] = 21,
	[78] = 22,
	[79] = 23,
	[80] = 24,
	[81] = 25,
	[82] = 26,
	[83] = 27 -- Sliders 19-27
}


----------------------------------------------- Global Helpers ----------------------------------------------------

function fromHex(nr)
	return tonumber(nr, 16)
end


function toHex(nr)
	return string.format("%02x", nr)
end


----------------------------------------------- Remote Init -------------------------------------------------------

function remote_init(manufacturer, model)
	local globalItems       = {}
	local globalAutoInputs  = {}
	local globalAutoOutputs = {}

	---------- Helper Functions ----------

	local function makeButtonInputMask(controlID)
		local mask = "b?" .. toHex(controlID) .. "?<???x>"
		return mask
	end

	local function makeEncoderInputMask(controlID)
		local mask = "b?" .. toHex(controlID) .. "<???y>x"
		return mask
	end


	---------- Define Controls ----------

	local function defineControlInputs()
		local inputDefs =
		{
			{ id = fromHex("0C"), name = "Encoder1 B1", type = "encoder" }, -- 12
			{ id = fromHex("0D"), name = "Encoder2 B1", type = "encoder" }, -- 13
			{ id = fromHex("0E"), name = "Encoder3 B1", type = "encoder" }, -- 14
			{ id = fromHex("0F"), name = "Encoder4 B1", type = "encoder" }, -- 15
			{ id = fromHex("10"), name = "Encoder5 B1", type = "encoder" }, -- 16
			{ id = fromHex("11"), name = "Encoder6 B1", type = "encoder" }, -- 17
			{ id = fromHex("12"), name = "Encoder7 B1", type = "encoder" }, -- 18
			{ id = fromHex("13"), name = "Encoder8 B1", type = "encoder" }, -- 19
			{ id = fromHex("14"), name = "Encoder9 B1", type = "encoder" }, -- 20
			{ id = fromHex("27"), name = "Encoder1 B2", type = "encoder" }, -- 39
			{ id = fromHex("28"), name = "Encoder2 B2", type = "encoder" }, -- 40
			{ id = fromHex("29"), name = "Encoder3 B2", type = "encoder" }, -- 41
			{ id = fromHex("2A"), name = "Encoder4 B2", type = "encoder" }, -- 42
			{ id = fromHex("2B"), name = "Encoder5 B2", type = "encoder" }, -- 43
			{ id = fromHex("2C"), name = "Encoder6 B2", type = "encoder" }, -- 44
			{ id = fromHex("2D"), name = "Encoder7 B2", type = "encoder" }, -- 45
			{ id = fromHex("2E"), name = "Encoder8 B2", type = "encoder" }, -- 46
			{ id = fromHex("2F"), name = "Encoder9 B2", type = "encoder" }, -- 47
			{ id = fromHex("42"), name = "Encoder1 B3", type = "encoder" }, -- 66
			{ id = fromHex("43"), name = "Encoder2 B3", type = "encoder" }, -- 67
			{ id = fromHex("44"), name = "Encoder3 B3", type = "encoder" }, -- 68
			{ id = fromHex("45"), name = "Encoder4 B3", type = "encoder" }, -- 69
			{ id = fromHex("46"), name = "Encoder5 B3", type = "encoder" }, -- 70
			{ id = fromHex("47"), name = "Encoder6 B3", type = "encoder" }, -- 71
			{ id = fromHex("48"), name = "Encoder7 B3", type = "encoder" }, -- 72
			{ id = fromHex("49"), name = "Encoder8 B3", type = "encoder" }, -- 73
			{ id = fromHex("4A"), name = "Encoder9 B3", type = "encoder" }, -- 74

			{ id = fromHex("15"), name = "Slider1 B1", type = "slider" },   -- 21
			{ id = fromHex("16"), name = "Slider2 B1", type = "slider" },   -- 22
			{ id = fromHex("17"), name = "Slider3 B1", type = "slider" },   -- 23
			{ id = fromHex("18"), name = "Slider4 B1", type = "slider" },   -- 24
			{ id = fromHex("19"), name = "Slider5 B1", type = "slider" },   -- 25
			{ id = fromHex("1A"), name = "Slider6 B1", type = "slider" },   -- 26
			{ id = fromHex("1B"), name = "Slider7 B1", type = "slider" },   -- 27
			{ id = fromHex("1C"), name = "Slider8 B1", type = "slider" },   -- 28
			{ id = fromHex("1D"), name = "Slider9 B1", type = "slider" },   -- 29
			{ id = fromHex("30"), name = "Slider1 B2", type = "slider" },   -- 48
			{ id = fromHex("31"), name = "Slider2 B2", type = "slider" },   -- 49
			{ id = fromHex("32"), name = "Slider3 B2", type = "slider" },   -- 50
			{ id = fromHex("33"), name = "Slider4 B2", type = "slider" },   -- 51
			{ id = fromHex("34"), name = "Slider5 B2", type = "slider" },   -- 52
			{ id = fromHex("35"), name = "Slider6 B2", type = "slider" },   -- 53
			{ id = fromHex("36"), name = "Slider7 B2", type = "slider" },   -- 54
			{ id = fromHex("37"), name = "Slider8 B2", type = "slider" },   -- 55
			{ id = fromHex("38"), name = "Slider9 B2", type = "slider" },   -- 56
			{ id = fromHex("4B"), name = "Slider1 B3", type = "slider" },   -- 75
			{ id = fromHex("4C"), name = "Slider2 B3", type = "slider" },   -- 76
			{ id = fromHex("4D"), name = "Slider3 B3", type = "slider" },   -- 77
			{ id = fromHex("4E"), name = "Slider4 B3", type = "slider" },   -- 78
			{ id = fromHex("4F"), name = "Slider5 B3", type = "slider" },   -- 79
			{ id = fromHex("50"), name = "Slider6 B3", type = "slider" },   -- 80
			{ id = fromHex("51"), name = "Slider7 B3", type = "slider" },   -- 81
			{ id = fromHex("52"), name = "Slider8 B3", type = "slider" },   -- 82
			{ id = fromHex("53"), name = "Slider9 B3", type = "slider" },   -- 83

			{ id = fromHex("1E"), name = "Select1 B1", type = "button" },   -- 30
			{ id = fromHex("1F"), name = "Select2 B1", type = "button" },   -- 31
			{ id = fromHex("20"), name = "Select3 B1", type = "button" },   -- 32
			{ id = fromHex("21"), name = "Select4 B1", type = "button" },   -- 33
			{ id = fromHex("22"), name = "Select5 B1", type = "button" },   -- 34
			{ id = fromHex("23"), name = "Select6 B1", type = "button" },   -- 35
			{ id = fromHex("24"), name = "Select7 B1", type = "button" },   -- 36
			{ id = fromHex("25"), name = "Select8 B1", type = "button" },   -- 37
			{ id = fromHex("26"), name = "Select9 B1", type = "button" },   -- 38
			{ id = fromHex("39"), name = "Select1 B2", type = "button" },   -- 57
			{ id = fromHex("3A"), name = "Select2 B2", type = "button" },   -- 58
			{ id = fromHex("3B"), name = "Select3 B2", type = "button" },   -- 59
			{ id = fromHex("3C"), name = "Select4 B2", type = "button" },   -- 60
			{ id = fromHex("3D"), name = "Select5 B2", type = "button" },   -- 61
			{ id = fromHex("3E"), name = "Select6 B2", type = "button" },   -- 62
			{ id = fromHex("3F"), name = "Select7 B2", type = "button" },   -- 63
			{ id = fromHex("40"), name = "Select8 B2", type = "button" },   -- 64
			{ id = fromHex("41"), name = "Select9 B2", type = "button" },   -- 65
			{ id = fromHex("54"), name = "Select1 B3", type = "button" },   -- 84
			{ id = fromHex("55"), name = "Select2 B3", type = "button" },   -- 85
			{ id = fromHex("56"), name = "Select3 B3", type = "button" },   -- 86
			{ id = fromHex("57"), name = "Select4 B3", type = "button" },   -- 87
			{ id = fromHex("58"), name = "Select5 B3", type = "button" },   -- 88
			{ id = fromHex("59"), name = "Select6 B3", type = "button" },   -- 89
			{ id = fromHex("5A"), name = "Select7 B3", type = "button" },   -- 90
			{ id = fromHex("5B"), name = "Select8 B3", type = "button" },   -- 91
			{ id = fromHex("5C"), name = "Select9 B3", type = "button" }    -- 92
		}

		for k, v in pairs(inputDefs) do
			local itemName = v.name
			local itemID = v.id
			if (v.type == "button") then
				table.insert(globalItems,       { name = itemName, input = "button"                                         })
				table.insert(globalAutoInputs,  { name = itemName, pattern = makeButtonInputMask(itemID),  value = "x"      })
				-- No output as it isn't changing button's lighted status on the KeyLab
			elseif (v.type == "encoder") then
				table.insert(globalItems,       { name = itemName, input = "delta"                                          })
				table.insert(globalAutoInputs,  { name = itemName, pattern = makeEncoderInputMask(itemID), value = "x-16*y" })
				-- No output as there isn't anything to change on the KeyLab
			elseif (v.type == "slider") then
				table.insert(globalItems,       { name = itemName, input = "value", output = "value", min = 0, max = 127    })
				-- No auto-input as the sliders are handled below in remote_process_midi to enable soft pickup
			else
				-- don't have anything else to process
			end
		end
	end

	--------------------------------------------------------------------------------------------------------------

    defineControlInputs()
	
	remote.define_items(globalItems)
	remote.define_auto_inputs(globalAutoInputs)
	remote.define_auto_outputs(globalAutoOutputs)
end


----------------------------------------------- Control Input Logic -----------------------------------------------

-- Set up slider/knob tracking arrays.
for i = 1, gNumberOfAnalogs do
	gAnalogPhysicalState[i] = 0
	gAnalogMachineState[i]  = 0
	gAnalogMismatch[i]      = nil
	gLastAnalogMoveTime[i]  = 0
	gSentValueSettleTime[i] = 250
end


 -- Manual handling of incoming values sent by controller.
function remote_process_midi(event)
	-- Check for analog Messages.
	ret = remote.match_midi("B0 yy xx", event)
	if ret ~= nil then
		-- Catch knob events
		-- Try to get the analog number that corresponds to the received Continuous Controller message.
		local AnalogNum = gAnalogCCLookup[ret.y]
		-- Try to get the analog number that corresponds to the received Continuous Controller message.
		-- If message isn't from an analog ...
		if AnalogNum == nil then
			-- ... pass it on to auto input handling.
			return false
		else
			-- Update the stored physical state to the incoming value.
			gAnalogPhysicalState[AnalogNum] = ret.x
			-- We'll send the incoming value to the host unless we find a reason not to.
			local AllowChange = true

			-- Assess conditions if controller and software values are mismatched.
			if gAnalogMismatch[AnalogNum] ~= 0 then
				-- Startup condition: analog hasn't reported in yet.
				if gAnalogMismatch[AnalogNum] == nil then
					-- Calculate and store how physical and machine states relate to each other.
					gAnalogMismatch[AnalogNum] = gAnalogPhysicalState[AnalogNum] - gAnalogMachineState[AnalogNum]
					-- Calculate and store how physical and machine states relate to each other.
					-- If the physical value is too far from the machine value.
					if math.abs(gAnalogMismatch[AnalogNum]) > gStartupLiveband then
						AllowChange = false -- don't send it to Reason
					end
				 -- If physical state of analog was and still is above virtual value.
				elseif gAnalogMismatch[AnalogNum] > 0 and gAnalogPhysicalState[AnalogNum] - gAnalogMachineState[AnalogNum] > 0 then
					 -- Don't send the new value to Reason because it's out of sync.
					AllowChange = false
				 -- If physical state of analog was and still is below virtual value.
				elseif gAnalogMismatch[AnalogNum] < 0 and gAnalogPhysicalState[AnalogNum] - gAnalogMachineState[AnalogNum] < 0 then
					-- Don't send the updated value.
					AllowChange = false
				end
			end

			 -- If the incoming change should be sent to Reason.
			if AllowChange then
				 -- Send the new analog value to Reason.
				remote.handle_input({ time_stamp = event.time_stamp, item = gFirstAnalogIndex + AnalogNum - 1, value = ret.x })
				-- Store the time this change was sent.
				gLastAnalogMoveTime[AnalogNum] = remote.get_time_ms()
				-- And set the flag to show the controller and Reason are in sync.
				gAnalogMismatch[AnalogNum] = 0
			end
			 -- Input has been handled.
			return true
		end
	end
	return false
end


 -- Handle incoming changes sent by Reason.
function remote_set_state(changed_items)
	for i, item_index in ipairs(changed_items) do
		 -- Calculate which analog (if any) the index of the changed item indicates.
		local AnalogNum = item_index - gFirstAnalogIndex + 1
		 -- If change belongs to an analog control ...
		if AnalogNum >= 1 and AnalogNum <= gNumberOfAnalogs then
			 -- ... update the machine state for the analog.
			gAnalogMachineState[AnalogNum] = remote.get_item_value(item_index)
			 -- If we know the analog's physical state ...
			if gAnalogMismatch[AnalogNum] ~= nil then
				 -- And the last value it sent to Reason happened outside the settle time ...
				if (remote.get_time_ms() - gLastAnalogMoveTime[AnalogNum]) > gSentValueSettleTime[AnalogNum] then
					 -- ... recalculate and store how physical and machine states relate to each other.
					gAnalogMismatch[AnalogNum] = gAnalogPhysicalState[AnalogNum] - gAnalogMachineState[AnalogNum]
				end
			end
		end
	end
end


function remote_probe()
	local controlRequest  = "F0 7E 7F 06 01 F7"
	local controlResponse = "F0 7E 7F 06 02 00 20 6B 02 00 05 64 ?? ?? ?? ?? F7"
	return { request = controlRequest, response = controlResponse }
end


function trace_event(event)
	result = "Event: "
	result = result .. "port " .. event.port .. ", "
	result = result .. (event.timestamp and ("timestamp " .. event.timestamp .. ", ") or "")
	result = result .. (event.hi and ("hi " .. event.hi .. ", ") or "")
	result = result .. (event.lo and ("lo " .. event.lo .. ", ") or "")
	result = result .. (event.size and ("size " .. event.size .. ", ") or "")
	result = result .. "data {"
	for i = 1, event.size do
		result = result .. event[i] .. ", "
	end
	result = result .. "}, "
	remote.trace(result)
end
