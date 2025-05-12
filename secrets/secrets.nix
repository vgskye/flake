let
  bs2k = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBS7egIeC7rCo9RumuBUmKa/2gJ9aHjuOZ9OSWL+1ISt";
  secondary = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILMND02AdGLP0cSTCjXqqjOWxfKlEKxhgZnugxwUFLQt";
  chell = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOJ+kd1bkPvYO3uZfvnRsYCjOR1H1FdRnLmdNvC4mEZY";
  # primary =
  #   "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINpAmy/zpf4w3rUtVF7nXWTOz+HyhJJyPfkHVl7xO555";
  # beta =
  #   "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN2dVPx61/yeAWKzD0ITIY2R5s7V9gdL+uFr531WPbay";
  alpha = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHD6naA5qBpo8OZoP3OG0e2tU+gymHpDONPDhKkZZ01J";
  e4mc-us = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINF1khzNsJ4U1xdr/wyiLE/a4U8C1/DV8zBROufs3HUE";
  e4mc-de = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP6AI3RxPDSq4X4n7fg2XSETP6tyfa/l1DRAlcrJ/Un6";
  e4mc-jp = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINykTNT8C2IWl7C2K3J5ekpM5wQAoVRcyA5dOuVEjhpg";
  e4mc-oc = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIa5Om7O0cvuilCRd+HEX+4mCyAExdrH0WYsbbB4Lr3j";
  e4mc-eu = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMEVFCGpglejaOTeoC55g0DQSUjIjx0GnXSSNgR4usJJ";
  e4mc-ap = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBPnmIQEttFDyztdw15/gtUjM+yIKbYMJhWg/50r0bkB";
  e4mc-na = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPEQgot7X7+sQD4CSL09yTTPiiTEjxAsG3q7T5e6hhtu";
  e4mc-sg = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDfOxzhcwZIHdht892nbBd/8tOyMyou9Q264Rygka1XM";
  alex = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM8JVv9KAmACsDEBXRm1vm7ww4rtu4RQPaddU6JJ2MOo";
  e4mc = [e4mc-us e4mc-de e4mc-jp e4mc-oc e4mc-eu alex e4mc-ap e4mc-na e4mc-sg];
  bridget = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHmdvjJ9WkP1bbL965gt8d+d/RUK8TZLwnk+eEMhbaVZ";
  jenny = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPbyhPgceZnlXr5RIgY0TRplK+5/ZaejMDP2oDYAsab3";
  theworldmachine = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBFseK1tVmweXcvELo/2N4Ws+Pyk6lOi+PTk9382x2u1";
  allay = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEViKAQz1Z5352D4QNU5pM04bgU24PRTWSvbx6HiJb+O";
  all = [bridget jenny theworldmachine allay] ++ e4mc;
in {
  "cf-api-key.age".publicKeys = [bs2k secondary alpha bridget];
  "email-password.age".publicKeys = [bs2k secondary];
  "datadog-key.age".publicKeys = [bs2k secondary];
  "password.age".publicKeys = [bs2k chell];
  "longview-secondary.age".publicKeys = [bs2k secondary];
  "longview-primary.age".publicKeys = [bs2k];
  "e4mc-dns-key.age".publicKeys = [bs2k] ++ e4mc;
  "e4mc-cf-key.age".publicKeys = [bs2k] ++ e4mc;
  "telegraf-key.age".publicKeys = [bs2k] ++ all;
  "restic-secrets.age".publicKeys = [bs2k bridget];
  "mailer-cf-key.age".publicKeys = [bs2k theworldmachine];
  "restic-secrets-twm.age".publicKeys = [bs2k theworldmachine];
  "geoipupdate.age".publicKeys = [bs2k theworldmachine];
}
