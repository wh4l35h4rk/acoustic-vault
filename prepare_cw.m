close all
clear variables
clc

file = 'hydrology_2023_20.mat';
cw_field = load(file).cw_field;
dep = load(file).dep;
x = load(file).x;

for c = 1:length(x)
    for r = 1:length(dep)
        if (1530 <= cw_field(r, c)) && (cw_field(r, c) <= 1700)
           cw_field(r, c) = 1700;
        end
    end
end

figure
set(gca, 'YDir', 'reverse')
imagesc(x, dep, cw_field)