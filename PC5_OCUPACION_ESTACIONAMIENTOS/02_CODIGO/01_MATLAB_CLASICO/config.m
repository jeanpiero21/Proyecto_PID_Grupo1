function cfg = config()
%CONFIG Rutas y parámetros del proyecto. Edita aquí, no dentro de las funciones.
%   Si cambias algún parámetro de las secciones "Preprocesamiento" o "Cajón", pon
%   cfg.recalibrar = true (o borra resultados/calibracion.mat) para rehacer la calibración.

raiz = fileparts(mfilename('fullpath'));            % ...\PROYECTO_SEGMENTACION\codigo_matlab
cfg.raiz        = raiz;
cfg.rutaDataset = fullfile(raiz, '..', '..', 'pid_2_pklot');   % carpeta con train / valid / test
% Las salidas del metodo clasico quedan separadas de YOLO en la entrega.
cfg.rutaSalida  = fullfile(raiz, '..', '..', '04_RESULTADOS', '01_MATLAB_CLASICO');
cfg.rutaComparacion = fullfile(raiz, '..', '..', '04_RESULTADOS', '03_COMPARACION');
cfg.version     = 2;          % versión del formato de calibración

cfg.splitCalib   = 'valid';   % imágenes etiquetadas para calibrar (mapa, referencias, umbrales)
cfg.splitEval    = 'test';    % imágenes para medir el desempeño
cfg.maxImgsCalib = Inf;       % p.ej. 600 para calibrar más rápido
cfg.recalibrar   = false;     % true = rehacer la calibración aunque exista calibracion.mat

% ---------------- Preprocesamiento (S3) ----------------
cfg.preproc = 'gauss';        % 'gauss' | 'ninguno' | 'mediana' | 'histeq'  (scripts_auxiliares/comparar_preprocesamiento.m prueba todos)

% ---------------- Cajón ----------------
cfg.factorROI = 0.6;          % se analiza el 60 % central de cada caja (las cajas se solapan por la perspectiva)
cfg.tamParche = [24 16];      % [filas columnas] del parche que se compara con el vacío (NCC y resta)
cfg.tamHOG    = [48 32];      % tamaño del parche para el HOG (múltiplo de 8: celdas de 8x8)
cfg.binsHist  = 32;           % nº de bins del histograma de cada cajón
cfg.K         = 3;            % nº de referencias de "cajón vacío" por cajón (una por nivel de iluminación)

% ---------------- Identificación de cámara ----------------
cfg.tamPlantilla     = [64 64];
cfg.maxImgsPlantilla = 60;
cfg.tolLayout        = 0.005;  % tolerancia (coordenadas normalizadas) para reconocer el layout de etiquetas

% ---------------- Detección automática de cajones (exploratoria) ----------------
cfg.auto.maxImgs       = 200;          % imágenes usadas para el fondo y el mapa de actividad
cfg.auto.umbralDif     = 30/255;       % diferencia con el fondo para contar "cambio" en un píxel
cfg.auto.sigma         = 3;            % suavizado del mapa de actividad
cfg.auto.hLista        = [0.02 0.04];  % alturas de los h-máximos (marcadores del watershed) que se comparan
cfg.auto.radioApertura = 2;            % apertura morfológica (disco)
cfg.auto.areaMinRel    = 0.4;          % descarta regiones con área < 0.4 * mediana
cfg.auto.iou           = 0.3;          % IoU mínima para contar un cajón detectado como correcto

% ---------------- Comparación con YOLO (opcional) ----------------
cfg.rutaPredYOLO = fullfile(raiz, '..', '..', '04_RESULTADOS', ...
    '02_YOLO', 'PREDICCIONES_TEST');  % .txt de scripts_auxiliares/exportar_predicciones_yolo.py
cfg.iouDeteccion = 0.5;

% ---------------- Etiquetas erróneas detectadas en test ----------------
% En estas imágenes de PUCPR el estacionamiento está lleno o a medias, pero la etiqueta
% marca solo 1-3 % ocupado (error del dataset, verificado a la vista). Con true se excluyen
% de la evaluación; reporta ambas versiones en el informe.
cfg.excluirMalEtiquetadas = false;
cfg.imagenesExcluir = {'2012-10-30_14_17_16', '2012-11-06_13_43_31', '2012-11-06_14_13_33', ...
    '2012-11-06_16_53_40', '2012-11-06_18_38_46', '2012-11-06_19_18_48', '2012-11-06_19_43_49', ...
    '2012-11-07_10_09_27', '2012-11-07_11_44_32', '2012-11-07_12_59_36', '2012-11-07_13_19_38', ...
    '2012-11-07_13_34_38', '2012-11-07_14_29_41', '2012-11-07_14_59_42', '2012-11-07_19_39_55'};

% Imagen de la demo final (la misma que usa scripts_auxiliares/probar.py con YOLO)
cfg.imagenDemo = '2013-04-13_15_45_10_jpg.rf.3be1e71f3af841bc5e5e346118ceac52.jpg';
end
