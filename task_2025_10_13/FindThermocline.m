function [first, last] = FindThermocline(f)

cw = f(:, 2);
N = length(cw);
d = zeros(N - 1, 1);
for i = 2:N
    d(i) = abs(cw(i) - cw(i - 1));
end

mean_d = mean(d);
first = find(d > mean_d, 1);
last = find(d > mean_d, 1, 'last');

end

% close all;
% clear variables;
% clc;
% 
% f = readmatrix('Hydrology_2015.07.22_18.45_St.145.hydr', 'FileType', 'text');
% 
% cw = f(:, 2);
% N = length(cw);
% d = zeros(N - 1, 1);
% for i = 2:N
%     d(i) = abs(cw(i) - cw(i - 1));
% end
% 
% mean_d = mean(d);
% first = find(d > mean_d, 1);
% last = find(d > mean_d, 1, 'last');
% 
% % plot(f(:, 2), f(:, 1))
% % set(gca, 'YDir', 'reverse')
% 
% plot(d)