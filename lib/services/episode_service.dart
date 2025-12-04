
class Episode {
  final DateTime start;
  DateTime end;
  double totalIntensity;

  Episode({
    required this.start,
    required this.end,
    required this.totalIntensity,
  });

  Duration get duration => end.difference(start);
}

class EpisodeService {
  static final EpisodeService _instance = EpisodeService._internal();
  factory EpisodeService() => _instance;
  EpisodeService._internal();

  Episode? _currentEpisode;
  final List<Episode> episodes = [];

  static const movementGap = Duration(seconds: 15);
  static const episodeEndGap = Duration(seconds: 30);

  DateTime? _lastMovementTime;

  void registerMovement(double intensity) {
    final now = DateTime.now();

    if (_currentEpisode == null) {
      // Neue Episode?
      if (_lastMovementTime != null &&
          now.difference(_lastMovementTime!) < movementGap) {
        _currentEpisode = Episode(
          start: _lastMovementTime!,
          end: now,
          totalIntensity: intensity,
        );
      }
    } else {
      // Episode läuft
      _currentEpisode!.end = now;
      _currentEpisode!.totalIntensity += intensity;
    }

    // Episode beenden
    if (_currentEpisode != null &&
        now.difference(_currentEpisode!.end) > episodeEndGap) {
      episodes.add(_currentEpisode!);
      _currentEpisode = null;
    }

    _lastMovementTime = now;
  }
}
