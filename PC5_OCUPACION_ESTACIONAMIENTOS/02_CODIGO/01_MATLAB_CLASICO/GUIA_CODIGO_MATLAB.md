# Guía sencilla del código MATLAB

Esta guía explica qué hace cada parte del método clásico. La idea general es comparar cada cajón de la imagen con ejemplos del mismo cajón cuando estaba vacío. Si la diferencia supera un umbral, el cajón se marca como ocupado.

## 1. Flujo general

```text
Imagen + etiquetas de calibración
          ↓
Calibrar cámaras, cajones, referencias vacías y umbrales
          ↓
Preprocesar cada imagen de prueba
          ↓
Identificar la cámara y recortar cada cajón
          ↓
Calcular HOG, bordes, color, textura y diferencias
          ↓
Aplicar un umbral: libre u ocupado
          ↓
Calcular métricas, tablas, gráficas e imágenes finales
```

El método principal es **HOG contra referencias del cajón vacío**, con un umbral calibrado para cada cajón. Las demás técnicas se ejecutan sobre los mismos datos para comparar su comportamiento.

## 2. Archivos principales

### `main.m`

Es el punto de entrada del experimento completo.

1. **Prepara las carpetas de salida.** Crea `tablas`, `figuras`, `imagenes_intermedias` y `deteccion_auto_cajones`.
2. **Carga o genera la calibración.** Si `calibracion.mat` es compatible, lo reutiliza; en caso contrario llama a `calibrarSistema`.
3. **Evalúa el split de prueba.** `evaluarSplit` procesa todas las imágenes una sola vez y almacena los indicadores.
4. **T1 — Compara técnicas.** Evalúa HOG, NCC-Sobel, gradientes, resta, bordes, color y voto combinado.
5. **T2 — Compara umbrales.** Prueba umbrales globales, por cámara y por cajón; cada uno puede ser Otsu o calibrado.
6. **T4 — Mide robustez.** Separa resultados por cámara y franja horaria.
7. **Genera gráficas.** Matriz de confusión, ocupación real contra estimada e histograma del error.
8. **Guarda etapas intermedias.** Selecciona una imagen representativa de cada cámara.
9. **T5 — Detecta cajones automáticamente.** Compara componentes conexos y watershed sin usar etiquetas para detectar.
10. **Comparación opcional con YOLO.** Solo se ejecuta si existen predicciones exportadas.
11. **Genera una demostración final.** Analiza la misma escena usada por el script Python.

### `config.m`

Centraliza los parámetros para no dispersarlos por las funciones.

- `rutaDataset`: ubicación de `train`, `valid` y `test`.
- `rutaSalida`: lugar donde se guardan resultados.
- `splitCalib` / `splitEval`: datos usados para calibrar y evaluar.
- `preproc`: filtro previo (`gauss`, `ninguno`, `mediana` o `histeq`).
- `factorROI`: fracción central analizada de cada cajón.
- `tamParche` / `tamHOG`: tamaños normalizados para comparar cajones.
- `K`: cantidad de referencias vacías según iluminación.
- `auto.*`: parámetros de Otsu, apertura y watershed.
- `rutaPredYOLO`: predicciones usadas en la comparación opcional.
- `imagenesExcluir`: casos identificados como mal etiquetados.

Si cambia el preprocesamiento o un parámetro del cajón, se debe recalibrar.

### `comparar_preprocesamiento.m`

Genera la tabla T3. Ejecuta el mismo experimento con cuatro entradas:

1. Sin filtro.
2. Filtro gaussiano.
3. Filtro de mediana.
4. Ecualización de histograma.

Cada opción vuelve a calibrarse para que la comparación sea justa. Por eso tarda aproximadamente cuatro veces más que una calibración normal.

### `demo_una_imagen.m`

Sirve para la exposición:

1. Carga `calibracion.mat`.
2. Permite elegir una imagen.
3. Ejecuta `analizarImagen`.
4. Dibuja los cajones libres y ocupados.
5. Si existe una etiqueta, muestra también los aciertos y errores.

## 3. Calibración y organización de datos

### `listarSplit.m`

Busca las imágenes y etiquetas de un split. Devuelve por caso la ruta de la imagen, la ruta de la etiqueta y un nombre común.

### `leerEtiquetas.m`

Lee una anotación YOLO `clase xc yc w h`. Convierte las coordenadas normalizadas a cajas `[x y ancho alto]` en píxeles. La clase 0 significa libre y la 1, ocupado.

### `camaraDesdeEtiquetas.m`

Compara la distribución de cajones de una etiqueta con los mapas conocidos. Se usa durante la calibración para agrupar imágenes que pertenecen a la misma cámara.

### `emparejarConMapa.m`

Relaciona cada caja de una etiqueta con el cajón correspondiente del mapa fijo. Usa la distancia entre centros porque el orden de las filas en los `.txt` puede cambiar.

### `referenciasPorBrillo.m`

Construye `K` ejemplos de un cajón vacío:

1. Ordena los parches por brillo.
2. Los divide en niveles de iluminación.
3. Calcula la mediana de cada grupo.

