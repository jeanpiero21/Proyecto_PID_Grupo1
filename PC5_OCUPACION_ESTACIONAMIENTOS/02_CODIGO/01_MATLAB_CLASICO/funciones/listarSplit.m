function lista = listarSplit(rutaDataset, split, maxN)
%LISTARSPLIT Rutas de imágenes y etiquetas de un split (train / valid / test).
%   lista(i).img, lista(i).lbl, lista(i).nombre
if nargin < 3, maxN = Inf; end
dirImg = fullfile(rutaDataset, split, 'images');
dirLbl = fullfile(rutaDataset, split, 'labels');
if ~isfolder(dirImg)
    error('No encuentro %s. Revisa cfg.rutaDataset en config.m', dirImg);
end
d = dir(fullfile(dirImg, '*.jpg'));
[~, orden] = sort({d.name});
d = d(orden);
n = min(numel(d), maxN);
if n < numel(d)                         % submuestreo uniforme
    d = d(round(linspace(1, numel(d), n)));
end
lista = struct('img', cell(n, 1), 'lbl', cell(n, 1), 'nombre', cell(n, 1));
for i = 1:n
    [~, base] = fileparts(d(i).name);
    lista(i).img    = fullfile(dirImg, d(i).name);
    lista(i).lbl    = fullfile(dirLbl, [base '.txt']);
    lista(i).nombre = base;
end
end
