close all;
clear variables;
clc;

fig = openfig('bath.fig');
get(fig, 'Children')
x = get(get(get(fig, 'Children'), 'Children'), 'xdata');
y = get(get(get(fig, 'Children'), 'Children'), 'ydata');

M = [(round(1000 * x))' (-1 * y)'];
writematrix(M, 'bath.txt', 'FileType', 'text', 'Delimiter', '\t');