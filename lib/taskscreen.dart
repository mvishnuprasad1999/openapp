import 'package:flutter/material.dart';
import 'package:open_ui/model/taskmodel.dart';
import 'package:open_ui/taskcard.dart';

import 'package:open_ui/widgets/bottombar.dart'; // adjust import path as needed

class TaskScreen extends StatefulWidget {
  const TaskScreen({super.key});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  int _selectedIndex = 0;

  final List<TaskModel> tasks = [
    TaskModel(
      id: '1',
      category: 'BetterFlutter',
      title: 'Build this UI in Flutter –\n"Task Manager"',
      description:
          'Build a functional, state-managed Task Manager application using Flutter. '
          'This project will test your ability to handle UI layouts, user input, and local data persistence.',
      features: [
        'Task Dashboard: A clean list view showing all current tasks.',
        'Add Task Screen: A form to input a task title, a brief description, and a due date.',
        'Task Completion: A toggle system (like a checkbox) to mark tasks as "Done."',
        'Delete Functionality: The ability to remove a task using a "Swipe to Delete" or a delete icon.',
      ],
      likes: 100,
    ),
    TaskModel(
      id: '2',
      category: 'BetterFlutter',
      title: 'Build a Weather App\nin Flutter',
      description:
          'Create a beautiful weather application with real-time data, '
          'animated backgrounds, and hourly/weekly forecasts.',
      features: [
        'Location Search: Auto-detect or manually search for any city.',
        'Current Weather: Show temperature, humidity, wind speed.',
        'Hourly Forecast: Scrollable hourly breakdown for the day.',
        'Weekly Forecast: 7-day overview with high/low temperatures.',
      ],
      likes: 87,
    ),
    TaskModel(
      id: '3',
      category: 'BetterFlutter',
      title: 'Build a Chat UI\nin Flutter',
      description:
          'Design a fully functional chat interface with bubbles, timestamps, '
          'read receipts, and image sharing capabilities.',
      features: [
        'Message Bubbles: Differentiated sent/received styles.',
        'Timestamps: Grouped by date headers.',
        'Image Sharing: Pick from gallery or camera.',
        'Typing Indicator: Animated dots while other user types.',
      ],
      likes: 143,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121218),
      body: SafeArea(
        child: Stack(
          children: [
            // ── Main content ──────────────────────────────────────────
            Column(
              children: [
                _buildTopBar(),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                    itemCount: tasks.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, index) => TaskCard(task: tasks[index]),
                  ),
                ),
              ],
            ),

            // ── Custom Bottom Bar ─────────────────────────────────────
            CustomBottomBar(selectedIndex: 1),
          ],
        ),
      ),
    );
  }

  // ── TOP BAR ──────────────────────────────────────────────────────────────
  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          // Logo mark
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