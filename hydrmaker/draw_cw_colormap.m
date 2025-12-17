close all;
clear variables;
clc;

nmod = 10;
dz = 1;
f = 400;
pFolder = 'EXP2_2_2025_09_20/';
hydrFolder = 'hydrology/';

% ModeDecomposition(pFolder,nmod,dz);

bath = load(fullfile(pFolder, 'bath.txt'));

RamsData = LoadConfigRAMS(pFolder);

fHydrList = '*.hydr';
fHydrList = GetFiles([pFolder, hydrFolder, fHydrList], '', 'ASC');
RANGES = [];
num = size(fHydrList,2);

for ii = 1:num
 hydr = dlmread([pFolder hydrFolder fHydrList(ii).name]);
 [~,b,~] = fileparts([fHydrList(ii).name]);
 RANGES(ii) = str2double(b);
end

dmax = max(bath(:, 2));
new_depth = linspace(0, dmax , dmax + 1 );

[X, Y] = meshgrid(RANGES, new_depth);

HYDRO = [];
for ii = 1:num
 hydro = dlmread([pFolder hydrFolder fHydrList(ii).name]);
 d = hydro(:,1);
 cw = hydro(:,2); 
 HYDRO(:, ii) = (interp1(d, cw, new_depth))';
end

for ii = 2:dmax + 1
  for jj = 1:num
    if(isnan(HYDRO(ii, jj)))
       HYDRO(ii, jj) = HYDRO(ii - 1, jj);
    end
  end
end

[~, dr, dzf, aFieldP] = ReadRamsBinary([pFolder 'results/']);
rmax = RamsData.rmax;
rstep = 500 ; %range in metres
r = linspace(0, rmax, rmax/rstep);

r1 = RamsData.bath(:,1);
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

find_res = find(bath(:, 2) > 200);
small_bath = bath(1:find_res - 1, :);

figure;
subplot(2, 1, 1);
imagesc(r1/1000, new_depth(1:200), Z1(1:200, :));
set(gca, 'YDir', 'reverse');
hold all;
plot(small_bath(:, 1)/1000, small_bath(:, 2), 'color', 'white', 'linewidth', 1.5)
xlabel('Range, km');
ylabel('Depth, m');
colorbar;
colormap('jet');
caxis([1455 1520]);
hold off;

subplot(2, 1, 2);
imagesc(r1/1000, new_depth, Z1);
set(gca, 'YDir', 'reverse');
hold all;
plot(bath(:, 1)/1000, bath(:, 2), 'color', 'white', 'linewidth', 1.5)
xlabel('Range, km');
ylim([0 1200])
ylabel('Depth, m');
colorbar;
colormap('jet');
caxis([1455 1520]);
hold off;



