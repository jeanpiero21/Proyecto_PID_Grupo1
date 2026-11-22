function calib = calibrarSistema(cfg)
%CALIBRARSISTEMA Calibra cada cámara fija con imágenes etiquetadas (cfg.splitCalib).
%   1) Agrupa las imágenes por disposición de cajones (cada cámara fija tiene la suya).
%   2) Mapa de cajones de cada cámara.
%   3) Plantilla de la cámara (mediana de varias imágenes) para identificarla después.
%   4) K referencias de "cajón vacío" por cajón y por descriptor (Sobel, gris, HOG,
%      histograma, saturación), una por nivel de brillo.
%   5) Umbral de la resta (Otsu sobre las diferencias) y umbrales de decisión de cada
%      indicador: global, por cámara y por cajón; con Otsu (sin etiquetas) o calibrado.

lista = listarSplit(cfg.rutaDataset, cfg.splitCalib, cfg.maxImgsCalib);
info = imfinfo(lista(1).img);
W = info.Width; H = info.Height;
fprintf('Calibrando con %d imágenes de "%s" (%dx%d, preprocesamiento "%s")...\n', ...
    numel(lista), cfg.splitCalib, W, H, cfg.preproc);

% ---------- 1) Agrupar por layout ----------
camaras = struct('nombre', {}, 'cajas', {}, 'norm', {}, 'idx', {});
for i = 1:numel(lista)
    [~, cajas, nrm] = leerEtiquetas(lista(i).lbl, W, H);
    if isempty(cajas), continue; end                 % sin etiquetas: no sirve para calibrar
    c = camaraDesdeEtiquetas(nrm, camaras, cfg.tolLayout);
    if c == 0
        c = numel(camaras) + 1;
        camaras(c).nombre = nombreCamara(size(nrm, 1), camaras);
        camaras(c).cajas  = cajas;
        camaras(c).norm   = nrm;
        camaras(c).idx    = [];
    end
    camaras(c).idx(end + 1) = i;
end

indicadores = {'hog', 'ncc', 'resta', 'hist', 'sat', 'grad', 'gradMorf', 'topHat', 'desv', 'bordes'};
escalares = {'brillo', 'sat', 'bordes', 'grad', 'desv', 'gradMorf', 'topHat'};
Lp = prod(cfg.tamParche);
Lh = prod(cfg.tamHOG / 8) * 9;
Vcal = cell(numel(camaras), 1);
Ycal = cell(numel(camaras), 1);

