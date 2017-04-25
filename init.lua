-- Libraries
--local yaml = require("zettels.zettel_handler")
--local basedir = _USERHOME .. '/modules/zettels/examples/'
local basedir = ""
local columns = {'Title', 'File', 'Tags'}
local examples = {'File 1', 'file1.md', 'example, first, test',
                  'File 2', 'file2.md', 'example, second',
                  'File 3', 'file3.md', 'example, third',
                  'File 4', 'subdir/file4.md', 'example, fourth'}

--- Little helper used in debugging
-- Prints out a table's contents with indentation
local function tprint (tbl, indent)
  if not indent then indent = 0 end
  for k, v in pairs(tbl) do
    formatting = string.rep("  ", indent) .. k .. ": "
    if type(v) == "table" then
      ui.print(formatting)
      tprint(v, indent+1)
    else
      ui.print(formatting .. tostring(v))
    end
  end
end

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

--- Search operations on the Zettel index
-- It opens the selected file(s) in Textadept. 
-- @param searchcolumns String defining the column that is to be searched. Must be one of 
--                      the index' column entries, e.g. 'Title' or 'Tags'. Default ist 'Title'
local function search_zettel(searchcolumn)
    searchcolumn = searchcolumn or 'Title'
    
    -- The dialog box needs the searchcolumn by its number, so let's find it.
    columnnumber = get_index_of(columns, searchcolumn)
        
    -- Call the dialog
    button_or_exit, zettels = ui.dialogs.filteredlist{
                            title = 'Search Zettel by ' .. searchcolumn, 
                            columns = columns,
                            search_column = columnnumber,
                            items = examples, 
                            select_multiple=true, 
                            string_output=true,
                            output_column=get_index_of(columns, 'File')}
    
    if button_or_exit ~= "delete" then
        for i, zettel in pairs(zettels) do
            io.open_file(basedir .. zettel)
        end
    end
end

local function search_fulltext()
    --TODO
    ui.print("search_fulltext is not Implemented, yet")
end

local function testoutstuff()
    ui.print("Testing stuff out")
end

-- Define Zettels Menu
local zettels_menu = {
  title = 'Zettels',
  {'Search by Title',       function() search_zettel('Title') end},
  {'Search by Filename',    function() search_zettel('File') end},
  {'Search by Tag',         function() search_zettel('Tags') end},
  {'Search full text',      function() search_fulltext() end},
  {'Test out Stuff', function() testoutstuff()  end}
}

-- Define Zettels Context Menu
local zettels_context_menu = {
    title = 'Zettels',
    {'Test out Stuff', function() testoutstuff() end}
}

-- Enable the Module
local function enable(zettel_dir)
    if not zettel_dir then
        basedir = _USERHOME .. '/modules/zettels/examples/'
    else
        basedir = zettel_dir
    end
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
    enable = enable
}

return M
