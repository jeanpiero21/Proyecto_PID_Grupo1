%% ========================================================================
%  OCUPACIÓN DE ESTACIONAMIENTOS (PKLot) — PROCESAMIENTO CLÁSICO DE IMÁGENES
%  Grupo 1 · PC5 · EL5313
%
%   1) Calibración por cámara fija: mapa de cajones, plantilla de la cámara,
%      referencias de cajón vacío y umbrales.
%   2) Evaluación en test: todos los indicadores para todos los cajones.
%   3) T1: comparación de TÉCNICAS para decidir ocupado / libre.
%   4) T2: comparación de TIPOS DE UMBRAL (global / cámara / cajón; Otsu / calibrado).
%   5) T4: robustez por CÁMARA y por HORA del día.
%   6) Figuras del método principal (matriz de confusión, % real vs. estimado).
%   7) Imágenes intermedias (una imagen por cámara).
%   8) T5: detección automática de cajones sin etiquetas (variantes).
%   9) (Opcional) Comparación con YOLO con las mismas métricas.
%  10) Demo sobre la misma imagen que usa probar.py.
%  (T3, preprocesamiento: script aparte comparar_preprocesamiento.m)
%
%  Requisitos: MATLAB R2020b o superior + Image Processing Toolbox.
%
%  CÓMO LEER ESTE SCRIPT:
%  Cada bloque responde una pregunta concreta. Primero se prepara el sistema,
%  después se evalúa una sola vez y finalmente se reutilizan esos datos para
%  comparar técnicas. Así evitamos procesar las mismas imágenes muchas veces.
% =========================================================================
clear; clc; close all;

% Cargamos la configuración y agregamos la carpeta de funciones auxiliares.
cfg = config();
addpath(fullfile(cfg.raiz, 'funciones'));

% Creamos las carpetas donde se guardarán tablas, gráficas y evidencias.
carpetas = {'', 'tablas', 'figuras', 'imagenes_intermedias', 'deteccion_auto_cajones'};
for k = 1:numel(carpetas)
    d = fullfile(cfg.rutaSalida, carpetas{k});
    if ~isfolder(d), mkdir(d); end
end
rutaFig = @(nombre) fullfile(cfg.rutaSalida, 'figuras', nombre);
rutaTab = @(nombre) fullfile(cfg.rutaSalida, 'tablas', nombre);
AZUL = [0.20 0.45 0.75]; NARANJA = [0.90 0.55 0.15];

%% 1) CALIBRACIÓN ---------------------------------------------------------
% La calibración guarda lo que depende de cada cámara: ubicación de cajones,
% apariencia del cajón vacío y umbrales. Si ya existe y es compatible, se reutiliza.
archivoCalib = fullfile(cfg.rutaSalida, 'calibracion.mat');
calib = [];
if isfile(archivoCalib) && ~cfg.recalibrar
    load(archivoCalib, 'calib');
    if ~isfield(calib, 'version') || calib.version ~= cfg.version || ~strcmp(calib.cfg.preproc, cfg.preproc)
        fprintf('La calibración guardada es de otra versión o preprocesamiento: se rehace.\n');
        calib = [];
    else
        fprintf('Calibración cargada de %s\n', archivoCalib);
    end
end
if isempty(calib)
    tic;
    calib = calibrarSistema(cfg);
    save(archivoCalib, 'calib');
    fprintf('Calibración lista en %.0f s\n', toc);
end
camaras = calib.camaras;
metodos = calib.metodos;
nC = numel(camaras);
nM = numel(metodos.nombre);

%% 2) EVALUACIÓN EN TEST --------------------------------------------------
% Procesamos el test una sola vez. E guarda la etiqueta real y el valor de cada
% indicador para cada cajón; las tablas siguientes trabajan sobre esos valores.
E = evaluarSplit(calib, cfg);
save(fullfile(cfg.rutaSalida, 'evaluacion.mat'), 'E');
[~, nombresVar] = filaMetricas();
colF1 = strcmp(nombresVar, 'F1');
colMAE = strcmp(nombresVar, 'MAE_pp');

