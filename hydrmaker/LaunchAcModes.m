function [k_r, modal_functions] = LaunchAcModes(pFolder, dz, opts, hydro_folder, ii)

if nargin < 4
    hydro_folder = 'hydrology/';
end

hydr_file_list = '*.hydr';
hydr_file_list = GetFiles([pFolder, hydro_folder, hydr_file_list], '', 'ASC');

RamsData = LoadConfigRAMS(pFolder, hydro_folder);
WriteRAMSIn(RamsData);
f = RamsData.freq;

hydr_mat = load([pFolder hydro_folder hydr_file_list(ii).name]);
max_depth = hydr_mat(end, 1);

cw = hydr_mat(:, 2);
z = 0:max_depth;

%   only water layer and top ocean floor layer are taken into account!

MP.HydrologyData = [z' cw];
MP.LayersData = [[0 1450 1450 1 1 0 0]; 
                 [max_depth 1450 RamsData.bParams(1, 1) 1 RamsData.bParams(1, 3) 0 0]];


%   setting computational depth

if max_depth >= 500
    opts.Hb = max_depth + 500;
elseif max_depth < 100
    opts.Hb = 200;
else
    opts.Hb = 2 * MP.LayersData(end, 1);
end

%   finding solution of spectral problem and computating group velocities

[k_r, modal_functions] = ac_modesr(dz, MP, f, opts);

end