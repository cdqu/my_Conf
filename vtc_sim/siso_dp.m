% Dynamic Programming simulation
% single in single out
clear;
clc;
T = 2;
N = 20;
dt = 0.1;
A = 1 + dt;
B = 1;
H = 0;
Q = 0.1;
R = dt;
x = zeros(1, N + 1);  % 状态
x(1) = 4;
u = zeros(1, N);  % 控制输入
K = zeros(1, N + 1);
F = zeros(1, N);
K(1) = H;
for i = 1:N  % 倒着求系数
    F(i) = - (R + B * K(i) * B)^(-1) * B * K(i) * A;
    K(i+1) = Q + F(i) * R * F(i) + (A + B * F(i)) * K(i) * (A + B * F(i));
end
for j = 1:N  % 正着求输入和状态
    u(j) = F(N-j+1) * x(j);
    x(j+1) = A * x(j) + B * u(j);
end
figure();
subplot(1,2,1);
n1 = 0:1:N;
plot(n1, x);
subplot(1,2,2);
n2 = 1:1:N;
plot(n2, u);

%% Kalman滤波预测
H = 1;  % 观测矩阵 H(k)
P(1) = 1;  % 一步预测的协方差 P(k)
w = 0.5 * randn(1,N+1);  % 模拟产生测量噪声
Q = 1;
R = std(w)^2;    % V(k)的协方差 covariance
y(1) = x(1) + w(1);  % y是x的后验估计x(k|k)

for t = 2:N+1
    x_pre(t) = A * y(t-1) + B * u(t-1);  % x_pre是x的预测 x(k+1|k)
    P(t) = A * P(t-1) * A' + Q;  % 一步预测的协方差 P(k+1|k)  
    z(t) = H * x(t) + w(t);  % 观测方程 Z(k+1)=H(k+1)X(k+1)+W(k+1),Z(k+1)是k+1时刻的观测值
    
    S(t) = H * P(t) * H' + R;  % 观测向量的预测误差协方差 S(k+1)
    K_(t) = H * P(t) / S(t);  % 卡尔曼滤波器增益 K(k+1) 
    v(t) = z(t) - ( H * x_pre(t) );  % 测量残差 v(k+1)
    y(t) = x_pre(t) + K_(t) * v(t);  % 状态更新 X(k+1|k+1)=X(k+1|k)+K(k+1)*v(k+1)
    P(t) = (1 - H * K_(t)) * P(t);  % 误差协方差更新 P(k+1|k+1)=(I-K(k+1)*H(k+1))*P(k+1|k)
end
err = (x_pre(2:N+1) - x(2:N+1));
E = norm(err, 1)/N;
% c1 = [246 83 20]./255;
% c2 = [124 187 0]./255;
% c3 = [0 161 241]./255;
% c4 = [255 187 0]./255;
c1 = [0.85 0.33 0.10];
c2 = [0.93 0.69 0.13];
c4 = [0.49 0.18 0.56];
c3 = [0.00 0.45 0.74];
% figure();
% t1 = 1:N+1;
% t2 = 1:N;
% t3 = 2:N+1;
% plot(t1,y,'color',c1,'LineWidth',1.5);
% hold on;
% plot(t1,x,'color',c3,'LineWidth',1.5);
% plot(t2,x_pre(2:N+1),'color',c2,'LineWidth',1.5);
% plot(t3,err,'-.','color',c4,'LineWidth',1.5); 
% set(gca,"FontSize",15,"LineWidth",0.8);
% legend('estimation','true value','prediction','prediction error','FontSize',15);
