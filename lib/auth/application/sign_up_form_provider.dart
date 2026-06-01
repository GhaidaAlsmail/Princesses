import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reactive_forms/reactive_forms.dart';

final signUpFormProvider = Provider((ref) {
  return FormGroup({
    "country": FormControl<String>(
      value: null,
      validators: [Validators.required],
    ),

    "notes": FormControl<String>(validators: []),
    "userName": FormControl<String>(validators: [Validators.required]),
    "email": FormControl<String>(
      validators: [Validators.required, Validators.email],
    ),
    "password": FormControl<String>(
      validators: [Validators.required, Validators.minLength(8)],
    ),
  });
});
