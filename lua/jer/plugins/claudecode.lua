return {
  {
    "coder/claudecode.nvim",
    dependencies = {
      "folke/snacks.nvim", -- Optional: Provides UI picker benefits
    },
    opts = {
      -- Custom configurations go here
    },
    keys = {
      { "<leader>ac", "<cmd>ClaudeCode<cr>", desc = "Toggle Claude Code Window" },
      { "<leader>as", ":ClaudeCodeSend<cr>", mode = "v", desc = "Send Selection to Claude" },
    },
  }
}

