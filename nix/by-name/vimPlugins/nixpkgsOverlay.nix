{ ... }:
finalPkgs: prevPkgs: {
  vimPlugins = prevPkgs.vimPlugins.extend (finalVimPlugins: prevVimPlugins:
    let
      inherit (finalPkgs) fetchFromGitHub;
      inherit (finalPkgs.vimUtils) buildVimPlugin;
    in
    {
      direnv-nvim = prevVimPlugins.direnv-nvim or (buildVimPlugin {
        pname = "direnv.nvim";
        version = "2024-10-30";
        src = fetchFromGitHub {
          owner = "actionshrimp";
          repo = "direnv.nvim";
          rev = "eec36a38285457c4e5dea2c6856329a9a20bd3a4";
          hash = "sha256-7NcVskgAurbIuEVIXxHvXZfYQBOEXLURGzllfVEQKNE=";
        };
        meta.homepage = "https://github.com/actionshrimp/direnv.nvim/";
      });
    });
}
