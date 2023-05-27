% siso ilqg
% x(k+1)=1/2 x(k)^2+u(k), J=E[lambda1 x(N)^2+sum(lambda2 u(k)^2))]
% initialize
clc;
clear;
N = 10;
xbar = zeros(1,N);
xbar(1) = 2;
ubar = -0.1 * ones(1,N-1);
for i = 1:N-1
    xbar(i+1) = 0.5 * xbar(i)^2 + ubar(i);
end
x0 = xbar;
u0 = ubar;
% linearization
t = 1;
lambda1 = 1;
lambda2 = 0.5;
Q = 0;
I = zeros(1,N-1);
L = zeros(1,N-1);
delta_u = zeros(1,N-1);
delta_x = zeros(1,N);
u = zeros(1,N-1);
x = zeros(1,N);
x(1) = 2;
a = [0.4 * ones(1,7)  ,0.05, 0.01];
while t < 15
    A = xbar(1:N-1);
    B = ones(1,N-1);
    S = zeros(1,N);
    S(N) = 2 * lambda1;
    s = zeros(1,N);
    s(N) = 2 * lambda1 * xbar(N);
    shat = zeros(1,N);
    for i = N-1:-1:1
        r = 2 * lambda2 * ubar(i);
        R = 2 * lambda2;
        g = r + B(i)' * s(i+1);
        G = B(i)' * S(i+1) * A(i);
        H = R + B(i)' * S(i+1) * B(i);
        I(i) = -H^(-1) * g;
        L(i) = -H^(-1) * G;
        S(i) = Q + A(i)' * S(i+1) * A(i) + L(i)' * H * L(i) + L(i)' * G + G' * L(i);
        s(i) = A(i)' * s(i+1) + L(i)' * H * I(i) + L(i)' * g + G' * I(i);
        %shat = 
    end
    for j = 1:N-1
        delta_u(j) = I(j) + L(j) * delta_x(j);
        u(j) = delta_u(j) + ubar(j);
        %delta_x(j+1) = A(j) * delta_x(j) + B(j) * delta_u(j);
        %x(j+1) = delta_x(j+1) + x(j+1);
        x(j+1) = 0.5 * x(j)^2 + u(j);
       % if t == 14
        %    noise = unifrnd(-a(j), a(j));
         %   x(j+1) = x(j+1) + noise;
       % end
        delta_x(j+1) = x(j+1) - xbar(j+1);
        ubar = u;
        xbar = x;
    end
    t = t + 1;
end
for j = 1:N-2
    noise = unifrnd(-a(j), a(j));
	x(j+1) = x(j+1) + noise;
    u(j+1) = u(j+1) + noise;
end
noise = unifrnd(-a(N-1), a(N-1));
x(N) = x(N) + noise;
%%
c1 = [0.85 0.33 0.10];
c2 = [0.93 0.69 0.13];
figure(1);
n1 = 0:1:N-1;
p1 = plot(n1, x,'-','LineWidth',1,'color',c1);
hold on;
n2 = 0:1:N-2;
p2 = plot(n1, x0,'-','LineWidth',1,'color',c2);
figure(2);
p3 = plot(n2, u,'-','LineWidth',1,'color',c1);
hold on;
p4 = plot(n2, u0,'-','LineWidth',1,'color',c2);