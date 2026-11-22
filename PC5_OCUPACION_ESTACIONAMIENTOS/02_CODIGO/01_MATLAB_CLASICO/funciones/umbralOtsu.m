function t = umbralOtsu(v)
%UMBRALOTSU Umbral de Otsu (graythresh, S10) para valores en cualquier rango (no usa etiquetas).
%   Se normalizan los valores a [0,1], graythresh analiza su histograma y se vuelve a la escala original.
v = double(v(isfinite(v)));
if isempty(v), t = 0; return; end
vmin = min(v); vmax = max(v);
if vmax - vmin < eps
    t = vmax; return;
end
t = vmin + graythresh((v(:) - vmin) / (vmax - vmin)) * (vmax - vmin);
end
