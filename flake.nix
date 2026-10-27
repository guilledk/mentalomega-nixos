{
  description = "Mental Omega 3.3.6 (C&C Red Alert 2: Yuri's Revenge mod) launcher via umu/GE-Proton";

  # Only the flake files, README.md and RA2MO.ini are tracked by git, so the
  # ~2.8 GB of game data in this directory never gets copied into the store.
  # The launcher finds the game directory at runtime (see `findGameDir`).

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};

      mentalomega = pkgs.writeShellApplication {
        name = "mentalomega";
        runtimeInputs = [ pkgs.umu-launcher pkgs.coreutils ];
        text = ''
          # Game directory: $MO_DIR, else the current directory if it holds
          # the game, else ~/Games/MentalOmega.
          findGameDir() {
            if [ -n "''${MO_DIR:-}" ]; then echo "$MO_DIR"
            elif [ -f "$PWD/MentalOmegaClient.exe" ]; then echo "$PWD"
            else echo "$HOME/Games/MentalOmega"
            fi
          }
          MO="$(findGameDir)"
          if [ ! -f "$MO/MentalOmegaClient.exe" ] || [ ! -f "$MO/gamemd.exe" ]; then
            echo "mentalomega: game not found in '$MO' (set MO_DIR=/path/to/MentalOmega)" >&2
            exit 1
          fi

          # Wine prefix lives outside the game dir so the game dir stays portable.
          export WINEPREFIX="''${WINEPREFIX:-''${XDG_DATA_HOME:-$HOME/.local/share}/mentalomega/prefix}"
          # umu downloads and caches GE-Proton on first run; override with an
          # absolute path to a local Proton build, e.g. a Steam compatibilitytools.d entry.
          export PROTONPATH="''${PROTONPATH:-GE-Proton}"
          export GAMEID="''${GAMEID:-0}"
          export STORE="none"
          # Use the bundled cnc-ddraw (ddraw.dll in the game dir) instead of Wine's.
          export WINEDLLOVERRIDES="ddraw=n,b''${WINEDLLOVERRIDES:+;$WINEDLLOVERRIDES}"
          mkdir -p "$WINEPREFIX"

          cd "$MO"
          [ $# -eq 0 ] && set -- "$MO/MentalOmegaClient.exe"
          exec umu-run "$@"
        '';
      };

      desktopItem = pkgs.makeDesktopItem {
        name = "mentalomega";
        desktopName = "Mental Omega";
        genericName = "Real-time strategy";
        comment = "Red Alert 2: Yuri's Revenge mod (Mental Omega 3.3.6)";
        exec = "${mentalomega}/bin/mentalomega";
        categories = [ "Game" "StrategyGame" ];
      };
    in
    {
      packages.${system} = {
        default = pkgs.symlinkJoin {
          name = "mentalomega";
          paths = [ mentalomega desktopItem ];
        };
        launcher = mentalomega;
      };

      apps.${system}.default = {
        type = "app";
        program = "${mentalomega}/bin/mentalomega";
      };
    };
}
