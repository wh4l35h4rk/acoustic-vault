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

foldername = 'hydrology';
if not(isfolder(foldername))
    mkdir(foldername)
end

for c = 1:length(x) 
    i = find(cw_field(:, c) >= 1700, 1);
    x_data = int2str(round(x(1, c)*1000));

    M = [dep(:, 1:i-1)' cw_field(1:i-1, c)];
    writematrix(M, [foldername '\' x_data '.hydr'], 'FileType', 'text', 'Delimiter', '\t')
end


