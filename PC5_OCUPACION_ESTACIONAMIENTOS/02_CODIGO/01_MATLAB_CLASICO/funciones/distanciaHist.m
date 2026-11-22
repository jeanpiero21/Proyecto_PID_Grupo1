function d = distanciaHist(P, R)
%DISTANCIAHIST 1 - máxima intersección de histogramas contra las K referencias vacías.
%   P : N x B histogramas normalizados,  R : K x B  ->  d : N x 1 (0 = histogramas iguales)
P = double(P); R = double(R);
inter = zeros(size(P, 1), size(R, 1));
for k = 1:size(R, 1)
    inter(:, k) = sum(min(P, R(k, :)), 2);
end
d = 1 - max(inter, [], 2);
end
