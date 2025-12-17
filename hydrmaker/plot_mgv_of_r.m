close all;
clear variables;
clc;

% plot modes' group velocities for different track ranges

pFolder = 'EXP2_3_2025_10_22/';
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

mgv = readmatrix(fullfile(pFolder, "mgv.txt"));
N_modes = size(mgv, 2);

figure;

set(0, 'DefaultAxesFontSize', 14, 'DefaultAxesFontName', 'Arial');
set(0, 'DefaultTextFontSize', 16, 'DefaultTextFontName', 'Arial'); 

for i = 1:N_modes
    if i > 5; style = '--'; else; style = '-'; end
    plot(range, mgv(:, i), "LineStyle", style, "DisplayName", ['Mode #', int2str(i)], "Marker", ".", "LineWidth", 1);
    hold on;
end
grid on;
legend('Location','northeast');
xlabel('Range, m');
ylabel('V_{gr}');
