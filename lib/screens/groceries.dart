import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shopping_list/widgets/grocery.dart';
import 'package:shopping_list/widgets/new_item.dart';
import 'package:shopping_list/models/grocery_item.dart';

class GroceriesScreen extends StatefulWidget {
  const GroceriesScreen({super.key});

  @override
  State<GroceriesScreen> createState() => _GroceriesScreenState();
}

class _GroceriesScreenState extends State<GroceriesScreen> {
  final List<GroceryItem> _groceryItems = [];

  void _addItem() async {
    final result = await Navigator.of(context).push<GroceryItem>(
        MaterialPageRoute(builder: (ctx) => const NewItem())
    );
    if (result == null) {
      return;
    } else {
      setState(() {
        _groceryItems.add(result);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content = const Center(
      child: Text('No items in list yet', style: TextStyle(fontSize: 20),),
    );


    if (_groceryItems.isNotEmpty) {
      content = ListView.builder(
          itemCount: _groceryItems.length,
          itemBuilder: (ctx, index) =>
              Dismissible(
                key: ValueKey(_groceryItems[index].id),
                background: Container(color: Colors.redAccent,),
                onDismissed: (direction) {
                  setState(() {
                    _groceryItems.removeAt(index);
                  });
                },
                child: ListTile(
                  title: Text(_groceryItems[index].name),
                  leading: Container(
                    width: 24,
                    height: 24,
                    color: _groceryItems[index].category.color,
                  ),
                  trailing: Text(_groceryItems[index].quantity.toString()),
                ),
              ));

    }

      return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Your Groceries'),
              actions: [
                IconButton(onPressed: _addItem, icon: const Icon(Icons.add))
              ],
            ),
            body: content

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
