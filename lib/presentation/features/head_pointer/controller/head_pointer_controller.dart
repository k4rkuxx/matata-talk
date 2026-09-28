import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import '../../../../domain/models/head_pointer_settings.dart';

typedef OnHeadPointerClick = void Function(Offset normalizedPosition);

class HeadPointerController extends ChangeNotifier {
  HeadPointerSettings _settings;
  final OnHeadPointerClick? onPointerClick;

  CameraController? _cameraController;
  FaceDetector? _faceDetector;

  bool _isInitialized = false;
  bool _isRunning = false;
  bool _isProcessingFrame = false;
  bool _isFaceDetected = false;
  String? _errorMessage;

  // Calibración y orientación
  double _calibratedYaw = 0.0;
  double _calibratedPitch = 0.0;
  double _lastRawYaw = 0.0;
  double _lastRawPitch = 0.0;

  // Coordenadas normalizadas [0.0 - 1.0]
  double _pointerX = 0.5;
  double _pointerY = 0.5;

  // Dwell timer
  Timer? _dwellTimer;
  double _dwellProgress = 0.0;
  Offset? _dwellAnchorPosition;
  DateTime? _dwellStartTime;
  bool _isInCooldown = false;

  HeadPointerController({
    required HeadPointerSettings settings,
    this.onPointerClick,
  }) : _settings = settings;

  // Getters
  bool get isInitialized => _isInitialized;
  bool get isRunning => _isRunning;
  bool get isFaceDetected => _isFaceDetected;
  String? get errorMessage => _errorMessage;
  Offset get normalizedPosition => Offset(_pointerX, _pointerY);
  double get dwellProgress => _dwellProgress;
  CameraController? get cameraController => _cameraController;
  HeadPointerSettings get settings => _settings;

