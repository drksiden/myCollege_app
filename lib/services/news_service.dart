import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/news.dart';

class NewsService {
  final _db = FirebaseFirestore.instance;

  // Получить ленту новостей (только опубликованные, по убыванию даты)
  Stream<List<News>> getPublishedNews() {
    return _db
        .collection('news')
        .where('isPublished', isEqualTo: true)
        .orderBy('publishedAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => News.fromJson({...doc.data(), 'id': doc.id}))
                  .toList(),
        );
  }
}
