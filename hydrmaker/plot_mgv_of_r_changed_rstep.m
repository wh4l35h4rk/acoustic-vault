close all;
clear variables;
clc;

% plot modal group velocities for different track ranges; sound speed
% profiles are taken not from initial hydrology, but from its interpolated
% with ac_modes version

pFolder = 'EXP2_4_2025_10_30/';

dz = 1;
opts.nmod = 10;

% SwitchHydrologyWithInterpolated(pFolder, opts.nmod, dz)

mgv = GetHydroMGV(dz, pFolder, opts);


hydro_folder = 'hydrology/';
hydro_files = '*.hydr';

hydro_files = GetFiles([pFolder, hydro_folder, hydro_files], '', 'ASC');
len = size(hydro_files, 2);

range = zeros(1, len);
for i = 1:len
    file = hydro_files(i).name;
    [~, range_name, ~] = fileparts(file);
    range(i) = str2double(range_name);
end

N_modes = size(mgv, 2);

figure;

set(0, 'DefaultAxesFontSize', 14, 'DefaultAxesFontName', 'Arial');
set(0, 'DefaultTextFontSize', 16, 'DefaultTextFontName', 'Arial'); 

for i = 1:10
    if i > 5; style = '--'; else; style = '-'; end
    plot(range, mgv(:, i), "LineStyle", style, "DisplayName", ['Mode #', int2str(i)], "Marker", ".", "LineWidth", 1);
    hold on;
end
grid on;
legend('Location','northeast');
xlabel('Range, m');
ylabel('V_{gr}');
