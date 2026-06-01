import 'package:princesses/home/application/appoitment_service.dart';
import 'package:princesses/home/data/firestore_appointment_repository.dart';
import 'package:princesses/home/domain/appointment_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

final getAppProvider = StreamProvider.family<AppointmentModel?, String>((
  ref,
  dayId,
) {
  final service = ref.watch(firestoreAppoitmentRepositoryProvider);
  return service.streamAppointment(id: dayId);
});

final updateAppointmentNotifierProvider =
    StateNotifierProvider<UpdateAppointmentNotifier, AsyncValue<void>>(
      (ref) => UpdateAppointmentNotifier(ref.read(appoitmentServiceProvider)),
    );

class UpdateAppointmentNotifier extends StateNotifier<AsyncValue<void>> {
  UpdateAppointmentNotifier(this._service) : super(const AsyncData(null));

  final AppoitmentService _service;

  Future<void> update(AppointmentModel app) async {
    state = const AsyncLoading();
    try {
      await _service.updateAppointment(app);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

final deleteAppProvider = FutureProvider.family<void, String>((ref, id) async {
  final repo = ref.watch(firestoreAppoitmentRepositoryProvider);
  await repo.deleteAppoitment(id: id);
});

final allReservationsStreamProvider = StreamProvider<List<AppointmentModel>>((
  ref,
) {
  final repo = ref.watch(firestoreAppoitmentRepositoryProvider);
  return repo.streamAppointments();
});
