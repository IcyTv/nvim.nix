{...}: {
  plugins.sidekick = {
    enable = true;
    settings = {
      nes = {
        enable = false;
      };
    };
  };

  keymaps = [
    {
      mode = "n";
      key = "<leader>aa";
      command = ":Sidekick toggle<cr>";
      options.desc = "Toggle Sidekick";
    }
    {
      mode = "n";
      key = "<leader>ap";
      command = ":Sidekick prompt<cr>";
      options.desc = "Sidekick Prompt";
    }
  ];
}
