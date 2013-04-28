clear;
%data_org =importdata('../Features/ShortFeat_trainingAddLong.csv');
%data_org =importdata('../Features/ShortFeat_training.csv');
%data_org =importdata('../Features/LongFeat_trainingAddLong.csv');
data_org =importdata('../Features/LongFeat_training.csv');
data = data_org.data(:,2:end);
label = data_org.data(:,1);
T = 10;
N = size(data,1);
aa = randperm(N);
n_para = 10;
%smooth_para = 10^-4;
smooth_para = 0.2;
for time = 1: T %T %1
    disp(time);
    test_id = aa( N/10 *(time-1)+1:N/10*time);    
    train_id = setdiff(aa,test_id);
    train_data = data(train_id,:);
    test_data = data(test_id,:);
    train_label = label(train_id);
    test_label = label(test_id);
    for i = 1:n_para
        KSWidth = 10^(i-n_para/2);
        model = NaiveBayes.fit(train_data, train_label, 'Distribution', 'normal', 'KSWidth', KSWidth);
        Y_test = model.predict(test_data);
        prob_org   = model.posterior(test_data);
        precision_model(time,i) =  nnz(Y_test == test_label)/size(test_data,1);
        %smoothing;
        prob = max(prob_org, ones(size(prob_org)) * smooth_para);
        for k = 1:size(prob)
            s = prob(k, 1) + prob(k, 2);
            prob(k, 1) = prob(k, 1) / s;
            prob(k, 2) = prob(k, 2) / s;
        end
        %logliklihood_model(time,i)= mean(log(prob(:,1).^(1-Y_test))+log(prob(:,2).^ Y_test));
        logliklihood_model(time,i)= mean(log(prob(:,1).^(1-test_label))+log(prob(:,2).^ test_label));
    end
end
%precision = sum(precision_model);
disp('#### FINAL ##############');
disp(precision_model);
precision = sum(precision_model);
disp('==================');
disp(precision);
logliklihood_train = sum(logliklihood_model);
%[value,index] = max(logliklihood_train);
index=1;
mxl=-1e6;
for i=1:n_para
  if (logliklihood_train(i) > mxl)
    mxl=logliklihood_train(i);
    %disp(['###', num2str(logliklihood_train(i))])
    index=i;
    disp(['### ', num2str(mxl), ' @@ ', num2str(index)])
  end
end
KSWidth = 10^(index-n_para/2);
disp(['Max params, index =', num2str(index), ' KSWidth=', num2str(KSWidth)])
model = NaiveBayes.fit(data, label, 'Distribution', 'normal', 'KSWidth', KSWidth);


save '../production/NB_model' model;

for d=1:2
    if d == 1
        DevFile = '../Features/LongFeat_development.csv';
        %DevFile = '../Features/ShortFeat_development.csv';
    else
        DevFile = '../Features/LongFeat_developmentAdd.csv';
        %DevFile = '../Features/ShortFeat_developmentAdd.csv';
    end
    data_dev_org = importdata(DevFile);
    data_dev = data_dev_org.data(:,2:end);
    label_dev = data_dev_org.data(:,1);

    Y_test = model.predict(data_dev);
    prob_org   = model.posterior(data_dev);

    %%smoothing
    prob = max(prob_org, ones(size(prob_org)) * smooth_para);
    for k = 1:size(prob)
        s = prob(k, 1) + prob(k, 2);
        prob(k, 1) = prob(k, 1) / s;
        prob(k, 2) = prob(k, 2) / s;
    end
    %logliklihood= mean(log(prob(:,1).^(1-Y_test))+log(prob(:,2).^ Y_test));
    logliklihood= mean(log(prob(:,1).^(1-label_dev))+log(prob(:,2).^ label_dev));
    precision_dev =  nnz(Y_test == label_dev)/size(data_dev,1);
    %%developset

    disp(['File: ', DevFile])
    disp('Log-lik:')
    disp(logliklihood/log(2));
    disp('Avg-prob:')
    disp(exp(logliklihood));
    %avg_precision = mean(precision_fold);
    disp('prec dev');
    disp(precision_dev);
end
