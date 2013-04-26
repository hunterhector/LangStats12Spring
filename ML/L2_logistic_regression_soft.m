clear;
addpath('liblinear');
data_org =importdata('training.csv');
data = data_org.data(:,2:end);
label = data_org.data(:,1);
data_dev_org = importdata('development.csv');
data_dev = data_dev_org.data(:,2:end);
label_dev = data_dev_org.data(:,1);
T = 10;
N = size(data,1);
aa = randperm(N);
n_para = 10;
smooth_para = 10^-4;
for time = 1: T %T %1
    disp(time);
    test_id = aa( N/10 *(time-1)+1:N/10*time);    
    train_id = setdiff(aa,test_id);
    train_data = data(train_id,:);
    test_data = data(test_id,:);
    train_label = label(train_id);
    test_label = label(test_id);
    for i = 1:n_para
        svm_option = ['-c ',num2str(10^(i-n_para/2)),' -s 7'];
%%svm classifier        
        model = {train(train_label,sparse(train_data), svm_option)};        
        weight(i,:) = model{1}.w;
        y = zeros(size(test_data,1),1);
        [Y_test,accuracy,prob_org] = predict(y, sparse(test_data),model{1},'-b 1');
        precision_model(time,i) =  nnz(Y_test == test_label)/size(test_data,1);
        %smoothing;
        prob = max(prob_org, ones(size(prob_org)) * smooth_para);
        logliklihood_model(time,i)= mean(log(prob(:,1).^(1-Y_test))+log(prob(:,2).^ Y_test));
    end
end
%precision = sum(precision_model);
disp('##################');
disp(precision_model);
precision = sum(precision_model);
disp('==================');
disp(precision);
logliklihood_train = sum(logliklihood_model);
[value,index] = max(logliklihood_train);
para = 10^(index-n_para/2);
svm_option = ['-c ',num2str(para),' -s 7'];
%%svm classifier        
model = {train(label,sparse(data), svm_option)};        
weight(i,:) = model{1}.w;
%prob = data_dev *model{1}.w';
save L1_model model;
%load L1_model;
y = zeros(size(test_data,1),1);
[Y_test,accuracy,prob] = predict(label_dev, sparse(data_dev),model{1},'-b 1');
%%smoothing
prob = max(prob, ones(size(prob)) * smooth_para);
logliklihood= mean(log(prob(:,1).^(1-Y_test))+log(prob(:,2).^ Y_test));
precision_dev =  nnz(Y_test == label_dev)/size(data_dev,1);
%%developset
disp(logliklihood);
%avg_precision = mean(precision_fold);
disp(precision_dev);
