--- A module handling the Zettel index
--[[
It acts as a convenience wrapper around lyaml and does some table conversions
for Textadept.
]] 

-- ###########################################################################
-- Check for lyaml
-- ###########################################################################
--local lyaml = require "yaml.lyaml"

local lyaml = lyaml
-- If it's not available globally, the local lyaml will now be nil
-- In that case, we look for other options

if not lyaml then
    -- maybe Textadept's yaml-Module is present, which includes lyaml
    if pcall(require, "yaml.lyaml") then
        lyaml = require "yaml.lyaml"
    else
    -- otherwise, let's hope the user has made a working lyaml.lua available
    -- to Textadept
        lyaml = require "lyaml"
    end
    -- if that isn't the case, either, Textadept will complain at startup.
end

--###########################################################################
-- Wrappers around lyaml
-- ###########################################################################

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

-- ###########################################################################
-- Some stuff to work with the Zettels
-- ###########################################################################
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
    -- if tags was empty, s is still nil. But in that case, we want to return
    -- an empty string.
    return s or ""
end

--- Lines up structured data from yaml in a table format used by Textadept's ui.dialogs.filteredlist function
local function lineup(files)
    -- In the dialog, we want to show the files ordered by filename. Thus 
    -- we have to sort the keys of files first:
    local keys = {}
    for k,v in pairs(files) do
        table.insert(keys, k)
    end
    table.sort(keys)
    
    -- Now, for what this function is actually supposed to be doing, 
    -- we iterate over keys and use them to read the values of files.
    local lined_up = {}
    for _, k in pairs(keys) do
        -- We want to fill an array with 'Title', 'File', and 'Tags'
        lined_up[#lined_up+1] = files[k].title
        lined_up[#lined_up+1] = k
        lined_up[#lined_up+1] = make_tag_string(files[k].tags)
    end
    return lined_up
end

--- Returns the followups of a given Zettel
-- @index  Table containing the index.
-- @zettel String containing the file path of the Zettel relative to the 
--         basedir, as defined in the index.
local function get_followups(index, zettel)
    return index.files[zettel].followups
end

--- Returns the targets of a given Zettel
-- @index  Table containing the index.
-- @zettel String containing the file path of the Zettel relative to the 
--         basedir, as defined in the index.
local function get_targets(index, zettel)
    return index.files[zettel].targets
end

--- Returns the sources linking to a given Zettel
-- @zettel_absolute String containing the absolute file path of the Zettel
local function get_sources(zettel_absolute)
    local filehandle = io.popen("zettels -i " .. zettel_absolute)
    local sources = {}
        
    if filehandle then
        for line in filehandle:lines() do
            sources[#sources+1] = line 
        end
        filehandle:close()
    end
    
    return sources
end


--- Returns the tags of a given Zettel
-- @index  Table containing the index.
-- @zettel String containing the file path of the Zettel relative to the 
--         basedir, as defined in the index.
local function get_tags(index, zettel)
    return index.files[zettel].tags
end


-- ###########################################################################
-- Public interface
-- ###########################################################################
M = {
    load = load,
    dump = dump,
    loadfile = loadfile,
    dumpfile = dumpfile,
    lineup = lineup,
    get_followups = get_followups,
    get_targets = get_targets,
    get_sources = get_sources,
}

return M