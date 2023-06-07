clc;
clear;
N = 20;
delt = 0.5;
A = eye(2)*1.1;  % 2*2 n* n
B = eye(2)*delt;  % 2*2 n*m
H = eye(2);
Q = eye(2)*0;
R = [0.4,0;0,0.4];
x_start = [1600;1000];
x_end = [10;10];
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
traj = [y,zeros(N+1,1)];