  void updateSettings(HeadPointerSettings settings) {
    final wasEnabled = _settings.enabled;
    _settings = settings;

    if (settings.enabled && !wasEnabled) {
      start();
    } else if (!settings.enabled && wasEnabled) {
      stop();
    }
    notifyListeners();
  }

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final cameras = await availableCameras();
      final frontCamera = cameras.firstWhere(
        (cam) => cam.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      _cameraController = CameraController(
        frontCamera,
        ResolutionPreset.low, // 240p/480p para máximo rendimiento y baja latencia
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.nv21,
      );

      await _cameraController!.initialize();

      _faceDetector = FaceDetector(
        options: FaceDetectorOptions(
          performanceMode: FaceDetectorMode.accurate,
          enableClassification: true, // Sonrisa y ojos para gestos
          enableLandmarks: true,
        ),
      );

      _isInitialized = true;
      _errorMessage = null;

      if (_settings.enabled) {
        await start();
      }
    } catch (e) {
      _errorMessage = 'Error al inicializar cámara: $e';
      notifyListeners();
    }
  }

  Future<void> start() async {
    if (!_isInitialized) {
      await initialize();
    }
    if (_isRunning || _cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    try {
      _isRunning = true;
      _isProcessingFrame = false;
      _dwellProgress = 0.0;
      _dwellAnchorPosition = null;

      await _cameraController!.startImageStream(_processCameraFrame);
      _startDwellTicker();
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error al iniciar captura: $e';
      _isRunning = false;
      notifyListeners();
    }
  }

  Future<void> stop() async {
    _isRunning = false;
    _isFaceDetected = false;
    _stopDwellTicker();
    _dwellProgress = 0.0;

    try {
      if (_cameraController != null && _cameraController!.value.isStreamingImages) {
        await _cameraController!.stopImageStream();
      }
    } catch (_) {}

    notifyListeners();
  }

  void calibrateCenter() {
    _calibratedYaw = _lastRawYaw;
    _calibratedPitch = _lastRawPitch;
    _pointerX = 0.5;
    _pointerY = 0.5;
    _resetDwell();
    notifyListeners();
  }

  // ----- PROCESAMIENTO DE FRAMES -----

  Future<void> _processCameraFrame(CameraImage image) async {
    if (!_isRunning || _isProcessingFrame || _faceDetector == null || _cameraController == null) {
      return;
    }
    _isProcessingFrame = true;

    try {
      final inputImage = _inputImageFromCameraImage(image, _cameraController!.description);
      if (inputImage == null) {
        _isProcessingFrame = false;
        return;
      }

      final faces = await _faceDetector!.processImage(inputImage);

      if (faces.isNotEmpty) {
        final face = faces.first;
        _isFaceDetected = true;

        final rawYaw = face.headEulerAngleY ?? 0.0;
        final rawPitch = face.headEulerAngleX ?? 0.0;
        _lastRawYaw = rawYaw;
        _lastRawPitch = rawPitch;

        // Calcular desplazamiento relativo al centro calibrado
        final deltaYaw = rawYaw - _calibratedYaw;
        final deltaPitch = rawPitch - _calibratedPitch;

        // Filtro de Zona Muerta (Dead zone anti-temblor)
        final effectiveYaw = _applyDeadZone(deltaYaw, _settings.deadZone);
        final effectivePitch = _applyDeadZone(deltaPitch, _settings.deadZone);

        // Mapeo a pantalla con sensibilidad
        // Yaw gira hacia los lados: ~20-25 grados de rango normal
        final horizontalFactor = (_settings.mirrorX ? -1.0 : 1.0);
        final targetX = 0.5 + horizontalFactor * (effectiveYaw / 22.0) * _settings.sensitivityX;
        // Pitch inclina arriba/abajo: ~15-20 grados de rango normal
        final targetY = 0.5 - (effectivePitch / 18.0) * _settings.sensitivityY;

        // Filtro de Suavizado Pasa-Bajos (Exponential Moving Average)
        final smoothing = _settings.smoothingFactor.clamp(0.08, 0.6);
        _pointerX = (_pointerX * (1.0 - smoothing) + targetX.clamp(0.02, 0.98) * smoothing).clamp(0.02, 0.98);
        _pointerY = (_pointerY * (1.0 - smoothing) + targetY.clamp(0.02, 0.98) * smoothing).clamp(0.02, 0.98);

        // Gesto opcional: Sonrisa
        if (_settings.triggerOnSmile && !_isInCooldown) {
          final smile = face.smilingProbability ?? 0.0;
          if (smile > 0.75) {
            _triggerClick();
          }
        }
      } else {
        _isFaceDetected = false;
      }
    } catch (_) {
      // Ignorar caídas de frames individuales
    } finally {
      _isProcessingFrame = false;
      notifyListeners();
    }
  }

  double _applyDeadZone(double val, double deadZone) {
    if (val.abs() <= deadZone) return 0.0;
    return val > 0 ? val - deadZone : val + deadZone;
  }

  InputImage? _inputImageFromCameraImage(CameraImage image, CameraDescription camera) {
    try {
      final rotation = InputImageRotationValue.fromRawValue(camera.sensorOrientation) ??
          InputImageRotation.rotation0deg;
      final format = InputImageFormatValue.fromRawValue(image.format.raw) ??
          InputImageFormat.nv21;

      final bytes = Uint8List.fromList(
        image.planes.fold<List<int>>(<int>[], (prev, plane) => prev..addAll(plane.bytes)),
      );

      return InputImage.fromBytes(
        bytes: bytes,
        metadata: InputImageMetadata(
          size: Size(image.width.toDouble(), image.height.toDouble()),
          rotation: rotation,
          format: format,
          bytesPerRow: image.planes.first.bytesPerRow,
        ),
      );
    } catch (_) {
      return null;
    }
  }

  // ----- LÓGICA DE DWELL CLICK -----

  void _startDwellTicker() {
    _dwellTimer?.cancel();
    _dwellTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (!_isRunning || !_isFaceDetected || _isInCooldown) return;

      final currentPos = normalizedPosition;
      if (_dwellAnchorPosition == null) {
        _dwellAnchorPosition = currentPos;
        _dwellStartTime = DateTime.now();
        _dwellProgress = 0.0;
        notifyListeners();
        return;
      }

      // Si el puntero se movió más allá del umbral de tolerancia (0.06 normalizado ~ 6% de pantalla)
      final distance = (currentPos - _dwellAnchorPosition!).distance;
      if (distance > 0.065) {
        // Se movió a un nuevo destino: reiniciar dwell
        _dwellAnchorPosition = currentPos;
        _dwellStartTime = DateTime.now();
        _dwellProgress = 0.0;
        notifyListeners();
        return;
      }

      // Calcular progreso de fijación
      final elapsedMs = DateTime.now().difference(_dwellStartTime!).inMilliseconds;
      final progress = (elapsedMs / _settings.dwellDurationMs).clamp(0.0, 1.0);
      _dwellProgress = progress;

      if (_dwellProgress >= 1.0) {
        _triggerClick();
      } else {
        notifyListeners();
      }
    });
  }

  void _stopDwellTicker() {
    _dwellTimer?.cancel();
    _dwellTimer = null;
  }

  void _resetDwell() {
    _dwellProgress = 0.0;
    _dwellAnchorPosition = null;
    _dwellStartTime = null;
  }

  void _triggerClick() {
    _isInCooldown = true;
    _dwellProgress = 1.0;
    notifyListeners();

    onPointerClick?.call(normalizedPosition);

    // Enfriamiento de 600ms antes de permitir la siguiente selección
    Future.delayed(const Duration(milliseconds: 600), () {
      _isInCooldown = false;
      _resetDwell();
      notifyListeners();
    });
  }

  @override
  void dispose() {
    stop();
    _faceDetector?.close();
    _cameraController?.dispose();
    super.dispose();
  }
}
