function [wNum, wmode] = ThreeLayerRunAcModes(pFolder, profile_index, dz, freq, n_modes, hydro_folder)
%THREELAYERSRUNACMODES Function that runs ac_modes for 3-layer waveguide

if nargin < 7
    hydro_folder = 'hydrology/';
end
if nargin < 6
    n_modes = 15;
end
if nargin < 5
    freq = 400;
end
if nargin < 4 
    dz = 1;
end


hydro_files = GetFiles([pFolder, hydro_folder, '*.hydr'], '', 'ASC');
hydrology_mat = load([pFolder hydro_folder hydro_files(profile_index).name]);
water_layers_depth = FindThermoclineAxis(hydrology_mat);

max_depth = hydrology_mat(end, 1);
z = 0:dz:max_depth;

cw = hydrology_mat(:, 2);
c1 = max(cw);                   % top water layer soundspeed
c2 = min(cw);                   % bottom water layer soundspeed
cb = 1700;                      % bottom layer soundspeed

rho_w = 1;                      % water density
rho_b = 1.7;                    % bottom density


MP.HydrologyData = [z' cw];
MP.LayersData = [[0                  c1 c1 rho_w rho_w 0 0]; 
                 [water_layers_depth c1 c2 rho_w rho_w 0 0];
                 [max_depth          c2 cb rho_w rho_b 0 0]];

opts.nmod = n_modes;  


%   setting computational depth

if max_depth >= 500
    opts.Hb = max_depth + 500;
elseif max_depth < 100
    opts.Hb = 200;
else
    opts.Hb = 2 * MP.LayersData(end, 1);
end

%   finding solution of spectral problem

[wNum, wmode] = ac_modesr(dz, MP, freq, opts);

kj_im = ModesAttCoeffs(dz, freq, wNum, wmode, MP);        
wNum = wNum + 1i*kj_im;

end