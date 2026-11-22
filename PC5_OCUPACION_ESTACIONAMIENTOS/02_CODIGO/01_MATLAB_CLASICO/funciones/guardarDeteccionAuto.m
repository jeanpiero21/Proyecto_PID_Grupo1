function guardarDeteccionAuto(inter, variantes, cajasReal, carpeta, prefijo)
%GUARDARDETECCIONAUTO Guarda las imágenes intermedias de la detección automática de cajones.
% La numeración 01--08 mantiene el orden del proceso para revisar los fallos.
if ~isfolder(carpeta), mkdir(carpeta); end
f = @(nombre) fullfile(carpeta, sprintf('%s_%s.png', prefijo, nombre));

imwrite(inter.fondo, f('01_fondo_mediano'));
% Primero guardamos las transformaciones puras, sin anotaciones encima.
imwrite(ind2rgb(gray2ind(mat2gray(inter.actividad), 256), jet(256)), f('02_mapa_actividad'));
imwrite(inter.binaria, f('03_actividad_otsu'));
imwrite(inter.apertura, f('04_otsu_mas_apertura'));
imwrite(label2rgb(inter.etiquetas, 'jet', 'k', 'shuffle'), f('05_watershed'));

% Comparación visual de las variantes: centros detectados (cian) sobre los cajones reales (amarillo)
% Esta figura permite ver rápidamente si faltan regiones o aparecen demasiadas.
nV = numel(variantes);
fig = figure('Visible', 'off', 'Color', 'w', 'Position', [100 100 300*nV 340]);
tl = tiledlayout(1, nV, 'TileSpacing', 'compact', 'Padding', 'compact');
for v = 1:nV
    nexttile; imshow(inter.fondo); hold on;
    for j = 1:size(cajasReal, 1)
        rectangle('Position', [cajasReal(j, 1:2) + 0.5, cajasReal(j, 3:4)], 'EdgeColor', [1 1 0], 'LineWidth', 0.5);
    end
    c = variantes(v).centros;
    if ~isempty(c), plot(c(:, 1) + 0.5, c(:, 2) + 0.5, 'c+', 'MarkerSize', 6, 'LineWidth', 1.5); end
    hold off;
    title({variantes(v).nombre, sprintf('(%d regiones)', size(c, 1))}, 'FontSize', 8);
end
title(tl, 'Amarillo: cajones reales  |  Cian: centros detectados');
guardarFigura(fig, f('06_comparacion_variantes'));

imwrite(inter.tophat_bin, f('07_tophat_binaria'));
% La última evidencia muestra las líneas pintadas encontradas mediante Hough.
fig = figure('Visible', 'off', 'Color', 'w');
imshow(inter.fondo); hold on;
for k = 1:numel(inter.lineas)
    xy = [inter.lineas(k).point1; inter.lineas(k).point2];
    plot(xy(:, 1), xy(:, 2), 'r-', 'LineWidth', 1);
end
hold off;
title(sprintf('Líneas pintadas: top-hat + Otsu + Hough (%d segmentos)', numel(inter.lineas)), 'FontSize', 9);
guardarFigura(fig, f('08_lineas_hough'));
end
