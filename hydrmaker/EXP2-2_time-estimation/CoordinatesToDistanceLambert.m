function Dists = CoordinatesToDistanceLambert(fi1,lyam1,fi2,lyam2)
    fi1=pi*fi1/180; lyam1=pi*lyam1/180;
     fi2=pi*fi2/180; lyam2= pi*lyam2/180;
    f=1/298.25642;alpha=6378.1366;
    beta1=atan((1-f)*tan(fi1));beta2=atan((1-f)*tan(fi2));%reduced latitudes
    theta=acos(sin(beta1)*sin(beta2) + cos(beta1)*cos(beta2)*cos(lyam2-lyam1));%central angle
    P=0.5*(beta1+beta2); Q=0.5*(beta1-beta2);
    X=(theta-sin(theta))*sin(P)*sin(P)*cos(Q)*cos(Q)/(cos(0.5*theta)*cos(0.5*theta));
    Y=(theta+sin(theta))*cos(P)*cos(P)*sin(Q)*sin(Q)/(sin(0.5*theta)*sin(0.5*theta));
Dists=alpha*(theta-0.5*f*(X+Y));