close all
clear variables
clc

set(0, 'DefaultAxesFontSize', 16, 'DefaultAxesFontName', 'Arial');
set(0, 'DefaultTextFontSize', 18, 'DefaultTextFontName', 'Arial'); 

openfig('18082024_CTD')
x = get(get(gca,'Children'), 'xdata');
y = get(get(gca,'Children'), 'ydata');
m = 1842;

ranges = fliplr(5*m*(0:4));

figure;

for ii = 1:size(x,1)
   cw = (x{ii,:});
   dep = (y{ii,:});

   dep = dep(dep < dep(end) - 1);
   cw = cw(1:length(dep));

   [unique_d, unique_d_ii] = unique(dep);
   dep = unique_d;
   cw = cw(unique_d_ii);

   dep(end) = ceil(dep(end));
   dep(1) = 0;
   dep_new = 0:floor(dep(end));
   cw_new = interp1(dep', cw', dep_new, 'linear','extrap');

   plot(cw_new, dep_new, 'LineWidth', 1);
   set(gca, 'YDir', 'reverse');
   xlabel("c, m/s");
   ylabel("z, m");
   grid on;
   hold on;

   writematrix([dep_new' cw_new'], [int2str(ranges(ii)) '.hydr'], 'FileType', 'text', 'delimiter', '\t');
end