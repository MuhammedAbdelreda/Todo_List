import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_13/screens/addPage.dart';
import 'package:http/http.dart' as http;

class ToDoList extends StatefulWidget {
  const ToDoList({super.key});

  @override
  State<ToDoList> createState() => _ToDoListState();
}

class _ToDoListState extends State<ToDoList> {
  bool isLoading = false;
  List items = [];

  void SnackBarSuccess() {
    final snack = SnackBar(content: Text('Deletion Success'));
    ScaffoldMessenger.of(context).showSnackBar(snack);
  }

  void SnackBarFailed() {
    final snack = SnackBar(
        content: Text(
      'Delettion Failed',
      style: TextStyle(backgroundColor: Colors.red),
    ));
    ScaffoldMessenger.of(context).showSnackBar(snack);
  }

  Future<void> deleteByID(String id) async {
    //deletion function
    final url = 'https://api.nstack.in/v1/todos/$id';
    final uri = Uri.parse(url);
    final response = await http.delete(uri);
    if (response.statusCode == 200) {
      SnackBarSuccess();
      final filtered = items
          .where((element) => element['_id'] != id)
          .toList(); //update list after deletion
      setState(() {
        items = filtered;
      });
    } else {
      SnackBarFailed();
    }
  }

  Future<void> FetchData() async {
    final url =
        'https://api.nstack.in/v1/todos?page=1&limit=10'; //function to get created data
    final uri = Uri.parse(url);
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map;
      final result = json['items'] as List;
      setState(() {
        items = result;
      });
    }
    setState(() {
      isLoading = true;
    });
  }

   Future<void> NavigateToEditPage(Map item) async{
     await Navigator.push(
      context,
      MaterialPageRoute(builder: ((context) => AddPage(todo: item,))),
    );
    setState(() {
      isLoading = true;
    });
    FetchData();
  }

  Future<void> NavigateToAddPage() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: ((context) => AddPage())),
    );
    setState(() {
      isLoading = true;
    });
    FetchData();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    FetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Todo List'),
        centerTitle: true,
      ),
      body: Visibility(
        visible: isLoading,
        replacement: Center(
          child: CircularProgressIndicator(),
        ),
        child: RefreshIndicator(
          onRefresh: FetchData,
          child: ListView.builder(
              itemCount: items.length,
              itemBuilder: ((context, index) {
                final item = items[index];
                final id = item['_id'];
                return ListTile(
                  leading: CircleAvatar(
                    child: Text('${index + 1}'),
                  ),
                  title: Text(item['title']),
                  subtitle: Text(item['description']),
                  trailing: PopupMenuButton(
                    onSelected: (value) {
                      if (value == 'edit') {
                        NavigateToEditPage(item);
                      } else if (value == 'delete') {
                        deleteByID(id);
                      }
                    },
                    itemBuilder: (context) {
                      return [
                        PopupMenuItem(child: Text('Edit'), value: 'edit'),
                        PopupMenuItem(child: Text('Delete'), value: 'delete'),
                      ];
                    },
                  ),
                );
              })),
        ),
      ),
            floatingActionButton: FloatingActionButton(
        child: Text('add todo'),
        onPressed: NavigateToAddPage,
      ),
    );
  }
}
