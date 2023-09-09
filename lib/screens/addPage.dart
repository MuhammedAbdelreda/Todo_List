import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AddPage extends StatefulWidget {
  const AddPage({super.key, this.todo});
  final Map? todo;

  // final map? todo;
  // AddPage({required this.todo});

  @override
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  TextEditingController title = TextEditingController();
  TextEditingController description = TextEditingController();

  bool isEdit = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    final todo = widget.todo;
    if (widget.todo != null) {
      isEdit = true;
      final titleUpdated = todo!['title'];
      final descriptionUpdated = todo['description'];
      title.text = titleUpdated;
      description.text = descriptionUpdated;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEdit ? 'Edit Page' : 'Add Page',
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 15, right: 15),
        child: ListView(
          children: [
            TextField(
              controller: title,
              decoration: InputDecoration(hintText: 'Title'),
            ),
            TextField(
              controller: description,
              decoration: InputDecoration(hintText: 'Description'),
              minLines: 5,
              maxLines: 8,
              keyboardType: TextInputType.multiline,
            ),
            SizedBox(
              height: 20,
            ),
            ElevatedButton(
                onPressed: isEdit?updateData:submitData,
                child: Text(isEdit ? 'Update' : 'Submit')),
          ],
        ),
      ),
    );
  }

  Future<void> updateData() async {
    final todo = widget.todo;
    if (todo == null) {
      print('You can not call update without update data');
      return;
    }
    final id = todo['_id'];
    final newTitle = title.text;
    final newDescription = description.text;
    final body = {
      "title": newTitle,
      "description": newDescription,
      "is_completed": false,
    };
    final url = 'https://api.nstack.in/v1/todos/$id'; //put data and update
    final uri = Uri.parse(url);
    final response = await http.put(uri,
        body: jsonEncode(body), headers: {'Content-Type': 'application/json'});

    void SnackBarSuccess() {
      final snack = SnackBar(
          content:
              Text('Value updated')); //snack bar to show creation success
      ScaffoldMessenger.of(context).showSnackBar(snack);
    }

    void SnackBarFailed() {
      final snack = SnackBar(
          content: Text(
        'Failed to update',
        style: TextStyle(backgroundColor: Colors.red),
      ));
      ScaffoldMessenger.of(context).showSnackBar(snack);
    }

    if (response.statusCode == 200) { //200->put and get and delete__________201->post
      SnackBarSuccess();
    } else {
      SnackBarFailed();
    }
  }

  Future<void> submitData() async {
    //post function
    final newTitle = title.text;
    final newDescription = description.text;
    final body = {
      "title": newTitle,
      "description": newDescription,
      "is_completed": false,
    };

    final url = 'https://api.nstack.in/v1/todos'; //post data
    final uri = Uri.parse(url);
    final response = await http.post(uri,
        body: jsonEncode(body), headers: {'Content-Type': 'application/json'});

    void SnackBarSuccess() {
      final snack = SnackBar(
          content:
              Text('Creation Success')); //snack bar to show creation success
      ScaffoldMessenger.of(context).showSnackBar(snack);
    }

    void SnackBarFailed() {
      final snack = SnackBar(
          content: Text(
        'Creation Failed',
        style: TextStyle(backgroundColor: Colors.red),
      ));
      ScaffoldMessenger.of(context).showSnackBar(snack);
    }

    if (response.statusCode == 201) {
      SnackBarSuccess();
    } else {
      SnackBarFailed();
    }
  }
}
