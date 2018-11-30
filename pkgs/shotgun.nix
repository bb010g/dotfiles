{ stdenv, fetchFromGitHub, rustPlatform,
  libX11, libXrandr,
  git, pkgconfig }:

rustPlatform.buildRustPackage rec {
  name = "shotgun-${version}";
  version = "2.0.0";

  src = fetchFromGitHub {
    owner = "neXromancers";
    repo = "shotgun";
    rev = "v${version}";
    sha256 = "0kc8mrdcmalv84jlggw8cc9g2402yyzqv473hgwjg50lc0diasaw";
  };

  cargoSha256 = "0f8gwfg7p38zwkpi6k6dn0gq5f4f2khmw7jrj8as6ihdhqwb7q0c";

  nativeBuildInputs = [ pkgconfig ];
  buildInputs = [ libX11 libXrandr ];

  meta = with stdenv.lib; {
    description = "Minimal X screenshot utility";
    homepage = https://github.com/neXromancers/shotgun;
    license = with licenses; [ mpl2 ];
    maintainers = [ maintainers.bb010g ];
    platforms = platforms.all;
  };
}

