-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
vim.opt.wrap = true -- Enable line wrap
vim.opt.winbar = "%=%m %f"
vim.opt.list = true
vim.opt.listchars = {
    space = "·", -- Replace spaces with a dot (·)
    eol = "↴", -- Show end-of-line character
    tab = "→ ", -- Show tab with an arrow
    trail = "•", -- Show trailing spaces as a dot
}
vim.opt.tabstop = 4 -- Number of spaces tabs count for
vim.g.have_nerd_font = true
