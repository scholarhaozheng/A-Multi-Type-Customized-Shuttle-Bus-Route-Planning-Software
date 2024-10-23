% function [dis] = caldistance(location1,location2)
% Pi = 3.1415926;
% R = 6378.137;
% a = location1(1,1);
% b = location1(1,2);
% c = location2(1,1);
% d = location2(1,2);
% D = sin(b*Pi/180)*sin(d*Pi/180) + cos(b*Pi/180)*cos(d*Pi/180)*cos(abs(a-c)*Pi/180);
% dis = R*acos(D)*Pi/180;
function [s] = caldistance1(Data1,Data2)
x1 = Data1(1,1);
x2 = Data2(1,1);
y1 = Data1(1,2);
y2 = Data2(1,2);
s = sqrt(power(x1-x2,2)+power(y1-y2,2));
end
