import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shopping_list/data/categories.dart';
import 'package:shopping_list/widgets/grocery.dart';
import 'package:shopping_list/widgets/new_item.dart';
import 'package:shopping_list/models/grocery_item.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class GroceriesScreen extends StatefulWidget {
  const GroceriesScreen({super.key});

  @override
  State<GroceriesScreen> createState() => _GroceriesScreenState();
}

class _GroceriesScreenState extends State<GroceriesScreen> {
  List<GroceryItem> _groceryItems = [];
  late Future<List<GroceryItem>> _loadedItems;
  String? _error;
  final _mainUrlString = 'flutter-course-5166b-default-rtdb.firebaseio.com';

  @override
  void initState() {
    super.initState();
    _loadedItems = _loadItems();
  }

  Future<List<GroceryItem>> _loadItems() async {
    final url = Uri.https(_mainUrlString,
        'shopping-list.json');

      final response = await http.get(url);
      if (response.statusCode >= 400) {
        // setState(() {
        //   _error = 'Error fetching data. Please try again later';
        // });
        throw Exception('Failed to fetch grocery items. Please try again');
      }

      if (response.body == 'null') {
        return [];
      }

      final Map<String, dynamic> listData = json.decode(response.body);
      final List<GroceryItem> _loadedItems = [];
      for (final item in listData.entries) {
        final category = categories.entries
            .firstWhere(
                (catItem) => catItem.value.title == item.value['category'])
            .value;
        _loadedItems.add(GroceryItem(
            id: item.key,
            name: item.value['name'],
            quantity: item.value['quantity'],
            category: category));
      }
        return _loadedItems;
  }

  void _addItem() async {
    final newItem = await Navigator.of(context).push<GroceryItem>(
        MaterialPageRoute(builder: (ctx) => const NewItem()));

    if (newItem == null) {
      return;
    }

    setState(() {
      _groceryItems.add(newItem);
    });
  }

  void _removeItem(GroceryItem item) async {
    final index = _groceryItems.indexOf(item);
    setState(() {
      _groceryItems.remove(item);
    });

    final url = Uri.https(_mainUrlString, 'shopping-list/${item.id}.json');
    final response = await http.delete(url);
    print('Delete response code: ${response.statusCode}');

    if (response.statusCode >= 400) {
      setState(() {
        _groceryItems.insert(index, item);
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Scaffold(
            appBar: AppBar(
              title: const Text('Your Groceries'),
              actions: [
                IconButton(onPressed: _addItem, icon: const Icon(Icons.add))
              ],
            ),
            // Context je sadrzaj koji se prosledjuje, snapshot je trenutni
            // state
            body: FutureBuilder(future: _loadedItems, builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text(snapshot.error.toString(),),);
                }
                if (snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text(
                      'No items in list yet',
                      style: TextStyle(fontSize: 20),
                    ),
                  );
                }

                return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (ctx, index) => Dismissible(
                      key: ValueKey(snapshot.data![index].id),
                      background: Container(
                        color: Colors.redAccent,
                      ),
                      onDismissed: (direction) {
                        _removeItem(snapshot.data![index]);
                      },
                      child: ListTile(
                        title: Text(snapshot.data![index].name),
                        leading: Container(
                          width: 24,
                          height: 24,
                          color: snapshot.data![index].category.color,
                        ),
                        trailing: Text(snapshot.data![index].quantity.toString()),
                      ),
                    ));
            },),


            // child: SingleChildScrollView(
            //   child: Column(
            //     mainAxisAlignment: MainAxisAlignment.start,
            //     children: [
            //       ...groceryItems.map((grocery) => GroceryWidget(boxColor: grocery.category.color,
            //           title: grocery.name, groceryAmount: grocery.quantity))
            //     ],
            //   ),
            // ),
            // ),
            );
      },
    );
  }
}
