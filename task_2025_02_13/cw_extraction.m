close all;
clear variables;
clc;

fig = openfig('1.fig');
cell = get(get(fig, 'Children'), 'Children');

line = cell{3}(1);

image = cell{3}(2);
xdata = get(image, 'XData');
ydata = get(image, 'YData')';
cdata = get(image, 'CData');

% M = [(round(1000 * x))' (-1 * y)'];
writematrix(xdata, 'range.txt', 'FileType', 'text', 'Delimiter', '\t');
writematrix(ydata, 'width.txt', 'FileType', 'text', 'Delimiter', '\t');
writematrix(cdata, 'cw.txt', 'FileType', 'text', 'Delimiter', '\t');
