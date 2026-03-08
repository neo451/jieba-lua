{
  pkgs ? import <nixpkgs> { },
}:

with pkgs;
mkShell {
  name = "jieba.nvim";
  buildInputs = [
    cargo

    (luajit.withPackages (
      p: with p; [
        busted
        ldoc
        luarocks-build-rust-mlua
      ]
    ))
  ];
}
