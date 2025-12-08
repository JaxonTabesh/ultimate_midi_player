import 'package:flutter_test/flutter_test.dart';
import 'package:ultimate_midi_player/ultimate_midi_player.dart';
import 'package:ultimate_midi_player/ultimate_midi_player_platform_interface.dart';
import 'package:ultimate_midi_player/ultimate_midi_player_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockUltimateMidiPlayerPlatform
    with MockPlatformInterfaceMixin
    implements UltimateMidiPlayerPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final UltimateMidiPlayerPlatform initialPlatform = UltimateMidiPlayerPlatform.instance;

  test('$MethodChannelUltimateMidiPlayer is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelUltimateMidiPlayer>());
  });

  test('getPlatformVersion', () async {
    UltimateMidiPlayer ultimateMidiPlayerPlugin = UltimateMidiPlayer();
    MockUltimateMidiPlayerPlatform fakePlatform = MockUltimateMidiPlayerPlatform();
    UltimateMidiPlayerPlatform.instance = fakePlatform;

    expect(await ultimateMidiPlayerPlugin.getPlatformVersion(), '42');
  });
}
