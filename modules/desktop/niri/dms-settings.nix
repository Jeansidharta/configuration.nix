{ pkgs, theme }:
{
  launcherLogoCustomPath = ../../../assets/nix-snowflake.svg;
  customThemeFile = pkgs.writeText "theme" (
    builtins.toJSON (import ./dms-theme.nix { inherit theme; })
  );
}
// {
  currentThemeName = "custom";
  currentThemeCategory = "custom";
  matugenScheme = "scheme-tonal-spot";
  runUserMatugenTemplates = false;
  matugenTargetMonitor = "";
  popupTransparency = 1;
  dockTransparency = 1;
  widgetBackgroundColor = "sch";
  widgetColorMode = "colorful";
  cornerRadius = 12;
  niriLayoutGapsOverride = -1;
  niriLayoutRadiusOverride = -1;
  use24HourClock = true;
  showSeconds = false;
  useFahrenheit = true;
  nightModeEnabled = false;
  animationSpeed = 1;
  customAnimationDuration = 500;
  wallpaperFillMode = "Fill";
  blurredWallpaperLayer = false;
  blurWallpaperOnOverview = false;
  showLauncherButton = true;
  showWorkspaceSwitcher = true;
  showFocusedWindow = true;
  showWeather = true;
  showMusic = true;
  showClipboard = true;
  showCpuUsage = true;
  showMemUsage = true;
  showCpuTemp = true;
  showGpuTemp = true;
  selectedGpuIndex = 0;
  enabledGpuPciIds = [ ];
  showSystemTray = true;
  showClock = true;
  showNotificationButton = true;
  showBattery = true;
  showControlCenterButton = true;
  showCapsLockIndicator = true;
  controlCenterShowNetworkIcon = true;
  controlCenterShowBluetoothIcon = true;
  controlCenterShowAudioIcon = true;
  controlCenterShowVpnIcon = true;
  controlCenterShowBrightnessIcon = false;
  controlCenterShowMicIcon = false;
  controlCenterShowBatteryIcon = false;
  controlCenterShowPrinterIcon = false;
  showPrivacyButton = true;
  privacyShowMicIcon = false;
  privacyShowCameraIcon = false;
  privacyShowScreenShareIcon = false;
  controlCenterWidgets = [
    {
      id = "volumeSlider";
      enabled = true;
      width = 50;
    }
    {
      id = "brightnessSlider";
      enabled = true;
      width = 50;
    }
    {
      id = "wifi";
      enabled = true;
      width = 50;
    }
    {
      id = "bluetooth";
      enabled = true;
      width = 50;
    }
    {
      id = "audioOutput";
      enabled = true;
      width = 50;
    }
    {
      id = "audioInput";
      enabled = true;
      width = 50;
    }
    {
      id = "nightMode";
      enabled = true;
      width = 50;
    }
    {
      id = "darkMode";
      enabled = true;
      width = 50;
    }
  ];
  showWorkspaceIndex = false;
  showWorkspacePadding = false;
  workspaceScrolling = false;
  showWorkspaceApps = false;
  maxWorkspaceIcons = 3;
  workspacesPerMonitor = true;
  showOccupiedWorkspacesOnly = false;
  dwlShowAllTags = false;
  workspaceNameIcons = {
  };
  waveProgressEnabled = true;
  scrollTitleEnabled = true;
  audioVisualizerEnabled = true;
  clockCompactMode = false;
  focusedWindowCompactMode = false;
  runningAppsCompactMode = true;
  keyboardLayoutNameCompactMode = false;
  runningAppsCurrentWorkspace = true;
  runningAppsGroupByApp = true;
  centeringMode = "geometric";
  clockDateFormat = "";
  lockDateFormat = "";
  mediaSize = 1;
  appLauncherViewMode = "grid";
  spotlightModalViewMode = "list";
  sortAppsAlphabetically = false;
  appLauncherGridColumns = 5;
  spotlightCloseNiriOverview = true;
  niriOverviewOverlayEnabled = true;
  weatherLocation = "New York, NY";
  weatherCoordinates = "40.7128,-74.0060";
  useAutoLocation = true;
  weatherEnabled = true;
  networkPreference = "wifi";
  vpnLastConnected = "";
  iconTheme = "System Default";
  launcherLogoMode = "custom";
  launcherLogoColorOverride = "#03a9f4";
  launcherLogoColorInvertOnMode = false;
  launcherLogoBrightness = 0.5;
  launcherLogoContrast = 1;
  launcherLogoSizeOffset = 0;
  fontFamily = "JetBrains Mono NL SemiBold";
  monoFontFamily = "JetBrains Mono";
  fontWeight = 400;
  fontScale = 1;
  notepadUseMonospace = true;
  notepadFontFamily = "";
  notepadFontSize = 14;
  notepadShowLineNumbers = false;
  notepadTransparencyOverride = -1;
  notepadLastCustomTransparency = 0.7;
  soundsEnabled = true;
  useSystemSoundTheme = false;
  soundNewNotification = true;
  soundVolumeChanged = true;
  soundPluggedIn = true;
  acMonitorTimeout = 0;
  acLockTimeout = 0;
  acSuspendTimeout = 0;
  acSuspendBehavior = 0;
  acProfileName = "";
  batteryMonitorTimeout = 0;
  batteryLockTimeout = 0;
  batterySuspendTimeout = 0;
  batterySuspendBehavior = 0;
  batteryProfileName = "";
  lockBeforeSuspend = true;
  loginctlLockIntegration = true;
  fadeToLockEnabled = true;
  fadeToLockGracePeriod = 5;
  launchPrefix = "";
  brightnessDevicePins = {
  };
  wifiNetworkPins = {
  };
  bluetoothDevicePins = {
  };
  audioInputDevicePins = {
  };
  audioOutputDevicePins = {
  };
  gtkThemingEnabled = false;
  qtThemingEnabled = false;
  syncModeWithPortal = true;
  terminalsAlwaysDark = true;
  runDmsMatugenTemplates = false;
  matugenTemplateGtk = true;
  matugenTemplateNiri = true;
  matugenTemplateQt5ct = true;
  matugenTemplateQt6ct = true;
  matugenTemplateFirefox = true;
  matugenTemplatePywalfox = true;
  matugenTemplateVesktop = true;
  matugenTemplateEquibop = true;
  matugenTemplateGhostty = true;
  matugenTemplateKitty = true;
  matugenTemplateFoot = true;
  matugenTemplateAlacritty = true;
  matugenTemplateNeovim = true;
  matugenTemplateWezterm = true;
  matugenTemplateDgop = true;
  matugenTemplateKcolorscheme = true;
  matugenTemplateVscode = true;
  showDock = false;
  dockAutoHide = true;
  dockGroupByApp = false;
  dockOpenOnOverview = false;
  dockPosition = 1;
  dockSpacing = 4;
  dockBottomGap = 0;
  dockMargin = 0;
  dockIconSize = 40;
  dockIndicatorStyle = "circle";
  dockBorderEnabled = false;
  dockBorderColor = "surfaceText";
  dockBorderOpacity = 1;
  dockBorderThickness = 1;
  dockIsolateDisplays = false;
  notificationOverlayEnabled = false;
  modalDarkenBackground = true;
  lockScreenShowPowerActions = true;
  lockScreenShowSystemIcons = true;
  lockScreenShowTime = true;
  lockScreenShowDate = true;
  lockScreenShowProfileImage = true;
  lockScreenShowPasswordField = true;
  enableFprint = false;
  maxFprintTries = 15;
  lockScreenActiveMonitor = "all";
  lockScreenInactiveColor = "#000000";
  hideBrightnessSlider = false;
  notificationTimeoutLow = 5000;
  notificationTimeoutNormal = 5000;
  notificationTimeoutCritical = 0;
  notificationPopupPosition = 0;
  osdAlwaysShowValue = true;
  osdPosition = 5;
  osdVolumeEnabled = true;
  osdMediaVolumeEnabled = true;
  osdBrightnessEnabled = true;
  osdIdleInhibitorEnabled = true;
  osdMicMuteEnabled = true;
  osdCapsLockEnabled = true;
  osdPowerProfileEnabled = false;
  osdAudioOutputEnabled = true;
  powerActionConfirm = true;
  powerActionHoldDuration = 0.5;
  powerMenuActions = [
    "reboot"
    "logout"
    "poweroff"
    "lock"
    "suspend"
    "restart"
  ];
  powerMenuDefaultAction = "logout";
  powerMenuGridLayout = false;
  customPowerActionLock = "";
  customPowerActionLogout = "";
  customPowerActionSuspend = "";
  customPowerActionHibernate = "";
  customPowerActionReboot = "";
  customPowerActionPowerOff = "";
  updaterHideWidget = false;
  updaterUseCustomCommand = false;
  updaterCustomCommand = "";
  updaterTerminalAdditionalParams = "";
  displayNameMode = "system";
  screenPreferences = {
  };
  showOnLastDisplay = {
  };
  niriOutputSettings = {
  };
  hyprlandOutputSettings = {
  };
  barConfigs = [
    {
      id = "default";
      name = "Main Bar";
      enabled = true;
      position = 0;
      screenPreferences = [
        "all"
      ];
      showOnLastDisplay = true;
      leftWidgets = [
        {
          id = "launcherButton";
          enabled = true;
        }
        {
          id = "runningApps";
          enabled = true;
          runningAppsCompactMode = false;
        }
      ];
      centerWidgets = [

      ];
      rightWidgets = [
        {
          id = "music";
          enabled = true;
        }
        {
          id = "spacer";
          enabled = true;
          size = 10;
        }
        {
          id = "cpuUsage";
          enabled = true;
        }
        {
          id = "memUsage";
          enabled = true;
        }
        {
          id = "diskUsage";
          enabled = true;
        }
        {
          id = "spacer";
          enabled = true;
          size = 10;
        }
        {
          id = "clock";
          enabled = true;
        }
        {
          id = "spacer";
          enabled = true;
          size = 10;
        }
        {
          id = "privacyIndicator";
          enabled = true;
        }
        {
          id = "colorPicker";
          enabled = true;
        }
        {
          id = "systemTray";
          enabled = true;
        }
        {
          id = "notificationButton";
          enabled = true;
        }
        {
          id = "controlCenterButton";
          enabled = true;
        }
        {
          id = "battery";
          enabled = true;
        }
      ];
      spacing = 0;
      innerPadding = 4;
      bottomGap = 0;
      transparency = 0.8;
      widgetTransparency = 1;
      squareCorners = true;
      noBackground = true;
      gothCornersEnabled = false;
      gothCornerRadiusOverride = false;
      gothCornerRadiusValue = 0;
      borderEnabled = true;
      borderColor = "secondary";
      borderOpacity = 0.31;
      borderThickness = 1;
      widgetOutlineEnabled = false;
      widgetOutlineColor = "secondary";
      widgetOutlineOpacity = 0.07;
      widgetOutlineThickness = 1;
      fontScale = 1;
      autoHide = false;
      autoHideDelay = 250;
      openOnOverview = false;
      visible = true;
      popupGapsAuto = true;
      popupGapsManual = 4;
      maximizeDetection = true;
    }
  ];
  desktopClockEnabled = false;
  desktopClockStyle = "analog";
  desktopClockTransparency = 0.8;
  desktopClockColorMode = "primary";
  desktopClockCustomColor = {
    r = 1;
    g = 1;
    b = 1;
    a = 1;
    hsvHue = -1;
    hsvSaturation = 0;
    hsvValue = 1;
    hslHue = -1;
    hslSaturation = 0;
    hslLightness = 1;
    valid = true;
  };
  desktopClockShowDate = true;
  desktopClockShowAnalogNumbers = false;
  desktopClockShowAnalogSeconds = true;
  desktopClockX = -1;
  desktopClockY = -1;
  desktopClockWidth = 280;
  desktopClockHeight = 180;
  desktopClockDisplayPreferences = [
    "all"
  ];
  systemMonitorEnabled = false;
  systemMonitorShowHeader = true;
  systemMonitorTransparency = 0.8;
  systemMonitorColorMode = "primary";
  systemMonitorCustomColor = {
    r = 1;
    g = 1;
    b = 1;
    a = 1;
    hsvHue = -1;
    hsvSaturation = 0;
    hsvValue = 1;
    hslHue = -1;
    hslSaturation = 0;
    hslLightness = 1;
    valid = true;
  };
  systemMonitorShowCpu = true;
  systemMonitorShowCpuGraph = true;
  systemMonitorShowCpuTemp = true;
  systemMonitorShowGpuTemp = false;
  systemMonitorGpuPciId = "";
  systemMonitorShowMemory = true;
  systemMonitorShowMemoryGraph = true;
  systemMonitorShowNetwork = true;
  systemMonitorShowNetworkGraph = true;
  systemMonitorShowDisk = true;
  systemMonitorShowTopProcesses = false;
  systemMonitorTopProcessCount = 3;
  systemMonitorTopProcessSortBy = "cpu";
  systemMonitorGraphInterval = 60;
  systemMonitorLayoutMode = "auto";
  systemMonitorX = -1;
  systemMonitorY = -1;
  systemMonitorWidth = 320;
  systemMonitorHeight = 480;
  systemMonitorDisplayPreferences = [
    "all"
  ];
  systemMonitorVariants = [

  ];
  desktopWidgetPositions = {
  };
  desktopWidgetGridSettings = {
  };
  desktopWidgetInstances = [

  ];
  configVersion = 4;
}
