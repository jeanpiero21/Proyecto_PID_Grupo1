function guardarIntermedias(I, R, calib, cfg, carpeta, prefijo)
%GUARDARINTERMEDIAS Guarda la imagen original, las intermedias y la final de una imagen analizada.
% Los nombres 01--10 siguen el recorrido del algoritmo. Así una persona puede
% entender el resultado abriendo las imágenes en orden, sin ejecutar MATLAB.
if ~isfolder(carpeta), mkdir(carpeta); end
cam = calib.camaras(R.camara);
f = @(nombre) fullfile(carpeta, sprintf('%s_%s.png', prefijo, nombre));
[H, W] = size(R.P.gris);
ind = calib.metodos.ind{1};

imwrite(I, f('01_original'));
% 01--06: transformaciones sobre la imagen completa.
imwrite(R.P.suave, f('02_preprocesada'));
imwrite(mat2gray(R.P.sobel), f('03_magnitud_sobel'));
imwrite(R.P.bordes, f('04_bordes_canny'));
imwrite(mat2gray(R.P.gradMorf), f('05_gradiente_morfologico'));
imwrite(mat2gray(R.P.topHat), f('06_tophat_bottomhat'));

% 07: mapa de cajones de la cámara
% Todavía no hay decisión: amarillo solo indica qué zona se analizará.
fig = dibujarCajones(I, cam.cajas, [], cfg.factorROI, ...
    sprintf('Mapa de cajones - %s (%d cajones)', cam.nombre, size(cam.cajas, 1)));
guardarFigura(fig, f('07_mapa_cajones'));

% 08: indicador del método principal por cajón, escalado a su umbral
%     (azul = parecido al vacío, verde = en el umbral, rojo = muy distinto)
t = cam.umbral.(ind).(calib.metodos.tipo{1}); t = t(:);
% Dividir por dos veces el umbral lleva los valores a una escala visual común.
if isscalar(t), t = repmat(t, size(cam.cajas, 1), 1); end
M = nan(H, W);
for j = 1:size(cam.cajas, 1)
    [fr, co] = recorteROI(cam.cajas(j, :), cfg.factorROI, H, W);
    M(fr, co) = R.V.(ind)(j) / (2 * max(t(j), eps));
end
mascara = ~isnan(M);
M(~mascara) = 0;
color = ind2rgb(gray2ind(min(max(M, 0), 1), 256), jet(256));
mezcla = im2double(I);
for ch = 1:3
    a = mezcla(:, :, ch); b = color(:, :, ch);
    a(mascara) = 0.35*a(mascara) + 0.65*b(mascara);
    mezcla(:, :, ch) = a;
end
imwrite(mezcla, f(['08_mapa_indicador_' ind]));

% 09: parche actual vs. referencia de cajón vacío y resultado de la resta + Otsu + apertura
% Elegimos pocos ejemplos ocupados y libres para que la lámina sea legible.
ocup = find(R.ocupado); libr = find(~R.ocupado);
sel = [ocup(1:min(4, end)); libr(1:min(4, end))];
if ~isempty(sel)
    nS = numel(sel);
    fig = figure('Visible', 'off', 'Color', 'w', 'Position', [100 100 130*nS 480]);
    tl = tiledlayout(3, nS, 'TileSpacing', 'compact', 'Padding', 'compact');
    for k = 1:nS
        s = sel(k);
        [~, kk] = min(distanciaHOG(cam.refs.hog{s}, R.F.hog(s, :)));   % referencia más parecida
        actual = reshape(double(R.F.gris(s, :)), cfg.tamParche);
        ref = reshape(double(cam.refs.gris{s}(kk, :)), cfg.tamParche);
        bw = imopen(abs((actual - mean(actual(:))) - (ref - mean(ref(:)))) > cam.Tresta, strel('diamond', 1));
        nexttile(k); imshow(actual, []);
        if R.ocupado(s)
            title(sprintf('#%d OCUPADO', s), 'Color', [0.8 0 0], 'FontSize', 8);
        else
            title(sprintf('#%d LIBRE', s), 'Color', [0 0.5 0], 'FontSize', 8);
        end
        nexttile(nS + k); imshow(ref, []);
        title(sprintf('vacío  d_{HOG}=%.2f', R.V.hog(s)), 'FontSize', 8);
        nexttile(2*nS + k); imshow(bw);
        title(sprintf('resta: %.0f%%', 100*mean(bw(:))), 'FontSize', 8);
    end
    title(tl, 'Fila 1: cajón actual | Fila 2: referencia vacía | Fila 3: resta + Otsu + apertura');
    guardarFigura(fig, f('09_parches_vs_referencia'));
end

% 10: resultado final
% Esta es la imagen que resume el conteo y el porcentaje de ocupación.
titulo = sprintf('%s | Total: %d | Libres: %d | Ocupados: %d | Ocupación: %.1f%%', ...
    cam.nombre, R.nTotal, R.nTotal - R.nOcupados, R.nOcupados, R.porcentaje);
fig = dibujarCajones(I, cam.cajas, R.ocupado, cfg.factorROI, titulo);
guardarFigura(fig, f('10_resultado'));
end
