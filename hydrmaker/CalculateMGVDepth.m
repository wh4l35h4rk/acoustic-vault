function z_vgr = CalculateMGVDepth(pFolder, M_modes, dz, depth_dir)

if (nargin < 4)
    depth_dir = '';
end
if (nargin < 3)
    dz = 1;
end
if (nargin < 2)
    M_modes = 10;
end

hydro_dir = 'hydrology/';
hydro_files = GetFiles([pFolder, depth_dir, hydro_dir, '*.hydr'], '', 'ASC');


% find example depth 

cw_original_last = readmatrix(fullfile(pFolder, hydro_dir, hydro_files(end).name), FileType="text");
H_example = cw_original_last(end, 1) * 4;


% calculate modal group velocities for model hydrology

opts.nmod = M_modes;
mgv = GetHydroMGV(dz, fullfile(pFolder, depth_dir), opts);


% find depth where MGV equals to the sound speed of given profile

N_hydro = size(mgv, 1);
z_vgr = zeros(size(mgv));
for i = 1:N_hydro
    cw_original = readmatrix(fullfile(pFolder, hydro_dir, hydro_files(i).name), FileType="text");
    [~, range, ~] = fileparts(hydro_files(i).name);
    H_base = cw_original(end, 1);
    
    % expand approximated with tanh profile for search
    cw = ExpandTanhApproxToH(pFolder, range, H_base, H_example, true);

    for j = 1:M_modes
        vel = mgv(i, j);
        i_closest = LocateMGVOnSpeedProfile(vel, cw);
        z_vgr(i, j) = cw(i_closest, 1);
    end
end


% write results in matrix:
%   - rows represent sound speed profiles
%   - columns represent modes

file = fullfile(pFolder, depth_dir, 'zVgr.txt');
writematrix(z_vgr, file, "Delimiter", '\t')

end