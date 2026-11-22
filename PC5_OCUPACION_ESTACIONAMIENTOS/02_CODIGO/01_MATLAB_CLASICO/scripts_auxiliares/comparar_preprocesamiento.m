%% T3: COMPARACIÓN DE PREPROCESAMIENTO (S3)
%  Sin filtro / gaussiano 5x5 / mediana 3x3 / ecualización de histograma.
%  Para cada opción se recalibra y se evalúa en test con los mismos indicadores.
%  Tarda unas 4 veces lo que tarda la calibración de main.m.
clear; clc; close all;
carpetaScript = fileparts(mfilename('fullpath'));
addpath(fileparts(carpetaScript));
cfg = config();
addpath(fullfile(cfg.raiz, 'funciones'));
carpetaTab = fullfile(cfg.rutaSalida, 'METRICAS');
carpetaFig = fullfile(cfg.rutaSalida, 'GRAFICAS');
if ~isfolder(carpetaTab), mkdir(carpetaTab); end
if ~isfolder(carpetaFig), mkdir(carpetaFig); end

modos    = {'ninguno', 'gauss', 'mediana', 'histeq'};
nomModos = {'Sin filtro', 'Gaussiano 5x5', 'Mediana 3x3', 'Ecualización (histeq)'};
inds     = {'hog', 'ncc', 'grad', 'resta'};
nomInds  = {'HOG', 'NCC-Sobel', 'Gradiente Sobel', 'Resta+Otsu+apertura'};

F1 = zeros(numel(inds), numel(modos)); MAE = F1;
for p = 1:numel(modos)
    fprintf('\n##### Preprocesamiento: %s #####\n', nomModos{p});
    cfgP = cfg;
    cfgP.preproc = modos{p};
    calibP = calibrarSistema(cfgP);
    E = evaluarSplit(calibP, cfgP);
    for a = 1:numel(inds)
        [mc, mo] = metricasRegla(E, aplicarRegla(E, calibP, inds{a}, 'spotCalib'));
        F1(a, p) = mc.f1;
        MAE(a, p) = mo.MAE;
    end
end

T3 = array2table([F1 MAE], 'VariableNames', [strcat('F1_', modos), strcat('MAE_', modos)]);
T3 = addvars(T3, string(nomInds(:)), 'Before', 1, 'NewVariableNames', 'Indicador');
fprintf('\n=== T3. Preprocesamiento (umbral calibrado por cajón) ===\n'); disp(T3);
writetable(T3, fullfile(carpetaTab, 'T3_preprocesamiento.csv'));

fig = figure('Visible', 'off', 'Color', 'w', 'Position', [100 100 900 420]);
bar(F1); xticklabels(nomInds); ylabel('F1 (clase ocupado)'); ylim([0.6 1]); grid on;
legend(nomModos, 'Location', 'southoutside', 'Orientation', 'horizontal');
title('T3. Efecto del preprocesamiento');
guardarFigura(fig, fullfile(carpetaFig, 'T3_preprocesamiento.png'));
