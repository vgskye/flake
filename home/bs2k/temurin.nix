{
  stdenv,
  lib,
  fetchurl,
  autoPatchelfHook,
  makeWrapper,
  setJavaClassPath,
  # minimum dependencies
  alsa-lib,
  fontconfig,
  freetype,
  libffi,
  libxtst,
  libxrender,
  libxi,
  libxext,
  libx11,
  zlib,
  # runtime dependencies
  cups,
  # runtime dependencies for GTK+ Look and Feel
  # TODO(@sternenseemann): gtk3 fails to evaluate in pkgsCross.ghcjs.buildPackages
  # which should be fixable, this is a no-rebuild workaround for GHC.
  gtkSupport ? !stdenv.targetPlatform.isGhcjs,
  cairo,
  glib,
  gtk3,
}:

let
  cpuName = stdenv.hostPlatform.parsed.cpu.name;
  runtimeDependencies = [
    cups
  ]
  ++ lib.optionals gtkSupport [
    cairo
    glib
    gtk3
  ];
  runtimeLibraryPath = lib.makeLibraryPath runtimeDependencies;
in
stdenv.mkDerivation {
    pname = "temurin-bin";

    version = "27";

    src = fetchurl {
      url = "https://github.com/adoptium/temurin27-binaries/releases/download/jdk-27%2B35/OpenJDK27U-jdk_x64_linux_hotspot_27_35.tar.gz";
      sha256 = "1cf69a4848ffb728b3b260dfd45206a51566ab571a02a30092271d4c580bccbc";
    };

    buildInputs = [
      alsa-lib # libasound.so wanted by lib/libjsound.so
      fontconfig
      freetype
      (lib.getLib stdenv.cc.cc) # libstdc++.so.6
      libx11
      libxext
      libxi
      libxrender
      libxtst
      zlib
    ]
    ++ lib.optional stdenv.hostPlatform.isAarch32 libffi;

    nativeBuildInputs = [
      autoPatchelfHook
      makeWrapper
    ];

    # See: https://github.com/NixOS/patchelf/issues/10
    dontStrip = 1;

    installPhase = ''
      cd ..

      mv $sourceRoot $out

      # jni.h expects jni_md.h to be in the header search path.
      ln -s $out/include/linux/*_md.h $out/include/

      # Remove some broken manpages.
      # Only for 11 and earlier.
      [ -e "$out/man/ja" ] && rm -r $out/man/ja*

      # Remove embedded freetype to avoid problems like
      # https://github.com/NixOS/nixpkgs/issues/57733
      find "$out" -name 'libfreetype.so*' -delete

      # Propagate the setJavaClassPath setup hook from the JDK so that
      # any package that depends on the JDK has $CLASSPATH set up
      # properly.
      mkdir -p $out/nix-support
      printWords ${setJavaClassPath} > $out/nix-support/propagated-build-inputs

      # Set JAVA_HOME automatically.
      cat <<EOF >> "$out/nix-support/setup-hook"
      if [ -z "\''${JAVA_HOME-}" ]; then export JAVA_HOME=$out; fi
      EOF

      # We cannot use -exec since wrapProgram is a function but not a command.
      #
      # jspawnhelper is executed from JVM, so it doesn't need to wrap it, and it
      # breaks building OpenJDK (#114495).
      for bin in $( find "$out" -executable -type f -not -name jspawnhelper ); do
        if patchelf --print-interpreter "$bin" &> /dev/null; then
          wrapProgram "$bin" --prefix LD_LIBRARY_PATH : "${runtimeLibraryPath}"
        fi
      done
    '';

    preFixup = ''
      find "$out" -name libfontmanager.so -exec \
        patchelf --add-needed libfontconfig.so {} \;
    '';

    meta = {
      license = with lib.licenses; [
        gpl2
        classpathException20
      ];
      sourceProvenance = with lib.sourceTypes; [
        binaryNativeCode
        binaryBytecode
      ];
      description = "Eclipse Teumrin, prebuilt OpenJDK binary";
      platforms = [
        "x86_64-linux"
      ];
      maintainers = with lib.maintainers; [ vgskye ];
      mainProgram = "java";
    };
  }