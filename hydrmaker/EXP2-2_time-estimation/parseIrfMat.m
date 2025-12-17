close all;
clear variables;
clc;

mat = load('IRF_var_freqs.mat');
freqs = mat.freqs;
irf = mat.irf;
time = mat.time;
modal_time = load("time_delays.txt");
modal_time_fixed = load("time_delays_fixed.txt");

line_color = ['b' 'g' 'y' 'c' 'm' 'r'];

Nmod = length(modal_time);
Mmod = min(Nmod, 5);

p = zeros(1, Nmod);

figure;
plot(time, irf(1, :) / max(irf(1, :)), 'LineWidth', 0.2);

for i = 1:Mmod
    p(i) = xline(modal_time_fixed(i, end), 'LineWidth', 1.5, 'Color', line_color(i), 'DisplayName', "Мода " + i);
end

for j = (Mmod + 1):Nmod
    p(j) = xline(modal_time_fixed(j, end), 'LineWidth', 1.5, 'Color', line_color(j - Mmod), 'DisplayName', "Мода " + j, LineStyle="--");
end

xlabel("Время, с");
legend(p(1:Nmod), Location="eastoutside")
xlim([24.3 25.7]) 

savefig('modes.fig')
