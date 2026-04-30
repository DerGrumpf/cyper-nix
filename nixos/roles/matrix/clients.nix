{
  pkgs,
  lib,
  ...
}:
let
  flavours = [
    {
      name = "Latte";
      slug = "latte";
      is_dark = false;
    }
    {
      name = "Frappé";
      slug = "frappe";
      is_dark = true;
    }
    {
      name = "Macchiato";
      slug = "macchiato";
      is_dark = true;
    }
    {
      name = "Mocha";
      slug = "mocha";
      is_dark = true;
    }
  ];
  accents = [
    "rosewater"
    "flamingo"
    "pink"
    "mauve"
    "red"
    "maroon"
    "peach"
    "yellow"
    "green"
    "teal"
    "sky"
    "sapphire"
    "blue"
    "lavender"
  ];
  themeHashes = {
    "latte/rosewater" = "0l1m4bhaxdam07rfqag6pjbzhdpyi5w3i14vp6rq7aj59pildw3a";
    "latte/flamingo" = "1m8hh2l87xv2rfgpnnl5vzddmam0n82h25fwadb37blgab08vhsr";
    "latte/pink" = "0ambrc42mvg0vdspfmnl31ka1nsxpdyv1p3nh045822y02q20wwh";
    "latte/mauve" = "1nnn2w6nsr24a45jy497c2vhi8v64bwg99fj2dyhpfsn89c63lhn";
    "latte/red" = "14lmw4c4llfz6zqvfymkc6k3msxcml2gwq9rhwsixdpc5mjjbn8n";
    "latte/maroon" = "0ydpng9451mpn7hv5ag1ck8hryx8pdvrml3zksvzm2fiwzzjkpcf";
    "latte/peach" = "1fn5804wv9z9iv65ikyv015b01a7c546rsaaks2a2sq2c37n75l0";
    "latte/yellow" = "0hzgiyhqmwgp3h3v1y23sx3x5qp712sw106472lbnxbywqlavcza";
    "latte/green" = "194kxv6d9hc4nixy16hy9nvf32qs3v214nr2r2qf2z9l89rk5pnp";
    "latte/teal" = "12n25d38zpqxsskglymhmza972klg2hj3c23v2nb3jfj82llw6v4";
    "latte/sky" = "0yghds3xpmbhkbcj2jkh8df82j6vrn9q1z0s2129nca7l5g5f9w2";
    "latte/sapphire" = "18dl1srxp3xccvvy56za6kp05n68d918l0wrxga11746g9sib7r3";
    "latte/blue" = "1zv9nap21d80flvd1jwmjph05jgykxngv5kqbhk95mvqh962ygnf";
    "latte/lavender" = "03j4fwbscip1qm6px1qxkha0c5csq2wwvzg9vwjkc2ja48v1mp9k";
    "frappe/rosewater" = "032qbgj32mvgpankl9777x2lxk18451kglsxg5215k8zrwcg9y95";
    "frappe/flamingo" = "1grhgynn8q7isv18981km5k8ll72ihsjw2ciy8widl6wikv29j8p";
    "frappe/pink" = "0h33g721bph8ihd6lmbc7szxy4dq85ng1cgg5cxjb5y2m7wpdbsy";
    "frappe/mauve" = "121jmznc9q3p7crsy9p2khw8xnzvz4lxms26g1h5wqa67wqvalc4";
    "frappe/red" = "07wm4h1giyy6a5nlh0d3qdarfsp6ikyr5nmg94n13lj4q03d0cn0";
    "frappe/maroon" = "08vg70nr918n4ffi1wnbba4xrx5ak5vfgq7m5ik0rpkb2wdb4x6k";
    "frappe/peach" = "1cg753w2dxs0sx97d8y0g62s8aw3w6b9hrll0lsrw3bc1bvm23fl";
    "frappe/yellow" = "0g43g2if1pcm25i261zfw43bawqqdlgg2f6q2bqhyqvafk9yb3dy";
    "frappe/green" = "1n71mndzds3zldb271g8hdw1yn29s68svzvh8ckjcsz4sb9h1i74";
    "frappe/teal" = "0b6m9cibfwf8csh1pk5i76xi3wx3v2aqwgffzsidw8nwc7c1a3wk";
    "frappe/sky" = "1l4d44399ixshlc9fdsx7iqwxm6kdkp6k4z3z6bdyyx6adw3z4q5";
    "frappe/sapphire" = "03fa9rnclvs5ljd0lzz15vnkzpqpbrhfppg3zwfchs9fvak0n3ni";
    "frappe/blue" = "0r4jjn3pab77w1aanlv3143ch60400q44mdzaqmcjbcr6l2knmjh";
    "frappe/lavender" = "1mrkaz72w6j9hh4dpxwgd6ks5wsnq9ydgy6f9gms4jx1611aab96";
    "macchiato/rosewater" = "001akfnhlvwaiz5faahl4qi0qp6as6ilvkbja6bjy9f5iasr4ygp";
    "macchiato/flamingo" = "06xq3pbx4cb3pyblx2vydr4bp0ylm7866d66agg5wg5qnr356wb3";
    "macchiato/pink" = "1hb32dj0n3wx4f1wxa4n7fib2mazghwsg2ljycza9macfn2n87qn";
    "macchiato/mauve" = "1yrnp162blizc10fz2n6ls1x0di1sdjk53vpsl7mifrkcr1k2nq7";
    "macchiato/red" = "1g9s39q7459lk830vhdrfqkbzz88p3fp8k98a2ygj2hz8sycpryq";
    "macchiato/maroon" = "0ad7rx8sbkygvsgywhpjvvzmyflyhz7jlm13dr7cxj3801rxhl6d";
    "macchiato/peach" = "1m5m6afcl8s1ghn2b9n1d20fhsygnhgn0205nhpxh4bih3kg8c8m";
    "macchiato/yellow" = "0zcc26d28jaq71mz8nqssz8p0hylczirjwjxr2dkha1133vjmvy5";
    "macchiato/green" = "055xdb5jilp5fq3a1g8773rv52zr68fp4l3hs56yj6dy3bq3q22v";
    "macchiato/teal" = "1sfci2g2nvmj0v72gnxqbj0k8053qz0rl6iphfxs3pgpi1b0rczq";
    "macchiato/sky" = "0vhfmdliy8cbb0vqq3v26isvcz4sxzq0xrb4p5a6gibvxaqi6bf3";
    "macchiato/sapphire" = "1744jiv57aqz4qi52n92nrx0s1rhylgg08qqc31jr2clk9h6bw18";
    "macchiato/blue" = "1arp8r2g8ivs1xipq39d3l6cvx0zrr1vwv9yac5j33d6c93wbb2i";
    "macchiato/lavender" = "0kak1f574c07gqjfafg3w5avrci584iqxjkmvrl2pv1879g84nn3";
    "mocha/rosewater" = "0p3ck9crskrhk1za6knaznjlj464mx4sdkkadna6k2152m3czjpz";
    "mocha/flamingo" = "04xx1mky230saqxxqin2fph8cnnz1jhmvb9qd9f5yc3pai3q5wdw";
    "mocha/pink" = "1cj9zdd72vcc45ziav625yq6hrp1zw21f7xsic0ip065xcqzdl3p";
    "mocha/mauve" = "1wb0ibmdv6vn07bk570pikm43qdxj3n2zsqr5sip17ay05j5l6dm";
    "mocha/red" = "1mnzrk57ar2cphyi2ry2lg5ilmb26gm4pr7ixch2ls0hk8ilp9p9";
    "mocha/maroon" = "1mcpwz3yrg3kk0hkqv5nykxj07bm70403yyl8r60pqlh74dnhkbf";
    "mocha/peach" = "0jglpcs41rfqxcm45mvnbdqhma0bv4h07nc7c3nrwz3g3h2djmzr";
    "mocha/yellow" = "0jqkvcjiwid1zdvrj2ikqf5winm08qyd51nfsawfdspbfhqnzmis";
    "mocha/green" = "0bg0014a77yx7f2r6n4mxm7rqgdnymqq7cq6bvpgkfk2z1gyr38l";
    "mocha/teal" = "0kzvi3gfirpcxdhgsilm51lk3j1z6lavb7160chgd9jhzk0xg97c";
    "mocha/sky" = "057nmp2aywdxzrkmzi65bh2mvf1a9cnri0g0jdyzdnrn7f8bbsiw";
    "mocha/sapphire" = "0nfklzb0a7mxv6nzav7m2g0y9plm72vwadm06445myv3k9j3ffmj";
    "mocha/blue" = "06ay46x2aq1q5ghz2zhzhn6qyqkrrf4p9j59qywnxh1jvv728ns8";
    "mocha/lavender" = "0iip063f6km17998c7ak0lb3kq6iskyi3xv2phn618mhslnxhwm5";
  };
  catppuccinThemes = lib.concatMap (
    flavour:
    map (
      accent:
      builtins.fromJSON (
        builtins.readFile (
          pkgs.fetchurl {
            url = "https://element.catppuccin.com/${flavour.slug}/${accent}.json";
            sha256 = themeHashes."${flavour.slug}/${accent}";
          }
        )
      )
    ) accents
  ) flavours;
  elementConfig = builtins.toFile "element-config.json" (
    builtins.toJSON {
      default_server_config = {
        "m.homeserver" = {
          base_url = "https://matrix.cyperpunk.de";
          server_name = "cyperpunk.de";
        };
      };
      jitsi = {
        preferred_domain = "jitsi.cyperpunk.de";
      };
      element_call = {
        url = "https://element-call.cyperpunk.de";
        use_exclusively = true;
        participant_limit = 8;
        brand = "Cyperpunk Call";
      };
      livekit = {
        livekit_service_url = "https://cyperpunk.de/livekit/jwt/";
      };
      setting_defaults = {
        custom_themes = catppuccinThemes;
        feature_custom_themes = true;
      };
      features = {
        feature_group_calls = true;
        "feature_disable_call_per_sender_encryption" = true;
      };
    }
  );
  elementWebConfigured = pkgs.element-web.overrideAttrs (old: {
    postInstall = (old.postInstall or "") + ''
      cp ${elementConfig} $out/config.json
    '';
  });
  synapseAdmin = pkgs.ketesa.withConfig {
    restrictBaseUrl = [ "https://matrix.cyperpunk.de" ];
    loginFlows = [ "password" ];
  };
  elementCallConfigured = pkgs.element-call.overrideAttrs (old: {
    postInstall = (old.postInstall or "") + ''
      cp ${
        builtins.toFile "element-call-config.json" (
          builtins.toJSON {
            default_server_config = {
              "m.homeserver" = {
                base_url = "https://matrix.cyperpunk.de";
                server_name = "cyperpunk.de";
              };
            };
            livekit_service_url = "https://cyperpunk.de/livekit/jwt/";
          }
        )
      } $out/config.json
    '';
  });
