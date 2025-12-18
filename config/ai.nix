{...}: {
  plugins.sidekick = {
    enable = true;
    settings = {
      nes = {
        enabled = false;
      };
    };
  };

  keymaps = [
    {
      mode = "n";
      key = "<leader>aa";
      action = ":Sidekick cli toggle<cr>";
      options.desc = "Toggle Sidekick";
    }
    {
      mode = "n";
      key = "<leader>ap";
      action = ":Sidekick cli prompt<cr>";
      options.desc = "Sidekick Prompt";
    }
  ];
}
