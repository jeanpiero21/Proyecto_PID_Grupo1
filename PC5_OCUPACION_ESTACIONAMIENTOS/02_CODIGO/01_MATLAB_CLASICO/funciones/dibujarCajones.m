function fig = dibujarCajones(I, cajas, ocupado, factor, titulo)
%DIBUJARCAJONES Dibuja la zona analizada de cada cajón: verde = libre, rojo = ocupado,
%   amarillo = sin estado (cuando ocupado = []). La figura se crea oculta.
fig = figure('Visible', 'off', 'Color', 'w');
imshow(I); hold on;
[H, W, ~] = size(I);
for j = 1:size(cajas, 1)
    [fr, co] = recorteROI(cajas(j, :), factor, H, W);
    pos = [co(1) - 0.5, fr(1) - 0.5, numel(co), numel(fr)];
    if isempty(ocupado)
        col = [1 1 0];
    elseif ocupado(j)
        col = [1 0 0];
    else
        col = [0 1 0];
    end
    rectangle('Position', pos, 'EdgeColor', col, 'LineWidth', 1.2);
end
hold off;
title(titulo, 'Interpreter', 'none', 'FontSize', 9);
end
