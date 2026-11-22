function M = mascaraZonaInteres(cajas, H, W)
%MASCARAZONAINTERES Zona de interés = envolvente convexa de los cajones de la cámara
%   (equivale a la ROI que define PKLot; también se puede dibujar a mano con roipoly).
x = [cajas(:,1); cajas(:,1) + cajas(:,3); cajas(:,1);              cajas(:,1) + cajas(:,3)];
y = [cajas(:,2); cajas(:,2);              cajas(:,2) + cajas(:,4); cajas(:,2) + cajas(:,4)];
k = convhull(x, y);
M = poly2mask(x(k) + 0.5, y(k) + 0.5, H, W);
end
