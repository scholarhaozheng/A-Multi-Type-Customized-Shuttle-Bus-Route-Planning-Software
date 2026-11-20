function [distancematrix] = generatedismatrix1(demandstartlocation,demandendlocation)
M = size(demandstartlocation,1);
N = size(demandendlocation,1);
distancematrix = zeros(M,N);
for i = 1:M
%     X1 = demandstartlocation(i,1);
%     Y1 = demandstartlocation(i,2);
    for j = 1:N
%         X2 = demandendlocation(j,1);
%         Y2 = demandendlocation(j,2);
%         Distance = sin(Y1*Pi/180)*sin(Y2*Pi/180) + cos(Y1*Pi/180)*cos(Y2*Pi/180)*cos(abs(X1-X2)*Pi/180);
%         D = R*acos(Distance)*Pi/180;
        D = caldistance1(demandstartlocation(i,:),demandendlocation(j,:));
        distancematrix(i,j) = D;
    end
end
end