"""Exporta predicciones YOLO al formato que consume el bloque T6 de MATLAB.

Cada imagen produce un TXT con filas:
    clase x_centro y_centro ancho alto confianza

Las coordenadas son normalizadas, igual que en las etiquetas YOLO. El script
solo realiza inferencia; no vuelve a entrenar el modelo.
"""

from __future__ import annotations

import argparse
from pathlib import Path

from ultralytics import YOLO


def argumentos() -> argparse.Namespace:
    carpeta_script = Path(__file__).resolve().parent
    carpeta_codigo = carpeta_script.parent
    raiz_entrega = carpeta_codigo.parent.parent
    parser = argparse.ArgumentParser(
        description="Exporta las predicciones del test para compararlas en MATLAB."
    )
    parser.add_argument(
        "--pesos",
        type=Path,
        default=carpeta_codigo / "pesos" / "best.pt",
        help="Ruta al archivo best.pt.",
    )
    parser.add_argument(
        "--imagenes",
        type=Path,
        default=raiz_entrega / "pid_2_pklot" / "test" / "images",
        help="Carpeta test/images del dataset completo.",
    )
    parser.add_argument(
        "--salida",
        type=Path,
        default=raiz_entrega / "04_RESULTADOS" / "02_YOLO" / "PREDICCIONES_TEST",
        help="Carpeta de TXT que leerá evaluarYOLO.m.",
    )
    parser.add_argument("--conf", type=float, default=0.25)
    parser.add_argument("--iou", type=float, default=0.70)
    parser.add_argument("--imgsz", type=int, default=640)
    parser.add_argument("--device", default=None, help="Ejemplo: 0 o cpu.")
    return parser.parse_args()


def exportar() -> None:
    args = argumentos()
    pesos = args.pesos.resolve()
    imagenes = args.imagenes.resolve()
    salida = args.salida.resolve()

    if not pesos.is_file():
        raise FileNotFoundError(f"No se encontraron los pesos: {pesos}")
    if not imagenes.is_dir():
        raise FileNotFoundError(f"No se encontró test/images: {imagenes}")

    salida.mkdir(parents=True, exist_ok=True)
    modelo = YOLO(str(pesos))
    resultados = modelo.predict(
        source=str(imagenes),
        conf=args.conf,
        iou=args.iou,
        imgsz=args.imgsz,
        device=args.device,
        stream=True,
        verbose=False,
    )

    cantidad = 0
    for resultado in resultados:
        nombre = Path(resultado.path).stem
        ruta_txt = salida / f"{nombre}.txt"
        lineas: list[str] = []
        if resultado.boxes is not None:
            clases = resultado.boxes.cls.cpu().tolist()
            confianzas = resultado.boxes.conf.cpu().tolist()
            cajas = resultado.boxes.xywhn.cpu().tolist()
            for clase, caja, confianza in zip(clases, cajas, confianzas):
                xc, yc, ancho, alto = caja
                lineas.append(
                    f"{int(clase)} {xc:.8f} {yc:.8f} "
                    f"{ancho:.8f} {alto:.8f} {confianza:.8f}"
                )
        ruta_txt.write_text("\n".join(lineas), encoding="utf-8")
        cantidad += 1

    print(f"Predicciones exportadas: {cantidad}")
    print(f"Carpeta de salida: {salida}")


if __name__ == "__main__":
    exportar()
