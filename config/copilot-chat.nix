{...}: {
  plugins.copilot-chat = {
    enable = true;

    settings = {
      mappings = {
        accept_diff = {
          insert = "<C-y>";
          normal = "<C-y>";
        };
        close = {
          insert = "<C-c>";
          normal = "q";
        };
        jump_to_diff = {
          normal = "gj";
        };
        quickfix_diffs = {
          normal = "gq";
        };
        reset = {
          insert = "<C-l>";
          normal = "<C-l>";
        };
        show_context = {
          normal = "gc";
        };
        show_diff = {
          normal = "gd";
        };
        show_help = {
          normal = "gh";
        };
        show_info = {
          normal = "gi";
        };
        submit_prompt = {
          insert = "<C-s>";
          normal = "<CR>";
        };
        toggle_sticky = {
          detail = "Makes line under cursor sticky or deletes sticky line.";
          normal = "gr";
        };
        yank_diff = {
          normal = "gy";
          register = "\"";
        };
      };
    };
  };

  keymaps = [
    {
      mode = ["n" "v"];
      key = "<leader>aa";
      action = "<cmd>CopilotChatToggle<CR>";
      options.desc = "Format file or range (in visual mode)";
    }
  ];
}
