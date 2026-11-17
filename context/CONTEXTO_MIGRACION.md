# Contexto de Migración — RutaAccesible IA

Este documento resume todo el contexto técnico, funcional y de arquitectura trabajado en el proyecto **RutaAccesible IA** para migrarlo de forma limpia a un nuevo proyecto de Flutter creado desde la plantilla oficial de VS Code.

---

## 1. Propósito del Proyecto y Contexto del Hackatón

- **Nombre:** RutaAccesible IA — Asistente Urbano Multimodal (Frontend Flutter).
- **Contexto:** Hackatón Nacional de Innovación con IA Aplicada 2026 (UVM - Ingenio Incluyente), basado en `Caso de Estudio 2 - RutaAccesible IA (Hackatón UVM 2026).pdf`.
- **Objetivo:** Asistir a **personas con discapacidad motriz** (usuarios de sillas de ruedas, muletas o bastón) y **adultos mayores** para evaluar en segundos qué tan seguro y accesible es un cruce peatonal o banqueta mediante fotografía, dictado por voz y alertas auditivas en voz alta.
- **Alineación ODS:**
  - **ODS 10 (Reducción de las Desigualdades):** Promueve la autonomía e inclusión con información visual y auditiva accesible.
  - **ODS 11 (Ciudades y Comunidades Sostenibles):** Identificación temprana de barreras arquitectónicas y riesgos peatonales.
- **Uso de IA:**
  - **Backend (pendiente/externo en Python):** Google Gemini API (`gemini-2.5-flash`) para evaluar fotos de banquetas/cruces y devolver: 1) presencia de rampa, 2) obstáculos detectados, 3) nivel de riesgo (`Bajo`, `Medio`, `Alto`) y 4) mensaje corto de advertencia auditiva.
  - **Diseño de UI:** Basado en prototipos de **Google Stitch v2** (alto contraste, botones grandes para uso con una sola mano y semáforo de riesgo).
  - **Voz en dispositivo:** `flutter_tts` (lectura en voz alta en `es-MX`) y `speech_to_text` (dictado por micrófono).

---

## 2. Motivo de la Migración

Al comparar este proyecto con una plantilla nueva de Flutter creada desde VS Code, la plantilla nueva compila y se visualiza sin problemas en el dispositivo móvil físico. Para evitar arrastrar configuraciones o cachés problemáticas de Android/Gradle del proyecto anterior, se migrará únicamente:
1. La carpeta `lib/` y `test/widget_test.dart`.
2. Las dependencias de `pubspec.yaml`.
3. Los permisos y `<queries>` necesarios en `android/app/src/main/AndroidManifest.xml`.

---

## 3. Arquitectura y Archivos Implementados en `lib/`

El proyecto sigue una arquitectura por capas (`domain`, `data`, `ui` con patrón MVVM usando `ChangeNotifier`):

### Capa de Dominio (`lib/domain/`)
- `lib/domain/models/accessibility_diagnosis.dart`
  - `enum RiskLevel { bajo, medio, alto }`: Incluye `fromString()`, `badgeTitle` (`CAMINO SEGURO`, `RIESGO MEDIO`, `ALTO RIESGO`) y `photoBadgeLabel`.
  - `class AccessibilityDiagnosis`: Contiene `hasRamp`, `headline`, `obstaclesDescription`, `riskLevel`, `actionRecommendation`, `audioWarningMessage`, `imagePath` y `userVoicePrompt`.

### Capa de Datos (`lib/data/`)
- `lib/data/models/diagnosis_api_model.dart`
  - `DiagnosisApiModel`: Soporta tanto JSON estructurado del backend (`tiene_rampa`, `titulo`, `obstaculos_detectados`, `nivel_riesgo`, `recomendacion`, `advertencia_auditiva`, con alias en inglés y español) como texto plano de Gemini (`fromRawText`).
- `lib/data/services/accessibility_api_service.dart`
  - Lee la URL del backend desde variable de entorno en tiempo de compilación:
    `static const String backendApiUrl = String.fromEnvironment('BACKEND_API_URL');`
  - Si `BACKEND_API_URL` está configurada, envía `MultipartRequest` (`POST`) con el archivo `imagen` y el campo opcional `consulta_voz` (o JSON si no hay imagen).
  - Si no hay backend configurado, usa `fetchDemoDiagnosis()` con los 3 escenarios de demostración (`Alto`, `Medio`, `Bajo`).
- `lib/data/services/voice_assistant_service.dart`
  - Inicializa `FlutterTts` en español de México (`es-MX`, `speechRate: 0.48`).
  - Administra `SpeechToText` para dictado por micrófono en tiempo real.
- `lib/data/repositories/accessibility_repository.dart`
  - Decide entre consultar el backend real (cuando `hasLiveBackend && !forceDemoMode`) o usar el modo demostración.

