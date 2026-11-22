function V = valoresIndicadores(F, cam, cfg)
%VALORESINDICADORES Valor de cada indicador para los N cajones de una imagen.
%   Indicadores que se comparan con la referencia de cajón vacío (calibración):
%     hog   : 1 - similitud coseno del HOG                          (S11)
%     ncc   : 1 - correlación normalizada de la magnitud Sobel      (extra)
%     resta : fracción de píxeles que cambian tras resta+Otsu+apertura (S9-S10)
%     hist  : 1 - intersección de histogramas                       (S3, S10)
%     sat   : diferencia de saturación HSV                          (S7)
%   Indicadores directos:
%     grad (Sobel), gradMorf, topHat, desv, bordes (Canny)
N = size(F.sobel, 1);
[V.hog, V.ncc, V.resta, V.hist, V.sat] = deal(zeros(N, 1));
for s = 1:N
    V.hog(s)   = distanciaHOG(F.hog(s, :), cam.refs.hog{s});
    V.ncc(s)   = distanciaNCC(F.sobel(s, :), cam.refs.sobel{s});
    V.resta(s) = distanciaResta(F.gris(s, :), cam.refs.gris{s}, cam.Tresta, cfg.tamParche);
    V.hist(s)  = distanciaHist(F.hist(s, :), cam.refs.hist{s});
    V.sat(s)   = distanciaSat(F.sat(s), cam.refs.sat{s});
end
V.grad = F.grad; V.gradMorf = F.gradMorf; V.topHat = F.topHat; V.desv = F.desv; V.bordes = F.bordes;
end
