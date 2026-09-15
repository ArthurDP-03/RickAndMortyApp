/// Modelo de Informações de Paginação da API Rick and Morty
class ApiPageInfo {
  final int count;
  final int pages;
  final String? next;
  final String? prev;

  ApiPageInfo({
    required this.count,
    required this.pages,
    this.next,
    this.prev,
  });

  factory ApiPageInfo.fromJson(Map<String, dynamic> json) {
    return ApiPageInfo(
      count: json['count'] is int ? json['count'] as int : int.tryParse(json['count'].toString()) ?? 0,
      pages: json['pages'] is int ? json['pages'] as int : int.tryParse(json['pages'].toString()) ?? 1,
      next: json['next'] as String?,
      prev: json['prev'] as String?,
    );
  }
}

/// Wrapper de resposta paginada para listas
class ApiResponse<T> {
  final ApiPageInfo info;
  final List<T> results;

  ApiResponse({
    required this.info,
    required this.results,
  });
}
