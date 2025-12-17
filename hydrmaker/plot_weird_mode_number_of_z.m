close all;
clear variables;
clc;

profile_start = 2;
profile_end = 3;
pFolder = 'EXP2-5_tanh-approx/';

hydro_folder = 'hydrology/';
wmn_of_r_folder = 'weird_mode_numbers/';
graphics_folder = 'graphics/';
wmn_of_z_folder = 'weird_mode_number_of_z/';

if ~exist(fullfile(pFolder, graphics_folder), 'dir')
    mkdir(fullfile(pFolder, graphics_folder))
end
if ~exist(fullfile(pFolder, wmn_of_z_folder), 'dir')
    mkdir(fullfile(pFolder, wmn_of_z_folder))
end


hydro_files = GetFiles([pFolder, hydro_folder, '*.hydr'], '', 'ASC');
N = size(hydro_files, 2);

for i = profile_start:profile_end
    file = hydro_files(i).name;
    [~, range, ~] = fileparts(file);
    cw = readmatrix(fullfile(pFolder, hydro_folder, file), 'FileType','text');

    wmn_of_H = readmatrix(fullfile(pFolder, wmn_of_r_folder, strcat(num2str(range), '.txt')));
    wmn_of_z = wmn_of_H;

    [first, last] = FindThermocline(cw);
    z_start = cw(last, 1);
    z_max = cw(end, 1);
    wmn_of_z(:, 1) = (z_max + wmn_of_H(:, 1)) - z_start;

    figure;
    scatter(wmn_of_z(:, 2) - 1, wmn_of_z(:, 1));
    title(strcat('Глубина V_{gr} для R = ', num2str(range), ' м'))
    ylabel("Глубина под термоклином z, м");
    xlabel("Количество мод, помещающихся под термоклином");

    savefig(fullfile(pFolder, graphics_folder, strcat('wmn-of-z_', range, '.fig')));
    writematrix(wmn_of_z, fullfile(pFolder, wmn_of_z_folder, strcat('wmn-of-z_', range, '.txt')), "Delimiter", '\t');
end
