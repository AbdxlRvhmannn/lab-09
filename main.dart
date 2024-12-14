import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CRUD App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: PostList(),
    );
  }
}

class PostList extends StatefulWidget {
  @override
  _PostListState createState() => _PostListState();
}

class _PostListState extends State<PostList> {
  List posts = [];

  @override
  void initState() {
    super.initState();
    fetchPosts();
  }

  Future<void> fetchPosts() async {
    final response =
        await http.get(Uri.parse('https://jsonplaceholder.typicode.com/posts'));
    if (response.statusCode == 200) {
      setState(() {
        posts = json.decode(response.body);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load posts')),
      );
    }
  }

  Future<void> createPost(String title, String body) async {
    final response = await http.post(
      Uri.parse('https://jsonplaceholder.typicode.com/posts'),
      body: json.encode({
        'title': title,
        'body': body,
        'userId': 1,
      }),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 201) {
      setState(() {
        posts.insert(0, json.decode(response.body));
      });
    }
  }

  Future<void> updatePost(int id, String title, String body) async {
    final response = await http.put(
      Uri.parse('https://jsonplaceholder.typicode.com/posts/$id'),
      body: json.encode({
        'id': id,
        'title': title,
        'body': body,
        'userId': 1,
      }),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      setState(() {
        final index = posts.indexWhere((post) => post['id'] == id);
        posts[index] = json.decode(response.body);
      });
    }
  }

  Future<void> deletePost(int id) async {
    final response = await http.delete(
      Uri.parse('https://jsonplaceholder.typicode.com/posts/$id'),
    );
    if (response.statusCode == 200) {
      setState(() {
        posts.removeWhere((post) => post['id'] == id);
      });
    }
  }

  void showFormDialog({int? id, String? title, String? body}) {
    final titleController = TextEditingController(text: title);
    final bodyController = TextEditingController(text: body);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(id == null ? 'Create Post' : 'Edit Post'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: bodyController,
                decoration: InputDecoration(labelText: 'Body'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (id == null) {
                  createPost(titleController.text, bodyController.text);
                } else {
                  updatePost(id, titleController.text, bodyController.text);
                }
                Navigator.of(context).pop();
              },
              child: Text(id == null ? 'Create' : 'Update'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('CRUD Operations'),
      ),
      body: posts.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final post = posts[index];
                return ListTile(
                  title: Text(post['title'] ?? 'No Title'),
                  subtitle: Text(post['body'] ?? 'No Body'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          showFormDialog(
                            id: post['id'],
                            title: post['title'],
                            body: post['body'],
                          );
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          deletePost(post['id']);
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showFormDialog(),
        child: Icon(Icons.add),
      ),
    );
  }
}
