{ config, ... }:

{
  accounts.email.accounts.gmail = {
    primary = true;
    flavor = "gmail.com";
    address = "jgopel@gmail.com";
    userName = "jgopel@gmail.com";
    realName = "Jonathan Gopel";

    folders = {
      inbox = "INBOX";
      drafts = "[Gmail]/Drafts";
      sent = "[Gmail]/Sent Mail";
      trash = "[Gmail]/Trash";
    };

    # Leave passwordCommand unset: enter a Google app password in NeoMutt.
    neomutt = {
      enable = true;
      mailboxType = "imap";
      extraConfig = ''
        # Home Manager only generates smtp_url when passwordCommand is set.
        set smtp_url = "smtps://jgopel%40gmail.com@smtp.gmail.com:465/"
        # Gmail saves sent messages automatically.
        unset record
      '';
    };
  };

  programs.neomutt = {
    enable = true;
    # Use gq for prose wrapping without automatically reflowing quoted code.
    editor = "${config.programs.neovim.finalPackage}/bin/nvim -c 'setlocal textwidth=72 formatoptions-=t formatoptions-=a'";
    sort = "threads";
    settings = {
      ssl_force_tls = "yes";
      include = "yes";
      text_flowed = "no";
      send_charset = "us-ascii:utf-8";
    };
  };
}
