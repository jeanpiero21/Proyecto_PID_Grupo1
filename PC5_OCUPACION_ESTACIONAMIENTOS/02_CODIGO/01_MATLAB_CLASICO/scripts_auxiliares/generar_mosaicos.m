%% GENERAR_MOSAICOS
% Reconstruye los mosaicos comparativos con espacio suficiente para títulos.
% Usa únicamente las imágenes y métricas ya guardadas en la entrega.

clear; clc; close all;

raizCodigo = fileparts(fileparts(mfilename('fullpath')));
raizEntrega = fullfile(raizCodigo, '..', '..');
carpetaComparacion = fullfile(raizEntrega, '03_IMAGENES_REFERENCIALES', ...
    '03_FINALES', 'COMPARACION');
carpetaCasos = fullfile(carpetaComparacion, 'casos_detallados');
rutaMetricas = fullfile(raizEntrega, '04_RESULTADOS', ...
    '01_MATLAB_CLASICO', 'METRICAS', 'metricas_por_imagen.csv');

assert(isfolder(carpetaCasos), 'No se encontró la carpeta de casos detallados.');
assert(isfile(rutaMetricas), 'No se encontró metricas_por_imagen.csv.');

T = readtable(rutaMetricas, 'TextType', 'string');
casos = dir(carpetaCasos);
casos = casos([casos.isdir] & ~startsWith({casos.name}, '.'));

archivos = {
    '01_original.png'
    '02_gris_suavizado.png'
    '03_magnitud_sobel.png'
    '04_bordes_canny.png'
    '05_gradiente_morfologico.png'
    '06_tophat_bottomhat.png'
    '07_mapa_distancia_hog.png'
    '08_ground_truth.png'
    '09_prediccion.png'
    '10_comparacion.png'};

for i = 1:numel(casos)
    id = string(casos(i).name);
    fila = find(T.imagen == id, 1);
    assert(~isempty(fila), 'No hay métricas para %s.', id);

    realPct = T.pr(fila);
    estimadoPct = T.pp(fila);
    errorPct = abs(realPct - estimadoPct);
    titulos = {
        '1. Original RGB'
        '2. Gris + suavizado'
        '3. Magnitud Sobel'
        '4. Bordes Canny'
        '5. Gradiente morfológico'
        '6. Top-hat / bottom-hat'
        '7. Distancia HOG'
        sprintf('8. Ground truth\nReal: %.1f%% ocupado', realPct)
        sprintf('9. Predicción HOG\nEstimado: %.1f%% ocupado', estimadoPct)
        sprintf('10. Comparación\nError: %.1f pp', errorPct)};

    fig = figure('Visible', 'off', 'Color', 'w', ...
        'Position', [50 50 2200 1000]);
    tl = tiledlayout(fig, 2, 5, 'TileSpacing', 'loose', 'Padding', 'loose');
    tl.Units = 'normalized';
    tl.Position = [0.015 0.015 0.97 0.91];
    encabezado = sprintf(['Caso %s  |  Precisión %.3f  |  Recall %.3f  |  ' ...
        'F1 %.3f  |  Exactitud %.3f'], id, T.P(fila), T.R(fila), ...
        T.F1(fila), T.acc(fila));
    annotation(fig, 'textbox', [0.02 0.945 0.96 0.04], 'String', encabezado, ...
        'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', ...
        'EdgeColor', 'none', 'FontSize', 16, 'FontWeight', 'bold', ...
        'Interpreter', 'none');

    for k = 1:numel(archivos)
        ruta = fullfile(carpetaCasos, char(id), archivos{k});
        assert(isfile(ruta), 'Falta la imagen %s.', ruta);
        ax = nexttile(tl);
        imshow(imread(ruta), 'Parent', ax, 'InitialMagnification', 'fit');
        title(ax, titulos{k}, 'FontSize', 11, 'FontWeight', 'bold', ...
            'Interpreter', 'none');
        axis(ax, 'image');
        axis(ax, 'off');
    end

    salida = fullfile(carpetaComparacion, ['mosaico_' char(id) '.png']);
    exportgraphics(fig, salida, 'Resolution', 140, 'BackgroundColor', 'white');
    close(fig);
    fprintf('Mosaico actualizado: %s\n', salida);
end

% Resumen: usa el panel comparativo final de cada caso.
fig = figure('Visible', 'off', 'Color', 'w', 'Position', [50 50 2000 1800]);
tl = tiledlayout(fig, 3, 4, 'TileSpacing', 'loose', 'Padding', 'loose');
tl.Units = 'normalized';
tl.Position = [0.02 0.015 0.96 0.92];
annotation(fig, 'textbox', [0.02 0.95 0.96 0.035], ...
    'String', 'Resumen de los 12 casos evaluados', ...
    'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', ...
    'EdgeColor', 'none', 'FontSize', 18, 'FontWeight', 'bold');
for i = 1:numel(casos)
    id = string(casos(i).name);
    fila = find(T.imagen == id, 1);
    ax = nexttile(tl);
    ruta = fullfile(carpetaCasos, char(id), '10_comparacion.png');
    imshow(imread(ruta), 'Parent', ax, 'InitialMagnification', 'fit');
    title(ax, sprintf('%s\nReal %.1f%% | Est. %.1f%% | Error %.1f pp', ...
        id, T.pr(fila), T.pp(fila), abs(T.pr(fila) - T.pp(fila))), ...
        'FontSize', 10, 'FontWeight', 'bold', 'Interpreter', 'none');
    axis(ax, 'image');
    axis(ax, 'off');
end
exportgraphics(fig, fullfile(carpetaComparacion, ...
    'mosaico_resumen_12_imagenes.png'), 'Resolution', 140, ...
    'BackgroundColor', 'white');
close(fig);

fprintf('Listo: %d mosaicos individuales y un resumen.\n', numel(casos));
