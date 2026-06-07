% .\AMPLE.exe rays -c config.json -v 2 -o output --row_step 1 --col_step 1 -w 12 

close all
clear variables
clc

set(0, 'DefaultAxesFontSize', 18, 'DefaultAxesFontName', 'Arial');
set(0, 'DefaultTextFontSize', 20, 'DefaultTextFontName', 'Arial'); 

cd output\rays
c = jsondecode(fileread('meta.json'));
c1 = c.dimensions;
c2 = c1{2};
c3 = c1{1};
c4 = c1{3};
if exist('rays_x.mat')
    load('rays_x.mat');
    load('rays_y.mat');
else
    fid = fopen('400.txt');
    disp('Reading')
    a = fscanf(fid, '%f');
    x_r = a(1:2:end);
    y_r = a(2:2:end);
    x_r = reshape(x_r, [c1{3}.n (c1{1}.n)*(c1{2}.n)]);
    y_r = reshape(y_r, [c1{3}.n (c1{1}.n)*(c1{2}.n)]);
    x_r = x_r';
    y_r = y_r';
    save('rays_x', 'x_r', '-v7.3');
    save('rays_y', 'y_r', '-v7.3');
    clear a
end

disp('Читаем конфиг')

a0 = c2.bounds.a;   % раствор лучей
a1 = c2.bounds.b;
n_a = c1{2,1}.n;    % количество лучей в растворе (для кажд. моды будет считаться это число лучей)
ns = size(x_r,2);
nmod = c3.n;
s0 = c4.bounds.a;
smax = c4.bounds.b;

dx = zeros(nmod*n_a, ns);   % сетка по x
dy = zeros(nmod*n_a, ns);   % сетка по y
ds = zeros(nmod*n_a, ns);   % сетка по пройденному расстоянию

dx(:,2:ns) = x_r(:, 2:ns) - x_r(:,1:ns-1);
dy(:,2:ns) = y_r(:, 2:ns) - y_r(:,1:ns-1);
ds(:,1:ns) = sqrt(dx(:,1:ns).^2 + dy(:,1:ns).^2);

cum_eig_length = cumsum(ds, 2);
angle1 = -57.2957*(linspace(a0, a1, n_a));
angle = repmat(angle1,1,nmod);
cd ..\..

x = dlmread('x_axe.txt');
x_1 = x(1):100:x(end);
y = dlmread('y_axe.txt');
y_1 = y(1):10:y(end);
[X, Y] = meshgrid(x, y);
[X1, Y1] = meshgrid(x_1, y_1);
xmax = x(end-1);

cd output\bathymetry

