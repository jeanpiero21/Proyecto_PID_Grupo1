# PC5 — Ocupación de Estacionamientos con Drones

## Descripción

Proyecto académico de Procesamiento de Imágenes Digitales. Se comparan dos enfoques para estimar la ocupación de cajones de estacionamiento en imágenes del conjunto PKLot:

- **Procesamiento clásico de imágenes**, implementado en **MATLAB**.
- **Detección y clasificación con YOLOv8s**, implementada en **Python** mediante notebook Jupyter/Google Colab.

La entrega incluye un informe realizado en Overleaf/LaTeX, una presentación y evidencias del funcionamiento de ambos métodos.

## Estructura prevista

La siguiente es la **estructura objetivo de la entrega**. Se presenta expandida para que sea fácil identificar dónde va cada archivo y cómo se relacionan ambas técnicas.

> **Importante:** los nombres como `main.m`, `notebook_yolo.ipynb`, `best.pt` o `comparacion.csv` son **ejemplos de ubicación**; no deben crearse archivos vacíos para completar el árbol. Codex debe conservar los nombres reales cuando corresponda y documentar cualquier archivo faltante.

```text
PC5_OCUPACION_ESTACIONAMIENTOS/
│
├── 01_DOCUMENTACION/                         ← Documentos académicos
│   ├── Informe_Final.pdf                     ← Informe compilado desde Overleaf
│   ├── Presentacion_PC5.pdf                  ← Diapositivas exportadas a PDF
│   └── Fuente_LaTeX/                         ← Respaldo opcional del proyecto Overleaf
│       ├── main.tex
│       ├── referencias.bib
│       └── figuras/
│
├── 02_CODIGO/                                ← Implementaciones independientes
│   │
│   ├── 01_MATLAB_CLASICO/                    ← Método clásico (MATLAB)
│   │   ├── main.m                            ← Script principal (nombre referencial)
│   │   ├── funciones/                        ← Funciones auxiliares .m
│   │   └── README.md                         ← Cómo ejecutar MATLAB
│   │
│   └── 02_PYTHON_YOLO/                       ← Método YOLO (Python)
│       ├── notebook_yolo.ipynb              ← Notebook ejecutable (nombre referencial)
│       ├── entrenamiento_evaluacion_yolov8.html ← Exportación HTML para revisar resultados
│       ├── best.pt                          ← Pesos entrenados, si están disponibles
│       ├── requirements.txt                 ← Dependencias Python
│       └── README.md                        ← Cómo ejecutar YOLO
│
├── 03_IMAGENES_REFERENCIALES/                ← Evidencias solicitadas en la rúbrica
│   │
│   ├── 01_ORIGINALES/                        ← Imágenes sin procesar
│   │   ├── caso_01.png
│   │   ├── caso_02.png
│   │   └── caso_03.png
│   │
│   ├── 02_INTERMEDIAS/                       ← Etapas de procesamiento
│   │   ├── MATLAB/                          ← Máscaras, segmentación, cajones, etc.
│   │   └── YOLO/                            ← Detecciones y otras salidas disponibles
│   │
│   └── 03_FINALES/                           ← Resultados visuales definitivos
│       ├── MATLAB/                          ← Predicciones del método clásico
│       ├── YOLO/                            ← Predicciones del método YOLO
│       └── COMPARACION/                     ← Misma escena, ambos métodos
│
├── 04_RESULTADOS/                            ← Resultados numéricos y gráficas
│   ├── METRICAS/
│   │   ├── resultados_matlab.csv            ← Mediciones del método clásico
│   │   ├── resultados_yolo.csv              ← Mediciones de YOLO
│   │   └── comparacion.csv                  ← Comparación con datos reales
│   └── GRAFICAS/
│       ├── matriz_confusion/                ← Si se ha calculado
│       └── comparativas/                    ← Gráficas de evaluación conjunta
│
├── 05_DATOS_PRUEBA/                          ← Muestra reproducible de evaluación
│   ├── imagenes/                            ← Imágenes comunes a ambos métodos
│   ├── anotaciones/                         ← Etiquetas de referencia, si existen
│   └── README.md                            ← Origen, partición y uso de los datos
│
└── README.md                                ← Guía general de toda la entrega
```

**Guía rápida de lectura:**

- `01_DOCUMENTACION`: **qué se presenta y explica** (informe y diapositivas).
- `02_CODIGO`: **cómo funciona** cada técnica. El archivo `entrenamiento_evaluacion_yolov8.html` se guarda junto al notebook de YOLO, **no** dentro del informe.
- `03_IMAGENES_REFERENCIALES`: **qué se ve** en el proceso: entrada, etapas intermedias y salida.
- `04_RESULTADOS`: **qué se mide** para comparar MATLAB y YOLO.
- `05_DATOS_PRUEBA`: **con qué imágenes y etiquetas se puede comprobar** el proyecto.

Para facilitar la comparación, usar el **mismo identificador de caso** (`caso_01`, `caso_02`, etc.) en los archivos de entrada y las salidas de ambos métodos.

## Archivos de referencia

| Archivo | Función |
|---|---|
| `01_DOCUMENTACION/Informe_Final.pdf` | Informe consolidado producido desde Overleaf. |
| `01_DOCUMENTACION/Presentacion_PC5.pdf` | Exposición de 4–5 minutos, a cargo de al menos dos integrantes. |
| `02_CODIGO/01_MATLAB_CLASICO/` | Código fuente de la técnica clásica. |
| `02_CODIGO/02_PYTHON_YOLO/*.ipynb` | Notebook fuente ejecutable de YOLO. |
| `02_CODIGO/02_PYTHON_YOLO/entrenamiento_evaluacion_yolov8.html` | Exportación HTML del notebook para revisar código, gráficas y resultados; **no es ejecutable como notebook**. |
| `03_IMAGENES_REFERENCIALES/` | Evidencias originales, intermedias y finales de los dos métodos. |
| `04_RESULTADOS/` | Gráficas y tablas de métricas reales, incluyendo comparación. |
| `05_DATOS_PRUEBA/` | Imágenes de evaluación y anotaciones permitidas, más instrucciones para conseguir el dataset. |

## Reproducibilidad

**MATLAB:** `PENDIENTE: indicar script principal, versión, toolboxes, datos de entrada y ejecución.`

**YOLO:** `PENDIENTE: indicar notebook principal, dependencias, ubicación de pesos, dataset e instrucciones de inferencia.`

**Comparación:** se deben utilizar las mismas imágenes y anotaciones de referencia para comparar las predicciones de ocupación cuando corresponda. No se deben inventar métricas faltantes.

## Rúbrica PC5

| Criterio | Puntos |
|---|---:|
| Calidad y dificultad del resultado | 3 |
| Código ordenado y estructurado | 4 |
| Documentación: PDF de PPT | 2 |
| Documentación: imágenes originales, intermedias y finales | 3 |
| Documentación: breve informe de resultados | 3 |
| Exposición (4–5 min, al menos dos integrantes) | 5 |
| **Total** | **20** |

## Estado de la entrega

`PENDIENTE: completar este README después de reorganizar y verificar los archivos reales. No dar por existente ninguna ruta o resultado que aún no se haya generado.`
