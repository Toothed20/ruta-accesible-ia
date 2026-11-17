import 'package:flutter_test/flutter_test.dart';
import 'package:ruta_accesible_ia/data/repositories/accessibility_repository.dart';
import 'package:ruta_accesible_ia/data/services/accessibility_api_service.dart';
import 'package:ruta_accesible_ia/data/services/voice_assistant_service.dart';
import 'package:ruta_accesible_ia/main.dart';
import 'package:ruta_accesible_ia/ui/features/scan/view_models/scan_view_model.dart';

void main() {
  testWidgets('Renderiza la pantalla de escaneo de RutaAccesible IA', (
    WidgetTester tester,
  ) async {
    final viewModel = ScanViewModel(
      repository: AccessibilityRepository(
        apiService: AccessibilityApiService(),
      ),
      voiceService: VoiceAssistantService(),
    );

    await tester.pumpWidget(RutaAccesibleApp(viewModel: viewModel));

    expect(find.text('RUTAACCESIBLE IA'), findsOneWidget);
    expect(find.text('Navegación En Vivo'), findsOneWidget);
    expect(find.text('Listo para mirar'), findsOneWidget);
    expect(find.text('Revisar Camino'), findsOneWidget);
    expect(find.text('Subir foto de galería'), findsOneWidget);
    expect(find.text('Hablar por micrófono'), findsOneWidget);
  });
}