%% 3) T1: COMPARACIÓN DE TÉCNICAS ------------------------------------------
% Pregunta: ¿qué descriptor separa mejor los cajones libres de los ocupados?
% Todos usan las mismas imágenes y el umbral calibrado por cajón.
res = zeros(nM, numel(nombresVar));
for m = 1:nM
    [mc, mo] = metricasRegla(E, aplicarRegla(E, calib, metodos.ind{m}, metodos.tipo{m}));
    res(m, :) = filaMetricas(mc, mo);
end
T1 = array2table(res, 'VariableNames', nombresVar);
T1 = addvars(T1, string(metodos.nombre(:)), string(metodos.semana(:)), 'Before', 1, ...
    'NewVariableNames', {'Tecnica', 'Curso'});
fprintf('\n=== T1. Técnicas para decidir ocupado/libre (umbral calibrado por cajón) ===\n');
disp(T1(:, {'Tecnica', 'Curso', 'Exactitud', 'Precision', 'Recall', 'F1', 'Kappa', 'MAE_pp', 'RMSE_pp'}));
writetable(T1, rutaTab('T1_tecnicas.csv'));

% Azul identifica técnicas vistas en el curso; naranja, técnicas adicionales.
esExtra = startsWith(metodos.semana, 'Extra');
colores = repmat(AZUL, nM, 1);
colores(esExtra, :) = repmat(NARANJA, nnz(esExtra), 1);
etiquetas = cellfun(@(a, b) sprintf('%s (%s)', a, b), metodos.nombre, metodos.semana, 'UniformOutput', false);
fig = figure('Visible', 'off', 'Color', 'w', 'Position', [100 100 1150 450]);
tl = tiledlayout(1, 2, 'TileSpacing', 'compact');
nexttile; b = barh(res(:, colF1)); b.FaceColor = 'flat'; b.CData = colores;
yticks(1:nM); yticklabels(etiquetas); set(gca, 'YDir', 'reverse'); xlim([0.5 1]);
xlabel('F1 (clase ocupado)'); grid on;
nexttile; b = barh(res(:, colMAE)); b.FaceColor = 'flat'; b.CData = colores;
yticks(1:nM); yticklabels({}); set(gca, 'YDir', 'reverse');
xlabel('MAE del % de ocupación (pp)'); grid on;
title(tl, 'T1. Comparación de técnicas  |  azul: del curso  ·  naranja: extra');
guardarFigura(fig, rutaFig('T1_comparacion_tecnicas.png'));

%% 4) T2: COMPARACIÓN DE TIPOS DE UMBRAL -----------------------------------
% Pregunta: ¿conviene un único umbral o uno adaptado a la cámara/cajón?
% También comparamos Otsu (sin etiquetas) contra calibración supervisada.
indT2 = {'hog', 'ncc', 'grad', 'resta'};
nomT2 = {'HOG', 'NCC-Sobel', 'Gradiente Sobel', 'Resta+Otsu+apertura'};
tipos = {'globOtsu', 'globCalib', 'camOtsu', 'camCalib', 'spotOtsu', 'spotCalib'};
nomTipos = {'Global (Otsu)', 'Global (calibrado)', 'Cámara (Otsu)', 'Cámara (calibrado)', 'Cajón (Otsu)', 'Cajón (calibrado)'};
F1t = zeros(numel(indT2), numel(tipos)); MAEt = F1t;
for a = 1:numel(indT2)
    for b = 1:numel(tipos)
        [mc, mo] = metricasRegla(E, aplicarRegla(E, calib, indT2{a}, tipos{b}));
        F1t(a, b) = mc.f1; MAEt(a, b) = mo.MAE;
    end
end
T2 = array2table([F1t MAEt], 'VariableNames', [strcat('F1_', tipos), strcat('MAE_', tipos)]);
T2 = addvars(T2, string(nomT2(:)), 'Before', 1, 'NewVariableNames', 'Indicador');
fprintf('\n=== T2. Tipo de umbral (F1) ===\n'); disp(T2(:, 1:numel(tipos) + 1));
writetable(T2, rutaTab('T2_tipos_umbral.csv'));
fig = figure('Visible', 'off', 'Color', 'w', 'Position', [100 100 950 420]);
bar(F1t); xticklabels(nomT2); ylabel('F1 (clase ocupado)'); ylim([0.6 1]); grid on;
legend(nomTipos, 'Location', 'southoutside', 'Orientation', 'horizontal', 'NumColumns', 3);
title('T2. Umbral global vs. por cámara vs. por cajón; Otsu (sin etiquetas) vs. calibrado');
guardarFigura(fig, rutaFig('T2_tipos_umbral.png'));

