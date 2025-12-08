import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'ultimate_midi_player_platform_interface.dart';

/// An implementation of [UltimateMidiPlayerPlatform] that uses method channels.
class MethodChannelUltimateMidiPlayer extends UltimateMidiPlayerPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('ultimate_midi_player');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
