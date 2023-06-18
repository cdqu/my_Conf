clear;
clc;
A = [1.2,0;0,1.2];
B = [1,0;0,1];  % 2*2 n*m
H = 0.2*eye(2);
Q = H;
R = 0.5*eye(2);
N = 5;
n = 2;
l = 5;
X = [];
y = [];
for i=1:n*n*l
    x0 = randi(5,2,1);
    [y,K] = my_lqr(A,B,N,H,Q,R,x0);
    X = [X;y'];
end
x_minus = X(:,n+1:(N+1)*n);
x_plus = X(:,1:N*n);

%% LASSO
xm_l = x_minus;
lamda = 0.001;
B = [];
for j = 1:10
    xp_l = x_plus(:,j);
    [bb,FitInfo] = lasso(xm_l, xp_l, 'Lambda',lamda);
    B = [B, bb];
end
y_p=xm_l*B+FitInfo.Intercept;
e = x_plus - y_p;