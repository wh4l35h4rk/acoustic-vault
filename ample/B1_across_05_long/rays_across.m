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

a0 = c2.bounds.a;
a1 = c2.bounds.b;
n_a = c1{2,1}.n;
ns = size(x_r,2);
nmod = c3.n;
s0 = c4.bounds.a;
smax = c4.bounds.b;

dx = zeros(nmod*n_a, ns);
dy = zeros(nmod*n_a, ns);
ds = zeros(nmod*n_a, ns);

dx(:,2:ns) = x_r(:, 2:ns) - x_r(:,1:ns-1);
dy(:,2:ns) = y_r(:, 2:ns) - y_r(:,1:ns-1);
ds(:,1:ns) = sqrt(dx(:,1:ns).^2 + dy(:,1:ns).^2);

cum_eig_length = cumsum(ds, 2);
angle1 = -57.2957*(linspace(a0, a1, n_a));
angle = repmat(angle1,1,nmod);
cd ..\..

x = dlmread('x_axe.txt');
x_1 = x(1):10:x(end);
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
cd B1_across_05\output\rays
up_border = zeros(nmod, 1);
low_border = zeros(nmod, 1);
ind1 = zeros(size(x_r,1), 1);
y_r_cross = zeros(size(x_r,1), 1);
eigen_length = zeros(size(x_r,1), 1);

for ii = 1:size(x_r,1)
    ind1(ii) = find(x_r(ii,:) <= xmax, 1, 'last');
   if ind1(ii) == size(x_r,2)
        eigen_length(ii) = cum_eig_length(ii, ind1(ii)) + ds(ii,ind1(ii))*(xmax - x_r(ii,ind1(ii)))/dx(ii,ind1(ii));
    else
        eigen_length(ii) = cum_eig_length(ii, ind1(ii)) + (cum_eig_length(ii, ind1(ii)+1) - cum_eig_length(ii, ind1(ii)))*(xmax - x_r(ii,ind1(ii)))/(x_r(ii,ind1(ii) + 1) - x_r(ii,ind1(ii))); 
    end
    if eigen_length(ii) < xmax
        eigen_length(ii) = cum_eig_length(ii, ind1(ii) + 1);
    end
     eigen_length(ii) =  eigen_length(ii) - ds(ii,2);
    
    y_r_cross(ii) = y_r(ii, ind1(ii)) - dy(ii,ind1(ii))*(x_r(ii,ind1(ii)) - xmax)/dx(ii,ind1(ii)) ;  
    disp(['Eigen length ' int2str(ii) ' of ' int2str(size(x_r, 1))]);
end

y_r_cross = reshape(y_r_cross, n_a, nmod);
eigen_length = reshape(eigen_length, n_a, nmod);
y1 = zeros(nmod, 1);
y2 = zeros(nmod, 1);
dl1 = zeros(nmod, 1);
dl2 = zeros(nmod, 1);
alpha_1 = zeros(nmod, 1);
alpha_2 = zeros(nmod, 1);
alpha_med_exp = zeros(nmod, 1);
delta_length_exp = zeros(nmod, 1);
K1 = zeros(nmod, 1);
K2 = zeros(nmod, 1);

 for ii = 1:nmod

         up_border(ii) = find(y_r_cross(:, ii) > 0, 1, 'first');
         y1(ii) = y_r_cross(up_border(ii), ii);
         dl1(ii) = eigen_length(up_border(ii),ii) - xmax;
         alpha_1(ii) = angle1(up_border(ii));
         low_border(ii) = find(y_r_cross(:, ii) < 0, 1, 'last');
         y2(ii) = y_r_cross(low_border(ii), ii);
         dl2(ii) = eigen_length(low_border(ii),ii) - xmax;
         alpha_2(ii) = angle1(low_border(ii));
         
         k1 = abs(y2(ii))/abs((y1(ii) - y2(ii)));
         K1(ii) = k1;
         k2 = abs(y1(ii))/abs((y1(ii) - y2(ii)));
         K2(ii) = k2;
         
         xr_l = x_r((n_a*(ii - 1) + low_border(ii)),:);
         xr_u = x_r((n_a*(ii - 1) + up_border(ii)),:);
         yr_l = y_r((n_a*(ii - 1) + low_border(ii)),:);
         yr_u = y_r((n_a*(ii - 1) + up_border(ii)),:);

         alpha_med_exp(ii) = k1*alpha_1(ii) + k2*alpha_2(ii); 
         delta_length_exp(ii) = k1*dl1(ii) + k2*dl2(ii);
         if delta_length_exp(ii) < 0
             delta_length_exp(ii) = 0;
         end
         disp(['Estimating angles and rays, mode ' int2str(ii) ' of ' int2str(nmod)]);
 end
 
