close all;
clear variables;
clc;

% plot sound speed profile and modal functions on the same figure to
% illustrate its dependency 

pFolder = 'EXP2_3_2025_10_22/';
hydro_folder = 'hydrology/';
bounds_folder = 'modal_localisation_intervals/';

hydro_files = GetFiles([pFolder, hydro_folder, '*.hydr';], '', 'ASC');
bounds_files = GetFiles([pFolder, bounds_folder, '*.txt'], '', 'ASC');
N = size(hydro_files, 2);

RamsData = LoadConfigRAMS(pFolder);

dz = 1;
N_modes = 10;
f = 400;
omega = 2*pi*f; 


range_start = 4;
range_end = 5;
m_start = 1;
m_end = 5;

for i = range_start:range_end
    file = hydro_files(i).name;
    [~, range, ~] = fileparts(file);
    cw = readmatrix(fullfile(pFolder, hydro_folder, file), 'FileType','text');

    z = cw(:, 1);
    c = cw(:, 2);

    max_depth = z(end);
    MP.LayersData = [[0 1450 1450 1 1 0 0]; 
                     [max_depth 1450 RamsData.bParams(1, 1) 1 RamsData.bParams(1, 3) 0 0]];
    MP.HydrologyData = [z c];

    if max_depth >= 500
        opts.Hb = max_depth + 500;
    elseif max_depth < 100
        opts.Hb = 200;
    else
        opts.Hb = 2 * MP.LayersData(end, 1);
    end
    opts.nmod = N_modes;

    [wNum, wmode] = ac_modesr(dz, MP, f, opts);
    z_mode = dz * (0:size(wmode, 1) - 1);
    

%     for M = m_start:m_end
%         mode = wmode(:, M);
%         figure;
%         title(['R = ' range ' m']);
%         plot(c, z, 'DisplayName', ['C_w #' int2str(M)]);
%         ylim([0, z(end)]);
%         set(gca, 'YDir', 'reverse');
%         xlabel("c, m/s")
%         ylabel("z, m")
%         axes('color', 'none', 'XAxisLocation', 'top', 'YAxisLocation', 'right');
%         hold on;
%         plot(mode, z_mode, 'Color', 'red', 'DisplayName', ['Mode #' int2str(M)]);
%         ylim([0, z(end)]);
%         xlim([-max(abs(mode)), max(abs(mode))]);
%         set(gca, 'YDir', 'reverse');
%         legend('Location', 'northwest');
%     end


    bounds_file = bounds_files(i).name;
    boundaries = readmatrix(fullfile(pFolder, bounds_folder, bounds_file));

    for M = m_start:m_end
        mode = wmode(:, M);
        b = boundaries(:, M);

        c_high = cw(cw(:, 1) == b(1), 2);
        c_low = cw(cw(:, 1) == b(2), 2);

        figure;
        subplot(1, 2, 1)
        plot(c, z);
        ylim([0, z(end)]);
        set(gca, 'YDir', 'reverse');
        xlabel("c, m/s");
        ylabel("z, m");
        grid on;
        hold on
        yline(b(1));
        yline(b(2));
        plot(c_high, b(1), 'o', 'Color', 'red')
        plot(c_low, b(2), 'o', 'Color', 'red')
        hold off

        i_high = find(z_mode == b(1));
        i_low = find(z_mode == b(2));
    
        subplot(1, 2, 2)
        plot(mode, z_mode, 'Color', 'red', 'DisplayName', ['Mode #' int2str(M)]);
        ylim([0, z(end)]);
        xlim([-max(abs(mode)), max(abs(mode))]);
        xlabel(['Modal function #',num2str(M)]);
        set(gca, 'YDir', 'reverse');
        grid on;
        hold on
        yline(b(1));
        yline(b(2));
        plot(mode(i_high), b(1), 'o', 'Color', 'red')
        plot(mode(i_low), b(2), 'o', 'Color', 'red')
        hold off

        sgtitle(['R = ' range ' m']);
    end


%     figure;
% %     subplot(1, 2, 1)
%     plot(c, z);
%     ylim([0, z(end)]);
%     set(gca, 'YDir', 'reverse');
%     xlabel("c, m/s");
%     ylabel("z, m");
%     grid on;
%     hold on
% 
%     for M = m_start:m_end
%         mode = wmode(:, M);
%         b = boundaries(:, M);
% 
%         c_high = cw(cw(:, 1) == b(1), 2);
%         c_low = cw(cw(:, 1) == b(2), 2);
%         
%         yline(b(1));
%         yline(b(2));
%         plot(c_high, b(1), 'o', 'Color', 'red')
%         plot(c_low, b(2), 'o', 'Color', 'green')
%     end
%     hold off
% 
% %     i_high = find(z_mode == b(1));
% %     i_low = find(z_mode == b(2));
% 
% %     subplot(1, 2, 2)
% %     plot(mode, z_mode, 'Color', 'red', 'DisplayName', ['Mode #' int2str(M)]);
% %     ylim([0, z(end)]);
% %     xlim([-max(abs(mode)), max(abs(mode))]);
% %     xlabel(['Modal function #',num2str(M)]);
% %     set(gca, 'YDir', 'reverse');
% %     grid on;
% %     hold on
% %     yline(b(1));
% %     yline(b(2));
% %     plot(mode(i_high), b(1), 'o', 'Color', 'red')
% %     plot(mode(i_low), b(2), 'o', 'Color', 'red')
% %     hold off
% 
%     title(['R = ' range ' m']);


end    

