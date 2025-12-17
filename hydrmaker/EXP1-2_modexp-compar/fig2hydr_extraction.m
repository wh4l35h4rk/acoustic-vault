close all;
clear variables;
clc;

fig = openfig('гидро.fig');
axes = get(fig, 'Children');
x = get(get(axes(3,1), 'Children'), 'xdata');
y = get(get(axes(3,1), 'Children'), 'ydata');

M = [(-1 * y)' x'];
writematrix(M, 'exp.hydr', 'FileType', 'text', 'Delimiter', '\t');