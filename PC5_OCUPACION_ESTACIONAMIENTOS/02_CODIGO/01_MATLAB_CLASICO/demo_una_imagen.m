%% DEMO: analizar una imagen elegida (útil para la exposición)
%  Requiere haber corrido main.m al menos una vez (genera resultados/calibracion.mat).
%  Ojo: el sistema conoce solo las cámaras calibradas (PUCPR, UFPR04, UFPR05).
clear; clc; close all;
cfg = config();
addpath(fullfile(cfg.raiz, 'funciones'));
archivoCalib = fullfile(cfg.rutaSalida, 'calibracion.mat');
if ~isfile(archivoCalib), error('Primero ejecuta main.m para calibrar.'); end
load(archivoCalib, 'calib');

[archivo, carpeta] = uigetfile({'*.jpg;*.png', 'Imágenes'}, 'Elige una imagen del estacionamiento', ...
    fullfile(cfg.rutaDataset, cfg.splitEval, 'images'));
if isequal(archivo, 0), return; end
I = imread(fullfile(carpeta, archivo));

tic;
R = analizarImagen(I, calib, cfg);
t = toc;
cam = calib.camaras(R.camara);
fprintf('Cámara: %s (correlación %.3f) | tiempo: %.0f ms\n', cam.nombre, max(R.puntajes), 1000*t);
fprintf('Total: %d | Libres: %d | Ocupados: %d | Ocupación: %.1f %%\n', ...
    R.nTotal, R.nTotal - R.nOcupados, R.nOcupados, R.porcentaje);

titulo = sprintf('%s | Libres: %d | Ocupados: %d | Ocupación: %.1f%%', ...
    cam.nombre, R.nTotal - R.nOcupados, R.nOcupados, R.porcentaje);
fig = dibujarCajones(I, cam.cajas, R.ocupado, cfg.factorROI, titulo);
set(fig, 'Visible', 'on');

% Si la imagen tiene etiqueta, mostrar los aciertos
[~, base] = fileparts(archivo);
rutaLbl = fullfile(carpeta, '..', 'labels', [base '.txt']);
[cl, cajasR] = leerEtiquetas(rutaLbl, size(I, 2), size(I, 1));
if ~isempty(cl)
    j = emparejarConMapa(cajasR, cam.cajas);
    y = nan(R.nTotal, 1); y(j) = cl; ok = ~isnan(y);
    mc = metricasClasificacion(y(ok), R.ocupado(ok));
    fprintf('Contra la etiqueta: exactitud = %.3f | P = %.3f | R = %.3f | %% real = %.1f %%\n', ...
        mc.exactitud, mc.precision, mc.recall, 100*mean(y(ok)));
end
