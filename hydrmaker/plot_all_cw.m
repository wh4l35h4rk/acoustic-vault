close all;
clear variables;
clc;

pFolder = 'EXP2_2_2025_09_20/';
hydro_folder = 'hydrology/';

hydro_files = '*.hydr';
hydro_files = GetFiles([pFolder, hydro_folder, hydro_files], '', 'ASC');
N = size(hydro_files, 2);

for i = 1:N
    file = hydro_files(i).name;
    [~, range, ~] = fileparts(file);
    cw = readmatrix(fullfile(pFolder, hydro_folder, file), 'FileType','text');

    z = cw(:, 1);
    c = cw(:, 2);
    
    figure;
    plot(c, z);
    title(['R = ' range ' m'])
    set(gca, 'YDir', 'reverse');
    xlabel("c, m/s")
    ylabel("z, m")
end    

