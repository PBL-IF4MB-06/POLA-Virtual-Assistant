import 'package:flutter/material.dart';

class TodayClass {
  const TodayClass({
    required this.course,
    required this.room,
    required this.time,
    required this.lecturer,
    required this.icon,
  });

  final String course;
  final String room;
  final String time;
  final String lecturer;
  final IconData icon;
}

class CampusSchedule {
  static const todayClasses = <TodayClass>[
    TodayClass(
      course: 'Pemrograman Web',
      room: 'Lab TI-2',
      time: '08:00 – 10:30',
      lecturer: 'Bpk. Ahmad, S.Kom',
      icon: Icons.code_rounded,
    ),
    TodayClass(
      course: 'Basis Data',
      room: 'Ruang 3.12',
      time: '10:45 – 12:15',
      lecturer: 'Ibu Siti, M.T.',
      icon: Icons.storage_rounded,
    ),
    TodayClass(
      course: 'PBL — Proyek IoT',
      room: 'Lab Elektronika',
      time: '13:00 – 15:30',
      lecturer: 'Tim Dosen PBL',
      icon: Icons.sensors_rounded,
    ),
  ];
}
