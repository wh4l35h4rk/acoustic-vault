%close all
clear variables
clc

set(0, 'DefaultAxesFontSize', 14, 'DefaultAxesFontName', 'Arial');
set(0, 'DefaultTextFontSize', 16, 'DefaultTextFontName', 'Arial'); 

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
load('VGM_interp_NEMO_18');
nm = 1;
angle1 = -57.2957*(linspace(a0, a1, n_a));
angle = repmat(angle1,1,nmod);
load('Map_Jap_Sea_2023-1.mat');
bath = [BData BData(:,end)];
cd ..\..
x = dlmread('x_axe_kj.txt');
y = dlmread('y_axe_kj.txt');

xmax = x(end-1);
freq = 400;
cd output\rays
%xmax = 3450; 
%%
% for nm = 1:5:40
%     figure;
%     imagesc(x/1000, y/1000, KJ_interp(:,:,nm));
%     hold on;
%     grid on;
%     xlabel('X, km');
%     ylabel('Y,km');
%     colorbar;
%     colormap(jet);
%     title(['400 Hz, mode No ' int2str(nm) ]);
%     ylim([-15 15]);
%     plot([0 x(end)], [0 0], '--', 'linewidth' ,1, 'color', 'black','HandleVisibility', 'off');
%     for ii = (n_a*(nm-1)+1):20:(n_a*nm-1)
%         plot(x_r(ii,:)/1000, y_r(ii,:)/1000, 'linewidth', 1.5, 'color', 'white' ,'HandleVisibility', 'off');
%         plot(x_r(ii,:)/1000, y_r(ii,:)/1000,'--', 'linewidth', 1.5, 'DisplayName', sprintf('%0.3f',angle(ii)));
%      legend('-DynamicLegend', 'location', 'eastoutside');
%     end
%     %caxis([1.7347 1.7353])
%     set(gca, 'YDir', 'normal');
% end

%%
up_border = zeros(nmod, 1);
low_border = zeros(nmod, 1);
ind1 = zeros(size(x_r,1), 1);
y_r_cross = zeros(size(x_r,1), 1);
alpha_0 = zeros(nmod, 1);
alpha_1 = zeros(nmod, 1);
eigen_length = zeros(size(x_r,1), 1);

for ii = 1:size(x_r,1)
    ind1(ii) = find(x_r(ii,:) <= xmax, 1, 'last');
    eigen_length(ii) = cum_eig_length(ii, ind1(ii)) - ds(ii,ind1(ii))*(x_r(ii,ind1(ii)) - xmax)/dx(ii,ind1(ii)) ;
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
alpha_med = zeros(nmod, 1);
delta_length = zeros(nmod, 1);
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
         
         alpha_med(ii) = k1*alpha_1(ii) + k2*alpha_2(ii); 
         delta_length(ii) = k1*dl1(ii) + k2*dl2(ii);
         disp(['Estimating angles and rays, mode ' int2str(ii) ' of ' int2str(nmod)]);
 end
 
figure;
plot(alpha_med(1:10), 'o','color','red','linewidth', 2)
hold on
grid on
xlabel('Номер моды')
ylabel('\alpha, градусы')
plot(alpha_med(1:10), '--','color','black','linewidth', 1.2)

