// ignore_for_file: use_build_context_synchronously

import 'package:princesses/home/data/firestore_appointment_repository.dart';
import 'package:princesses/home/domain/appointment_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:princesses/core/presentation/widgets/button.dart';

Center buildBookingButton(BuildContext context, WidgetRef ref, FormGroup form) {
  return Center(
    child: ReactiveFormConsumer(
      builder: (context, formGroup, child) {
        return MyButton(
          text: "حجز",
          textColor: Theme.of(context).colorScheme.primary,
          width: 350,
          iconColor: Theme.of(context).colorScheme.primary,
          fillColor: Theme.of(context).colorScheme.secondary.withAlpha(150),
          icon: Icons.app_registration_rounded,
          onpressed: formGroup.invalid
              ? null
              : () async {
                  try {
                    final repo = ref.read(
                      firestoreAppoitmentRepositoryProvider,
                    );

                    final appointment = AppointmentModel(
                      id: DateTime.now().millisecondsSinceEpoch
                          .toString(), // unique ID
                      name: form.control("name").value,
                      place: form.control("place").value,
                      mediator: form.control("mediator").value,
                      city: form.control("city").value,
                      notes: form.control("notes").value,
                      phone: form.control("phone").value.toString(),
                      date: form.control("date").value,
                      number: form.control("number").value,
                      email: form.control("email").value,
                      paid: form.control("paid").value,
                      rest: form.control("rest").value,
                    );

                    await repo.addAppointment(app: appointment);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          " تم حفظ الحجز بنجاح!",
                          textAlign: TextAlign.center,
                        ),
                        backgroundColor: Colors.green,
                      ),
                    );

                    formGroup.reset();
                    Navigator.pop(context);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "حدث خطأ أثناء حفظ الحجز: $e",
                          textAlign: TextAlign.center,
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
        );
      },
    ),
  );
}
