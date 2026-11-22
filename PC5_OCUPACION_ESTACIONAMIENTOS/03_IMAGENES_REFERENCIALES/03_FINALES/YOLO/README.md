# Imágenes finales de YOLO

- `DETECCIONES`: muestra únicamente la salida de YOLO. Las cajas indican qué
  cajones detectó como libres u ocupados, junto con la confianza y la ocupación
  estimada. No señala todavía si cada detección fue correcta.
- `EVALUACION`: compara las detecciones con las anotaciones reales. Permite
  identificar verdaderos positivos, falsos positivos y falsos negativos.
- `DEMO`: contiene una ejecución individual y sencilla del script `probar.py`.

Esta separación evita confundir la predicción visual del modelo con su
evaluación frente al valor real.
