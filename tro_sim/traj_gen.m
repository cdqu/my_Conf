% clc;
clear;
N = 10;
delt = 0.3;
A = eye(2)*1;  % 2*2 n* n
B = eye(2)*delt;  % 2*2 n*m
H = eye(2);
Q = eye(2)*0.1;    %% 0:匀速 0.1:变速
R = [0.8,0;0,0.8];   %% 相同直线，不同曲线
x_start = [1310;1471];
x_end = [3110;2327];
x0 = x_start - x_end;
[y,u] = my_lqr(A,B,N,H,Q,R,x0);
scatter(y(:,1),y(:,2));
% figure();
% plot(1:1:N,y(:,1));
% plot(1:1:N,u(1,:));
% hold on;
% plot(1:1:N,u(2,:));
%%
y(:,1) = y(:,1) + x_end(1);
y(:,2) = y(:,2) + x_end(2);
traj = [y,zeros(N+1,1)]
save my_traj traj
vel_xy=u';
save my_vel vel_xy