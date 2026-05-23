close all;
clear variables;
clc;

H = 1.8 * 0;
nModes = 15;
PROFILE = 2;

pFolder = ['EXP2-5_tanh-approx/hydrology_model/H' num2str(H), '/'];
resultsFolder = 'EXP2-6_analytical_criteria/';

hydro_folder = 'hydrology/';
hydro_files = GetFiles([pFolder, hydro_folder, '*.hydr'], '', 'ASC');
cw_name = hydro_files(PROFILE).name;

cw = readmatrix([pFolder hydro_folder cw_name], "FileType", "text");
cw_name = cw_name(1:end - 5);



for MODE = 1
    [wnum, wmode] = R(pFolder, PROFILE, 0.25);
    wmode = wmode(:, MODE);
    d = size(wmode);
    d = d(1);

    [k1_z, k2_z, kb_z] = ThreeLayerWavenumbers(pFolder, PROFILE, MODE, 0.25);
    [A, B, C] = ThreeLayerAnalyticalCoefs(cw, [k1_z, k2_z, kb_z]);

    z1 = 1:h1;
    z2 = h1 + 1:h2;
    zb = h2 + 1:d;
    z = 1:d;

    phi_1 = sin(k1_z * z1);
    phi_2 = A * sin(k2_z * z2) + B * cos(k2_z * z2);
    phi_b = C * exp(-kb_z * zb);
    phi = [phi_1'; phi_2'; phi_b'];

    figure
    plot(z, phi, 'DisplayName', 'Analytical');
    hold on
    plot(wmode, 'DisplayName', 'Numerical');
    legend
end

