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

[~, numerical_modefunc] = ThreeLayerRunAcModes(pFolder, PROFILE, 0.25);

cw = readmatrix([pFolder hydro_folder cw_name], "FileType", "text");
cw_name = cw_name(1:end - 5);

h1 = FindThermoclineAxis(cw);
h2 = cw(end, 1);

k1_vec = zeros(1, nModes);
k2_vec = zeros(1, nModes);
modes = 1:nModes;

for MODE = modes
%     numerical_modefunc = numerical_modefunc(:, MODE);
%     d = size(numerical_modefunc);
%     d = d(1);

    [k1_z, k2_z, kb_z] = ThreeLayerWavenumbers(pFolder, PROFILE);
    k1_vec(MODE) = k1_z(MODE);
    k2_vec(MODE) = k2_z(MODE);  

%     [A, B, C] = ThreeLayerAnalyticalCoefs(cw, [k1_z, k2_z, kb_z]);
% 
%     z1 = 1:h1;
%     z2 = h1 + 1:h2;
%     zb = h2 + 1:d;
%     z = 1:d;
% 
%     phi_1 = sin(k1_z * z1);
%     phi_2 = A * sin(k2_z * z2) + B * cos(k2_z * z2);
%     phi_b = C * exp(-kb_z * zb);
%     phi = [phi_1'; phi_2'; phi_b'];
% 
%     figure
%     plot(z, phi, 'DisplayName', 'Analytical');
%     hold on
%     plot(numerical_modefunc, 'DisplayName', 'Numerical');
%     legend
end

tiledlayout(2, 1);
plot(modes, imag(k1_vec), 'DisplayName', 'k_1');
hold on;
plot(modes, imag(k2_vec), 'DisplayName', 'k_2');
xlabel('Номер моды');
ylabel('Im(k_z)');
legend;
hold off;

nexttile
plot(modes, real(k1_vec), 'DisplayName', 'k_1');
hold on;
plot(modes, real(k2_vec), 'DisplayName', 'k_2');
xlabel('Номер моды');
ylabel('Re(k_z)');
legend;




