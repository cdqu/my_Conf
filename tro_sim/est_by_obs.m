% 2d case
clear;
global N
global y
global M
global x0
y = [];
x0 = [];
load('my_ob1.mat');
ob = observe(:,1:2)';
y = [y, ob(:)];
x0 = [x0, ob(:,1)];
load('my_ob2.mat');
ob = observe(:,1:2)';
y = [y, ob(:)];
x0 = [x0, ob(:,1)];
load('my_ob4.mat');
ob = observe(:,1:2)';
y = [y, ob(:)];
x0 = [x0, ob(:,1)];
y = y(
N = size(y,1)/2;
M = size(y,2);

global A
A = eye(2)*1;
global B
B = [1,0;0,1]*0.3;

fun = @obj;
nonlcon = @cons;
x_ini = zeros(2*(N*M+2),2);
x_ini(1:2,:) = x_ini(1:2,:) + rand(size(x_ini(1:2,:)));

lb = -ones(2*(N*M+2),2) * Inf;
lb(1:2,:) = eye(2);
ub = ones(2*(N*M+2),2) * Inf;
% ub(1:2,:) = zeros(2);
option = optimoptions(@fmincon,'Display','final','MaxIter',1000,'MaxfunEvals',25000);
x = fmincon(fun,x_ini,[],[],[],[],lb,[],nonlcon,option);
r_est = inv(x(1:2,:))
%     h_est = x(2*(N*M+1)+1:2*(N*M+1)+2,:)
%err = norm(r_est - R)/norm(R);

% objective func
function J = obj(x)
    global y
    global N
    global M
    J = 0;
    for j = 1:M
        J = J + norm(x(3+2*N*(j-1):(2+2*N*j),1)-y(:,j));
    end
    J = J/(N*M);
end
% constraints
function [c_x,ceq_x] = cons(x)
    global x0
    global N
    global A
    global B
    global M
    brb = B*x(1:2,:)*B';
%     h = x(2*(N*M+1)+1:2*(N*M+1)+2,:);
    E_td = [eye(2), brb; zeros(2), zeros(2)];
    F_td = [zeros(2), zeros(2); -eye(2), eye(2)];
    E = [eye(2), brb; zeros(2), A'];
    F = [A, zeros(2); zeros(2), eye(2)];
    FR = [E_td, zeros(4,4*N-8),F_td];
    FR = [FR; zeros(4*(N-1), 4*N)];
    for i = 2:N
        FR(4*(i-1)+1:4*i, 4*(i-2)+1:4*(i-1)) = -F;
        FR(4*(i-1)+1:4*i, 4*(i-1)+1:4*i) = E;
    end
    A_td = [A; zeros(4*N-2,2)];
    Z = [];
    for j = 1:M
        zz = [];
        for i = 1:N
            zz = [zz; 
                  x(2*(N*(j-1)+i)+1:2*(N*(j-1)+i)+2,1); 
                  x(2*(N*(j-1)+i)+1:2*(N*(j-1)+i)+2,2)];
        end
        Z = [Z, zz];
    end
    q_td = inv(brb)-inv(brb)';
%     q_td = [];
    c_x = [];
    ceq_x = q_td(:);
    for j = 1:M
        ceq_x = [ceq_x; FR * Z(:,j) - A_td * x0(:,j)];
    end
end