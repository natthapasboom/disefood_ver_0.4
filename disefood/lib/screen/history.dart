import 'dart:convert';
import 'dart:ui';
import 'package:disefood/model/shop_id.dart';
import 'package:disefood/screen/home_customer.dart';
import 'package:disefood/screen/payment_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:disefood/model/orderList.dart';
import 'package:disefood/services/api_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:steps_indicator/steps_indicator.dart';

class History extends StatefulWidget {
  @override
  _HistoryState createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  int userId;
  Map jsonMap;
  Logger logger = Logger();
  bool isLoading = false;
  String token = '';
  var mapData;
  List list = List();
  var orderLists;
  ApiProvider apiProvider = ApiProvider();
  Future<OrderList> _orderLists;
  List<OrderDetails> orderDetail = [];
  List<OrderList> orderList = [];
  String _shopName;
  var orderDetailList;
  List returnedList = new List();
  OrderDetails food;
  @override
  void initState() {
    isLoading = false;
    _orderLists = orderByUserId();
    // logger.d(_orderLists);

    super.initState();
    Future.microtask(() {});
  }

  Future<OrderList> orderByUserId() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    userId = sharedPreferences.getInt('user_id');
    token = sharedPreferences.getString('token');

    try {
      if (userId != null) {
        var response = await apiProvider.getHistoryById(token);
        // print('response : ${response.body}');
        // print('status code: ${response.statusCode}');
        if (response.statusCode == 200) {
          setState(() {
            var jsonString = response.body;
            jsonMap = json.decode(jsonString);
            orderLists = OrderList.fromJson(jsonMap);
          });
        } else {
          print('${response.request}');
        }
      }
    } catch (e) {
      print('error : $e');
      return orderLists;
    }

