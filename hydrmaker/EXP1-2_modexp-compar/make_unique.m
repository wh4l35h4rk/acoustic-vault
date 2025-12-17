close all;
clear variables;
clc;

files = dir('hydrology\*.hydr');
exp = load("exp.hydr");
cw = load('test.hydr');

% searching 4 unique exp data
depth = exp(:, 1);
sound = exp(:, 2);
[d_u, ind] = unique(depth);
depth1 = d_u;
sound1 = sound(ind);
exp = [depth1 sound1];

writematrix(exp, 'exp_unique.hydr', 'FileType', 'text', 'Delimiter', '\t')

% dep_exp = exp(:,1);
% sp_exp = exp(:,2);
% end_of_exp = round(dep_exp(end,1));

% i = find(cw(:, 1) > end_of_exp, 1);
% dep = [exp(:, :); cw(i:end, :)];