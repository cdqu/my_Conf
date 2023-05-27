% CDC22 simulation
% car_module
clear;
clc;
T = 10;
N = 20;
dt = 0.5;
A = [1 0 dt 0; 0 1 0 dt; 0 0 1 0; 0 0 0 1];  % 4*4 n*n
B = [0 0; 0 0; dt 0; 0 dt];  % 4*2 n*m
H = eye(4)*1;
Q = eye(4)*0.04;
R = dt * eye(2);
lambda1 = 20;
lambda2 = 2;
lambda3 = 2;
xN_o = [0; 0; 0; 0];
qn = xN_o' * H;

J1 = lambda1 * H;
J2 = 2 * lambda1 * qn;
J3 = 0;

P = zeros(2,2,N);
G = zeros(2,4,N);
M = zeros(2,N);

x = zeros(4, N + 1);  % 状态
x(:,1) = [10; 10; 0; 0];
u = zeros(2, N);  % 控制输入
mu = zeros(2, N);
sigma2 = zeros(2, N);
delta = zeros(2, N);

for i = 0:N-1  % 倒着求系数
    W = lambda2 * Q + A' * J1 * A;
    Z = J2 * A;
    P(:,:,N-i) = lambda2 * R + B' * J1 * B;
    G(:,:,N-i) = inv(lambda2 * R + B' * J1 * B) * B' * J1' * A;
    M(:,N-i) = 0.5 * inv(lambda2 * R + B' * J1 * B) * B' * J2';
    
    J1 = W + G(:,:,N-i)' * P(:,:,N-i) * G(:,:,N-i) - 2 * A' * J1 * B * G(:,:,N-i);
%     J1 = W - A' * J1 * B * G(:,:,N-i);
    J2 = Z + 2 * M(:,N-i)' * (P(:,:,N-i) * G(:,:,N-i) - B' * J1' * A) - J2 * B * G(:,:,N-i);
%     J2 = Z  - J2 * B * G(:,:,N-i);
    J3 = M(:,N-i)' * P(:,:,N-i) * M(:,N-i) - J2 * B * M(:,N-i) + 2 * sqrt(lambda3 * (P(1,1,N-i))) + 2 * sqrt(lambda3 * (P(2,2,N-i))) + J3;
end

for j = 1:N  % 正着求输入和状态
    mu(:,j) = -G(:,:,j) * x(:,j) + M(:,j);
%     if mu(1,j)>2
%         mu(1,j) = 2;
%     end
%     if mu(2,j)>2
%         mu(2,j) = 2;
%     end
%     if mu(1,j)<-2
%         mu(1,j) = -2;
%     end
%     if mu(2,j)<-2
%         mu(2,j) = -2;
%     end
    sigma2(1,j) = sqrt(lambda3 / P(1,1,j));
    sigma2(2,j) = sqrt(lambda3 / P(2,2,j));
    a1 = sqrt(3 * sigma2(1,j));
    a2 = sqrt(3 * sigma2(2,j));
    delta(1,j) = unifrnd(-a1, a1);
    delta(2,j) = unifrnd(-a2, a2);
    u(:,j) = mu(:,j) + delta(:,j);
    x(:,j+1) = A * x(:,j) + B * u(:,j);
end
%%
figure();
plot(x(1,:),x(2,:),(0:1:10),(0:1:10),'LineWidth',1.2);
% figure();
% n1 = 1:1:N;
% plot(n1, sigma2(1,:))
% plot(n1,x(3,:),n1,x(4,:));