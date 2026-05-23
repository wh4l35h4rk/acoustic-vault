close all;
clear variables;
clc;

nmod = 10;
dz = 1;
f = 400;
pFolder = 'EXP2-2_time-estimation/';
hydrFolder = 'hydrology/';
lang = 'RUS';
% lang = 'ENG';

% ModeDecomposition(pFolder, nmod, dz);


% load ranges from hydrology files names

hydro_files = GetFiles([pFolder, hydrFolder, '*.hydr'], '', 'ASC');
hydrology_files_amount = size(hydro_files, 2);
RANGES = [];

for ii = 1:hydrology_files_amount
 [~, r, ~] = fileparts([hydro_files(ii).name]);
 RANGES(ii) = str2double(r);
end


% load bathymetry data

bath = load(fullfile(pFolder, 'bath.txt'));
max_depth = max(bath(:, 2));
new_depth = linspace(0, max_depth, max_depth + 1);  % sets dz to 1?

[X, Y] = meshgrid(RANGES, new_depth);


% interpolate sound speed profiles to new depth

HYDRO = [];
for ii = 1:hydrology_files_amount
    hydro = dlmread([pFolder hydrFolder hydro_files(ii).name]);
    d = hydro(:,1);
    cw = hydro(:,2); 
    HYDRO(:, ii) = (interp1(d, cw, new_depth))';
end

for ii = 2:max_depth + 1
    for jj = 1:hydrology_files_amount
        if (isnan(HYDRO(ii, jj)))
            HYDRO(ii, jj) = HYDRO(ii - 1, jj);
        end
    end
end


% interpolate rams-made hydrology

RamsData = LoadConfigRAMS(pFolder);
rmax = RamsData.rmax;
rstep = 500; % range in metres
r = linspace(0, rmax, rmax/rstep);

r1 = RamsData.bath(:, 1);
[X1, Y1] = meshgrid(r1, new_depth);
Z1 = interp2(X, Y, HYDRO, X1, Y1);


for ii = 2:length(r1)
    if (isnan(Z1(:,ii)))
        Z1(:,ii) = Z1(:,ii - 1);
    end
end

for ii = 1:length(r1) - 1
    if (isnan(Z1(ii,:)))
        Z1(ii,:) = Z1(ii + 1,:);
    end
end


% set sound speed in bottom to 1700

for ii = 1:length(r1)
    target_r = r1(ii);
    ab = 5000;
    target_bath = 0;
    for jj = 1:length(bath)
        bath_r = bath(jj, 1);
        if (abs(target_r - bath_r) < ab)
            ab = abs(target_r - bath_r);
            target_bath = bath(jj, 2);
        end
    end
    Z1(round(target_bath):end, ii) = 1700;
end


% set depth considered shallow for a more detailed subplot

find_res = find(bath(:, 2) > 200);
small_bath = bath(1:find_res - 1, :);


% set labels for axes depending on language

x_label = 'Range, km';
y_label = 'Depth, m';
if strcmp(lang, 'RUS')
    x_label = 'Расстояние, км';
    y_label = 'Глубина, м';
end


% plot 2 subplots for detailed view of shallow water sound speed

tcl = tiledlayout(2, 1);
tcl.TileSpacing = 'compact';

t1 = nexttile();

imagesc(r1/1000, new_depth(1:200), Z1(1:200, :));
set(gca, 'YDir', 'reverse');
hold on;
p1 = plot(small_bath(:, 1)/1000, small_bath(:, 2), 'color', 'white', 'linewidth', 1.5);
% xlabel(x_label);
% t1.XTick = [];
ylabel(y_label);
colormap('jet');
caxis([1455 1520]);
hold off;

t2 = nexttile();

imagesc(r1/1000, new_depth, Z1);
set(gca, 'YDir', 'reverse');
hold on;
plot(bath(:, 1)/1000, bath(:, 2), 'color', 'white', 'linewidth', 1.5)
xlabel(x_label);
ylabel(y_label);
ylim([0 1200])
colormap('jet');
caxis([1455 1520]);
hold off;

cb = colorbar(); 
cb.Layout.Tile = 'east';

