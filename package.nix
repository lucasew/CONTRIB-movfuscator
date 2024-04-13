{ stdenv
, fetchFromGitHub
}:

stdenv.mkDerivation {
  pname = "movfuscator";
  version = "unstable-2020.2.11";

  postPatch = let 
    lcc = fetchFromGitHub {
      owner = "drh";
      repo = "lcc";
      rev = "3b3f01b4103cd7b519ae84bd1122c9b03233e687";
      hash = "sha256-gq+zStRrnY8Avo7n1gZbNqlVll9BxMVtL/rgrMS34go=";
    };
  in ''
    cp -r ${lcc} lcc
    chmod -R 777 lcc

    # substituteInPlace build.sh check.sh --replace 'git reset' 'echo git reset'

    substituteInPlace **/*.c \
      --replace-quiet /usr/bin/as "$(which as)" \
      --replace-quiet /usr/bin/ld "$(which ld)" \
      --replace-quiet /usr/bin/cpp $out/bin/lcc
  '';

  src = ./.;

  buildPhase = ''
  runHook preBuild
  
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

  MOVFUSCATOR_CPP=build/lcc bash check.sh
  
  runHook postCheck
  '';

  installPhase = ''
  runHook preInstall

  mkdir -p $out/bin

  install -m755 build/movcc $out/bin
  install -m755 build/lcc $out/bin


  find -type f
  
  runHook postInstall
  '';
}
