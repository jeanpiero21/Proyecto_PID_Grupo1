function [mc, mo, pctReal, pctPred] = metricasRegla(E, pred, mascaraImg)
%METRICASREGLA Métricas por cajón (mc) y del % de ocupación por imagen (mo) de una regla.
%   mascaraImg (opcional): lógico por imagen evaluada, para calcular sobre un subconjunto
%   (una cámara, una franja horaria, etc.).
nImg = numel(E.imgLista);
if nargin < 3 || isempty(mascaraImg), mascaraImg = true(nImg, 1); end
m = mascaraImg(E.img);
mc = metricasClasificacion(E.y(m), pred(m));
cnt = accumarray(E.img(m), 1, [nImg 1]);
pr  = accumarray(E.img(m), double(E.y(m)), [nImg 1]);
pp  = accumarray(E.img(m), double(pred(m)), [nImg 1]);
ok = cnt > 0;
pctReal = 100 * pr(ok) ./ cnt(ok);
pctPred = 100 * pp(ok) ./ cnt(ok);
mo = metricasOcupacion(pctReal, pctPred);
end
