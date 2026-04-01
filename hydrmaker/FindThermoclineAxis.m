function axis = FindThermoclineAxis(f)

cw = f(:, 2);
N = length(cw);
d = zeros(N - 1, 1);
for i = 2:N
    d(i) = abs(cw(i) - cw(i - 1));
end

max_d = max(d);
axis = find(d == max_d, 1);

end