figure;
plot(delta_length(1:10), 'o','color','blue','linewidth', 2)
hold on
grid on
xlabel('Номер моды')
ylabel('Удлинение, м')
plot(delta_length(1:10), '--','color','black','linewidth', 1.2)

 VGM_rays = zeros(size(x_r, 1), size(x_r, 2));
  
 ind2 = zeros(size(x_r, 1),1);
 
 for ii = 1:nmod
     ind2(((ii-1)*n_a + 1):(ii*(n_a))) = ii*ones(n_a, 1);
 end
 
 [X_mesh, Y_mesh] = meshgrid(x(1:end-1),y);
 for ii = 1:size(x_r, 1)
         VGM_rays(ii,1:ind1(ii)) = interp2(X_mesh, Y_mesh, VGM_interp(:,:,ind2(ii)), x_r(ii,1:ind1(ii)), y_r(ii,1:ind1(ii)));
     disp(['Interping rays ' int2str(ii) ' of ' int2str(size(x_r, 1))]);
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
ARR_TIME_g = zeros(nmod,1);
V_EFF_g = zeros(nmod,1);
RAYS_X = zeros(nmod, size(x_r, 2));
RAYS_Y = zeros(nmod, size(x_r, 2));
VGR = zeros(nmod, size(x_r, 2));
RGS = zeros(nmod, size(x_r, 2)-1);
ref = 100;
int_up = zeros(nmod,floor(size(RAYS_X,2)/ref)+1);
int_low = zeros(nmod,floor(size(RAYS_X,2)/ref)+1);
VGR_deep_med = zeros(1,nmod);
SOFAR = zeros(1,size(CW_interp,2));
ind_med = floor(size(CW_interp,1)/2) + 1;

for ii = 1:size(SOFAR,2)
   [~,SOFAR(ii)] = min(squeeze(CW_interp(ind_med,ii,:))); 
end
 
 for ii = 1:nmod
     disp(['VGM ' int2str(ii) ' of ' int2str(nmod)]);
     xr_l = x_r((n_a*(ii - 1) + low_border(ii)),:);
     xr_u = x_r((n_a*(ii - 1) + up_border(ii)),:);
     yr_l = y_r((n_a*(ii - 1) + low_border(ii)),:);
     yr_u = y_r((n_a*(ii - 1) + up_border(ii)),:);
     RAYS_X(ii,:) = K2(ii).*xr_l + K1(ii).*xr_u;
     RAYS_Y(ii,:) = K2(ii).*yr_l + K1(ii).*yr_u;
     VGR(ii,:) = interp2(X_mesh, Y_mesh, VGM_interp(:,:,ii), RAYS_X(ii,:), RAYS_Y(ii,:));

     KR = interp2(X_mesh, Y_mesh, KJ_interp(:,:,ii), RAYS_X(ii,1:ref:end), RAYS_Y(ii,1:ref:end));

    cw_field = zeros(length(dep), floor(size(RAYS_X,2)/ref)+1);
     for ll = 1:length(dep)
         cw_field(ll,:) = interp2(X_mesh, Y_mesh, CW_interp(:,:,ll), RAYS_X(ii,1:ref:end), RAYS_Y(ii,1:ref:end)); 
     end
     %figure
    %imagesc(RAYS_X(ii,1:ref:end)/1000, dep, cw_field)
    cw_field = cw_field(:,1:284);
     for kk = 1:size(cw_field,2)
         [int_up(ii,kk), ~] = find(cw_field(:,kk) <= (2*pi*freq)/KR(kk), 1,'first');
         [int_low(ii,kk),~] = find(cw_field(:,kk) <= (2*pi*freq)/KR(kk), 1,'last');
     end
     
    [~, ind_xmax] = find(RAYS_X(ii,:)<= xmax, 1, 'last');  
    dx = RAYS_X(ii, 2:end) - RAYS_X(ii,1:end-1);
    dy = RAYS_Y(ii, 2:end) - RAYS_Y(ii,1:end-1);
    RGS(ii,:) = cumsum(sqrt(dx.^2 + dy.^2));
     vgm = zeros(ind_xmax-1,1);
     tj = vgm;
     for jj = 2:ind_xmax
         vgm(jj-1) = (VGR(ii,jj) - VGR(ii,jj-1))/(log(VGR(ii,jj)/VGR(ii,jj-1)));
         tj(jj-1) = (RGS(ii,jj) - RGS(ii,jj-1))/vgm(jj-1);
     end
          i1 = find(RGS(ii,:) >= 80000, 1, 'first');
     i2 = find(isnan(vgm), 1,'first');
     VGR_deep_med(ii) = mean(vgm(i1:end));
     ARR_TIME(ii) = sum(tj);
     V_EFF(ii) = mean(vgm);
     
     ind_med = floor(size(VGM_interp,1)/2) + 1;
     tj_g = zeros(1,size(X_mesh, 2)-1);
     vgm_g = zeros(ind_xmax-1,1);
     for kk = 2:size(X_mesh, 2)
        vgm_g(kk-1) = (VGM_interp(ind_med,kk,ii) - VGM_interp(ind_med,kk-1,ii))/(log(VGM_interp(ind_med,kk,ii)/VGM_interp(ind_med,kk-1,ii)));
        tj_g(kk-1) = (x(kk) - x(kk-1))/vgm_g(kk-1);
     end
     ARR_TIME_g(ii) = sum(tj_g);
     V_EFF_g(ii) = xmax/ARR_TIME_g(ii);
     
 end
 dlmwrite('v_gr_deep_80.txt', VGR_deep_med,'delimiter', '&','precision', '%.2f')
