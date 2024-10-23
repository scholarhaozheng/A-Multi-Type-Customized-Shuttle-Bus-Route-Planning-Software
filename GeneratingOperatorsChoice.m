function [ option ] = GeneratingOperatorsChoice( i,lambda,desORrep,omega )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
sumup_operator=0;
for k=1:size(omega,2)
    sumup_operator=sumup_operator+omega(k);
end
omega=omega/sumup_operator;
choose_operator = rand();
choose_matrix=zeros(1,size(omega,2));
for k=1:size(omega,2)
    if k==1
        choose_matrix(1,k)=omega(1,1);
    else
        choose_matrix(1,k)=choose_matrix(1,k-1)+omega(1,k);
    end
end
option=[];
if desORrep==1
    if choose_operator<choose_matrix(1,1)
        option=1;
    elseif choose_operator>=choose_matrix(1,1)&&choose_operator<choose_matrix(1,2)
        option=2;
    elseif choose_operator>=choose_matrix(1,2)&&choose_operator<choose_matrix(1,3)
        option=3;
    elseif choose_operator>=choose_matrix(1,3)&&choose_operator<choose_matrix(1,4)
        option=4;
    elseif choose_operator>=choose_matrix(1,4)&&choose_operator<choose_matrix(1,5)
        option=5;
    end
else
    if choose_operator<choose_matrix(1,1)
        option=1;
    elseif choose_operator>=choose_matrix(1,1)&&choose_operator<choose_matrix(1,2)
        option=2;
    elseif choose_operator>=choose_matrix(1,2)&&choose_operator<choose_matrix(1,3)
        option=3;
    end
end
if isempty(option)
    display('stop')
    pause(100000)
end

