clear;
clc;
% 创建决策变量
n = 2;
m = 2;
A = [1.2,0;0,1.2];
B = [1,0;0,1];
H = 1*eye(2);
Q = H;
R = 0.5*eye(2);
N = 5;
l = 1;
X = [];

for i=1:n*n*l
    x0 = randi(5,2,1);
    [y,K] = my_lqr(A,B,N,H,Q,R,x0);
    X = [X;y'];
end
x_minus = X(:,n+1:(N+1)*n);
x_plus = X(:,1:N*n);

%% OLS回归
a_tilde = [];
k_e = [];
k_err = [];
for j = 1:l
    aj = ((x_minus(:,1+n*(j-1):n*j)'*x_minus(:,1+n*(j-1):n*j))\x_minus(:,1+n*(j-1):n*j)'*x_plus(:,1+n*(j-1):n*j))';
    a_tilde = [a_tilde,aj];
    k_e = [k_e,B \ (A - aj)];
    k_err = [k_err, B \ (A - aj) - K(:,:,N-j+1)];
end

%% 计算ai,bi
a = [];
b = [];
for i = 1:l  % 从N到1
    a_s = 0;
    for s = 1:(i-1)
        a_nr = 1;
        a_np = 1;
        for r = i-s+1:i-1
            a_nr = a_nr * a_tilde(:,1+n*(r-1):n*r);
        end
        for p = s:i-1
            a_np = a_np * a_tilde(:,1+n*(p-1):n*p);
        end
        a_s = a_s + a(:,1+n*(i-s-1):n*(i-s)) * a_nr + a_np;
    end
    ai = (a_s + eye(n)) * a_tilde(:,1+n*(i-1):n*i);
    a = [a, ai];
end

for i = 1:l  % 从N到1
    b_s = 0;
    for s = 1:(i-1)
        b_nr = eye(n);
        b_np = eye(n);
        for r = s+1:i-1
            b_nr = b_nr * a_tilde(:,1+n*(r-1):n*r)' * k_e(:,1+n*(s-1):n*s)' * b(:,1+n*(s-1):n*s)';
        end
        for p = s:i-1
            b_np = b_np * a_tilde(:,1+n*(p-1):n*p)';
        end
        b_s = b_s + (b_nr + b_np);
    end
    bi = B' * (b_s + eye(n));
    b = [b, bi];
end

%% 求解LMI
Q_est = sdpvar(n,n);
R_est = sdpvar(m,m);
phi = blkdiag(Q_est,R_est);
I = eye(size(phi));
alpha = sdpvar(1);

% 添加约束条件
cons = [phi >= I, phi <= alpha.*I];
for i = 1:l
    cons = [cons, R_est * k_e(:,1+n*(i-1):n*i) == b(:,1+n*(i-1):n*i) * Q_est * (A-B*k_e(:,1+n*(i-1):n*i))];
end
% i= 1;
% cons = [cons, R_est * k_e(:,1+n*(i-1):n*i) == b(:,1+n*(i-1):n*i) * Q_est * (A-B*k_e(:,1+n*(i-1):n*i))];

ops = sdpsettings('solver', 'sedumi', 'verbose',0);
z = alpha*alpha;

result = solvesdp(cons,z);  
if result.problem == 0 % problem =0 代表求解成功
    double(Q_est)
    double(R_est)
    double(alpha)
else
    disp('求解出错');
    result.info
end