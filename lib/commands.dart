class Commands {

  // ===============================
  // AUDIO
  // ===============================

  static const volumeUp = "ssap://audio/volumeUp";
  static const volumeDown = "ssap://audio/volumeDown";
  static const setVolume = "ssap://audio/setVolume";
  static const getVolume = "ssap://audio/getVolume";
  static const setMute = "ssap://audio/setMute";
  static const getMute = "ssap://audio/getStatus";

  // ===============================
  // 🔌 POWER / SYSTEM
  // ===============================

  static const turnOff = "ssap://system/turnOff";
  static const getSystemInfo = "ssap://system/getSystemInfo";
  static const getPowerState = "ssap://com.webos.service.tvpower/power/getPowerState";

  // ===============================
  // 📺 CHANNEL / TV
  // ===============================

  static const channelUp = "ssap://tv/channelUp";
  static const channelDown = "ssap://tv/channelDown";
  static const getChannelList = "ssap://tv/getChannelList";
  static const getCurrentChannel = "ssap://tv/getCurrentChannel";
  static const openChannel = "ssap://tv/openChannel";

  // ===============================
  // 🎛 INPUTS
  // ===============================

  static const listInputs = "ssap://tv/getExternalInputList";
  static const switchInput = "ssap://tv/switchInput";

  // ===============================
  // 📱 APPS
  // ===============================

  static const listApps =
      "ssap://com.webos.applicationManager/listApps";

  static const launchApp =
      "ssap://system.launcher/launch";

  static const closeApp =
      "ssap://system.launcher/close";

  static const getForegroundApp =
      "ssap://com.webos.applicationManager/getForegroundAppInfo";

  // ===============================
  // REMOTE KEYS (IME)
  // ===============================

  static const enter = "ssap://com.webos.service.ime/sendEnterKey";
  static const back = "ssap://com.webos.service.ime/sendBackKey";
  static const exit = "ssap://com.webos.service.ime/sendExitKey";

  static const up = "ssap://com.webos.service.ime/sendUpKey";
  static const down = "ssap://com.webos.service.ime/sendDownKey";
  static const left = "ssap://com.webos.service.ime/sendLeftKey";
  static const right = "ssap://com.webos.service.ime/sendRightKey";

  static const red = "ssap://com.webos.service.ime/sendRedKey";
  static const green = "ssap://com.webos.service.ime/sendGreenKey";
  static const yellow = "ssap://com.webos.service.ime/sendYellowKey";
  static const blue = "ssap://com.webos.service.ime/sendBlueKey";

  static const play = "ssap://media.controls/play";
  static const pause = "ssap://media.controls/pause";
  static const stop = "ssap://media.controls/stop";
  static const rewind = "ssap://media.controls/rewind";
  static const fastForward = "ssap://media.controls/fastForward";

  // ===============================
  // 🖱 MAGIC REMOTE (MOUSE)
  // ===============================

  static const moveMouse =
      "ssap://com.webos.service.networkinput/mouse/move";

  static const clickMouse =
      "ssap://com.webos.service.networkinput/mouse/click";

  static const scrollMouse =
      "ssap://com.webos.service.networkinput/mouse/scroll";

  // ===============================
  // KEYBOARD INPUT
  // ===============================

  static const insertText =
      "ssap://com.webos.service.ime/insertText";

  static const deleteCharacters =
      "ssap://com.webos.service.ime/deleteCharacters";

  // ===============================
  // MEDIA INFO
  // ===============================

  static const getMediaInfo =
      "ssap://media/getCurrentMedia";

  static const getPlayingStatus =
      "ssap://media.controls/getPlayState";

  // ===============================
  // SETTINGS
  // ===============================

  static const getSettings =
      "ssap://settings/getSystemSettings";

  static const setSettings =
      "ssap://settings/setSystemSettings";

  // ===============================
  // NETWORK
  // ===============================

  static const getNetworkStatus =
      "ssap://com.webos.service.connectionmanager/getStatus";

}