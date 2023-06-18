clear;
% clc;
% 创建决策变量
n = 2;
m = 2;
A = [1.2,0;0,1.2];
B = [1,0;0,1];
H_r = 1*eye(2);
% Q_r = 0.8*eye(2);
Q_r = H_r;
R_r = 0.5*eye(2);
N = 8;
l = 1;
X = [];
x0 = randi(5,2,1);
[y,K,P] = my_lqr(A,B,N,H_r,Q_r,R_r,x0);

Q = sdpvar(n,n);
R = sdpvar(m,m);
% H = sdpvar(n,n);
H = Q;
theta = blkdiag(H,Q,R);
I = eye(size(theta));
alpha = sdpvar(1);
K1 = K(:,:,N);
K1 = K1 + 0.01*rand(size(K1));
K2 = K(:,:,N-1);
K2 = K2 + 0.01*rand(size(K2));
K3 = K(:,:,N-2);
% K = K + 0.02*rand(  size(K));
b1 = B';
a1 = A - B*K1;
b2 = B'*(K1'*b1+(A-B*K1)'+eye(2));
a2 = (a1 + (A-B*K1)+eye(2))*(A - B*K2);
a3 = (a2 + a1*(A-B*K2) + (A-B*K1)*(A-B*K2)+ (A-B*K2)+eye(2))*(A-B*K3);
b3 = B'*(K2'*b2 + (A-B*K2)'*K1'*b1 + (A-B*K2)'*(A-B*K1)' + (A-B*K2)' + eye(2));
p = K1'*b1 * Q * a1+(A-B*K1)'*Q*(A-B*K1)+Q;
c1 = B' *[K1'*b1, (A-B*K1)',eye(2)];
c2 = [a1,(A-B*K1),eye(2)]'* (A-B*K2);
% 添加约束条件
% cons = [theta >= I, theta <= alpha.*I, R * K2 == b2 * Q * a2];
cons = [theta >= I, theta <= alpha.*I,R * K1 == b1 * H * a1, R * K2 == c1*blkdiag(H, H, Q)*c2];
% 配置
ops = sdpsettings('solver', 'sedumi', 'verbose',1);
% 目标函数
z = alpha*alpha;
% 求解
result = solvesdp(cons,z);
if result.problem == 0 % problem =0 代表求解成功
    double(Q)
    double(R)
    double(H)
    double(alpha)
else
    disp('求解出错');
%     result.info
end


%% infeasible case
p = [b1, eye(size(b1))];
q=[a1;-K1];
phi1=kron(q',p);
p= [b2, eye(size(b2))];
q=[a2;-K2];
phi2=kron(q',p);
p= [b3, eye(size(b3))];
q=[a3;-K3];
phi3=kron(q',p);
phi = [phi1;phi2;phi3];
phi = [phi(:,1:2),phi(:,5:6),phi(:,11:12),phi(:,15:16)];
[U,S,V] = svd(phi);