close all;
clear variables;
clc;

exp = load("exp.hydr");
m120 = load("model120131.hydr");
m130 = load("model130335.hydr");
m140 = load("model140074.hydr");

xex = exp(:,2);
yex = exp(:,1);
xm120 = m120(1:441,2);
ym120 = m120(1:441,1);
xm130 = m130(1:441,2);
ym130 = m130(1:441,1);
xm140 = m140(1:441,2);
ym140 = m140(1:441,1);

figure
t = tiledlayout(1, 2);
xlabel(t, 'Скорость звука, м/с')
ylabel(t, 'Глубина, м')

nexttile
plot(xm120, ym120, 'LineWidth', 1.2)
hold on
plot(xex, yex, 'color', 'red', 'LineWidth', 1.2)
title('R = 120 км')
legend('Модель', 'Эксперимент', 'Location','southeast')
set(gca, 'YDir', 'reverse')
grid on
hold off

% nexttile
% plot(xm130, ym130, 'LineWidth', 1.2)
% hold on
% plot(xex, yex, 'color', 'red', 'LineWidth', 1.2)
% title('R = 130 км')
% legend('Модель', 'Эксперимент', 'Location','southeast')
% set(gca, 'YDir', 'reverse')
% grid on
% hold off

nexttile
plot(xm140, ym140, 'LineWidth', 1.2)
hold on
plot(xex, yex, 'color', 'red', 'LineWidth', 1.2)
title('R = 140 км')
legend('Модель', 'Эксперимент', 'Location','southeast')
set(gca, 'YDir', 'reverse')
grid on
hold off

savefig("modexp_comparison_wo_130.fig")