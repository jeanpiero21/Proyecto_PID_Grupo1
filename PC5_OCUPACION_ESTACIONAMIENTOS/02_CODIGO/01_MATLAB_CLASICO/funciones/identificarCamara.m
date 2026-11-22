function [c, puntajes] = identificarCamara(gris, camaras, tamPlantilla)
%IDENTIFICARCAMARA Cámara cuya plantilla (imagen mediana) tiene mayor correlación 2D con la imagen.
g = imresize(gris, tamPlantilla);
puntajes = zeros(1, numel(camaras));
for k = 1:numel(camaras)
    puntajes(k) = corr2(g, camaras(k).plantilla);
end
[~, c] = max(puntajes);
end
