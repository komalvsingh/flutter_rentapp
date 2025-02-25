import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'item.dart'; // Import the Item model
import 'item_detail_screen.dart'; // Import the detail screen

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  _ExploreScreenState createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  List<dynamic> allItems = [];
  List<dynamic> filteredItems = [];
  String _selectedCategory = 'All';
  String _searchQuery = '';
  RangeValues _priceRange = RangeValues(0, 10000);
  bool _isFilterVisible = false;
  bool _isLoading = true;

  final List<String> categories = [
    'All',
    'Cameras',
    'Lenses',
    'Audio',
    'Lighting',
    'Stabilizers',
    'Studios'
  ];

  @override
  void initState() {
    super.initState();
    loadItems();
  }

  Future<void> loadItems() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final String response = await rootBundle.loadString(
          'assets/items.json'); // Using the same JSON file as HomeScreen
      final data = await json.decode(response);

      setState(() {
        allItems = data;
        filteredItems = allItems;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading items: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void filterItems() {
    setState(() {
      filteredItems = allItems.where((item) {
        final matchesCategory =
            _selectedCategory == 'All' || item['category'] == _selectedCategory;
        final matchesSearch = item['title']
            .toString()
            .toLowerCase()
            .contains(_searchQuery.toLowerCase());
        final price = double.parse(item['price'].toString());
        final matchesPrice =
            price >= _priceRange.start && price <= _priceRange.end;

        return matchesCategory && matchesSearch && matchesPrice;
      }).toList();
    });
  }

  // Function to navigate to ItemDetailScreen
  void _navigateToDetailScreen(BuildContext context, dynamic itemData) {
    // Convert the JSON item to an Item object
    final item = Item(
      id: itemData['id']?.toString() ??
          itemData['title']
              .hashCode
              .toString(), // Convert to String if not null
      name: itemData['title'],
      description: itemData['description'] ?? 'No description available',
      price: int.parse(
          itemData['price'].toString()), // Parse as int instead of double
      imageUrl: itemData['image'],
      category: itemData['category'] ?? 'Uncategorized',
      location: itemData['location'] ?? 'Unknown',
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ItemDetailScreen(item: item),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: Text(
          "Explore Equipment",
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list, color: Colors.white),
            onPressed: () {
              setState(() {
                _isFilterVisible = !_isFilterVisible;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search equipment...",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                  filterItems();
                });
              },
            ),
          ),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : filteredItems.isEmpty
                    ? Center(child: Text('No items found'))
                    : GridView.builder(
                        padding: EdgeInsets.all(12),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.8, // Reduced card size
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: filteredItems.length,
                        itemBuilder: (context, index) {
                          final item = filteredItems[index];
                          return GestureDetector(
                            onTap: () => _navigateToDetailScreen(context, item),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.2),
                                    blurRadius: 8,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(12)),
                                    child: Hero(
                                      tag:
                                          'item-image-${item['id']?.toString() ?? item['title'].hashCode.toString()}',
                                      child: Image.network(
                                        item['image'],
                                        height: 140, // Increased image height
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item['title'],
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Icon(Icons.location_on,
                                                size: 12, color: Colors.grey),
                                            SizedBox(width: 4),
                                            Text(
                                              item['location'],
                                              style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 8),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "₹${item['price']}/day",
                                              style: TextStyle(
                                                color: Colors.deepPurple,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                            ),
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: Colors.deepPurple,
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                "Rent Now",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
