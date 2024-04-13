{ stdenv_32bit
, fetchFromGitHub
, which
, makeWrapper
}:

stdenv_32bit.mkDerivation {
  pname = "movfuscator";
  version = "unstable-2020.2.11";

  dontPatchELF = true;

  postPatch = let 
    lcc = fetchFromGitHub {
      owner = "drh";
      repo = "lcc";
      rev = "3b3f01b4103cd7b519ae84bd1122c9b03233e687";
      hash = "sha256-gq+zStRrnY8Avo7n1gZbNqlVll9BxMVtL/rgrMS34go=";
    };
  in ''
    ln -s $out/share/lcc-movcc build

    cp -r ${lcc} lcc
    chmod -R 777 lcc

    substituteInPlace build.sh check.sh \
      --replace-quiet 'git reset' 'echo git reset' \
      --replace-quiet 'BUILDDIR=`pwd`/build' BUILDDIR=$out/share/lcc-movcc

    for item in **/*; do
      substituteInPlace $item \
        --replace-quiet /usr/bin/as "$(which as)" \
        --replace-quiet /usr/bin/ld "$(which ld)" \
        --replace-quiet /usr/bin/cpp "$out/share/lcc-movcc/cpp" \
        --replace-quiet /lib/ld-linux.so.2 "$(cat ${stdenv_32bit.cc}/nix-support/dynamic-linker)" \
          || true
    done
  '';

  src = ./.;

  env = {
    NIX_CFLAGS_COMPILE = "-D LCCDIR=\"${placeholder "out"}/share/lcc-movcc/\"";
  };

  nativeBuildInputs = [ which makeWrapper ];

  buildPhase = ''
  runHook preBuild

  env
  
  bash build.sh
    
  runHook postBuild
  '';

  checkPhase = let
    validationAes = fetchFromGitHub {
      owner = "kokke";
      repo = "tiny-AES128-C";
      rev = "7e42e693288bdf22d8e677da94248115168211b9";
      hash = "sha256-4hk90Nl2bGKY+VGIE+VsjGV9CwP2npKQhi6kFJVI06g=";
    };
  in ''
  runHook preCheck

  ln -s ${validationAes} validation/aes

  # bash check.sh
  
  runHook postCheck
  '';

  installPhase = ''
  runHook preInstall

  mkdir -p $out/bin

  for item in $out/share/lcc-movcc/*; do
    if [ -x "$(realpath "$item")" ]; then
      ln -s $item $out/bin
    fi
  done
  # ln -s $out/share/lcc-movcc/movcc $out/bin/movcc
  # install -m755 build/lcc $out/bin
  # ln -s $out/bin/lcc $out/bin/movcc

  mkdir -p $out/src
  cp -r . $out/src

  find -type f
  
  runHook postInstall
  '';
}
