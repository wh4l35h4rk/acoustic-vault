function [k1_z, k2_z, kb_z] = ThreeLayerWavenumbers(pFolder, profile_index, mode_index, dz, freq, n_modes, hydro_folder)
%THREELAYERWAVENUMBERS Numerically find wavenumbers for profile in 3-layer waveguide;

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
cw = load([pFolder hydro_folder hydro_files(profile_index).name]);


% get wavenumbers numerically

w = 2*pi*freq;

c1 = max(cw(:, 2));                   % top water layer soundspeed
c2 = min(cw(:, 2));                   % bottom water layer soundspeed
cb = 1700;                            % bottom layer soundspeed


[k_mat, ~] = ThreeLayerRunAcModes(pFolder, profile_index, dz, freq, n_modes);
k_r = k_mat(mode_index);

h1 = FindThermoclineAxis(cw);
h2 = cw(end, 1);

k1_z = sqrt(w^2 / c1^2 - k_r^2);
k2_z = sqrt(w^2 / c2^2 - k_r^2);
kb_z = sqrt(k_r^2 - w^2 / cb^2);


% find coefficients for modal functions analytical form

rho_w = 1;                      % water density
rho_b = 1.7;                    % bottom density

X = [
    sin(k2_z * h1),           cos(k2_z * h1);
    k2_z * cos(k2_z * h1), -k2_z / rho_w * sin(k2_z * h1);
];
y = [sin(k1_z * h1); k1_z / rho_w * cos(k1_z * h1)];
coefs_for_water_layers = linsolve(X, y);

A = coefs_for_water_layers(1);
B = coefs_for_water_layers(2);
C = A * sin(k2_z * h2) / exp(-kb_z * h2) + B * cos(k2_z * h2) / exp(-kb_z * h2);

end