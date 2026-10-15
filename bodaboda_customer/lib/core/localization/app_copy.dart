import 'package:flutter/widgets.dart';

String appCopy(BuildContext context, String english, String swahili) =>
    Localizations.localeOf(context).languageCode == 'sw' ? swahili : english;