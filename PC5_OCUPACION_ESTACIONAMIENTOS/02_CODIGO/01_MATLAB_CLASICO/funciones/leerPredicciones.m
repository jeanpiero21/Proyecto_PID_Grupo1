function [clase, cajas, conf] = leerPredicciones(rutaTxt, W, H)
%LEERPREDICCIONES Lee predicciones YOLO exportadas: "clase xc yc w h [conf]" (normalizado).
clase = zeros(0, 1); cajas = zeros(0, 4); conf = zeros(0, 1);
txt = strtrim(fileread(rutaTxt));
if isempty(txt), return; end
lineas = splitlines(txt);
nc = numel(sscanf(lineas{1}, '%f'));
A = reshape(sscanf(txt, '%f'), nc, [])';
clase = A(:, 1);
nrm = A(:, 2:5);
cajas = [(nrm(:,1) - nrm(:,3)/2)*W, (nrm(:,2) - nrm(:,4)/2)*H, nrm(:,3)*W, nrm(:,4)*H];
if nc >= 6, conf = A(:, 6); else, conf = ones(size(clase)); end
end
