import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doctor_booking_flutter/app/common/home/models/appointment.dart';
import 'package:doctor_booking_flutter/app/doctor/auth/data/models/doctor.dart';
import 'package:doctor_booking_flutter/app/patient/auth/data/models/patient.dart';
import 'package:doctor_booking_flutter/app/patient/home/data/data_source/appointment_datasource.dart';
import 'package:doctor_booking_flutter/core/api/firebase.dart';

class AppointmentDataSourceImpl extends AppointmentDataSource {
  final FirebaseFirestore firestore;
  final FirebaseApi firebaseApi;

  AppointmentDataSourceImpl(this.firestore, this.firebaseApi);

  @override
  Future<bool> bookDoctorAppointment(
      {required Appointment newAppointment,
      required Doctor doctor,
      required String patientEmail}) async {
    bool updated = false;
    //update doctors' appointment
    DocumentReference doctorDbRef =
        firestore.collection('doctors').doc(doctor.emailAddress);
    //update patient's appointment
    DocumentReference patientDbRef =
        firestore.collection('patients').doc(patientEmail);

    Patient patient = await firebaseApi.getPatientData(patientEmail);
    await patientDbRef.update({
      'appointments': [newAppointment, ...patient.appointments]
          .map((e) => e.toJson())
          .toList()
    });
    await doctorDbRef.update({
      'appointments': [newAppointment, ...doctor.appointments]
          .map((e) => e.toJson())
          .toList()
    });
    updated = true;

    return updated;
  }
}