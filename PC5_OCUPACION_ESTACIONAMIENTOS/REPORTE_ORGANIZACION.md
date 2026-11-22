# Reporte de organización de la entrega PC5

Fecha de organización: 22 de noviembre de 2026.

## Inventario inicial

El repositorio contenía únicamente `rubrica.md` y `README_ESTRUCTURA_PC5.md`; Git no tenía commits. Mediante una búsqueda de solo lectura se localizaron los materiales reales en `Downloads`.

| Tipo | Localizado | Función probable |
|---|---:|---|
| MATLAB `.m` | 47 | Pipeline clásico y funciones auxiliares. |
| Notebook `.ipynb` | 1 | Entrenamiento/evaluación YOLO en Colab. |
| HTML | 1 | Evidencia visual del notebook. |
| Pesos `.pt` | 1 | Modelo YOLO entrenado. |
| PDF | 1 relevante | Presentación de la exposición. |
| LaTeX `.tex` | No incluido | El informe en desarrollo se mantiene en su repositorio Git externo. |
| Bibliografía `.bib` | No usada | El informe final contiene su bibliografía dentro de `main.tex`. |
| CSV | 8 verificables | Siete tablas MATLAB y una tabla YOLO transcrita de la validación final. |
| Imágenes | 12 entradas y más de 200 evidencias | Originales, etapas y resultados. |
| Anotaciones | 12 seleccionadas | Ground truth YOLO correspondiente a la muestra. |

## Copias realizadas

Se copiaron los materiales; no se borró ni modificó ningún original en `Downloads`.

- Código MATLAB → `02_CODIGO/01_MATLAB_CLASICO`.
- Notebook, HTML, script, YAML y pesos → `02_CODIGO/02_PYTHON_YOLO`.
- La plantilla local llamada `Proyecto_PkLot_LaTeX_Overleaf` se retiró por indicación del propietario.
- El repositorio versionado `6af93590bd9d3f02fe9cd113` se inspeccionó, pero su copia fue retirada de la entrega por indicación del propietario. El repositorio externo continúa siendo la única fuente de trabajo mientras se termina el informe.
- `PID PPT.pdf` → `01_DOCUMENTACION/Presentacion_PC5.pdf`.
- Imágenes seleccionadas → originales y muestra de prueba.
- Etiquetas coincidentes → `05_DATOS_PRUEBA/anotaciones`.
- Resultados MATLAB → `04_RESULTADOS/01_MATLAB_CLASICO`.
- Resultados YOLO → `04_RESULTADOS/02_YOLO`, separados de las métricas clásicas.
- Comparación homogénea → `04_RESULTADOS/03_COMPARACION`; se genera como T6 cuando existen predicciones del mismo test.
- Carpetas detalladas y mosaicos de los 12 casos → `03_FINALES/COMPARACION`; se clasificaron como comparativos porque mezclan etapas y técnicas y no deben presentarse falsamente como salidas YOLO puras.

## Exclusiones intencionales

- `yolo_env/`: entorno virtual reproducible desde `requirements.txt`.
- `train/`, `valid/`, `test/`: dataset completo de miles de archivos.
- `_cache_temporal/`: caché de trabajo (aprox. 97 MB).
- `Resultados/_borrar/`: archivo marcado explícitamente para descarte (aprox. 62 MB).
- Archivos de otras asignaturas encontrados en `Downloads`.

## Cambios de rutas y dependencias

- MATLAB espera el dataset en `../../pid_2_pklot`; debe ajustarse `cfg.rutaDataset` o recrearse esa ubicación.
- El notebook usa `/content/...` y descarga el dataset mediante Roboflow.
- `probar.py` contiene rutas del equipo original que deben adaptarse para inferencia local.
- MATLAB: R2020b+ e Image Processing Toolbox, según la documentación original.
- Python: consulte `requirements.txt`.
- Se detectó una clave de Roboflow embebida en el notebook y el HTML originales. La credencial fue redactada en ambas copias antes de publicar el repositorio; las salidas y el resto del contenido se conservaron.

## Verificaciones efectuadas

- Copia preservativa: los archivos fuente permanecen en sus ubicaciones originales.
- Correspondencia de 12 imágenes con 12 archivos de anotación por nombre base.
- El notebook se validó como JSON y conserva celdas/salidas.
- Se verificaron firmas y tamaños no nulos del PDF, HTML y pesos: PDF válido de 29,388,369 bytes, HTML con estructura de documento y `best.pt` de 22,520,426 bytes.
- Se inspeccionaron importaciones y rutas del notebook y scripts.
- MATLAB R2025b analizó los 47 archivos `.m`: no reportó errores de sintaxis; emitió 7 avisos no bloqueantes. Cuatro son supresiones antiguas que ya no corresponden a un aviso y tres recomiendan preasignar arreglos en `evaluarYOLO.m` para mejorar rendimiento.
- No se reentrenó YOLO. La tabla YOLO conserva exactamente los valores de la validación final registrada en el notebook.
- Se añadió `exportar_predicciones_yolo.py`; T6 queda preparado, pero no se inventó una comparación porque el dataset completo no está incluido.
- Durante la inspección del repositorio externo se detectó que falta `figuras/09_comparacion_clasico.png`; este pendiente debe resolverse allí antes de compilar.
- No se generó un PDF local porque no hay una distribución LaTeX instalada y la figura 09 sigue pendiente.

## Pendientes por rúbrica

### Calidad/dificultad — 3 puntos

- Evidencia disponible: dos enfoques, múltiples técnicas clásicas, YOLOv8s, métricas y pesos.
- Pendiente: explicar con precisión que PKLot usa cámaras fijas; no afirmar validación experimental con drones.

### Código ordenado — 4 puntos

- Código separado por método, con guías y dependencias.
- Pendiente manual: comprobar una ejecución completa con el dataset en otro equipo. No se hizo porque el dataset completo fue excluido y no se deben recalcular resultados sin necesidad.

### Documentación — 8 puntos

- Presentación PDF: disponible.
- Imágenes originales/intermedias/finales: disponibles y trazables por fecha/hora.
- Fuente del informe: no incluida mientras esté en desarrollo; se gestiona exclusivamente en el repositorio externo.
- **Pendiente crítico:** falta `Fuente_LaTeX/figuras/09_comparacion_clasico.png`; actualmente el LaTeX mostrará un recuadro de archivo pendiente en esa posición.
- **Pendiente crítico:** terminar el informe en su repositorio Git/Overleaf, resolver la figura faltante y revisar su contenido.
- **Pendiente crítico:** una vez aprobada la versión definitiva, compilarla y copiar el PDF generado como `01_DOCUMENTACION/Informe_Final.pdf`.

### Exposición — 5 puntos

- Pendiente humano: ensayar 4–5 minutos y distribuir la exposición entre al menos dos integrantes.
- Sugerencia de tiempos: problema/datos 40 s; MATLAB 70 s; YOLO 70 s; comparación/resultados 70 s; limitaciones/conclusión 30 s.

## Conclusión

La entrega quedó organizada y verificable, pero no se declara lista para 20/20 mientras falte el PDF final del informe y la validación manual de la exposición.
