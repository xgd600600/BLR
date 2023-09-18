function [G_skeleton] = LSkeR(sampling_data,alpha,ns,p,maxK,n,num_skeleton)
% PC_subskeleton_G2: Strtified skeleton learning 
% INPUT :sampling_data,alpha,ns,p,maxK,n,num_skeleton      
% OUTPUT:G_skeleton

%Restore each sampled data set
for i = 1:n
    data_i = cell2mat(sampling_data(i));
    eval(['data_',num2str(i),'=data_i',';']);
end

%Initialize the fully connected graph
for i = 1:n
    G_i = ones(p,p);
    G_i = setdiag(G_i,0);
    eval(['G_',num2str(i),'=G_i',';']);
end
test = 0;

%Learning by separation set length
for ord = 0:maxK
    %Use n datasets to separate skeletons
    for i = 1:n 
        %The separation set length is 0, starting from the fully connected graph
        if ord==0
            G_start = eval(['G_',num2str(i)]);
            [X,Y] = find(G_start); 
            for j = 1:length(X)
                x = X(j);
                y = Y(j);

                nbrs = mysetdiff(myneighbors(G_start,y),x);% bug fix by Raanan Yehezkel <raanany@ee.bgu.ac.il> 6/27/04   
                if length(nbrs)>=ord && G_start(x,y)~=0
       
                    SS = subsets1(nbrs,ord);
                    for si = 1:length(SS)
                        S = SS{si};
                        test = test + 1;

                        [pval] = my_g2_test(x,y,S,eval(['data_',num2str(i)]),ns,alpha);
                        if isnan(pval)
                            CI = 0;
                        else 
                            if pval<=alpha
                                CI = 0;
                            else 
                                CI = 1;
                            end
                        end

                        if (CI==1)
                            G_start(x,y) = 0;
                            G_start(y,x) = 0;
                            break;% no need to check any more subsets
                        end
                    end
                end
            end           
            %Get G_i_0   
            eval(['G_',num2str(i),'_',num2str(ord),'=G_start',';']);  
        else
            %The separation set length is larger than 0, starting from skeleton aggregated last layer
            G_start = eval(['G_Final_',num2str(ord-1),';']);
            [X,Y] = find(G_start); 
            for j = 1:length(X)
                x = X(j);
                y = Y(j);

                nbrs = mysetdiff(myneighbors(G_start,y),x);% bug fix by Raanan Yehezkel <raanany@ee.bgu.ac.il> 6/27/04   
                if length(nbrs)>=ord && G_start(x,y)~=0

                    SS = subsets1(nbrs,ord);
                    for si = 1:length(SS)
                        S = SS{si};
                        test = test + 1;

                        [pval] = my_g2_test(x,y,S,eval(['data_',num2str(i)]),ns,alpha);
                        if isnan(pval)
                            CI = 0;
                        else 
                            if pval<=alpha
                                CI = 0;
                            else 
                                CI = 1;
                            end
                        end

                        if (CI==1)
                            G_start(x,y) = 0;
                            G_start(y,x) = 0;
                            break;% no need to check any more subsets
                        end
                    end
                end
            end       
            %Get G_i_0   
            eval(['G_',num2str(i),'_',num2str(ord),'=G_start',';']);
        end        
    end
    
    %Aggregate n skeletons to get G_Final_0
    sum = zeros(p,p);
    G_Final = zeros(p,p);
    for i = 1:n
        G_i = eval(['G_',num2str(i),'_',num2str(ord),';']);   
        sum = sum + G_i;
    end
    for j = 1:p
            for k = 1:p
                if sum(j,k) > num_skeleton
                    G_Final(j,k) = 1;
                end
            end
    end
    eval(['G_Final','_',num2str(ord),'=G_Final',';']);             
end

%Return global skeleton
G_skeleton = eval(['G_Final','_',num2str(maxK),';']);

