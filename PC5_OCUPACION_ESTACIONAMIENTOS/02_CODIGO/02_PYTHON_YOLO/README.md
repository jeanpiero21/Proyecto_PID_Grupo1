# Método YOLOv8s en Python

## Archivos principales

- `pid_2.ipynb`: notebook original, con celdas, metadatos y salidas preservados.
- `pid_2.html`: exportación para revisión visual; no es un notebook ejecutable.
- `probar.py`: inferencia local original.
- `exportar_predicciones_yolo.py`: exporta todo `test/images` al formato que consume T6 en MATLAB.
- `pesos/best.pt`: pesos entrenados (aprox. 22.5 MB).
- `data.yaml`: definición original del dataset.
- `requirements.txt`: dependencias directas verificadas en el notebook/script.

## Entorno

El notebook registró una ejecución en Google Colab con Python 3.13, `ultralytics 8.4.215` y `roboflow 1.7.3`. El archivo de requisitos usa mínimos o paquetes sin fijar cuando una versión exacta no es necesaria para no inventar compatibilidades.

```powershell
python -m venv .venv
.\.venv\Scripts\Activate.ps1
python -m pip install -r requirements.txt
```

## Inferencia

`probar.py` contiene rutas del equipo original. Antes de ejecutarlo, configure la ruta de la imagen y confirme que el modelo apunta a `pesos/best.pt`. El notebook usa rutas `/content/...` propias de Colab.

No se debe ejecutar el entrenamiento para revisar la entrega. El HTML permite comprobar el proceso ya realizado y `resultado_ocupacion_pklot.jpg` conserva una salida real.

## Exportación para la comparación T6

Con el dataset completo disponible:

```powershell
python exportar_predicciones_yolo.py --imagenes "RUTA_AL_DATASET/test/images"
```

Los TXT se guardan por defecto en
`04_RESULTADOS/02_YOLO/PREDICCIONES_TEST`. Después, `main.m` puede calcular una
comparación homogénea sobre las mismas imágenes. Las métricas originales de
validación del entrenamiento están separadas en
`04_RESULTADOS/02_YOLO/METRICAS`.

## Dataset y credencial

El dataset se descargó mediante Roboflow y usa anotaciones YOLO. El notebook original contenía una clave de API escrita en una celda. La copia incluida conserva sus celdas, metadatos y salidas, pero la credencial fue reemplazada por `ROBOFLOW_API_KEY_REDACTED` para permitir su publicación segura. Use una credencial propia mediante un secreto o variable de entorno para descargar nuevamente el dataset.

El `data.yaml` conserva rutas relativas a `../train`, `../valid` y `../test`; el dataset completo no forma parte de esta entrega.
