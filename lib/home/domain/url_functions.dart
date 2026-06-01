import 'package:url_launcher/url_launcher.dart';

Future<void> openWhatsApp() async {
  const phone = '46762543094'; // بدون +
  final url = Uri.parse('https://wa.me/$phone');

  try {
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      // إذا فشل التطبيق، نحاول فتح المتصفح
      await launchUrl(url, mode: LaunchMode.platformDefault);
    }
  } catch (e) {
    // fallback أخير لمحاكي أو Web
    await launchUrl(url, mode: LaunchMode.inAppWebView);
  }
}

Future<void> openFacebook() async {
  const fbUrl = 'fb://page/amiratphoto';
  const fbWebUrl = 'https://www.facebook.com/amiratphoto';
  if (await canLaunchUrl(Uri.parse(fbUrl))) {
    await launchUrl(Uri.parse(fbUrl), mode: LaunchMode.externalApplication);
  } else {
    await launchUrl(Uri.parse(fbWebUrl), mode: LaunchMode.platformDefault);
  }
}

Future<void> openInstagram() async {
  const instaAppUrl = 'instagram://user?username=amirat_photo';
  const instaWebUrl = 'https://www.instagram.com/amirat_photo/';
  if (await canLaunchUrl(Uri.parse(instaAppUrl))) {
    await launchUrl(
      Uri.parse(instaAppUrl),
      mode: LaunchMode.externalApplication,
    );
  } else {
    await launchUrl(Uri.parse(instaWebUrl), mode: LaunchMode.platformDefault);
  }
}