bath = dlmread('0.txt');
bath_1 = (interp2(X, Y, bath', X1, Y1))'; 

x = x_1;
y = y_1;
bath = bath_1;
freq = 400;

cd ..\..\..
load('vgm_merge')
cd B1_across_05_long\output\rays


%% VGM!!
 
 [X_mesh, Y_mesh] = meshgrid(x,y);
 VGM_interp = zeros(length(x), length(y), nmod);
 VGM_interp1 = zeros(length(y), nmod);
 for ii = 1:length(x)
     for jj = 1:length(y)
         for kk = 1:nmod
             VGM_interp1(:,kk) = interp1(depths,VGM(kk,:),bath(1,:));           
         end
     end
     VGM_interp(ii,:,:) = VGM_interp1;
     disp([int2str(ii) '/' int2str(length(x)) ', ' int2str(jj) '/' int2str(length(y))])
 end


%% time!!!!


% RAYS_X = zeros(nmod, size(x_r, 2));
% RAYS_Y = zeros(nmod, size(x_r, 2));
% VGR = zeros(nmod, size(x_r, 2));
% RGS = zeros(nmod, size(x_r, 2)-1);

tj_fixed = 5:2:30;
tj_fixed_len = length(tj_fixed);
tj_fixed_RGS = zeros(nmod, n_a, tj_fixed_len);
TFIXED_X = tj_fixed_RGS;
TFIXED_Y = tj_fixed_RGS;

RAYS_X = zeros(nmod, n_a, length(x_r));
RAYS_Y = zeros(nmod, n_a, length(x_r));
VGR = zeros(nmod, n_a, length(x_r));
RGS = zeros(nmod, n_a, length(x_r) - 1);

V_EFF = zeros(nmod, n_a, 1);

for kk = 1:nmod
    disp(['VGM ' int2str(kk) ' of ' int2str(nmod)]);
    for aa = 1:n_a
        disp(['     Ray ' int2str(aa) ' of ' int2str(n_a)]);
%         RAYS_X(kk, aa, 1:5)
        RAYS_X(kk, aa, :) = x_r(n_a*(kk - 1) + aa, :);
        RAYS_Y(kk, aa, :) = y_r(n_a*(kk - 1) + aa, :);

        VGR(kk, aa, :) = interp2(X_mesh, Y_mesh, VGM_interp(:, :, kk)', RAYS_X(kk, aa, :), RAYS_Y(kk, aa, :));

        [~, ind_xmax] = find(RAYS_X(kk, aa, :) <= xmax, 1, 'last');  
        dx = RAYS_X(kk, aa, 2:end) - RAYS_X(kk, aa, 1:end-1);
        dy = RAYS_Y(kk, aa, 2:end) - RAYS_Y(kk, aa, 1:end-1);
        RGS(kk, aa, :) = cumsum(sqrt(dx.^2 + dy.^2));

        vgm = zeros(ind_xmax, 1);
        tj = vgm;
        for jj = 2:ind_xmax - 1
            if VGR(kk, aa, jj) == VGR(kk, aa, jj-1)
               vgm(jj-1) = VGR(kk, aa, jj-1);
            else
               vgm(jj-1) = (VGR(kk, aa, jj) - VGR(kk, aa, jj-1)) / log(VGR(kk, aa, jj) / VGR(kk,aa, jj-1));
            end
            tj(jj-1) = (RGS(kk, aa, jj) - RGS(kk, aa, jj-1)) / vgm(jj-1);
        end
    
        for ti = 1:tj_fixed_len
            tt = tj_fixed(ti);
            t_abs = abs(tj - tt);
            tj_closest_index = find(t_abs == min(t_abs));
         
            tt_vgm = vgm(tj_closest_index);
            r = tt_vgm * tt;
            tj_fixed_RGS(kk, aa, ti) = r;
            
            RGS_cur = reshape(RGS(kk, aa, :), [1, size(RGS, 3)]);
            r_abs = abs(RGS_cur - r);
            rgs_closest_index = find(r_abs == min(r_abs), 1, 'first');
            TFIXED_X(kk, aa, ti) = RAYS_X(kk, aa, rgs_closest_index);
            TFIXED_Y(kk, aa, ti) = RAYS_Y(kk, aa, rgs_closest_index);
        end
    
        V_EFF(kk, aa) = mean(vgm);
    end
 end
 
 
 %% figure
close all

colormap = [
  255, 160, 134;
  255, 218, 134;
  239, 255, 134;
  138, 255, 134;
  134, 255, 190;
  134, 250, 255;
  134, 200, 255;
  134, 135, 255;
  209, 134, 255;
  255, 134, 234;
];
colormap = colormap ./ 255;
 
fig = figure;
hold on
for kk = 1:5
    for aa = 1:2:n_a
        if aa == 1
            visibility = 'on';
            name = ['Мода №' int2str(kk)];
        else
            visibility = 'off';
            name = ' ';
        end
        x_coords = reshape(RAYS_X(kk, aa, :), [1, size(RAYS_X, 3)]);
        y_coords = reshape(RAYS_Y(kk, aa, :), [1, size(RAYS_Y, 3)]);
        plot(x_coords/1000, y_coords/1000, 'linewidth', 1, 'Color', colormap(kk, :), 'HandleVisibility', visibility, 'DisplayName', name);
    end
    legend('-DynamicLegend');
end
for kk = 6:10
    for aa = 1:n_a
        if aa == 1
            visibility = 'on';
            name = ['Мода №' int2str(kk)];
        else
            visibility = 'off';
            name = ' ';
        end
        x_coords = reshape(RAYS_X(kk, aa, :), [1, size(RAYS_X, 3)]);
        y_coords = reshape(RAYS_Y(kk, aa, :), [1, size(RAYS_Y, 3)]);
        plot(x_coords/1000, y_coords/1000,'--', 'linewidth', 1, 'Color', colormap(kk, :), 'HandleVisibility', visibility, 'DisplayName', name);
    end
    legend('-DynamicLegend');
end
plot([x(end)/1000 x(end-1)/1000], [y(1)/1000 y(end)/1000], 'linewidth', 1.2, 'color', 'white', 'DisplayName', ' ');
plot([x(1)/1000 x(end-1)/1000], [0 0], 'linewidth', 1.2, 'color', 'white','HandleVisibility', 'off');

for tt = 1:tj_fixed_len
    for a = 1:n_a
        if a == 9
            visibility = 'on';
            name = ['t = ', num2str(round(tj_fixed(tt), 1)), ' с'];

            x_coords = reshape(TFIXED_X(:, a, tt), [1, size(TFIXED_X, 1)]);
            y_coords = reshape(TFIXED_Y(:, a, tt), [1, size(TFIXED_Y, 1)]);
            plot(x_coords/1000, y_coords/1000, 'Marker', '*', 'linewidth', 1.4, 'HandleVisibility', visibility, 'DisplayName', name);
        else
            visibility = 'off';
            name = ' ';
        end

%         x_coords = reshape(TFIXED_X(:, a, tt), [1, size(TFIXED_X, 1)]);
%         y_coords = reshape(TFIXED_Y(:, a, tt), [1, size(TFIXED_Y, 1)]);
%         plot(x_coords/1000, y_coords/1000, 'Marker', '*', 'linewidth', 1.4, 'HandleVisibility', visibility, 'DisplayName', name);
    end
    legend('-DynamicLegend');
end

grid on;
xlabel('X, км');
ylabel('Y, км');
ylim([-3.7 3.7])
xlim([0 xmax/1000])
set(gca, 'YDir', 'normal');
legend('location', 'northeastoutside')
title('Клин 0.25^{\circ}')

