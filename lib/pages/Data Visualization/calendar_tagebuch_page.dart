import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'visualize_tagebuch_page.dart';

class CalendarTagebuchPage extends StatefulWidget {
  const CalendarTagebuchPage({super.key});

  @override
  _CalendarTagebuchPageState createState() => _CalendarTagebuchPageState();
}

class _CalendarTagebuchPageState extends State<CalendarTagebuchPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // generic app bar (same on every page)
      appBar: AppBar(
        title: const Text(
          "SomniLink",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
        elevation: 6,
      ),
      // define look of the calender (same like the one of adding a new tagebuch)
      body: Center(
        child: TableCalendar(
          firstDay: DateTime.utc(2025, 1, 1),
          lastDay: DateTime.utc(2100, 12, 31),
          focusedDay: _focusedDay,
          calendarFormat: CalendarFormat.month,

          selectedDayPredicate: (day) =>
              isSameDay(_selectedDay, day),

          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
            // forward to the tagebuch visualization page, with the selected day as takeover parameter
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => VisualizeTagebuchPage(
                  selectedDate: selectedDay,
                ),
              ),
            );
          },

          onPageChanged: (focusedDay) {
            _focusedDay = focusedDay;
          },

          headerStyle: const HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
          ),
          calendarStyle: const CalendarStyle(
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
