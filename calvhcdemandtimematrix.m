function [vhcdemandtimematrix] = calvhcdemandtimematrix(vhcnum,demand,tsNum,depotNum,timeMatrix,vhcindex)
vhcdemandtimematrix = zeros(vhcnum,2*demand+tsNum+depotNum);
for i = 1:vhcnum
    for j = 1:2*demand+tsNum+depotNum
    vhcdemandtimematrix(i,j) = timeMatrix(vhcindex(i,1),j); 
    %%% Inputs:a��������󣩣�sp-���ı�ţ�ep-�յ�ı�� ��Outputs:d-���·�ľ��룻path-���·��·��
    %%% �ӳ�վ����������վ�����õ�ʱ��
    end
end
end
