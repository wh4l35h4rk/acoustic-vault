close all;
clear variables;
clc;

% H = 32.4;
H = 3.6 * 9;
nModes = 15;
PROFILE = 2;

pFolder = ['EXP2-5_tanh-approx/hydrology_model/H' num2str(H), '/'];
resultsFolder = 'EXP2-6_analytical_criteria/';

hydro_folder = 'hydrology/';
hydro_files = GetFiles([pFolder, hydro_folder, '*.hydr'], '', 'ASC');
cw_name = hydro_files(PROFILE).name;

cw = readmatrix([pFolder hydro_folder cw_name], "FileType", "text");
cw_name = cw_name(1:end - 5);

h1 = FindThermoclineAxis(cw);
h2 = cw(end, 1);

k1_vec = zeros(1, nModes);
k2_vec = zeros(1, nModes);
modes = 1:nModes;

[k1_z, k2_z, ~] = ThreeLayerWavenumbers(pFolder, PROFILE);

im1 = imag(k1_z);
im2 = imag(k2_z);
re1 = real(k1_z);
re2 = real(k2_z);
abs1 = sqrt(im1.^2 + re1.^2);
abs2 = sqrt(im2.^2 + re2.^2);

min_abs1 = min(abs1);
weird_mode_number = find(abs1 == min_abs1)

subplot(2,2,1);
plot(modes, im1, 'DisplayName', 'k_1', 'Marker', '.');
hold on;
plot(modes, im2, 'DisplayName', 'k_2', 'Marker', '.');
xlabel('Номер моды');
ylabel('Im(k_z)');
legend;
hold off;

subplot(2,2,3); 
plot(modes, re1, 'DisplayName', 'k_1', 'Marker', '.');
hold on;
plot(modes, re2, 'DisplayName', 'k_2', 'Marker', '.');
xlabel('Номер моды');
ylabel('Re(k_z)');
legend(Location="southeast");

subplot(2, 2, [2, 4])
plot(modes, abs1, 'DisplayName', 'k_1', 'Marker', '.');
hold on;
plot(modes, abs2, 'DisplayName', 'k_2', 'Marker', '.');
xlabel('Номер моды');
ylabel('|k_z|');
legend(Location="southeast");
hold off;
sgtitle(['H = ' num2str(H) ' м,  R = ' cw_name ' м']);

savefig([resultsFolder 'wnums_R' cw_name '_H' num2str(H) '.fig']);
saveas(gcf, [resultsFolder 'wnums_R' cw_name '_H' num2str(H) '.jpg']);




