function fig = graficarResumenMetricas(mc, mo, pctReal, pctPred, imgCam, nombresCam, nImg)
%GRAFICARRESUMENMETRICAS Diapositiva-resumen de resultados del método principal:
%   3 métricas grandes (exactitud, recall, error del %) + gráfico % real vs. estimado.
AZ = [0.18 0.43 0.71];
fig = figure('Visible', 'off', 'Color', 'w', 'Position', [50 50 1600 900]);
annotation(fig, 'textbox', [0 0.9 1 0.08], 'String', ...
    sprintf('Resultados del método clásico en test (%d imágenes)', nImg), ...
    'HorizontalAlignment', 'center', 'FontSize', 24, 'FontWeight', 'bold', 'Color', AZ, 'EdgeColor', 'none');

grande = {sprintf('%.0f %%', 100*mc.exactitud), sprintf('%.0f %%', 100*mc.recall), sprintf('%.1f pp', mo.MAE)};
etiq   = {'exactitud', 'recall', 'error del %'};
desc   = {sprintf('acierta en %.0f de cada 100 cajones', 100*mc.exactitud), ...
          'casi nunca se le escapa un auto', ...
          'diferencia promedio entre % estimado y % real'};
for k = 1:3
    y0 = 0.64 - (k-1)*0.24;
    annotation(fig, 'rectangle', [0.03 y0 0.42 0.2], 'Color', AZ, 'LineWidth', 2, 'FaceColor', [0.93 0.95 0.98]);
    annotation(fig, 'textbox', [0.04 y0 0.17 0.2], 'String', grande{k}, 'FontSize', 40, 'FontWeight', 'bold', ...
        'Color', AZ, 'EdgeColor', 'none', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle');
    annotation(fig, 'textbox', [0.23 y0+0.1 0.21 0.08], 'String', etiq{k}, 'FontSize', 20, 'FontWeight', 'bold', ...
        'EdgeColor', 'none', 'VerticalAlignment', 'middle');
    annotation(fig, 'textbox', [0.23 y0+0.02 0.21 0.08], 'String', desc{k}, 'FontSize', 13, ...
        'Color', [0.27 0.27 0.27], 'EdgeColor', 'none', 'VerticalAlignment', 'middle');
end

ax = axes(fig, 'Position', [0.55 0.14 0.4 0.7]); hold(ax, 'on');
for c = 1:numel(nombresCam)
    m = imgCam == c;
    scatter(ax, pctReal(m), pctPred(m), 22, 'filled', 'MarkerFaceAlpha', 0.6, 'DisplayName', nombresCam{c});
end
plot(ax, [0 100], [0 100], 'k--', 'LineWidth', 2, 'DisplayName', 'ideal (estimado = real)');
axis(ax, [0 100 0 100]); axis(ax, 'square'); grid(ax, 'on'); box(ax, 'on');
xlabel(ax, '% de ocupación real', 'FontSize', 15); ylabel(ax, '% de ocupación estimado', 'FontSize', 15);
legend(ax, 'Location', 'southeast', 'FontSize', 12);
title(ax, 'Cada punto es una imagen', 'FontSize', 15);
end
