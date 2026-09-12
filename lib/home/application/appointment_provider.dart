import 'package:princesses/home/application/appoitment_service.dart';
import 'package:princesses/home/application/current_user_provider.dart';
import 'package:princesses/home/data/firestore_appointment_repository.dart';
import 'package:princesses/home/domain/appointment_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:reactive_phone_form_field/reactive_phone_form_field.dart';

final defaultPhoneValue = PhoneNumber(nsn: '', isoCode: IsoCode.SY);

final appointmentProvider = Provider<FormGroup>((ref) {
  return FormGroup({
    'name': FormControl<String>(validators: [Validators.required]),
    //اسم الصالة
    'place': FormControl<String>(validators: [Validators.required]),

    //اسم الوسيط
    'hasMediator': FormControl<bool>(value: false),
    'mediator': FormControl<String>(value: ''),
    'city': FormControl<String>(value: 'idleb'),

    'notes': FormControl<String>(validators: [Validators.required]),

    //  حقل رقم الجوال
    'phone': FormControl<PhoneNumber>(
      value: defaultPhoneValue,
      validators: [Validators.required],
    ),

    //  حقل التاريخ (من الأفضل يكون DateTime)
    'date': FormControl<DateTime>(validators: [Validators.required]),

    //  رقم (قيمة رقمية كنص)
    'number': FormControl<String>(
      validators: [Validators.required, Validators.pattern(r'^[0-9]+$')],
    ),

    //  البريد الإلكتروني
    'email': FormControl<String>(validators: [Validators.email]),

    //  المبلغ المدفوع
    'paid': FormControl<String>(
      validators: [Validators.required, Validators.pattern(r'^[0-9]+$')],
    ),

    //  المبلغ المتبقي
    'rest': FormControl<String>(
      validators: [Validators.required, Validators.pattern(r'^[0-9]+$')],
    ),
    'hasCoversService': FormControl<bool>(value: false),
    // الحقول الجديدة الخاصة بالخدمات والريف داخل الفورم
    'hasMemoriesCorner': FormControl<bool>(value: false),
    'hasSafesCorner': FormControl<bool>(value: false),
    'hasCar': FormControl<bool>(value: false),
    'isRural': FormControl<bool>(value: false),
    'ruralLocation': FormControl<String>(value: ''),
    'transportFees': FormControl<double>(value: 0.0),
    'customRuralLocation': FormControl<String>(),
    'customTransportFees': FormControl<String>(value: '0'),
    'memoriesCornerPrice': FormControl<double>(value: 0.0),
    'safesCornerPrice': FormControl<double>(value: 0.0),
    'coversServicePrice': FormControl<double>(value: 0.0),
  });
});

final reservationsProvider = StreamProvider<List<AppointmentModel>>((ref) {
  // 1. مراقبة حالة المستخدم الحالي كـ AsyncValue (بدون await)
  final userAsyncValue = ref.watch(currentUserProvider);

  // 2. استخدام .when للتعامل مع الحالات غير المتزامنة
  return userAsyncValue.when(
    // أثناء تحميل بيانات المستخدم (Future)
    loading: () => const Stream.empty(),

    // في حال حدث خطأ أثناء جلب بيانات المستخدم
    error: (e, s) => Stream.error(e, s),

    // عندما تكون بيانات المستخدم جاهزة
    data: (user) {
      // 3. تطبيق منطق التصفية حسب الدور
      if (user == null) {
        return Stream.value([]); // إذا لم يكن هناك مستخدم مسجل دخول
      }

      final service = ref.watch(appoitmentServiceProvider);

      if (user.isAdmin) {
        // إذا كان أدمن: يرجع Stream كل الحجوزات
        return service.streamAppointments();
      } else {
        // إذا كان مستخدم عادي: يرجع Stream حجوزات مدينته فقط
        return service.streamAppointmentsByCity(user.city);
      }
    },
  );
});

final getResProvider = StreamProvider<List<AppointmentModel>>((ref) {
  final appService = ref.watch(firestoreAppoitmentRepositoryProvider);
  return appService.streamAppointments();
});

final myReservationsCityProvider =
    StreamProvider.family<List<AppointmentModel>, String>((ref, city) {
      final resService = ref.watch(appoitmentServiceProvider);
      return resService.streamAppointmentsByCity(city);
    });

final appointmentNotifierProvider =
    StateNotifierProvider<AppointmentNotifier, AsyncValue<void>>(
      (ref) => AppointmentNotifier(ref.read(appoitmentServiceProvider)),
    );

class AppointmentNotifier extends StateNotifier<AsyncValue<void>> {
  AppointmentNotifier(this._service) : super(const AsyncData(null));

  final AppoitmentService _service;

  Future<void> add(AppointmentModel app) async {
    state = const AsyncLoading();
    try {
      await _service.addAppointment(app);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

final getAppointmentsFutureProvider = FutureProvider<List<AppointmentModel>>((
  ref,
) async {
  final appService = ref.watch(appoitmentServiceProvider);
  return appService.getAppointments();
});
