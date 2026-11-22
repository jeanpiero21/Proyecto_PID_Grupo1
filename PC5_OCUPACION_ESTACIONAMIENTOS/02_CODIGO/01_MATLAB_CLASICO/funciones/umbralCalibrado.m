function t = umbralCalibrado(v, y)
%UMBRALCALIBRADO Umbral t de la regla "v > t => ocupado" que maximiza la exactitud
%   en las imágenes de calibración (y: 0 = libre, 1 = ocupado).
v = v(:); y = y(:) == 1;
vs = sort(v);
n = numel(vs);
cand = unique(vs(round(linspace(0.02, 0.98, 97) * (n - 1)) + 1));
acc = zeros(numel(cand), 1);
for i = 1:numel(cand)
    acc(i) = mean((v > cand(i)) == y);
end
[~, k] = max(acc);
t = cand(k);
end
