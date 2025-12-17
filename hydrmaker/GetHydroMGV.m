function mgv_mat = GetHydroMGV(dz, pFolder, opts, hydro_folder)
%GETHYDROMGV Function that computates modal group velocities for all profiles in hydrology folder

if nargin < 4
    hydro_folder = 'hydrology/';
end

hydr_file_list = '*.hydr';
hydr_file_list = GetFiles([pFolder, hydro_folder, hydr_file_list], '', 'ASC');
nHydr = length(hydr_file_list);

RamsData = LoadConfigRAMS(pFolder, hydro_folder);
WriteRAMSIn(RamsData);
f = RamsData.freq;

mgv_mat = zeros(nHydr, opts.nmod);

for ii = 1:nHydr
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

    [wNum, wmode] = ac_modesr(dz, MP, f, opts);
    z = dz * (0:size(wmode, 1) - 1);

    mgv = ModesGroupVelocities(z, f, wNum, wmode, MP);
    mgv_mat(ii, :) = mgv';
end

mgv_mat = round(mgv_mat, 4);
writematrix(mgv_mat, [pFolder 'mgv.txt'], 'Delimiter', '\t', 'FileType','text');

end