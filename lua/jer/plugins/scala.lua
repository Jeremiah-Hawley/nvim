return {
  {
    "scalameta/nvim-metals",
    dependencies = { "nvim-lua/plenary.nvim" },
    ft = { "scala", "sbt" },
    config = function()
      local metals_config = require("metals").bare_config()

      metals_config.on_attach = function(_, bufnr)
        local opts = { noremap = true, silent = true, buffer = bufnr }
        vim.keymap.set("n", "K",          vim.lsp.buf.hover,       opts)
        vim.keymap.set("n", "gd",         vim.lsp.buf.definition,  opts)
        vim.keymap.set("n", "gr",         vim.lsp.buf.references,  opts)
        vim.keymap.set("n", "gi",         vim.lsp.buf.implementation, opts)
        vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename,      opts)
        vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
        vim.keymap.set("n", "<leader>f",  vim.lsp.buf.format,      opts)
        vim.keymap.set("n", "[d",         vim.diagnostic.goto_prev, opts)
        vim.keymap.set("n", "]d",         vim.diagnostic.goto_next, opts)
      end

      metals_config.settings = {
        showImplicitArguments = true,
        excludedPackages = { "akka.actor.typed.javadsl", "com.github.swagger.akka.javadsl" },
      }

      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "scala", "sbt" },
        callback = function()
          require("metals").initialize_or_attach(metals_config)
        end,
      })
    end,
  },
}
