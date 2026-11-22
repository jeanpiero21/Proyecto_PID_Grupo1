function [variantes, inter] = detectarCajonesAuto(rutasImgs, mascaraROI, cfg)
%DETECTARCAJONESAUTO Detección de cajones SIN etiquetas, solo con procesamiento de imágenes.
%   1) Fondo = mediana temporal de muchas imágenes de la misma cámara (los autos son transitorios).
%   2) Mapa de actividad = fracción de imágenes en que cada píxel difiere del fondo.
%   3) Suavizado + umbral de Otsu dentro de la zona de interés.                       (S10)
%   4) Variantes que se comparan:
%      a) Otsu + componentes conexas                                                 (S10)
%      b) Otsu + apertura + componentes conexas                                      (S9)
%      c) Otsu + apertura + watershed con marcadores de h-máximos, para varios h     (S10)
%   5) Aparte: líneas pintadas sobre el fondo (top-hat + Otsu + Hough), para visualización.
%   variantes(k).nombre, .centros (Mx2), .cajas (Mx4)
n = numel(rutasImgs);
I0 = imread(rutasImgs{1});
[H, W, ~] = size(I0);
pila = zeros(H, W, n, 'single');
for k = 1:n
    I = imread(rutasImgs{k});
    if size(I, 3) == 3, I = rgb2gray(I); end
    pila(:, :, k) = im2single(I);
end
fondo = median(pila, 3);
actividad = mean(abs(pila - fondo) > cfg.auto.umbralDif, 3);
g = fspecial('gaussian', 2*ceil(2*cfg.auto.sigma) + 1, cfg.auto.sigma);
actividad = imfilter(double(actividad), g, 'replicate');
clear pila

if isempty(mascaraROI), mascaraROI = true(H, W); end
act = actividad .* mascaraROI;
bw0 = act > umbralOtsu(act(mascaraROI));
bw1 = imopen(bw0, strel('disk', cfg.auto.radioApertura));

variantes = struct('nombre', {}, 'centros', {}, 'cajas', {});
[c0, b0] = regionesFiltradas(bwlabel(bw0), cfg);
variantes(end + 1) = struct('nombre', 'Otsu + componentes conexas', 'centros', c0, 'cajas', b0);
[c0, b0] = regionesFiltradas(bwlabel(bw1), cfg);
variantes(end + 1) = struct('nombre', 'Otsu + apertura + componentes conexas', 'centros', c0, 'cajas', b0);
Lws = [];
for k = 1:numel(cfg.auto.hLista)
    h = cfg.auto.hLista(k);
    marcadores = imextendedmax(act, h) & bw1;
    L = watershed(imimposemin(-act, marcadores));
    L(~bw1) = 0;
    if k == 1, Lws = L; marcadores1 = marcadores; end
    [c0, b0] = regionesFiltradas(L, cfg);
    variantes(end + 1) = struct('nombre', sprintf('Otsu + apertura + watershed (h = %.2f)', h), ...
        'centros', c0, 'cajas', b0); %#ok<AGROW>
end

[inter.lineas, inter.tophat_bin] = lineasPintadas(fondo);
inter.fondo = fondo;
inter.actividad = actividad;
inter.binaria = bw0;
inter.apertura = bw1;
inter.marcadores = marcadores1;
inter.etiquetas = Lws;
end

function [centros, cajas] = regionesFiltradas(L, cfg)
% Centroides y cajas de las regiones de una matriz de etiquetas, sin las regiones pequeñas.
centros = zeros(0, 2); cajas = zeros(0, 4);
stats = regionprops(L, 'Area', 'BoundingBox', 'Centroid');
if isempty(stats), return; end
area = [stats.Area];
stats = stats(area > 0); area = area(area > 0);
if isempty(stats), return; end
stats = stats(area >= cfg.auto.areaMinRel * median(area));
cajas = reshape([stats.BoundingBox], 4, [])';
cajas(:, 1:2) = cajas(:, 1:2) - 0.5;                 % a coordenadas con origen 0
centros = reshape([stats.Centroid], 2, [])' - 0.5;
end
