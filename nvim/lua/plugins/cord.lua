return {
    "vyfor/cord.nvim",
    branch = "master",
    build = ":Cord update",
    config = function()
        require("cord").setup({
            idle = {
                enabled = false,
                timeout = 3000,
                details = "Floating in Thought Space",
                tooltip = "☁️",
            },
            assets = {
                -- 🐍 Python
                [".py"] = {
                    icon = "python",
                    tooltip = "Python",
                    text = "🐍 Crafting with Pythonic Elegance",
                },
                [".env"] = {
                    icon = "environment", -- Use an appropriate icon or a generic one
                    tooltip = "Environment Variables",
                    text = "🌍 Configuring the Environment Secrets",
                },
                -- 🌙 Lua
                [".lua"] = {
                    icon = "lua",
                    tooltip = "Lua",
                    text = "🌙 Scripting Under the Lua Moon",
                },
                -- ☕ Java
                [".java"] = {
                    icon = "java",
                    tooltip = "Java",
                    text = "☕ Brewing Some Java Code",
                },
                -- 💎 Ruby
                [".rb"] = {
                    icon = "ruby",
                    tooltip = "Ruby",
                    text = "💎 Polishing Ruby Gems",
                },
                -- 🚀 JavaScript
                [".js"] = {
                    icon = "javascript",
                    tooltip = "JavaScript",
                    text = "🚀 Making the Web Dynamic",
                },
                -- ⚛️ React (JavaScript XML)
                [".jsx"] = {
                    icon = "react",
                    tooltip = "React",
                    text = "⚛️ Reacting to Every Component",
                },
                -- 🌐 HTML
                [".html"] = {
                    icon = "html",
                    tooltip = "HTML",
                    text = "🌐 Structuring the Web",
                },
                -- 🎨 CSS
                [".css"] = {
                    icon = "css",
                    tooltip = "CSS",
                    text = "🎨 Painting the Web with CSS",
                },
                -- 🌀 TypeScript
                [".ts"] = {
                    icon = "typescript",
                    tooltip = "TypeScript",
                    text = "🌀 Typing with Precision",
                },
                -- 🛡️ C
                [".c"] = {
                    icon = "c",
                    tooltip = "C",
                    text = "🛡️ Building Foundations with C",
                },
                -- ⚙️ C++
                [".cpp"] = {
                    icon = "cpp",
                    tooltip = "C++",
                    text = "⚙️ Engineering Robust Solutions with C++",
                },
                -- 🐘 PHP
                [".php"] = {
                    icon = "php",
                    tooltip = "PHP",
                    text = "🐘 Serving Dynamic Web Pages",
                },
                -- 📝 Markdown
                [".md"] = {
                    icon = "markdown",
                    tooltip = "Markdown",
                    text = "📝 Writing Docs in Markdown",
                },
                -- 🧠 JSON
                [".json"] = {
                    icon = "json",
                    tooltip = "JSON",
                    text = "🧠 Structuring Data with JSON",
                },
                -- 🏗️ YAML
                [".yaml"] = {
                    icon = "yaml",
                    tooltip = "YAML",
                    text = "🏗️ Configuring with YAML",
                },
                -- 🛠️ Dockerfile
                ["Dockerfile"] = {
                    icon = "docker",
                    tooltip = "Docker",
                    text = "🐳 Shipping with Docker Containers",
                },
                -- 🌍 Go
                [".go"] = {
                    icon = "go",
                    tooltip = "Go",
                    text = "🌍 Going Further with Go",
                },
                -- 🐍 Shell Script
                [".sh"] = {
                    icon = "bash",
                    tooltip = "Shell Script",
                    text = "🐚 Automating with Shell Scripts",
                },
                -- 🔗 Rust
                [".rs"] = {
                    icon = "rust",
                    tooltip = "Rust",
                    text = "🔗 Forging with Rust",
                },
                -- 🛡️ C#
                [".cs"] = {
                    icon = "csharp",
                    tooltip = "C#",
                    text = "🛡️ Sharpening Code with C#",
                },
                -- 🧬 SQL
                [".sql"] = {
                    icon = "sql",
                    tooltip = "SQL",
                    text = "🧬 Querying the Database",
                },
                -- 🧑‍🎨 Figma
                [".fig"] = {
                    icon = "figma",
                    tooltip = "Figma",
                    text = "🎨 Designing Interfaces with Figma",
                },
                -- 📦 TOML
                [".toml"] = {
                    icon = "toml",
                    tooltip = "TOML",
                    text = "📦 Organizing Configurations with TOML",
                },
                -- 🗂️ XML
                [".xml"] = {
                    icon = "xml",
                    tooltip = "XML",
                    text = "🗂️ Structuring Data with XML",
                },
                -- 🛠️ Makefile
                ["Makefile"] = {
                    icon = "makefile",
                    tooltip = "Makefile",
                    text = "🛠️ Automating Builds with Makefile",
                },
                -- 🔍 Log
                [".log"] = {
                    icon = "log",
                    tooltip = "Log",
                    text = "🔍 Investigating Logs",
                },
                -- 📜 Plain Text
                [".txt"] = {
                    icon = "text",
                    tooltip = "Text",
                    text = "📜 Scribbling Notes",
                },
                -- 🎵 Audio Files
                [".mp3"] = {
                    icon = "audio",
                    tooltip = "Audio",
                    text = "🎵 Jamming to Audio Files",
                },
                -- 🎥 Video Files
                [".mp4"] = {
                    icon = "video",
                    tooltip = "Video",
                    text = "🎥 Watching Code Tutorials",
                },
                -- 🧩 Config Files
                [".conf"] = {
                    icon = "config",
                    tooltip = "Config",
                    text = "🧩 Tinkering with Configurations",
                },
            },
            text = {
                viewing = "👀 Viewing: %{file_name}",
                file_browser = "📂 Exploring Files in the Project",
                plugin_manager = "🧩 Managing Plugins",
                lsp_manager = "⚙️ Configuring LSP",
                docs = "📖 Reading Documentation",
                vcs = "🔄 Committing Changes to Version Control",
                notes = "📝 Taking Notes",
                dashboard = "🏠 Home Dashboard",
                workspace = "🚀 To Infinity and Beyond",
                terminal = "💻 Working in the Terminal",
                testing = "🧪 Running Tests",
                debugging = "🐞 Debugging Code",
                git = "🔗 Working with Git",
            },
        })
    end,
}
