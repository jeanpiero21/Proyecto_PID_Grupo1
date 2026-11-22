function guardarFigura(fig, ruta)
%GUARDARFIGURA Exporta una figura a PNG y la cierra.
try
    exportgraphics(fig, ruta, 'Resolution', 150);
catch
    saveas(fig, ruta);
end
close(fig);
end