Así se tienen referencias para mañana, tarde, sombra u otras condiciones de luz.

### `umbralCalibrado.m`

Prueba posibles límites para la regla `indicador > umbral`. Conserva el valor que produce mayor exactitud en los datos etiquetados de calibración.

### `umbralOtsu.m`

Calcula un umbral sin mirar las etiquetas. Normaliza los valores, aplica Otsu sobre su histograma y devuelve el resultado a la escala original.

### `calibrarSistema.m`

Coordina toda la calibración:

1. Agrupa imágenes por cámara.
2. Define el mapa fijo de cajones.
3. Construye una plantilla visual de cada cámara.
4. Obtiene referencias vacías para cada cajón.
5. Calcula indicadores sobre las imágenes de calibración.
6. Obtiene umbrales globales, por cámara y por cajón.
7. Guarda métodos, referencias y umbrales dentro de `calib`.

## 4. Procesamiento de una imagen

### `preprocesar.m`

Genera las representaciones base:

- Imagen en gris.
- Imagen suavizada según `cfg.preproc`.
- Magnitud del gradiente Sobel.
- Bordes Canny.
- Gradiente morfológico.
- Top-hat y bottom-hat.

Estas salidas se reutilizan; no se recalculan para cada técnica.

### `identificarCamara.m`

Reduce la imagen y la compara con la plantilla de cada cámara usando correlación 2D. Selecciona la cámara con mayor parecido.

### `recorteROI.m`

Obtiene la zona central de una caja. Evita bordes y cajones vecinos, especialmente donde la perspectiva hace que las cajas se superpongan.

### `indicadoresCajones.m`

Para cada cajón obtiene:

- Parche gris normalizado.
- Parche de magnitud Sobel.
- Vector HOG.
- Histograma de intensidad.
- Saturación media.
- Densidad Canny.
- Gradiente medio y desviación estándar.
- Respuestas morfológicas.

### `valoresIndicadores.m`

Convierte los descriptores anteriores en valores comparables con un cajón vacío. Un valor pequeño significa “parecido al vacío”; uno grande indica cambio y posible vehículo.

### `decidirOcupacion.m`

Selecciona el umbral solicitado y aplica la regla:

```text
indicador > umbral  → ocupado
indicador ≤ umbral  → libre
```

El umbral puede ser global, de la cámara o del cajón.

### `analizarImagen.m`

Une todas las etapas para una sola imagen:

1. Preprocesa.
2. Identifica la cámara.
3. Extrae indicadores por cajón.
4. Calcula sus diferencias frente al vacío.
5. Aplica el método principal.
6. Cuenta ocupados y calcula el porcentaje.

Devuelve una estructura `R` con las etapas y el resultado final.

## 5. Descriptores y medidas de diferencia

### `hogPropio.m`

Implementa HOG paso a paso:

1. Calcula gradientes Sobel horizontal y vertical.
2. Obtiene magnitud y orientación entre 0° y 180°.
3. Divide el parche en celdas de 8×8.
4. Forma nueve grupos de orientación por celda.
5. Normaliza los histogramas para reducir el efecto de iluminación.

### `distanciaHOG.m`

Calcula `1 - similitud coseno` entre el HOG actual y las referencias vacías. Cerca de 0 significa libre; un valor alto indica una estructura diferente, normalmente un auto.

### `distanciaNCC.m`

Calcula `1 - correlación normalizada`. Es útil porque tolera cambios globales de brillo y contraste.

### `distanciaResta.m`

Compara píxel a píxel con una referencia vacía:

1. Compensa el brillo medio.
2. Resta ambos parches.
3. Aplica un umbral de Otsu.
4. Usa apertura morfológica para quitar ruido.
5. Devuelve la proporción de píxeles cambiados.

### `distanciaHist.m`

Compara histogramas de intensidad mediante su intersección. Devuelve 0 cuando los histogramas son muy parecidos.

### `distanciaSat.m`

Mide la diferencia entre la saturación media del cajón actual y la de sus referencias vacías.

### `listaMetodos.m`

Declara las técnicas incluidas en T1 y su procedencia en el curso. La primera entrada es el método principal. También define qué indicadores forman el voto por mayoría.

### `aplicarRegla.m`

Aplica una pareja `indicador + tipo de umbral` a todos los cajones ya evaluados. Si el método es `voto`, combina varias decisiones y elige la mayoría.

## 6. Evaluación y métricas

### `evaluarSplit.m`

Procesa todas las imágenes de prueba y crea la estructura `E`:

- `E.y`: estado real de cada cajón.
- `E.cam`: cámara correspondiente.
- `E.spot`: identificador del cajón.
- `E.img`: imagen de origen.
- `E.V.*`: valores de todos los indicadores.

Al guardar los indicadores una sola vez, las comparativas posteriores son rápidas y usan exactamente los mismos datos.

### `metricasClasificacion.m`

Calcula métricas por cajón, considerando “ocupado” como positivo:

