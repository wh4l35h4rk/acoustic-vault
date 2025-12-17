close all;
clear variables;
clc;

% for each range in hydrology folder, get how many modes would exist

pFolder = 'EXP2_2_2025_09_20/';
hydro_folder = 'hydrology/';

hydro_files = '*.hydr';
hydro_files = GetFiles([pFolder, hydro_folder, hydro_files], '', 'ASC');
N = size(hydro_files, 2);

mat = zeros(N, 2);
for i = 1:N
    file = hydro_files(i).name;
    [~, range, ~] = fileparts(file);

    cw = readmatrix(fullfile(pFolder, hydro_folder, file), 'FileType','text');

    f = 400;
    w = 2 * pi * f;
    H = cw(end, 1);
    c = cw(end, 2);

    n = ceil(sqrt((H * w) / (pi * c)));
    mat(i, :) = [str2double(range) n];
end    

writematrix(mat, [pFolder 'modes_amount.txt'], "Delimiter", '\t');
