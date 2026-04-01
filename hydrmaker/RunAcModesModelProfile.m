function [wNum, wmode] = RunAcModesModelProfile(pFolder, dz, depth, soundspeed, layer_rho, opts, hydro_folder)
%GETHYDROMGV Function that runs ac_modes for hydrology folder

if nargin < 7
    hydro_folder = 'hydrology/';
end

RamsData = LoadConfigRAMS(pFolder, hydro_folder);
WriteRAMSIn(RamsData);
f = RamsData.freq;

z = 0:depth;
cw = z;
cw(:) = soundspeed;

%   only water layer and top ocean floor layer are taken into account!

MP.HydrologyData = [z' cw'];
MP.LayersData = [[0     soundspeed soundspeed             layer_rho layer_rho              0 0]; 
                 [depth soundspeed RamsData.bParams(1, 1) layer_rho RamsData.bParams(1, 3) 0 0]];


%   setting computational depth

if depth >= 500
    opts.Hb = depth + 500;
elseif depth < 100
    opts.Hb = 200;
else
    opts.Hb = 2 * MP.LayersData(end, 1);
end

%   finding solution of spectral problem

[wNum, wmode] = ac_modesr(dz, MP, f, opts);

end