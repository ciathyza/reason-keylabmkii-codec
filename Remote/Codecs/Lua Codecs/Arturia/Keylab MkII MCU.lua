-- Reason ReMote Codec for Arturia Keylab MkII Track and DAW controls.
-- NOTE: Keylab DAW mode must be set to Standard MCU. DAW controls are also available when in User mode as they output from separate port.
-- Version 1.2
-- V1.0 Timothy Rylatt - 15/11/2020
-- V1.2 Changes Ciathyza 14/02/2022


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

	local function makeButtonMIDIInputMask(buttonID)
		assert(buttonID >= 0)
		assert(buttonID <= fromHex("67"))
		local mask = "90" .. toHex(buttonID) .. "<?xxx>x"
		return mask
	end

	local function makeLEDMIDIOutputMask(ledID)
		assert(ledID >= 0)
		assert(ledID <= fromHex("73"))
		local mask = "90" .. toHex(ledID) .. "xx"
		return mask
	end

	---------- Define MCU Buttons ----------

	local function defineMCUInputs()
		local inputDefs =
		{
			--- Track controls ---
			{ id = fromHex("08"), name = "Track Solo",   type = "button" },
			{ id = fromHex("10"), name = "Track Mute",   type = "button" },
			{ id = fromHex("00"), name = "Track Record", type = "button" },
			{ id = fromHex("4a"), name = "Track Read",   type = "button" },
			{ id = fromHex("4b"), name = "Track Write",  type = "button" },
			--- Global controls ---
			{ id = fromHex("50"), name = "Save",         type = "button" },
			{ id = fromHex("57"), name = "In",           type = "button" },
			{ id = fromHex("58"), name = "Out",          type = "button" },
			{ id = fromHex("59"), name = "Metro",        type = "button" },
			{ id = fromHex("51"), name = "Undo" },
			--- Transport controls ---
			{ id = fromHex("5b"), name = "Rewind",       type = "button" },
			{ id = fromHex("5c"), name = "Fast Forward", type = "button" },
			{ id = fromHex("5d"), name = "Stop",         type = "button" },
			{ id = fromHex("5e"), name = "Play",         type = "button" },
			{ id = fromHex("5f"), name = "Record",       type = "button" },
			{ id = fromHex("56"), name = "Loop",         type = "button" },
			{ id = fromHex("62"), name = "Left Arrow"                    },
			{ id = fromHex("63"), name = "Right Arrow"                   },
			--- Select buttons ---
			{ id = fromHex("18"), name="Select 1",       type = "button" },
			{ id = fromHex("19"), name="Select 2",       type = "button" },
			{ id = fromHex("1a"), name="Select 3",       type = "button" },
			{ id = fromHex("1b"), name="Select 4",       type = "button" },
			{ id = fromHex("1c"), name="Select 5",       type = "button" },
			{ id = fromHex("1d"), name="Select 6",       type = "button" },
			{ id = fromHex("1e"), name="Select 7",       type = "button" },
			{ id = fromHex("1f"), name="Select 8",       type = "button" },
		}

		for k, v in pairs(inputDefs) do
			local itemName = v.name
			local itemID = v.id
			if (v.type == "button") then
				table.insert(globalItems,        { name = itemName, input = "button", output = "value"                                              })
				table.insert(globalAutoInputs,   { name = itemName, pattern = makeButtonMIDIInputMask(itemID), value = "x/127"                      })
				table.insert(globalAutoOutputs,  { name = itemName, pattern = makeLEDMIDIOutputMask(itemID), x = "value*(127-(mode-1)*126)*enabled" })
			else
				table.insert(globalItems,        { name = itemName, input = "button"                                                                })
				table.insert(globalAutoInputs,   { name = itemName, pattern = makeButtonMIDIInputMask(itemID), value = "x/127"                      })
			end
		end
	end


	--------------------------------------------------------------------------------------------------------------

	defineMCUInputs()
	
	remote.define_items(globalItems)
	remote.define_auto_inputs(globalAutoInputs)
	remote.define_auto_outputs(globalAutoOutputs)
end