%% 5) T4: ROBUSTEZ POR CÁMARA Y POR HORA -----------------------------------
% Aquí no cambiamos el método: dividimos el test para ver en qué cámara u hora
% baja el desempeño. Esto ayuda a detectar sensibilidad a perspectiva e iluminación.
indT4 = {'hog', 'ncc', 'gradMorf', 'resta'};
nomT4 = {'HOG', 'NCC-Sobel', 'Gradiente morfológico', 'Resta+Otsu+apertura'};
franjas = [6 9; 9 12; 12 15; 15 18; 18 21];
nomFr = {'6-9 h', '9-12 h', '12-15 h', '15-18 h', '18-21 h'};
F1cam = nan(numel(indT4), nC); MAEcam = F1cam;
F1hora = nan(numel(indT4), size(franjas, 1)); MAEhora = F1hora;
for a = 1:numel(indT4)
    pred = aplicarRegla(E, calib, indT4{a}, 'spotCalib');
    for c = 1:nC
        msk = E.imgCam == c;
        if any(msk)
            [mc, mo] = metricasRegla(E, pred, msk); F1cam(a, c) = mc.f1; MAEcam(a, c) = mo.MAE;
        end
    end
    for h = 1:size(franjas, 1)
        msk = E.imgHora >= franjas(h, 1) & E.imgHora < franjas(h, 2);
        if any(msk)
            [mc, mo] = metricasRegla(E, pred, msk); F1hora(a, h) = mc.f1; MAEhora(a, h) = mo.MAE;
        end
    end
