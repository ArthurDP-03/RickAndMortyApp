class AppConstants {
  static const String appName = 'RM Guide';
  static const String defaultApiBaseUrl = 'https://rickandmortyapi.com/api';

  static const String storageKeyFavorites = 'rm_favorites_episodes';
  static const String storageKeyWatched = 'rm_watched_episodes';
  static const String storageKeyUser = 'rm_current_user';
  static const String storageKeyUsersList = 'rm_registered_users';
  static const String storageKeyIsLoggedIn = 'rm_is_logged_in';

  static const int itemsPerPage = 20;
  static const int displayPageLimit = 10;

  static const String placeholderEpisode =
      'https://rickandmortyapi.com/api/character/avatar/1.jpeg';
}
