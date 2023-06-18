%%%% 同时估计HQR，求解器yalmip+sedumi，无噪+有噪

clear;
% clc;
% 创建决策变量
n = 2;
m = 2;
A = [1.2,0;0,1.2];
B = [1,0;0,1];
H_r = 1*eye(2);
Q_r = 0.2*eye(2);
% Q_r = H_r;
R_r = 0.5*eye(2);
N = 8;
l = 1;
X = [];
x0 = randi(5,2,1);
[y,K,P] = my_lqr(A,B,N,H_r,Q_r,R_r,x0);

Q = sdpvar(n,n);
R = sdpvar(m,m);
H = sdpvar(n,n);
% H = Q;
theta = blkdiag(H,Q,R);
I = eye(size(theta));
alpha = sdpvar(1);
K1 = K(:,:,N);
K1 = K1 + 0.01*rand(size(K1));
K2 = K(:,:,N-1);
K2 = K2 + 0.01*rand(size(K2));
K3 = K(:,:,N-2);
K3 = K3 + 0.01*rand(size(K3));

a1 = eye(2);
b1 = K1;
c1 = A - B*K1;
d1 = B';
r1 = kron(b1',a1);
q1 = kron(d1',c1);

a2 = [eye(2), -B'*K1'];
b2 = [K2; K1*(A-B*K2)];
c2 = [B'*(A-B*K1)', B'];
d2 = [(A-B*K1)*(A-B*K2); (A-B*K2)];
r2 = kron(b2',a2);
q2 = kron(d2',c2);

a3 = [eye(2), -B'*K2', -B'*(A-B*K2)'*K1];
b3 = [K3; K2*(A-B*K3); K1*(A-B*K2)*(A-B*K3)];
c3 = [B'*(A-B*K2)'*(A-B*K1)', B'*(A-B*K2)', B'];
d3 = [(A-B*K1)*(A-B*K2)*(A-B*K3); (A-B*K2)*(A-B*K3); (A-B*K3)];
r3 = kron(b3',a3);
q3 = kron(d3',c3);
%%
% 添加约束条件
% cons = [theta >= I, theta <= alpha.*I, R * K2 == b2 * Q * a2];
cons = [theta >= I, theta <= alpha.*I, a1*R*b1 == c1*H*d1, a2*blkdiag(R,R)*b2 == c2*blkdiag(H,Q)*d2, 
    a3*blkdiag(R,R,R)*b3 == c3*blkdiag(H,Q,Q)*d3];
% cons = [theta >= I, theta <= alpha.*I, r1*vec(R) == q1*vec(H), r2*vec(blkdiag(R,R)) == q2*vec(blkdiag(H,Q))];
% 配置
ops = sdpsettings('solver', 'sedumi', 'verbose',0);
% 目标函数
z = alpha*alpha;
% 求解
result = solvesdp(cons,z);
if result.problem == 0 % problem =0 代表求解成功
    double(H)
    double(Q)
    double(R)
    double(alpha)
else
    disp('求解出错');
    result.info
end

%% infeasible case
cons = [theta >= I.*0.2];
% cons = [norm(vec(theta)) == 1];
% 配置
ops = sdpsettings('solver', 'sedumi', 'verbose',0);
% 目标函数
res1 = [r1,-q1]*[vec(R);vec(H)];
res2 = [r2,-q2]*[vec(blkdiag(R,R));vec(blkdiag(H,Q))];
res3 = [r3,-q3]*[vec(blkdiag(R,R,R));vec(blkdiag(H,Q,Q))];
z = norm(res1)+norm(res2)+norm(res3);
% 求解
result = solvesdp(cons,z);
if result.problem == 0 % problem =0 代表求解成功
    double(H)
    double(Q)
    double(R)
else
    disp('求解出错');
    result.info
end
