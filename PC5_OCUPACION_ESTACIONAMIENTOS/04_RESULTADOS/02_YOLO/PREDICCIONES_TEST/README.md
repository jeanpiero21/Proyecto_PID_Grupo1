# Predicciones del split test

Aquí se generan los archivos `<nombre_imagen>.txt` mediante
`scripts_auxiliares/exportar_predicciones_yolo.py`. Cada fila contiene:

```text
clase x_centro y_centro ancho alto confianza
```

Las coordenadas están normalizadas. Los TXT no se incluyen porque requieren
ejecutar inferencia sobre el dataset completo, que fue excluido de la entrega.
