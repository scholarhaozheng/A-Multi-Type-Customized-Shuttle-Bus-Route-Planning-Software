load solution0416.mat
demandlocations = xlsread('.\longtitude_and_latitude0415.xlsx','A2:E101');
TSlocations=xlsread('.\longtitude_and_latitude0415.xlsx','A102:C104');
StartFromWhere=0;
partA=[];
partB=[];
partC=[];
partD=[];
partE=[];
partF=[];
partG=[];
partH=[];
partI=[];
partJ=[];
for i=1:vhcnum
    chain=bestsolution{i,1};
    length=size(chain,2);
    chainID=i*ones(length-1,1);
    partB=[partB;chainID];
    chain=chain';
    partCadd=[1,1:length];
    partCadd(:,1)=[];
    partC=[partC,partCadd];
    partD=[partD;chain];
    chainE=chain;
    chainE(1,:)=[];
    chainE=[chainE;0];
    partE=[partE;chainE];
    for j=1:length-1
        if chain(j,1)<=demand
            demandlocationsindex=demandlocations(:,1);
            [loc,~]=find(demandlocationsindex==chain(j,1));
            partF=[partF;demandlocations(loc,2)];
            partG=[partG;demandlocations(loc,3)];
        elseif chain(j,1)<=2*demand
            [loc,~]=find(demandlocations==chain(j,1)-demand);
            partF=[partF;demandlocations(loc,4)];
            partG=[partG;demandlocations(loc,5)];
        else
            [loc,~]=find(TSlocations==chain(j,1)-200);
            partF=[partF;TSlocations(loc,2)];
            partG=[partG;TSlocations(loc,3)];
        end
    end
    partH=partF;
    partH(1,:)=[];
    partH=[partH;0];
    partI=partG;
    partI(1,:)=[];
    partI=[partI;0];
end
numbers=size(partB,1);
partA=[1,1:numbers];
partA(:,1)=[];
partA=partA';
delete=find(partE==0);
partD(delete)=[];
partC=partC';
partC(delete)=[];
partE(delete)=[];
for i=1:numbers
    add=['LINESTRING(' num2str(partF(i,1)) ' ' num2str(partG(i,1)) ',' num2str(partH(i,1)) ' ' num2str(partI(i,1)) ')' ];
    addstring=string(add);
    partJ=[partJ;addstring];
end
matr=[partA,partB,partC,partD,partE,partF,partG,partH,partI];
csvwrite('data0416.csv',matr,1,0);


