--[[
    Surface:    Arturia Keylab mkII Drum Pads
    Developer:  Ciathyza
    Version:    2.0.0
    Date:       2022/02/22
]]


----------------------------------------------- Remote Init -------------------------------------------------------

function remote_init()
    local itemsPads =
    {
        { name = "Keyboard",         input = "keyboard"                  },
        { name = "Channel Pressure", input = "value", min = 0, max = 127 }
    }

    local inputsPads =
    {
        { pattern = "99 xx 00",      name = "Keyboard", value = "0", note = "x", velocity = "64" },
        { pattern = "<100x>9 yy zz", name = "Keyboard"                                           },
        { pattern = "a9 xx",         name = "Channel Pressure"                                   }
    }

    remote.define_items(itemsPads)
    remote.define_auto_inputs(inputsPads)
end


----------------------------------------------- Control Input Logic -----------------------------------------------

function remote_probe()
    local controlRequest =  "F0 7E 7F 06 01 F7"
    local controlResponse = "F0 7E 7F 06 02 00 20 6B 02 00 05 64 ?? ?? ?? ?? F7"
    return { request = controlRequest, response = controlResponse }
end
