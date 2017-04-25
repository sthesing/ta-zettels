--- A module handling the Zettel index
--[[
It acts as a convenience wrapper around lyaml and does some table conversions
for Textadept.
]] 
local lyaml = require "lyaml"

local function load(content)
    return lyaml.load(content)
end

local function dump(content)
    return lyaml.dump({content})
end

local function loadfile(filename)
    local file = io.input(filename)
    local content = file:read("*all")
    io.close(file)
    return load(content)
end

local function dumpfile(content, filename)
    local file = io.open(filename, "w+")
    io.output(file)
    io.write(dump(content))
    io.close(file)
end

--- Receives a list of strings and converts it to one comma-separated string
-- @param tags List of strings
local function make_tag_string(tags)
    local s = nil
    for k, v in pairs(tags) do
        if not s then
            s = tostring(v)
        else
            s = s .. ", " .. tostring(v)
        end
    end
    return s
end

--- Lines up structured data from yaml in a table format used by Textadept's ui.dialogs.filteredlist function
local function lineup(files)
    lined_up = {}
    for k, v in pairs(files) do
        -- We want to fill an array with 'Title', 'File', and 'Tags'
        lined_up[#lined_up+1] = v.title
        lined_up[#lined_up+1] = k
        lined_up[#lined_up+1] = make_tag_string(v.tags)
    end
    return lined_up
end

M = {
    load = load,
    dump = dump,
    loadfile = loadfile,
    dumpfile = dumpfile,
    lineup = lineup
}

return M