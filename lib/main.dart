import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  final List<String> _hours = <String>[
    "Select one...",
    "1",
    "2",
    "3",
    "4",
    "5",
    "6",
    "7",
    "8",
  ];
  List<String> subject_array = ["Select one..."];
  String _subjectController = "Select one...";
  String _selectedHour = "Select one...";

//  Image loader;
//
//  @override
//  void initState() {
//    loader = Image.asset(
//      "images/loader.gif",
//    );
//    super.initState();
//    new Future.delayed(Duration.zero, () {
//      showProgressModal(context);
//    });
//  }
//
//  @override
//  void didChangeDependencies() async {
//    await precacheImage(loader.image, context);
//    super.didChangeDependencies();
//  }

  showProgressModal(context) {
    AlertDialog alert = AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(2.0))),
      contentPadding: EdgeInsets.all(0.0),
      content: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(2.0)),
          ),
          child: Wrap(
            alignment: WrapAlignment.center,
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(top: 10, bottom: 10),
                    child: Text("hi"),
                  ),
                  Wrap(
                    alignment: WrapAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Text(
                          "Please wait...",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontFamily: "Poppins", color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          )),
    );
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("STATES MULTI DROPDOWN"),
        elevation: 0.1,
      ),
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 50, vertical: 30),
          child: Column(
            children: <Widget>[
              DropdownButtonFormField(
                isExpanded: true,
                items: _hours.map((String dropDownStringItem) {
                  return DropdownMenuItem<String>(
                    value: dropDownStringItem,
                    child: Text(dropDownStringItem),
                  );
                }).toList(),
                onChanged: (value) => _onSelectedHour(value),
                value: _selectedHour,
              ),
              DropdownButton<String>(
                isExpanded: true,
                items: subject_array.map((String dropDownStringItem) {
                  return DropdownMenuItem<String>(
                    value: dropDownStringItem,
                    child: Text(dropDownStringItem),
                  );
                }).toList(),
                // onChanged: (value) => print(value),
                onChanged: (value) => _onSelectedSubject(value),
                value: _subjectController,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onSelectedHour(String value_x) {
    showProgressModal(context);
    subject_array = ["Select one..."];
    SuperUserSelectionRestDataSource ds =
    new SuperUserSelectionRestDataSource();
    ds
        .fetch("prabha.b@licet.ac.in", "2fQjzDniyJ6qS71s0C9Mr8EwWLbU", "dit",
        "III", "2020-05-22", value_x)
        .then((value) {
      bool super_json = true;
      List<dynamic> final_json_array = [];
      List<dynamic> super_json_array = [];
      List<dynamic> regular_json_array = [];
      value.forEach((element) {
        if (element["source"] == "super") {
          super_json_array.add(element);
        } else if (element["source"] == "regular") {
          regular_json_array.add(element);
          print("added");
        }
      });

      // rarest case - single elective being substituted with a different hour
      super_json_array.forEach((super_element) {
        regular_json_array.forEach((regular_element) {
          if (super_element['subCode_dept_sem'] ==
              regular_element['subCode_dept_sem']) {
            print("All electives substituted");
            super_json = false;
          }
        });
      });

      if (super_json_array.isEmpty) {
        super_json = false;
      } else if (regular_json_array.isEmpty) {
        super_json = true;
      }

      // final_json_array wil have the regular timetable if an elective/regular
      // hour was substituted with a regular hour
      final_json_array = super_json ? super_json_array : regular_json_array;

      final_json_array.forEach((element) {
        subject_array.add(element["subject_code"].toString().toUpperCase() +
            " - " +
            element["subject_name"].toString());
      });
      Navigator.pop(context);
      setState(() {
        _subjectController = "Select one...";
        subject_array = subject_array;
        _selectedHour = value_x;
      });
    });
  }

  void _onSelectedSubject(String value) {
    setState(() => _subjectController = value);
    print(value);
  }
}

//do not touch below this
class SuperUserSelectionRestDataSource {
  NetworkUtil _netUtil = new NetworkUtil();
  static final BASE_URL = "https://weareeverywhere.in";
  static final LOGIN_URL = BASE_URL + "/od-superuser.php";

  Future<dynamic> fetch(String username, String auth_token, String department,
      String year, String date, String hour) {
    print(username + auth_token + department + year + date + hour);
    return _netUtil.post(LOGIN_URL, body: {
      "username": username,
      "auth_token": auth_token,
      "department": department,
      "year": year,
      "date": date,
      "hour": hour,
    }).then((dynamic res) {
      if (res == "no-class")
        throw new Exception("No class was scheduled for this hour.");
      else if (res == "invalid-auth-or-access")
        throw new Exception(
            "You do not have the privileges to access this content.");
      return res;
    });
  }
}

class NetworkUtil {
  // next three lines makes this class a Singleton
  static NetworkUtil _instance = new NetworkUtil.internal();

  NetworkUtil.internal();

  factory NetworkUtil() => _instance;

  final JsonDecoder _decoder = new JsonDecoder();

  Future<dynamic> get(String url) {
    return http.get(url).then((http.Response response) {
      final String res = response.body;
      final int statusCode = response.statusCode;

      if (statusCode < 200 || statusCode > 400 || json == null) {
        throw new Exception("Error while fetching data");
      }
      return _decoder.convert(res);
    });
  }

  Future<dynamic> post(String url, {Map headers, body, encoding}) {
    return http
        .post(url, body: body, headers: headers, encoding: encoding)
        .then((http.Response response) {
      final String res = response.body;
      final int statusCode = response.statusCode;

      if (statusCode < 200 || statusCode > 400 || json == null) {
        throw new Exception("Error while fetching data");
      }
      return _decoder.convert(res);
    });
  }
}
