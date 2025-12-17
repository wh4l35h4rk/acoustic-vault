function [wNum, mAmpl, wmode] = PlotAmplitudes(pFolder,nmod,dz)

% CLEANED MODEDECOMPOSITION.M FILE

set(0, 'DefaultAxesFontSize', 14, 'DefaultAxesFontName', 'Arial');
set(0, 'DefaultTextFontSize', 16, 'DefaultTextFontName', 'Arial'); 

RamsData = LoadConfigRAMS(pFolder);

f = 400;
omega = 2*pi*f;    %frequency

% !to change: bathData(end,2) = last bath. point
% only 1 bottom layer included

MP.LayersData = [[0 1450 1450 1 1 0 0]; 
                 [RamsData.bath(end,2) 1450 RamsData.bParams(1,1) 1 RamsData.bParams(1,3) 0 0] ];
cb = RamsData.bParams(1,1);

hydrFolder = [pFolder 'hydrology/'];
fHydrList = '*.hydr';
fHydrList = GetFiles([hydrFolder,fHydrList],'','ASC');
DEP = [];
RANGES = [];
num = size(fHydrList,2);


for ii = 1:num
 hydr = dlmread([hydrFolder fHydrList(ii).name]);
 DEP(ii) = hydr(end,1);
 [~,b,~] = fileparts([fHydrList(ii).name]);
 RANGES(ii) = str2double(b);
end; 

dmax = max(DEP);
new_depth = linspace(0, dmax , dmax + 1 );

[X, Y] = meshgrid(RANGES, new_depth);

HYDRO = [];

for ii = 1:num
 hydro = dlmread([hydrFolder fHydrList(ii).name]);
 d = hydro(:,1);
 cw = hydro(:,2); 
 HYDRO(:, ii) = (interp1(d, cw, new_depth))';
end;

for ii = 2:dmax + 1
  for jj = 1:num
    if(isnan(HYDRO(ii,jj)))
       HYDRO(ii,jj) = HYDRO(ii - 1,jj);
    end;
  end;
end;

MP.LayersData(2,1) = floor(MP.LayersData(2,1));
%% loading RAMS computations results

[~, dr, dzf, aFieldP] = ReadRamsBinary([pFolder 'results/']);
rmax = RamsData.rmax;
rstep = 2000 ; %range in metres
r = linspace(0, rmax, rmax/rstep);
rf = (0:size(aFieldP,2)-1)*dr;

%% hydrology interpolating

r1 = RamsData.bath(:,1);
d1 = RamsData.bath(:,2);

d = interp1(r1, d1, r);
 for ii = 1:length(d)
    if (isnan(d(ii)))
        d(ii) = d(ii-1);
    end;
 end;
RamsData.bath = [r' d'];

[X1, Y1] = meshgrid(r, new_depth);
Z1 = interp2(X, Y, HYDRO, X1, Y1);

for ii = 2:length(r)
    if (isnan(Z1(:,ii)))
        Z1(:,ii) = Z1(:,ii - 1);
    end;
end;

for ii = 1:length(r) - 1
    if (isnan(Z1(ii,:)))
        Z1(ii,:) = Z1(ii + 1,:);
    end;
end;

res = [];

for kk = 1:dmax + 1;
    for ii = 1:length(RANGES)
     res(kk, ii) = RANGES(ii);
    end;
end;


%% bath and hydrology drawing

MAMPL = zeros(length(r)-1, nmod);
IND_BOT = zeros(1,length(r)-1);
ALPHA = zeros(length(r)-1, nmod);
COS_ALPHA = zeros(length(r)-1, nmod);
C_MIN = zeros(length(r)-1, 1);

save([hydrFolder 'HYDRO_interp'], 'Z1', 'new_depth', 'r');

%% modes amplitudes' calculating

