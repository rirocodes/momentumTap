import 'dart:async';

import 'package:logging/logging.dart';
import 'package:flutter_soloud/flutter_soloud.dart';

class AudioController {
  static final Logger _log = Logger('AudioController');
  SoLoud? _soloud;
  SoundHandle? _musicHandle;
  Future<void> initialize() async {
    _soloud = SoLoud.instance;
    await _soloud!.init();
  }

  void dispose() {
    _soloud?.deinit();
  }

  Future<void> playSound(String assetKey) async {
    try {
      final source = await _soloud!.loadAsset(assetKey);
      await _soloud!.play(source);
    } on SoLoudException catch (e) {
      _log.severe("Cannot play sound '$assetKey'. Ignoring.", e);
    }
  }

  bool isMusicOn() {
    return _musicHandle != null;
  }

  Future<void> startMusic() async {
    if (_musicHandle != null) {
      if (_soloud!.getIsValidVoiceHandle(_musicHandle!)) {
        _log.info('Music is already playing. Stopping first.');
        await _soloud!.stop(_musicHandle!);
      }
    }
    _log.info('Loading music');
    final musicSource =
        await _soloud!.loadAsset('assets/music/bg.mp3', mode: LoadMode.disk);
    musicSource.allInstancesFinished.first.then((_) {
      _soloud!.disposeSource(musicSource);
      _log.info('Music source disposed');
      _musicHandle = null;
    });

    _log.info('Playing music');
    _musicHandle = await _soloud!.play(
      musicSource,
      volume: 0.3,
      looping: true,
      loopingStartAt: const Duration(seconds: 8),
    );
  }

  void fadeOutMusic() {
    if (_musicHandle == null) {
      _log.info('Nothing to fade out');
      return;
    }
    const length = Duration(seconds: 8);
    _soloud!.fadeVolume(_musicHandle!, 0, length);
    _soloud!.scheduleStop(_musicHandle!, length);
  }

  void applyFilter() {
    _soloud!.filters.freeverbFilter.activate();
    _soloud!.filters.freeverbFilter.wet.value = 0.5;
    // _soloud!.filters.freeverbFilter.wet.value = 0.2;
    // _soloud!.filters.freeverbFilter.roomSize.value = 0.9;
  }

  void removeFilter() {
    _soloud!.filters.freeverbFilter.deactivate();
  }
}
