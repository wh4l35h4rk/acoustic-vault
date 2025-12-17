function [first, last] = FindThermocline(f)

cw = f(:, 2);
N = length(cw);
d = zeros(N - 1, 1);
for i = 2:N
    d(i) = abs(cw(i) - cw(i - 1));
end

mean_d = mean(d);
first = find(d > mean_d, 1);
last = find(d > mean_d, 1, 'last');

% last = min(length(d), last + 5);
last = last - 5;
end