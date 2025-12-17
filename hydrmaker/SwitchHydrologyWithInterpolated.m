function SwitchHydrologyWithInterpolated(pFolder, nmodes, dz)
%SWITCHHYDROLOGYWITHINTERPOLATED Function to create hydrology folder with files made from ModeDecomposition HYDRO_interp.mat

hydro_folder = 'hydrology/';
old_hydro_folder = 'hydrology_old/';

hydro_interp_file = fullfile(pFolder, hydro_folder, 'HYDRO_interp.mat');

if ~exist(hydro_interp_file, 'file')
    ModeDecomposition(pFolder, nmodes, dz)
end

load(hydro_interp_file, 'Z1', 'r', 'd', 'new_depth')
mkdir(fullfile(pFolder, old_hydro_folder))
movefile(fullfile(pFolder, hydro_folder, '*.*'), fullfile(pFolder, old_hydro_folder))

N_ranges = length(r);

for ii = 1:N_ranges
    hydro = Z1(:, ii);
    depth_cut = new_depth(new_depth <= d(ii));
    hydro = hydro(1:length(depth_cut));

    writematrix([depth_cut' hydro], fullfile(pFolder, hydro_folder, [int2str(r(ii)), '.hydr']), "FileType", "text", "Delimiter", "\t")
end

end