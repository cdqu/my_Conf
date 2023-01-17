clear;
clc;
A = [1.2,0;0,1.2];
B = [1,0;0,1];  % 2*2 n*m
H = 1*eye(2);
Q = zeros(2,2);
R = 0.5*eye(2);
L = 10;
N = 15;
P = zeros(2,2,N + 1);
P(:,:,N + 1) = H;
K = zeros(2,2,N);
x_ = zeros(2, N + 1);  % 状态
x_(:,1) = [6;8];
u_ = zeros(2, N); 
for i = 0:N-1  % 倒着求系数
    P(:,:,N-i) = A'*P(:,:,N-i+1)*A - A'*P(:,:,N-i+1)*B/(R+B'*P(:,:,N-i+1)*B)*B'*P(:,:,N-i+1)*A;
end
for j = 1:N  % 正着求输入和状态
    K(:,:,j) = (R + B' * P(:,:,j+1) * B) \ B' * P(:,:,j+1) * A;
    u_(:,j) = -K(:,:,j) * x_(:,j);
    x_(:,j+1) = A * x_(:,j) + B * u_(:,j);
end
x0 = x_(:,1:L);
x0 = x0 + 0.01 * randn(size(x0));
%%
Nmin = L + 1;
Nmax = 25;
err = zeros(1, Nmax - Nmin + 1);
for N = Nmin:1:Nmax
    x = zeros(2, N + 1);  % 状态
    x(:,1) = x_(:,1);
    u = zeros(2, N);  % 控制输入
    P = zeros(2,2,N + 1);
    P(:,:,N + 1) = H;
    K = zeros(2,2,N);
    for i = 0:N-1  % 倒着求系数
        P(:,:,N-i) = A'*P(:,:,N-i+1)*A - A'*P(:,:,N-i+1)*B/(R+B'*P(:,:,N-i+1)*B)*B'*P(:,:,N-i+1)*A;
    end
    for j = 1:N  % 正着求输入和状态
        K(:,:,j) = (R + B' * P(:,:,j+1) * B) \ B' * P(:,:,j+1) * A;
        u(:,j) = -K(:,:,j) * x(:,j);
        x(:,j+1) = A * x(:,j) + B * u(:,j);
    end
    err(N-L) = norm(x(:,1:L)-x0);
end
plot([Nmin:Nmax],err);
