function cw_approx = FitThermoclineWTanh(pFolder, hydrology_file)

hydro_folder = 'hydrology/';
params_folder = 'tanh_params/';
graphics_folder = 'graphics/';

if ~exist(fullfile(pFolder, graphics_folder), 'dir')
    mkdir(fullfile(pFolder, graphics_folder))
end
if ~exist(fullfile(pFolder, params_folder), 'dir')
    mkdir(fullfile(pFolder, params_folder))
end


% get sound speed profile from file and find thermocline in it

[~, range, ~] = fileparts(hydrology_file);
cw = readmatrix(fullfile(pFolder, hydro_folder, hydrology_file), 'FileType','text');

[first, last] = FindThermocline(cw);
z = cw(first:min(end, last + 30), 1);
c = cw(first:min(end, last + 30), 2);


% approximate thermocline with tanh function

best_params.rmse = 100;
best_params.a = 1;
best_params.b = 0;
best_params.c0 = 0;
best_params.d = 1;

n = length(c);

for a = 1:60
    for b = 0.1:0.1:5
        for d = 1:60
%             for c0 = 1400:1530
                c0 = c(end) + a * tanh(z(end)/d - b);
                c_approx = c0 + -1*a * tanh(z / d - b);

                rmse = sqrt(sum((abs(c - c_approx)).^2) / n);
                if rmse < best_params.rmse
                    best_params.rmse = rmse;
                    best_params.a = a;
                    best_params.b = b;
                    best_params.c0 = c0;
                    best_params.d = d;
                end
%             end
        end
    end
end

c_approx = best_params.c0 + -1 * best_params.a * tanh(z / best_params.d - best_params.b);
cw_approx = [z c_approx];
best_params


% plot result

figure;
title(strcat('R = ', range, ' m'));
plot(c, z, DisplayName='Experimental');
set(gca, 'YDir', 'reverse');
xlabel("c, m/s")
ylabel("z, m")
hold on;
plot(c_approx, z, DisplayName='As tanh(x)');
legend(Location="best")


% save approximation parameters and figure to dirs

save(fullfile(pFolder, params_folder, strcat('params_', range, '.mat')), "best_params");
savefig(fullfile(pFolder, graphics_folder, strcat('tanh_', range, '.fig')));

end
