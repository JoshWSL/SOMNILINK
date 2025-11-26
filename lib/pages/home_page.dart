import 'package:flutter/material.dart';
import 'questionnaire_list_page.dart';
import 'graph_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ❌ KEINE bottomNavigationBar -> kommt aus root_navigation.dart

      body: SafeArea(
        child: Column(
          children: [
            // ---------- TAB BAR ----------
            Container(
              color: Colors.blue.shade50,
              child: TabBar(
                controller: _tabController,
                labelColor: Colors.blue,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Colors.blue,
                tabs: const [
                  Tab(text: "Fragebögen"),
                  Tab(text: "Graphen"),
                ],
              ),
            ),

            // ---------- TAB CONTENT ----------
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: const [
                  QuestionnaireListPage(),
                  HistoryPage(), // oder GraphPage()
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
