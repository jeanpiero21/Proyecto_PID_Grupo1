function [lineas, bw] = lineasPintadas(fondo)
%LINEASPINTADAS Líneas blancas pintadas del estacionamiento sobre la imagen de fondo:
%   top-hat blanco (resalta estructuras claras y delgadas) -> Otsu -> limpieza -> Hough.
th = imtophat(fondo, strel('square', 9));
bw = imbinarize(th, graythresh(th));
bw = bwareaopen(bw, 8);
[Hh, theta, rho] = hough(bw);
picos = houghpeaks(Hh, 80, 'Threshold', ceil(0.2 * max(Hh(:))));
if isempty(picos)
    lineas = struct('point1', {}, 'point2', {}, 'theta', {}, 'rho', {});
else
    lineas = houghlines(bw, theta, rho, picos, 'FillGap', 3, 'MinLength', 12);
end
end
