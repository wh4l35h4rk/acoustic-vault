close all;
clear variables;
clc;

pFolder = 'EXP2_2_2025_09_20/';
RunModel(pFolder);

[aFieldTL, range, depth] = PlotResults(pFolder);

pAx = get(gca,'Position');