- Exactitud: proporción total de aciertos.
- Precisión: de lo marcado ocupado, cuánto estaba ocupado.
- Recall: de lo realmente ocupado, cuánto se detectó.
- Especificidad: capacidad para reconocer libres.
- F1: equilibrio entre precisión y recall.
- Kappa y MCC: acuerdo más robusto ante clases desbalanceadas.

### `metricasOcupacion.m`

Compara el porcentaje real y estimado por imagen:

- MAE y RMSE en puntos porcentuales.
- Sesgo: indica si se sobreestima o subestima.
- Error máximo.
- Casos dentro de 5 y 10 puntos porcentuales.
- Correlación de Pearson.

### `metricasRegla.m`

Agrupa las métricas por cajón y por imagen para una regla concreta. También permite evaluar solo una cámara o una franja horaria.

### `filaMetricas.m`

Convierte las métricas en una fila con orden fijo. Esto permite que todas las técnicas, incluida YOLO, aparezcan con las mismas columnas.

### `iouCajas.m`

Calcula la intersección sobre unión entre cada caja predicha y cada caja real. Un valor de 1 significa coincidencia perfecta y 0, ninguna superposición.

### `metricasDeteccion.m`

Empareja cajas predichas y reales uno a uno usando IoU. Luego calcula verdaderos positivos, falsos positivos, falsos negativos, precisión, recall y F1.

### `metricasDeteccionCentro.m`

Considera correcta una detección si su centro cae dentro de la zona central de un cajón real. Es más tolerante que IoU cuando la perspectiva deforma las cajas.

### `leerPredicciones.m`

Lee archivos exportados por YOLO con el formato `clase xc yc w h confianza` y los convierte a coordenadas en píxeles.

### `evaluarYOLO.m`

Evalúa YOLO con criterios compatibles con MATLAB:

1. Lee las predicciones de cada imagen.
2. Empareja cajas por IoU.
3. Evalúa detección y clase libre/ocupado.
4. Calcula porcentaje de ocupación por imagen.
5. Devuelve métricas con el mismo formato de las técnicas clásicas.

Esta comparación es opcional y requiere predicciones exportadas. El mAP de YOLO no se confunde con la exactitud de ocupación por cajón.

## 7. Detección automática de cajones

### `mascaraZonaInteres.m`

Crea una máscara alrededor del conjunto de cajones. Limita el análisis al área útil del estacionamiento.

### `detectarCajonesAuto.m`

Busca cajones sin usar sus etiquetas durante la detección:

1. Calcula el fondo mediano de muchas imágenes.
2. Mide qué píxeles cambian con frecuencia.
3. Suaviza el mapa de actividad.
4. Aplica Otsu dentro de la zona de interés.
5. Compara componentes conexos sin apertura, con apertura y con watershed.
6. Watershed intenta separar regiones vecinas que quedaron unidas.

### `lineasPintadas.m`

Busca líneas blancas del estacionamiento mediante top-hat, Otsu, limpieza morfológica y transformada de Hough. Se usa como evidencia exploratoria, no como clasificador principal.

## 8. Visualización y archivos de salida

### `dibujarCajones.m`

Dibuja cada cajón: verde para libre, rojo para ocupado y amarillo cuando no hay estado asignado.

### `guardarIntermedias.m`

Guarda original, gris suavizado, Sobel, Canny, gradiente morfológico, top-hat/bottom-hat, mapa de cajones, indicador HOG, comparación de parches y resultado final.

### `guardarDeteccionAuto.m`

Guarda las etapas de detección automática y una comparación visual entre variantes.

### `graficarConfusion.m`

Construye una matriz de confusión 2×2 sin depender de una función externa de visualización.

### `graficarResumenMetricas.m`

Genera un resumen para presentación: exactitud, recall, error del porcentaje y gráfica de ocupación real frente a estimada.

### `guardarFigura.m`

Exporta una figura como PNG y la cierra para liberar memoria.

## 9. Qué compara cada tabla

| Tabla | Pregunta que responde |
|---|---|
| T1 | ¿Qué descriptor o técnica clasifica mejor libre/ocupado? |
| T2 | ¿Conviene un umbral global, por cámara o por cajón? ¿Otsu o calibrado? |
| T3 | ¿Qué preprocesamiento funciona mejor? |
| T4 | ¿El resultado cambia según la cámara o la hora? |
| T5 | ¿Qué variante localiza mejor los cajones sin etiquetas? |
| T6, opcional | ¿Cómo se compara YOLO con el método clásico usando métricas compatibles? |

Las comparativas no son modelos independientes completos: reutilizan el mismo conjunto de imágenes y los mismos indicadores almacenados para aislar el efecto de la técnica o el umbral que se está estudiando.

## 10. Orden recomendado para estudiar el código

1. `config.m`
2. `main.m`
3. `calibrarSistema.m`
4. `preprocesar.m`
5. `indicadoresCajones.m`
6. `valoresIndicadores.m`
7. `decidirOcupacion.m`
8. `evaluarSplit.m`
9. `metricasRegla.m`
10. Funciones de distancia, métricas y visualización según sea necesario.

Este orden permite entender primero el flujo y después los detalles matemáticos.