%%
load('sigs')
figure;
subplot(2,2,1)
text(102, 1.1, 'T^{t,r}(f,j)')
hold on
grid on;
xlabel('Время, сек');
xlim([94 99]);
set(gca, 'ColorOrder', circshift(get(gca, 'ColorOrder'), 5));
for ii = 1:5
    plot([ARR_TIME(ii) ARR_TIME(ii)], [0 1], 'linewidth', 1.5, 'DisplayName', sprintf('Мода %i',ii));
end
for ii = 6:10
    plot([ARR_TIME(ii) ARR_TIME(ii)], [0 1],'--','linewidth', 1.2, 'DisplayName', sprintf('Мода %i',ii));
end
plot(t69(1:1000:end), sig69(1:1000:end)/max(sig69), 'linewidth', 1.1, 'color','blue', 'handlevisibility', 'off')
lg = legend('-DynamicLegend', 'Location', 'NorthEastOutside');
title(lg, '69 м')
subplot(2,2,2)
hold on
grid on;
xlabel('Время, сек');
xlim([94 99]);
set(gca, 'ColorOrder', circshift(get(gca, 'ColorOrder'), 5));
for ii = 1:5
    plot([ARR_TIME(ii) ARR_TIME(ii)], [0 1], 'linewidth', 1.5, 'DisplayName', sprintf('Мода %i',ii));
end
for ii = 6:10
    plot([ARR_TIME(ii) ARR_TIME(ii)], [0 1],'--','linewidth', 1.2, 'DisplayName', sprintf('Мода %i',ii));
end
plot(t126(1:1000:end), sig126(1:1000:end)/max(sig126), 'linewidth', 1.1, 'color','blue', 'handlevisibility', 'off')
lg = legend('-DynamicLegend', 'Location', 'NorthEastOutside');
title(lg, '126 м')
subplot(2,2,3)
hold on
grid on;
xlabel('Время, сек');
xlim([94 99]);
set(gca, 'ColorOrder', circshift(get(gca, 'ColorOrder'), 5));
for ii = 1:5
    plot([ARR_TIME(ii) ARR_TIME(ii)], [0 1], 'linewidth', 1.5, 'DisplayName', sprintf('Мода %i',ii));
end
for ii = 6:10
    plot([ARR_TIME(ii) ARR_TIME(ii)], [0 1],'--','linewidth', 1.2, 'DisplayName', sprintf('Мода %i',ii));
end
plot(t648(1:1000:end), sig648(1:1000:end)/max(sig648), 'linewidth', 1.1, 'color','blue', 'handlevisibility', 'off')
lg = legend('-DynamicLegend', 'Location', 'NorthEastOutside');
title(lg, '648 м')
subplot(2,2,4)
hold on
grid on;
xlabel('Время, сек');
xlim([94 99]);
set(gca, 'ColorOrder', circshift(get(gca, 'ColorOrder'), 5));
for ii = 1:5
    plot([ARR_TIME(ii) ARR_TIME(ii)], [0 1], 'linewidth', 1.5, 'DisplayName', sprintf('Мода %i',ii));
end
for ii = 6:10
    plot([ARR_TIME(ii) ARR_TIME(ii)], [0 1],'--','linewidth', 1.2, 'DisplayName', sprintf('Мода %i',ii));
