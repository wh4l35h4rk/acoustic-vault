close all
clear variables
clc

files = dir('hydrology\*.hydr');
sz = size(files);
M = zeros(sz(1), 3);

row = 0;
for file = files'
    cw = load(['hydrology\', file.name]);
    sz = size(cw);
    if sz(1) >= 900
        row = row + 1;
         [file.name cw(60, 2) cw(900, 2)]
        M(row:1, row:3) = [file.name cw(60, 2) cw(900, 2)];
    end
end
