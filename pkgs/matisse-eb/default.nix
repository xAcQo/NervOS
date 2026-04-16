{ stdenvNoCC, ... }:
stdenvNoCC.mkDerivation {
  pname = "matisse-eb";
  version = "1.0";
  src = ../../assets/fonts;
  dontUnpack = true;
  installPhase = ''
    runHook preInstall
    install -Dm644 $src/MatissePro-EB.otf -t $out/share/fonts/opentype
    runHook postInstall
  '';
  meta.description = "Matisse EB display font (Fontworks) — NERV Command display/title typeface";
}
