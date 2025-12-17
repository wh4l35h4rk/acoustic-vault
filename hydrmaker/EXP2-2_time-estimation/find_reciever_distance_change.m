close all;
clear variables;
clc;

irf_filename = "irf_fixed.mat";
irf = load(irf_filename);
irf = irf.irf;

gpgga = irf.GPGGA;
signal_indices = FindSignalIndicesInGPGGA(irf);

N = size(signal_indices);

gpgga = gpgga(:, signal_indices);
gpgga = [gpgga(1, :); gpgga(3, :); gpgga(2, :)];
source = irf.src;

figure;
plot(gpgga(2, :), gpgga(3, :));

dist = zeros(N);
for i = 1:N(2)
    dist(i) = CoordinatesToDistanceLambert(gpgga(2, i), gpgga(3, i), source(1), source(2));
end

writematrix(dist', "reciever_dist.txt", "Delimiter", "tab");




