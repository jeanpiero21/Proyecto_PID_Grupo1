# Resultados YOLOv8s

`METRICAS/metricas_validacion_yolo.csv` transcribe la validación final guardada
en la salida de `entrenamiento_evaluacion_yolov8.ipynb`. Corresponde al mejor peso luego de 50 épocas:
1 618 imágenes y 92 808 instancias de validación.

Estas son métricas de **detección de objetos**. No deben confundirse con las
métricas por cajón fijo y el error porcentual de ocupación del método clásico.

`PREDICCIONES_TEST` es la salida reproducible de
`scripts_auxiliares/exportar_predicciones_yolo.py`. Se deja sin archivos porque el dataset completo
no forma parte de la entrega. Al generarlos, `main.m` activa automáticamente T6.

`METRICAS/metricas_12_casos_yolo.csv` contiene la evaluación reproducible sobre
las 12 imágenes del entregable. En sus columnas principales, la clase positiva
es `space-occupied`; las columnas terminadas en `_deteccion_global` conservan la
evaluación conjunta de ambas clases.

Las 12 imágenes finales están en
`03_IMAGENES_REFERENCIALES/03_FINALES/YOLO` y fueron generadas por
`scripts_auxiliares/generar_comparativas.py` sin volver a entrenar el modelo.