end
nomCam = matlab.lang.makeValidName({camaras.nombre});
T4a = array2table([F1cam MAEcam], 'VariableNames', [strcat('F1_', nomCam), strcat('MAE_', nomCam)]);
T4a = addvars(T4a, string(nomT4(:)), 'Before', 1, 'NewVariableNames', 'Indicador');
nomFrV = matlab.lang.makeValidName(strcat('h', strrep(nomFr, ' h', '')));
T4b = array2table([F1hora MAEhora], 'VariableNames', [strcat('F1_', nomFrV), strcat('MAE_', nomFrV)]);
T4b = addvars(T4b, string(nomT4(:)), 'Before', 1, 'NewVariableNames', 'Indicador');
fprintf('\n=== T4a. F1 y MAE por cámara ===\n'); disp(T4a);
fprintf('\n=== T4b. F1 y MAE por franja horaria ===\n'); disp(T4b);
writetable(T4a, rutaTab('T4a_por_camara.csv'));
writetable(T4b, rutaTab('T4b_por_hora.csv'));
nImgHora = arrayfun(@(h) nnz(E.imgHora >= franjas(h, 1) & E.imgHora < franjas(h, 2)), 1:size(franjas, 1));
etqHora = arrayfun(@(h) sprintf('%s (n=%d)', nomFr{h}, nImgHora(h)), 1:numel(nomFr), 'UniformOutput', false);
fig = figure('Visible', 'off', 'Color', 'w', 'Position', [100 100 1100 420]);
tl = tiledlayout(1, 2, 'TileSpacing', 'compact');
nexttile; bar(F1cam'); xticklabels({camaras.nombre}); ylabel('F1'); ylim([0.6 1]); grid on;
legend(nomT4, 'Location', 'southoutside', 'Orientation', 'horizontal', 'NumColumns', 2); title('Por cámara');
nexttile; plot(1:numel(nomFr), F1hora', '-o', 'LineWidth', 1.5); grid on; ylim([0.6 1]);
xticks(1:numel(nomFr)); xticklabels(etqHora); ylabel('F1');
legend(nomT4, 'Location', 'southoutside', 'Orientation', 'horizontal', 'NumColumns', 2); title('Por hora del día');
title(tl, 'T4. Robustez (umbral calibrado por cajón)');
guardarFigura(fig, rutaFig('T4_robustez_camara_hora.png'));

%% 6) FIGURAS DEL MÉTODO PRINCIPAL ------------------------------------------
% Resumimos el mejor método con tres vistas: confusión por cajón, porcentaje
% real frente al estimado y distribución del error por imagen.
pred1 = aplicarRegla(E, calib, metodos.ind{1}, metodos.tipo{1});
[mc1, mo1, pctReal, pctPred] = metricasRegla(E, pred1);
guardarFigura(graficarConfusion(mc1, metodos.nombre{1}), rutaFig('matriz_confusion.png'));

fig = figure('Visible', 'off', 'Color', 'w'); hold on;
for c = 1:nC
    im = E.imgCam == c;
    scatter(pctReal(im), pctPred(im), 14, 'filled', 'MarkerFaceAlpha', 0.6, 'DisplayName', camaras(c).nombre);
end
plot([0 100], [0 100], 'k--', 'DisplayName', 'ideal');
axis([0 100 0 100]); axis square; grid on; box on;
xlabel('% de ocupación real'); ylabel('% de ocupación estimado'); legend('Location', 'southeast');
title(sprintf('%s | MAE = %.2f pp | sesgo = %+.2f pp', metodos.nombre{1}, mo1.MAE, mo1.sesgo), 'FontSize', 9);
guardarFigura(fig, rutaFig('ocupacion_real_vs_estimada.png'));

fig = figure('Visible', 'off', 'Color', 'w');
histogram(pctPred - pctReal, 30);
xlabel('Error del % de ocupación (pp)'); ylabel('Nº de imágenes'); grid on;
title('Distribución del error (método principal)');
guardarFigura(fig, rutaFig('histograma_error_ocupacion.png'));

%% 7) IMÁGENES INTERMEDIAS (una imagen de test por cámara) -----------------
% Elegimos, por cámara, una escena cercana al 50 % de ocupación. Es más útil
% visualmente que mostrar únicamente estacionamientos vacíos o llenos.
for c = 1:nC
    cand = find(E.imgCam == c);
    if isempty(cand), continue; end
    [~, k] = min(abs(pctReal(cand) - 50));      % una con ocupación cercana al 50 %
    i = E.imgLista(cand(k));
    I = imread(E.lista(i).img);
    R = analizarImagen(I, calib, cfg);
    guardarIntermedias(I, R, calib, cfg, ...
        fullfile(cfg.rutaSalida, 'imagenes_intermedias', camaras(c).nombre), camaras(c).nombre);
end
fprintf('\nImágenes intermedias guardadas en %s\n', fullfile(cfg.rutaSalida, 'imagenes_intermedias'));

%% 8) T5: DETECCIÓN AUTOMÁTICA DE CAJONES (sin etiquetas) ------------------
% Esta parte es exploratoria: intenta encontrar los cajones sin usar el mapa fijo.
% Comparamos componentes conexos y watershed contra los cajones reales.
fprintf('\nDetección automática de cajones (fondo mediano + actividad + Otsu + morfología + watershed)...\n');
filasA = cell(0, 2); resA = zeros(0, 7);
for c = 1:nC
    cam = camaras(c);
    nA = min(cfg.auto.maxImgs, numel(cam.rutas));
    rutas = cam.rutas(round(linspace(1, numel(cam.rutas), nA)));
    roi = mascaraZonaInteres(cam.cajas, calib.H, calib.W);
    [variantes, inter] = detectarCajonesAuto(rutas, roi, cfg);
    for v = 1:numel(variantes)
        mCt = metricasDeteccionCentro(variantes(v).centros, cam.cajas, cfg.factorROI/2);
        mI  = metricasDeteccion(variantes(v).cajas, cam.cajas, cfg.auto.iou);
        filasA(end + 1, :) = {cam.nombre, variantes(v).nombre};                                   %#ok<SAGROW>
        resA(end + 1, :) = [size(cam.cajas, 1) size(variantes(v).centros, 1) ...
            mCt.precision mCt.recall mCt.f1 mI.precision mI.recall];                             %#ok<SAGROW>
    end
    guardarDeteccionAuto(inter, variantes, cam.cajas, fullfile(cfg.rutaSalida, 'deteccion_auto_cajones'), cam.nombre);
