function r = evaluarYOLO(calib, cfg)
%EVALUARYOLO Evalúa las predicciones de YOLO (exportadas con exportar_predicciones_yolo.py)
%   con las MISMAS métricas que el método clásico, para que la comparación sea justa.
%   Archivo por imagen: <nombre>.txt con filas "clase xc yc w h conf" (normalizado).
%   (a) Detección de cajones: emparejamiento 1 a 1 con IoU >= cfg.iouDeteccion.
%   (b) Por clase: además el par emparejado debe tener la misma clase (libre / ocupado).
%   (c) % de ocupación "crudo" (como probar.py): ocupados / (ocupados + libres detectados).
%   (d) Híbrido: cada cajón del mapa fijo toma la clase de la caja YOLO que más se le superpone
%       (IoU >= 0.3; si no hay ninguna se asume libre) -> denominador fijo.
lista = listarSplit(cfg.rutaDataset, cfg.splitEval);
W = calib.W; H = calib.H;
det = zeros(1, 3); porClase = zeros(2, 3);          % [TP FP FN]
yReal = zeros(0, 1); yHib = false(0, 1);
pctReal = zeros(0, 1); pctCrudo = zeros(0, 1); pctHib = zeros(0, 1);
nFalta = 0;
for i = 1:numel(lista)
    if cfg.excluirMalEtiquetadas && startsWith(lista(i).nombre, cfg.imagenesExcluir), continue; end
    [cl, cajasR, nrm] = leerEtiquetas(lista(i).lbl, W, H);
    if isempty(cl), continue; end
    rutaPred = fullfile(cfg.rutaPredYOLO, [lista(i).nombre '.txt']);
    if ~isfile(rutaPred), nFalta = nFalta + 1; continue; end
    [clP, cajasP] = leerPredicciones(rutaPred, W, H);
    I = imread(lista(i).img);
    if size(I, 3) == 3, g = im2double(rgb2gray(I)); else, g = im2double(I); end
    c = identificarCamara(g, calib.camaras, cfg.tamPlantilla);
    if c ~= camaraDesdeEtiquetas(nrm, calib.camaras, cfg.tolLayout), continue; end

    % (a) y (b)
    m = metricasDeteccion(cajasP, cajasR, cfg.iouDeteccion);
    det = det + [m.TP m.FP m.FN];
    for k = 0:1
        mk = metricasDeteccion(cajasP(clP == k, :), cajasR(cl == k, :), cfg.iouDeteccion);
        porClase(k + 1, :) = porClase(k + 1, :) + [mk.TP mk.FP mk.FN];
    end
    % (c)
    if isempty(clP), pc = 0; else, pc = 100*mean(clP == 1); end
    % (d)
    cajasMapa = calib.camaras(c).cajas;
    yh = false(size(cajasMapa, 1), 1);
    if ~isempty(cajasP)
        [mx, kmax] = max(iouCajas(cajasMapa, cajasP), [], 2);
        yh = mx >= 0.3 & clP(kmax) == 1;
    end
    j = emparejarConMapa(cajasR, cajasMapa);
    y = nan(size(cajasMapa, 1), 1); y(j) = cl;
    ok = ~isnan(y);
    yReal = [yReal; y(ok)];          %#ok<AGROW>
    yHib  = [yHib; yh(ok)];          %#ok<AGROW>
    pctReal(end + 1, 1)  = 100*mean(y(ok));
    pctCrudo(end + 1, 1) = pc;
    pctHib(end + 1, 1)   = 100*mean(yh(ok));
end
r.nImagenes = numel(pctReal);
r.nSinPrediccion = nFalta;
r.det = prf(det);
r.libre = prf(porClase(1, :));
r.ocupado = prf(porClase(2, :));
r.hibrido = metricasClasificacion(yReal, yHib);
r.ocupCrudo = metricasOcupacion(pctReal, pctCrudo);
r.ocupHibrido = metricasOcupacion(pctReal, pctHib);
end

function s = prf(v)
s.TP = v(1); s.FP = v(2); s.FN = v(3);
s.precision = v(1) / max(v(1) + v(2), 1);
s.recall    = v(1) / max(v(1) + v(3), 1);
s.f1        = 2*s.precision*s.recall / max(s.precision + s.recall, eps);
end
