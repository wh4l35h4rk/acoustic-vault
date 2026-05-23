function [aFieldTL, range, depth]=PlotResults(pFolder)

set(0, 'DefaultAxesFontSize', 16, 'DefaultAxesFontName', 'Arial');
set(0, 'DefaultTextFontSize', 16, 'DefaultTextFontName', 'Arial'); 


tlDat = dlmread([pFolder 'results/' 'tl.nLine.Txt']);

% TL(r) plot at z = zr

% CoupleTL  = dlmread([pFolder 'CoupleAtt.TL']); 
% 
load('Params.mat')
save(['tlDat_dz_' num2str(dz) '_dr' num2str(dr) '_drProf' int2str(drProf) '.mat' ] , 'tlDat', 'dz', 'dr', 'drProf' );

figure;
plot(tlDat(:,1)/1000,tlDat(:,3),'linewidth',2,'color','black');
title(['dz = ' num2str(dz) 'm, dr = ' num2str(dr) 'm, drProf = ' int2str(drProf) ]);
xlim([60 75]);
% hold on;
% plot(CoupleTL(:,1),-CoupleTL(:,2),'color','red','linestyle','--','linewidth',2);

figure;
plot(tlDat(:,1)/1000,tlDat(:,3),'linewidth',2,'color','black');
title(['dz = ' num2str(dz) 'm, dr = ' num2str(dr) 'm, drProf = ' int2str(drProf) ]);
xlim([120 135]);

bottom(:,1) = tlDat(:,1);
bottom(:,2) = tlDat(:,end);


[aFieldTL, dr, dz, aFieldP] = ReadRamsBinary([pFolder 'results/']);

nr = size(aFieldTL,2);
nz = size(aFieldTL,1);
xlabel('r, km');
% TL(r,z) computed from model's TL output



figure;
imagesc((0:nr-1)*dr,(0:nz-1)*dz,aFieldTL);
caxis([-110 -70]);
hold on;
grid on;
ylim([0 1600]);
plot(bottom(:,1)/10000,bottom(:,2),'linewidth',2,'color','black');
xlabel('R, km');
ylabel('Z, m');

colorbar;

% TL(r,z) computed from the complex pressure field
% IMPORTANT! scaling of the field by 4*pi is already applied!



figure;
imagesc((0:nr-1)*dr/1000,(0:nz-1)*dz,20*log10(abs(aFieldP)));
caxis([-110 -70]);
hold on;
plot(bottom(:,1)/1000,bottom(:,2),'linewidth',2,'color','white');
plot(bottom(:,1)/1000,bottom(:,2),'linewidth',1,'color','black');
xlabel('R, km');
ylabel('Z, m');
grid on;
ylim([0 3500]);
colorbar;
%title('z_s = 35 m,  f = 490 Hz');
range = (0:nr-1)*dr;
depth = (0:nz-1)*dz;

