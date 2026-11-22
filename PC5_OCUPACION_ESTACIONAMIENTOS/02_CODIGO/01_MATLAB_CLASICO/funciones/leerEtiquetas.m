function [clase, cajas, nrm] = leerEtiquetas(rutaTxt, W, H)
%LEERETIQUETAS Lee una etiqueta en formato YOLO: "clase xc yc w h" (normalizado).
%   clase : Nx1  (0 = libre, 1 = ocupado)
%   cajas : Nx4  [x y w h] en píxeles; (x, y) = esquina superior izquierda con origen 0
%   nrm   : Nx4  [xc yc w h] normalizado (tal como está en el .txt)
clase = zeros(0, 1); cajas = zeros(0, 4); nrm = zeros(0, 4);
if ~isfile(rutaTxt), return; end
fid = fopen(rutaTxt, 'r');
C = textscan(fid, '%f %f %f %f %f');
fclose(fid);
n = min(cellfun(@numel, C));
if n == 0, return; end
clase = C{1}(1:n);
nrm   = [C{2}(1:n) C{3}(1:n) C{4}(1:n) C{5}(1:n)];
cajas = [(nrm(:,1) - nrm(:,3)/2)*W, (nrm(:,2) - nrm(:,4)/2)*H, nrm(:,3)*W, nrm(:,4)*H];
end
