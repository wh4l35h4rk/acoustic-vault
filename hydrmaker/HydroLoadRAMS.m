function cw = HydroLoadRAMS(pFolder,dzHydr,drProf,varargin)

% cw = HydroLoadRAMS(pFolder,dzHydr,drProf);
% cw = HydroLoadRAMS(pFolder,dzHydr,drProf,rmax);


% вытаскиваем все файлы гидрологии из папки
fHydrList = '*.hydr';
fHydrList = GetFiles([pFolder,fHydrList],'','ASC');
nHydr = length(fHydrList); % кол-во файлов


zMax = 0;
rHydr(1:nHydr) = 0; % список с r гидрологии

for ii=1:nHydr
    
    tmp = textscan(fHydrList(ii).name,'%f.hydr');
    rHydr(ii) = tmp{1}; % записываем в список название файла гидрологии
    
    Hydr = dlmread([pFolder fHydrList(ii).name]);
    zMax = max(zMax, Hydr(end,1)); % ищем максимальную глубину на всех расстояниях
end;

% special case 1: zMax == 0 -> constant ss in water
% special case 2: length(rHydr) == 1 -> constant profile along the track 

zHydr = (0:dzHydr:zMax).'; % строим вектор глубины до максимальной по всем расстояниям
nz = length(zHydr); % размер вектора глубины

if nargin > 3
    nProf = fix(varargin{1}/drProf)+1;
else
    nProf = fix(rHydr(nHydr)/drProf)+1;
end; % деление по r



cw(1:nz,1:nProf) = 0;

Hydr = dlmread([pFolder fHydrList(1).name]);
cProf = interp1(Hydr(:,1),Hydr(:,2),zHydr,'linear','extrap'); % натягиваем профиль на zHydr)
iProfE = 1;


for ii=2:nHydr
    cProfPrev = cProf;
    iProfB = ceil(rHydr(ii-1)/drProf)+1;           
    iProfE = floor(rHydr(ii)/drProf)+1;
    Hydr = dlmread([pFolder fHydrList(ii).name]);
    cProf = interp1(Hydr(:,1),Hydr(:,2),zHydr,'linear','extrap');
       
    
    cw(1:nz,iProfB:iProfE) = interp1([rHydr(ii-1); rHydr(ii)], [cProfPrev.'; cProf.'], drProf*(iProfB-1:iProfE-1).').';    
    
    if (ii==2) && (iProfB>1)
        cw(1:nz,1:iProfB-1) = repmat(cw(1:nz,iProfB),1,iProfB-1);
    end;
    
end;


cw(1:nz,iProfE:nProf) = repmat(cProf,1,nProf-iProfE+1);
