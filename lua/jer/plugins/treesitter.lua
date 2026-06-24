-- nvim-treesitter (new `main` branch rewrite, post-2026)
-- NOTE: this branch requires Neovim 0.12+ (nightly), tree-sitter-cli, and a C compiler.
-- This plugin does NOT support lazy-loading, so `lazy = false` is required.

local ensure_installed = {
  "cpp",
  "python",
  "json",
  "javascript",
  -- "typescript",
  "tsx",
  "yaml",
  "html",
  "css",
  "markdown",
  -- "markdown_inline",
  "bash",
  "lua",
  "vim",
  -- "dockerfile",
  "gitignore",
  "c",
  "rust",
  -- "java",
  "nasm",
}

-- Filetypes to enable treesitter features for (highlight, indent, fold)
local ft_list = {
  "cpp",
  "py",
  "python",
  "json",
  "javascript",
  "typescriptreact",
  "yaml",
  "html",
  "css",
  "markdown",
  "bash",
  "lua",
  "vim",
  "gitignore",
  "c",
  "rust",
  "masm", -- nasm, mapped via vim.filetype.add below
}

return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = ":TSUpdate",
    dependencies = {
      "windwp/nvim-ts-autotag",
    },
    init = function()
      -- Register the custom nasm parser before TSUpdate runs
      vim.api.nvim_create_autocmd("User", {
        pattern = "TSUpdate",
        callback = function()
          local parsers = require("nvim-treesitter.parsers")
          parsers.nasm = {
            install_info = {
              url = "https://github.com/naclsn/tree-sitter-nasm",
              files = { "src/parser.c" },
              branch = "main",
            },
            filetype = "masm",
          }
        end,
      })

      -- Map .asm / .masm extensions to the masm filetype
      vim.filetype.add({
        extension = {
          asm = "masm",
          masm = "masm",
        },
      })

      -- nasm's parser name differs from the "masm" filetype, so register it
      vim.treesitter.language.register("nasm", { "masm" })
    end,
    config = function()
      require("nvim-treesitter").setup({
        install_dir = vim.fn.stdpath("data") .. "/site",
      })

      -- Make sure everything in ensure_installed is actually installed
      require("nvim-treesitter").install(ensure_installed)

      -- Enable highlighting, indentation, and treesitter folding per-filetype
      vim.api.nvim_create_autocmd("FileType", {
        pattern = ft_list,
        callback = function()
          vim.treesitter.start()
          vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          vim.wo[0][0].foldexpr = "v:lua.vim.treesitter.foldexpr()"
          vim.wo[0][0].foldmethod = "expr"
        end,
      })

      -- markdown excluded from treesitter folding per original config
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "markdown",
        callback = function()
          vim.wo[0][0].foldmethod = "manual"
        end,
      })
    end,
  },
}
