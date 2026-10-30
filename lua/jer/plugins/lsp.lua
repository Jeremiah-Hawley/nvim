return {
  {
    "neovim/nvim-lspconfig",
    ft = { "python", "c", "cpp", "java", "javascript", "javascriptreact", "typescript", "typescriptreact" },
    config = function()
      vim.lsp.enable({ "pyright", "clangd", "jdtls", "ts_ls", "texlab" })
    end,
  },

  {
    "williamboman/mason-lspconfig.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "pyright", "clangd", "jdtls", "ts_ls" })
    end,
  },
}
