close all;
clear variables;
clc;

hydro_folder = 'hydrology/';
hydro_files_data = dir([hydro_folder '*.hydr']);
len = size(hydro_files_data, 1);

H = 50;

range = zeros(1, len);
for i = 1:len
    file_name = hydro_files_data(i).name;
    [~, range_name, ~] = fileparts(file_name);
    range(i) = str2double(range_name);
    cw = readmatrix(fullfile(hydro_folder, file_name), 'FileType','text');
    z = cw(:, 1);
    c = cw(:, 2);

    z = 1:H + z(end);
    top_c = zeros(H, 1);
    top_c(:) = c(1);
    c = vertcat(top_c, c);
    cw = [z' c];

    writematrix(cw, fullfile(hydro_folder, file_name), 'FileType','text', 'Delimiter','\t');
end