# Resultados del enfoque clásico en MATLAB

`GRAFICAS` contiene las representaciones visuales de las pruebas T1, T2 y T4,
además de la matriz de confusión y los errores de ocupación del método final.

`METRICAS` contiene los valores numéricos que respaldan esas gráficas. Los
archivos que comienzan con `T` corresponden a una prueba comparativa concreta:

- `T1`: selección de la técnica clásica.
- `T2`: selección del tipo y nivel de umbral.
- `T4`: análisis de robustez por cámara y hora.
- `T5`: prueba de detección automática de cajones.

Los archivos `metricas_por_imagen.csv` y
`metricas_por_imagen_y_tecnica.csv` permiten revisar los casos individuales y
no solamente los promedios globales. La descripción exacta de cada archivo se
encuentra en `../README.md`.

