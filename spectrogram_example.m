close all
clear variables
clc

Fs = 1000;            % sampling frequency                    
T = 1/Fs;             % sampling period       
L = 1000;             % length of signal
t = (0:L-1)*T;        % time vector

A0 = 0.8;
A1 = 0.7;
A2 = 1;

f1 = 400;
f2 = 120;

S = A0 + A1 * sin(2*pi * f1*t) + A2 * sin(2*pi * f2*t);

figure
spectrogram(S)
% spectrogram(S, 500)
% spectrogram(S, 200)
% spectrogram(S, 50)

w = 200;
overlap = 10;

n = L / w * overlap;
wins = zeros(w + 1, n);

for i = 1:overlap:n
    wins(:, i) = S(i:i + w)';
end

fourier = fft(wins);

half_sample = fourier(1 : w/2 + 1, :);
half_sample(2 : end-1, :) = 2 * half_sample(2 : end-1, :);

figure
imagesc(abs(half_sample).^2)
colorbar