for ii = 1:length(r) - 1
tic
 % z grid in RAMS is usually to fine for spectral problem,
 % we take a somewhat coarser one
 ir = find(rf>=r(ii),1,'first');
 
 MP.HydrologyData = [new_depth' Z1(:, ii)];

 nzf = size(aFieldP,1);
 zf = (0:nzf-1)*dzf;

 % TL(r,z) computed from the complex pressure field
 % IMPORTANT! scaling of the field by 4*pi is already applied!


 % the ii slice P(ii,z)
 aFieldPzf = (aFieldP(1:nzf,ir)).';
 
 % new grid: magic number! 

 z = 0:dz:zf(end);
 nz = length(z);
 aFieldPz = interp1(zf,aFieldPzf,z,'linear','extrap');
 
 % inverse density for the scalar product
 
 gamma(1:nz) = 1;
 izb = find(z>=d(ii),1,'first');
 gamma(izb:nz) = 1/RamsData.bParams(1,3);
 if (isempty(izb))
     MP.LayersData(2,1) = 2200;
  else MP.LayersData(2,1) = z(izb);
 end;
 % solving spectral problem

 % to use Richardson extrap. we have to apply correction to eigenfunctions!

 opts.nmod = nmod;
 opts.Hb = zf(end) + 500;
 opts.Ngr = 3;
 opts.Tgr = 3;
 
 [wNum, wmode] = ac_modesr(dz,MP,RamsData.freq,opts);
 
 % computing amplitudes via gamma-weighted scalar product

 mAmpl = (aFieldPz.*gamma)*(wmode(1:nz,:))*dz;
 MAMPL(ii,:) = mAmpl;
 toc
 
disp(['Iteration ' num2str(ii) ' of ' num2str(length(r)) ]);

% angles calculating

ind = find((Z1(:, ii) == min(Z1(:, ii))),1, 'first');
C_MIN(ii) = Z1(ind, ii);

if(isempty(wNum))
  ALPHA(ii,:) = zeros(1,20);
else
  cos_alpha = (C_MIN(ii)/omega)*wNum; 
  COS_ALPHA(ii,:) = cos_alpha;
  ALPHA(ii,:) = acos(cos_alpha);
end;

mAmpl = [];
cos_alpha = [];

Z1(izb:end, ii) = 800;
end;

MAMPLTL = (20*log10(abs(MAMPL)));


%% modes rendering

figure;
hold all;

for ii = 1:nmod
 plot(r(1:end-1)/1000, MAMPL(:,ii), 'linewidth', 1.5, 'DisplayName', sprintf('Mode № %d',ii));
 legend('-DynamicLegend');
 
end

title([num2str(nmod) ' modes']);

grid on;
xlabel('Range, km');
ylabel('Amplitude, dB');

% drawing modes' amplitudes 
save('NEMO_2016_2D','r','new_depth','Z1','d','dmax');

figure;
subplot(2,1,1);
contourf(r/1000, new_depth, Z1, 10);
hold all;
set(gca, 'YDir', 'reverse');
plot(r/1000,d, 'linewidth', 1.5, 'color', 'white');
grid on;
xlabel('Range, km');
ylim([0 dmax])
ylabel('Depth, m');
colorbar;
caxis([1440 1520]);
subplot(2,1,2);
for ii = 1:nmod;
 plot(r(1:end-1)/1000, MAMPLTL(:,ii), 'linewidth', 1.4, 'DisplayName', sprintf('Mode № %d',ii));
 legend('-DynamicLegend');
end;
 grid on;
 ylim([-90 -40]);
 xlabel('Range, km');
 ylabel('A_j (r), dB');
 hold off;
 
 figure;
 grid on;
 hold on;
 plot(r(1:end-1)/1000, MAMPLTL(:,1), 'linewidth', 2, 'color', 'red');
 plot(r(1:end-1)/1000, MAMPLTL(:,2), 'linewidth', 2, 'color', 'yellow');
 plot(r(1:end-1)/1000, MAMPLTL(:,3), 'linewidth', 2, 'color', 'cyan');
 plot(r(1:end-1)/1000, MAMPLTL(:,4), 'linewidth', 1.6, 'color', 'magenta');
 plot(r(1:end-1)/1000, MAMPLTL(:,5), 'linewidth', 1.6, 'color', 'green');
 plot(r(1:end-1)/1000, MAMPLTL(:,6), '--', 'linewidth', 1.6, 'color' ,'black');
 plot(r(1:end-1)/1000, MAMPLTL(:,7), '--', 'linewidth', 1.6, 'color', 'magenta');
 plot(r(1:end-1)/1000, MAMPLTL(:,8), '--', 'linewidth', 1.6, 'color', 'blue');
 plot(r(1:end-1)/1000, MAMPLTL(:,9), '--', 'linewidth', 1.6, 'color', 'red');
 plot(r(1:end-1)/1000, MAMPLTL(:,10), '--', 'linewidth', 1.6, 'color', 'yellow');
 ylim([-90 -40]);
 legend('Mode №1', 'Mode №2', 'Mode №3', 'Mode №4', 'Mode №5', 'Mode №6', 'Mode №7', 'Mode №8', 'Mode №9', 'Mode №10');
 xlabel('Range, km');
 ylabel('A_j (r), dB');


ALPHA1 = (180/pi)*ALPHA;

save('NEMO_2016_2D', 'MAMPLTL','C_MIN', 'ALPHA1', 'r');