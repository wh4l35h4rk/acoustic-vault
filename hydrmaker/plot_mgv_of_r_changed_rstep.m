close all;
clear variables;
clc;

% plot modal group velocities for different track ranges; sound speed
% profiles are taken not from initial hydrology, but from its interpolated
% with ac_modes version

pFolder = 'EXP2-4_mgv-r-interp/';
lang = 'RUS';
% lang = 'ENG';

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

x_label = 'Range, km';
y_label = 'V_{gr}, m/s';
mode_label = 'Mode #';
if strcmp(lang, 'RUS')
    x_label = 'Расстояние, км';
    y_label = 'V_{gr}, м/с';
    mode_label = 'Мода №';
end

for i = 1:8
    if i > 5; style = '--'; else; style = '-'; end
    plot(range / 1000, mgv(:, i), "LineStyle", style, "DisplayName", [mode_label, int2str(i)], "Marker", ".", "LineWidth", 1);
    hold on;
end
grid on;
legend('Location','northeast');
xlabel(x_label);
ylabel(y_label);

savefig(fullfile(pFolder, ['mgv_of_r_changed_step_', lang, '.fig']));
