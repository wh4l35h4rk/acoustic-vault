close all;
clear variables;
clc;

pFolder = 'EXP2-5_tanh-approx/';
hydro_folder = 'hydrology/';

hydro_files = GetFiles([pFolder, hydro_folder, '*.hydr'], '', 'ASC');
N = size(hydro_files, 2);

for i = 1:N
    file = hydro_files(i).name;
    cw_approx = FitThermoclineWTanh(pFolder, file);
end  

