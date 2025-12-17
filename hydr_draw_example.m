close all
clear variables
clc

set(0, 'DefaultAxesFontSize', 16, 'DefaultAxesFontName', 'Arial','DefaultAxesFontWeight', 'bold');
set(0, 'DefaultTextFontSize', 16, 'DefaultTextFontName', 'Arial','DefaultAxesFontWeight', 'bold'); 

a = dlmread('70000.hydr');
b = smooth(a(:,2),15    );

ind = find(a(:,1)>=310, 1, 'first');
c = zeros(1, length(b));
c(1:ind) = b(1:ind);
c(ind+1:end) = a(ind+1:end,2);

figure
plot(a(:,2), a(:,1), 'linewidth', 1.5, 'color', 'red', 'displayname','Исходная')
hold on
plot(b, a(:,1), '--', 'linewidth', 1.2, 'color', 'black', 'displayname','Сглаженная')
plot(c, a(:,1), '-.', 'linewidth', 1.0, 'color', 'green', 'displayname','Итоговая')
set(gca, 'YDir', 'reverse')
xlim([1455 1460])
ylim([50 350])
grid on
xlabel('Скорость звука, м/с')
legend( 'location', 'northeastoutside')
ylabel('Глубина, м')
h = [15 30];
for ii = 1:2
dlmwrite(['yoba' int2str(h(ii)) '.txt'], [a(:,1) c'], 'delimiter', '\t')
end
