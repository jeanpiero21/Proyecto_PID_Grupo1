function P = preprocesar(I, modo)
%PREPROCESAR Gris, filtrado previo y mapas base de la imagen completa.
%   modo: 'gauss' (por defecto) | 'ninguno' | 'mediana' | 'histeq'
%   P.gris     : gris en [0,1]
%   P.suave    : gris tras el preprocesamiento elegido                      (S3)
%   P.sobel    : magnitud del gradiente de Sobel                            (S3, S10)
%   P.bordes   : bordes de Canny                                            (S3, S10)
%   P.gradMorf : gradiente morfológico = dilatación - erosión               (S9)
%   P.topHat   : top-hat + bottom-hat (detalles claros y oscuros pequeños)  (S9)
%   P.sat      : saturación del modelo HSV                                  (S7)
if nargin < 2, modo = 'gauss'; end
if size(I, 3) == 3
    P.gris = im2double(rgb2gray(I));
    hsv = rgb2hsv(I);
    P.sat = hsv(:, :, 2);
else
    P.gris = im2double(I);
    P.sat = zeros(size(P.gris));
end
switch modo
    case 'gauss',   P.suave = imfilter(P.gris, fspecial('gaussian', 5, 0.8), 'replicate');
    case 'mediana', P.suave = medfilt2(P.gris, [3 3], 'symmetric');
    case 'histeq',  P.suave = histeq(P.gris);
    otherwise,      P.suave = P.gris;
end
P.sobel  = imgradient(P.suave, 'sobel');
P.bordes = edge(P.suave, 'canny');
se = strel('square', 3);
P.gradMorf = imdilate(P.suave, se) - imerode(P.suave, se);
sd = strel('disk', 5);
P.topHat = imtophat(P.suave, sd) + imbothat(P.suave, sd);
end
