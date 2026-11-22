function R = referenciasPorBrillo(Pv, bv, K)
%REFERENCIASPORBRILLO K referencias de un cajón vacío, una por nivel de iluminación.
%   Pv : M x L parches del cajón cuando está vacío,  bv : M x 1 su brillo medio.
%   Se ordenan por brillo, se dividen en K grupos y se toma la mediana de cada grupo
%   (la mediana elimina sombras o personas que aparecen solo a veces).
[~, orden] = sort(bv);
n = numel(orden);
K = min(K, n);
lim = round(linspace(0, n, K + 1));
R = zeros(K, size(Pv, 2), 'single');
for k = 1:K
    sel = orden(lim(k) + 1 : lim(k + 1));
    R(k, :) = median(Pv(sel, :), 1);
end
end
