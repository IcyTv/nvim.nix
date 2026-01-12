{lib}: {
  mkLang = {
    name,
    filetypes ? [name],
    description ? "Enable ${name} support",
    lsp ? null, # { server = "serverName"; package = pkgs.package; }
    format ? null, # { tool = "toolName"; package = pkgs.package; }
    extraLspOptions ? {},
    extraFormatOptions ? {},
    extraOptions ? {},
    extraConfig ? cfg: {},
  }: {
    config,
    pkgs,
    ...
  }: let
    cfg = config.languages.${name};
    defaultLspPackage = lsp.package or null;
    defaultFormatPackage = format.package or null;
  in {
    options.languages.${name} =
      {
        enable = lib.mkEnableOption description;

        lsp =
          {
            enable = lib.mkEnableOption "Enable LSP support" // {default = true;};
            package = lib.mkOption {
              type = with lib.types; nullOr package;
              default = defaultLspPackage;
              description = "LSP package to use. Set to null to use the one in your PATH (e.g. from devshell).";
            };
          }
          // extraLspOptions;

        format =
          {
            enable = lib.mkEnableOption "Enable formatting" // {default = true;};
            package = lib.mkOption {
              type = with lib.types; nullOr package;
              default = defaultFormatPackage;
              description = "Formatter package to use. Set to null to use the one in your PATH.";
            };
            command = lib.mkOption {
              type = lib.types.str;
              default =
                if cfg.format.package != null
                then lib.getExe cfg.format.package
                else format.tool;
              description = "Command to run formatter";
            };
          }
          // extraFormatOptions;
      }
      // extraOptions;

    config = lib.mkIf cfg.enable (lib.mkMerge [
      # LSP Configuration
      (lib.mkIf (lsp != null && cfg.lsp.enable) {
        plugins.lsp.servers.${lsp.server} = {
          enable = true;
          package = cfg.lsp.package;
        };
      })

      # Format Configuration
      (lib.mkIf (format != null && cfg.format.enable) {
        plugins.conform-nvim.settings = {
          formatters_by_ft = lib.genAttrs filetypes (_: [format.tool]);
          formatters.${format.tool} = {
            command = cfg.format.command;
          };
        };
      })

      # Extra Config
      (extraConfig cfg)
    ]);
  };
}
