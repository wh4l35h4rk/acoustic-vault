close all;
clear variables;
clc;

fig = openfig("tl_1-2_rus.fig");

set(0, 'DefaultAxesFontSize', 20, 'DefaultAxesFontName', 'Arial');
set(0, 'DefaultTextFontSize', 18, 'DefaultTextFontName', 'Arial');

xlabel("Расстояние, км");
ylabel("Глубина, м");

cb = colorbar();  

ticklabels = get(cb, 'TickLabels');
f = cellfun(@(x) x(2:end), ticklabels, 'UniformOutput', false);

cb.set("TickLabels", f);

savefig("tl_1-2_rus-expanded.fig");
saveas(fig, "tl_1-2_rus-expanded.png");