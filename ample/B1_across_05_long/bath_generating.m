close all
clear variables
clc

set(0, 'DefaultAxesFontSize', 14, 'DefaultAxesFontName', 'Arial');
set(0, 'DefaultTextFontSize', 16, 'DefaultTextFontName', 'Arial'); 

%% across 
x1 = 50000;
rstep = 100;
y1 = 4000;
h0 = 50;
x = [0 x1 x1 + 500];
y = [-y1 y1];
angles = [0.5];

alpha = pi*angles./180;
for ii = 1:length(alpha)
    %bath = h0 + tan(alpha(ii)).*(y - y1/2);
    bath = h0 + tan(alpha(ii)).*(y);
    bath1 = repmat(bath, length(x), 1);
    figure
    imagesc(x/1000, y/1000, bath1')
    hold on
    colorbar
    colormap(jet)
    set(gca, 'YDir', 'reverse')
    xlabel('Îסü X, ךל')
    ylabel('Îסü Y, ךל')
    grid on
    if ~exist(['B1_across_' num2str(angles(ii))], 'dir')
        mkdir(['B1_across_' num2str(angles(ii))])
    end
    dlmwrite(['bath.txt'], bath1, 'delimiter', '\t', 'precision', '%.3f');
    dlmwrite(['x_axe.txt'], x', 'delimiter', '\t', 'precision', '%.3f');
    dlmwrite(['y_axe.txt'], y', 'delimiter', '\t', 'precision', '%.3f');
end