# 🗺️ Roadmap de Desarrollo de MatataTalk

Plan de ejecución estructurado por fases para llevar a **MatataTalk** desde el prototipo hasta la versión de producción en Google Play y F-Droid.

---

## 📍 Fase 1: Motor Base & Cuadrícula Motora (MVP Funcional)
- [x] Configuración del proyecto con FVM y arquitectura Clean.
- [x] Modelos de dominio: `AACBoard`, `AACButton`, `MessageToken`, `PartOfSpeech`.
- [x] Paleta de colores estándar Fitzgerald Modificado.
- [x] Tablero base de Palabras Núcleo (*Core Words*) y subcarpeta de Comida.
- [x] Barra superior de mensajes con visualización de pictogramas.
- [x] Síntesis de voz nativa (TTS) en español para botones individuales y frase completa.
- [ ] Renderizado dinámico de pictogramas vectoriales de ARASAAC (`.vg` / SVG).

---

## 📍 Fase 2: Motor Morfológico & Gramática Dinámica
- [ ] Implementación de `SpanishGrammarEngine` (conjugador regular e irregular).
- [ ] Widget de rueda/matriz emergente (*Morphology Popup*) activado por pulsación prolongada (*Long-Press*).
- [ ] Reglas de pluralización automática para sustantivos.
- [ ] Concordancia de género y número en artículos y adjetivos.

---

## 📍 Fase 3: Navegación Avanzada & Buscador Guiado (*Path Finder*)
- [ ] Base de datos local **Drift (SQLite)** con soporte **FTS5** para indexar todo el vocabulario.
- [ ] Algoritmo de búsqueda de rutas en grafo para palabras profundas.
- [ ] Animación de superposición (*Canvas Overlay*) que guía visualmente la pulsación paso a paso.
- [ ] Historial de frases y botón de "Frases Rápidas" de uso frecuente.

---

## 📍 Fase 4: Accesibilidad Universal & Métodos de Acceso
- [ ] Filtros táctiles avanzados: tiempo mínimo de retención (*hold time*) y debounce.
- [ ] Modo de activación al soltar (*Release to Activate*).
- [ ] Motor de barrido por conmutadores (*Switch Scanning*) para 1 y 2 conmutadores Bluetooth.
- [ ] Barrido auditivo con retroalimentación acústica previa.
- [ ] Prototipo de puntero facial (*Head Tracking*) usando la cámara frontal y MediaPipe.

---

## 📍 Fase 5: Ecosistema, Interoperabilidad & Comunidad
- [ ] Soporte de importación y exportación de paquetes estándar **Open Board Format (`.obf` / `.obz`)**.
- [ ] Sistema de perfiles múltiples (soporte para terapeutas y escuelas).
- [ ] Respaldo y restauración de perfiles en archivos locales y almacenamiento en la nube.
- [ ] Publicación en **F-Droid** y **Google Play Store**.
