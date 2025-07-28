close all;
clear variables;
clc;

pFolder = 'EXP2_2024_11_21/';
dz0 = 1;

opts.Tgr = 3; % кол-во сеток
opts.Ngr = 3; % кол-во сеток
opts.nmod = 10;
opts.BotBC = 'D'; % дирихле (гран.)

GetHydroMGV(dz0, pFolder, opts);

