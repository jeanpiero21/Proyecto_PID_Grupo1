function [filas, cols] = recorteROI(caja, factor, H, W)
%RECORTEROI Filas y columnas (índices MATLAB) de la zona central de una caja [x y w h].
%   factor = fracción del ancho/alto que se conserva (p.ej. 0.6). Evita incluir autos vecinos,
%   porque las cajas rectangulares se solapan por la perspectiva de la cámara.
xc = caja(1) + caja(3)/2;   yc = caja(2) + caja(4)/2;
w2 = caja(3)*factor/2;      h2 = caja(4)*factor/2;
c1 = max(1, floor(xc - w2) + 1);   c2 = min(W, ceil(xc + w2));
f1 = max(1, floor(yc - h2) + 1);   f2 = min(H, ceil(yc + h2));
if c2 - c1 < 2, c2 = min(W, c1 + 2); end
if f2 - f1 < 2, f2 = min(H, f1 + 2); end
filas = f1:f2;
cols  = c1:c2;
end
