import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'global_vars.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final myBox=Hive.box("MYBOX");
  @override
  void initState() {
    super.initState();
    // Load data from Hive into lists when the screen is initialized
    titleList = List<String>.from(myBox.get(1, defaultValue: []));
    descriptionList = List<String>.from(myBox.get(2, defaultValue: []));
    isCompletedList = List<bool>.from(myBox.get(3, defaultValue: []));
  }
  void _writeData(){
    setState(() {
      myBox.put(1, titleList);
      myBox.put(2, descriptionList);
      myBox.put(3, isCompletedList);
    });
  }

  String newTitle = '';
  String newDescription = '';

  void _showAddTaskDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Task'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'Title'),
                onChanged: (value) {
                  setState(() {
                    newTitle = value;
                  });
                },
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Description'),
                onChanged: (value) {
                  setState(() {
                    newDescription = value;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {

                setState(() {
                  if (newTitle.isNotEmpty && newDescription.isNotEmpty){
                    titleList.insert(0,newTitle);
                    descriptionList.insert(0,newDescription);
                    isCompletedList.insert(0,false);

                    _writeData();
                  }else{
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please fill in both title and description.'),
                          backgroundColor: Colors.red,
                        ));
                  }
                  newTitle = '';
                  newDescription = '';
                });
                Navigator.pop(context); // Close the dialog
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _showEditTaskDialog(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Task'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration:  InputDecoration(labelText: 'Title',hintText: titleList[index]),
                onChanged: (value) {
                  setState(() {
                    newTitle = value;
                  });
                },
              ),
              TextField(
                decoration:  InputDecoration(labelText: 'Description',hintText: descriptionList[index]),
                onChanged: (value) {
                  setState(() {
                    newDescription = value;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {

                setState(() {
                  if (newTitle.isNotEmpty && newDescription.isNotEmpty){
                    titleList[index]=newTitle;
                    descriptionList[index]=newDescription;
                    _writeData();
                  }else{
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please fill in both title and description.'),
                          backgroundColor: Colors.red,
                        ));
                  }
                  newTitle = '';
                  newDescription = '';
                });
                Navigator.pop(context);
              },
              child: const Text('Save'),
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
        title: const Text('To-do List App',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
        backgroundColor: Colors.transparent,
      ),
      body: ListView.builder(
        itemCount: titleList.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration:BoxDecoration(
                  color: isCompletedList[index] ? Colors.green.shade200 : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: const [
                    BoxShadow(
                        color: Colors.black,
                        blurRadius: 5
                    )
                  ]
              ),
                child: ListTile(
                leading:  InkWell(
                  onTap: (){
                    setState(() {
                      bool isCompleted=isCompletedList[index];
                      if (isCompleted){
                        isCompletedList[index]=false;

                      }else{
                        // isCompletedList[index]=true;

                        newTitle=titleList[index];
                        newDescription=descriptionList[index];
                        titleList.removeAt(index);
                        descriptionList.removeAt(index);
                        isCompletedList.removeAt(index);

                        titleList.add(newTitle);
                        descriptionList.add(newDescription);
                        isCompletedList.add(true);
                        _writeData();
                      }
                    });
                  },
                    child: Icon(isCompletedList[index] ? Icons.check_circle_outline : Icons.circle_outlined,)),
                  title: Text(
                    titleList[index].toString(),
                    style: isCompletedList[index] ? const TextStyle(decoration: TextDecoration.lineThrough,fontWeight: FontWeight.bold) : const TextStyle(
                      fontWeight: FontWeight.bold
                    ),

                  ),
                subtitle: Text(descriptionList[index].toString()),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () async {
                        _showEditTaskDialog(index);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        setState(() {
                          titleList.removeAt(index);
                          descriptionList.removeAt(index);
                          isCompletedList.removeAt(index);
                          _writeData();
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {_showAddTaskDialog();},
        backgroundColor: Colors.black,
        tooltip: 'Add Task',
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
      backgroundColor: Colors.blueGrey,
    );
  }
}
