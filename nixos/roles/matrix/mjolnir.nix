{ config, ... }:
{
  sops.secrets.mjolnir_access_token = { };

  services.draupnir = {
    enable = true;
    secrets.accessToken = config.sops.secrets.mjolnir_access_token.path;
    settings = {
      homeserverUrl = "https://matrix.cyperpunk.de";
      managementRoom = "!eErCimyDjLSebHjpJA:cyperpunk.de";
    };
  };
}

#curl -X POST https://matrix.cyperpunk.de/_matrix/client/v3/login \
#  -H "Content-Type: application/json" \
#  -d '{"type":"m.login.password ","user":"mjolnir","password":"i318HXBRkt)Lh$nOPwq#6n9z&<W[XJ&2c4$Zf>7jV}-uQCE{<plwk;LZ)10*N<~1"}'
