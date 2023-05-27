% CDC22 simulation
% SISO with constraints
clear;
clc;
T = 2;
N = 10;
dt = T / N;
A = 1 + dt; 
B = 1;
H = 1;
Q = 0;
R = dt;
lambda1 = 5;
lambda2 = 0.1;
lambda3 = 0.5;
qn = 0;
uup = 1;

J1 = zeros(1,N+1);
J2 = zeros(1,N+1);
J3 = zeros(1,N+1);
J1(N+1) = lambda1 * H;
J2(N+1) = 2 * lambda1 * qn;
J3(N+1) = 0;

W = zeros(1,N);
Z = zeros(1,N);
P = zeros(1,N);
G_tilde = zeros(1,N);
M_tilde = zeros(1,N);

x = zeros(1, N + 1);  % 状态
x(1) = 4;
u = zeros(1, N);  % 控制输入
mu = zeros(1, N);
sigma2 = zeros(1, N);
delta = zeros(1, N);

list = [1:4];
for i = 0:N-1  % 倒着求系数
    W(N-i) = lambda2 * Q + A' * J1(N-i+1) * A;
    Z(N-i) = J2(N-i+1) * A;
    P(N-i) = lambda2 * R + B' * J1(N-i+1) * B;
    
    if ismember(N-i, list)
        G_tilde(N-i) = 0;
        M_tilde(N-i) = -uup;
    else
        G_tilde(N-i) = (lambda2 * R + B' * J1(N-i+1) * B)^(-1) * B' * J1(N-i+1) * A;
        M_tilde(N-i) = 0.5 * (lambda2 * R + B' * J1(N-i+1) * B)^(-1) * B' * J2(N-i+1);
    end
    
    J1(N-i) = W(N-i) - A * J1(N-i+1) * B * G_tilde(N-i);
    J2(N-i) = Z(N-i)  - J2(N-i+1) * B * G_tilde(N-i);
%     J3(N-i) = M_tilde(N-i) * P(N-i) * M_tilde(N-i) - J2(N-i+1) * B * M_tilde(N-i) + 2 * sqrt(lambda3 * P(N-i)) + J3(N-i+1);
end


for j = 1:N  % 正着求输入和状态
    mu(j) = -G_tilde(j) * x(j) + M_tilde(j);
    sigma2(j) = lambda3 / P(j);
    a = sqrt(3 * sigma2(j));
    if a > 0.5
        a = 0.5;
    end
    delta(j) = unifrnd(-a, a);
    u(j) = mu(j) + delta(j);

    x(j+1) = A * x(j) + B * u(j);
end

x1 = zeros(1, N + 1);  % 状态
x1(1) = x(1);
u1 = zeros(1, N);  % 控制输入
mu1 = zeros(1, N);
for k = 1:N  % 正着求输入和状态
    mu1(k) = -G_tilde(k) * x1(k) + M_tilde(k);
    u1(k) = mu1(k) + 0;
    x1(k+1) = A * x1(k) + B * u1(k);
end

% subplot(1,2,1);
figure();
n1 = 0:1:N;
p1 = plot(n1, x,'-','LineWidth',1);
hold on;
% subplot(1,2,2);
figure();
n2 = 1:1:N;
plot(n2, u,'LineWidth',1);
hold on;
plot(n2, ones(N)*(-1.3),'LineWidth',1);
plot(n2, ones(N)*(1.3),'LineWidth',1);