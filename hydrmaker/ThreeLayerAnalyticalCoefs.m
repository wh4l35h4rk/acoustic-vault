function [A, B, C] = ThreeLayerAnalyticalCoefs(cw, k_mat)
%THREELAYERANALYTICALCOEFS Acoustic spectral problem analytical solution coefs
%   Function that takes previously calculated k_z wavenumbers for the
%   selected profile & mode and estimates coefficients for its modal
%   function

h1 = FindThermoclineAxis(cw);   % water layers boundary depth
h2 = cw(end, 1);                % water and bottom layers boundary depth 
rho_w = 1;                      % water density
rho_b = 1.7;                    % bottom density

k1_z = k_mat(1);
k2_z = k_mat(2);
kb_z = k_mat(3);

X = [
    sin(k2_z * h1),        cos(k2_z * h1);
    k2_z * cos(k2_z * h1), -k2_z / rho_w * sin(k2_z * h1);
];
y = [
    sin(k1_z * h1); 
    k1_z / rho_w * cos(k1_z * h1)
];
coefs_for_water_layers = linsolve(X, y);


%   modal function for every of three layers:
%     Г phi_1(z) = sin(k1_z * z),
%     | phi_2(z) = A * sin(k2_z * z) + B * cos(k2_z * z),
%     L phi_b(z) = C * exp(-kb_z * z).

A = coefs_for_water_layers(1);
B = coefs_for_water_layers(2);
C = A * sin(k2_z * h2) / exp(-kb_z * h2) + B * cos(k2_z * h2) / exp(-kb_z * h2);

end