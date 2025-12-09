import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'ultimate_midi_player_method_channel.dart';

typedef MidiProgress = ({
  String kind,
  int trackIndex,
  int stepIndex,
  int? noteIndex,
  int? note,
  int channel,
  int timeMs,
});

typedef MidiStep = ({
  List<int?> notes,
  List<int?> velocities,
  int startMs,
  int durationMs,
});

typedef MidiTrack = ({List<MidiStep> steps, int channel});

abstract class UltimateMidiPlayerPlatform extends PlatformInterface {
  UltimateMidiPlayerPlatform() : super(token: _token);

  static final Object _token = Object();

  static UltimateMidiPlayerPlatform _instance =
      MethodChannelUltimateMidiPlayer();

  static UltimateMidiPlayerPlatform get instance => _instance;

  static set instance(UltimateMidiPlayerPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Initializes the MIDI engine and prepares the audio backend.
  Future<void> init();

  /// Releases all native audio and MIDI resources.
  ///
  /// After calling this, the instance must be re-initialized via [init]
  /// before it can be used again.
  Future<void> dispose();

  /// Loads a SoundFont into the synthesizer for MIDI playback.
  ///
  /// If a SoundFont is already loaded, it will be replaced.
  Future<void> loadSoundFont();

  /// Unloads the currently active SoundFont from the synthesizer.
  Future<void> unloadSoundFont();

  /// Changes the active instrument (program) on the specified MIDI channel.
  ///
  /// [program] is the MIDI program number (0–127).
  /// [channel] is the MIDI channel (0–15).
  ///
  /// Once set, all subsequent notes sent on this [channel] will use the
  /// selected instrument until the program is changed again.
  Future<void> changeProgram({required int program, int channel = 0});

  /// Changes the output volume level on the specified MIDI channel.  ///
  /// [value] is the volume level (0–127).
  /// [channel] is the MIDI channel (0–15).
  Future<void> changeVolume({required int value, int channel = 0});

  /// Changes the stereo pan position on the specified MIDI channel.
  ///
  /// [value] is the pan position (0–127):
  /// - 0   = full left
  /// - 64  = center
  /// - 127 = full right
  ///
  /// [channel] is the MIDI channel (0–15).
  Future<void> changePan({required int value, int channel = 0});

  /// Turns on one or more MIDI notes immediately.
  ///
  /// [notes] is the list of MIDI note numbers.
  ///
  /// [velocities] controls the loudness:
  /// - If `velocities.length == 1`, that single velocity is used for all notes.
  /// - If `velocities.length == notes.length`, each note uses the corresponding velocity.
  /// - Otherwise, velocities are reused cyclically.
  /// - Defaults to [100].
  ///
  /// [channel] selects the MIDI channel (0–15). Defaults to 0.
  ///
  /// Example:
  /// ```dart
  /// // C major chord
  /// await notesOn(
  ///   notes: [60, 64, 67],
  ///   velocities: [100],
  /// );
  ///
  /// // Per-note velocity
  /// await notesOn(
  ///   notes: [60, 64, 67],
  ///   velocities: [90, 100, 110],
  ///   channel: 2,
  /// );
  ///
  /// // With rests
  /// await notesOn(
  ///   notes: [60, null, 67, 72],
  ///   velocities: [100],
  ///   channel: 1,
  /// );
  /// ```
  Future<void> notesOn({
    required List<int> notes,
    List<int> velocities,
    int channel = 0,
  });

  /// Turns off one or more currently sounding MIDI notes.
  ///
  /// [notes] defines the notes to turn off, using the same structure rules as [notesOn].
  ///
  /// [channel] selects the MIDI channel (0–15). Defaults to 0.
  ///
  /// Only notes that are currently active on this [channel] will be affected.
  Future<void> notesOff({required List<int> notes, int channel = 0});

  /// Plays multiple MIDI tracks concurrently on a shared timeline.
  ///
  /// [tracks] is a list of logical tracks (piano, bass, drums, etc.).
  ///
  /// Each track:
  /// - Defines its own MIDI [channel] (0–15)
  /// - Contains a list of timed [MidiStep] events
  /// - May contain `null` notes to represent rests
  ///
  /// Each [MidiStep]:
  /// - Uses [startMs] as an absolute start time
  /// - Uses [durationMs] as the hold length for all non-null notes in the step
  ///
  /// All tracks are mixed together and scheduled against a single unified
  /// playback timeline.
  ///
  /// Example:
  /// ```dart
  /// final pianoTrack = (
  ///   channel: 0,
  ///   steps: [
  ///     (
  ///       notes: [60, 64, 67],
  ///       velocities: [100],
  ///       startMs: 0,
  ///       durationMs: 400,
  ///     ),
  ///     (
  ///       notes: [62, 65, 69],
  ///       velocities: [100],
  ///       startMs: 400,
  ///       durationMs: 400,
  ///     ),
  ///   ],
  /// );
  ///
  /// final bassTrack = (
  ///   channel: 1,
  ///   steps: [
  ///     (
  ///       notes: [36],
  ///       velocities: [110],
  ///       startMs: 0,
  ///       durationMs: 800,
  ///     ),
  ///     (
  ///       notes: [null, 38],
  ///       velocities: [110],
  ///       startMs: 800,
  ///       durationMs: 400,
  ///     ),
  ///   ],
  /// );
  ///
  /// final drumTrack = (
  ///   channel: 9,
  ///   steps: [
  ///     (
  ///       notes: [36, null, 38],
  ///       velocities: [120],
  ///       startMs: 0,
  ///       durationMs: 200,
  ///     ),
  ///   ],
  /// );
  ///
  /// await playTracks(tracks: [pianoTrack, bassTrack, drumTrack]);
  /// ```
  Future<void> playTracks({required List<MidiTrack> tracks});

  /// Stops all currently scheduled MIDI tracks.
  ///
  /// Any timed or queued playback created via [playTracks] or other
  /// sequencing methods is immediately cancelled.
  Future<void> stopTracks();

  /// Immediately stops all sounding MIDI notes on all channels.
  ///
  /// This sends an emergency "all notes off" across every channel and
  /// silences the synthesizer instantly, regardless of current playback state.
  Future<void> stopAll();

  /// Emits an event whenever a scheduled [MidiStep] or note starts or ends.
  ///
  /// [kind] is one of:
  ///   - 'stepStart'
  ///   - 'stepEnd'
  ///   - 'noteStart'
  ///   - 'noteEnd'
  ///
  /// For step events:
  ///   - [noteIndex] and [note] are null.
  ///
  /// For note events:
  ///   - [noteIndex] is the index into that step's `notes` list.
  ///   - [note] is the MIDI note number.
  ///
  /// [trackIndex]: index into the `tracks` list passed to [playTracks].
  /// [stepIndex]: index into that track's `steps` list.
  /// [channel]: MIDI channel for that track.
  /// [timeMs]: absolute time offset in ms from the beginning of the sequence.
  Stream<MidiProgress> get progressStream;
}
