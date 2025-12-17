close all
clear variables
clc

M = readmatrix('90000.hydr', 'FileType', 'text');
y = M(:, 1);
x = M(:, 2);

figure
grid on
semilogy(x, y, 'LineWidth', 1.2)
hold on
set(gca, 'YDir', 'reverse')
ylim([0 3500])

title('профиль скорости звука')
xlabel('скорость звука, м/сек')
ylabel('глубина, м')

hold off