local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local lazyrepo = "https://github.com/folke/lazy.nvim.git"
    local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
    if vim.v.shell_error ~= 0 then
        vim.api.nvim_echo({
            { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
            { out, "WarningMsg" },
            { "\nPress any key to exit..." },
        }, true, {})
        vim.fn.getchar()
        os.exit(1)
    end
end

vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
    spec = {
        -- add LazyVim and import its plugins
        { "LazyVim/LazyVim", import = "lazyvim.plugins" },
        -- import/override with your plugins
        { import = "plugins" },
    },
    defaults = {
        -- By default, only LazyVim plugins will be lazy-loaded. Your custom plugins will load during startup.
        -- If you know what you're doing, you can set this to `true` to have all your custom plugins lazy-loaded by default.
        lazy = false,
        -- It's recommended to leave version=false for now, since a lot the plugin that support versioning,
        -- have outdated releases, which may break your Neovim install.
        version = false, -- always use the latest git commit
        -- version = "*", -- try installing the latest stable version for plugins that support semver
    },
    install = { colorscheme = { "tokyonight", "habamax", "catppuccin" } },
    checker = {
        enabled = true, -- check for plugin updates periodically
        notify = false, -- notify on update
    }, -- automatically check for plugin updates
    performance = {
        rtp = {
            -- disable some rtp plugins
            disabled_plugins = {
                "gzip",
                -- "matchit",
                -- "matchparen",
                -- "netrwPlugin",
                "tarPlugin",
                "tohtml",
                "tutor",
                "zipPlugin",
            },
        },
    },
})

-- Setup for basedpyright
require("lspconfig").basedpyright.setup({
    settings = {
        basedpyright = {
            analysis = {
                diagnosticMode = "openFilesOnly", --  ["openFilesOnly", "workspace"]:
                inlayHints = {
                    callArgumentNames = true,
                },
            },
        },
    },
})

-- Schema storee for jsonls
require("lspconfig").jsonls.setup({
    settings = {
        json = {
            schemas = require("schemastore").json.schemas(),
            validate = { enable = true },
        },
    },
})

-- Schema store for yamlls
require("lspconfig").yamlls.setup({
    settings = {
        yaml = {
            schemaStore = {
                -- You must disable built-in schemaStore support if you want to use
                -- this plugin and its advanced options like `ignore`.
                enable = false,
                -- Avoid TypeError: Cannot read properties of undefined (reading 'length')
                url = "",
            },
            schemas = require("schemastore").yaml.schemas({
                replace = {
                    -- Overide trafeik v2 schema with v3
                    ["Traefik v3"] = {
                        description = "Traefik v3 YAML configuration file",
                        fileMatch = { "traefik.yml", "traefik.yaml" },
                        name = "Traefik v3",
                        url = "https://json.schemastore.org/traefik-v3.json",
                    },
                    ["Traefik v3 File Provider"] = {
                        description = "Traefik v3 Dynamic Configuration File Provider",
                        fileMatch = {
                            "services.yml",
                            "services.yaml",
                            "middlewares.yml",
                            "middlewares.yaml",
                            "tls.yml",
                            "tls.yaml",
                        },
                        name = "Traefik v3 File Provider",
                        url = "https://json.schemastore.org/traefik-v3-file-provider.json",
                    },
                },
            }),
        },
    },
})
