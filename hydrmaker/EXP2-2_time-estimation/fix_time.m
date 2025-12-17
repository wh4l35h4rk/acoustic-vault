close all;
clear variables;
clc;

irf = load("импульсные 30 км канал.mat");
time = irf.GPGGA(1, :);

N = size(time);
time_cell = num2cell(time);

hours = zeros(N);
minutes = zeros(N);
secs = zeros(N);

for i = 1:N(2)
    element_string = num2str(time_cell{i});
    if (length(element_string) < 6) 
        element_string = strcat('0', element_string);
    end
 
    hours(i) = str2double(element_string(1:2));
    minutes(i) = str2double(element_string(3:4));
    secs(i) = str2double(element_string(5:6));
end

timezone = 11;
time_fixed = (timezone + hours)*3600 + minutes*60 + secs;
time_duration = duration(timezone + hours, minutes, secs);
irf.GPGGA(1, :) = time_fixed;

[irf.GPGGA_t] = time_duration;

save("irf_fixed.mat", "irf");