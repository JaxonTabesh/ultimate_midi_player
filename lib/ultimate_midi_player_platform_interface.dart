import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'ultimate_midi_player_method_channel.dart';

abstract class UltimateMidiPlayerPlatform extends PlatformInterface {
  /// Constructs a UltimateMidiPlayerPlatform.
  UltimateMidiPlayerPlatform() : super(token: _token);

  static final Object _token = Object();

  static UltimateMidiPlayerPlatform _instance = MethodChannelUltimateMidiPlayer();

  /// The default instance of [UltimateMidiPlayerPlatform] to use.
  ///
  /// Defaults to [MethodChannelUltimateMidiPlayer].
  static UltimateMidiPlayerPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [UltimateMidiPlayerPlatform] when
  /// they register themselves.
  static set instance(UltimateMidiPlayerPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
