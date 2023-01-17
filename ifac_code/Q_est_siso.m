% single in single out
clear;
clc;
global N
global x0
global C
global y
global A_td
global A_prod
A = 1.2;
B = 1;
N = 5;
M = 2;
x0 = randperm(5);
x0 = x0(1:M);
% parameter setting
C = zeros(N*M,N*M+1);
for i = 1:N*M
    C(i,i+1) = 1;
end
y = [];
for j = 1:M
    y = [y; lqr_dp(A, B, N-1, 1, 0, 0.5, x0(j))];
end
y = y + 0.01 * randn(size(y));
% I_td = zeros(1,N+1);
% I_td(1,2) = 1;

A_td = zeros((N-1)*M,N*M);
for j = 1:M
    for i = 1:(N-1)
        A_td((j-1)*(N-1)+i,(j-1)*(N-1)+i+(j-1)) = -A;
        A_td((j-1)*(N-1)+i,(j-1)*(N-1)+i+(j-1)+1) = 1;
    end
end
A_prod = zeros(N-1,1);
for i = 1:(N-1)
    A_prod(i,1) = A^(N-1-i); 
end
% Aeq = [I_td; A_td];
% beq = zeros(N,1);
% beq(1,1) = x0;
% lb = zeros(N+1,1);
% ub = ones(N+1,1) * Inf;
%% lsqlin_solver
% x = lsqlin(C,y,[],[],Aeq,beq,lb,ub);
% q_hat = x(N+1)/x(1);
% q_hat
%% fmincon_solver
fun = @obj;
nonlcon = @cons;
x = fmincon(fun,zeros(M*N+1,1),[],[],[],[],zeros(M*N+1,1),[],nonlcon);
q_est = 1/x(1)
% objective func
function J = obj(x)
    global C
    global y
    J = norm(C*x - y);
end
% constraints
function [c_x,ceq_x] = cons(x)
    global x0
    global A_td
    global N
    global A_prod
    c_x = [];
    q_td = [x(1)*x(N+1); x(1)*x(2*N+1)];
    ceq_x = [x(2) - x0(1);
             x(2+N) - x0(2);
             kron(q_td,A_prod) + A_td*x(2:2*N+1)];
end