end
plot(t914(1:1000:end), sig914(1:1000:end)/max(sig914), 'linewidth', 1.1, 'color','blue', 'handlevisibility', 'off')
lg = legend('-DynamicLegend', 'Location', 'NorthEastOutside');
title(lg, '914 м')

%%

figure;
subplot(2,2,1)
text(102, 1.1, 'T^{t,g}(f,j)')
hold on
grid on;
xlabel('Время, сек');
xlim([94 99]);
set(gca, 'ColorOrder', circshift(get(gca, 'ColorOrder'), 5));
for ii = 1:5
    plot([ARR_TIME_g(ii) ARR_TIME_g(ii)], [0 1], 'linewidth', 1.5, 'DisplayName', sprintf('Мода %i',ii));
end
for ii = 6:10
    plot([ARR_TIME_g(ii) ARR_TIME_g(ii)], [0 1],'--','linewidth', 1.2, 'DisplayName', sprintf('Мода %i',ii));
end
plot(t69(1:1000:end), sig69(1:1000:end)/max(sig69), 'linewidth', 1.1, 'color','blue', 'handlevisibility', 'off')
lg = legend('-DynamicLegend', 'Location', 'NorthEastOutside');
title(lg, '69 м')
subplot(2,2,2)
hold on
grid on;
xlabel('Время, сек');
xlim([94 99]);
set(gca, 'ColorOrder', circshift(get(gca, 'ColorOrder'), 5));
for ii = 1:5
    plot([ARR_TIME_g(ii) ARR_TIME_g(ii)], [0 1], 'linewidth', 1.5, 'DisplayName', sprintf('Мода %i',ii));
end
for ii = 6:10
    plot([ARR_TIME_g(ii) ARR_TIME_g(ii)], [0 1],'--','linewidth', 1.2, 'DisplayName', sprintf('Мода %i',ii));
end
plot(t126(1:1000:end), sig126(1:1000:end)/max(sig126), 'linewidth', 1.1, 'color','blue', 'handlevisibility', 'off')
lg = legend('-DynamicLegend', 'Location', 'NorthEastOutside');
title(lg, '126 м')
subplot(2,2,3)
hold on
grid on;
xlabel('Время, сек');
xlim([94 99]);
set(gca, 'ColorOrder', circshift(get(gca, 'ColorOrder'), 5));
for ii = 1:5
    plot([ARR_TIME_g(ii) ARR_TIME_g(ii)], [0 1], 'linewidth', 1.5, 'DisplayName', sprintf('Мода %i',ii));
end
for ii = 6:10
    plot([ARR_TIME_g(ii) ARR_TIME_g(ii)], [0 1],'--','linewidth', 1.2, 'DisplayName', sprintf('Мода %i',ii));
end
plot(t648(1:1000:end), sig648(1:1000:end)/max(sig648), 'linewidth', 1.1, 'color','blue', 'handlevisibility', 'off')
lg = legend('-DynamicLegend', 'Location', 'NorthEastOutside');
title(lg, '648 м')
subplot(2,2,4)
hold on
grid on;
xlabel('Время, сек');
xlim([94 99]);
set(gca, 'ColorOrder', circshift(get(gca, 'ColorOrder'), 5));
for ii = 1:5
    plot([ARR_TIME_g(ii) ARR_TIME_g(ii)], [0 1], 'linewidth', 1.5, 'DisplayName', sprintf('Мода %i',ii));
end
for ii = 6:10
    plot([ARR_TIME_g(ii) ARR_TIME_g(ii)], [0 1],'--','linewidth', 1.2, 'DisplayName', sprintf('Мода %i',ii));
end
plot(t914(1:1000:end), sig914(1:1000:end)/max(sig914), 'linewidth', 1.1, 'color','blue', 'handlevisibility', 'off')
lg = legend('-DynamicLegend', 'Location', 'NorthEastOutside');
title(lg, '914 м')
 %%


