import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../providers/task_provider.dart';
import '../models/task.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Statistics',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      body: FutureBuilder<Map<String, int>>(
        future: taskProvider.getStatistics(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final stats = snapshot.data ?? {'total': 0, 'completed': 0, 'pending': 0};
          final total = stats['total'] ?? 0;
          final completed = stats['completed'] ?? 0;
          final pending = stats['pending'] ?? 0;
          final completionRate = total > 0 ? completed / total : 0.0;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Completion Rate Card
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      const Text(
                        'Overall Completion Rate',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),
                      CircularPercentIndicator(
                        radius: 80,
                        lineWidth: 16,
                        percent: completionRate,
                        center: Text(
                          '${(completionRate * 100).toStringAsFixed(0)}%',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        progressColor: Colors.green,
                        backgroundColor: Colors.grey[200]!,
                        circularStrokeCap: CircularStrokeCap.round,
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatItem(
                            'Total',
                            total.toString(),
                            Colors.blue,
                          ),
                          _buildStatItem(
                            'Completed',
                            completed.toString(),
                            Colors.green,
                          ),
                          _buildStatItem(
                            'Pending',
                            pending.toString(),
                            Colors.orange,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Priority Distribution
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Priority Distribution',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildPriorityChart(taskProvider.tasks),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Task Breakdown
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Task Breakdown',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildProgressBar(
                        'Completed',
                        completed,
                        total,
                        Colors.green,
                      ),
                      const SizedBox(height: 12),
                      _buildProgressBar(
                        'Pending',
                        pending,
                        total,
                        Colors.orange,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Quick Stats
              Row(
                children: [
                  Expanded(
                    child: _buildQuickStatCard(
                      'Today\'s Tasks',
                      taskProvider.todayTasks.length.toString(),
                      Icons.today,
                      Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildQuickStatCard(
                      'This Week',
                      _getThisWeekTaskCount(taskProvider.tasks).toString(),
                      Icons.date_range,
                      Colors.purple,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildPriorityChart(List<Task> tasks) {
    final highPriority = tasks.where((t) => t.priority == 2).length;
    final mediumPriority = tasks.where((t) => t.priority == 1).length;
    final lowPriority = tasks.where((t) => t.priority == 0).length;
    final total = tasks.length;

    if (total == 0) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text('No tasks to display'),
        ),
      );
    }

    return SizedBox(
      height: 200,
      child: PieChart(
        PieChartData(
          sectionsSpace: 2,
          centerSpaceRadius: 40,
          sections: [
            PieChartSectionData(
              value: highPriority.toDouble(),
              title: '$highPriority',
              color: Colors.red,
              radius: 60,
              titleStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            PieChartSectionData(
              value: mediumPriority.toDouble(),
              title: '$mediumPriority',
              color: Colors.orange,
              radius: 60,
              titleStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            PieChartSectionData(
              value: lowPriority.toDouble(),
              title: '$lowPriority',
              color: Colors.green,
              radius: 60,
              titleStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(String label, int value, int total, Color color) {
    final percentage = total > 0 ? value / total : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '$value / $total',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearPercentIndicator(
          lineHeight: 12,
          percent: percentage,
          backgroundColor: Colors.grey[200]!,
          progressColor: color,
          barRadius: const Radius.circular(6),
        ),
      ],
    );
  }

  Widget _buildQuickStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _getThisWeekTaskCount(List<Task> tasks) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));

    return tasks.where((task) {
      return task.dueDate.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
          task.dueDate.isBefore(endOfWeek.add(const Duration(days: 1)));
    }).length;
  }
}
