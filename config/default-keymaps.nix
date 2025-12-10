{...}: {
  plugins.snacks.enable = true;

  keymaps = [
    {
      mode = ["n"];
      key = "<leader>bd";
      action = ":lua Snacks.bufdelete()<CR>";
      options.desc = "Delete current buffer";
    }
    {
      mode = ["n"];
      key = "<leader>bo";
      action = ":lua Snacks.bufdelete.other()<CR>";
      options.desc = "Delete other buffers";
    }
  ];
}
