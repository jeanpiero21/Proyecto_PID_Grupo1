function j = emparejarConMapa(cajasImg, cajasMapa)
%EMPAREJARCONMAPA Índice del cajón del mapa que corresponde a cada caja de una etiqueta
%   (el más cercano por centro). Las filas de los .txt no siempre vienen en el mismo orden.
cI = cajasImg(:, 1:2)  + cajasImg(:, 3:4)/2;
cM = cajasMapa(:, 1:2) + cajasMapa(:, 3:4)/2;
D = abs(cI(:, 1) - cM(:, 1)') + abs(cI(:, 2) - cM(:, 2)');
[~, j] = min(D, [], 2);
end
