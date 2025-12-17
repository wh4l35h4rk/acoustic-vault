function signal_indices = FindSignalIndicesInGPGGA(irf_struct)

signal_dur = irf_struct.t;
gpgga_time = irf_struct.GPGGA(1, :);

len = size(signal_dur);
signal_indices = zeros(len);

signal_time = seconds(signal_dur);

for i = 1:len(2)
    find_result = find(gpgga_time == signal_time(i), 1);

    if (isempty(find_result))
        find_left_result = find(gpgga_time == signal_time(i) - 1, 1);
        find_right_result = find(gpgga_time == signal_time(i) + 1, 1);

        if (~isempty(find_left_result))
            signal_indices(i) = find_left_result;
            continue;
        end
        if (~isempty(find_right_result))
            signal_indices(i) = find_right_result;
            continue;
        end
        
        signal_indices(i) = -1;
    else
        signal_indices(i) = find_result;
    end
end

signal_indices = signal_indices(signal_indices >= 0);
end