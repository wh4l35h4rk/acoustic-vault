close all;
clear variables;
clc;

%dz - шаг по глубине
%MP - параметры среды
%freq - частота

MP.LayersData = [ [0 1500 1500 1 1 0 0] ];

filename = 'exp_ssp_deep.mat';
% filename = 'exp_unique.hydr';

data = load(filename);
filename = split(filename, '.');

if strcmp(filename(2), 'mat')
    z = data.dep.';
    c = data.cw.';
else
    z = data(:, 1);
    c = data(:, 2);
end


dz = 0.25;
freq = 400;
zbar = 2*(z-1300)/1300;
eps = 0.00737;


MP.HydrologyData = [z c];

%nmod - количество мод
%Hb - вычислительная глубина, m
%Ngr, Tgr - параметры для экстраполяции Ричардсона
%BotBC - граничное условие Дирихле

opts.nmod = 40;
opts.Hb = z(length(z));
opts.Ngr = 3;
opts.BotBC = 'D';
opts.Tgr = 3;



tic
%[wnum, wmode] = ac_modes(z,MP,freq,0.7,'D');

%krs - волновые числа
%wmode - модовые функции
[krs, wmode] = ac_modesr(dz, MP, freq, opts);

disp(krs.');
toc



z = dz*(0:size(wmode,1)-1);

figure;
hold all;
for ii = 1:5:opts.nmod
    
    [~,im] = max(abs(wmode(:,ii)));
    
    wmode(:,ii) = wmode(im,ii)*wmode(:,ii);
    
    plot(z, wmode(:,ii));
end

mgv = ModesGroupVelocities(z,freq,krs,wmode,MP);

% figure;
% plot(krs,'--rs','LineWidth',2,...
%                 'MarkerEdgeColor','k',...
%                 'MarkerFaceColor','g',...
%                 'MarkerSize',10);


foldername = ['EXP2_1_z' int2str(opts.Hb)];
if not(isfolder(foldername))
    mkdir(foldername)
end

savefig([foldername '/wmodes_EXP2_1.fig'])

dlmwrite([foldername '/kj_f_' int2str(freq) 'Hz.txt'], (krs).','delimiter','\t','precision',10);
dlmwrite([foldername '/vgj_f_' int2str(freq) 'Hz.txt'], (mgv).','delimiter','\t','precision',10);
dlmwrite([foldername '/phij_f_' int2str(freq) 'Hz.txt'], [z.' wmode],'delimiter','\t','precision',10);

