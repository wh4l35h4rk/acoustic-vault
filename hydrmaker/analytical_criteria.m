close all;
clear variables;
clc;

H = 0;
pFolder = ['EXP2-5_tanh-approx/hydrology_model/H' num2str(H), '/'];
resultsFolder = 'EXP2-6_analytical_criteria/';

hydro_folder = 'hydrology/';
hydro_files = GetFiles([pFolder, hydro_folder, '*.hydr'], '', 'ASC');
cw_name = hydro_files(2).name;
cw_name = cw_name(1:end - 5);

nModes = 15;
PROFILE = 2;

k_z_mat = zeros(nModes, 3);
im_k1 = zeros(nModes, 1);
for MODE = 1:nModes
    k_z_mat(MODE, :) = ThreeLayerWavenumbers(pFolder, PROFILE, MODE);
    k1 = k_z_mat(MODE, 1);
    im_k1(MODE) = imag(k1);
end

writematrix(k_z_mat, [resultsFolder 'wnums_R' cw_name '_H' num2str(H)], "Delimiter", "\t");

figure;
plot(1:nModes, im_k1, Marker="o")
title(['R = ', cw_name, ' м, H = ' num2str(H), ' м'])
xlabel('Номер моды')
ylabel('Im(k_1)')
savefig([resultsFolder 'Im(k1)_R' cw_name '_H' num2str(H)])
saveas(gcf, [resultsFolder 'Im(k1)_R' cw_name  '_H' num2str(H) '.jpeg'])

