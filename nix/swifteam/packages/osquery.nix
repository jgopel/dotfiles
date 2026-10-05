
{ pkgs, ... }:
{
  environment.systemPackages = [ 
    pkgs.osquery
  ];
}
	