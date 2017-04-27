# ta-zettels

Still heavily under development.

## Installation

Clone (or download and unzip) the repository into the modules directory inside
your Textadept userhome, e.g.:

```
cd ~/.textadept/modules
git clone https://github.com/sthesing/ta-zettels.git
```

In Textadept's `init.lua`, import and enable it. 
If you just want to try it out, call the `enable()`-function without arguments.
The module will then use some example zettels in the "examples"-directory and
the file "example-data.yaml" as index.
```
local zettels = require('ta-zettels')
zettels.enable()
```

If you want to use it with your own Zettelkasten, you have to tell the 
`enable()`-function where to find your stuff.

The `enable()`-function takes two arguments:

    1. `zettel_dir` - Absolute path to the directory where your Zettels are.
    2. `indexfile` - Absolute path to the index file of your Zettelkasten. 

For example:
```
local zettels = require('ta-zettels')
zettels.enable("/home/username/MyZettelkasten/", "/home/username/.config/Zettels/index.yaml")
```

## Usage

- A new menu entry "Zettels" is added to Textadept, it should be rather 
  self-explanatory.
- If you have a zettel opened in Textadept, right-click and select the 
  corresponding entry from the context-menu to show (and later open) the link 
  targets or follow-ups of the current zettel.
  
## Used libraries
- [lyaml](https://github.com/gvvaughan/lyaml) – LibYAML binding for Lua
  
  For ta-zettels to work, Textadept needs to be able to access lyaml.
  Either you install lyaml in your system and modify the global 
  `package.path` and `package.cpath` in Textadept's `init.lua` as needed.
  
  Alternatively, you can put the necessary files into your Textadept 
  \_USERHOME directory.
  
  The easiest way is to use Textadept's own YAML-Module. That comes with
  a working installation of lyaml. ta-zettels will work with it, out of the
  box.