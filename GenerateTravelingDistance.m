clc;
clear all;
close all;
load solution.mat
distance_matrix=zeros(vhcnum,1);
for i=1:vhcnum
    solution=bestsolution{i,1};
    dis=0;
    for j=1:size(solution,2)-1
        dis=dis+distancematrix(solution(j),solution(j+1));
    end
    dis=dis+vhcdemandtimematrix(i,solution(1,1))/2+vhcdemandtimematrix(i,solution(1,size(solution,2)))/2;
    distance_matrix(i,1)=dis;
end