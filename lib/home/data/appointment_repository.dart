import 'package:princesses/home/domain/appointment_model.dart';

abstract class AppoitmentRepository {
  Future<void> addAppointment({required AppointmentModel app});
  Future<AppointmentModel?> readAppointment({required String id});
  Future<void> updateAppoitment({required AppointmentModel app});
  Future<void> deleteAppoitment({required String id});
  Stream<List<AppointmentModel>> streamAppointments();
  Stream<List<AppointmentModel>> streamAppointmentsByCity(String city);
  Future<List<AppointmentModel>> getAppointments();
}
