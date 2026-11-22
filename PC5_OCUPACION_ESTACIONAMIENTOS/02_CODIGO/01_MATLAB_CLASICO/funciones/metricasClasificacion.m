function M = metricasClasificacion(yReal, yPred)
%METRICASCLASIFICACION Métricas por cajón con "ocupado" como clase positiva.
%   Precisión = TP/(TP+FP): de los cajones que dije ocupados, cuántos lo estaban.
%   Recall    = TP/(TP+FN): de los cajones realmente ocupados, cuántos detecté.
%   Especificidad (= recall de "libre") = TN/(TN+FP).
%   Precisión de "libre" = TN/(TN+FN): si digo libre, qué tan seguro es (lo que le importa a un conductor).
%   Kappa de Cohen y MCC: acuerdo corregido por azar (0 = azar, 1 = perfecto).
yReal = logical(yReal(:)); yPred = logical(yPred(:));
TP = nnz( yPred &  yReal);   FP = nnz( yPred & ~yReal);
FN = nnz(~yPred &  yReal);   TN = nnz(~yPred & ~yReal);
n = max(TP + FP + FN + TN, 1);
M.TP = TP; M.FP = FP; M.FN = FN; M.TN = TN;
M.precision      = TP / max(TP + FP, 1);
M.recall         = TP / max(TP + FN, 1);
M.f1             = 2*M.precision*M.recall / max(M.precision + M.recall, eps);
M.exactitud      = (TP + TN) / n;
M.especificidad  = TN / max(TN + FP, 1);
M.precisionLibre = TN / max(TN + FN, 1);
M.exactitudBal   = (M.recall + M.especificidad) / 2;
pe = ((TP + FP)*(TP + FN) + (FN + TN)*(FP + TN)) / n^2;
M.kappa = (M.exactitud - pe) / max(1 - pe, eps);
M.mcc = (TP*TN - FP*FN) / max(sqrt((TP + FP)*(TP + FN)*(TN + FP)*(TN + FN)), eps);
end
