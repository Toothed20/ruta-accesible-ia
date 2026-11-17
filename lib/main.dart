import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'data/repositories/accessibility_repository.dart';
import 'data/services/accessibility_api_service.dart';
import 'data/services/voice_assistant_service.dart';
import 'ui/core/theme/app_theme.dart';
import 'ui/features/scan/view_models/scan_view_model.dart';
import 'ui/features/scan/views/scan_flow_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  final apiService = AccessibilityApiService();
  final voiceService = VoiceAssistantService();
  final repository = AccessibilityRepository(apiService: apiService);
  final viewModel = ScanViewModel(
    repository: repository,
    voiceService: voiceService,
  );

  runApp(RutaAccesibleApp(viewModel: viewModel));
}

class RutaAccesibleApp extends StatelessWidget {
  const RutaAccesibleApp({super.key, required this.viewModel});

  final ScanViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RutaAccesible IA',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: ScanFlowPage(viewModel: viewModel),
    );
  }
}
