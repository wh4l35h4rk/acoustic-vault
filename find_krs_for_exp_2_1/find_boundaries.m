close all;
clear variables;
clc;

% filename = 'exp_unique.hydr';
filename = 'exp_ssp_deep.mat';

cw = load(filename);

data = load(filename);
filename = split(filename, '.');

if strcmp(filename(2), 'mat')
    z = data.dep.';
    c = data.cw.';
else
    z = data(:, 1);
    c = data(:, 2);
end

% foldername = 'EXP2_1_z440';
foldername = 'EXP2_1_z1000';

freq = 400;
ks = load([foldername '\kj_f_400Hz.txt']);
omega = 2*pi*freq;

bounds = zeros(length(ks), 2);

% для красивых графиков
cws = zeros(length(ks), 2);
vals = zeros(length(ks), 1);

for j = 1:length(ks)
    val = omega / ks(j);

    i_up = find(c < val, 1, 'first');
    i_low = find(c < val, 1, 'last');

    z_up = z(i_up);
    z_low = z(i_low);

    bounds(j, :) = [z_up z_low]; 
    
    % для красивых графиков
    vals(j) = val;
    cws(j, :) = [c(i_up) c(i_low)];
end

ks_w_bounds = [ks bounds];
writematrix(ks_w_bounds, [foldername '/z_bounds.txt'], 'delimiter', '\t')


figure
semilogx(c, z, 'LineWidth', 1.2)
xlabel('скорость звука c(z)')
ylabel('глубина z')
xlim([0 val + 2]);
hold on
grid on
set(gca, 'YDir', 'reverse')

scatter(cws(:, 1), bounds(:, 1), [], 'blue')
scatter(cws(:, 2), bounds(:, 2), [], 'green', 'filled')
xline(vals)

legend('cw', 'Z_u', 'Z_l', 'omega / k_j')
hold off

