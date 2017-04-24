--- A convenience wrapper for lyaml
--[[
For some reason, when you load a yaml file using lyaml, it stores
it in a table with the key '1'. The corresponding value is a table
containing the actual data described in the yaml file.

This module is just a wrapper around lyaml for users who'd like their 
yaml-parser to behave differently.
A table corresponds to the yaml-file and vice versa.

So it's lyaml minus the 1.
It doesn't support the whole lyaml-data, just what I use, regularly. 
I'll add them as needed.

But it adds a few more convenience-functions.
]] 
local lyaml = require "lyaml"
M = {}

function M.load(content)
    return lyaml.load(content, {all = true})[1]
end

function M.dump(content)
    plusone = {}
    plusone[1] = content
    return lyaml.dump(plusone, {all = true})
end

function M.loadfile(filename)
    file = io.input(filename)
    content = file:read("*all")
    io.close(file)
    return M.load(content)
end

function M.dumpfile(content, filename)
    file = io.open(filename, "w+")
    io.output(file)
    io.write(M.dump(content))
    io.close(file)
end

return M