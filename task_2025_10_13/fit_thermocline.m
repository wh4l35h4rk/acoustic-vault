close all;
clear variables;
clc;

hydro_folder = 'hydrology/';

hydro_files = '*.hydr';
hydro_files = GetFiles([hydro_folder, hydro_files],'','ASC');

cw = readmatrix("Hydrology_2015.08.19_19.25_St.215.hydr", 'FileType','text');

[first, last] = FindThermocline(cw);
z = cw(1:min(end, last + first + 20), 1);
c = cw(1:min(end, last + first + 20), 2);


c0 = 1430:1500;
a = 1:20;
d = 0.1:0.1:10;
b = 1:20;

best_params.rmse = 100;
best_params.a = 1;
best_params.b = 0;
best_params.c0 = 0;
best_params.d = 1;

n = length(c);

for a = 1:30
    for b = 1:30
        for d = 1:10
            for c0 = 1400:1500
                c_approx = c0 + -1*a * tanh(z / d - b);

                rmse = sqrt(sum((abs(c - c_approx)).^2) / n);
                if rmse < best_params.rmse
                    best_params.rmse = rmse;
                    best_params.a = a;
                    best_params.b = b;
                    best_params.c0 = c0;
                    best_params.d = d;
                end
            end
        end
    end
end

best_params

figure;
% subplot(1,2,1);
plot(z, c);
set(gca, 'YDir', 'reverse');
ylabel("c, m/s")
xlabel("z, m")
hold on;

c_approx = best_params.c0 + -1 * best_params.a * tanh(z / best_params.d - best_params.b);
rmse = sqrt(sum((abs(c - c_approx)).^2) / n)

% subplot(1,2,2);
plot(z, c_approx);
set(gca, 'YDir', 'reverse');
ylabel("c_1, m/s")
xlabel("z, m")

