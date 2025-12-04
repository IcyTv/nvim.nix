{pkgs, ...}: {
  plugins.telescope = {
    enable = true;
    keymaps = {
      "<leader>," = {
        action = "buffers sort_mru = true sort_lastused=true";
        options.desc = "[,] Find existing buffers";
      };
      "<leader>/" = {
        action = "live_grep";
        options.desc = "[/] Grep (Root Dir)";
      };
      "<leader><space>" = {
        action = "find_files";
        options.desc = "[ ] Find Files (Root Dir)";
      };
      "<leader>fc" = {
        action = "";
        options.desc = "[f]ind [c]onfig files";
      };
      "<leader>fB" = {
        action = "buffers";
        options.desc = "[F]ind [B]uffers (all)";
      };
      "<leader>ff" = {
        action = "find_files";
        options.desc = "[f]ind [f]iles (all)";
      };
      "<leader>fg" = {
        action = "git_files";
        options.desc = "[f]ind [g]it files";
      };
      "<leader>fr" = {
        action = "oldfiles";
        options.desc = "[f]ind [r]ecent files";
      };

      "<leader>gc" = {
        action = "git_commits";
        options.desc = "Find [g]it [c]ommits";
      };
      "<leader>gs" = {
        action = "git_status";
        options.desc = "Find in [g]it [s]tatus";
      };
      "<leader>gS" = {
        action = "git_stash";
        options.desc = "Find in [g]it [S]tash";
      };

      "<leader>s\"" = {
        action = "registers";
        options.desc = "[s]earch [\"] registers";
      };
      "<leader>s/" = {
        action = "history";
        options.desc = "[s]earch [/] history";
      };
      "<leader>sa" = {
        action = "autocommands";
        options.desc = "[s]earch [a]utocommands";
      };
      "<leader>sb" = {
        action = "current_buffer_fuzzy_find";
        options.desc = "[s]earch current [b]uffer";
      };
      "<leader>sc" = {
        action = "command_history";
        options.desc = "[s]earch [c]ommand history";
      };
      "<leader>sC" = {
        action = "commands";
        options.desc = "[s]earch [C]ommands";
      };
      "<leader>sd" = {
        action = "diagnostics";
        options.desc = "[s]earch [d]iagnostics";
      };
      "<leader>sD" = {
        action = "diagnostics bufnr=0";
        options.desc = "[s]earch [D]iagnostics in current buffer";
      };
      "<leader>sg" = {
        action = "live_grep";
        options.desc = "[s]earch with [g]rep";
      };
      "<leader>sh" = {
        action = "help_tags";
        options.desc = "[s]earch [h]elp pages";
      };
      "<leader>sH" = {
        action = "highlights";
        options.desc = "[s]earch [H]ighlight groups";
      };
      "<leader>sj" = {
        action = "jumplist";
        options.desc = "[s]earch [j]umplist";
      };
      "<leader>sk" = {
        action = "keymaps";
        options.desc = "[s]earch [k]eymaps";
      };
      "<leader>sl" = {
        action = "loclist";
        options.desc = "[s]earch [l]ocation list";
      };
      "<leader>sM" = {
        action = "man_pages";
        options.desc = "[s]earch [M]an pages";
      };
      "<leader>sm" = {
        action = "marks";
        options.desc = "Jump to [s]earched [m]arks";
      };
      "<leader>sn" = {
        action = "manix";
        options.desc = "[s]earch [n]ixos documentation";
      };
      "<leader>so" = {
        action = "vim_options";
        options.desc = "[s]earch vim [o]ptions";
      };
      "<leader>sR" = {
        action = "resume";
        options.desc = "[s]earch [R]esume";
      };
      "<leader>su" = {
        action = "undo";
        options.desc = "[s]earch [u]ndo tree";
      };
      "<leader>sq" = {
        action = "quickfix";
        options.desc = "[s]earch [q]uick fix";
      };
      "<leader>sz" = {
        action = "zoxide list";
        options.desc = "Open [s]earched folder with [z]oxide";
      };
    };

    extensions = {
      fzy-native.enable = true;
      zoxide.enable = true;
      undo.enable = true;
      manix.enable = true;
    };
  };

  extraPackages = [
    pkgs.ripgrep
    pkgs.fd
    pkgs.fzy
    pkgs.zoxide
    pkgs.manix
  ];

  extraConfigLuaPost = ''
    local manix_cache = vim.fn.expand("$HOME/.cache/manix/last_version.txt")

    if vim.fn.filereadable(manix_cache) == 0 then
      print("Manix cache missing. Gnerating in the background")

      vim.fn.jobstart({"manix", "\"\"", "--update-cache", "--source", "hm_options,nd_options,nixos_options,nixpkgs_doc,nixpkgs_tree"}, {
    	on_exit = function()
    	  print("Manix cache updated!")
    	end
      })
    end
  '';
}
