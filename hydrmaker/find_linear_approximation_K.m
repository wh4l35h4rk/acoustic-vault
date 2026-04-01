close all;
clear variables;
clc;

pFolder = 'EXP2-6_tanh-variants/original/';

wmn_folder = 'weird_mode_number_of_z/';
graphics_folder = 'graphics/';
if ~exist(fullfile(pFolder, graphics_folder), 'dir')
    mkdir(fullfile(pFolder, graphics_folder))
end


files = GetFiles([pFolder, wmn_folder, '*.txt'], '', 'ASC');
m = readmatrix(fullfile(pFolder, wmn_folder, files(1).name));

N = size(files, 2);
ranges = zeros(N);

x_data = zeros(size(m, 1), N);
y_data = zeros(size(m, 1), N);

x_data(:, 1) = m(:, 1);
y_data(:, 1) = m(:, 2);

for i = 2:N
    m = readmatrix(fullfile(pFolder, wmn_folder, files(i).name));

    [~, range, ~] = fileparts(files(i).name);
    cell_range = regexp(range,'\d*','Match');
    ranges(i) = str2double(cell_range(end));

    x_data(:, i) = m(:, 1);
    y_data(:, i) = m(:, 2);
end


f = 400;
c = 1450;
lambda = c / f;

k0 = [1, 0];
% k0 = 1;

fun = @(k, x_data) k(1) * x_data * lambda + k(2);
% fun = @(k, x_data) k * x_data * lambda;

k = zeros(2, N);
ydata_pred = zeros(size(y_data));

figure;
for i = 1:N
    k0 = [1, 0];
    k(:, i) = lsqcurvefit(fun, k0, x_data(:, i), y_data(:, i))
    ydata_pred(:, i) =  k(1, i) * x_data(:, i) * lambda + k(2, i);
%     ydata_pred =  k * x_data * lambda;

    plot(x_data(:, i), ydata_pred(:, i), 'HandleVisibility','off');
    hold on;
end

p = zeros(N);
for i = 1:N
    scatter(x_data(:, i), y_data(:, i), DisplayName=strcat('R = ', num2str(ranges(i)), ' m'));
end

legend(Location="northwest");
xlabel("Глубина под термоклином, м");
ylabel("Кол-во мод");


savefig(fullfile(pFolder, graphics_folder, strcat('linear_approx.fig')));
saveas(gcf, fullfile(pFolder, graphics_folder, strcat('linear_approx.jpeg')));