figure;
subplot(1,2,1)
plot(alpha_med_exp, 'o','color','red','linewidth', 2)
text(1,8, 'Клин 0.5^{\circ}')
hold on
grid on
xlabel('Номер моды')
ylabel('\alpha, градусы')
xticks(1:10)
plot(alpha_med_exp, '--','color','black','linewidth', 1.2)
subplot(1,2,2)
plot(delta_length_exp, 'o','color','blue','linewidth', 2)
hold on
grid on
xlabel('Номер моды')
ylabel('Удлинение, м')
plot(delta_length_exp, '--','color','black','linewidth', 1.2)
xticks(1:10)

 VGM_rays = zeros(size(x_r, 1), size(x_r, 2));
  
 ind2 = zeros(size(x_r, 1),1);
 
 for ii = 1:nmod
     ind2(((ii-1)*n_a + 1):(ii*(n_a))) = ii*ones(n_a, 1);
 end
 
 
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
 


 ind_eig_up = zeros(nmod,1);
 ind_eig_low = zeros(nmod,1);
 
for ii = 1:nmod
    ind_eig = (ii - 1)*n_a + 1;
    ind_eig_up(ii) = ind1(ind_eig - 1 + up_border(ii));
    ind_eig_low(ii) = ind1(ind_eig - 1 + low_border(ii));
end 

ARR_TIME = zeros(nmod,1);
V_EFF = zeros(nmod,1);
RAYS_X = zeros(nmod, size(x_r, 2));
RAYS_Y = zeros(nmod, size(x_r, 2));
VGR = zeros(nmod, size(x_r, 2));
RGS = zeros(nmod, size(x_r, 2)-1);
 
 for ii = 1:nmod
     disp(['VGM ' int2str(ii) ' of ' int2str(nmod)]);
     xr_l = x_r((n_a*(ii - 1) + low_border(ii)),:);
     xr_u = x_r((n_a*(ii - 1) + up_border(ii)),:);
     yr_l = y_r((n_a*(ii - 1) + low_border(ii)),:);
     yr_u = y_r((n_a*(ii - 1) + up_border(ii)),:);
     RAYS_X(ii,:) = K2(ii).*xr_l + K1(ii).*xr_u;
     RAYS_Y(ii,:) = K2(ii).*yr_l + K1(ii).*yr_u;
     VGR(ii,:) = interp2(X_mesh, Y_mesh, VGM_interp(:,:,ii)', RAYS_X(ii,:), RAYS_Y(ii,:));

    [~, ind_xmax] = find(RAYS_X(ii,:)<= xmax, 1, 'last');  
    dx = RAYS_X(ii, 2:end) - RAYS_X(ii,1:end-1);
    dy = RAYS_Y(ii, 2:end) - RAYS_Y(ii,1:end-1);
    RGS(ii,:) = cumsum(sqrt(dx.^2 + dy.^2));
     vgm = zeros(ind_xmax-1,1);
     tj = vgm;
     for jj = 2:ind_xmax
         if VGR(ii,jj) == VGR(ii,jj-1)
             vgm(jj-1) = VGR(ii,jj-1);
         else
            vgm(jj-1) = (VGR(ii,jj) - VGR(ii,jj-1))/(log(VGR(ii,jj)/VGR(ii,jj-1)));
         end
         tj(jj-1) = (RGS(ii,jj) - RGS(ii,jj-1))/vgm(jj-1);
     end
     ARR_TIME(ii) = sum(tj);
     V_EFF(ii) = mean(vgm);
 end
 
 
 
 figure
hold on
for ii = 1:5
    %plot(RAYS_X(ii,:)/1000, RAYS_Y(ii,:)/1000, 'linewidth', 1.5, 'color', 'white' ,'HandleVisibility', 'off');
    plot(RAYS_X(ii,:)/1000, RAYS_Y(ii,:)/1000, 'linewidth', 1.5, 'DisplayName', sprintf('Мода %i',ii));
    legend('-DynamicLegend');
end
for ii = 6:10
    plot(RAYS_X(ii,:)/1000, RAYS_Y(ii,:)/1000, 'linewidth', 1.5, 'color', 'white' ,'HandleVisibility', 'off');
    plot(RAYS_X(ii,:)/1000, RAYS_Y(ii,:)/1000,'--', 'linewidth', 1.5, 'DisplayName', sprintf('Мода %i',ii));
    legend('-DynamicLegend');
end
plot([x(end)/1000 x(end-1)/1000], [y(1)/1000 y(end)/1000], 'linewidth', 1.2, 'color', 'white','HandleVisibility', 'off');
plot([x(1)/1000 x(end-1)/1000], [0 0], 'linewidth', 1.2, 'color', 'white','HandleVisibility', 'off');
grid on;
xlabel('X, км');
ylabel('Y, км');
ylim([-0.4 0])
xlim([0 xmax/1000])
set(gca, 'YDir', 'normal');
legend('location', 'northeastoutside')
title('Клин 0.5^{\circ}')
 tj_across_05 = ARR_TIME;
 cd ..\..\..
 save('tj_across_05', 'tj_across_05')