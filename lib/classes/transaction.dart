import 'package:flutter/material.dart';

class Transaction {
  double montant;
  String date;
  TimeOfDay heure;
  String numeroTransaction;

  Transaction({
    required this.montant,
    required this.date,
    required this.heure,
    required this.numeroTransaction,
  });

  static Transaction fromJson(Map<String, dynamic> json) {
    String heureString = json['heure'];
    TimeOfDay heure = _convertToTimeOfDay(heureString);

    return Transaction(
      montant: json['montant'],
      date: json['date'],
      heure: heure,
      numeroTransaction: json['numeroTransaction'],
    );
  }

  static TimeOfDay _convertToTimeOfDay(String timeString) {

    List<String> hourMinute = timeString.split(' ')[0].split(':');
    int hour = int.parse(hourMinute[0]);
    int minute = int.parse(hourMinute[1]);

    if (timeString.contains('PM') && hour != 12) {
      hour += 12;
    }

    return TimeOfDay(hour: hour, minute: minute);
  }
}
