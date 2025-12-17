close all
clear variables
clc

Fs = 1000;            % sampling frequency                    
T = 1/Fs;             % sampling period       
L = 1500;             % length of signal
t = (0:L-1)*T;        % time vector


% DC - постоянный ток, DC offset - среднее значение формы волны???
% signal containing: DC offset of amplitude 0.8, 
%                    50 Hz sinusoid of amplitude 0.7, 
%                    120 Hz sinusoid of amplitude 1.

A0 = 0.8;
A1 = 0.7;
A2 = 1;

f1 = 600;
f2 = 120;

S = A0 + A1 * sin(2*pi * f1*t) + A2 * sin(2*pi * f2*t);

% signal corruption
X = S + 2*randn(size(t));

figure
plot(1000*t,S)
title("Signal Not Corrupted with Zero-Mean Random Noise")
xlabel("t (milliseconds)")
ylabel("S(t)")

figure
plot(1000*t,X)
title("Signal Corrupted with Zero-Mean Random Noise")
xlabel("t (milliseconds)")
ylabel("X(t)")


% fourier transform of the signal
Y = fft(X);

% plotting the complex moduli of the fft spectrum
figure
plot(Fs/L*(0:L-1),abs(Y),"LineWidth",3)
title("Complex Magnitude of fft Spectrum")
xlabel("f (Hz)")
ylabel("|fft(X)|")

% the first half of its spectrum is in positive frequencies 
% and the second half is in negative frequencies, 
% with the first element reserved for the zero frequency.

% Nyquist frequency - частота Найквиста, половина частоты дискретизации

% the frequency domain starts from the 
%   negative of the Nyquist frequency -Fs/2 up to Fs/2-Fs/L 
%   with a spacing or frequency resolution of Fs/L
figure
plot(Fs/L*(-L/2:L/2-1),abs(fftshift(Y)),"LineWidth",3)
title("fft Spectrum in the Positive and Negative Frequencies")
xlabel("f (Hz)")
ylabel("|fft(X)|")

% To find the amplitudes of the three frequency peaks, 
%   convert the fft spectrum in Y to the single-sided amplitude spectrum. 
% Because the fft function includes a scaling factor L between 
%   the original and the transformed signals, rescale Y by dividing by L. 

P2 = abs(Y/L);

% make one-sided amplitude spectrum from two-sided.
% we then multiply by 2 freqs that have corresponding complex conjugate
% pairs in the negative frequencies (all, except for P1(1) and P1(end), 
% which are zero and Nyquist frequencies)

P1 = P2(1:L/2+1);
P1(2:end-1) = 2*P1(2:end-1);

% define frequency domain f for the single-sided spectrum
f = Fs/L*(0:(L/2));

figure
plot(f,P1,"LineWidth",3) 
title("Single-Sided Amplitude Spectrum of X(t)")
xlabel("f (Hz)")
ylabel("|P1(f)|")

% take the fourier transform of the original, uncorrupted signal and 
% retrieve the exact amplitudes at 0.8, 0.7, and 1.0.

figure
Y = fft(S);
P2_perfect = abs(Y/L);
P1_perfect = P2_perfect(1:L/2+1);
P1_perfect(2:end-1) = 2 * P1_perfect(2:end-1);

plot(f,P1_perfect,"LineWidth",3) 
title("Single-Sided Amplitude Spectrum of S(t)")
xlabel("f (Hz)")
ylabel("|P1(f)|")


% calculating SEL

dt = T;
int = sum((X./ 10^(-6)).^2 * dt)
SEL = 10*log10(int)






