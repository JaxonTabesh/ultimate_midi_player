
import 'ultimate_midi_player_platform_interface.dart';

class UltimateMidiPlayer {
  Future<String?> getPlatformVersion() {
    return UltimateMidiPlayerPlatform.instance.getPlatformVersion();
  }
}
