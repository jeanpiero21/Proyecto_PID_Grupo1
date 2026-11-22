function M = metricasDeteccionCentro(centros, cajasReal, tolRel)
%METRICASDETECCIONCENTRO Detección correcta si el centro detectado cae en la zona central del
%   cajón real (|dx| <= tolRel*w y |dy| <= tolRel*h), con emparejamiento 1 a 1.
%   Es más justo que la IoU cuando las cajas reales son rectángulos inflados por la perspectiva.
nP = size(centros, 1); nR = size(cajasReal, 1);
M.TP = 0;
if nP > 0 && nR > 0
    cR = cajasReal(:, 1:2) + cajasReal(:, 3:4)/2;
    dx = abs(centros(:, 1) - cR(:, 1)') ./ (tolRel * cajasReal(:, 3)');
    dy = abs(centros(:, 2) - cR(:, 2)') ./ (tolRel * cajasReal(:, 4)');
    costo = max(dx, dy);
    costo(costo > 1) = 10;
    pares = matchpairs(costo, 0.5 + 1e-6);
    M.TP = nnz(costo(sub2ind(size(costo), pares(:, 1), pares(:, 2))) <= 1);
end
M.FP = nP - M.TP;
M.FN = nR - M.TP;
M.precision = M.TP / max(nP, 1);
M.recall    = M.TP / max(nR, 1);
M.f1        = 2*M.precision*M.recall / max(M.precision + M.recall, eps);
end
