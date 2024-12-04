rec {
  colors = rec {
    bgDarker = "0D0C1E"; # 080814
    bgDark = "1b1a33";
    bgMediumDark = "28274d";
    bgMedium = "434180";
    bgMediumLight = "504e99";
    bgMediumLighter = "6b68cc";
    bgLight = "7975e6";
    bgLighter = "8682ff";

    lightYellow = "d7a65f";
    blue = "0060e6";
    purple = "8c33ff";
    orange = "e68600";
    cyan = "00dee6";
    green = "12de00";
    pink = "ea00d9";
    gray = "4A5057";

    error = "f44336";
    success = "66bb6a";

    primaryColor = pink;
    secondaryColor = orange;
    tertiaryColor = cyan;
    quaternaryColor = green;
    quintenaryColor = purple;
    baseText = bgLighter;
    disabled = gray;
  };
  colorsWithHash = builtins.mapAttrs (_: val: "#${val}") colors;
}
