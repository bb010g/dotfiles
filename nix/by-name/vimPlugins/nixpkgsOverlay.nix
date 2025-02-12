{ ... }:
finalPkgs: prevPkgs: {
  vimPlugins = pkgsPrev.vimPlugins.extend (finalVimPlugins: prevVimPlugins: {
    direnv-nvim = pkgsPrev.direnv-nvim or (pkgsFinal.buildVimPlugin {
      pname = "direnv.nvim";
      version = "2024-10-30";
      src = fetchFromGitHub {
        owner = "actionshrimp";
        repo = "direnv.nvim";
        rev = "eec36a38285457c4e5dea2c6856329a9a20bd3a4";
        sha256 = "0000000000000000000000000000000000000000000000000000";
      };
      meta.homepage = "https://github.com/actionshrimp/direnv.nvim/";
    });
  });
}
