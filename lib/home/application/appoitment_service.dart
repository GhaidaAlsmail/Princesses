import 'package:princesses/home/data/firestore_appointment_repository.dart';
import 'package:princesses/home/domain/appointment_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'appoitment_service.g.dart';

@riverpod
AppoitmentService appoitmentService(Ref ref) => AppoitmentService(
  firestoreAppoitmentRepository: ref.read(
    firestoreAppoitmentRepositoryProvider,
  ),
);

class AppoitmentService {
  final FirestoreAppoitmentRepository firestoreAppoitmentRepository;
  AppoitmentService({required this.firestoreAppoitmentRepository});

  /// إضافة حجز جديد
  Future<void> addAppointment(AppointmentModel app) async {
    return firestoreAppoitmentRepository.addAppointment(app: app);
  }

  /// جلب جميع الحجوزات (أو أول حجز كما في المستودع)
  //   Future<List<AppointmentModel>> getAppointments() {
  //     // return firestoreAppoitmentRepository.getAppointments();
  //     return firestoreAppoitmentRepository.getAppointments();
  //   }
  //  FutureOr<List<AppointmentModel>> getAppointmentsByCity(String city) {
  //     return firestoreAppoitmentRepository.getAppointmentsByCity(city);
  //   }

  Stream<List<AppointmentModel>> streamAppointments() {
    // return firestoreAppoitmentRepository.getAppointments();
    return firestoreAppoitmentRepository.streamAppointments();
  }

  Stream<List<AppointmentModel>> streamAppointmentsByCity(String city) {
    return firestoreAppoitmentRepository.streamAppointmentsByCity(city);
  }

  /// تحديث حجز
  Future<void> updateAppointment(AppointmentModel app) async {
    await firestoreAppoitmentRepository.updateAppoitment(app: app);
  }

  /// حذف حجز
  Future<void> deleteAppointment(String id) async {
    await firestoreAppoitmentRepository.deleteAppoitment(id: id);
  }

  /// قراءة حجز واحد
  Future<AppointmentModel?> readAppointment(String id) {
    return firestoreAppoitmentRepository.readAppointment(id: id);
  }
}
