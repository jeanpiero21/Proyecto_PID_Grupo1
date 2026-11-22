function R = analizarImagen(I, calib, cfg)
%ANALIZARIMAGEN Pipeline completo para una imagen:
%   preprocesar -> identificar cámara -> descriptores por cajón -> indicadores
%   -> umbral (método principal) -> % de ocupación con denominador fijo.
R.P = preprocesar(I, cfg.preproc);
[R.camara, R.puntajes] = identificarCamara(R.P.gris, calib.camaras, cfg.tamPlantilla);
cam = calib.camaras(R.camara);
R.F = indicadoresCajones(R.P, cam.cajas, cfg);
R.V = valoresIndicadores(R.F, cam, cfg);
R.ocupado    = decidirOcupacion(R.V, cam, calib.metodos.ind{1}, calib.metodos.tipo{1});
R.nTotal     = numel(R.ocupado);
R.nOcupados  = nnz(R.ocupado);
R.porcentaje = 100 * R.nOcupados / R.nTotal;
end
