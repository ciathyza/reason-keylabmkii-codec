-- Reason ReMote Codec for Arturia Keylab MkII Keyboard.
-- Version 1.2
-- V1.0 Timothy Rylatt - 15/11/2020
-- V1.2 Changes Ciathyza 14/02/2022


----------------------------------------------- Remote Init -------------------------------------------------------

function remote_init()
	local itemsKeyboard =
	{
		{ name = "Keyboard",         input ="keyboard"                },
		{ name = "Channel Pressure", input ="value", min=0, max=127   },
		{ name = "Mod Wheel",        input ="value", min=0, max=127   },
		{ name = "Pitch Bend",       input ="value", min=0, max=16384 },
		{ name = "Expression",       input ="value", min=0, max=127   },
		{ name = "Breath",           input ="value", min=0, max=127   },
		{ name = "Damper Pedal",     input ="value", min=0, max=127   },
	}

	local inputsKeyboard =
	{
		{ pattern = "e? xx yy",      name = "Pitch Bend", value = "y*128 + x" },
		{ pattern = "b0 01 xx",      name = "Mod Wheel"                       },
		{ pattern = "b0 0b xx",      name = "Expression"                      },
		{ pattern = "b0 02 xx",      name = "Breath"                          },
		{ pattern = "d0 xx",         name = "Channel Pressure"                },
		{ pattern = "b0 40 xx",      name = "Damper Pedal"                    },
		{ pattern = "<100x>0 yy zz", name = "Keyboard"                        },
	}

	remote.define_items(itemsKeyboard)
	remote.define_auto_inputs(inputsKeyboard)
end


----------------------------------------------- Control Input Logic -----------------------------------------------

function remote_probe()
	local controlRequest="F0 7E 7F 06 01 F7"
	local controlResponse="F0 7E 7F 06 02 00 20 6B 02 00 05 64 ?? ?? ?? ?? F7"
	return { request=controlRequest, response=controlResponse }
end
