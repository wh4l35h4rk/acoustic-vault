function index_of_closest = LocateMGVOnSpeedProfile(velocity, cw)
%LOCATEMGVONSPEEDPROFILE Function that finds index of sound speed profile
%row where speed is the closest to mode's group velocity

dist = 10000;
index_of_closest = 0;
for ii = 1:length(cw)
    new_dist = abs(cw(ii, 2) - velocity);
    if new_dist <= dist
        dist = new_dist;
        index_of_closest = ii;
    end
end
end