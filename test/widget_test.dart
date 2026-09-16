import 'package:flutter_test/flutter_test.dart';
import 'package:rick_and_morty_app/main.dart';
import 'package:rick_and_morty_app/models/episode_model.dart';
import 'package:rick_and_morty_app/providers/favorites_provider.dart';
import 'package:rick_and_morty_app/providers/watched_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  testWidgets('App smoke test - loads Rick and Morty App',
      (WidgetTester tester) async {
    await tester.pumpWidget(const RickAndMortyApp());
    expect(find.byType(RickAndMortyApp), findsOneWidget);
  });

  test('Episode Model correctly parses Season and Episode numbers', () {
    final episode = Episode(
      id: 9,
      name: 'Something Ricked This Way Comes',
      airDate: 'March 24, 2014',
      episode: 'S01E09',
      characters: ['https://rickandmortyapi.com/api/character/1'],
      url: 'https://rickandmortyapi.com/api/episode/9',
      created: '2017-11-10T12:56:34.789Z',
    );

    expect(episode.seasonNumber, 1);
    expect(episode.episodeNumber, 9);
    expect(episode.thumbnailPlaceholder,
        'https://rickandmortyapi.com/api/character/avatar/1.jpeg');
  });

  test('FavoritesProvider adds and sorts episodes in ascending order', () async {
    final provider = FavoritesProvider(autoLoad: false);
    final ep1 = Episode(
      id: 2,
      name: 'Lawnmower Dog',
      airDate: 'December 9, 2013',
      episode: 'S01E02',
      characters: [],
      url: '',
      created: '',
    );
    final ep2 = Episode(
      id: 1,
      name: 'Pilot',
      airDate: 'December 2, 2013',
      episode: 'S01E01',
      characters: [],
      url: '',
      created: '',
    );

    // Adiciona na ordem inversa
    await provider.toggleFavorite(ep1);
    await provider.toggleFavorite(ep2);

    expect(provider.count, 2);
    // Deve estar ordenado em ordem crescente S01E01, S01E02
    expect(provider.favorites.first.episode, 'S01E01');
    expect(provider.favorites.last.episode, 'S01E02');
  });

  test('WatchedProvider adds and toggles watched episodes', () async {
    final provider = WatchedProvider(autoLoad: false);
    final ep = Episode(
      id: 1,
      name: 'Pilot',
      airDate: 'December 2, 2013',
      episode: 'S01E01',
      characters: [],
      url: '',
      created: '',
    );

    await provider.toggleWatched(ep);
    expect(provider.isWatched(1), true);

    await provider.toggleWatched(ep);
    expect(provider.isWatched(1), false);
  });
}
