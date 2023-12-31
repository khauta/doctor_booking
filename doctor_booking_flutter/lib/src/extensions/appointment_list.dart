import 'dart:math';

import 'package:doctor_booking_flutter/app/common/home/models/appointment.dart';
import 'package:doctor_booking_flutter/app/doctor/home/data/models/custom_appointment.dart';
import 'package:flutter/animation.dart';

extension AppointmentList on List<Appointment> {
  List<Color> get colorCollection => const <Color>[
        Color(0xFF0F8644),
        Color(0xFF8B1FA9),
        Color(0xFFD20100),
        Color(0xFFFC571D),
        Color(0xFF36B37B),
        Color(0xFF01A1EF),
        Color(0xFF3D4FB5),
        Color(0xFFE47C73),
        // Color(0xFF636363),
        Color(0xFF0A8043)
      ];

  List<CustomAppointment> toSyncfusionAppointment({bool isDoctor = true}) {
    final Random random = Random();
    return map((e) => CustomAppointment(
          appointment: e,
          subject:
              'Appointment with ${isDoctor ? e.patientName ?? 'a Patient' : 'Dr. ${e.doctorName!}'}',
          startTime: e.bookingStart!,
          endTime: e.bookingEnd!,
          notes: e.patientNote,
          color: e.bookingEnd!.isBefore(DateTime.now())
              ? const Color(0xFF636363)
              : colorCollection[random.nextInt(8)],
          /*recurrenceRule: 'FREQ=DAILY;INTERVAL=10'*/
        )).toList();
  }
}