for c = 1:numel(camaras)
    ids = camaras(c).idx;
    nI = numel(ids);
    N = size(camaras(c).cajas, 1);
    Ps = zeros(nI, N, Lp, 'single');            % parches Sobel
    Pg = zeros(nI, N, Lp, 'single');            % parches de gris
    Ph = zeros(nI, N, Lh, 'single');            % HOG
    Pt = zeros(nI, N, cfg.binsHist, 'single');  % histogramas
    S = struct();
    for q = 1:numel(escalares), S.(escalares{q}) = zeros(nI, N); end
    y = nan(nI, N);
    nPl = min(nI, cfg.maxImgsPlantilla);
    selPl = round(linspace(1, nI, nPl));
    pila = zeros([cfg.tamPlantilla nPl]);
    kp = 0;

    % ---------- 2) y 3) recorrer las imágenes de la cámara ----------
    for t = 1:nI
        i = ids(t);
        I = imread(lista(i).img);
        P = preprocesar(I, cfg.preproc);
        [cl, cajasImg] = leerEtiquetas(lista(i).lbl, W, H);
        j = emparejarConMapa(cajasImg, camaras(c).cajas);
        y(t, j) = cl';
        F = indicadoresCajones(P, camaras(c).cajas, cfg);
        Ps(t, :, :) = reshape(F.sobel, [1 N Lp]);
        Pg(t, :, :) = reshape(F.gris,  [1 N Lp]);
        Ph(t, :, :) = reshape(F.hog,   [1 N Lh]);
        Pt(t, :, :) = reshape(F.hist,  [1 N cfg.binsHist]);
        for q = 1:numel(escalares), S.(escalares{q})(t, :) = F.(escalares{q})'; end
        if any(selPl == t)
            kp = kp + 1;
            pila(:, :, kp) = imresize(P.gris, cfg.tamPlantilla);
        end
    end
    camaras(c).plantilla = median(pila(:, :, 1:kp), 3);
    camaras(c).rutas = {lista(ids).img};

    % ---------- 4) referencias de cajón vacío ----------
    refs = struct('sobel', {cell(N, 1)}, 'gris', {cell(N, 1)}, 'hog', {cell(N, 1)}, ...
                  'hist', {cell(N, 1)}, 'sat', {cell(N, 1)});
    V = struct('ncc', zeros(nI, N), 'hog', zeros(nI, N), 'hist', zeros(nI, N), ...
               'sat', zeros(nI, N), 'resta', zeros(nI, N));
    rng(0);
    muestras = cell(N, 1);
    for s = 1:N
        vacio = y(:, s) == 0;
        if nnz(vacio) < 2*cfg.K
            % casi nunca está vacío: usar los parches con menos textura (gradiente bajo)
            [~, orden] = sort(S.grad(:, s));
            vacio = false(nI, 1);
            vacio(orden(1:min(nI, max(cfg.K, round(0.2*nI))))) = true;
        end
        b = S.brillo(vacio, s);
        Xs = reshape(Ps(:, s, :), [nI Lp]);
        Xg = reshape(Pg(:, s, :), [nI Lp]);
        Xh = reshape(Ph(:, s, :), [nI Lh]);
        Xt = reshape(Pt(:, s, :), [nI cfg.binsHist]);
        refs.sobel{s} = referenciasPorBrillo(Xs(vacio, :), b, cfg.K);
        refs.gris{s}  = referenciasPorBrillo(Xg(vacio, :), b, cfg.K);
        refs.hog{s}   = referenciasPorBrillo(Xh(vacio, :), b, cfg.K);
        refs.hist{s}  = referenciasPorBrillo(Xt(vacio, :), b, cfg.K);
        refs.sat{s}   = referenciasPorBrillo(S.sat(vacio, s), b, cfg.K);
        V.ncc(:, s)  = distanciaNCC(Xs, refs.sobel{s});
        V.hog(:, s)  = distanciaHOG(Xh, refs.hog{s});
        V.hist(:, s) = distanciaHist(Xt, refs.hist{s});
        V.sat(:, s)  = distanciaSat(S.sat(:, s), refs.sat{s});
        % muestras de |diferencia| para el umbral de Otsu de la resta
        A = double(Xg) - mean(double(Xg), 2);
        B = double(refs.gris{s}) - mean(double(refs.gris{s}), 2);
        dif = abs(reshape(A, nI, 1, Lp) - reshape(B, 1, [], Lp));
        dif = dif(:);
        muestras{s} = dif(randperm(numel(dif), min(numel(dif), 2000)));
    end
    Tresta = umbralOtsu(vertcat(muestras{:}));
    for s = 1:N
        Xg = reshape(Pg(:, s, :), [nI Lp]);
        V.resta(:, s) = distanciaResta(Xg, refs.gris{s}, Tresta, cfg.tamParche);
    end
    V.grad = S.grad; V.gradMorf = S.gradMorf; V.topHat = S.topHat; V.desv = S.desv; V.bordes = S.bordes;
    camaras(c).refs = refs;
    camaras(c).Tresta = Tresta;

    % ---------- 5) umbrales por cámara y por cajón ----------
    ok = ~isnan(y);
    for q = 1:numel(indicadores)
        X = V.(indicadores{q});
        U = struct();
        U.camOtsu   = umbralOtsu(X(ok));
        U.camCalib  = umbralCalibrado(X(ok), y(ok));
        U.spotOtsu  = zeros(1, N);
        U.spotCalib = zeros(1, N);
        for s = 1:N
            oks = ok(:, s);
            U.spotOtsu(s) = umbralOtsu(X(oks, s));
            if nnz(y(oks, s) == 0) >= 5 && nnz(y(oks, s) == 1) >= 5
                U.spotCalib(s) = umbralCalibrado(X(oks, s), y(oks, s));
            else
                U.spotCalib(s) = U.camCalib;     % pocos ejemplos de una clase: umbral de la cámara
            end
        end
        camaras(c).umbral.(indicadores{q}) = U;
    end
    Vcal{c} = V;
    Ycal{c} = y;
    fprintf('  %-10s: %3d cajones, %4d imágenes de calibración\n', camaras(c).nombre, N, nI);
end

% ---------- umbral global único (el mismo para todas las cámaras) ----------
for q = 1:numel(indicadores)
    v = []; yy = [];
    for c = 1:numel(camaras)
        ok = ~isnan(Ycal{c});
        X = Vcal{c}.(indicadores{q});
        v = [v; X(ok)];             %#ok<AGROW>
        yy = [yy; Ycal{c}(ok)];     %#ok<AGROW>
    end
    gO = umbralOtsu(v);
    gC = umbralCalibrado(v, yy);
    for c = 1:numel(camaras)
        camaras(c).umbral.(indicadores{q}).globOtsu  = gO;
        camaras(c).umbral.(indicadores{q}).globCalib = gC;
    end
end

calib.camaras = camaras;
calib.indicadores = indicadores;
calib.W = W;
calib.H = H;
calib.metodos = listaMetodos();
calib.cfg = cfg;
calib.version = cfg.version;
end

function nombre = nombreCamara(n, camaras)
% Nombre según el nº de cajones etiquetados en PKLot.
switch n
    case 100, nombre = 'PUCPR';
    case 40,  nombre = 'UFPR05';
    case 28,  nombre = 'UFPR04';
    otherwise, nombre = sprintf('CAM_%d', n);
end
existentes = {camaras.nombre};
if any(strcmp(existentes, nombre))
    nombre = sprintf('%s_v%d', nombre, nnz(startsWith(existentes, nombre)) + 1);
end
end
