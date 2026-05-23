close all;
clear variables;
clc;

pFolder = 'diploma-2026_bottom-sound-channel/';
RunModel(pFolder);

[aFieldTL, range, depth] = PlotResults(pFolder);

pAx = get(gca,'Position');

ylim([0 130])
clim([-100 -50])
colormap(jet)