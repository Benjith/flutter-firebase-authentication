import 'package:firebase_authentication/restaurant_model.dart';
import 'package:flutter/material.dart';

class CartPage extends StatefulWidget {
  final List<CategoryDish> cartItems;

  const CartPage({Key key, this.cartItems}) : super(key: key);

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  Map groupedItem;
  createNewGroupedList() {
    setState(() {
      groupedItem = null;
      groupedItem = widget.cartItems.groupBy((m) => m.dishId);
    });
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        groupedItem = widget.cartItems.groupBy((m) => m.dishId);
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order Summary'),
        actions: [
          IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                print(groupedItem.entries.length);
                // print(groupedItem.entries.elementAt(i).value[0].dishName);
              })
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(5.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black45),
                ),
                child: groupedItem == null
                    ? CircularProgressIndicator()
                    : SingleChildScrollView(
                        child: Column(
                          children: [
                            Container(
                              width: double.infinity,
                              height: 50.0,
                              color: Colors.green,
                              child: Center(
                                  child: Text(
                                '${groupedItem.entries.length} dishes - ${widget.cartItems.length} items',
                                style: TextStyle(fontSize: 18.0),
                              )),
                            ),
                            for (var i = 0; i < groupedItem.entries.length; i++)
                              ListTile(
                                isThreeLine: true,
                                leading: Icon(
                                  Icons.radio_button_checked,
                                  color: groupedItem.entries
                                              .elementAt(i)
                                              .value[0]
                                              .dishType ==
                                          1
                                      ? Colors.red
                                      : Colors.blue,
                                ),
                                title: Text(groupedItem.entries
                                    .elementAt(i)
                                    .value[0]
                                    .dishName),
                                subtitle: Column(
                                  children: [
                                    SizedBox(
                                      height: 5.0,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('INR ' +
                                            groupedItem.entries
                                                .elementAt(i)
                                                .value[0]
                                                .dishPrice
                                                .toString() +
                                            '₹'),
                                        Text(groupedItem.entries
                                                .elementAt(i)
                                                .value[0]
                                                .dishCalories
                                                .toString() +
                                            ' Calories'),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 5.0,
                                    ),
                                    Text(groupedItem.entries
                                        .elementAt(i)
                                        .value[0]
                                        .dishDescription),
                                    SizedBox(
                                      height: 5.0,
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                          color: Colors.green,
                                          borderRadius:
                                              BorderRadius.circular(50.0)),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: IconButton(
                                              icon: Icon(Icons.remove),
                                              onPressed: () {
                                                setState(() {
                                                  if (groupedItem.entries
                                                          .elementAt(i)
                                                          .value
                                                          .length ==
                                                      1) return;
                                                  for (var item
                                                      in widget.cartItems) {
                                                    if (item.dishId ==
                                                        widget.cartItems[i]
                                                            .dishId) {
                                                      widget.cartItems
                                                          .remove(item);
                                                      createNewGroupedList();
                                                      return;
                                                    }
                                                  }
                                                });
                                              },
                                            ),
                                          ),
                                          Text(
                                            groupedItem.entries
                                                .elementAt(i)
                                                .value
                                                .length
                                                .toString(),
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Expanded(
                                            child: IconButton(
                                              icon: Icon(Icons.add),
                                              onPressed: () {
                                                setState(() {
                                                  widget.cartItems
                                                      .add(widget.cartItems[i]);
                                                  createNewGroupedList();
                                                });
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      height: 5.0,
                                    ),
                                    if (groupedItem.entries
                                        .elementAt(i)
                                        .value[0]
                                        .addonCat
                                        .isNotEmpty)
                                      Text(
                                        'Customization available',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                  ],
                                ),
                                trailing: Image.network(
                                  groupedItem.entries
                                      .elementAt(i)
                                      .value[0]
                                      .dishImage,
                                  fit: BoxFit.fill,
                                  height: 70,
                                  width: 70,
                                ),
                              ),
                            Divider()
                          ],
                        ),
                      ),
              ),
            ),
            SizedBox(
              height: 2.0,
            ),
            MaterialButton(
              height: 50.0,
              color: Colors.green,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadiusDirectional.circular(50.0)),
              onPressed: () async {
                bool result = await showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                          title: Text('Order successfully placed'),
                          actions: [
                            FlatButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: Text('Shop more'),
                            )
                          ],
                        ));
                if (result) {
                  Navigator.pop(context, true);
                }
              },
              child: Text(
                'Place Order',
                style: TextStyle(fontSize: 22.0),
              ),
            )
          ],
        ),
      ),
    );
  }
}

extension Iterables<E> on List<E> {
  Map<K, List<E>> groupBy<K>(K Function(E) keyFunction) => fold(
      <K, List<E>>{},
      (Map<K, List<E>> map, E element) =>
          map..putIfAbsent(keyFunction(element), () => <E>[]).add(element));
}
