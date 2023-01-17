% 2d LQR
function x = my_lqr(a,b,n,h,q,r,x0)
    N = n;
    A = a;
    B = b;
    H = h;
    Q = q;
    R = r;
    P = zeros(2,2,N + 1);
    P(:,:,N + 1) = H;
    K = zeros(2,2,N);
    x = zeros(2, N + 1);  % 状态
    x(:,1) = x0;
    u = zeros(2, N); 
    for i = 0:N-1  % 倒着求系数
        P(:,:,N-i) = A'*P(:,:,N-i+1)*A - A'*P(:,:,N-i+1)*B/(R+B'*P(:,:,N-i+1)*B)*B'*P(:,:,N-i+1)*A;
    end
    y = [];
    for j = 1:N  % 正着求输入和状态
        K(:,:,j) = (R + B' * P(:,:,j+1) * B) \ B' * P(:,:,j+1) * A;
        u(:,j) = -K(:,:,j) * x(:,j);
        x(:,j+1) = A * x(:,j) + B * u(:,j);
        y = [y;x(:,j+1)];
    end
%     K
%     P
end