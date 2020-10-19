import 'package:cached_network_image/cached_network_image.dart';
import 'package:disefood/model/cart.dart';
import 'package:disefood/screen/customer_dialog/order_failed_dialog.dart';
import 'package:disefood/screen/customer_utilities/sqlite_helper.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:toast/toast.dart';

class EditOrderAmountDialog extends StatefulWidget {
  final int shopId;
  final int foodId;
  final String foodName;
  final String foodImg;
  final int foodPrice;
  const EditOrderAmountDialog({
    Key key,
    @required this.foodName,
    @required this.foodImg,
    @required this.foodId,
    @required this.shopId,
    @required this.foodPrice,
  }) : super(key: key);
  @override
  _EditOrderAmountDialogState createState() => _EditOrderAmountDialogState();
}

class _EditOrderAmountDialogState extends State<EditOrderAmountDialog> {
  Logger logger = Logger();
  int foodId;
  String shopId;
  String foodName;
  String foodImg;
  int foodQuantity = 1;
  int foodPrice;
  final myController = TextEditingController();
  @override
  void initState() {
    super.initState();

    setState(() {
      foodName = widget.foodName;
      foodImg = widget.foodImg;
      foodId = widget.foodId;
      shopId = widget.shopId.toString();
      foodPrice = widget.foodPrice;
    });
    Future.microtask(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      elevation: 8,
      backgroundColor: Colors.transparent,
      child: _buildChild(context),
    );
  }

  void add() {
    foodQuantity++;
    checkButtonRemove();
    setState(() {});
  }

  void remove() {
    if (foodQuantity > 0) {
      foodQuantity--;
      checkButtonRemove();
      setState(() {});
    }
  }

  void checkButtonRemove() {
    if (foodQuantity <= 0) {
      setState(() {});
    } else {
      setState(() {});
    }
  }

  void showToast(String msg) {
    Toast.show(msg, context,
        duration: Toast.LENGTH_LONG,
        textColor: Colors.white,
        backgroundColor: const Color(0xff1BCC2E),
        gravity: Toast.CENTER);
  }

  Future<Null> addFoodToCart() async {
    Map<String, dynamic> orderMap = Map();
    orderMap['shopId'] = shopId;
    orderMap['foodId'] = foodId;
    orderMap['foodName'] = foodName;
    orderMap['foodQuantity'] = foodQuantity;
    orderMap['foodDescription'] = myController.text;
    orderMap['foodPrice'] = foodPrice;
    orderMap['foodSumPrice'] = foodPrice * foodQuantity;
    orderMap['foodImg'] = foodImg;
    print('orderMap Data :  ${orderMap.toString()} ');
    CartModel cartModel = CartModel.fromJson(orderMap);

    var object = await SQLiteHelper().readAllDataFromSQLite();

    if (object.length == 0) {
      await SQLiteHelper().insertDataToSQLite(cartModel).then(
        (value) {
          showToast("เพิ่มไปยังตะกร้าเรียบร้อยแล้ว");
          print("Insert Success");
        },
      );
    } else {
      String idShopSQLite = object[0].shopId;
      print(idShopSQLite);
      if (shopId == idShopSQLite) {
        await SQLiteHelper().insertDataToSQLite(cartModel).then(
          (value) {
            showToast("เพิ่มไปยังตะกร้าเรียบร้อยแล้ว");
            print("Insert Success");
          },
        );
      } else {
        showDialog(context: context, builder: (context) => OrderFailed());
      }
    }
  }

  _buildChild(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Container(
        child: Card(
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Stack(
                children: <Widget>[
                  CachedNetworkImage(
                    imageUrl:
                        'https://disefood.s3-ap-southeast-1.amazonaws.com/$foodImg',
                    height: 120,
                    width: double.maxFinite,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Center(
                        child: Container(
                            margin: EdgeInsets.only(top: 50, bottom: 35),
                            child: CircularProgressIndicator(
                              strokeWidth: 5.0,
                              valueColor: AlwaysStoppedAnimation(
                                  const Color(0xffF6A911)),
                            ))),
                    errorWidget: (context, url, error) => Container(
                      height: 120,
                      width: double.maxFinite,
                      color: Colors.orange,
                      child: Center(
                        child: Icon(
                          Icons.fastfood,
                          size: 50,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  // These values are based on trial & error method
                ],
              ),
              Container(
                margin: EdgeInsets.only(left: 15),
                padding: EdgeInsets.only(top: 5),
                alignment: Alignment.centerLeft,
                height: 30,
                child: Text(
                  "$foodName",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
              Divider(
                thickness: 8,
              ),
              Container(
                height: 50,
                padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                child: TextFormField(
                  controller: myController,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.only(left: 15),
                    hintText: 'คำแนะนำพิเศษ : ไม่จำเป็นต้องระบุ',
                    hintStyle: TextStyle(color: Colors.black38, fontSize: 14),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black38)),
                    enabledBorder: new OutlineInputBorder(
                      borderSide: new BorderSide(color: Colors.black38),
                    ),
                  ),
                ),
              ),
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                      width: 40,
                      height: 30,
                      child: FloatingActionButton(
                        backgroundColor: Colors.orange,
                        onPressed: () {
                          remove();
                        },
                        child: Icon(
                          Icons.remove,
                          size: 30,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(
                          left: 20, right: 20, top: 10, bottom: 10),
                      child: new Text(
                        '$foodQuantity',
                        style: new TextStyle(fontSize: 20.0),
                      ),
                    ),
                    SizedBox(
                      width: 40,
                      height: 30,
                      child: FloatingActionButton(
                        backgroundColor: Colors.orange,
                        onPressed: () {
                          add();
                        },
                        child: Icon(
                          Icons.add,
                          size: 30,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(left: 15, right: 15, bottom: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 140,
                      child: RaisedButton(
                        elevation: 8,
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        padding: EdgeInsets.only(left: 20, right: 20),
                        color: Colors.white,
                        child: Text(
                          "ยกเลิก",
                          style: TextStyle(
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                        ),
                      ),
                    ),
                    Container(
                      width: 140,
                      child: RaisedButton(
                        elevation: 8,
                        onPressed: () {
                          if (foodQuantity == 0) {
                            Navigator.of(context).pop();
                          } else {
                            addFoodToCart();
                            Navigator.of(context).pop();
                          }
                        },
                        padding: EdgeInsets.only(left: 20, right: 20),
                        color: Colors.orange,
                        child: Text(
                          "ตกลง",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
