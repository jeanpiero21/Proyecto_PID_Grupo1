import cv2
from ultralytics import YOLO

# 1. Cargar el nuevo modelo (Asegúrate de colocar tu nuevo best.pt)
model = YOLO('modelo_entrenado/best.pt')

# 2. Cargar una imagen de prueba del dataset
imagen_prueba = 'test/images/2013-04-13_15_45_10_jpg.rf.3be1e71f3af841bc5e5e346118ceac52.jpg'
imagen = cv2.imread(imagen_prueba)

print("Analizando estacionamiento con el modelo PKLot...")
# conf=0.4 filtra las detecciones dudosas
resultados = model.predict(source=imagen, conf=0.3) 

# Contadores
ocupados = 0
libres = 0

# Configuraciones visuales para las etiquetas pequeñas
fuente = cv2.FONT_HERSHEY_SIMPLEX
escala_fuente = 0.3
grosor_fuente = 1

# 3. Dibujar cajas y contar espacios
for box in resultados[0].boxes:
    x1, y1, x2, y2 = map(int, box.xyxy[0])
    conf = float(box.conf[0])
    cls = int(box.cls[0]) # Extrae el ID de la clase (0 o 1)
    
    # Asignar lógica según la clase (vacío u ocupado)
    # NOTA: Si al probarlo los colores salen al revés (verde en autos y rojo en vacíos), 
    # simplemente cambia el `if cls == 0:` por `if cls == 1:`
    if cls == 0:  
        color = (0, 255, 0) # Verde para espacios libres
        etiqueta = f"Libre {int(conf*100)}%"
        libres += 1
    else:         
        color = (0, 0, 255) # Rojo para espacios ocupados
        etiqueta = f"Ocupado {int(conf*100)}%"
        ocupados += 1
        
    # Dibujar la caja delgada (grosor 1)
    cv2.rectangle(imagen, (x1, y1), (x2, y2), color, 1)
    
    # Dibujar fondo sólido para que el texto sea legible
    (ancho_texto, alto_texto), _ = cv2.getTextSize(etiqueta, fuente, escala_fuente, grosor_fuente)
    cv2.rectangle(imagen, (x1, y1 - alto_texto - 4), (x1 + ancho_texto + 2, y1), color, -1)
    
    # Escribir el texto en color negro sobre el fondo
    cv2.putText(imagen, etiqueta, (x1 + 1, y1 - 2), fuente, escala_fuente, (0, 0, 0), grosor_fuente)

# 4. Calcular el porcentaje de ocupación
total_espacios = ocupados + libres
porcentaje_ocupacion = (ocupados / total_espacios * 100) if total_espacios > 0 else 0

# 5. Generar la franja negra superior para los resultados
alto_borde = 50
imagen_expandida = cv2.copyMakeBorder(imagen, alto_borde, 0, 0, 0, cv2.BORDER_CONSTANT, value=[0, 0, 0])

# 6. Escribir las estadísticas totales en la franja
texto_stats = f"Total: {total_espacios} | Libres: {libres} | Ocupados: {ocupados} | Ocupacion: {porcentaje_ocupacion:.1f}%"
cv2.putText(imagen_expandida, texto_stats, (15, 45), cv2.FONT_HERSHEY_SIMPLEX, 0.5, (255, 255, 255), 2)

# 7. Mostrar y guardar el resultado final
cv2.imshow("Monitoreo de Ocupacion - PKLot", imagen_expandida)
print("Presiona cualquier tecla en la imagen para cerrarla y guardar.")
cv2.waitKey(0)
cv2.destroyAllWindows()

cv2.imwrite("resultado_ocupacion_pklot.jpg", imagen_expandida)
print("Imagen guardada como 'resultado_ocupacion_pklot.jpg'")