{ lib, stdenv, runCommand, fetchurl, autoPatchelfHook, makeDesktopItem, p7zip
, alsa-lib
, at-spi2-atk
, at-spi2-core
, atk
, cups
, curl
, dbus
, expat
, ffmpeg
, fontconfig
, freetype
, glib
, harfbuzz
, icu
, jsoncpp
, libX11
, libXcomposite
, libXcursor
, libXdamage
, libXext
, libXfixes
, libXi
, libXrandr
, libXrender
, libXtst
, libcap
, libdrm
, libevent
, libgcrypt
, libglvnd
, libjpeg
, libkrb5
, libopus
, libpng
, libpulseaudio
, libsecret
, libtiff
, libvpx
, libwebp
, libxcb
, libxkbcommon
, libxkbfile
, libxml2
, libxshmfence
, libxslt
, lshw
, mesa
, minizip
, nspr
, nss
, openssl
, pango
, pciutils
, pcre2
, pipewire
, protobuf
, snappy
, sqlite
, srtp
, udev
, wayland
, xcbutil
, xcbutilimage
, xcbutilkeysyms
, xcbutilrenderutil
, xcbutilwm
, xrandr
, zlib
, enableWayland ? false
}:

let
  inherit (lib) concatStringsSep getLib optional;
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
    autoPatchelfHook
  ];

  buildInputs = [
    alsa-lib
    at-spi2-atk
    at-spi2-core
    atk
    cups
    curl
    dbus
    expat
    ffmpeg
    fontconfig
    freetype
    glib
    harfbuzz
    icu
    jsoncpp
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
    libcap
    libdrm
    libevent
    libgcrypt
    libglvnd
    libjpeg
    libkrb5
    libopus
    libpng
    libpulseaudio
    libsecret
    libtiff
    libvpx
    libwebp
    libxcb
    libxkbcommon
    libxkbfile
    libxml2
    libxshmfence
    libxslt
    lshw
    mesa
    minizip
    nspr
    nss
    openssl
    pango
    pciutils
    pcre2
    pipewire
    protobuf
    snappy
    sqlite
    srtp
    udev
    xcbutil
    xcbutilimage
    xcbutilkeysyms
    xcbutilrenderutil
    xcbutilwm
    xrandr
    zlib
  ] ++ optional enableWayland wayland;

  runtimeDependencies = concatStringsSep " " (map getLib buildInputs ++ [
    "${placeholder "out"}/opt/Webex"
    # guard $out/opt/Webex/bin from having /lib suffixed
    "${placeholder "out"}/opt/Webex/bin:/dev/null"
  ]);

  postUnpack = ''
    sourceRoot=$sourceRoot/Webex_ubuntu
  '';

  # dontPatchELF = true;
  # dontStrip = true;

  # buildPhase = ''
  #   runHook preBuild
  #   patchelf \
  #     --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
  #     --set-rpath "$runtimeDependencies" \
  #     opt/Webex/bin/CiscoCollabHost \
  #     opt/Webex/bin/CiscoCollabHostCef \
  #     opt/Webex/bin/CiscoCollabHostCefWM \
  #     opt/Webex/bin/WebexFileSelector \
  #     opt/Webex/bin/pxgsettings
  #   for each in $(find opt/Webex -type f | grep \\.so); do
  #     patchelf --set-rpath "$runtimeDependencies" "$each"
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
