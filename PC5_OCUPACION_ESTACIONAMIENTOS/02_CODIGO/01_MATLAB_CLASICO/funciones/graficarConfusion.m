function fig = graficarConfusion(mc, titulo)
%GRAFICARCONFUSION Matriz de confusión 2x2 (sin depender de otros toolboxes).
% Filas = clase real; columnas = predicción. "Ocupado" es la clase positiva.
CM = [mc.TN mc.FP; mc.FN mc.TP];
fig = figure('Visible', 'off', 'Color', 'w');
imagesc(CM); colormap(flipud(gray)); axis square;
xticks([1 2]); yticks([1 2]);
xticklabels({'Pred. libre', 'Pred. ocupado'});
yticklabels({'Real libre', 'Real ocupado'});
total = sum(CM(:));
% Escribimos conteo y porcentaje dentro de cada celda. El color del texto cambia
% según el fondo para que siga siendo legible.
for r = 1:2
    for c = 1:2
        if CM(r, c) > 0.5*max(CM(:)), col = 'w'; else, col = 'k'; end
        text(c, r, {sprintf('%d', CM(r, c)), sprintf('(%.1f%%)', 100*CM(r, c)/total)}, ...
            'HorizontalAlignment', 'center', 'Color', col, 'FontWeight', 'bold');
    end
end
title({titulo, sprintf('P = %.3f   R = %.3f   F1 = %.3f   Exactitud = %.3f', ...
    mc.precision, mc.recall, mc.f1, mc.exactitud)}, 'Interpreter', 'none', 'FontSize', 9);
end
