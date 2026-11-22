function [fila, nombres] = filaMetricas(mc, mo)
%FILAMETRICAS Fila de la tabla de resultados (mismo orden para todos los métodos, incluido YOLO).
%   [~, nombres] = filaMetricas() devuelve solo los nombres de las columnas.
nombres = {'Exactitud', 'Precision', 'Recall', 'F1', 'Especificidad', 'Precision_libre', ...
           'Kappa', 'MCC', 'MAE_pp', 'RMSE_pp', 'Sesgo_pp', 'Dentro5pp', 'Dentro10pp', 'r_Pearson'};
if nargin == 0
    fila = [];
    return;
end
fila = [mc.exactitud mc.precision mc.recall mc.f1 mc.especificidad mc.precisionLibre ...
        mc.kappa mc.mcc mo.MAE mo.RMSE mo.sesgo mo.dentro5 mo.dentro10 mo.r];
end
