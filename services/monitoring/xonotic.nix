let
  xonoticTargets = [
    "vehicles"
    "resurrection"
    "insurrection"
    "nexuiz"
  ];

  mkXonoticJob =
    {
      job_name,
      metrics_path ? "/metrics",
      scrape_interval ? "15s",
    }:
    {
      inherit job_name metrics_path scrape_interval;
      scrape_timeout = "10s";
      relabel_configs = [
        {
          source_labels = [ "__address__" ];
          target_label = "__param_target";
        }
        {
          source_labels = [ "__param_target" ];
          target_label = "instance";
        }
        {
          target_label = "__address__";
          replacement = "10.10.0.100:9260";
        }
      ];
      static_configs = [ { targets = xonoticTargets; } ];
    };
in
{
  services.prometheus.scrapeConfigs = [
    (mkXonoticJob { job_name = "xonotic"; })
    (mkXonoticJob {
      job_name = "xonotic_geo";
      metrics_path = "/geo";
      scrape_interval = "30s";
    })
    (mkXonoticJob {
      job_name = "xonotic_match";
      metrics_path = "/match";
    })
  ];
}
