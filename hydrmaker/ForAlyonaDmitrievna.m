function [k1_z, k2_z, kb_z] = ForAlyonaDmitrievna()
%FORALYONADMITRIEVNA Function that computates k_z for a mode in 3-layer waveguide;

MODE = 1;                       % mode number

water_layers_depth = 47;        % between water layers depth
bottom_depth = 62;              % between water an bottom layers depth

c1 = 1518.2;                    % top water layer soundspeed
c2 = 1486.3;                    % bottom water layer soundspeed
cb = 1700;                      % bottom layer soundspeed

rho_w = 1;                      % water density
rho_b = 1.7;                    % bottom density


MP.HydrologyData = [
    0                      c1;
    water_layers_depth - 1 c1;
    water_layers_depth     c2;
    bottom_depth           c2;
];
MP.LayersData = [[0                  c1 c1 rho_w rho_w 0 0]; 
                 [water_layers_depth c1 c2 rho_w rho_w 0 0];
                 [bottom_depth       c2 cb rho_w rho_b 0 0]];


% finding solution of spectral problem

freq = 400;
dz = 0.25;
opts.nmod = 15;  
opts.Hb = 500;

[wnum, wmode] = ac_modesr(dz, MP, freq, opts);

kj_im = ModesAttCoeffs(dz, freq, wnum, wmode, MP);        
wnum = wnum + 1i*kj_im;


% computating k_z

w = 2*pi * freq;
k_r = wnum(MODE);

k1_z = sqrt(w^2 / c1^2 - k_r^2);
k2_z = sqrt(w^2 / c2^2 - k_r^2);
kb_z = sqrt(k_r^2 - w^2 / cb^2);


end