function [k1_z, k2_z, kb_z] = ThreeLayerWavenumbers(pFolder, profile_index, mode_index, dz, freq, n_modes, hydro_folder)
%THREELAYERWAVENUMBERS Numerically find wavenumbers for profile in 3-layer waveguide;
%   Function that runs ac_modes to computate vertical wavenumbers in
%   three-layer waveguide for selected profile and selected mode.

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
    dz = 0.25;
end
if nargin < 3
    mode_index = -1;
end

hydro_files = GetFiles([pFolder, hydro_folder, '*.hydr'], '', 'ASC');
cw = load([pFolder hydro_folder hydro_files(profile_index).name]);


% get wavenumbers numerically

w = 2*pi*freq;

c1 = max(cw(:, 2));                   % top water layer soundspeed
c2 = min(cw(:, 2));                   % bottom water layer soundspeed
cb = 1700;                            % bottom layer soundspeed

[k_mat, ~] = ThreeLayerRunAcModes(pFolder, profile_index, dz, freq, n_modes);

if mode_index == -1
    k_r = k_mat;
else
    k_r = k_mat(mode_index);
end

k1_z = sqrt(w^2 / c1^2 - k_r.^2);
k2_z = sqrt(w^2 / c2^2 - k_r.^2);
kb_z = sqrt(k_r.^2 - w^2 / cb^2);

end