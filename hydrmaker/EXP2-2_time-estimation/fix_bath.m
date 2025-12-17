close all;
clear variables;
clc;

bath = readmatrix("bath.txt");

hill = [bath(1, :); bath(4, :)];
hill_x = bath(1:4, 1);

hill_interp = interp1(hill(:, 1), hill(:, 2), hill_x);
bath(1:4, 2) = hill_interp;

figure;
plot(bath(:, 1), bath(:, 2));
set(gca, 'YDir', 'reverse');
xlabel("R, m");
ylabel("z, m");

writematrix(bath, "bath.txt", "Delimiter", "tab");