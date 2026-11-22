# Método YOLOv8s en Python

## Archivos principales

- `entrenamiento_evaluacion_yolov8.ipynb`: notebook principal, con celdas, metadatos y salidas preservados.
- `entrenamiento_evaluacion_yolov8.html`: exportación para revisión visual; no es un notebook ejecutable.
- `scripts_auxiliares/probar.py`: demostración local sobre una imagen.
- `scripts_auxiliares/exportar_predicciones_yolo.py`: exporta todo `test/images` al formato que consume T6 en MATLAB.
- `scripts_auxiliares/generar_comparativas.py`: genera resultados YOLO y comparativas MATLAB--YOLO para las 12 imágenes del entregable.
- `pesos/best.pt`: pesos entrenados (aprox. 22.5 MB).
- `configuracion_dataset/data.yaml`: definición original del dataset.
- `configuracion_dataset/`: información original de Roboflow y del dataset.
- `requirements.txt`: dependencias directas verificadas en el notebook/script.

## Entorno

El notebook registró una ejecución en Google Colab con Python 3.13, `ultralytics 8.4.215` y `roboflow 1.7.3`. El archivo de requisitos usa mínimos o paquetes sin fijar cuando una versión exacta no es necesaria para no inventar compatibilidades.

```powershell
python -m venv .venv
.\.venv\Scripts\Activate.ps1
python -m pip install -r requirements.txt
```

## Inferencia

`scripts_auxiliares/probar.py` usa rutas relativas a la entrega y toma una imagen de `05_DATOS_PRUEBA`. El notebook conserva rutas `/content/...` propias de Colab.

No se debe ejecutar el entrenamiento para revisar la entrega. El HTML permite comprobar el proceso ya realizado y `resultado_ocupacion_pklot.jpg` conserva una salida real.

## Exportación para la comparación T6

Con el dataset completo disponible:

```powershell
python scripts_auxiliares/exportar_predicciones_yolo.py --imagenes "RUTA_AL_DATASET/test/images"
```

Los TXT se guardan por defecto en
`04_RESULTADOS/02_YOLO/PREDICCIONES_TEST`. Después, `main.m` puede calcular una
comparación homogénea sobre las mismas imágenes. Las métricas originales de
validación del entrenamiento están separadas en
`04_RESULTADOS/02_YOLO/METRICAS`.

## Dataset y credencial

El dataset se descargó mediante Roboflow y usa anotaciones YOLO. El notebook original contenía una clave de API escrita en una celda. La copia incluida conserva sus celdas, metadatos y salidas, pero la credencial fue reemplazada por `ROBOFLOW_API_KEY_REDACTED` para permitir su publicación segura. Use una credencial propia mediante un secreto o variable de entorno para descargar nuevamente el dataset.

`configuracion_dataset/data.yaml` conserva rutas relativas a `../train`, `../valid` y `../test`; el dataset completo no forma parte de esta entrega.