    return orderLists;
  }

  Widget checkStatus(String status) {
    if (status == "success") {
      return Container(
        margin: EdgeInsets.only(top: 0.0),
        child: Text(
          'เสร็จสิ้น',
          style: TextStyle(
              color: const Color(0xff11AB17),
              fontSize: 16,
              fontFamily: 'Aleo',
              fontWeight: FontWeight.bold),
        ),
      );
    } else if (status == "not confirmed") {
      return Container(
        margin: EdgeInsets.only(top: 0.0),
        child: Text(
          'ยังไม่ได้รับออเดอร์',
          style: TextStyle(
              color: const Color(0xffAB0B1F),
              fontSize: 16,
              fontFamily: 'Aleo',
              fontWeight: FontWeight.bold),
        ),
      );
    } else if (status == "in process") {
      return Container(
        margin: EdgeInsets.only(top: 00.0),
        child: Text(
          'กำลังทำ',
          style: TextStyle(
              color: const Color(0xffFF7C2C),
              fontSize: 16,
              fontFamily: 'Aleo',
              fontWeight: FontWeight.bold),
        ),
      );
    }
  }

  Widget getDate(String timePickup) {
    DateTime convertDate = DateTime.parse(timePickup);
    final DateFormat formatter = DateFormat('dd/MM/yyyy');

    String formattedDate = formatter.format(convertDate);
    // print(formattedDate);
    return Text('$formattedDate',
        style: TextStyle(
          fontFamily: 'Aleo',
        ));
  }

  Future<Widget> getNameShop(int shopId) async {
    String url = 'http://54.151.194.224:8000/api/shop/$shopId/detail';
    Map<String, String> headers = {
      'Content-Type': 'application/json;charset=UTF-8',
      'Charset': 'utf-8'
    };
    http.Response response = await http.get(url, headers: headers);

    Map map = json.decode(response.body);
    ShopById msg = ShopById.fromJson(map);
    setState(() {
      _shopName = msg.data.name;
    });
  }

  Widget getShopName(int shopId) {
    Future getNameApi(int shopId) async {
      String url = 'http://54.151.194.224:8000/api/shop/$shopId/detail';
      Map<String, String> headers = {
        'Content-Type': 'application/json;charset=UTF-8',
        'Charset': 'utf-8'
      };
      http.Response response = await http.get(url, headers: headers);

      Map map = json.decode(response.body);
      ShopById msg = ShopById.fromJson(map);
      setState(() {
        _shopName = msg.data.name;
      });
    }

    return Text("$_shopName",
        style: TextStyle(
            fontFamily: 'Aleo', fontSize: 20, fontWeight: FontWeight.bold));
  }

  Widget getTime(String timePickup) {
    DateTime convertDate = DateTime.parse(timePickup);
    String formattedTime = DateFormat.Hm().format(convertDate);
    // print(formattedTime);
    return Text('$formattedTime',
        style: TextStyle(
          fontFamily: 'Aleo',
        ));
  }

  Widget checkTextStatus(String status) {
    if (status == "success") {
      return Text(
        'เสร็จสิ้น',
        textAlign: TextAlign.center,
        style: TextStyle(
            fontFamily: 'Aleo', fontSize: 24, fontWeight: FontWeight.bold),
      );
    } else if (status == "not confirmed") {
      return Text(
        'ยังไม่ได้รับออเดอร์',
        textAlign: TextAlign.center,
        style: TextStyle(
            fontFamily: 'Aleo', fontSize: 24, fontWeight: FontWeight.bold),
      );
    } else if (status == "in process") {
      return Text(
        'กำลังทำ',
        textAlign: TextAlign.center,
        style: TextStyle(
            fontFamily: 'Aleo', fontSize: 24, fontWeight: FontWeight.bold),
      );
    }
  }

  Widget checkImageStatus(String status) {
    if (status == "not confirmed") {
      return Center(
        child: Image.asset('assets/images/baking.png'),
      );
    } else if (status == "in process") {
      return Center(
        child: Image.asset('assets/images/flambe.png'),
      );
    } else if (status == "success") {
      return Center(
        child: Image.asset('assets/images/bakery.png'),
      );
    }
  }

  Widget indicatorCheck(String status) {
    if (status == "not confirmed") {
      return Center(
          child: StepsIndicator(
        selectedStep: 0,
        nbSteps: 3,
        selectedStepColorOut: const Color(0xff11AB17),
        selectedStepColorIn: const Color(0xff11AB17),
        doneStepColor: const Color(0xff11AB17),
        doneLineColor: const Color(0xff11AB17),
        undoneLineColor: const Color(0xffAB0B1F),
        unselectedStepColorIn: const Color(0xffAB0B1F),
        unselectedStepColorOut: const Color(0xffAB0B1F),
        unselectedStepSize: 20,
        selectedStepSize: 20,
        doneStepSize: 20,
      ));
    } else if (status == "in process") {
      return Center(
          child: StepsIndicator(
        selectedStep: 1,
        nbSteps: 3,
        selectedStepColorOut: const Color(0xff11AB17),
        selectedStepColorIn: const Color(0xff11AB17),
        doneStepColor: const Color(0xff11AB17),
        doneLineColor: const Color(0xff11AB17),
        undoneLineColor: const Color(0xffAB0B1F),
        unselectedStepColorIn: const Color(0xffAB0B1F),
        unselectedStepColorOut: const Color(0xffAB0B1F),
        unselectedStepSize: 20,
        selectedStepSize: 20,
        doneStepSize: 20,
      ));
    } else if (status == "success") {
      return Center(
          child: StepsIndicator(
        selectedStep: 2,
        nbSteps: 3,
        selectedStepColorOut: const Color(0xff11AB17),
        selectedStepColorIn: const Color(0xff11AB17),
        doneStepColor: const Color(0xff11AB17),
        doneLineColor: const Color(0xff11AB17),
        undoneLineColor: const Color(0xffAB0B1F),
        unselectedStepColorIn: const Color(0xffAB0B1F),
        unselectedStepColorOut: const Color(0xffAB0B1F),
        unselectedStepSize: 20,
        selectedStepSize: 20,
        doneStepSize: 20,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: <Widget>[
          Container(
            margin: EdgeInsets.only(right: 360),
            child: new IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Home(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      body: ListView(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(left: 40, top: 20),
                child: Text(
                  "ประวัติการสั่งอาหาร",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      fontFamily: 'Aleo'),
                ),
              ),
              Container(
                padding: EdgeInsets.only(top: 10),
                child: Divider(
                  thickness: 1,
                  indent: 40,
                  color: Colors.black,
                  endIndent: 40,
                ),
              ),
            ],
          ),
          Container(
            margin: EdgeInsets.only(top: 0, bottom: 20),
            child: FutureBuilder<OrderList>(
                future: _orderLists,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return snapshot.data.data.length != 0
                        ? ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: snapshot.data.data.length,
                            itemBuilder: (context, index) {
                              var data = snapshot.data.data[index];

                              return Container(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    Center(
                                      child: Container(
                                        margin: EdgeInsets.only(
                                            left: 20,
                                            right: 20,
                                            top: 0.0,
                                            bottom: 0.0),
                                        child: InkWell(
                                          onTap: () {
                                            alertHistory(
                                              context,
                                              data.status,
                                              data.orderDetails,
                                              data.shopId,
                                              data.totalPrice,
                                              data.id,
                                            );
                                          },
                                          child: Card(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                            ),
                                            margin: EdgeInsets.all(12),
                                            elevation: 10,
                                            color: Colors.white,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 8.0,
                                                      horizontal: 16),
                                              child: Row(
                                                children: <Widget>[
                                                  Container(
                                                    width: 170,
                                                    padding: EdgeInsets.all(10),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: <Widget>[
                                                        Text(
                                                          data.shop.name != null
                                                              ? "${data.shop.name}"
                                                              : "",
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: GoogleFonts
                                                              .roboto(
                                                                  fontSize: 20,
                                                                  color: Colors
                                                                      .orange,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                        ),
                                                        SizedBox(height: 4),
                                                        getDate(
                                                            data.timePickup),
                                                        getTime(
                                                            data.timePickup),
                                                      ],
                                                    ),
                                                  ),
                                                  Spacer(),
                                                  Container(
                                                      padding: EdgeInsets.only(
                                                          right: 12),
                                                      child: checkStatus(
                                                          data.status)),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              );
                            }
                            // getNameShop(data.shopId);
                            )
                        : Center(
                            child: Container(
                              margin: EdgeInsets.only(top: 170),
                              child: Text(
                                "ยังไม่มีประวัติการซื้อในขณะนี้",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black38,
                                    fontSize: 20),
                              ),
                            ),
                          );
                  } else {
                    return Container(
                      margin: EdgeInsets.only(top: 150),
                      child: Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 5.0,
                          valueColor:
                              AlwaysStoppedAnimation(const Color(0xffF6A911)),
                        ),
                      ),
                    );
                  }
                }),
          ),
        ],
      ),
    );
  }

  alertHistory(BuildContext context, String status,
      List<OrderDetails> orderDetail, int shopId, int totalPrice, int orderId) {
    showDialog(
        context: context,
        builder: (context) {
          return Container(
            child: AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0))),
              contentPadding: EdgeInsets.only(top: 0.0),
              content: Container(
                width: 400,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: EdgeInsets.only(top: 5.0, bottom: 5.0),
                      decoration: BoxDecoration(
                        color: Color(0xffFF7C2C),
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10.0),
                            topRight: Radius.circular(10.0)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            margin: EdgeInsets.only(left: 100),
                            alignment: Alignment.center,
                            child: Text(
                              "รีวิวร้านค้า",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Aleo',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 24),
                              // textAlign: TextAlign.center,
                            ),
                          ),
                          Container(
                            alignment: Alignment.centerLeft,
                            margin: EdgeInsets.only(left: 40),
                            child: IconButton(
                                icon: Icon(
                                  Icons.clear,
                                  color: Colors.white,
                                  size: 36,
                                ),
                                onPressed: () {
                                  Navigator.pop(context);
                                }),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(
                        top: 20,
                      ),
                      child: checkTextStatus(status),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 15, bottom: 20),
                      child: indicatorCheck(status),
                    ),
                    Container(
                      margin: EdgeInsets.only(bottom: 20),
                      child: checkImageStatus(status),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 15, bottom: 10),
                      child: Center(
                        child: Text(
                          'รายการอาหาร',
                          style: TextStyle(
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.bold,
                              fontSize: 24),
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(bottom: 20),
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: orderDetail.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Center(
                            child: Container(
                              margin: EdgeInsets.only(bottom: 5),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '${orderDetail[index].food.name} ',
                                    style: TextStyle(
                                        fontFamily: 'Roboto',
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xff838181)),
                                  ),
                                  Text(
                                    'x${orderDetail[index].quantity}',
                                    style: TextStyle(
                                      fontFamily: 'Roboto',
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.orange,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        // itemCount: ,
                      ),
                    ),
                    Visibility(
                      visible: status == "in process",
                      replacement: Container(
                        margin:
                            EdgeInsets.only(right: 100, left: 100, bottom: 30),
                        child: status == "in process" ||
                                status == "not confirmed"
                            ? RaisedButton(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                color: Colors.orange,
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => PaymentPage(
                                        shopId: shopId,
                                        totalPrice: totalPrice,
                                        orderId: orderId,
                                      ),
                                    ),
                                  ).then(
                                      (value) => {Navigator.of(context).pop()});
                                },
                                child: Container(
                                  child: Text(
                                    "ชำระเงิน",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18),
                                  ),
                                ),
                              )
                            : Container(),
                      ),
                      child: Container(
                        margin:
                            EdgeInsets.only(right: 46, left: 46, bottom: 30),
                        child: RaisedButton(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          color: Color(0xff00D30A),
                          onPressed: () {},
                          child: Container(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.check_circle_outline,
                                  color: Colors.white,
                                ),
                                Text(
                                  " ชำระเงินเรียบร้อยแล้ว",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }
}
