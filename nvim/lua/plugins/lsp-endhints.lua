return {
    "chrisgrieser/nvim-lsp-endhints",
    event = "LspAttach",
    opts = {}, -- required, even if empty
    config = function()
        require("lsp-endhints").setup({
            icons = {
                Type = "󰜁 ",
                Parameter = "󰏪 ",
                Offspec = " ", -- hint kind not defined in official LSP spec
                Unknown = " ", -- hint kind is nil
            },
            label = {
                truncateAtChars = 40,
                padding = 1,
                marginLeft = 0,
                sameKindSeparator = ", ",
            },
            extmark = {
                priority = 50,
            },
            autoEnableHints = true,
        })
    end,
}
