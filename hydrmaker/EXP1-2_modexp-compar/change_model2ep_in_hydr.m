close all;
clear variables;
clc;

files = dir('hydrology_old\*.hydr');
exp = load("exp.hydr");

foldername = 'hydrology';
if not(isfolder(foldername))
    mkdir(foldername)
end

dep_exp = exp(:,1);
sp_exp = exp(:,2);
end_of_exp = round(dep_exp(end,1));

depth = exp(:, 1);
sound = exp(:, 2);
[d_u, ind] = unique(depth);
depth1 = d_u;
sound1 = sound(ind);
exp = [depth1 sound1];

for file = files'
    km = str2double(file.name(1:end-8));
    if km < 60
       copyfile(['hydrology_old\', file.name], ['hydrology\', file.name])
    end
    if km >= 70
        cw = load(['hydrology_old\', file.name]);
        i = find(cw(:, 1) > end_of_exp, 1);
        M = [exp(:, :); cw(i:end, :)];
        writematrix(M, ['hydrology\', file.name], 'FileType', 'text', 'Delimiter', '\t')
    end
end