figure
imagesc(x/1000,y/1000,BData);
hold on
for ii = [1 2 4 8]
    plot(RAYS_X(ii,:)/1000, RAYS_Y(ii,:)/1000, 'linewidth', 1.5, 'color', 'white' ,'HandleVisibility', 'off');
    plot(RAYS_X(ii,:)/1000, RAYS_Y(ii,:)/1000,'--', 'linewidth', 1.5, 'DisplayName', sprintf('Мода %i',ii));
    legend('-DynamicLegend');
end
plot([x(end) x(end)], [y(1) y(end)], 'linewidth', 1.2, 'color', 'white','HandleVisibility', 'off');
plot([x(1) x(end)], [0 0], 'linewidth', 1.2, 'color', 'white','HandleVisibility', 'off');
plot([100 100], [-3.2 0], '-.','linewidth', 1, 'color', 'white','HandleVisibility', 'off');
text(105, -3, '100 км', 'color', 'white')
grid on;
xlabel('X, км');
ylabel('Y, км');
ylim([-3.2 0])
set(gca, 'YDir', 'normal');
colorbar;
colormap(jet);
legend('location', 'southeast')

for nm = [1 2 4 8]
    figure;
    subplot(2,1,1)
    imagesc(x/1000, y/1000, VGM_interp(:,:,nm));
    hold on;
    plot(RAYS_X(nm,:)/1000, RAYS_Y(nm,:)/1000, 'linewidth', 1.5, 'color', 'white');
    plot(RAYS_X(nm,:)/1000, RAYS_Y(nm,:)/1000,'--', 'linewidth', 1.5);
    grid on;
    xlabel('X, км');
    ylabel('Y, км');
    colorbar;
    colormap(jet);
    caxis([1450 1520])
    xlim([0 xmax/1000])
    ylim([-5 5])
    title(['V^{' int2str(nm) '}_{gr}, м/с ' ]);
    plot([0 x(end)], [0 0], '--', 'linewidth' ,1, 'color', 'black','HandleVisibility', 'off');
    set(gca, 'YDir', 'normal');
    subplot(2,1,2)
    imagesc(x/1000, y/1000, KJ_interp(:,:,nm));
    hold on;
    plot(RAYS_X(nm,:)/1000, RAYS_Y(nm,:)/1000, 'linewidth', 1.5, 'color', 'white');
    plot(RAYS_X(nm,:)/1000, RAYS_Y(nm,:)/1000,'--', 'linewidth', 1.5);
    grid on;
    xlabel('X, км');
    ylabel('Y, км');
    colorbar;
    colormap(jet);
    ylim([-5 5])
    xlim([0 xmax/1000])
    %caxis([1450 1520])
    title(['k_{' int2str(nm) '}, м^{-1}' ]);
    plot([0 x(end)], [0 0], '--', 'linewidth' ,1, 'color', 'black','HandleVisibility', 'off');
    set(gca, 'YDir', 'normal');
end

figure;
subplot(2,1,1)
hold on
grid on;
xlabel('Время, сек');
plot(1:nmod, V_EFF, '-o', 'linewidth', 1.5,'color','blue', 'displayname', 'V^{t,r}_{eff}(f,j)')
plot(1:nmod, V_EFF_g, '-o', 'linewidth', 1.5,'color','red', 'displayname', 'V^(t,g}_{eff}(f,j)')
%plot(1:nmod, V_EFF_tr, '-*', 'linewidth', 1.5,'color','black', 'displayname', 'R/t_j вдоль лучей')
xticks([1 5 10 15 20 25 30 35 40])
xlabel('Номер моды')
subplot(2,1,2)
hold on
grid on;
xlabel('Время, сек');
plot(1:nmod, V_EFF, '-o', 'linewidth', 1.5,'color','blue', 'displayname', 'V^{t,r}_{eff}(f,j)')
plot(1:nmod, V_EFF_g, '-o', 'linewidth', 1.5,'color','red', 'displayname', 'V^{t,g}_{eff}(f,j)')
%plot(1:nmod, V_EFF_tr, '-*', 'linewidth', 1.5,'color','black', 'displayname', 'R/t_j вдоль лучей')
xlabel('Номер моды')
xticks(1:10)
xlim([1 11])
ylim([1410 1520])
ylabel('Эффективная скорость, м/с')
legend('location', 'northeastoutside')

