addpath('liblinear');

data_short_org = importdata('features/fshort.csv');
data_short = data_short_org.data(:,1:end);
load HardModel;
y = zeros(size(data_short,1),1);
hard = predict(y, sparse(data_short),model{1});

data_long_org = importdata('features/flong.csv');
data_long = data_long_org.data(:,1:end);
%smooth_para = 10^-4;
smooth_para = 0.1
load L1_model;
y = zeros(size(data_long,1),1);
[Y_test,accuracy,prob] = predict(y, sparse(data_long),model{1},'-b 1');
%%smoothing
prob = max(prob, ones(size(prob)) * smooth_para);
for k = 1:size(prob)
    s = prob(k, 1) + prob(k, 2);
    prob(k, 1) = prob(k, 1) / s;
    prob(k, 2) = prob(k, 2) / s;
end

N = size(prob,1);

results = fopen('data/result','w');

for j = 1:N,
	fprintf(results,'%.7f %.7f %d\n', prob(j,1), prob(j,2), hard(j))
end
