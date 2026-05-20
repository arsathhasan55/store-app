import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/review_model.dart';

class ReviewService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get reviews for a specific product
  Stream<List<ReviewModel>> getProductReviews(String productId) {
    return _firestore
        .collection('reviews')
        .where('productId', isEqualTo: productId)
        .snapshots()
        .map((snapshot) {
      final reviews = snapshot.docs
          .map((doc) => ReviewModel.fromMap(doc.data(), doc.id))
          .toList();
      // Sort in-memory to avoid requiring a composite index
      reviews.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return reviews;
    });
  }

  // Get reviews by a specific user
  Stream<List<ReviewModel>> getUserReviews(String uid) {
    if (uid.isEmpty) return Stream.value([]);
    return _firestore
        .collection('reviews')
        .where('userId', isEqualTo: uid)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ReviewModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // Add a new review
  Future<void> addReview(ReviewModel review) async {
    await _firestore.collection('reviews').add(review.toMap());
  }

  // Delete a review (optional, but good to have)
  Future<void> deleteReview(String reviewId) async {
    await _firestore.collection('reviews').doc(reviewId).delete();
  }
}
