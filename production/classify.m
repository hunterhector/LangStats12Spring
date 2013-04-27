addpath('liblinear');

data_short_org = importdata('features/fshort.csv');
data_short = data_short_org.data(:,1:end);
load HardModel;
y = zeros(size(data_short,1),1);
hard = predict(y, sparse(data_short),model{1});

data_long_org = importdata('features/flong.csv');
data_long = data_long_org.data(:,1:end);
smooth_para = 10^-4;
load L2_model;
y = zeros(size(data_long,1),1);
[Y_test,accuracy,prob] = predict(y, sparse(data_long),model{1},'-b 1');
%%smoothing
prob = max(prob, ones(size(prob)) * smooth_para);

N = size(prob,1);

results = fopen('result','w');

for j = 1:N,
	fprintf(results,'%.7f %.7f %d\n', prob(j,1), prob(j,2), hard(j))
end
