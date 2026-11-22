function v = hogPropio(p)
%HOGPROPIO Histograma de Gradientes Orientados (S11) implementado paso a paso.
%   1) Gradiente de Sobel (Gx, Gy) -> magnitud y orientación sin signo (0-180°).
%   2) Celdas de 8x8 píxeles: histograma de 9 orientaciones (20° cada una),
%      donde cada píxel vota con su magnitud.
%   3) Normalización L2 de cada celda (robustez a la iluminación) y del vector final.
%   p debe tener filas y columnas múltiplos de 8 (p.ej. 48x32 -> 6x4 celdas -> 216 valores).
[Gx, Gy] = imgradientxy(p, 'sobel');
mag = hypot(Gx, Gy);
ang = mod(atan2d(Gy, Gx), 180);
bin = min(floor(ang / 20), 8) + 1;
[H, W] = size(p);
v = zeros(1, (H/8) * (W/8) * 9);
k = 0;
for i = 1:8:H
    for j = 1:8:W
        b = bin(i:i+7, j:j+7);
        m = mag(i:i+7, j:j+7);
        h = accumarray(b(:), m(:), [9 1])';
        v(k+1:k+9) = h / (norm(h) + 1e-6);
        k = k + 9;
    end
end
v = v / (norm(v) + 1e-6);
end
