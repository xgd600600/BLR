clear all
clc
close all

%Start the time
start = tic;

% Name of skeleton learn algorithm
alg_name = 'BLR';

%Folder of data
data_folder ='data';

%Name of data
data_name='child';

%Samples of data
data_samples = 500;

%Define the number of sampled datasets
n = 10;
%Define the aggregation threshold
varepsilon = 5;

% Significance level
alpha = 0.01;
%Maximum size of conditioning set
maxK = 3;

fprintf('BLR is running...\n');
fprintf('n=%d\nvarepsilon =%d',n,varepsilon);
%Path of the data set
data_path = strcat(data_folder,'/',data_name,'_',num2str(data_samples),'.txt');
if exist(data_path,'file')==0
    fprintf('\n%s does not exist.\n\n',strcat(data_folder,'/',data_name,'_',num2str(data_samples),'.txt'));
    return;
end
fprintf('\nData path:%s.\n\n',data_path);

%Load data according to the path
%data needs to start from 0
data = importdata(data_path)+1;

% Get the number of samples in the data set: samples
% and the number of nodes: p
[samples,p]=size(data);

% Size array of each node
ns=max(data);

%Create a set of sampled datasets
sampling_data = cell(1,n);
for i = 1:n
    data_i = datasample(data,data_samples);
    eval(['data_',num2str(i),'=data_i',';']);  
    sampling_data{i} = data_i;
end

%Strtified learning skeleton procedure
fprintf('LSkeR is running...\n');
%[Result] = algrithm_skeleton(sampling_data,alpha,ns,p,maxK,n,varepsilon);
[Result] = LSkeR(sampling_data,alpha,ns,p,maxK,n,varepsilon);
G_skeleton = Result;

%Collective skeleton orientation procedure
fprintf('CSkeO is running...\n'); 

%Learn and Integrate DAGs
sum = zeros(p,p);
for i = 1:n
    [Result] = score_orientation(eval(['data_',num2str(i)]),G_skeleton,ns);
    DAG = Result;
    sum = sum + DAG;
end
%Aggregated DAG
DAG = zeros(p,p);
for i = 1:p
    for j = 1:p
        if sum(i,j) > varepsilon
            DAG(i,j) = 1;
        end
    end
end

% Evaluation--------------------------------------------------
% path of the graph
graph_path = strcat(data_folder,'/',data_name,'_graph.txt');
if exist(data_path,'file')==0
    fprintf('\n%s does not exist.\n\n',strcat('data/',data_name,'_graph.txt'));
    return;
end
fprintf('\nStart evaluating... \n');
fprintf('Graph path:%s.\n',graph_path);
% %Load graph (true DAG) according to the path
graph = importdata(graph_path);

% % Evaluate global causal structure
[arrhd_F1,arrhd_precision,arrhd_recall,SHD,reverse,miss,extra]=evaluation_GCS(DAG,graph);
fprintf('\nThe learned global causal structure is as follows.\n');
%sparse(DAG)
%draw_graph(DAG);
fprintf('Arc_F1=%.4f, Arc_P=%.4f, Arc_R=%.4f£¬SHD=%.0f\n',arrhd_F1,arrhd_precision,arrhd_recall,SHD);

time = toc(start);
%fprintf('\nElapsed time is %.4f seconds.\n',time);
