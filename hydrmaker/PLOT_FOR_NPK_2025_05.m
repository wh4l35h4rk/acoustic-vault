close all;
clear variables;
clc;

folder = 'npk_2025_05/';
addpath(folder);


min_frequency = 10;
max_frequency = 1000;

freqs = GetFrequencies(min_frequency, max_frequency);
M = length(freqs);
TL = zeros(M, 1);

for j = 1:M
    new_freq = freqs(j);
    ReplaceFrequencyInRAMS(folder, new_freq)

    RunModel(folder)
    
    results_folder = 'results/';
    tl_file = readmatrix([folder results_folder 'tl.nLine.Txt']);
    TL(j) = tl_file(end, 4);
end

TL_matrix = [freqs TL];

postfix = 'storm';    % change for different samples
writematrix(TL_matrix, [folder 'tl_' postfix],  Delimiter='tab')

x = TL_matrix(:, 1); 
y = TL_matrix(:, 2); 

figure

plot(x, y, 'LineWidth', 2); 
set(gca, 'XScale', 'log');
xlabel('frequency, Hz');
ylabel('TL, dB');
title('TL(f)');
grid on;
