return {
  {
    "lervag/vimtex",
    ft = "tex",
    init = function()
      vim.g.vimtex_view_method = "sioyek"
      -- ponytail: dev nvim build reads as older than it is to vimtex's gate; drop this once nvim >=0.12.4 lands
      vim.g.vimtex_version_check = 0
      vim.g.vimtex_syntax_conceal = {
        accents = 1,
        ligatures = 1,
        cites = 1,
        fancy = 1,
        spacing = 1,
        greek = 1,
        math_bounds = 1,
        math_delimiters = 1,
        math_fracs = 1,
        math_super_sub = 1,
        math_symbols = 1,
        sections = 0,
        styles = 1,
      }
    end,
    config = function()
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "tex",
        callback = function()
          vim.opt_local.conceallevel = 2
          vim.opt_local.concealcursor = ""
        end,
        desc = "LaTeX conceal settings",
      })
    end,
  },

  -- Live preview: https://github.com/let-def/texpresso.vim
  -- requires building the texpresso binary yourself and setting
  -- require("texpresso").texpresso_path before it'll do anything.
  {
    "let-def/texpresso.vim",
    ft = "tex",
  },

  {
    "neovim/nvim-lspconfig",
    ft = "tex",
  },

  {
    "williamboman/mason-lspconfig.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      table.insert(opts.ensure_installed, "texlab")
    end,
  },
}
