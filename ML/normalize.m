function Xn = normalize(X)
% normalize(X) turns all row vectors of X into unit length

n = size(X,1);  % the number of documents
Xt = X';
l = sqrt(sum(Xt.^2));  % the row vector length (L2 norm)
N_inv = sparse(1:n,1:n,l);
N_inv(find(N_inv)) = 1./N_inv(find(N_inv));
Xn = (Xt*N_inv)';

end
