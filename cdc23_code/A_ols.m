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

%% 整合起来求
xm_l = x_minus./l;
xp_l = x_plus./l;
A_est = ((xm_l'*xm_l)\xm_l'*xp_l)';

K_err = [];
Ac_true = [];
Ac = [];
for j = 1:l
    Ac_j = A_est(1:n,1+n*(j-1):n*j) + eye(2);
    Ac = [Ac, Ac_j];
    K_est = B \ (A - Ac_j);
    Ac_true = [Ac_true, A - B*K(:,:,N-j+1)];
    K_err = [K_err, K_est - K(:,:,N-j+1)];
end
A_err = Ac - Ac_true;

%% 分开求
a = [];
k_e = [];
k_err = [];
for j = 1:l
    aj = ((x_minus(:,1+n*(j-1):n*j)'*x_minus(:,1+n*(j-1):n*j))\x_minus(:,1+n*(j-1):n*j)'*x_plus(:,1+n*(j-1):n*j))';
    a = [a,aj];
    k_e = [k_e,B \ (A - aj)];
    k_err = [k_err, B \ (A - aj) - K(:,:,N-j+1)];
end
a_err = a - Ac_true;