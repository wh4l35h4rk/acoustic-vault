close all;
clear variables;
clc;

% pFolder must contain:
% - hydrology folder with sound speed profiles
% - bathymetry data
% - MainRAMS.txt

pFolder = 'EXP2_3_2025_10_22/';

dz = 0.5;
opts.nmod = 10;     % amount of computated modes

mgv = GetHydroMGV(dz, pFolder, opts);
egv = GetHydroEGV(mgv, pFolder);
time = ModesDelay(egv, pFolder); 