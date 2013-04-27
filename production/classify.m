data_test_org = importdata('features/flong.csv');
label = data_test_org.data(:,1);
data_test = data_test_org.data(:,2:end);

N = size(data_test,1);

for j = 1:N,
	fprintf ('%.7f %.7f 0\n',0.5, 0.5);
end
