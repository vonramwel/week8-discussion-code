/*
  Created by: Claizel Coubeili Cepe
  Date: updated April 26, 2023
  Description: Sample todo app with Firebase 
*/
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/todo_model.dart';
import '../providers/todo_provider.dart';
import 'modal_todo.dart';

class TodoPage extends StatefulWidget {
  const TodoPage({super.key});

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  @override
  Widget build(BuildContext context) {
    // access the list of todos in the provider
    Stream<QuerySnapshot> todosStream = context.watch<TodoListProvider>().todos;

    return Scaffold(
      appBar: AppBar(
        title: Text("Todo"),
      ),
      body: StreamBuilder(
        stream: todosStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text("Error encountered! ${snapshot.error}"),
            );
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (!snapshot.hasData) {
            return Center(
              child: Text("No Todos Found"),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data?.docs.length,
            itemBuilder: ((context, index) {
              print(snapshot.data?.docs[index].data());
              print(snapshot.data?.docs[index].id);
              Todo todo = Todo.fromJson(
                  snapshot.data?.docs[index].data() as Map<String, dynamic>);
              todo.id = snapshot.data?.docs[index].id;
              return Dismissible(
                key: Key(todo.id.toString()),
                onDismissed: (direction) {
                  context.read<TodoListProvider>().deleteTodo(todo.id!);
                  // context.read<TodoListProvider>().deleteTodo(todo.title);

                  // ScaffoldMessenger.of(context).showSnackBar(
                  //     SnackBar(content: Text('${todo.title} dismissed')));
                },
                background: Container(
                  color: Colors.red,
                  child: const Icon(Icons.delete),
                ),
                child: ListTile(
                  title: Text(todo.title),
                  leading: Checkbox(
                    value: todo.completed,
                    onChanged: (bool? value) {
                      context
                          .read<TodoListProvider>()
                          .toggleStatus(index, value!);
                    },
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () {
                          // showDialog(
                          //   context: context,
                          //   builder: (BuildContext context) => TodoModal(
                          //     type: 'Edit',,
                          //   ),
                          // );
                        },
                        icon: const Icon(Icons.create_outlined),
                      ),
                      IconButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) => TodoModal(
                              type: 'Delete',
                              item: todo,
                            ),
                          );
                        },
                        icon: const Icon(Icons.delete_outlined),
                      )
                    ],
                  ),
                ),
              );
            }),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) => TodoModal(
              type: 'Add',
              // todoIndex:
              //     -1, // Flag to identify that this particular modal is for add
            ),
          );
        },
        child: const Icon(Icons.add_outlined),
      ),
    );
  }
}
