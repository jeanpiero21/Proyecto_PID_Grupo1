function M = metricasDeteccion(cajasPred, cajasReal, umbralIoU)
%METRICASDETECCION Precisión y recall de una detección de cajas.
%   Empareja 1 a 1 (algoritmo húngaro, matchpairs) maximizando la IoU:
%   TP = pares con IoU >= umbral, FP = detecciones sin pareja, FN = cajas reales sin pareja.
nP = size(cajasPred, 1); nR = size(cajasReal, 1);
M.TP = 0; M.pares = zeros(0, 2); M.iou = zeros(0, 1);
if nP > 0 && nR > 0
    IoU = iouCajas(cajasPred, cajasReal);
    costo = 1 - IoU;
    costo(IoU < umbralIoU) = 10;                        % pares no permitidos
    pares = matchpairs(costo, (1 - umbralIoU)/2 + 1e-6);
    iouPares = IoU(sub2ind(size(IoU), pares(:, 1), pares(:, 2)));
    ok = iouPares >= umbralIoU;
    M.pares = pares(ok, :);
    M.iou = iouPares(ok);
    M.TP = nnz(ok);
end
M.FP = nP - M.TP;
M.FN = nR - M.TP;
M.precision = M.TP / max(nP, 1);
M.recall    = M.TP / max(nR, 1);
M.f1        = 2*M.precision*M.recall / max(M.precision + M.recall, eps);
end
