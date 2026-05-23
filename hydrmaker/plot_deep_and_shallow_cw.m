close all;
clear variables;
clc;

pFolder1 = 'npk_2025_05/hydrology_samples/';
file1 = 'Hydrology_2015.08.30_12.48_St.258.hydr';
cw = readmatrix(fullfile(pFolder1, file1), 'FileType','text');
cw = vertcat([0 cw(1, 2)], cw);
z1 = cw(:, 1);
c1 = cw(:, 2);


pFolder2 = 'EXP1_2024_10_27/';
hydro_folder = 'hydrology/';
hydro_files = '*.hydr';
hydro_files = GetFiles([pFolder2, hydro_folder, hydro_files], '', 'ASC');
N = size(hydro_files, 2);

file2 = hydro_files(N).name;
cw = readmatrix(fullfile(pFolder2, hydro_folder, file2), 'FileType','text');
cw = cw(1:end - 200, :);

z2 = cw(:, 1);
c2 = cw(:, 2);

c_min = min(c2);
i = find(c2 == c_min);
z_min = z2(i);


tiledlayout(1, 2)
nexttile
plot(c1, z1, LineWidth=1, Color=[0.9 0.5 0]);
title('Шельф')
set(gca, 'YDir', 'reverse');
grid on;
xlabel("c, м/с")
ylabel("z, м")
xlim([min(c1) - 5, max(c1) + 5])
ylim([0, max(z1)])

t2 = nexttile;
plot(c2, z2, LineWidth=1);
hold on;
yline(z_min, LineStyle="--");

newTick = z_min;
t2.YTick = sort([t2.YTick newTick]);
tick_amount = size(t2.YTick);
labels = t2.YTickLabels;
labels{2} = 'z_{c_{min}}';
t2.YTickLabels = labels;

title('Глубокий океан')
set(gca, 'YDir', 'reverse');
grid on;
xlabel("c, м/с")
ylabel("z, м")
xlim([min(c2) - 5, max(c2) + 5])

