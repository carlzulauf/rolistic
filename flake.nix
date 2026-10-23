{
  description = "rolistic - Ruby gem";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };
        ruby = pkgs.ruby_4_0;
      in {
        devShells.default = pkgs.mkShell {
          nativeBuildInputs = [
            ruby
            pkgs.git
          ];

          shellHook = ''
            # BUNDLE_PATH installs into <path>/ruby/<abi version>, so point
            # GEM_HOME at that same directory; gem executables can then find
            # their gems without `bundle exec`.
            export BUNDLE_PATH="$HOME/.local/share/gems/rolistic"
            export GEM_HOME="$BUNDLE_PATH/ruby/${ruby.version.libDir}"
            export PATH="$GEM_HOME/bin:$PATH"

            echo "### rolistic dev shell ###"
            echo "Ruby ${ruby.version}"
            echo ""
          '';
        };
      });
}
