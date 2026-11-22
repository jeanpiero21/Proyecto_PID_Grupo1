# Resultados YOLOv8s

## Contenido

- `ENTRENAMIENTO/`: historial de 50 épocas, curvas, pérdidas y matriz de
  confusión del entrenamiento final.
- `METRICAS/metricas_validacion_yolo.csv`: resultado global de validación del
  entrenamiento.
- `METRICAS/metricas_12_casos_yolo.csv`: evaluación por imagen sobre los 12
  casos comunes con MATLAB.
- `PREDICCIONES_TEST/`: archivos de detección que puede consumir MATLAB para
  evaluar el conjunto de prueba completo.

`METRICAS/metricas_validacion_yolo.csv` resume la validación final guardada
en la salida de `main_entrenamiento_yolo.ipynb`. Corresponde al mejor peso luego de 50 épocas:
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

Las imágenes finales están separadas en:

- `03_IMAGENES_REFERENCIALES/03_FINALES/YOLO/DETECCIONES`: predicciones
  directas del modelo, con cajas, clases, confianza, ocupación y métricas.
- `03_IMAGENES_REFERENCIALES/03_FINALES/YOLO/EVALUACION`: contraste con la
  anotación real mediante verdaderos positivos, falsos positivos y falsos
  negativos.
- `03_IMAGENES_REFERENCIALES/03_FINALES/YOLO/DEMO`: demostración individual
  producida por `probar.py`.

Las primeras dos carpetas fueron generadas por
`scripts_auxiliares/generar_comparativas.py` sin volver a entrenar el modelo.
