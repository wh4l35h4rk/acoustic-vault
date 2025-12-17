close all;
clear variables;
clc;

% function that computates modal numbers for all profiles in hydrology folder

pFolder = 'EXP2_3_2025_10_22/';
hydr_file_list = '*.hydr';
hydr_file_list = GetFiles([pFolder, 'hydrology/', hydr_file_list], '', 'ASC');
nHydr = length(hydr_file_list);

RamsData = LoadConfigRAMS(pFolder);
WriteRAMSIn(RamsData);

dz = 1;
opts.nmod = 10;
f = RamsData.freq;
w = 2*pi * f;

bounds_folder = 'modal_localisation_intervals/';
if ~exist(fullfile(pFolder, bounds_folder), 'dir')
    mkdir(fullfile(pFolder, bounds_folder))
end

for ii = 1:nHydr
    hydr_mat = load([pFolder 'hydrology/' hydr_file_list(ii).name]);
    [~, range, ~] = fileparts([pFolder 'hydrology/' hydr_file_list(ii).name]);
    max_depth = hydr_mat(end, 1);

    cw = hydr_mat(:, 2);
    z = 0:max_depth;

    MP.HydrologyData = [z' cw];
    MP.LayersData = [[0 1450 1450 1 1 0 0]; 
                     [max_depth 1450 RamsData.bParams(1, 1) 1 RamsData.bParams(1, 3) 0 0]];

    if max_depth >= 500
        opts.Hb = max_depth + 500;
    elseif max_depth < 100
        opts.Hb = 200;
    else
        opts.Hb = 2 * MP.LayersData(end, 1);
    end


    [wNum, wmode] = ac_modesr(dz, MP, f, opts);
    

    bounds_mat = zeros(2, opts.nmod);
    for jj = 1:opts.nmod
        k = wNum(jj)
        phi = wmode(:, jj);

        val = w / k;

        i_up = find(cw < val, 1, 'first');
        i_low = find(cw < val, 1, 'last');
    
        z_up = z(i_up);
        z_low = z(i_low);

        bounds_mat(:, jj) = [z_up; z_low];
    end

    writematrix(bounds_mat, fullfile(pFolder, bounds_folder, [range, '.txt']), "Delimiter", '\t')
end


