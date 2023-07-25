unused_args = false
allow_defined_top = true

globals = {
    "minetest",
    "airutils",
    "core",
    "player_api",
    "math.sign",
}

read_globals = {
    string = {fields = {"split"}},
    table = {fields = {"copy", "getn"}},

    -- Builtin
    "vector", "ItemStack",
    "dump", "DIR_DELIM", "VoxelArea", "Settings",

    -- MTG
    "default", "sfinv", "creative",
}

