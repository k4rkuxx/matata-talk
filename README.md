# 🦁 MatataTalk

<p align="center">
  <strong>Comunicador Aumentativo y Alternativo (CAA / AAC) libre, multiplataforma y accesible.</strong>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white" alt="Flutter" />
  <img src="https://img.shields.io/badge/FVM-Enabled-blue?style=for-the-badge" alt="FVM" />
  <img src="https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web%20%7C%20Desktop-green?style=for-the-badge" alt="Platforms" />
  <img src="https://img.shields.io/badge/License-GPLv3-orange.svg?style=for-the-badge" alt="License" />
</p>

---

## 💖 Dedicatoria

> *Este proyecto fue creado con amor y en honor a mi hijo, **Mateo Rafael** ("Matata"), un niño autista no verbal.*
> 
> *Nace con la misión de derribar las barreras económicas de la tecnología asistiva para que cada persona no verbal tenga siempre en sus manos una voz libre, digna y accesible en cualquier dispositivo.*

---

## 🌟 ¿Qué es MatataTalk?

**MatataTalk** es una solución de Comunicación Aumentativa y Alternativa (CAA) de código abierto diseñada para personas con necesidades complejas de comunicación (autismo, parálisis cerebral, síndrome de Down, apraxia del habla, afasia, etc.).

Inspirado en los principios clínicos de aplicaciones de referencia como *Proloquo2Go*, **MatataTalk** traslada estas capacidades al ecosistema libre y multiplataforma, permitiendo su ejecución fluida en tablets y teléfonos Android económicos de bajo costo.

---

## 🎯 Pilares Clínicos y Técnicos

* 🧠 **Planificación Motora Estricta (*Motor Planning*):** Las palabras conservan su posición espacial inmutable en la cuadrícula, permitiendo al usuario desarrollar memoria muscular automatizada.
* 🗣️ **Vocabulario Núcleo (*Core Vocabulary*):** Priorización de las 200–400 palabras de alta frecuencia que representan el 80% de la comunicación diaria.
* 🎨 **Código de Colores Fitzgerald Modificado:** Categorización sintáctica visual estandarizada (amarillo = pronombres, verde = verbos, naranja = sustantivos, azul = adjetivos, rojo = seguridad/urgencia).
* 🇪🇸 **Motor Morfológico Dinámico en Español:** Flexión verbal en presente, pasado, futuro y subjuntivo, además de pluralización y concordancia de género.
* 🖼️ **Pictogramas Abiertos ARASAAC:** Integración offline de la biblioteca de símbolos ARASAAC optimizada para GPU mediante vectores binarios.
* ♿ **Accesibilidad Universal:** Adaptaciones táctiles (retención, debounce, activación al soltar) y soporte para barrido por conmutadores (*Switch Scanning*).
* 🔄 **Estándar Abierto OpenAAC:** Compatibilidad de importación y exportación de paquetes estándar (`.obf` / `.obz`).

---

## 🏗️ Arquitectura de Software

El proyecto está diseñado bajo **Clean Architecture** y separación estricta de responsabilidades:

```text
=======================================================================
                         MATATA-TALK ARCHITECTURE
=======================================================================

+---------------------------------------------------------------------+
|                     1. PRESENTATION LAYER (UI)                      |
|                                                                     |
|  [MessageBarView]       [MotorGridView]         [AACButtonWidget]   |
|   (Bandeja de Frase)     (Cuadrícula Fija)       (Botón Accesible)  |
|          |                      |                        |          |
|          v                      v                        v          |
|  [MessageBarBloc]           [GridBloc]             [ScannerBloc]    |
|   (Tokens & Audio)       (Navegación & Pila)       (Conmutadores)   |
+---------------------------------------------------------------------+
                                  |
                                  v
+---------------------------------------------------------------------+
|                      2. DOMAIN LAYER (Dart Puro)                    |
|                                                                     |
|  * Modelos:     AACBoard, AACButton, MessageToken, PartOfSpeech     |
|  * Gramática:   SpanishGrammarEngine (Conjugaciones & Flexión)      |
|  * Pathfinder:  PathfinderService (Guía visual de rutas A*)         |
|  * Contratos:   IBoardRepository, ITTSRepository                    |
+---------------------------------------------------------------------+
                                  |
                                  v
+---------------------------------------------------------------------+
|                     3. DATA & HARDWARE LAYER                        |
|                                                                     |
|  * Base de Datos:  Drift / SQLite FTS5 (Vocabulario Indexado)       |
|  * Gráficos:       Caché de Vectores ARASAAC (.vg en GPU)           |
|  * Audio & Voz:    TTSService (Android Native + Piper Neural)       |
|  * Ecosistema:     Parser Open Board Format (OBF / OBZ)             |
|  * Hardware:       Driver Bluetooth HID (Pulsadores / Switches)     |
+---------------------------------------------------------------------+
=======================================================================
