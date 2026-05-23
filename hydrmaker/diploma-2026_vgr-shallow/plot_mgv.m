close all;
clear variables;
clc;

mgv = readmatrix('mgv.txt');
N_modes = size(mgv, 2);

figure;

set(0, 'DefaultAxesFontSize', 14, 'DefaultAxesFontName', 'Arial');
set(0, 'DefaultTextFontSize', 16, 'DefaultTextFontName', 'Arial'); 

modes = 1:N_modes;
plot(modes, mgv(1, :), "LineWidth", 1, "Marker","o");

grid on;
xlabel('Номер моды');
ylabel('V_{gr}, м/с');
xlim([1 10])
