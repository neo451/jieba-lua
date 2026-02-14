{
  pkgs ? import <nixpkgs> { },
}:

with pkgs;
mkShell {
  name = "jieba-lua";
  buildInputs = [
    (luajit.withPackages (
      p: with p; [
        busted
        ldoc
      ]
    ))
  ];
}
