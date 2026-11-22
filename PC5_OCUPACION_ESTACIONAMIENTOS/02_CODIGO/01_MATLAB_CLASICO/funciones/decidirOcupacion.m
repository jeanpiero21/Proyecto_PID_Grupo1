function ocupado = decidirOcupacion(V, cam, ind, tipo)
%DECIDIROCUPACION Regla de decisión para los cajones de UNA imagen: indicador > umbral => ocupado.
%   ind  : nombre del indicador ('hog', 'ncc', 'resta', 'grad', ...)
%   tipo : 'spotCalib' | 'spotOtsu' | 'camCalib' | 'camOtsu' | 'globCalib' | 'globOtsu'
t = cam.umbral.(ind).(tipo);             % escalar (global / cámara) o 1xN (por cajón)
ocupado = V.(ind)(:) > t(:);
end
