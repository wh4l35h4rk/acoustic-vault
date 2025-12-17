close all;
clear variables;
clc;

pFolder = 'EXP2_3_2025_10_22/';
hydro_folder = 'hydrology/';
i_profile = 2;
M_modes = 5;


% getting sound speed profile with given index

hydro_files = GetFiles([pFolder, hydro_folder, '*.hydr';], '', 'ASC');
N = size(hydro_files, 2);
assert(i_profile <= N)

cw_filepath = fullfile(pFolder, hydro_folder, hydro_files(i_profile).name);
cw = readmatrix(cw_filepath, 'FileType','text');
[~, range, ~] = fileparts(cw_filepath);


% getting modal group velocities for first 10 modes

mgv_filepath = fullfile(pFolder, "mgv.txt");
if ~exist(mgv_filepath, 'file')
    dz = 0.5;
    opts.nmod = 10;
    mgv = GetHydroMGV(dz, pFolder, opts);
else
    mgv = readmatrix(mgv_filepath, 'FileType', 'text');
end


% plot figure

figure
plot(cw(:, 2), cw(:, 1), 'DisplayName', 'c, m/s');
ylim([0, cw(end, 1)]);
set(gca, 'YDir', 'reverse');
xlabel("c, m/s");
ylabel("z, m");
grid on;
title(['R = ', range, ' m']);
hold on
    
for j = 1:M_modes
    vel = mgv(i_profile, j);
    i_closest = LocateMGVOnSpeedProfile(vel, cw);

    scatter(cw(i_closest, 2), cw(i_closest, 1), Marker="o", DisplayName=['V_{gr}^' int2str(j)], LineWidth=1.2)
end
legend('Location', 'northeastoutside');




