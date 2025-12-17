close all;
clear variables;
clc;

pFolder = 'EXP2_2_2025_09_20/';

if isfile(fullfile(pFolder, 'egv.txt'))
    egv = load(fullfile(pFolder, 'egv.txt'));
else 
    dz0 = 1;
    opts.Tgr = 3; opts.Ngr = 3;
    opts.nmod = 10;
    opts.BotBC = 'D';
    
    mgv = GetHydroMGV(dz0, pFolder, opts);
    egv = GetHydroEGV(mgv, pFolder);
end
s = size(egv);
N_mod = s(2);

[ranges, ~] = GetTrackRanges(pFolder);

dist = load(fullfile(pFolder, 'reciever_dist.txt'));
M_signals = length(dist);

time = zeros(N_mod, M_signals);

for i = 1:M_signals
    ranges(end) = round(dist(i) * 1000);
    intervals = diff(ranges);

    delays = intervals ./ egv;
    time(:, i) = sum(delays, 1);
end

writematrix(num2str(time), [pFolder 'time_delays_fixed.txt'], 'Delimiter', '\t');
