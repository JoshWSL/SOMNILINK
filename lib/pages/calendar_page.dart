import 'package:flutter/material.dart';
import 'package:rls_patient_app/pages/questionnaire_list_page.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "SomniLink",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: true,
        backgroundColor: Colors.blue,
        elevation: 6,
      ),
      body: Center(
        child: TableCalendar(
          firstDay: DateTime.utc(2025, 1, 1),
          lastDay: DateTime.utc(2100, 12, 31),
          focusedDay: _focusedDay,
          calendarFormat: CalendarFormat.month,

          // aktueller Tag automatisch markiert
          selectedDayPredicate: (day) {
            return isSameDay(_selectedDay, day);
          },

          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });

            // Beim Klick auf einen Tag Seite öffnen
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => QuestionnaireListPage(selectedDate: selectedDay,)),
            );
          },

          onPageChanged: (focusedDay) {
            _focusedDay = focusedDay;
          },

          headerStyle: HeaderStyle(
            formatButtonVisible: false, // nur Monatswechsel
            titleCentered: true,
          ),

          calendarStyle: CalendarStyle(
            todayDecoration: BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
            selectedDecoration: BoxDecoration(
              color: Colors.deepPurple,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}
