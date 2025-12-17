close all;
clear variables;
clc;

% pFolder = 'EXP1-2_modexp-compar/';
pFolder = 'EXP1_2024_10_27/';
hydro_folder = 'hydrology/';

hydro_files = GetFiles([pFolder, hydro_folder, '*.hydr'], '', 'ASC');
N = size(hydro_files, 2);

file = hydro_files(end).name;
[~, range, ~] = fileparts(file);
cw = readmatrix(fullfile(pFolder, hydro_folder, file), 'FileType','text');
[first, last] = FindThermocline(cw);
d = cw(last, 1) - cw(first, 1)

figure;
plot(cw(:, 2), cw(:, 1));
title(strcat("R = ", range, " m"));
set(gca, 'YDir', 'reverse');
grid on;
hold on;

yline(cw(first, 1), LineStyle="--", Color=[0.5 0.5 0.5]);
yline(cw(last, 1), LineStyle="--", Color=[0.5 0.5 0.5]);
scatter(cw(last, 2), cw(last, 1), Marker="*", MarkerEdgeColor='red');
scatter(cw(first, 2), cw(first, 1), Marker="*", MarkerEdgeColor='red');

min_cw = min(cw(:, 2));
imdex_min = find(cw(:, 2) == min(cw(:, 2)))
scatter(cw(imdex_min, 2), cw(imdex_min, 1), Marker="x");


cw_wo_min = cw;
cw_wo_min(imdex_min, :) = [];

%  min(cw_wo_min(:, 2))

% imdex_min = find(cw_wo_min(:, 2) == min(cw_wo_min(:, 2)))

% scatter(cw_wo_min(imdex_min, 2), cw_wo_min(imdex_min, 1), Marker="x");

