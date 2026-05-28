{
  lib,
  python312Packages,
  fetchFromGitHub,

  chromaprint,
  gettext,
  qt6,
  gst_all_1,
}:

let
  pythonPackages = python312Packages;
in
pythonPackages.buildPythonApplication rec {
  pname = "picard";
  # nix-update --commit picard --version-regex 'release-(.*)'
  version = "3.0.0a1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "metabrainz";
    repo = "picard";
    tag = "release-${version}";
    hash = "sha256-aI1yUi/5jWABJiBqvKUXCrj7Pu/cd/LpRHJdEEmbvYk=";
  };

  nativeBuildInputs = [
    gettext
    qt6.wrapQtAppsHook
    pythonPackages.pytestCheckHook
    gst_all_1.gst-libav
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
    gst_all_1.gst-vaapi
    gst_all_1.gstreamer
  ];

  buildInputs = [
    qt6.qtbase
    qt6.qtwayland
    qt6.qtmultimedia
  ];

  build-system = with pythonPackages; [ setuptools ];

  propagatedBuildInputs = with pythonPackages; [
    chromaprint
    charset-normalizer
    discid
    markdown
    mutagen
    pygit2
    pyjwt
    pyqt6
    pyyaml
  ];

  setupPyGlobalFlags = [
    "build"
    "--disable-autoupdate"
    "--localedir=${placeholder "out"}/share/locale"
  ];

  preCheck = ''
    export HOME=$(mktemp -d)
  '';
  doCheck = true;

  # In order to spare double wrapping, we use:
  preFixup = ''
    makeWrapperArgs+=("''${qtWrapperArgs[@]}")
    makeWrapperArgs+=(--prefix GST_PLUGIN_SYSTEM_PATH_1_0 : "$GST_PLUGIN_SYSTEM_PATH_1_0")
  '';

  meta = {
    homepage = "https://picard.musicbrainz.org";
    changelog = "https://picard.musicbrainz.org/changelog";
    description = "Official MusicBrainz tagger";
    mainProgram = "picard";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.all;
    maintainers = with lib.maintainers; [ doronbehar ];
  };
}