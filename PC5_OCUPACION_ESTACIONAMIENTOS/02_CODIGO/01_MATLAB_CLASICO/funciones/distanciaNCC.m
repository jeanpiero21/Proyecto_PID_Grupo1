function d = distanciaNCC(parches, refs)
%DISTANCIANCC Distancia = 1 - máxima correlación cruzada normalizada (NCC) contra las referencias.
%   parches : N x L   refs : K x L   ->   d : N x 1
%   d ~ 0  : el cajón se parece a su referencia vacía  -> libre
%   d -> 1 : estructura distinta (un auto)              -> ocupado
%   La NCC es invariante a cambios de brillo y contraste globales del parche.
A = double(parches);  A = A - mean(A, 2);  A = A ./ (sqrt(sum(A.^2, 2)) + eps);
B = double(refs);     B = B - mean(B, 2);  B = B ./ (sqrt(sum(B.^2, 2)) + eps);
d = 1 - max(A * B', [], 2);
end
