function [UTME,UTMN]=PositionChange(lat,lon)
a=6378.137;e=0.0818192; k0=0.9996;k0=0.9996;E0=500;N0=0;
Zonenum=fix(lon/6)+31;
lamda0=(Zonenum-1)*6-180+3;  %  degree
lamda0=lamda0*pi/180;          % radian
phi=lat*pi/180; lamda=lon*pi/180; % radian
v=1/sqrt( 1-e^2*(sin(phi)^2));
A=(lamda-lamda0)*cos(phi);
T=tan(phi)*tan(phi);
C=e^2*cos(phi)*cos(phi)/(1-e^2);
s=(1-e^2/4-3*e^4/64-5*e^6/256)*phi-...
    (3*e^2/8+e*e^4/32+45*e^6/1024)*sin(2*phi)+...
    (15*e^4/256+45*e^6/1024)*sin(4*phi)-35*e^6/3072*sin(6*phi);
UTME=E0+k0*a*v*(A+(1-T+C)*A*3/6+(5-18*T+T^2)*A^5/120);
UTMN=N0+k0*a*(s+v*tan(phi)*(A^2/2+(5-T+9*C+4*C^2)*A^4/24+(61-58*T+T^2)*A^6/720));
% 控制台输入  例如：[UTME,UTMN]=PositionChange(40.069,116.242)