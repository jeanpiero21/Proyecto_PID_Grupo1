function lista = listarSplit(rutaDataset, split, maxN)
%LISTARSPLIT Rutas de imágenes y etiquetas de un split (train / valid / test).
%   lista(i).img, lista(i).lbl, lista(i).nombre
% Esta función no abre las imágenes: solo arma una lista ordenada de pares.
if nargin < 3, maxN = Inf; end
dirImg = fullfile(rutaDataset, split, 'images');
dirLbl = fullfile(rutaDataset, split, 'labels');
if ~isfolder(dirImg)
    error('No encuentro %s. Revisa cfg.rutaDataset en config.m', dirImg);
end
d = dir(fullfile(dirImg, '*.jpg'));
% Ordenar garantiza que dos ejecuciones recorran los casos en el mismo orden.
[~, orden] = sort({d.name});
d = d(orden);
n = min(numel(d), maxN);
if n < numel(d)                         % submuestreo uniforme
    % Si se pidió un límite, repartimos las muestras a lo largo de todo el split.
    d = d(round(linspace(1, numel(d), n)));
end
lista = struct('img', cell(n, 1), 'lbl', cell(n, 1), 'nombre', cell(n, 1));
% Imagen y etiqueta comparten el mismo nombre base.
for i = 1:n
    [~, base] = fileparts(d(i).name);
    lista(i).img    = fullfile(dirImg, d(i).name);
    lista(i).lbl    = fullfile(dirLbl, [base '.txt']);
    lista(i).nombre = base;
end
end
