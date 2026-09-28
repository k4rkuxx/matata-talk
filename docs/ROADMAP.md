# 🗺️ Roadmap de Desarrollo de MatataTalk

Plan de ejecución estructurado por fases para llevar a **MatataTalk** desde el prototipo hasta la versión de producción en Google Play y F-Droid.

---

## 📍 Fase 1: Motor Base & Cuadrícula Motora (MVP Funcional)
- [x] Configuración del proyecto con FVM y arquitectura Clean.
- [x] Modelos de dominio: `AACBoard`, `AACButton`, `MessageToken`, `PartOfSpeech`.
- [x] Paleta de colores estándar Fitzgerald Modificado.
- [x] Tablero base de Palabras Núcleo (*Core Words*) y subcarpetas (Comida, Acciones, Emociones, Juguetes).
- [x] Barra superior de mensajes con visualización de pictogramas e instrucción persistente superior.
- [x] Síntesis de voz nativa (TTS) en español para botones individuales y frase completa.
- [x] Renderizado dinámico de pictogramas ARASAAC (`AACSymbolWidget`) con soporte red y caché local.

---

## 📍 Fase 2: Motor Morfológico & Gramática Dinámica
- [x] Implementación de `SpanishGrammarEngine` (conjugador regular e irregular).
- [x] Widget de matriz emergente (*Morphology Popup*) activado por pulsación prolongada (*Long-Press*).
- [x] Reglas de pluralización automática para sustantivos.
- [x] Concordancia de género y número en sustantivos y adjetivos.

---

## 📍 Fase 3: Navegación Avanzada & Buscador Guiado (*Path Finder*)
- [x] Algoritmo de búsqueda de rutas en grafo para palabras profundas (`PathfinderService`).
- [x] Modal de búsqueda en tiempo real (`WordFinderDialog`) con vista previa de pictogramas y ruta motora.
- [x] Modo Guía paso a paso con halo azul visual (`SetHighlightButtonId`) en la cuadrícula motora.
- [ ] Base de datos local **Drift (SQLite)** con soporte **FTS5** para indexar vocabulario offline.
- [ ] Historial de frases y panel de "Frases Rápidas" de uso frecuente.

---

## 📍 Fase 4: Accesibilidad Universal & Métodos de Acceso
- [x] Filtros táctiles avanzados: tiempo mínimo de retención (*hold time*) con animación circular de progreso.
- [x] Filtro anti-rebote (*Debounce*) para evitar dobles pulsaciones involuntarias.
- [x] Modo de activación al pulsar (*Touch Down*) y al soltar (*Release to Activate*).
- [x] Diálogo interactivo de ajustes táctiles (`TouchAccessibilityDialog`) con zona de pruebas en vivo.
- [x] Persistencia local de ajustes de accesibilidad (`SharedPreferences`).
- [ ] Motor de barrido por conmutadores (*Switch Scanning*) para 1 y 2 conmutadores Bluetooth.
- [ ] Barrido auditivo con retroalimentación acústica previa.
- [ ] Prototipo de puntero facial (*Head Tracking*) usando la cámara frontal y MediaPipe.

---

## 📍 Fase 5: Ecosistema, Interoperabilidad & Comunidad
- [ ] Soporte de importación y exportación de paquetes estándar **Open Board Format (`.obf` / `.obz`)**.
- [ ] Sistema de perfiles múltiples (soporte para terapeutas y escuelas).
- [ ] Respaldo y restauración de perfiles en archivos locales y almacenamiento en la nube.
- [ ] Publicación en **F-Droid** y **Google Play Store**.