figure
hold on
plot([0 RGS(1,1:ref:end)]/1000, int_up(1,:), '--','color', 'blue', 'linewidth', 1.5, 'displayname','Мода 1')
plot([0 RGS(1,1:ref:end)]/1000, int_low(1,:), '-.', 'color', 'blue','linewidth', 1.5, 'handlevisibility','off')

plot([0 RGS(2,1:ref:end)]/1000, int_up(2,:), '--','color', 'red', 'linewidth', 1.5, 'displayname','Мода 2')
plot([0 RGS(2,1:ref:end)]/1000, int_low(2,:), '-.', 'color', 'red','linewidth', 1.5, 'handlevisibility','off')

plot([0 RGS(4,1:ref:end)]/1000, int_up(4,:), '--','color', 'black', 'linewidth', 1.5, 'displayname','Мода 4')
plot([0 RGS(4,1:ref:end)]/1000, int_low(4,:), '-.', 'color', 'black','linewidth', 1.5, 'handlevisibility','off')

plot([0 RGS(8,1:ref:end)]/1000, int_up(8,:), '--','color', 'green', 'linewidth', 1.5, 'displayname','Мода 8')
plot([0 RGS(8,1:ref:end)]/1000, int_low(8,:), '-.', 'color', 'green','linewidth', 1.5, 'handlevisibility','off')

plot([0 RGS(16,1:ref:end)]/1000, int_up(16,:), '--','color', 'magenta', 'linewidth', 1.5, 'displayname','Мода 16')
plot([0 RGS(16,1:ref:end)]/1000, int_low(16,:), '-.', 'color', 'magenta','linewidth', 1.5, 'handlevisibility','off')

plot([0 RGS(24,1:ref:end)]/1000, int_up(24,:), '--','color', 'cyan', 'linewidth', 1.5, 'displayname','Мода 24')
plot([0 RGS(24,1:ref:end)]/1000, int_low(24,:), '-.', 'color', 'cyan','linewidth', 1.5, 'handlevisibility','off')

plot([0 RGS(40,1:ref:end)]/1000, int_up(40,:), '--','color', 'yellow', 'linewidth', 1.5, 'displayname','Мода 40')
plot([0 RGS(40,1:ref:end)]/1000, int_low(40,:), '-.', 'color', 'yellow','linewidth', 1.5, 'handlevisibility','off')
plot(x(1:end-1)/1000, SOFAR, '*','linewidth', 1.5,'color','black', 'displayname', 'Ось ПЗК')
legend('location', 'eastoutside')
grid on
plot(139.5, 69, 's', 'MarkerSize',10 ,'MarkerEdgeColor','b','MarkerFaceColor','r', 'handlevisibility','off'   )
plot(139.5, 126, 's', 'MarkerSize',10 ,'MarkerEdgeColor','b','MarkerFaceColor','r', 'handlevisibility','off')
plot(139.5, 648, 's', 'MarkerSize',10 ,'MarkerEdgeColor','b','MarkerFaceColor','r', 'handlevisibility','off')
plot(139.5, 914, 's', 'MarkerSize',10 ,'MarkerEdgeColor','b','MarkerFaceColor','r', 'handlevisibility','off')
set(gca, 'YDir','reverse')
ylim([50 960])
xlim([100 140])
xlabel('Длина вдоль луча, км')
ylabel('Глубина, м')

save('rays', 'RAYS_X', 'RAYS_Y','VGR_deep_med', 'ARR_TIME', 'ARR_TIME_g', 'delta_length', 'alpha_med', 'V_EFF', 'V_EFF_g')

figure
plot(1:nmod, VGR_deep_med, '-*', 'color', 'black', 'linewidth', 1.5)
grid on
xlabel('Номер моды')
ylabel('Групповая скорость, м/с')