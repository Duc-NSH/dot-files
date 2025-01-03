-- ~/.config/nvim/lua/plugins/neotree.lua
return {
    "nvim-neo-tree/neo-tree.nvim",
    opts = {
        filesystem = {
            filtered_items = {
                visible = true, -- Show hidden files by default
                hide_dotfiles = false, -- Do not hide dotfiles
                hide_gitignored = false, -- Optionally show gitignored files
            },
        },
    },
}
