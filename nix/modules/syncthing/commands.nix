{ pkgs }:

{
  syncthing = guiAddress: [
    "${pkgs.syncthing}/bin/syncthing"
    "serve"
    "--no-browser"
    "--gui-address=${guiAddress}"
  ];

  tunnel =
    {
      tunnel,
      localAddress,
      extraArgs,
    }:
    [
      "${pkgs.autossh}/bin/autossh"
      "-M"
      "0"
      "-N"
    ]
    ++ extraArgs
    ++ [
      "-o"
      "ServerAliveInterval=30"
      "-o"
      "ServerAliveCountMax=3"
      "-o"
      "ExitOnForwardFailure=yes"
      "-L"
      "${localAddress}:127.0.0.1:${toString tunnel.remotePort}"
      tunnel.host
    ];
}
