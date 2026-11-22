function E = evaluarSplit(calib, cfg)
%EVALUARSPLIT Analiza todas las imágenes etiquetadas de cfg.splitEval y guarda, por cajón,
%   la etiqueta real y el valor de TODOS los indicadores. Con eso se calculan después
%   las tablas comparativas (técnica, tipo de umbral, cámara, hora) sin volver a procesar.
%   E.y, E.cam, E.spot, E.img : N_cajones x 1
%   E.V.(indicador)           : N_cajones x 1
%   E.imgCam, E.imgHora, E.imgNombre, E.imgLista : por imagen evaluada
lista = listarSplit(cfg.rutaDataset, cfg.splitEval);
inds = calib.indicadores;
E.y = zeros(0, 1); E.cam = zeros(0, 1); E.spot = zeros(0, 1); E.img = zeros(0, 1);
for q = 1:numel(inds), E.V.(inds{q}) = zeros(0, 1); end
E.imgLista = zeros(0, 1); E.imgCam = zeros(0, 1); E.imgHora = zeros(0, 1); E.imgNombre = cell(0, 1);
E.nSinEtiqueta = 0; E.nExcluidas = 0; E.nCamMal = 0;
fprintf('Evaluando %d imágenes de "%s"...\n', numel(lista), cfg.splitEval);
tic;
for i = 1:numel(lista)
    if cfg.excluirMalEtiquetadas && startsWith(lista(i).nombre, cfg.imagenesExcluir)
        E.nExcluidas = E.nExcluidas + 1;                 % etiqueta errónea conocida
        continue;
    end
    [cl, cajasR, nrm] = leerEtiquetas(lista(i).lbl, calib.W, calib.H);
    if isempty(cl)
        E.nSinEtiqueta = E.nSinEtiqueta + 1;             % sin verdad de terreno
        continue;
    end
    R = analizarImagen(imread(lista(i).img), calib, cfg);
    if R.camara ~= camaraDesdeEtiquetas(nrm, calib.camaras, cfg.tolLayout)
        E.nCamMal = E.nCamMal + 1;                       % cámara mal identificada
        continue;
    end
    j = emparejarConMapa(cajasR, calib.camaras(R.camara).cajas);
    y = nan(R.nTotal, 1); y(j) = cl;
    ok = find(~isnan(y));
    k = numel(E.imgLista) + 1;
    E.y    = [E.y; y(ok)];                                 %#ok<AGROW>
    E.cam  = [E.cam; repmat(R.camara, numel(ok), 1)];      %#ok<AGROW>
    E.spot = [E.spot; ok];                                 %#ok<AGROW>
    E.img  = [E.img; repmat(k, numel(ok), 1)];             %#ok<AGROW>
    for q = 1:numel(inds)
        E.V.(inds{q}) = [E.V.(inds{q}); R.V.(inds{q})(ok)];
    end
    E.imgLista(k, 1)  = i;
    E.imgCam(k, 1)    = R.camara;
    E.imgHora(k, 1)   = str2double(lista(i).nombre(12:13));   % nombre: AAAA-MM-DD_HH_MM_SS...
    E.imgNombre{k, 1} = lista(i).nombre;
    if mod(i, 100) == 0, fprintf('  %d/%d (%.0f s)\n', i, numel(lista), toc); end
end
E.lista = lista;
fprintf('Imágenes evaluadas: %d | sin etiquetas: %d | mal etiquetadas excluidas: %d | cámara mal identificada: %d\n', ...
    numel(E.imgLista), E.nSinEtiqueta, E.nExcluidas, E.nCamMal);
end
