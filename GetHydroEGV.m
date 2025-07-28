function egv = GetHydroEGV(mgv, pFolder)
%GETHYDROEGV Find EGV for each profile in hydrology folder

s = size(mgv);
nhydr = s(1);
nmod = s(2);

egv = zeros(nhydr - 1, nmod);

for r = 1:nhydr - 1
    for m = 1:nmod
        if mgv(r, m) == mgv(r + 1, m)
            egv(r, m) = mgv(r, m);
        else
            egv(r, m) = (mgv(r + 1, m) - mgv(r, m)) / log(mgv(r + 1, m) / mgv(r, m));
        end
    end
end

writematrix(num2str(egv,'%.2f '), [pFolder 'egv.txt'], 'Delimiter', '\t');

end