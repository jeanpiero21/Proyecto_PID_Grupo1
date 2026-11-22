# Muestra de datos de prueba

Esta carpeta contiene 12 imágenes seleccionadas del conjunto usado por el proyecto y 12 anotaciones correspondientes en formato YOLO. Cada par comparte exactamente el mismo nombre base.

Las anotaciones fueron localizadas en los splits originales `train`, `valid` o `test`. Esta muestra sirve para inspección y trazabilidad; no reemplaza los splits completos necesarios para reproducir todas las métricas.

## Formato de anotación

Cada línea sigue el formato:

```text
clase x_centro y_centro ancho alto
```

Las coordenadas están normalizadas. Consulte `02_CODIGO/02_PYTHON_YOLO/configuracion_dataset/data.yaml` para los nombres de clase declarados por el dataset.

## Dataset completo

El material original identifica el dataset como una exportación de PKLot vía Roboflow. No se incluyeron `train/valid/test` completos para evitar duplicar miles de imágenes. Para reproducir la evaluación, descargue la misma versión del dataset y respete su licencia y términos de redistribución.
