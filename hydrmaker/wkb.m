close all;
clear variables;
clc;

H = 1.8 * 0;
nModes = 15;
PROFILE = 2;
f = 400;

omega = 2*pi*f;

pFolder = ['EXP2-5_tanh-approx/hydrology_model/H' num2str(H), '/'];
resultsFolder = 'EXP2-6_analytical_criteria/';
hydro_files = GetFiles([pFolder, 'hydrology/', '*.hydr'], '', 'ASC');
cw_name = hydro_files(PROFILE).name;

% k_r search for 3-layer waveguide
[k, ~] = ThreeLayerRunAcModes(pFolder, PROFILE, 0.25);

% % k_r search for 2-layer waveguide
% opts.nModes = nModes;
% [k, ~] = LaunchAcModes(pFolder, 0.25, opts, 'hydrology/', PROFILE); 

cw = readmatrix([pFolder 'hydrology/' cw_name], "FileType", "text");
cw_name = cw_name(1:end - 5);

h2 = cw(end, 1);

c = cw(:, 2);
z = cw(:, 1);

c1 = max(c);

division = omega / c1 - k


% find depth where soundspeed equals omega / k

abs(c - omega ./ k)
index = find(abs(c - omega ./ k) < 10^(-3));
h1 = z(index);


% compute integral

integr = zeros(1, nModes);
for dz = h1:h2
    integr = integr + sqrt(omega^2 / c(dz) - k.^2);
end


% estimate mode numbers with wkb method

assumed_nModes = zeros(1, nModes);
for j = 1:nModes
    assumed_nModes(j) = (2 * integr(j) - pi/2) / (2*pi);
end


