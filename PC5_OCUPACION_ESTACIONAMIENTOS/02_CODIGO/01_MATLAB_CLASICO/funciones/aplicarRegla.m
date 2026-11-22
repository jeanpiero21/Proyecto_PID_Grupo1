function pred = aplicarRegla(E, calib, ind, tipo)
%APLICARREGLA Predicción "ocupado" para todos los cajones evaluados (E) con un indicador y
%   un tipo de umbral. ind = 'voto' combina por mayoría los indicadores de calib.metodos.voto.
% ENTRADA: valores E, calibración, indicador y tipo de umbral.
% SALIDA : un vector lógico; true significa ocupado.
if strcmp(ind, 'voto')
    % Caso especial: cada indicador emite un voto y gana la mayoría.
    votos = zeros(numel(E.y), 1);
    lst = calib.metodos.voto;
    for k = 1:numel(lst)
        votos = votos + aplicarRegla(E, calib, lst{k}, tipo);
    end
    pred = votos >= ceil((numel(lst) + 1) / 2);
    return;
end
v = E.V.(ind);
t = zeros(size(v));
% Cada cámara puede tener un umbral único o un vector con uno por cajón.
for c = 1:numel(calib.camaras)
    m = E.cam == c;
    if ~any(m), continue; end
    u = calib.camaras(c).umbral.(ind).(tipo);
    u = u(:);
    if isscalar(u)
        t(m) = u;
    else
        t(m) = u(E.spot(m));
    end
end
% La decisión final es intencionalmente simple y fácil de explicar.
pred = v > t;
end
