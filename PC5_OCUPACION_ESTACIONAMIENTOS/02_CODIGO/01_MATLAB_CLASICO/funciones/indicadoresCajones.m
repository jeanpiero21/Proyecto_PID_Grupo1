function F = indicadoresCajones(P, cajas, cfg)
%INDICADORESCAJONES Descriptores de cada cajón (zona central de la caja) en una imagen.
%   Parches (se comparan con las referencias de cajón vacío):
%     F.sobel : N x L  magnitud Sobel a tamaño fijo cfg.tamParche     (para NCC)
%     F.gris  : N x L  gris a tamaño fijo cfg.tamParche              (para la resta)
%     F.hog   : N x 216 descriptor HOG propio                         (S11)
%     F.hist  : N x B  histograma normalizado del gris               (S3, S10)
%   Escalares (se umbralizan directamente):
%     F.brillo, F.sat, F.bordes, F.grad, F.desv, F.gradMorf, F.topHat
[H, W] = size(P.gris);
N = size(cajas, 1);
L = prod(cfg.tamParche);
F.sobel = zeros(N, L, 'single');
F.gris  = zeros(N, L, 'single');
F.hog   = zeros(N, prod(cfg.tamHOG / 8) * 9, 'single');
F.hist  = zeros(N, cfg.binsHist, 'single');
[F.brillo, F.sat, F.bordes, F.grad, F.desv, F.gradMorf, F.topHat] = deal(zeros(N, 1));
for j = 1:N
    [fr, co] = recorteROI(cajas(j, :), cfg.factorROI, H, W);
    g = P.suave(fr, co);
    s = P.sobel(fr, co);
    ps = imresize(s, cfg.tamParche, 'bilinear');  F.sobel(j, :) = single(ps(:)');
    pg = imresize(g, cfg.tamParche, 'bilinear');  F.gris(j, :)  = single(pg(:)');
    F.hog(j, :) = single(hogPropio(imresize(g, cfg.tamHOG, 'bilinear')));
    h = imhist(min(max(g, 0), 1), cfg.binsHist);  F.hist(j, :) = single(h(:)' / numel(g));
    F.brillo(j)   = mean(g(:));
    F.sat(j)      = mean(P.sat(fr, co), 'all');
    F.bordes(j)   = mean(P.bordes(fr, co), 'all');
    F.grad(j)     = mean(s(:));
    F.desv(j)     = std(g(:));
    F.gradMorf(j) = mean(P.gradMorf(fr, co), 'all');
    F.topHat(j)   = mean(P.topHat(fr, co), 'all');
end
end
