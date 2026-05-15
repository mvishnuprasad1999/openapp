import 'package:flutter/material.dart';
import 'package:open_ui/model/taskmodel.dart';
import 'package:open_ui/services/api_services.dart';
import 'package:open_ui/taskcard.dart';
import 'package:open_ui/taskuploadscreen.dart';
import 'package:open_ui/widgets/bottombar.dart';

class TaskScreen extends StatefulWidget {
  const TaskScreen({super.key});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {

  List<TaskModel> tasks = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadTasks();
  }

  Future<void> loadTasks() async {

    try {

      final fetchedTasks = await TaskApi.getTasks();

      setState(() {
        tasks = fetchedTasks;
      });

    } catch (e) {

      debugPrint(e.toString());

    } finally {

      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFF121218),

      body: SafeArea(
        child: Stack(
          children: [

            Column(
              children: [

                _buildTopBar(),

                Expanded(
                  child: isLoading
                      ? const Center(
                          child: CircularProgressIndicator(),
                        )
                      : tasks.isEmpty
                          ? const Center(
                              child: Text(
                                "No Tasks",
                                style: TextStyle(color: Colors.white),
                              ),
                            )
                          : RefreshIndicator(
                              onRefresh: loadTasks,
                              child: ListView.separated(
                                padding: const EdgeInsets.fromLTRB(
                                    16, 8, 16, 120),

                                itemCount: tasks.length,

                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 16),

                                itemBuilder: (context, index) {

                                  return TaskCard(
                                    task: tasks[index],
                                  );
                                },
                              ),
                            ),
                ),
              ],
            ),

            CustomBottomBar(selectedIndex: 1),

            Positioned(
              right: 25,
              bottom: 110,
              child: _buildFAB(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAB() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TaskUploadScreen(),
          ),
        );
      },
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: Colors.red,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.red.withOpacity(0.45),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 12,
      ),
      child: Row(
        children: [

          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text(
                'T',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ),

          const SizedBox(width: 6),

          const Text(
            'ask',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),

          const Spacer(),
        ],
      ),
    );
  }
}