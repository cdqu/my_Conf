%%% fmincon求解，同时估计HQR
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
x0 = randi(5,2,1);
[y,K,P] = my_lqr(A,B,N,H_r,Q_r,R_r,x0);

K1 = K(:,:,N);
K1 = K1 + 0.01*rand(size(K1));
K2 = K(:,:,N-1);
K2 = K2 + 0.01*rand(size(K2));
K3 = K(:,:,N-2);
K3 = K3 + 0.01*rand(size(K3));
global r1 q1 r2 q2 r3 q3
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

fun = @obj;
nonlcon = @cons;
x_ini = double(zeros(6,2));
lb = zeros(6,2);
ub = ones(6,2) * Inf;

option = optimoptions(@fmincon,'Display','final','MaxIter',1000,'MaxfunEvals',25000);
x = fmincon(fun,x_ini,[],[],[],[],lb,[],nonlcon,option);
x
% objective func
function J = obj(x)
    global r1 q1 r2 q2 r3 q3
    R = x(1:2,:);
    H = x(3:4,:);
    Q = x(5:6,:);
    res1 = [r1,-q1]*[vec(R);vec(H)];
    res2 = [r2,-q2]*[vec(blkdiag(R,R));vec(blkdiag(H,Q))];
    res3 = [r3,-q3]*[vec(blkdiag(R,R,R));vec(blkdiag(H,Q,Q))];
    J = norm(res1)+norm(res2)+norm(res3);
end
% constraints
function [c_x,ceq_x] = cons(x)
    c_x = [];
    R = x(1:2,:);
    H = x(3:4,:);
    Q = x(5:6,:);
    theta = [vec(R);vec(H);vec(Q)];
    ceq_x = [norm(theta)-1];
end