return {
    "nvim-treesitter/nvim-treesitter",
    event = { "BufReadPre", "BufNewFile" },
    build = ":TSUpdate",
    dependencies = {
        "windwp/nvim-ts-autotag",
    },
    config = function()
        local treesitter = require("nvim-treesitter.configs")
        local parser_config = require("nvim-treesitter.parsers").get_parser_configs()

        parser_config.nasm = {
            install_info = {
                url = "https://github.com/naclsn/tree-sitter-nasm",
                files = { "src/parser.c" },
                branch = "main",
            },
            filetype = "masm",
        }

        vim.filetype.add({
            extension = {
                asm = "masm",
                masm = "masm",
            },
        })

        treesitter.setup({
            highlight = {
                enable = true,
                additional_vim_regex_highlighting = false,
            },
            indent = { enable = true },
            autotag = {
                enable = true,
            },
            ensure_installed = {
                "cpp",
                "json",
                "javascript",
                --"typescript",
                "tsx",
                "yaml",
                "html",
                "css",
                "markdown",
                --"markdown_inline",
                "bash",
                "lua",
                "vim",
                --"dockerfile",
                "gitignore",
                "c",
                "rust",
                --"java",
                "nasm",
            },
            fold = {
                enable = true,
                disable = { "markdown" },
            },
            incremental_selection = {
                enable = true,
                keymaps = {
                    init_selection = "<C-space>",
                    node_incremental = "<C-space>",
                    scope_incremental = false,
                    node_decremental = "<bs>",
                },
            },
            rainbow = {
                enable = true,
                disable = { "html" },
                extended_mode = false,
                max_file_lines = nil,
            },
            context_commentstring = {
                enable = true,
                enable_autocmd = false,
            },
        })
    end,
}
