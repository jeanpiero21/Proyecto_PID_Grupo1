"""Genera detecciones YOLO y comparativas MATLAB–YOLO para los 12 casos.

Entradas:
  - 05_DATOS_PRUEBA/imagenes y anotaciones
  - pesos/best.pt
  - resultados visuales y métricas ya obtenidos con MATLAB

Salidas:
  - 03_IMAGENES_REFERENCIALES/03_FINALES/YOLO
  - 03_IMAGENES_REFERENCIALES/03_FINALES/COMPARACION/MATLAB_VS_YOLO
  - 04_RESULTADOS/02_YOLO/METRICAS/metricas_12_casos_yolo.csv
  - 04_RESULTADOS/03_COMPARACION/comparacion_matlab_vs_yolo.csv
"""

from __future__ import annotations

import argparse
import csv
from pathlib import Path

import cv2
import numpy as np
from PIL import Image, ImageDraw, ImageFont, ImageOps
from ultralytics import YOLO


COLORES = {0: (40, 200, 40), 1: (30, 30, 235)}  # BGR: libre / ocupado
NOMBRES = {0: "libre", 1: "ocupado"}
COLORES_EVALUACION = {
    "TP": (0, 0, 255),       # rojo
    "TN": (0, 220, 0),       # verde
    "FP": (0, 230, 230),     # amarillo
    "FN": (230, 230, 0),     # celeste
}


def argumentos() -> argparse.Namespace:
    carpeta = Path(__file__).resolve().parent
    entrega = carpeta.parent.parent
    p = argparse.ArgumentParser(description="Genera resultados comparables para 12 casos.")
    p.add_argument("--pesos", type=Path, default=carpeta / "pesos" / "best.pt")
    p.add_argument("--imagenes", type=Path, default=entrega / "05_DATOS_PRUEBA" / "imagenes")
    p.add_argument("--anotaciones", type=Path, default=entrega / "05_DATOS_PRUEBA" / "anotaciones")
    p.add_argument("--conf", type=float, default=0.25)
    p.add_argument("--iou-nms", type=float, default=0.70)
    p.add_argument("--iou-metrica", type=float, default=0.50)
    p.add_argument("--imgsz", type=int, default=640)
    p.add_argument("--device", default=None, help="Ejemplo: 0 o cpu.")
    return p.parse_args()


def id_caso(stem: str) -> str:
    return stem.split("_jpg.rf.", 1)[0]


def fuente(tamano: int, negrita: bool = False) -> ImageFont.FreeTypeFont | ImageFont.ImageFont:
    nombre = "arialbd.ttf" if negrita else "arial.ttf"
    ruta = Path("C:/Windows/Fonts") / nombre
    try:
        return ImageFont.truetype(str(ruta), tamano)
    except OSError:
        return ImageFont.load_default()


def leer_ground_truth(ruta: Path, ancho: int, alto: int) -> tuple[np.ndarray, np.ndarray]:
    clases, cajas = [], []
    for linea in ruta.read_text(encoding="utf-8").splitlines():
        if not linea.strip():
            continue
        clase, xc, yc, w, h = map(float, linea.split()[:5])
        cajas.append([
            (xc - w / 2) * ancho,
            (yc - h / 2) * alto,
            (xc + w / 2) * ancho,
            (yc + h / 2) * alto,
        ])
        clases.append(int(clase))
    return np.asarray(clases, dtype=int), np.asarray(cajas, dtype=float).reshape(-1, 4)


def iou(a: np.ndarray, b: np.ndarray) -> np.ndarray:
    if len(a) == 0 or len(b) == 0:
        return np.zeros((len(a), len(b)))
    x1 = np.maximum(a[:, None, 0], b[None, :, 0])
    y1 = np.maximum(a[:, None, 1], b[None, :, 1])
    x2 = np.minimum(a[:, None, 2], b[None, :, 2])
    y2 = np.minimum(a[:, None, 3], b[None, :, 3])
    inter = np.maximum(0, x2 - x1) * np.maximum(0, y2 - y1)
    area_a = (a[:, 2] - a[:, 0]) * (a[:, 3] - a[:, 1])
    area_b = (b[:, 2] - b[:, 0]) * (b[:, 3] - b[:, 1])
    return inter / np.maximum(area_a[:, None] + area_b[None, :] - inter, 1e-9)


