# Guía de resultados

Esta carpeta reúne las salidas numéricas del enfoque clásico, YOLOv8 y su
comparación directa. Los resultados visuales por imagen se encuentran en
`../03_IMAGENES_REFERENCIALES/03_FINALES`.

## 01_MATLAB_CLASICO

### GRAFICAS

- `histograma_error_ocupacion.png`: distribución del error de ocupación en
  puntos porcentuales para el método clásico.
- `matriz_confusion.png`: cantidades globales de verdaderos positivos,
  falsos positivos, falsos negativos y verdaderos negativos.
- `ocupacion_real_vs_estimada.png`: ocupación real frente a la estimada; cuanto
  más cerca estén los puntos de la diagonal, menor es el error.
- `T1_comparacion_tecnicas.png`: comparación de las variantes clásicas
  evaluadas en precisión, recall y F1.
- `T2_tipos_umbral.png`: efecto del tipo y nivel de umbral sobre el F1 y el
  error de ocupación.
- `T4_robustez_camara_hora.png`: variación del rendimiento según cámara y rango
  horario.

### METRICAS

- `metricas_por_imagen.csv`: resultado del método clásico principal para cada
  imagen, incluyendo TP, FP, FN, TN, precisión (`P`), recall (`R`), F1 y
  porcentajes de ocupación real y predicha.
- `metricas_por_imagen_y_tecnica.csv`: las mismas métricas separadas por cada
  técnica clásica probada.
- `T1_tecnicas.csv`: resumen global de las técnicas, con métricas de
  clasificación y error de estimación de ocupación.
- `T2_tipos_umbral.csv`: comparación entre umbral global, por cámara y por
  cajón, tanto automático como calibrado.
- `T4a_por_camara.csv`: F1 y error absoluto medio de ocupación para cada cámara.
- `T4b_por_hora.csv`: F1 y error absoluto medio según el rango horario.
- `T5_deteccion_cajones.csv`: evaluación del intento de localizar
  automáticamente los cajones mediante componentes conexas.

## 02_YOLO

- `ENTRENAMIENTO/METRICAS/historial_epocas.csv`: historial completo de las 50
  épocas de entrenamiento.
- `ENTRENAMIENTO/GRAFICAS/`: curvas de precisión, recall, F1, pérdidas, tasa de
  aprendizaje y matriz de confusión de YOLOv8s.
- `METRICAS/metricas_validacion_yolo.csv`: métricas de detección obtenidas en
  la validación del entrenamiento: precisión, recall, mAP50 y mAP50-95.
- `METRICAS/metricas_12_casos_yolo.csv`: métricas homogéneas de YOLO sobre las
  mismas 12 imágenes usadas para la comparación con MATLAB.
- `PREDICCIONES_TEST/`: ubicación donde se generan los TXT de inferencia del
  conjunto de prueba completo; su README explica el formato de cada fila.
- `README.md`: procedencia, alcance y protocolo de evaluación de los resultados
  de YOLO.

## 03_COMPARACION

- `comparacion_matlab_vs_yolo.csv`: comparación uno a uno sobre las mismas 12
  imágenes. Presenta precisión, recall, F1, ocupación estimada y error en
  puntos porcentuales para ambos métodos.
- `README.md`: explica el criterio de coincidencia, la clase positiva y dónde
  se encuentran las comparaciones visuales.

## Abreviaturas

- `TP`: verdadero positivo, cajón ocupado identificado como ocupado.
- `FP`: falso positivo, cajón libre identificado como ocupado.
- `FN`: falso negativo, cajón ocupado identificado como libre o no detectado.
- `TN`: verdadero negativo, cajón libre identificado como libre.
- `P` o precisión: proporción de predicciones de ocupado que fueron correctas.
- `R` o recall: proporción de cajones realmente ocupados que fueron detectados.
- `F1`: equilibrio entre precisión y recall.
- `MAE_pp`: error absoluto medio expresado en puntos porcentuales.