### Capa de Interfaz (`lib/ui/`)
- `lib/ui/core/theme/app_theme.dart`: Paleta de colores oficial (Google Stitch v2), superficies de alto contraste y colores de semáforo (verde seguro, ámbar precaución, rojo peligro).
- `lib/ui/core/widgets/ruta_header.dart`: Encabezado superior con botón de regreso y control de voz automática.
- `lib/ui/features/scan/view_models/scan_view_model.dart`:
  - Flujo de 3 etapas (`ScanStep`: `home`, `analyzing`, `result`).
  - Integra `ImagePicker` (cámara y galería con `imageQuality: 85`, `maxWidth: 1600`), micrófono, lectura automática por voz y selector de escenario demo.
- `lib/ui/features/scan/views/`:
  - `scan_flow_page.dart`: Contenedor principal con `PopScope`, `RutaHeader` y `AnimatedSwitcher`.
  - `scan_home_view.dart`: Pantalla 1 ("Listo para mirar", botón "Revisar Camino", galería y micrófono).
  - `analyzing_view.dart`: Pantalla 2 ("Analizando el camino con IA..." con animación).
  - `diagnosis_result_view.dart`: Pantalla 3 (Tarjeta de diagnóstico rápido adaptable a Alto, Medio y Seguro, estado de rampa, recomendación y control de audio).
  - `voice_input_sheet.dart`: Hoja modal para dictado por voz o escritura de consulta.
- `lib/main.dart`: Inicializa servicios, repositorio, `ScanViewModel` y `RutaAccesibleApp`.

### Pruebas (`test/`)
- `test/widget_test.dart`: Verifica que `RutaAccesibleApp` renderiza la pantalla inicial (`RUTAACCESIBLE IA`, `Navegación En Vivo`, `Listo para mirar`, `Revisar Camino`, `Subir foto de galería`, `Hablar por micrófono`).

---

## 4. Dependencias Requeridas (`pubspec.yaml`)

En el nuevo proyecto creado desde la plantilla de VS Code, se deben agregar estas dependencias (respetando el `sdk` de la nueva plantilla):

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  http: ^1.6.0
  image_picker: ^1.2.4
  flutter_tts: ^4.2.5
  speech_to_text: ^7.5.0
```

---

## 5. Configuración Necesaria en Android (`AndroidManifest.xml`)

En el nuevo proyecto, dentro de `android/app/src/main/AndroidManifest.xml` (sin reemplazar la configuración de Gradle que ya funcionó en la plantilla nueva), agregar:

1. **Permisos** (antes de `<application>`):
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.CAMERA" />
```

2. **En la etiqueta `<application>`**:
   - `android:label="RutaAccesible IA"`
   - `android:usesCleartextTraffic="true"` (útil si el backend local en Python corre por `http://` durante pruebas).

3. **En `<queries>`** (necesario en Android 11+ para voz):
```xml
<intent>
    <action android:name="android.speech.RecognitionService" />
</intent>
<intent>
    <action android:name="android.intent.action.TTS_SERVICE" />
</intent>
```

---

## 6. Seguridad y Variables de Entorno

- **Nunca guardar claves, contraseñas ni tokens dentro del código ni en archivos que se suban a GitHub.**
- Ejecución en **Modo Demostración** (sin backend):
  ```bash
  flutter run
  ```
- Ejecución conectada al **Backend en Python**:
  ```bash
  flutter run --dart-define=BACKEND_API_URL=http://TU_IP_LOCAL:8000/evaluar
  ```
  *(O mediante `--dart-define-from-file=.env.json` manteniendo `.env.json` en `.gitignore`).*

---

## 7. Archivos de Referencia en el Directorio Original

Si se requieren para consulta o documentación en el nuevo directorio:
- `README.md`
- `Caso de Estudio 2 - RutaAccesible IA (Hackatón UVM 2026).pdf`
- `rutaAccesible-diseño-preliminar.zip`
- `rutaAccesible-diseño-preliminar-v2.zip`

---

## 8. Prompt Sugerido para Iniciar la Nueva Conversación

Puedes copiar este mensaje en tu nueva conversación dentro del nuevo directorio:

> "Hola. Estoy migrando el proyecto **RutaAccesible IA** a este nuevo directorio creado con la plantilla limpia de Flutter en VS Code (porque la plantilla limpia sí compila y corre bien en mi teléfono). Lee el archivo `CONTEXTO_MIGRACION.md` y ayúdame a migrar paso a paso las dependencias, los permisos de Android y el código de `lib/` y `test/` desde el proyecto anterior `C:\Users\Josea\Programacion-Proyectos\Antigravity\RutaAccesibleIA`, probando que compile y funcione en mi dispositivo móvil."
