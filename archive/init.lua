-- Libraries
local zh = require("zettels.zettel_handler")
local path = require("path")

-- Just dummies, they get set by enable()
local basedir    = nil
local index_path = nil
-- Another dummy, gest set by refresh_index(), which is initially called by enable()
local index      = nil

-- Columns for Textadept's filteredlist dialog
local columns = {'Title', 'File', 'Tags'}

--- Little helper to find the index of a column, e.g. 'Title'.
-- It's needed 
-- because Textadept's ui.dialog.filteredlist function expects the numbers 
-- of columns and I don't want to hardcode them, so nothing breaks when 
-- the format of the Zettelkasten index shoud change in the future.
-- @param t Array containing the column headers
-- @param s String to be searched for, e.g. 'Title' or 'Tags'
local function get_index_of(t, s)
    for i,v in pairs(t) do
        if v == s then
            return i
        end
    end    
end

--- Shows the index or a part of it in Textadepts filteredlist dialog and opens
--the selected file
local function open_from_filteredlist(zettels,
                                      title, 
                                      columns,
                                      search_column, 
                                      output_column)
    local button_or_exit, selection = ui.dialogs.filteredlist{
                            title = title,
                            columns = columns,
                            search_column = search_column,
                            items = zh.lineup(zettels),
                            select_multiple=true, 
                            string_output=true,
                            output_column=get_index_of(columns, 'File')}
                            
    if button_or_exit ~= "delete" then
        for i, zettel in pairs(selection) do
            io.open_file(basedir .. zettel)
        end
    end
end

--- Search operations on the Zettel index
-- It opens the selected file(s) in Textadept. 
-- @param searchcolumns String defining the column that is to be searched. Must be one of 
--                      the index' column entries, e.g. 'Title' or 'Tags'. Default ist 'Title'
local function search_zettel(searchcolumn)
    local searchcolumn = searchcolumn or 'Title'
    
    -- The dialog box needs the searchcolumn by its number, so let's find it 
    -- by using get_index_of(columns, searchcolumn)
    open_from_filteredlist(index.files, 
                           'Search Zettel by ' .. searchcolumn,
                           columns,
                           get_index_of(columns, searchcolumn))
end

local function search_followups(filename)
    show_followups(index, filename)
end

local function show_items(index, absolutepath, f, parttitle)
    --[[
    TODO
    - We might still be in trouble if the path contains "../"'
    ]]
    
    -- To be sure that absolutepath is really a full and normalized path
    absolutepath = path.fullpath(absolutepath)
    
    local relpath = string.gsub(absolutepath, basedir, "")
    local reldir = path.dirname(relpath)
    
    
    local items = {}
    for _, file in pairs(f(index, relpath)) do
        items[path.join(reldir, file)] = index.files[path.join(reldir, file)]
    end
        
    local button_or_exit, zettels = ui.dialogs.filteredlist{
                              title         = parttitle .. relpath,
                              columns       = columns,
                              search_column = get_index_of(columns, 'Title'),
                              items         = zh.lineup(items),
                              select_multiple=true, 
                              string_output=true,
                              output_column=get_index_of(columns, 'File')
                            }

    if button_or_exit ~= "delete" then
        for i, zettel in pairs(zettels) do
            io.open_file(basedir .. zettel)
        end
    end
end

local function show_followups(index, absolutepath)
    show_items(index, absolutepath, zh.get_followups, 'Followups of ')
    
end

local function show_targets(index, absolutepath)
    show_items(index, absolutepath, zh.get_targets, 'Targets of ')
end

local function show_sources(index, absolutepath)
    local sources = zh.get_sources(absolutepath)
    
    absolutepath = path.fullpath(absolutepath)
    local relpath = string.gsub(absolutepath, basedir, "")
    local reldir = path.dirname(relpath)
        
        
    local items = {}
    for _, file in pairs(sources) do
        items[file] = index.files[file]
    end
    
    local button_or_exit, zettels = ui.dialogs.filteredlist{
        title         = 'Sources of ' .. relpath,
        columns       = columns,
        search_column = get_index_of(columns, 'Title'),
        items         = zh.lineup(items),
        select_multiple=true, 
        string_output=true,
        output_column=get_index_of(columns, 'File')
        }
    
        if button_or_exit ~= "delete" then
            for i, zettel in pairs(zettels) do
                io.open_file(basedir .. zettel)
            end
    end
    
end

local function refresh_index()
    --call zettels to update the index
    local status_code = os.execute("zettels -su")
    if not status_code then
        ui.print("Something went wrong when executing the system command 'zettels'")
    end
    --reload it
    index = zh.loadfile(index_path)
end

-- Define Zettels Menu
local zettels_menu = {
  title = 'Zettels',
  {'Search by Title',       function() search_zettel('Title') end},
  {'Search by Filename',    function() search_zettel('File') end},
  {'Search by Tag',         function() search_zettel('Tags') end},
  {'Refresh index',         function() refresh_index() end},
}

-- Define Zettels Context Menu
local zettels_context_menu = {
    title = 'Zettels',
    {'Open followups', function() show_followups(index, buffer.filename) end},
    {'Open targets',   function() show_targets(index, buffer.filename) end},
    {'Open sources', function() show_sources(index, buffer.filename) end},
    --{'Open mother zettel', function() TODO end},
    --{'Link to other zettel', function() TODO end},
    --{'Copy link to self to clipboard', function() TODO end},
}

-- Enable the Module
local function enable(zettel_dir, indexfile)
    -- set three module-wide variables: basdir, index_path and index
    if not zettel_dir then
        basedir = _USERHOME .. '/modules/zettels/examples/'
    else
        basedir = zettel_dir
    end
    -- Get the index
    if not indexfile then
        indexfile = basedir .. "../" .. "example-data.yaml"
    end

    index_path = indexfile
    -- index variable is set by refresh_index
    refresh_index()
    
    -- Activate Zettels Menu
    local menu = textadept.menu.menubar
    menu[#menu + 1] = zettels_menu
    -- And the Zettels Context Menu
    events.connect(events.INITIALIZED, function()
        local context_menu = textadept.menu.context_menu
        context_menu[#context_menu+1] = zettels_context_menu
    end)
end

--- ##########################################################################
--- Public Interface
--- ##########################################################################
local M = {
    enable = enable,
    _VERSION = '0.5.0',
    search_zettel = search_zettel,
    search_followups = search_followups,
}

return M
