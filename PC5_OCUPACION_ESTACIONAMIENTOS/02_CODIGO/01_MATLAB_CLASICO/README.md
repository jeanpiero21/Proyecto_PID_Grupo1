# Método clásico en MATLAB

Para una explicación sencilla, archivo por archivo y función por función, consulte [`GUIA_CODIGO_MATLAB.md`](GUIA_CODIGO_MATLAB.md).

## Requisitos

- MATLAB R2020b o posterior (declarado por el código original).
- Image Processing Toolbox.
- Dataset con splits `valid` y `test`, imágenes en `images/` y etiquetas YOLO en `labels/`.

## Entradas y rutas

`config.m` calcula rutas desde la ubicación del propio archivo. En el proyecto original el dataset estaba dos niveles por encima, en `pid_2_pklot`. En esta entrega no se incluye el dataset completo; por ello debe cambiarse únicamente esta línea antes de ejecutar:

```matlab
cfg.rutaDataset = 'RUTA_LOCAL_AL_DATASET';
```

No se modificó el valor original para preservar el código y sus resultados. Las salidas se generan de forma relativa en `resultados/`.

## Scripts

- `main.m`: entrada principal; calibra en `valid`, evalúa `test`, genera CSV, gráficas e imágenes intermedias.
- `demo_una_imagen.m`: demostración sobre una imagen.
- `comparar_preprocesamiento.m`: compara variantes de preprocesamiento.
- `config.m`: rutas y parámetros del experimento.
- `a.m`: script auxiliar original; se conserva sin reinterpretarlo.
- `funciones/`: 42 funciones auxiliares del pipeline.

El pipeline incluye filtrado gaussiano, histogramas, Otsu, morfología, watershed, Sobel/Canny, HOG propio, calibración por cámara y métricas de clasificación/ocupación.

## Ejecución

```matlab
cd('RUTA/02_CODIGO/01_MATLAB_CLASICO')
main
```

Para evitar recalibrar, `cfg.recalibrar` está en `false` y se conservan los archivos `.mat` disponibles. La compatibilidad de esos archivos depende de que el dataset y la versión esperada coincidan.

## Salidas conservadas

- Intermedias: `03_IMAGENES_REFERENCIALES/02_INTERMEDIAS/MATLAB`.
- Finales: `03_IMAGENES_REFERENCIALES/03_FINALES/MATLAB`.
- Tablas: `04_RESULTADOS/METRICAS`.
- Gráficas: `04_RESULTADOS/GRAFICAS`.

No se volvió a ejecutar el pipeline ni se alteraron algoritmos o métricas.
