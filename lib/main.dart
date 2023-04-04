import 'dart:convert';
import 'package:bcrypt/bcrypt.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // ตัวแปรเริ่มต้น
  String _hash = 'ยินดีต้อนรับ', statusEvent = "init";
  // controller
  TextEditingController name = TextEditingController(),
      password = TextEditingController(),
      passwordF = TextEditingController();
  bool register = false;
  // Link API
  String link = "https://b417-27-55-70-3.ap.ngrok.io/";
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Bcrypt plugin example app'),
        ),
        body: Center(
          child: statusEvent == "loading"
              ? const CircularProgressIndicator()
              : display(),
        ),
      ),
    );
  }

  Padding display() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // แสดงสถานะ
          SelectableText('สถานะ: $_hash,\n\n'),
          // input
          TextField(
            controller: name,
            decoration: const InputDecoration(hintText: "Name"),
          ),
          TextField(
            controller: password,
            decoration: const InputDecoration(hintText: "Password"),
          ),
          // หากสมัคร
          if (register)
            TextField(
              controller: passwordF,
              decoration: const InputDecoration(hintText: "Confirm password"),
            ),
          // submiter
          OutlinedButton(
              onPressed: register ? regist : login,
              child: Text(register ? "Regist" : "Submit")),
          // regist?
          InkWell(
            onTap: () => setState(() {
              register = !register;
            }),
            child: Text(
              register ? 'มีรหัสแล้ว' : 'ยังไม่มีรหัส?',
              style: const TextStyle(color: Colors.purple),
            ),
          )
        ],
      ),
    );
  }

// hash
  String bCryptHash(String password) {
    final String passwordHashed = BCrypt.hashpw(
      password,
      BCrypt.gensalt(),
    );
    return passwordHashed;
  }

// register
  void regist() async {
    statusEvent = "loading";
    setState(() {});
    // handle จัดการเงื่อนไข
    bool handle = password.text.trim() == passwordF.text.trim() &&
        password.text.trim().isNotEmpty &&
        name.text.trim().isNotEmpty;
    if (handle) {
      // ยิง API
      var res = await http.post(
          // headers json
          headers: {'Content-Type': 'application/json'},
          // String json data
          body: jsonEncode({
            "userName": name.text.trim(),
            "password": bCryptHash(password.text.trim())
          }),
          // ที่อยู่ API
          Uri.parse('${link}regist'));
      if (res.statusCode == 200) {
        // ตรวจสอบ status
        String status = jsonDecode(res.body)['status'];
        status == "success"
            ? _hash = "สร้าง ID สำเร็จ"
            : _hash = "มี user name นี้แล้ว";
      } else {
        _hash = "ไม่สามารถเชื่อมต่อ server ได้";
      }
    } else {
      _hash = "รหัสไม่ตรงกัน หรือ ไม่มีการใส่ข้อมูล";
    }
    statusEvent = "finished";
    setState(() {});
  }

// login
  void login() async {
    statusEvent = "loading";
    setState(() {});
    var res = await http.post(
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"userName": name.text.trim()}),
        Uri.parse('${link}login'));

    if (res.statusCode == 200) {
      String status = jsonDecode(res.body)['status'];
      if (status != 'failure') {
        String obj = jsonDecode(res.body)['hash'];
        final bool checkPassword = BCrypt.checkpw(password.text.trim(), obj);
        checkPassword ? _hash = "Login successful" : _hash = "รหัสไม่ถูกต้อง";
      } else {
        _hash = "ไม่พบชื่อผู้ใช้";
      }
    } else {
      _hash = "ไม่สามารถเชื่อมต่อ server ได้";
    }
    statusEvent = "finished";
    setState(() {});
  }
}
