close all
clear variables
clc

c = 1500;
f = 400;
H = 60;
ro_s = 1;
ro = 1;
dz = 0.25;

w = 2*pi * f;
k0 = sqrt(w^2 / c^2);

m = 5;
modes = 1:1:m;
x = 1:1:5000;
z = 0 + dz:dz:H;
z_s = 15;

const = (sqrt(2*pi * k0) * exp(-1i * (k0 - pi/4))) / ro_s;

k = sqrt(w^2/c^2 - (pi * modes / H).^2);
x_k = exp(1i * k .* x') ./ k;

fi = sqrt(2 * ro / H) * sin(z' .* sqrt(w^2 / c^2 - k.^2));
fi_s = sqrt(2 * ro / H) * sin(z_s * sqrt(w^2 / c^2 - k.^2));


fi_mult = zeros(H / dz, m);
for i = 1:m
    fi_mult(:,i) = fi_s(i) * fi(:,i);
end

sums = zeros(H / dz, 5000);
for i = 1:H / dz
    for j = 1:5000
        sums(i, j) = sum(fi_mult(i,:) .* x_k(j,:));
    end
end

TL = 20 * log10(abs(const * sums));

figure
imagesc(TL(:,:))
clim([-40 -15])
colormap(jet)
colorbar



