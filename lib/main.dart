import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart';

const api_url = 'https://masak-apa.tomorisakura.vercel.app';

void main () => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cari Resep Makanan',
      initialRoute: '/',
      routes: {
        '/': (context) => Utama(),
        // 'detail': (context) => Detail(),
        // 'favorite': (context) => Favorite()
      },
      debugShowCheckedModeBanner: false,
    );
  }
}

class Utama extends StatefulWidget {
  const Utama({Key? key}) : super(key: key);

  @override
  State<Utama> createState() => _UtamaState();
}

class _UtamaState extends State<Utama> {
  
  List _hasil = [];
  String cari = '';

  void cariResep(BuildContext context, {String query = ''}) async {
    var loading = showDialog(context: context, builder: (context){
                  return AlertDialog(content: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Mencari ...'),
                      CircularProgressIndicator(strokeWidth: 2,)
                    ],
                  ));
                }, barrierDismissible: false);

    Response response = await get(Uri.parse(api_url+'/api/search/?q=$query'));

    Navigator.of(context).pop();

    setState((){
      if(response.statusCode == 200){
        _hasil = jsonDecode(response.body)['results'];
      }else{
        _hasil = [];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: TextField(
          decoration: InputDecoration(
            hintText: 'Cari Resep Makanan',
            border: InputBorder.none,
          ),
          onChanged: (String newValue){
            cari = newValue;
          }
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.grey,),
            onPressed: (){
              if(cari.length >= 3){
                cariResep(context, query: cari);
              }else{
                showDialog(context: context, builder: (context){
                  return AlertDialog(content: Text('Pencarian minimal 3 karakter'));
                });
              }
            },
          )
        ]
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(5),
          child: _hasil.length > 0 ? ListView.separated(
            itemCount: _hasil.length,
            itemBuilder: (context, index){
              return ListTile(
                leading: Image.network(_hasil[index]['thumb']),
                title: Text(_hasil[index]['title']),
                onTap: (){
                  
                }
              );
            },
            separatorBuilder: (context, index){
              return Divider();
            },
          ) : (cari.length >0 ? Center(child: Text('Pencarian tidak ditemukan')) : Center(child: Text('Silahkan Cari Resep Makanan')))
        )
      )
    );
  }
}