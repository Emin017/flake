let
  admin = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBvL48MjBmTQrJAgen0wuUoDu3eD5gX2LF5e9SL2Ojrp me@emin.chat";
  fringe = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICx+GmWXZ02BVILdOfQG36u0G6sXcZO5DmtjRB1D2jrf root@Emin";
  ryzen = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINlHgJJsNFPTRAyNzP8jrzC9kZUw8GRfAELpH9upMCJA root@emin";

  defaultSecrets = [
    "password"
    "password-hash"
  ];

  mkHostSecrets =
    host: publicKeys: secrets:
    map (secret: {
      name = "system/hosts/${host}/secrets/${host}-user-${secret}.age";
      value = { inherit publicKeys; };
    }) secrets;
in
builtins.listToAttrs (
  builtins.concatLists [
    (mkHostSecrets "fringe" [ admin fringe ] [ "password-hash" ])
    (mkHostSecrets "ryzen" [ admin ryzen ] [ "password-hash" ])
    (mkHostSecrets "wsl" [ admin ] defaultSecrets)
    (mkHostSecrets "hydra" [ admin ] defaultSecrets)
  ]
)
