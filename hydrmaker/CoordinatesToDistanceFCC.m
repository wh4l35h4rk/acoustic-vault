function Dists = CoordinatesToDistanceFCC(coordDeg1,COORDDeg2)

% mean latitude

phim = (pi/180)*( COORDDeg2(:,2) + coordDeg1(1,2) )/2;

% delta lat, delta long

dphi =   ( COORDDeg2(:,2) - coordDeg1(1,2) );
dlamb =  ( COORDDeg2(:,1) - coordDeg1(1,1) );

% FCC ellipsoid proj. to plane formula

K1 = 111.13209 - 0.56605*cos(2*phim) + 0.00120*cos(4*phim);
K2 = 111.41513*cos(phim) - 0.09455*cos(3*phim) + 0.00012*cos(5*phim);


Dists = sqrt( (K1.*dphi).^2+(K2.*dlamb).^2 );
    
