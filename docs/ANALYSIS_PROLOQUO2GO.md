
---

### 2. `docs/ANALYSIS_PROLOQUO2GO.md`

```markdown
# 🔬 Análisis Profundo de Proloquo2Go y Fundamentos de CAA

Este documento detalla el análisis funcional, clínico y de ingeniería inversa de **Proloquo2Go** (AssistiveWare) para guiar el desarrollo de **MatataTalk**.

---

## 1. El Problema del Monopolio de iOS en CAA

Históricamente, las aplicaciones de CAA de grado clínico (*Proloquo2Go*, *TouchChat*, *LAMP Words for Life*) han sido exclusivas de iOS:
* **Costo de entrada:** Un iPad + Proloquo2Go supera los **$600–$800 USD**, dejando fuera a millones de familias en América Latina, España y países en desarrollo.
* **Fragilidad del ecosistema Android actual:** Las pocas alternativas disponibles en Android son aplicaciones abandonadas (*LetMeTalk*), herramientas en la nube con suscripción (*CoughDrop*) o PWAs web con soporte limitado de acceso motor (*Cboard*).

**MatataTalk** resuelve esta brecha creando una aplicación nativa, abierta y de alto rendimiento orientada a hardware accesible.

---

## 2. Desglose de Funcionalidades Clave de Proloquo2Go

### A. Vocabulario Crescendo™ y Planificación Motora
* **Estructura:** Cuadrículas escalables (desde 1x1 hasta 8x18 botones).
* **Regla de Oro:** La palabra "Quiero" siempre debe estar en la misma fila y columna, sin importar si el usuario usa una cuadrícula de 12, 36 o 60 botones. El espacio no utilizado se reserva como celda transparente para preservar la memoria motora.

### B. Sistema de Colores Fitzgerald Modificado
Facilita la estructuración sintáctica visual:
* 🟨 **Amarillo:** Personas y pronombres (*Yo, Tú, Mamá*).
* 🟩 **Verde:** Verbos y acciones (*Quiero, Comer, Ir*).
* 🟧 **Naranja:** Sustantivos y cosas (*Manzana, Pelota, Baño*).
* 🟦 **Azul:** Adjetivos y descriptores (*Grande, Rico, Feliz*).
* 🟪 **Rosa / Morado:** Expresiones sociales (*Hola, Por favor, Gracias*).
* ⬜ **Blanco / Gris:** Conectores, preposiciones y navegación.
* 🟥 **Rojo:** Vocabulario crítico de seguridad (*No, Parar, Ayuda*).

### C. Motor de Gramática y Morfología
En español, la riqueza flexiva exige que un botón verbal no solo hable en infinitivo:
* **Pulsación larga (*Long-Press*) o Tecla de Función:** Despliega una matriz emergente circular o cuadrangular con:
  * Presente (*como, comes, come...*)
  * Pasado pretérito (*comí, comiste...*)
  * Futuro (*comeré...*)
  * Subjuntivo y Formas no personales (*comiendo, comido*).
* **Sustantivos y Adjetivos:** Flexión automática de número (*árbol ➔ árboles*) y concordancia de género (*rápido / rápida*).

### D. Buscador Guiado (*Path Finder*)
En lugar de únicamente mostrar el resultado en una lista, el buscador ilumina paso a paso la ruta de carpetas para que el terapeuta o el usuario aprendan el camino motor (*Inicio ➔ Comida ➔ Frutas ➔ 🍎 Manzana*).

### E. Métodos de Acceso Alternativo
1. **Táctil Adaptado:**
   * *Hold Duration:* Tiempo mínimo de pulsación para evitar toques accidentales.
   * *Release to Activate:* Activa el botón al levantar el dedo (ideal para usuarios con distonía o espasticidad).
   * *Debounce:* Filtro de toques involuntarios repetidos.
2. **Barrido por Conmutadores (*Switch Scanning*):**
   * Barrido automático (1 switch) o paso a paso (2 switches).
   * Barrido fila-columna con retroalimentación auditiva previa.
3. **Seguimiento Facial y Ocular:**
   * Puntero controlado por cámara frontal con temporizador de permanencia (*Dwell Click*).
