{ runCommand, lib, bash, callPackage, coreutils, findutils, gettext, gnused, jq
, less, ncurses, unixtools, nix-output-monitor
# used for pkgs.path for nixos-option
, pkgs

# Path to use as the Home Manager channel.
, path ? null }:

let

  pathStr = if path == null then "" else path;

  nixos-option = pkgs.nixos-option or (callPackage
    (pkgs.path + "/nixos/modules/installer/tools/nixos-option") { });

in runCommand "nome-manager" {
  preferLocalBuild = true;
  nativeBuildInputs = [ gettext ];
  HM_PATH = /. + path;
  meta = with lib; {
    mainProgram = "nome-manager";
    description = "like home-manager, but wraps itself in nix-output-monitor";
    maintainers = [ maintainers.vgskye ];
    platforms = platforms.unix;
    license = licenses.mit;
  };
} ''
  install -v -D -m755  ${./nome-manager} $out/bin/nome-manager

  substituteInPlace $out/bin/nome-manager \
    --subst-var-by bash "${bash}" \
    --subst-var-by DEP_PATH "${
      lib.makeBinPath [
        coreutils
        findutils
        gettext
        gnused
        jq
        less
        ncurses
        nixos-option
        unixtools.hostname
        nix-output-monitor
      ]
    }" \
    --subst-var-by HOME_MANAGER_LIB '${pathStr}/lib/bash/home-manager.sh' \
    --subst-var-by HOME_MANAGER_PATH '${pathStr}' \
    --subst-var-by OUT "$out"

  install -D -m755 $HM_PATH/home-manager/completion.bash \
    $out/share/bash-completion/completions/nome-manager
  install -D -m755 $HM_PATH/home-manager/completion.zsh \
    $out/share/zsh/site-functions/_nome-manager
  install -D -m755 $HM_PATH/home-manager/completion.fish \
    $out/share/fish/vendor_completions.d/nome-manager.fish
  sed -i "s/home-manager/nome-manager/g" \
    $out/share/bash-completion/completions/nome-manager \
    $out/share/zsh/site-functions/_nome-manager \
    $out/share/fish/vendor_completions.d/nome-manager.fish

  install -D -m755 $HM_PATH/lib/bash/home-manager.sh \
    "$out/share/bash/home-manager.sh"

  for path in $HM_PATH/home-manager/po/*.po; do
    lang="''${path##*/}"
    lang="''${lang%%.*}"
    mkdir -p "$out/share/locale/$lang/LC_MESSAGES"
    msgfmt -o "$out/share/locale/$lang/LC_MESSAGES/home-manager.mo" "$path"
  done
''