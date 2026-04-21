return {
  {
    "williamboman/mason.nvim",
    opts = {},
  },
  {
    "williamboman/mason-lspconfig.nvim",
    opts = {
      ensure_installed = { "rust_analyzer" },
    },
  },
  {
    "mrcjkb/rustaceanvim",
    version = "^5",
    ft = { "rust" },
    init = function()
      vim.g.rustaceanvim = {
        server = {
          on_attach = function(_, bufnr)
            local opts = { noremap = true, silent = true, buffer = bufnr }
            vim.keymap.set("n", "K",          function() vim.cmd.RustLsp("hover_actions")  end, opts)
            vim.keymap.set("n", "<leader>ca", function() vim.cmd.RustLsp("codeAction")     end, opts)
            vim.keymap.set("n", "gd",         vim.lsp.buf.definition,                           opts)
            vim.keymap.set("n", "gr",         vim.lsp.buf.references,                           opts)
            vim.keymap.set("n", "gi",         vim.lsp.buf.implementation,                       opts)
            vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename,                               opts)
            vim.keymap.set("n", "<leader>f",  vim.lsp.buf.format,                               opts)
            vim.keymap.set("n", "[d",         vim.diagnostic.goto_prev,                         opts)
            vim.keymap.set("n", "]d",         vim.diagnostic.goto_next,                         opts)
          end,

          settings = {
            ["rust-analyzer"] = {
              checkOnSave = true,
              check = { command = "clippy" },
              inlayHints = { enable = true },
            },
          },
        },
      }
    end,
  },
}
