close all
clear variables
clc

pFolder = 'EXP2_2_2025_09_20/';

M = readmatrix(fullfile(pFolder, 'bath.txt'), 'FileType', 'text');
r = M(:, 1);
z = M(:, 2);

figure
grid on
plot(r, z, 'LineWidth', 1.2)
hold on
set(gca, 'YDir', 'reverse')
title('Батиметрия')
xlabel('Расстояние, м')
ylabel('Глубина, м')
hold off

savefig(fullfile(pFolder, 'bath.fig'))