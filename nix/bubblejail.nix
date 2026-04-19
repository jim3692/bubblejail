{
  lib,
  buildPythonPackage,
  xdg-dbus-proxy,
  bubblewrap,
  libseccomp,
  libnotify,
  desktop-file-utils,
  scdoc,
  meson-python,

  pyxdg,
  tomli-w,
  pyqt6,
  lxns,
  jinja2,
  qt6,
  cattrs,

  pkgs,
  python,
}:

let
  version = builtins.readFile (
    with pkgs;
    runCommand "get_version"
      { nativeBuildInputs = [ jq meson ]; }
      ''
        meson introspect ${./..}/meson.build --projectinfo | jq .version >$out
      ''
  );

  pythonVersion =
    with builtins;
    let
      version = splitVersion python.version;
    in
    "${elemAt version 0}.${elemAt version 1}";
in
buildPythonPackage rec {
  pname = "bubblejail";
  inherit version;

  src = ./..;

  patches = [
    ./patches/env-python.patch
    ./patches/jinja-out.patch
    ./patches/meson-options.patch
    ./patches/prefix.patch
    ./patches/scan-store.patch
  ];

  inherit pythonVersion;
  pyproject = true;

  build-system = [ meson-python ];

  dependencies = [
    pyxdg
    tomli-w
    pyqt6
    lxns
    cattrs
  ];

  buildInputs = [
    libnotify
    desktop-file-utils
    qt6.qtbase
  ];

  nativeBuildInputs = [
    # scdoc
    jinja2
    qt6.wrapQtAppsHook
  ];

  pythonImportsCheck = [
    "bubblejail"
  ];

  postPatch = ''
    substituteInPlace src/bubblejail/bubblejail_seccomp.py \
      --replace-fail 'find_library("seccomp")' '"${libseccomp.lib}/lib/libseccomp.so"'

    substituteInPlace src/bubblejail/dbus_proxy.py \
      --replace-fail 'which("xdg-dbus-proxy")' '"${xdg-dbus-proxy}/bin/xdg-dbus-proxy"'

    substituteInPlace src/bubblejail/bubblejail_runner.py \
      --replace-fail '/usr/bin/bwrap' '${bubblewrap}/bin/bwrap'
  '';

  postInstall = ''
    substituteInPlace \
      $out/bin/{bubblejail,bubblejail-config} \
      $out/lib/python${pythonVersion}/site-packages/.bubblejail.mesonpy.libs/bubblejail/bubblejail-helper \
      --subst-var-by OUT "$out/lib/python${pythonVersion}/site-packages"

    chmod +x $out/bin/{bubblejail,bubblejail-config}
    chmod +x $out/lib/python${pythonVersion}/site-packages/.bubblejail.mesonpy.libs/bubblejail/bubblejail-helper
    # chmod +x $out/lib/bubblejail/bubblejail-helper
  '';
}
