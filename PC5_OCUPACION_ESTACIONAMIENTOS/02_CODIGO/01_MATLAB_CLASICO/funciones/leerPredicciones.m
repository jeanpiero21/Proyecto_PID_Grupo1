function [clase, cajas, conf] = leerPredicciones(rutaTxt, W, H)
%LEERPREDICCIONES Lee predicciones YOLO exportadas: "clase xc yc w h [conf]" (normalizado).
% Devuelve la clase, la caja en píxeles y la confianza. Un archivo vacío es válido:
% simplemente significa que YOLO no encontró objetos en esa imagen.
clase = zeros(0, 1); cajas = zeros(0, 4); conf = zeros(0, 1);
txt = strtrim(fileread(rutaTxt));
if isempty(txt), return; end
lineas = splitlines(txt);
nc = numel(sscanf(lineas{1}, '%f'));
% Detectamos si cada fila trae cinco columnas o una sexta columna de confianza.
A = reshape(sscanf(txt, '%f'), nc, [])';
clase = A(:, 1);
nrm = A(:, 2:5);
% YOLO usa centro/ancho/alto normalizados; MATLAB dibuja desde la esquina superior.
cajas = [(nrm(:,1) - nrm(:,3)/2)*W, (nrm(:,2) - nrm(:,4)/2)*H, nrm(:,3)*W, nrm(:,4)*H];
if nc >= 6, conf = A(:, 6); else, conf = ones(size(clase)); end
end