in
{

  networking.firewall.allowedTCPPorts = [
    8009 # Cinny
    8010 # Element
    8011 # Synapse Admin
    8012 # FluffyChat
    8013 # Element Call
  ];

  services.nginx.virtualHosts = {
    "cinny.cyperpunk.de" = {
      listen = [
        {
          addr = "0.0.0.0";
          port = 8009;
        }
      ];
      root = "${pkgs.cinny}";
    };
    "element.cyperpunk.de" = {
      listen = [
        {
          addr = "0.0.0.0";
          port = 8010;
        }
      ];
      root = "${elementWebConfigured}";
    };
    "fluffy.cyperpunk.de" = {
      listen = [
        {
          addr = "0.0.0.0";
          port = 8012;
        }
      ];
      locations."/" = {
        proxyPass = "http://127.0.0.1:8082";
      };
    };
    "admin.cyperpunk.de" = {
      listen = [
        {
          addr = "0.0.0.0";
          port = 8011;
        }
      ];
      root = "${synapseAdmin}";
    };
    "element-call.cyperpunk.de" = {
      listen = [
        {
          addr = "0.0.0.0";
          port = 8013;
        }
      ];
      root = "${elementCallConfigured}";
    };
  };

  virtualisation.oci-containers.containers.fluffychat = {
    image = "ghcr.io/krille-chan/fluffychat:latest";
    ports = [ "127.0.0.1:8082:80" ];
    volumes = [
      "${
        builtins.toFile "fluffychat-config.json" (
          builtins.toJSON {
            default_homeserver = "matrix.cyperpunk.de";
            preset_homeserver = "matrix.cyperpunk.de";
          }
        )
      }:/app/config.json:ro"
    ];
  };
}
