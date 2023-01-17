% Dynamic Programming simulation
% single in single out
function y = lqr_dp(a,b,n,h,q,r,x0)
    N = n;
    A = a;
    B = b;
    H = h;
    Q = q;
    R = r;
    x = zeros(1, N + 1);  % 状态
    x(1) = x0;
    u = zeros(1, N);  % 控制输入
    K = zeros(1, N + 1);
    P = zeros(1, N);
    K(1) = H;
    for i = 1:N  % 倒着求系数
        P(i) = - (R + B * K(i) * B)^(-1) * B * K(i) * A;
        K(i+1) = Q + P(i) * R * P(i) + (A + B * P(i)) * K(i) * (A + B * P(i));
    end
    for j = 1:N  % 正着求输入和状态
        u(j) = P(N-j+1) * x(j);
        x(j+1) = A * x(j) + B * u(j);
    end
    y = x';
end
% figure();
% subplot(1,2,1);
% n1 = 0:1:N;
% plot(n1, x);
% subplot(1,2,2);
% n2 = 1:1:N;
% plot(n2, u);