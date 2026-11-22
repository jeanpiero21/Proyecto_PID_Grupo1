# Muestra de datos de prueba

Esta carpeta contiene 12 casos seleccionados del dataset PKLot. Cada caso está
formado por una imagen JPG y una anotación TXT con exactamente el mismo nombre
base. La selección incluye diferentes horas y niveles de ocupación para poder
comparar MATLAB y YOLO sobre entradas variadas.

## Contenido de las carpetas

- `imagenes/`: fotografías RGB del estacionamiento usadas como entrada por los
  dos métodos.
- `anotaciones/`: datos reales de referencia en formato YOLO. Cada TXT indica
  la clase y la caja delimitadora de los 40 cajones visibles en su imagen.

El nombre comienza con `AAAA-MM-DD_HH_MM_SS`, que indica la fecha y hora de
captura. La parte `_jpg.rf.<identificador>` fue añadida por Roboflow y permite
vincular de manera única cada imagen con su anotación.

## Qué contiene cada par de archivos

| Captura | Archivo JPG | Archivo TXT | Libres | Ocupados |
|---|---|---|---:|---:|
| 23/02/2013 18:10:12 | Imagen del estacionamiento | 40 cajas reales | 38 | 2 |
| 03/03/2013 17:30:13 | Imagen del estacionamiento | 40 cajas reales | 40 | 0 |
| 12/03/2013 06:40:00 | Imagen del estacionamiento | 40 cajas reales | 40 | 0 |
| 09/04/2013 07:45:02 | Imagen del estacionamiento | 40 cajas reales | 28 | 12 |
| 10/04/2013 10:45:05 | Imagen del estacionamiento | 40 cajas reales | 0 | 40 |
| 11/04/2013 07:50:02 | Imagen del estacionamiento | 40 cajas reales | 28 | 12 |
| 11/04/2013 17:00:12 | Imagen del estacionamiento | 40 cajas reales | 6 | 34 |
| 12/04/2013 06:50:00 | Imagen del estacionamiento | 40 cajas reales | 39 | 1 |
| 12/04/2013 08:35:02 | Imagen del estacionamiento | 40 cajas reales | 24 | 16 |
| 12/04/2013 17:15:12 | Imagen del estacionamiento | 40 cajas reales | 18 | 22 |
| 13/04/2013 06:45:01 | Imagen del estacionamiento | 40 cajas reales | 40 | 0 |
| 13/04/2013 17:20:12 | Imagen del estacionamiento | 40 cajas reales | 33 | 7 |

Las columnas `Libres` y `Ocupados` se obtienen directamente de las clases
guardadas en cada TXT, no de una predicción del modelo.

## Formato de anotación

Cada línea sigue el formato:

```text
clase x_centro y_centro ancho alto
```

Una línea representa un cajón:

- `clase`: `0` para `space-empty` (libre) y `1` para `space-occupied`
  (ocupado).
- `x_centro`, `y_centro`: posición del centro de la caja.
- `ancho`, `alto`: tamaño de la caja.

Las cuatro coordenadas están normalizadas entre 0 y 1 respecto al ancho y alto
de la imagen. Los nombres oficiales de las clases también están declarados en
`../02_CODIGO/02_PYTHON_YOLO/configuracion_dataset/data.yaml`.

## Uso dentro del proyecto

- `../02_CODIGO/02_PYTHON_YOLO/scripts_auxiliares/generar_comparativas.py`
  procesa estos 12 pares para generar las detecciones YOLO y la comparación
  visual con MATLAB.
- El enfoque clásico emplea las mismas imágenes y convierte las cajas reales en
  regiones fijas para evaluar la ocupación.
- Los valores numéricos resultantes se guardan en `../04_RESULTADOS`.

Las anotaciones fueron localizadas en los splits originales `train`, `valid` o
`test`. Esta muestra sirve para inspección, demostración y trazabilidad; no
reemplaza los splits completos necesarios para reproducir todas las métricas.

## Dataset completo

El material original identifica el dataset como una exportación de PKLot vía
Roboflow. No se incluyeron `train/valid/test` completos para evitar duplicar
miles de imágenes. Para reproducir la evaluación completa, se debe descargar
la misma versión del dataset y respetar su licencia y términos de
redistribución.
