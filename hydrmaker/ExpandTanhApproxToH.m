function m = ExpandTanhApproxToH(pFolder, sample_range, h_base, H, is_example)
%EXPANDTANHAPPROXTOH Function that takes approximated with tanh sound speed
%profile and draws it with given maximal depth H

if (nargin < 5)
    is_example = false;
end

model_hydrology_folder = 'hydrology_model/';
hydrology_folder = 'hydrology/';
h_folder = strcat('H', num2str(H), '/');
file = strcat(sample_range, '.hydr');

% if (is_example == true)
%     hydrology_folder = '';
%     h_folder = '';
%     file = 'example.hydr'; 
% end

params_folder = 'tanh_params/';
if ~exist(fullfile(pFolder, model_hydrology_folder, h_folder, hydrology_folder), 'dir')
    mkdir(fullfile(pFolder, model_hydrology_folder, h_folder, hydrology_folder))
end

params_file = strcat('params_', sample_range, '.mat');
params = open(fullfile(pFolder, params_folder, params_file));
params = params.best_params;

if (is_example == false)
    z = 0:1:h_base + H;
else
    z = 0:1:H;
end
c_approx = params.c0 + -1 * params.a * tanh(z / params.d - params.b);

m = [z' c_approx'];

if (is_example == true)
    return
end

filename =  fullfile(pFolder, model_hydrology_folder, h_folder, hydrology_folder, file);
writematrix(m, filename, "Delimiter", '\t', 'FileType', 'text');
end



