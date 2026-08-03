return {
  {
    "erichlf/devcontainer-cli.nvim",
    main = "devcontainer-cli",
    dependencies = { "akinsho/toggleterm.nvim" },
    cmd = {
      "DevcontainerUp",
      "DevcontainerConnect",
      "DevcontainerExec",
      "DevcontainerDown",
      "DevContainerToggle",
    },
    keys = {
      { "<leader>Ds", "<cmd>DevcontainerUp<cr>", desc = "Devcontainer Start" },
      { "<leader>Da", "<cmd>DevcontainerConnect<cr>", desc = "Devcontainer Attach" },
    },
    opts = {
      toplevel = true,
      remove_existing_container = false,
      dotfiles_repository = "https://github.com/agentcluck77/dotfiles.git",
      dotfiles_branch = "main",
      dotfiles_targetPath = "~/dotfiles",
      dotfiles_installCommand = "install-devcontainer.sh",
      shell = "bash",
      nvim_binary = "nvim",
    },
  },
}
