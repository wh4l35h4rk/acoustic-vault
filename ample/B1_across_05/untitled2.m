r = 840;
a = 0:50:1000;

ab = abs(a - r);
i = find(ab == min(ab))
a(i)
% find(a == )