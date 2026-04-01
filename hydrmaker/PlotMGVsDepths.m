function PlotMGVsDepths(pFolder, H_vec, M_modes, profile_start, profile_end)
%PLOTMGVSDEPTHS Finds sprouting modes for different widths of bottom sound channel

% Function that takes project directory and creates several
%   variarions of it, changing overall depth on H_vec values. For each of
%   these variations depth of MGVs are calculated, and first sprouting mode
%   number is found.

% PARAMETERS:
% - pFolder: project folder;
% - H_vec: vector of depths to be added to project's initial depth. it is
%       advised for it to start with zero;
% - M_modes: amount of modes calculated;
% - profile_start: index of first profile in hydrology folder for sprouting
%       modes to be searched in;
% - profile_end: index of last profile in hydrology folder for sprouting
%       modes to be searched in;

hydro_dir = 'hydrology/';
hydro_model_dir = 'hydrology_model/';
wmn_dir = 'weird_mode_numbers/';
graphics_dir = 'graphics/';

model_path = fullfile(pFolder, hydro_model_dir);
if exist(fullfile(model_path), 'dir')
    rmdir(fullfile(model_path), 's');
end
mkdir(fullfile(model_path))

if exist(fullfile(pFolder, graphics_dir), 'dir')
    rmdir(fullfile(pFolder, graphics_dir), 's');
end
mkdir(fullfile(pFolder, graphics_dir))


% prepare set of directories with tanh approximated hydrology

hydro_files = GetFiles([pFolder, hydro_dir, '*.hydr'], '', 'ASC');
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
        mkdir(fullfile(model_path, depth_dir, hydro_dir))

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

% for each profile and added depth, reform mgvs matrices so that they show
% how mgvs change with added depth instead of range

for i = profile_start:profile_end
    mgv_of_h = zeros(K_depths, M_modes);

    for h = 1:K_depths
        depth_dir = strcat('H', num2str(H_vec(h)), '/');
        mgv_of_r = readmatrix(fullfile(model_path, depth_dir, 'mgv.txt'), ...
            'Delimiter', '\t', 'ConsecutiveDelimitersRule', 'join');
   
        mgv_of_h(h, :) = mgv_of_r(i, :);
    end

    weird_mode_number = zeros(K_depths, 2);
    figure;
    for h = 1:K_depths
        plot(modes, mgv_of_h(h, :), "Marker", "o", "DisplayName", strcat('H =', num2str(H_vec(h))));
        title(strcat('V_{gr} для R = ', num2str(ranges(i)), ' м'))
        ylabel("c, м/с");
        xlabel("Номер моды");
        grid on;
        hold on;
        legend(Location="eastoutside");
    
        % get number of first sprouting mode: it's the one that has the highest group velocity

        weird_mode_number(h, 1) = H_vec(h);
        weird_mode_number(h, 2) = find((mgv_of_h(h, :) == max(mgv_of_h(h, :))), 1);

        if (max(mgv_of_h(h, :)) == 0)
            weird_mode_number(h, 2) = 0;
        end
    end

    savefig(fullfile(pFolder, graphics_dir, strcat('mgv-of-H_', num2str(ranges(i)), '.fig')));
    writematrix(weird_mode_number, fullfile(pFolder, wmn_dir, strcat(num2str(ranges(i)), '.txt')), Delimiter='\t');
end
