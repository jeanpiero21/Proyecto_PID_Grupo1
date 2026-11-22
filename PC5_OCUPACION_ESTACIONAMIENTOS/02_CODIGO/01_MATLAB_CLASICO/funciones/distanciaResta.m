function d = distanciaResta(P, R, T, tam)
%DISTANCIARESTA Resta con el cajón vacío + umbral + apertura (S9-S10).
%   1) Se resta el parche actual y la referencia vacía, compensando el brillo medio.
%   2) Píxel "cambiado" si |diferencia| > T (T = Otsu, calculado en la calibración).
%   3) Apertura morfológica para quitar píxeles sueltos (ruido).
%   4) d = fracción de píxeles cambiados (mínimo sobre las K referencias).
%   P : N x L parches de gris,  R : K x L,  tam = [filas columnas] del parche.
P = double(P); R = double(R);
A = P - mean(P, 2);
B = R - mean(R, 2);
se = strel('diamond', 1);
n = size(P, 1); K = size(R, 1);
frac = zeros(n, K);
for i = 1:n
    for k = 1:K
        bw = reshape(abs(A(i, :) - B(k, :)) > T, tam);
        bw = imopen(bw, se);
        frac(i, k) = mean(bw(:));
    end
end
d = min(frac, [], 2);
end
