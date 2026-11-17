# RutaAccesible IA — Asistente Urbano Multimodal (Frontend Flutter)

Aplicación móvil en Flutter desarrollada para el **Hackatón Nacional de Innovación con IA Aplicada 2026 (UVM - Ingenio Incluyente)**. Su objetivo es asistir a **personas con discapacidad motriz** (usuarios de silla de ruedas, muletas o bastón) y **adultos mayores** para evaluar en segundos qué tan seguro y accesible es un cruce peatonal o banqueta mediante fotografía, dictado por voz y alertas auditivas en voz alta.

---

## Alineación con ODS

- **ODS 10 (Reducción de las Desigualdades):** Promueve la autonomía e inclusión mediante información visual de alto contraste y alertas auditivas accesibles.
- **ODS 11 (Ciudades y Comunidades Sostenibles):** Facilita la identificación temprana de barreras arquitectónicas y riesgos peatonales.

---

## Funcionalidades Principales

- **Evaluación visual del entorno:** Captura de foto con la cámara o selección desde galería (`image_picker`).
- **Entrada multimodal por voz o texto:** Dictado por micrófono en tiempo real (`speech_to_text`) o escritura manual para consultar dudas específicas sobre el camino.
- **Alertas auditivas en voz alta:** Lectura automática del diagnóstico en español de México (`flutter_tts`, `es-MX`).
- **Semáforo de accesibilidad y alto contraste:** Interfaz diseñada para uso con una sola mano con niveles de riesgo (`Camino Seguro`, `Riesgo Medio`, `Alto Riesgo`), detección de rampa y recomendación de acción.
- **Modo Demostración + Conexión a Backend IA:** Funciona sin conexión externa usando 3 escenarios simulados (`Alto`, `Medio`, `Bajo`) y está lista para conectarse a un backend en Python (Google Gemini API) mediante la variable de compilación `BACKEND_API_URL`.

---

## Arquitectura del Proyecto

El código sigue una arquitectura por capas con patrón **MVVM** usando `ChangeNotifier`:

```text
lib/
├── domain/
│   └── models/
│       └── accessibility_diagnosis.dart   # Modelo de diagnóstico y RiskLevel
├── data/
│   ├── models/
│   │   └── diagnosis_api_model.dart       # Parseo de JSON del backend o texto plano
│   ├── repositories/
│   │   └── accessibility_repository.dart  # Alterna entre backend real y modo demo
│   └── services/
│       ├── accessibility_api_service.dart # Peticiones HTTP multipart/JSON
│       └── voice_assistant_service.dart   # TTS (es-MX) y reconocimiento de voz
├── ui/
│   ├── core/
│   │   ├── theme/app_theme.dart           # Paleta de alto contraste y semáforo
│   │   └── widgets/ruta_header.dart       # Encabezado y control de voz automática
│   └── features/scan/
│       ├── view_models/scan_view_model.dart
│       └── views/                         # Home, Analizando, Resultado y Voz
└── main.dart
```

---

## Requisitos y Ejecución

1. **Instalar dependencias:**
   ```bash
   flutter pub get
   ```

2. **Ejecutar en Modo Demostración (sin backend):**
   ```bash
   flutter run
   ```

3. **Ejecutar conectado al Backend en Python:**
   ```bash
   flutter run --dart-define=BACKEND_API_URL=http://TU_IP_LOCAL:8000/evaluar
   ```
   También puedes usar un archivo local `.env.json` (ya ignorado en `.gitignore`):
   ```bash
   flutter run --dart-define-from-file=.env.json
   ```

> **Seguridad:** Nunca guardes claves, contraseñas ni tokens dentro del código ni en archivos rastreados por Git.

---

## Pruebas y Análisis

```bash
flutter analyze
flutter test
```

---

## Flujo de Ramas (Git)

- `main`: Versiones estables listas para despliegue.
- `develop`: Rama principal de integración y progreso continuo.