def metricas(gt_c: np.ndarray, gt_b: np.ndarray, pr_c: np.ndarray, pr_b: np.ndarray,
             umbral: float) -> tuple[int, int, int, float, float, float]:
    """Empareja cajas de la misma clase, una a una, usando IoU."""
    tp = 0
    for clase in (0, 1):
        g = gt_b[gt_c == clase]
        p = pr_b[pr_c == clase]
        matriz = iou(g, p)
        usados_g, usados_p = set(), set()
        while matriz.size:
            gi, pi = np.unravel_index(np.argmax(matriz), matriz.shape)
            if matriz[gi, pi] < umbral:
                break
            tp += 1
            usados_g.add(gi)
            usados_p.add(pi)
            matriz[gi, :] = -1
            matriz[:, pi] = -1
    fp = len(pr_c) - tp
    fn = len(gt_c) - tp
    precision = tp / max(tp + fp, 1)
    recall = tp / max(tp + fn, 1)
    f1 = 2 * precision * recall / max(precision + recall, 1e-12)
    return tp, fp, fn, precision, recall, f1


def emparejar_cajas(gt_b: np.ndarray, pr_b: np.ndarray, umbral: float) -> list[tuple[int, int]]:
    """Empareja cajas por IoU sin usar la clase, una a una."""
    matriz = iou(gt_b, pr_b)
    pares: list[tuple[int, int]] = []
    while matriz.size:
        gi, pi = np.unravel_index(np.argmax(matriz), matriz.shape)
        if matriz[gi, pi] < umbral:
            break
        pares.append((int(gi), int(pi)))
        matriz[gi, :] = -1
        matriz[:, pi] = -1
    return pares


def dibujar_evaluacion(imagen: np.ndarray, gt_c: np.ndarray, gt_b: np.ndarray,
                       pr_c: np.ndarray, pr_b: np.ndarray, umbral: float) -> np.ndarray:
    """Dibuja TP, TN, FP y FN con el mismo código de color usado por MATLAB."""
    lienzo = imagen.copy()
    pares = emparejar_cajas(gt_b, pr_b, umbral)
    pred_asociada = {gi: pi for gi, pi in pares}
    usados_pred = {pi for _, pi in pares}

    for gi, caja in enumerate(gt_b):
        real = int(gt_c[gi])
        if gi in pred_asociada:
            pred = int(pr_c[pred_asociada[gi]])
            tipo = "TP" if real == 1 and pred == 1 else \
                   "TN" if real == 0 and pred == 0 else \
                   "FP" if real == 0 and pred == 1 else "FN"
        else:
            tipo = "FN" if real == 1 else "TN"
        x1, y1, x2, y2 = np.rint(caja).astype(int)
        cv2.rectangle(lienzo, (x1, y1), (x2, y2), COLORES_EVALUACION[tipo], 2)

    # Una predicción ocupada sin caja real asociada también es un falso positivo.
    for pi, caja in enumerate(pr_b):
        if pi not in usados_pred and int(pr_c[pi]) == 1:
            x1, y1, x2, y2 = np.rint(caja).astype(int)
            cv2.rectangle(lienzo, (x1, y1), (x2, y2), COLORES_EVALUACION["FP"], 2)
    return lienzo


def dibujar_yolo(imagen: np.ndarray, cajas: np.ndarray, clases: np.ndarray,
                 confianzas: np.ndarray, real: float, estimado: float,
                 precision: float, recall: float, f1: float) -> np.ndarray:
    barra = 108
    lienzo = cv2.copyMakeBorder(imagen, barra, 0, 0, 0, cv2.BORDER_CONSTANT, value=(245, 245, 245))
    for caja, clase, conf in zip(cajas, clases, confianzas):
        x1, y1, x2, y2 = np.rint(caja).astype(int)
        y1 += barra
        y2 += barra
        color = COLORES[int(clase)]
        cv2.rectangle(lienzo, (x1, y1), (x2, y2), color, 2)
    cv2.putText(lienzo, "YOLOv8s | Verde: libre | Rojo: ocupado",
                (10, 27), cv2.FONT_HERSHEY_SIMPLEX, 0.48, (20, 20, 20), 1, cv2.LINE_AA)
    cv2.putText(lienzo, f"Real {real:.1f}% | YOLO {estimado:.1f}% | Error {abs(real-estimado):.1f} pp",
                (10, 60), cv2.FONT_HERSHEY_SIMPLEX, 0.48, (20, 20, 20), 1, cv2.LINE_AA)
    cv2.putText(lienzo, f"Precision {precision:.3f} | Recall {recall:.3f} | F1 {f1:.3f}",
                (10, 93), cv2.FONT_HERSHEY_SIMPLEX, 0.38, (20, 20, 20), 1, cv2.LINE_AA)
    return lienzo


