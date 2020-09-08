import 'dart:convert';

import 'package:disefood/model/foods_list.dart';
import 'package:disefood/model/menuyShopId.dart';
import 'package:disefood/screen_seller/addmenu.dart';
import 'package:disefood/services/api_provider.dart';
import 'package:disefood/services/foodservice.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'editmenu.dart';

class OrganizeSellerPage extends StatefulWidget {
  static final route = "/organize_seller";
  @override
  _OrganizeSellerPageState createState() => _OrganizeSellerPageState();
}

class _OrganizeSellerPageState extends State<OrganizeSellerPage> {
  FoodsList foodslist = FoodsList();
  List foodList = [];
  bool _isLoading = false;
  int _shopId;
  String foodName;
  ApiProvider apiProvider = ApiProvider();
  @override
  void initState() {
    Future.microtask(() async {
      // fetchNameFromStorage();
      getFoodByShopId();
    });
    super.initState();
  }

  // Future fetchNameFromStorage() async {
  //   SharedPreferences _prefs = await SharedPreferences.getInstance();
  //   final name = _prefs.getString('first_name');
  //   final shopId = _prefs.getInt('shop_id');
  //   setState(() {
  //     _name = name;
  //     _shopId = shopId;
  //   });
  // }

  Future getFoodByShopId() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    _shopId = preferences.getInt('shop_id');
    String _url = 'http://10.0.2.2:8080/api/shop/menu/$_shopId';
    final response = await http.get(_url);
    var body = response.body;
    setState(() {
      _isLoading = true;
      foodList = json.decode(body)['data'];
      Logger logger = Logger();
      logger.d(foodList);
    });
  }

  @override
  Widget build(BuildContext context) {
    // final OrganizeSellerPage params = ModalRoute.of(context).settings.arguments;
    return Scaffold(
      body: ListView(
        children: [
          
              Row(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(left: 40, top: 30),
                    child: Text(
                      "รายการอาหาร",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                    ),
                  ),
                  // Container(
                  //   padding: EdgeInsets.only(left: 150, top: 38),
                  //   child: IconButton(
                  //   icon: Icon(
                  //     Icons.add_circle,
                  //     color: Colors.amber[800],
                  //   ),
                  //   onPressed: () {
                  //     Navigator.push(context,
                  //         MaterialPageRoute(builder: (context) => AddMenu()));
                  //   }
                  //   ),
                  // ),
                ],
              ),
              Container(
                padding: EdgeInsets.only(top: 10),
                child: Divider(
                  indent: 40,
                  color: Colors.black,
                  endIndent: 40,
                ),
              ),
              Expanded(
                child: !_isLoading
                    ? Container(
                        child: Center(
                          child: CircularProgressIndicator(
                            backgroundColor: Colors.amber[900],
                          ),
                        ),
                      )
                    : Expanded(
                      child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: foodList != null ? foodList.length : 0,
                          itemBuilder: (BuildContext context, int index) {
                            var foods = foodList[index];
                            return Expanded(
                              child: Column(
                                children: <Widget>[
                                  ListTile(
                                    leading: Container(
                                      margin: EdgeInsets.only(
                                        left: 30,
                                      ),
                                      child: Text(
                                        '${foods['name']}',
                                        style: TextStyle(
                                          fontSize: 18,
                                        ),
                                      ),
                                    ),
                                    trailing: Wrap(
                                      spacing: 12, // space between two icons
                                      children: <Widget>[
                                        Container(
                                          margin: EdgeInsets.only(top: 13),
                                          child: Text(
                                            '${foods['price']}',
                                            style: TextStyle(
                                              fontSize: 18,
                                            ),
                                          ),
                                        ),
                                        Container(
                                            child: IconButton(
                                                icon: Icon(
                                                  Icons.edit,
                                                  color: Colors.amber[800],
                                                ),
                                                onPressed: () {
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              EditMenuPage(
                                                                foodslist:
                                                                    foods[index],
                                                              )));
                                                })),
                                        // icon-1
                                      ],
                                    ),
                                  ),
                                  Container(
                                          padding: EdgeInsets.only(top: 0),
                                          child: Divider(
                                            indent: 40,
                                            color: Colors.black,
                                            endIndent: 40,
                                          ),
                                        ),
                                ],
                              ),
                            );
                          }),
                    ),
              ),
              Expanded(
                child: _isLoading
                    ? ListTile(
                        leading: Container(
                          margin: EdgeInsets.only(
                            left: 30,
                          ),
                          child: Text(
                            'เพิ่มรายการอาหาร',
                            style: TextStyle(
                              fontSize: 18,
                            ),
                          ),
                        ),
                        trailing: IconButton(
                          icon: Icon(
                            Icons.add_circle,
                            color: Colors.amber[800],
                          ),
                          onPressed: () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) => AddMenu()));
                          },
                        ),
                      )
                    : Container(),
              ),
        ],
      ),
    );
  }
}
