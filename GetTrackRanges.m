function intervals = GetTrackRanges(pFolder)
%GETTRACKRANGES Function to get list of hydrology ranges from folder

hydr_file_list = '*.hydr';
hydr_file_list = GetFiles([pFolder, 'hydrology/', hydr_file_list], '', 'ASC');

nHydr = length(hydr_file_list);
ranges = zeros([nHydr, 1]);

for ii = 1:nHydr
    [~, b, ~] = fileparts([hydr_file_list(ii).name]);
    ranges(ii) = str2double(b);
end

intervals = diff(ranges);

end