function [inisolution,tablereject] = Generateinisolution0710(demand,demandstarttime,demandendtime,vhclocation,vhcstarttime,vhcendtime,timematrix,vhcdemandtimematrix,vhccapacity,fixedcost,cwk,ctk,TravelTimeMax,op,tsop)
M = size(demandstarttime,1);
N = size(vhclocation,1);
solutioncell = cell(N,1);
YNC = [];
for i = 1:M
    i
    costsolutioncell = solutioncell;
    YN = 0;
    C = 0;
    bestaddnow = 20000000000;
    for j = 1:N
        solution = costsolutioncell{j,1};
        leng = size(solution,2);
        if leng/2 >= vhccapacity(j,1)%保证额定载客量
            continue;
        end
         for k = 0:leng
           if(k == 0)
               solutiona = [i solution];
               for m=1:(leng+1)
                   if (m>=1)&&(m<=leng)
                       solutiona = [solutiona(1,1:m) demand+i solutiona(1,m+1:leng+1)];
                   else
                       if (m==leng+1)
                           solutiona = [solutiona demand+i];
                       end
                   end
                   yn=1;
                   YNtime=1;
                   if yn == 0||YNtime==0
                       YN = 0;
                       solutiona = [i solution];%%%%%%%%%%%
                       continue;                
                   else
                       YN = 1;
                       break;
                   end
               end
           else
               if(k >= 1)&&(k < leng)
                   solutiona = [solution(1,1:k) i solution(1,k+1:leng)];
                   for m=k+1:(leng+1)
                       if (m>=k+1)&&(m<=leng)
                           solutiona = [solutiona(1,1:m) demand+i solutiona(1,m+1:leng+1)];
                       else
                           if (m==leng+1) 
                               solutiona = [solutiona demand+i];
                           end
                       end
                       yn=1;
                       YNtime=1;
                       if yn == 0||YNtime==0
                           YN = 0;
                           solutiona = [solution(1,1:k) i solution(1,k+1:leng)];%%%%%%%%%
                           continue;
                       else
                           YN = 1;
                           break;
                       end
                   end
               else
                   if k == leng
                       solutiona = [solution i demand+i];
                       yn=1;
                       YNtime=1;
                       if yn == 0||YNtime==0
                           YN = 0;
                       else
                           YN = 1;
                           break
                       end
                   end
               end
           end
        end
        if YN == 1
            C = 1;
            socell = solutioncell;
            socell{j,1} = solutiona;
            a = calculatetotalcost_test_right(socell,demand,vhccapacity,demandstarttime,demandendtime,vhcstarttime,timematrix,vhcdemandtimematrix,fixedcost,cwk,ctk);
            b = calculatetotalcost_test_right(solutioncell,demand,vhccapacity,demandstarttime,demandendtime,vhcstarttime,timematrix,vhcdemandtimematrix,fixedcost,cwk,ctk);
            add = a - b;  %选择增量最小的线路链作为最新解
            if add <= bestaddnow
                bestsolutionnow = socell;
                bestaddnow = add;
            end
        end
    end
    if C == 0
        YNC = [YNC;i];
    else
        solutioncell = bestsolutionnow; 
    end
end
tablereject = YNC;
inisolution = solutioncell;          