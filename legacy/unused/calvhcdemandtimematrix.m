function [vhcdemandtimematrix] = calvhcdemandtimematrix(vhcnum,demand,tsNum,depotNum,timeMatrix,vhcindex)
vhcdemandtimematrix = zeros(vhcnum,2*demand+tsNum+depotNum);
for i = 1:vhcnum
    for j = 1:2*demand+tsNum+depotNum
    vhcdemandtimematrix(i,j) = timeMatrix(vhcindex(i,1),j); 
    %%% Inputs:a（距离矩阵）；sp-起点的标号；ep-终点的标号 ；Outputs:d-最短路的距离；path-最短路的路径
    %%% 从场站到各个其他站点所用的时间
    end
end
end
