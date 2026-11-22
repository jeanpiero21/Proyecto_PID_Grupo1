function M = metricasOcupacion(pctReal, pctPred)
%METRICASOCUPACION Error del % de ocupación por imagen, en puntos porcentuales (pp).
%   MAE, RMSE, sesgo (> 0 = sobreestima), error máximo, fracción de imágenes con
%   error <= 5 pp y <= 10 pp, y correlación de Pearson entre % real y % estimado.
e = pctPred(:) - pctReal(:);
M.MAE      = mean(abs(e));
M.RMSE     = sqrt(mean(e.^2));
M.sesgo    = mean(e);
M.errMax   = max(abs(e));
M.dentro5  = mean(abs(e) <= 5);
M.dentro10 = mean(abs(e) <= 10);
if numel(e) >= 2
    C = corrcoef(pctReal(:), pctPred(:));
    M.r = C(1, 2);
else
    M.r = NaN;
end
end