end
T5 = array2table(resA, 'VariableNames', {'CajonesReales', 'Regiones', 'P_centro', 'R_centro', 'F1_centro', 'P_IoU', 'R_IoU'});
T5 = addvars(T5, string(filasA(:, 1)), string(filasA(:, 2)), 'Before', 1, 'NewVariableNames', {'Camara', 'Variante'});
fprintf('=== T5. Detección automática de cajones ===\n'); disp(T5);
writetable(T5, rutaTab('T5_deteccion_cajones.csv'));

%% 9) (OPCIONAL) COMPARACIÓN CON YOLO --------------------------------------
% Solo se ejecuta si existen archivos de predicción. Las predicciones se llevan
% al mismo formato de métricas para no comparar números que miden tareas distintas.
if isfolder(cfg.rutaPredYOLO)
    ry = evaluarYOLO(calib, cfg);
    fprintf('\n=== YOLO (%d imágenes, %d sin predicción) ===\n', ry.nImagenes, ry.nSinPrediccion);
    fprintf('Detección de cajones (IoU >= %.1f): P = %.3f  R = %.3f  F1 = %.3f\n', ...
        cfg.iouDeteccion, ry.det.precision, ry.det.recall, ry.det.f1);
    fprintf('  clase libre  : P = %.3f  R = %.3f\n', ry.libre.precision, ry.libre.recall);
    fprintf('  clase ocupado: P = %.3f  R = %.3f\n', ry.ocupado.precision, ry.ocupado.recall);
    fprintf('%% de ocupación "crudo" (como probar.py): MAE = %.2f pp\n', ry.ocupCrudo.MAE);
    TY = array2table(filaMetricas(ry.hibrido, ry.ocupHibrido), 'VariableNames', nombresVar);
    TY = addvars(TY, "YOLOv8 + mapa fijo (híbrido)", "Deep learning", 'Before', 1, ...
        'NewVariableNames', {'Tecnica', 'Curso'});
    T1y = [T1; TY];
    fprintf('\n=== Clásico vs. YOLO (mismas métricas) ===\n');
    disp(T1y(:, {'Tecnica', 'Curso', 'Exactitud', 'Precision', 'Recall', 'F1', 'Kappa', 'MAE_pp'}));
    writetable(T1y, rutaTab('T6_clasico_vs_yolo.csv'));
else
    fprintf('\n(Sin predicciones de YOLO en %s: corre exportar_predicciones_yolo.py para comparar.)\n', cfg.rutaPredYOLO);
end

%% 10) DEMO: la misma imagen que usa probar.py -------------------------------
% Cerramos con una escena fácil de mostrar en la exposición: cajas verdes para
% libres, rojas para ocupados y el porcentaje total en el título.
rutaDemo = fullfile(cfg.rutaDataset, cfg.splitEval, 'images', cfg.imagenDemo);
if ~isfile(rutaDemo), rutaDemo = E.lista(1).img; end
I = imread(rutaDemo);
R = analizarImagen(I, calib, cfg);
cam = camaras(R.camara);
titulo = sprintf('%s | Total: %d | Libres: %d | Ocupados: %d | Ocupación: %.1f%%', ...
    cam.nombre, R.nTotal, R.nTotal - R.nOcupados, R.nOcupados, R.porcentaje);
fprintf('\nDemo: %s\n', titulo);
fig = dibujarCajones(I, cam.cajas, R.ocupado, cfg.factorROI, titulo);
try
    exportgraphics(fig, fullfile(cfg.rutaSalida, 'resultado_demo.png'), 'Resolution', 150);
catch
    saveas(fig, fullfile(cfg.rutaSalida, 'resultado_demo.png'));
end
set(fig, 'Visible', 'on');
fprintf('Listo. Tablas en %s y figuras en %s\n', fullfile(cfg.rutaSalida, 'tablas'), fullfile(cfg.rutaSalida, 'figuras'));
