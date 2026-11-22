# Resultados YOLOv8s

`METRICAS/metricas_validacion_yolo.csv` transcribe la validación final guardada
en la salida de `pid_2.ipynb`. Corresponde al mejor peso luego de 50 épocas:
1 618 imágenes y 92 808 instancias de validación.

Estas son métricas de **detección de objetos**. No deben confundirse con las
métricas por cajón fijo y el error porcentual de ocupación del método clásico.

`PREDICCIONES_TEST` es la salida reproducible de
`exportar_predicciones_yolo.py`. Se deja sin archivos porque el dataset completo
no forma parte de la entrega. Al generarlos, `main.m` activa automáticamente T6.
