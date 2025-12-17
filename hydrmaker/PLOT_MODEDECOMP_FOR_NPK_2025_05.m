close all;
clear variables;
clc;

nmod = 10;
dz = [1, 1];
f = [20, 500];
folder = 'npk_2025_05/';

addpath(folder);

indices = [1, 2];
names = ["Homogenous cold water", "Thermocline"];
samples_folder = 'hydrology_samples/';


figure;
tiledlayout(1,3);
p = [];

for i = 1:length(f)
    ReplaceFrequencyInRAMS(folder, f(i));

    nexttile(i);
    N = 3;
    for k = indices
        MakeHydrologyFolder(folder, samples_folder, k)
        [wNum, ~, wmode] = ModeDecomposition(folder, nmod, dz(i));

        z = 1:length(wmode);
        if mod(k, 2) == 0
            style = '--';
        else
            style = '-';
        end

        for j = 1:N
            index = i + k;
            p(end + 1) = plot(wmode(:, j), z', 'LineStyle', style, ...
                        'DisplayName', ['Mode #', int2str(j), ', ' char(names(k))]);
            hold on
        end
    end

    if i == 2
        ylim([0, 40]);
    end

    title([int2str(f(i)), ' Hz']);
    xlabel('Modal function');
    ylabel('Depth, m');
    set(gca, 'YDir', 'reverse')
    grid on
end

lgd = legend(p(end - 5: end), 'Location', 'westoutside');
lgd.Layout.Tile = 3;

savefig(fullfile(folder, 'modesdecomp.fig'))
