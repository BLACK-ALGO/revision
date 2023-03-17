// ignore_for_file: file_names, prefer_const_constructors, unused_element, prefer_const_literals_to_create_immutables, non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _shoppingBox = Hive.box('Shopping_box');
  List<Map<String, dynamic>> _items = [];
  final TextEditingController name = TextEditingController();
  final TextEditingController quantity = TextEditingController();

  @override
  void initState() {
    super.initState();
    _reFreshItem();
  }

  void _reFreshItem() {
    final data = _shoppingBox.keys.map((key) {
      final item = _shoppingBox.get(key);
      return {"key": key, "name": item["name"], "quantity": item["quantity"]};
    }).toList();

    setState(() {
      _items = data.reversed.toList();
    });
  }

  Future<void> _createItem(Map<String, dynamic> newItem) async {
    await _shoppingBox.add(newItem);
    _reFreshItem();
    // print("amount of Box ${_shoppingBox.length}");
  }

  Future<void> _updateItem(int itemKey, Map<String, dynamic> Item) async {
    await _shoppingBox.put(itemKey, Item);
    _reFreshItem();
    // print("amount of Box ${_shoppingBox.length}");
  }

  Future<void> _deleteItem(int itemKey, Map<String, dynamic> Item) async {
    await _shoppingBox.delete(itemKey);
    _reFreshItem();
    // print("amount of Box ${_shoppingBox.length}");
  }

  void _showForm(BuildContext context, int? itemkey) async {
    if (itemkey != null) {
      final existingItem =
          _items.firstWhere((element) => element['key'] == itemkey);
      name.text = existingItem['name'];
      quantity.text = existingItem['quantity'];
    }
    showModalBottomSheet(
        context: context,
        elevation: 5,
        isScrollControlled: true,
        builder: (_) => Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.top,
                top: 15,
                left: 15,
                right: 15,
              ),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    TextField(
                      controller: name,
                      decoration: InputDecoration(hintText: 'Neme'),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    TextField(
                      controller: quantity,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(hintText: 'Qaulity'),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    ElevatedButton(
                        onPressed: () async {
                          if (itemkey == null) {
                            _createItem(
                                {"name": name.text, "quatity": quantity.text});
                          }

                          name.text = '';
                          quantity.text = '';
                          if (itemkey != null) {
                            _updateItem(itemkey, {
                              "name": name.text.trim(),
                              "quatity": quantity.text.trim()
                            });
                          }
                          Navigator.of(context).pop();
                        },
                        child: Text(itemkey == null ? 'Create' : 'Update'))
                  ]),
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Crud Localy'),
      ),
      body: ListView.builder(
          itemCount: _items.length,
          itemBuilder: (_, index) {
            final currentItem = _items[index];
            return Card(
              color: Colors.orange.shade100,
              elevation: 3,
              child: ListTile(
                title: Text(currentItem['name']),
                subtitle: Text(currentItem['quantity']),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                        onPressed: () => _showForm(context, currentItem['key']),
                        icon: Icon(Icons.edit)),
                    IconButton(
                        onPressed: () => _deleteItem(currentItem['key']),
                        icon: Icon(Icons.delete))
                  ],
                ),
              ),
            );
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(context, null),
        child: const Icon(Icons.add),
      ),
    );
  }
}
