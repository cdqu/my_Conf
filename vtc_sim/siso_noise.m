% CDC22 simulation
% SISO
clear;
clc;
T = 10;
N = 50;
dt = T / N;
A = 1 + dt;
B = 1;
H = 1;
Q = 0;
R = dt;
lambda1 = 0.5;
lambda2 = 1 ;
lambda3 = 0.5;
qn = 0;

J1 = zeros(1,N+1);
J2 = zeros(1,N+1);
J3 = zeros(1,N+1);
J1(N+1) = lambda1 * H;
J2(N+1) = 2 * lambda1 * qn;
J3(N+1) = 0;

W = zeros(N);
Z = zeros(N);
P = zeros(1,N);
% K = zeros(N);
G = zeros(N);
M = zeros(N);

x = zeros(1, N + 1);  % 状态
x(1) = 20;
u = zeros(1, N);  % 控制输入
mu = zeros(1, N);
sigma2 = zeros(1, N);
delta = zeros(1, N);

for i = 0:N-1  % 倒着求系数
    W(N-i) = lambda2 * Q + A' * J1(N-i+1) * A;
    Z(N-i) = J2(N-i+1) * A;
    P(N-i) = lambda2 * R + B' * J1(N-i+1) * B;
    G(N-i) = (lambda2 * R + B' * J1(N-i+1) * B)^(-1) * B' * J1(N-i+1) * A;
    M(N-i) = 0.5 * (lambda2 * R + B' * J1(N-i+1) * B)^(-1) * B' * J2(N-i+1);
    
%     J1(N-i) = W(N-i) + G(N-i) * P(N-i) * G(N-i) - 2 * A * J1(N-i+1) * B * G(N-i);
    J1(N-i) = W(N-i) - A * J1(N-i+1) * B * G(N-i);
%     J2(N-i) = Z(N-i) + 2 * M(N-i) * (P(N-i) * G(N-i) - B * J1(N-i+1) * A) - J2(N-i+1) * B * G(N-i);
    J2(N-i) = Z(N-i)  - J2(N-i+1) * B * G(N-i);
    J3(N-i) = M(N-i) * P(N-i) * M(N-i) - J2(N-i+1) * B * M(N-i) + 2 * sqrt(lambda3 * P(N-i)) + J3(N-i+1);
end

for j = 1:N  % 正着求输入和状态
    mu(j) = -G(j) * x(j) + M(j);
    %sigma2(j) = sqrt(lambda3 / P(j));
    sigma2(j) = (lambda3 / P(j));
    a = sqrt(3 * sigma2(j));
    delta(j) = unifrnd(-a, a);
    u(j) = mu(j) + delta(j);
    x(j+1) = A * x(j) + B * u(j);
end
%%
c1 = [0.85 0.33 0.10];
c2 = [0.93 0.69 0.13];
c4 = [0.49 0.18 0.56];
c3 = [0.00 0.45 0.74];
figure();
subplot(1,2,1);
n1 = 0:1:N;
p1 = plot(n1, x,'-','LineWidth',1,'color',c1);
% set(gca,"FontSize",15,"LineWidth",0.8);
% xlabel('N','FontSize',15); 
% ylabel('x', 'FontSize',15)  
% title('x','FontSize',15);
% hold on;
subplot(1,2,2);
n2 = 1:1:N;
% plot(n2, u,'LineWidth',1);
% title('u');
% subplot(2,2,3);
% % n1 = 0:1:N;
% plot(n2, mu);
% title('mu');
% subplot(2,2,4);
plot(n2, sigma2,'LineWidth',1,'color',c3);
% set(gca,"FontSize",15,"LineWidth",0.8);
% title('sigma^2','FontSize',15);
% hold on;
%%
% p4 = plot(n1, zeros(1,N+1),'LineWidth',1,'color',c4);
% legend('lambda3 = 15','lambda3 = 5', 'lambda3 = 1','FontSize',15);
%% Kalman滤波预测
% H = 1;  % 观测矩阵 H(k)
% P(1) = 1;  % 一步预测的协方差 P(k)
% w = 0.5 * randn(1,N+1);  % 模拟产生测量噪声
% Q = 1;
% R = std(w)^2;    % V(k)的协方差 covariance
% y(1) = x(1) + w(1);  % y是x的后验估计x(k|k)
% 
% for t = 2:N+1
%     x_pre(t) = A * y(t-1) + B * mu(t-1);  % x_pre是x的预测 x(k+1|k)
%     P(t) = A * P(t-1) * A' + Q;  % 一步预测的协方差 P(k+1|k)  
%     z(t) = H * x(t) + w(t);  % 观测方程 Z(k+1)=H(k+1)X(k+1)+W(k+1),Z(k+1)是k+1时刻的观测值
%     
%     S(t) = H * P(t) * H' + R;  % 观测向量的预测误差协方差 S(k+1)
%     K_(t) = H * P(t) / S(t);  % 卡尔曼滤波器增益 K(k+1) 
%     v(t) = z(t) - ( H * x_pre(t) );  % 测量残差 v(k+1)
%     y(t) = x_pre(t) + K_(t) * v(t);  % 状态更新 X(k+1|k+1)=X(k+1|k)+K(k+1)*v(k+1)
%     P(t) = (1 - H * K_(t)) * P(t);  % 误差协方差更新 P(k+1|k+1)=(I-K(k+1)*H(k+1))*P(k+1|k)
% end
% err = (x_pre(2:N+1) - x(2:N+1));
% E = norm(err, inf);
% figure();
% t1 = 1:N+1;
% t2 = 1:N;
% t3 = 2:N+1;
% plot(t1,y,'color',c1,'LineWidth',1.5);
% hold on;
% plot(t1,x,'color',c3,'LineWidth',1.5);
% plot(t2,x_pre(2:N+1),'color',c2,'LineWidth',1.5);
% plot(t3,err,'-.','color',c4,'LineWidth',1); 
% set(gca,"FontSize",15,"LineWidth",0.8);
% legend('estimation','true value','prediction','prediction error','FontSize',15);