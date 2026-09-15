import 'package:cloud_firestore/cloud_firestore.dart';

/// Single shared data-access layer. Controllers never call
/// FirebaseFirestore.instance directly — they go through this.
class CrudService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> collection(String path) {
    return _db.collection(path);
  }

  Future<DocumentReference<Map<String, dynamic>>> create(
    String collectionPath,
    Map<String, dynamic> data,
  ) {
    return collection(collectionPath).add(data);
  }

  Future<void> update(
    String collectionPath,
    String docId,
    Map<String, dynamic> data,
  ) {
    return collection(collectionPath).doc(docId).update(data);
  }

  Future<void> delete(String collectionPath, String docId) {
    return collection(collectionPath).doc(docId).delete();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> streamCollection(
    String collectionPath,
  ) {
    return collection(collectionPath).snapshots();
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getDoc(
    String collectionPath,
    String docId,
  ) {
    return collection(collectionPath).doc(docId).get();
  }

  /// For controllers that need a multi-document runTransaction
  /// (e.g. sale + ingredient deduction together).
  FirebaseFirestore get instance => _db;
}