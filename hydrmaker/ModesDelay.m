function time = ModesDelay(effective_velocities, pFolder)
%MODESDELAY Function that computates time of mode arrival from sound source to sound reciever

[~, ranges] = GetTrackRanges(pFolder);
delays = ranges ./ effective_velocities;
time = sum(delays, 1);

writematrix(num2str(time), [pFolder 'time_delays.txt'], 'Delimiter', '\t');

end