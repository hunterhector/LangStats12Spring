data_test_org = importdata('flong.csv')
label = data_test_org.data(:,1);
data_test = data_test_org.data(:,2:end);

N = size(data_test,1);

for j = 1:N,
	print 0.5 0.5 0
