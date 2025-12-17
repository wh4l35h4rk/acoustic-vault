close all
clear variables
clc

cw = readmatrix('cw.txt', 'FileType', 'text');
range = readmatrix('range.txt', 'FileType', 'text');
width = readmatrix('width.txt', 'FileType', 'text');

cntc = contourc(range, width, cw);

figure
cntf = contourf(range, width, cw, 15);
colorbar
grid on
hold on
plot(range, zeros(size(range)), 'Color', 'white', 'LineWidth', 1.2)

title('Bath across the track')
xlabel('Range, km')
ylabel('Width, km')

hold off
savefig('cntrf.fig');

% imagesc(cw)
% [X,Y] = meshgrid(range, width);
% ax1 = axes(range);
% contour(X, Y, cw)
