function c = camaraDesdeEtiquetas(nrm, camaras, tol)
%CAMARADESDEETIQUETAS Cámara cuyo layout de cajones coincide con el de una etiqueta (0 si ninguna).
%   Solo se usa para agrupar en la calibración y para verificar la identificación en la evaluación.
c = 0;
a = sortrows(nrm, [2 1]);
for k = 1:numel(camaras)
    b = sortrows(camaras(k).norm, [2 1]);
    if size(a, 1) == size(b, 1) && max(abs(a(:) - b(:))) < tol
        c = k; return;
    end
end
end