def tarjeta(ruta: Path, titulo: str, detalle: str = "", metricas: str = "",
            quitar_encabezado: bool = False, ancho: int = 850,
            alto: int = 680) -> Image.Image:
    panel = Image.open(ruta).convert("RGB")
    if quitar_encabezado and panel.height > panel.width:
        # Las salidas MATLAB y YOLO incluyen una franja superior propia.
        # Se retira para reemplazarla por un encabezado común y comparable.
        panel = panel.crop((0, panel.height - panel.width, panel.width, panel.height))
    alto_texto = 112
    panel = ImageOps.contain(panel, (ancho - 30, alto - alto_texto - 10), Image.Resampling.LANCZOS)
    fondo = Image.new("RGB", (ancho, alto), "white")
    x = (ancho - panel.width) // 2
    y = alto_texto + (alto - alto_texto - panel.height) // 2
    fondo.paste(panel, (x, y))
    d = ImageDraw.Draw(fondo)
    d.text((ancho // 2, 23), titulo, font=fuente(24, True), fill="black", anchor="mm")
    if detalle:
        d.text((ancho // 2, 56), detalle, font=fuente(19), fill="black", anchor="mm")
    if metricas:
        d.text((ancho // 2, 87), metricas, font=fuente(18), fill="black", anchor="mm")
    return fondo


def comparativa(paneles: list[tuple[Path, str, str, str, bool]],
                encabezado: str, salida: Path) -> None:
    cards = [tarjeta(*panel) for panel in paneles]
    margen_superior = 100
    lienzo = Image.new("RGB", (1700, 2 * 680 + margen_superior), "white")
    for i, card in enumerate(cards):
        lienzo.paste(card, ((i % 2) * 850, margen_superior + (i // 2) * 680))
    dibujo = ImageDraw.Draw(lienzo)
    dibujo.text((850, 28), encabezado, font=fuente(29, True), fill="black", anchor="mm")
    dibujo.text((850, 70),
                 "Rojo: TP | Verde: TN | Amarillo: FP | Celeste: FN",
                 font=fuente(20, True), fill="black", anchor="mm")
    salida.parent.mkdir(parents=True, exist_ok=True)
    lienzo.save(salida, quality=95)


def leer_csv_por_id(ruta: Path) -> dict[str, dict[str, str]]:
    with ruta.open(encoding="utf-8-sig", newline="") as f:
        return {fila["imagen"]: fila for fila in csv.DictReader(f)}


def escribir_csv(ruta: Path, filas: list[dict[str, object]]) -> None:
    ruta.parent.mkdir(parents=True, exist_ok=True)
    with ruta.open("w", encoding="utf-8", newline="") as f:
        w = csv.DictWriter(f, fieldnames=list(filas[0]))
        w.writeheader()
        w.writerows(filas)


def main() -> None:
    args = argumentos()
    carpeta_script = Path(__file__).resolve().parent
    entrega = carpeta_script.parent.parent
    salida_yolo = entrega / "03_IMAGENES_REFERENCIALES" / "03_FINALES" / "YOLO"
    salida_comp = entrega / "03_IMAGENES_REFERENCIALES" / "03_FINALES" / "COMPARACION" / "MATLAB_VS_YOLO"
    casos_matlab = entrega / "03_IMAGENES_REFERENCIALES" / "03_FINALES" / "COMPARACION" / "casos_detallados"
    csv_matlab = entrega / "04_RESULTADOS" / "01_MATLAB_CLASICO" / "METRICAS" / "metricas_por_imagen.csv"
    csv_yolo = entrega / "04_RESULTADOS" / "02_YOLO" / "METRICAS" / "metricas_12_casos_yolo.csv"
    csv_comp = entrega / "04_RESULTADOS" / "03_COMPARACION" / "comparacion_matlab_vs_yolo.csv"

    modelo = YOLO(str(args.pesos.resolve()))
    matlab = leer_csv_por_id(csv_matlab)
    filas_yolo, filas_comp = [], []
    imagenes = sorted(p for p in args.imagenes.iterdir() if p.suffix.lower() in {".jpg", ".jpeg", ".png"})

    for ruta_imagen in imagenes:
        caso = id_caso(ruta_imagen.stem)
        ruta_gt = args.anotaciones / f"{ruta_imagen.stem}.txt"
        imagen = cv2.imread(str(ruta_imagen))
        alto, ancho = imagen.shape[:2]
        gt_c, gt_b = leer_ground_truth(ruta_gt, ancho, alto)
        resultado = modelo.predict(str(ruta_imagen), conf=args.conf, iou=args.iou_nms,
                                   imgsz=args.imgsz, device=args.device, verbose=False)[0]
        pr_c = resultado.boxes.cls.cpu().numpy().astype(int)
        pr_b = resultado.boxes.xyxy.cpu().numpy()
        conf = resultado.boxes.conf.cpu().numpy()
        dtp, dfp, dfn, dp, dr, df1 = metricas(gt_c, gt_b, pr_c, pr_b, args.iou_metrica)
        # Para comparar con MATLAB usamos la clase positiva "ocupado".
        tp, fp, fn, precision, recall, f1 = metricas(
            gt_c[gt_c == 1], gt_b[gt_c == 1],
            pr_c[pr_c == 1], pr_b[pr_c == 1], args.iou_metrica)
        real = 100 * np.mean(gt_c == 1) if len(gt_c) else 0.0
        estimado = 100 * np.mean(pr_c == 1) if len(pr_c) else 0.0

        salida_individual = salida_yolo / f"yolo_{caso}.png"
        salida_evaluacion = salida_yolo / f"evaluacion_yolo_{caso}.png"
        salida_yolo.mkdir(parents=True, exist_ok=True)
        cv2.imwrite(str(salida_individual), dibujar_yolo(
            imagen, pr_b, pr_c, conf, real, estimado, precision, recall, f1))
        cv2.imwrite(str(salida_evaluacion), dibujar_evaluacion(
            imagen, gt_c, gt_b, pr_c, pr_b, args.iou_metrica))

        m = matlab[caso]
        filas_yolo.append({
            "imagen": caso, "TP": tp, "FP": fp, "FN": fn,
            "precision": f"{precision:.6f}", "recall": f"{recall:.6f}",
            "F1": f"{f1:.6f}", "ocupacion_real_pct": f"{real:.3f}",
            "ocupacion_yolo_pct": f"{estimado:.3f}",
            "error_yolo_pp": f"{abs(real-estimado):.3f}",
            "precision_deteccion_global": f"{dp:.6f}",
            "recall_deteccion_global": f"{dr:.6f}",
            "F1_deteccion_global": f"{df1:.6f}",
        })
        filas_comp.append({
            "imagen": caso, "ocupacion_real_pct": f"{real:.3f}",
            "precision_matlab": m["P"], "recall_matlab": m["R"], "F1_matlab": m["F1"],
            "ocupacion_matlab_pct": m["pp"],
            "error_matlab_pp": f"{abs(float(m['pr'])-float(m['pp'])):.3f}",
            "precision_yolo": f"{precision:.6f}", "recall_yolo": f"{recall:.6f}",
            "F1_yolo": f"{f1:.6f}", "ocupacion_yolo_pct": f"{estimado:.3f}",
            "error_yolo_pp": f"{abs(real-estimado):.3f}",
        })

        carpeta_caso = casos_matlab / caso
        comparativa(
            [
                (ruta_imagen, "Imagen original", "Entrada común a ambos métodos", "", False),
                (carpeta_caso / "08_ground_truth.png", "Ground truth",
                 f"Ocupación real: {real:.1f}%", "40 cajones etiquetados", True),
                (carpeta_caso / "10_comparacion.png", "MATLAB clásico",
                 f"Real {real:.1f}% | Estimado {float(m['pp']):.1f}% | Error {abs(float(m['pr'])-float(m['pp'])):.1f} pp",
                 f"Precisión {float(m['P']):.3f} | Recall {float(m['R']):.3f} | F1 {float(m['F1']):.3f}", True),
                (salida_evaluacion, "YOLOv8s",
                 f"Real {real:.1f}% | Estimado {estimado:.1f}% | Error {abs(real-estimado):.1f} pp",
                 f"Precisión {precision:.3f} | Recall {recall:.3f} | F1 {f1:.3f}", False),
            ],
            f"Caso {caso} | Ocupación real: {real:.1f}%",
            salida_comp / f"matlab_vs_yolo_{caso}.jpg",
        )
        print(f"Generado: {caso}")

    escribir_csv(csv_yolo, filas_yolo)
    escribir_csv(csv_comp, filas_comp)
    print(f"Listo: {len(imagenes)} resultados YOLO y {len(imagenes)} comparativas.")


if __name__ == "__main__":
    main()
