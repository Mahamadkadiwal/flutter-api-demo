import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Post {
  final int id;
  final String title;
  final String body;

  Post({
    required this.id,
    required this.title,
    required this.body,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json["id"],
      title: json["title"],
      body: json["body"],
    );
  }
}

// ---------------------------
// SCREEN : Fetch + Display Posts + Insert + Update
// ---------------------------
class PostScreen extends StatefulWidget {
  const PostScreen({super.key});

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  late Future<List<Post>> postList;
  List<Post> localPosts = []; // Store both API posts + inserted posts

  @override
  void initState() {
    super.initState();
    postList = getPosts();
  }

  // -----------------------
  // API CALL
  // -----------------------
  Future<List<Post>> getPosts() async {
    final response = await http
        .get(Uri.parse("https://jsonplaceholder.typicode.com/posts?_limit=5"));

    if (response.statusCode == 200) {
      List data = json.decode(response.body);
      return data.map((item) => Post.fromJson(item)).toList();
    } else {
      throw Exception("Unable to load posts");
    }
  }

  // ----------------------------------------------------
  // SINGLE FORM FUNCTION (INSERT + UPDATE)
  // ----------------------------------------------------
  void showPostForm({Post? post, int? index}) {
    bool isEdit = post != null;

    TextEditingController titleCtrl =
    TextEditingController(text: isEdit ? post!.title : "");
    TextEditingController bodyCtrl =
    TextEditingController(text: isEdit ? post!.body : "");

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isEdit ? "Edit Post" : "Insert New Post"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(
                    labelText: "Title",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: bodyCtrl,
                  decoration: const InputDecoration(
                    labelText: "Body",
                      border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),

            ElevatedButton(
              child: Text(isEdit ? "Update" : "Add"),
              onPressed: () async {
                if (titleCtrl.text.isEmpty || bodyCtrl.text.isEmpty) return;

                // -------------------------
                // UPDATE OPERATION
                // -------------------------
                if (isEdit) {
                  var response = await http.patch(
                    Uri.parse("https://jsonplaceholder.typicode.com/posts/${post.id}"),
                     body: jsonEncode({
                      "title": titleCtrl.text,
                      "body": bodyCtrl.text,
                    }),
                    headers: {"Content-Type": "application/json"},
                  );

                  if (response.statusCode == 200) {
                    var data = jsonDecode(response.body);

                    setState(() {
                      localPosts[index!] = Post(
                        id: post.id,
                        title: data["title"],
                        body: data["body"],
                      );
                    });

                    Navigator.pop(context);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Post Updated Successfully!")),
                    );
                  }
                }
                // -------------------------
                // INSERT OPERATION
                // -------------------------
                else {
                  var response = await http.post(
                    Uri.parse("https://jsonplaceholder.typicode.com/posts"),
                    body: jsonEncode({
                      "title": titleCtrl.text,
                      "body": bodyCtrl.text,
                      "userId": 1,
                    }),
                    headers: {"Content-Type": "application/json"},
                  );

                  if (response.statusCode == 201) {
                    var data = jsonDecode(response.body);

                    setState(() {
                      localPosts.add(Post(
                        id: data["id"],
                        title: data["title"],
                        body: data["body"],
                      ));
                    });

                    Navigator.pop(context);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Post Inserted Successfully!")),
                    );
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }


  void deletePost(int id, int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete Post"),
          content: const Text("Are you sure you want to delete this post?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),

            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () async {

                // -----------------------
                // API CALL (DELETE)
                // -----------------------
                var response = await http.delete(
                  Uri.parse("https://jsonplaceholder.typicode.com/posts/$id"),
                );

                // JSONPlaceholder returns 200 or 204 for DELETE
                if (response.statusCode == 200 || response.statusCode == 204) {

                  // Remove from local list
                  setState(() {
                    localPosts.removeAt(index);
                  });

                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Post Deleted Successfully!")),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Failed to delete post!")),
                  );
                }
              },
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }



  // -----------------------
  // UI
  // -----------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("API with Images"),
        centerTitle: true,
      ),

      body: Column(
        children: [
          // INSERT BUTTON
          Padding(
            padding: const EdgeInsets.all(10),
            child: ElevatedButton(
              onPressed: () => showPostForm(),
              child: const Text("Insert New Post"),
            ),
          ),

          // FETCH + LOCAL POSTS
          Expanded(
            child: FutureBuilder<List<Post>>(
              future: postList,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }

                if (localPosts.isEmpty && snapshot.hasData) {
                  localPosts.addAll(snapshot.data!); // Move API posts into list
                }

                final posts = localPosts;

                return ListView.builder(
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    final post = posts[index];

                    return Card(
                      margin: const EdgeInsets.all(10),
                      elevation: 3,
                      child: ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            "https://picsum.photos/200?random=$index",
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          ),
                        ),
                        title: Text(
                          post.title,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(post.body),

                        // EDIT BUTTON
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () {
                                showPostForm(post: post, index: index);
                              },
                            ),

                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                deletePost(post.id, index);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
