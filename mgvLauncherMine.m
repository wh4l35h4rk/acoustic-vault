close all;
clear variables;
clc;

nmod = 10;
pFolder = 'EXP2_2024_11_21/';

dz0 = 1;
opts.Tgr = 3; % кол-во сеток
opts.Ngr = 3; % кол-во сеток
opts.nmod = 10;
opts.BotBC = 'D'; % дирихле (гран.)

hydr_file_list = '*.hydr';
hydr_file_list = GetFiles([pFolder, 'hydrology/', hydr_file_list], '', 'ASC');
nHydr = length(hydr_file_list);

depths = zeros([1, nHydr]);
ranges = zeros([1, nHydr]);

for ii = 1:nHydr
    hydr_mat = load([pFolder 'hydrology/' hydr_file_list(ii).name]);
    [~, b, ~] = fileparts([hydr_file_list(ii).name]);
    depths(ii) = hydr_mat(end, 1);
    ranges(ii) = str2double(b);
end


RamsData = LoadConfigRAMS(pFolder);
WriteRAMSIn(RamsData);

dz = RamsData.dz;
f = RamsData.freq;
dzHydr = 1;

mgv_mat = zeros(nHydr, nmod);

for ii = 1:nHydr
    hydr_mat = load([pFolder 'hydrology/' hydr_file_list(ii).name]);
    max_depth = depths(ii);

    cw = hydr_mat(:, 2);
    z = 0:dzHydr:max_depth;

    MP.HydrologyData = [z' cw];
    MP.LayersData = [[0 1450 1450 1 1 0 0]; 
                     [max_depth 1450 RamsData.bParams(1, 1) 1 RamsData.bParams(1, 3) 0 0]];


    if MP.LayersData(end, 1) >= 500
        opts.Hb = MP.LayersData(end, 1) + 500;
    elseif MP.LayersData(end, 1) < 100
        opts.Hb = 200;
    else
        opts.Hb = 2 * MP.LayersData(end, 1);
    end


    [wNum, wmode] = ac_modesr(dz0, MP, f, opts);
    z = dz0 * (0:size(wmode, 1) - 1);

    mgv = ModesGroupVelocities(z, f, wNum, wmode, MP);
    mgv_mat(ii, :) = mgv';
end

writematrix(mgv_mat, [pFolder 'mgv.txt'], 'FileType', 'text', 'Delimiter', '\t');


