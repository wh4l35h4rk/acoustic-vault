close all;
clear variables;
clc;

nmod = 10;
dz = 1;
f = 400;
pFolder = 'EXP2_3_2025_10_22/';

[wNum, mAmpl, wmode] = ModeDecomposition(pFolder, nmod, dz);
writematrix(wmode, [pFolder 'wmodes.txt'], "Delimiter", '\t');