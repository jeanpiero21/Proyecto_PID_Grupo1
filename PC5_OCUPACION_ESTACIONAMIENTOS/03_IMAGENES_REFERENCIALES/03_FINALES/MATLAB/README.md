# Salidas finales de MATLAB

Esta carpeta separa las salidas según su propósito:

- `ARCHIVOS_MAT`: datos internos guardados por MATLAB para reutilizar cálculos.
  `calibracion.mat` contiene mapas de cajones, referencias vacías y umbrales;
  `evaluacion.mat` contiene los indicadores calculados para el conjunto de
  evaluación. No son imágenes y se abren desde MATLAB.
- `DETECCION_AUTOMATICA_CAJONES`: evidencias exploratorias de la prueba T5,
  agrupadas por cámara. Incluyen fondo mediano, mapa de actividad, Otsu,
  apertura, watershed, comparación de variantes, top-hat y líneas de Hough.
- `DEMO`: resultado visual final del método clásico sobre una imagen, con los
  cajones clasificados como libres u ocupados.

Las imágenes intermedias del clasificador principal se conservan por separado
en `../../02_INTERMEDIAS/MATLAB`.
