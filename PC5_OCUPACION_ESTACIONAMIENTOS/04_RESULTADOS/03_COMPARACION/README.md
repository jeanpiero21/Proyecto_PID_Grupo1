# Comparación homogénea MATLAB–YOLO

`comparacion_matlab_vs_yolo.csv` compara ambos métodos sobre las mismas 12
imágenes del entregable. La clase positiva es `ocupado`; para YOLO, una caja
debe coincidir en clase y alcanzar IoU mayor o igual que 0.50.

Las composiciones visuales correspondientes están en
`03_IMAGENES_REFERENCIALES/03_FINALES/COMPARACION/MATLAB_VS_YOLO`.

La comparación del test completo continúa disponible como T6: `main.m` genera
`T6_clasico_vs_yolo.csv` cuando existen predicciones en
`../02_YOLO/PREDICCIONES_TEST`. No se mezcla el mAP de validación con las
métricas por cajón porque describen protocolos distintos.
