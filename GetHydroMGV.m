function mgv_mat = GetHydroMGV(dz0, pFolder, opts)

%GETHYDROMGV Find MGV for each profile in hydrology folder

hydr_file_list = '*.hydr';
hydr_file_list = GetFiles([pFolder, 'hydrology/', hydr_file_list], '', 'ASC');
nHydr = length(hydr_file_list);

RamsData = LoadConfigRAMS(pFolder);
WriteRAMSIn(RamsData);
f = RamsData.freq;

mgv_mat = zeros(nHydr, opts.nmod);

for ii = 1:nHydr
    hydr_mat = load([pFolder 'hydrology/' hydr_file_list(ii).name]);
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


    [wNum, wmode] = ac_modesr(dz0, MP, f, opts);
    z = dz0 * (0:size(wmode, 1) - 1);

    mgv = ModesGroupVelocities(z, f, wNum, wmode, MP);
    mgv_mat(ii, :) = mgv';
end

writematrix(num2str(mgv_mat,'%.2f '), [pFolder 'mgv.txt'], 'Delimiter', '\t');

end