# Comparación homogénea MATLAB–YOLO

Esta carpeta está reservada para `T6_clasico_vs_yolo.csv`, generado por
`main.m` cuando existen predicciones para el mismo split `test` en
`../02_YOLO/PREDICCIONES_TEST`.

No se construye una tabla mezclando el mAP de YOLO con la exactitud de MATLAB,
porque miden tareas distintas. T6 usa las mismas imágenes, emparejamiento de
cajas y métricas de clasificación/ocupación compatibles.
