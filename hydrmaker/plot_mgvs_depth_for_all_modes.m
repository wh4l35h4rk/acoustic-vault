close all;
clear variables;
clc;

H_vec = 0:5:50;
M_modes = 15;
profile_start = 2;
profile_end = 3;
pFolder = 'EXP2-5_tanh-approx/';

hydro_dir = 'hydrology/';
hydro_model_dir = 'hydrology_model/';
wmn_dir = 'weird_mode_numbers/';
graphics_dir = 'graphics/';

model_path = fullfile(pFolder, hydro_model_dir);
if ~exist(fullfile(model_path), 'dir')
    mkdir(fullfile(model_path))
end
if ~exist(fullfile(pFolder, graphics_dir), 'dir')
    mkdir(fullfile(pFolder, graphics_dir))
end


% prepare set of directories with tanh approximated hydrology

hydro_files = GetFiles([pFolder, hydro_dir, '*.hydr'], '', 'ASC');

cw = readmatrix(fullfile(pFolder, hydro_dir, hydro_files(end).name), FileType="text");
cw_example_max_depth =  cw(end, 1) * 4;


N_hydr = length(hydro_files);
ranges = zeros(1, N_hydr);

for i = 1:N_hydr
    file = hydro_files(i).name;
    [~, range, ~] = fileparts(file);
    ranges(i) = str2double(range);

    cw = readmatrix(fullfile(pFolder, hydro_dir, file), FileType="text");
    H_base = cw(end, 1);
    
    for H = H_vec
        depth_dir = strcat('H', num2str(H), '/');
        if ~exist(fullfile(model_path, depth_dir, hydro_dir), 'dir')
            mkdir(fullfile(model_path, depth_dir, hydro_dir))
        end

        ExpandTanhApproxToH(pFolder, range, H_base, H);
    end
end


% add bottom.txt, bath.txt and MainRAMS.txt to approximated hydrolofy directories

for H = H_vec
    depth_dir = strcat('H', num2str(H), '/');
    copyfile(fullfile(pFolder, 'bottom.txt'), fullfile(model_path, depth_dir, 'bottom.txt'));
    copyfile(fullfile(pFolder, 'MainRAMS.txt'), fullfile(model_path, depth_dir, 'MainRAMS.txt'));

    % replace an actual bottom with model, which has depth increased by H 

    bath = readmatrix(fullfile(pFolder, 'bath.txt'));
    bath(:, 2) = bath(:, 2) + H;
    writematrix(bath, fullfile(model_path, depth_dir, 'bath.txt'), Delimiter='\t'); 

    % switch maximal depth and source depth in RAMS file with increased by H
    
    RamsData = LoadConfigRAMS(fullfile(model_path, depth_dir));
    ReplaceParameterInRAMS(fullfile(model_path, depth_dir), 'zmax', RamsData.zmax + H);
    ReplaceParameterInRAMS(fullfile(model_path, depth_dir), 'zs', RamsData.zs + H);

    % find depths where MGV equals to profile sound speed

    CalculateMGVDepth(pFolder, M_modes, 1, fullfile(hydro_model_dir, depth_dir));
end


% make directory to store number of modes fitting under thermocline in

if ~exist(fullfile(pFolder, wmn_dir), 'dir')
    mkdir(fullfile(pFolder, wmn_dir))
end


K_depths = length(H_vec);
modes = 1:M_modes;

for i = profile_start:profile_end
    z_vgr_of_h = zeros(K_depths, M_modes);
    mgv_of_h = zeros(K_depths, M_modes);

    for h = 1:K_depths
        depth_dir = strcat('H', num2str(H_vec(h)), '/');
        z_vgr_of_r = readmatrix(fullfile(model_path, depth_dir, 'zVgr.txt'));
        mgv_of_r = readmatrix(fullfile(model_path, depth_dir, 'mgv.txt'));

        z_vgr_of_h(h, :) = z_vgr_of_r(i, :);
        mgv_of_h(h, :) = mgv_of_r(i, :);
    end


    %  plot how MGV depth changes with mode number for different H
    
    weird_mode_number = zeros(K_depths, 2);
    figure;
    for h = 1:K_depths
        plot(modes, z_vgr_of_h(h, :), "Marker", "o", "DisplayName", strcat('H =', num2str(H_vec(h))));
        title(strcat('Глубина V_{gr} для R = ', num2str(ranges(i)), ' м'))
        ylabel("z, м");
        xlabel("Номер моды");
        set(gca, 'YDir', 'reverse');
        grid on;
        hold on;
        legend(Location="eastoutside");
    
        weird_mode_number(h, 1) = H_vec(h);
        weird_mode_number(h, 2) = find((z_vgr_of_h(h, :) == min(z_vgr_of_h(h, :))), 1);

        if (min(z_vgr_of_h(h, :)) == 0)
            weird_mode_number(h, 2) = 0;
        end
    end

    min_z = min(z_vgr_of_h, [], "all");
    max_z = max(z_vgr_of_h, [], "all");
    if max_z >= cw_example_max_depth
        max_z = max(z_vgr_of_h(z_vgr_of_h ~= max_z));
    end
    if ~(min_z == 0 && max_z == 0)
        ylim([min_z max_z])
    end
    savefig(fullfile(pFolder, graphics_dir, strcat('mgv-depth-of-H_', num2str(ranges(i)), '.fig')));

    writematrix(weird_mode_number, fullfile(pFolder, wmn_dir, strcat(num2str(ranges(i)), '.txt')), Delimiter='\t');


    % plot dependency between H and number of mode no longer fitting under thermocline

    figure;
    scatter(weird_mode_number(:, 2), weird_mode_number(:, 1));
    title(strcat('Глубина V_{gr} для R = ', num2str(ranges(i)), ' м'))
    ylabel("Добавленная глубина H, м");
    xlabel("Номер моды, выныривающей из-под термоклина");
    grid on;
end

