import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/news_service.dart';
import '../models/news.dart';

final newsServiceProvider = Provider((ref) => NewsService());

final publishedNewsProvider = StreamProvider<List<News>>((ref) {
  final newsService = ref.watch(newsServiceProvider);
  return newsService.getPublishedNews();
});
