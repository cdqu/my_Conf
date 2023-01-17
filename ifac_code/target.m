clear;
clc;
N = 15;
dt = 0.5;
A = [1 0 dt 0; 0 1 0 dt; 0 0 1 0; 0 0 0 1];  % 4*4 n*n
B = [0 0; 0 0; dt 0; 0 dt];  % 4*2 n*m
H = eye(4)*1;
R = dt * eye(2);

P = zeros(4,4,N + 1);
P(:,:,N + 1) = H;
K = zeros(2,4,N);

x = zeros(4, N + 1);  % 状态
x(:,1) = [5; 5; 0; 0];
u = zeros(2, N); 

for i = 0:N-1  % 倒着求系数
    K(:,:,N-i) = inv(R + B' * P(:,:,N-i+1) * B) * B' * P(:,:,N-i+1) * A;
    P(:,:,N-i) = K(:,:,N-i)' * R * K(:,:,N-i) + (A - B * K(:,:,N-i))' * P(:,:,N-i+1) * (A - B * K(:,:,N-i));
end

for j = 1:N  % 正着求输入和状态
    u(:,j) = - K(:,:,j) * x(:,j);
    x(:,j+1) = A * x(:,j) + B * u(:,j);
end
%%
figure();
scatter(x(1,1:N+1),x(2,1:N+1));
figure();
plot(x(3,:));