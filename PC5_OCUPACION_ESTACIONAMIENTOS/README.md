# PC5 — Ocupación de estacionamientos con drones

Entrega del Grupo 1 para Procesamiento de Imágenes Digitales. El proyecto estudia la ocupación de estacionamientos del conjunto PKLot mediante dos enfoques: procesamiento clásico en MATLAB y detección con YOLOv8s en Python/Google Colab.

## Integrantes

- Barboza Santa Cruz, Jean Piero
- Fuentes Cosme, Fabiola Ashly
- Gutierrez Callahua, Jhosep Andres

## Contenido

| Carpeta | Contenido verificable |
|---|---|
| `01_DOCUMENTACION` | Presentación oficial disponible en PDF. |
| `02_CODIGO/01_MATLAB_CLASICO` | Scripts MATLAB, funciones auxiliares y guía de ejecución. |
| `02_CODIGO/02_PYTHON_YOLO` | Notebook original con salidas, HTML de revisión, script de inferencia y pesos. |
| `03_IMAGENES_REFERENCIALES` | Entradas reales, etapas intermedias MATLAB y resultados finales/comparativos. |
| `04_RESULTADOS` | Resultados separados en MATLAB, YOLO y comparación homogénea. |
| `05_DATOS_PRUEBA` | Muestra de 12 imágenes y sus 12 anotaciones YOLO. |
| `REPORTE_ORGANIZACION.md` | Inventario, verificaciones y pendientes de la rúbrica. |

## Ejecución rápida

### MATLAB clásico

Requiere MATLAB R2020b o posterior e Image Processing Toolbox. El equipo usado para organizar esta entrega dispone de MATLAB R2025b, pero no se ejecutó nuevamente la evaluación porque el dataset completo fue excluido de la entrega.

1. Obtenga PKLot/Roboflow con las carpetas `valid` y `test`.
2. Ubique el dataset según se explica en `02_CODIGO/01_MATLAB_CLASICO/README.md` o ajuste `cfg.rutaDataset` en `config.m`.
3. Abra MATLAB en `02_CODIGO/01_MATLAB_CLASICO`.
4. Ejecute `main.m`. Para una demostración individual use `demo_una_imagen.m`.

### Python + YOLO

1. Cree un entorno virtual e instale `pip install -r requirements.txt`.
2. Para revisar el entrenamiento ya realizado, abra `pid_2.ipynb` o `pid_2.html`.
3. Para inferencia local, adapte la ruta de entrada de `probar.py`; los pesos están en `pesos/best.pt`.
4. Para exportar el test y habilitar T6, ejecute `exportar_predicciones_yolo.py` indicando la carpeta `test/images`.
5. No es necesario reentrenar para evaluar esta entrega.

El notebook fue creado en Colab y contiene rutas `/content/...`. La clave de API de Roboflow hallada en el original fue redactada en la copia publicable; configure una credencial propia mediante un secreto o variable de entorno antes de descargar nuevamente el dataset.

## Datos y trazabilidad

La muestra reproducible contiene 12 pares imagen/anotación con el mismo nombre base. Los mosaicos comparativos y sus carpetas detalladas usan el identificador de fecha y hora de la imagen, lo cual permite rastrear cada caso sin inventar nombres `caso_XX`. El dataset completo y el entorno virtual fueron excluidos para evitar una entrega masiva.

## Resultados

Los resultados están separados para evitar mezclar métricas de tareas distintas:

- `04_RESULTADOS/01_MATLAB_CLASICO`: métricas y gráficas del procesamiento clásico.
- `04_RESULTADOS/02_YOLO`: métricas de detección transcritas de la validación final del notebook y carpeta de predicciones reproducibles.
- `04_RESULTADOS/03_COMPARACION`: T6, generado únicamente cuando ambos métodos se evalúan sobre las mismas imágenes.

El mAP de YOLO no se presenta como si fuera equivalente a la exactitud o al error porcentual de ocupación de MATLAB.

## Estado

La estructura, código, muestra de datos, pesos, HTML, notebook, presentación y evidencias visuales están organizados. El informe se mantiene exclusivamente en su repositorio versionado externo mientras está en desarrollo; cuando se termine, solo se incorporará el PDF definitivo como `01_DOCUMENTACION/Informe_Final.pdf`. También falta ensayar una exposición de 4–5 minutos por al menos dos integrantes. Consulte el reporte para el detalle completo.
