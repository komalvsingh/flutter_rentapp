import 'package:cloud_firestore/cloud_firestore.dart';
import 'item.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Fetch all items from Firestore
  Future<List<Item>> getItems() async {
    try {
      QuerySnapshot snapshot = await _db.collection('items').get();
      return snapshot.docs.map((doc) {
        return Item.fromMap(doc.data() as Map<String, dynamic>)
            .copyWith(id: doc.id);
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch items: $e');
    }
  }

  // Add a new item to Firestore
  Future<void> addItem(Item item) async {
    try {
      await _db.collection('items').add(item.toMap());
    } catch (e) {
      throw Exception('Failed to add item: $e');
    }
  }

  // Update an existing item in Firestore
  Future<void> updateItem(Item item) async {
    try {
      await _db.collection('items').doc(item.id).update(item.toMap());
    } catch (e) {
      throw Exception('Failed to update item: $e');
    }
  }

  // Delete an item from Firestore
  Future<void> deleteItem(String itemId) async {
    try {
      await _db.collection('items').doc(itemId).delete();
    } catch (e) {
      throw Exception('Failed to delete item: $e');
    }
  }

  // Fetch a single item by its ID from Firestore
  Future<Item?> getItemById(String itemId) async {
    try {
      DocumentSnapshot doc = await _db.collection('items').doc(itemId).get();
      if (doc.exists) {
        return Item.fromMap(doc.data() as Map<String, dynamic>)
            .copyWith(id: doc.id);
      } else {
        return null;
      }
    } catch (e) {
      throw Exception('Failed to fetch item: $e');
    }
  }
}
