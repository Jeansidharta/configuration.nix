{ ... }:
{
  services.auto-cpufreq.enable = true;
  services.thermald.enable = true;
  services.upower = {
    enable = true;
  };
}
