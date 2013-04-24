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

for time = 1:T
    disp(time);
    test_id = aa( N/10 *(time-1)+1:N/10*time);    
    train_id = setdiff(aa,test_id);
    train_data = data(train_id,:);
    test_data = data(test_id,:);
    train_label = label(train_id);
    test_label = label(test_id);

    for i = 1:n_para
        svm_option = ['-c ',num2str(10^(i-n_para/2))];
%%svm classifier        
        model = {train(train_label,sparse(train_data), svm_option)};        
        weight(i,:) = model{1}.w;
        save model model ; %% save model if you wnat to load it just use
        %load model;
        y = zeros(size(test_data,1),1);
        Y_test = predict(y, sparse(test_data),model{1});
        precision_model(time,i) =  nnz(Y_test == test_label)/size(test_data,1);
    end

    [value, index ] = sort(abs(weight),2,'descend');
    weight_m(time,:) = mean(weight);
%    display(index(:,1:10));
%     for ve =1:size(index,1);
%         for vee =  1:10
%             vector(ve,index(ve,vee)) = 1;
%         end
%     end
%     s_vector = sum(vector);
%     [vote, index_s] = sort(s_vector,'descend');
%     display(index_s(1,1:20));
%     a(time,:) = index_s(1,1:20);
end

disp('##################');
disp(precision_model);
precision = sum(precision_model);
disp('==================');
disp(precision);
[value,index] = max(precision);
para = 10^(index-n_para/2);
svm_option = ['-c ',num2str(para)];

%%svm classifier        
model = {train(label,sparse(data), svm_option)};        
weight(i,:) = model{1}.w;
y = zeros(size(test_data,1),1);
Y_test = predict(label_dev, sparse(data_dev),model{1});
precision_dev =  nnz(Y_test == label_dev)/size(data_dev,1);

%avg_precision = mean(precision_fold);

disp(precision_dev);
display('Cross-validation:')
disp(precision_model(1:T,index))
display('accuracy:')
display(mean(precision_model(1:T,index)))
