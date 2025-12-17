close all;
clear variables;
clc;

pFolder = 'EXP2-5_tanh-approx/';

wmn_folder = 'weird_mode_number_of_z/';

files = GetFiles([pFolder, wmn_folder, '*.txt'], '', 'ASC');
m = readmatrix(fullfile(pFolder, wmn_folder, files(1).name));

N = size(files, 2);

x_data = zeros(size(m, 1), N);
y_data = zeros(size(m, 1), N);

x_data(:, 1) = m(:, 1);
y_data(:, 1) = m(:, 2);

for i = 2:N
    m = readmatrix(fullfile(pFolder, wmn_folder, files(i).name));
    x_data(:, i) = m(:, 1);
    y_data(:, i) = m(:, 2);
end


f = 400;
c = 1450;
lambda = c / f;
k0 = 0;

fun = @(k, x_data) k * x_data / lambda;
k = lsqcurvefit(fun, k0, x_data, y_data)

figure;
for i = 1:N
    plot(x_data(:, i), k * x_data(:, i) / lambda);
    hold on;
end
scatter(x_data, y_data);
xlabel("Глубина под термоклином");
ylabel("Кол-во мод");
