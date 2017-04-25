zh = require("zettel_handler")

--- Little helper used in debugging
-- Prints out a table's contents with indentation
function tprint(tab, indent)
  if not indent then indent = 0 end
  for k, v in pairs(tab) do
    formatstring = string.rep("  ", indent) .. k .. ": "
    if type(v) == "table" then
      print(formatstring)
      tprint(v, indent+1)
    else
      print(formatstring .. tostring(v))
    end
  end
end

local example_data = zh.loadfile("example-data.yaml")

zh.dumpfile(example_data, "example-data-output.yaml")
local files = example_data.files

tprint(zh.lineup(files))
