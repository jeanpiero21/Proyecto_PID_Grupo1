# Resultados del entrenamiento de YOLOv8s

Esta carpeta conserva el historial completo de las 50 épocas y las gráficas
finales entregadas por el equipo.

## METRICAS

- `historial_epocas.csv`: valores por época de las pérdidas de entrenamiento y
  validación, precisión, recall, mAP50, mAP50-95 y tasa de aprendizaje.

## GRAFICAS

- `matriz_confusion_yolo.png`: distribución de aciertos y confusiones entre
  las clases `space-empty` y `space-occupied`.
- `curva_precision_recall.png`: relación entre precisión y recall.
- `curva_f1_confianza.png`: F1 obtenido para cada umbral de confianza.
- `curva_precision_confianza.png`: precisión según el umbral de confianza.
- `curva_recall_confianza.png`: recall según el umbral de confianza.
- `evolucion_perdidas_entrenamiento.png`: evolución de las pérdidas durante las
  50 épocas.
- `metricas_validacion_por_epoca.png`: evolución de precisión, recall y mAP.
- `metricas_validacion_por_epoca.svg`: versión vectorial de las métricas.
- `perdidas_por_epoca.svg`: versión vectorial de las pérdidas.
- `tasa_aprendizaje_por_epoca.svg`: evolución de la tasa de aprendizaje.

Los PNG son adecuados para revisión directa y para insertarlos en documentos.
Los SVG conservan calidad vectorial para edición o exportación.
