{ lib, stdenv, runCommand, fetchurl, patchelf, makeDesktopItem
, alsa-lib, at-spi2-atk, at-spi2-core, atk, cups, dbus, expat, fontconfig
, freetype, glib, harfbuzz, libdrm, libgcrypt, libglvnd, libkrb5, libpulseaudio
, libsecret, udev, libxcb, libxkbcommon, lshw, mesa, nspr, nss, pango, zlib
, libX11, libXcomposite, libXcursor, libXdamage, libXext , libXfixes, libXi
, libXrandr, libXrender, libXtst, libxshmfence, xcbutil , xcbutilimage
, xcbutilkeysyms, xcbutilrenderutil, xcbutilwm, p7zip, wayland
, enableWayland ? false
}:

let
  inherit (lib) optional;
  desktopName = "Webex";
  binaryName = "CiscoCollabHost";
  versionSpec = builtins.fromJSON (builtins.readFile ./version.json);
  unpackedSrc = runCommand "source" {
    src = fetchurl {
      inherit (versionSpec) url sha256;
    };
    nativeBuildInputs = [ p7zip ];
  } ''
    7z x -o"$out" "$src"
  '';
in stdenv.mkDerivation rec {
  pname = "webex";
  inherit (versionSpec) version;

  src = unpackedSrc;

  nativeBuildInputs = [
    patchelf
  ];

  buildInputs = [
    alsa-lib
    at-spi2-atk
    at-spi2-core
    atk
    cups
    dbus
    expat
    fontconfig
    freetype
    glib
    harfbuzz
    lshw
    mesa
    nspr
    nss
    pango
    zlib
    libdrm
    libgcrypt
    libglvnd
    libkrb5
    libpulseaudio
    libsecret
    udev
    libxcb
    libxkbcommon
    libX11
    libXcomposite
    libXcursor
    libXdamage
    libXext
    libXfixes
    libXi
    libXrandr
    libXrender
    libXtst
    libxshmfence
    xcbutil
    xcbutilimage
    xcbutilkeysyms
    xcbutilrenderutil
    xcbutilwm
  ] ++ optional enableWayland wayland;

  libPath = lib.makeLibraryPath (buildInputs ++ [
    "${placeholder "out"}/opt/Webex"
  ]) + ":${placeholder "out"}/opt/Webex/bin";

  postUnpack = ''
    sourceRoot=$sourceRoot/Webex_ubuntu
  '';

  # dontPatchELF = true;
  # dontStrip = true;

  # buildPhase = ''
  #   runHook preBuild
  #   patchelf \
  #     --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
  #     --set-rpath "$libPath" \
  #     opt/Webex/bin/CiscoCollabHost \
  #     opt/Webex/bin/CiscoCollabHostCef \
  #     opt/Webex/bin/CiscoCollabHostCefWM \
  #     opt/Webex/bin/WebexFileSelector \
  #     opt/Webex/bin/pxgsettings
  #   for each in $(find opt/Webex -type f | grep \\.so); do
  #     patchelf --set-rpath "$libPath" "$each"
  #   done
  #   runHook postBuild
  # '';

  installPhase = ''
    runHook preInstall
    mkdir -p "$out"
    cp -r opt "$out"
    mkdir "$out/bin"
    ln -s "$out/opt/Webex/bin/${binaryName}" "$out/bin/${pname}"
    mkdir "$out/share"
    ln -s "${desktopItem}/share/applications" $out/share/
    mkdir -p "$out/share/icons/hicolor/scalable/apps"
    cp ${./webex.svg} "$out/share/icons/hicolor/scalable/apps/webex.svg"
    runHook postInstall
  '';

  desktopItem = makeDesktopItem {
    name = desktopName;
    exec = pname;
    icon = pname;
    desktopName = desktopName;
    genericName = meta.description;
    categories = "Network;InstantMessaging;";
    mimeType = "x-scheme-handler/webex";
  };

  meta = with lib; {
    description = "Cisco Webex collaboration application";
    homepage = "https://webex.com/";
    downloadPage = "https://www.webex.com/downloads.html";
    license = licenses.unfree;
    maintainers = with lib.maintainers; [ myme uvnikita ];
    platforms = [ "x86_64-linux" ];
  };
}
