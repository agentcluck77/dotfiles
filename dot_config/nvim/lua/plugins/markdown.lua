vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    vim.opt_local.wrap = true
  end,
})

return {
  -- disable LazyVim's default markdown renderer to avoid conflicts
  { "MeanderingProgrammer/render-markdown.nvim", enabled = false },

  {
    "OXY2DEV/markview.nvim",
    lazy = false,
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
    opts = {},
  },

  -- mermaid treesitter parser for syntax highlighting inside mermaid blocks
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, { "mermaid" })
    end,
  },
}
