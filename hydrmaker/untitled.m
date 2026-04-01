close all;
clear variables;
clc;

pFolder = 'EXP2-6_tanh-variants/';
original_folder = 'original/';
hydro_folder = 'hydrology/';
params_folder = 'tanh_params/';

hydro_files = GetFiles([pFolder, original_folder, hydro_folder, '*.hydr'], '', 'ASC');
params_files = GetFiles([pFolder, original_folder, params_folder, '*.mat'], '', 'ASC');

N = size(params_files, 2);
assert(N == 1 && N == size(hydro_files, 2));

cw_name = hydro_files(1).name;
cw = readmatrix(fullfile(pFolder, original_folder, hydro_folder, cw_name), FileType="text");
z = cw(:, 1);


file = fullfile(pFolder, original_folder, params_folder, params_files(1).name);
load(file, "best_params");

params.a = best_params.a;
params.b = best_params.b;
params.c0 = best_params.c0;
params.d = best_params.d;
clear best_params

new_params = params;
for a = 1:60
    new_params.a = a;
    c_new = params.c0 + -1 * params.a * tanh(z / params.d - params.b);
    cw_new = [z c_new];

    param_dir = strcat('a_', num2str(a), '/');
    if ~exist(fullfile(pFolder, param_dir), 'dir')
        mkdir(fullfile(pFolder, param_dir, hydro_folder));
        mkdir(fullfile(pFolder, param_dir, params_folder));
        copyfile(fullfile(pFolder, original_folder, 'bottom.txt'), ...
                 fullfile(pFolder, param_dir, 'bottom.txt'));
        copyfile(fullfile(pFolder, original_folder, 'MainRAMS.txt'), ...
                 fullfile(pFolder, param_dir, 'MainRAMS.txt'));
    end

    writematrix(cw_new, fullfile(pFolder, param_dir, hydro_folder, cw_name), 'FileType','text');
    save(fullfile(pFolder, param_dir, params_folder, params_files(1).name), "new_params");

    PlotMGVsDepths(fullfile(pFolder, param_dir), ...
                   0:3.6:3.6 * 15, ...
                   15, ...
                   1, 1);
end


