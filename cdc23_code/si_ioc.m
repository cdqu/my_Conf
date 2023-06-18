%%% System identification approach for inverse optimal control of 
%%% finite-horizon linear quadratic regulators 论文复现
clear;
% 创建决策变量
n = 2;
m = 2;
A = [1.2,0;0,1.2];
B = [1,0;0,1];
H = 1*eye(2);
Q = H;
R = 0.5*eye(2);
N = 10;
M = 2;
X = [];
for i=1:M
    x0 = randi(5,2,1);
    [y,K] = my_lqr(A,B,N,H,Q,R,x0);
    X = [X,y];
end
% 求中间参数
phi_N = [];
x_zero = X(1:n,:);
for i = 1:N
    x_plus = X(1+i*n:(i+1)*n,:);
    phi = x_zero*pinv(x_plus);
    phi_N = [phi_N, phi];
end
A_N = [];
gamma_N = [];
for i = 1:N-1
    Ai = phi_N(:,i*n+1:i*n+n) * inv(phi_N(:,(i-1)*n+1:(i-1)*n+n));
    A_N = [A_N, Ai];
    gamma_i = pinv(B)*(A*inv(Ai)-eye(n));
    gamma_N = [gamma_N, gamma_i];
end
zeta_0 = inv(R)*B'*Q; %%%%?????我请问呢
zeta_N = [zeta_0];
for i = 1:N-1
    zeta_i = gamma_N(:,(N-1-i)*n+1:(N-i)*n);
    for j = 1:i
        zeta_i = (zeta_i-zeta_N(:,(j-1)*n+1:j*n))*inv(A_N(:,(N-2+j-i)*n+1:(N-1+j-i)*n));
    end
    zeta_N = [zeta_N, zeta_i];
end
%% 求hankel矩阵
hank = [];
n1=2;
n2=7;
for i = 1:n1+1 % n1=4 n2=5
    h = [];
    for j = 1:n2+1
        h = [h, zeta_N(:,(i+j-2)*2+1:(i+j-2)*2+2)'];
    end
    hank = [hank;h];
end
[U,S,V] = svd(hank);
u1 = U(:,1:2);
v1 = V(1:2,:)';
s1 = S(1:2,1:2);
a_hat = u1(n+1:n*n1,:)*pinv(u1(1:n*n1-n,:));
q_hat = u1(1:n,:);
br_hat = s1*v1(1:m,:)';
%%
p = [1,0,0,0;0,0,1,0;0,1,0,0;0,0,0,1];
M = [kron(a_hat',eye(2))-kron(eye(2),A);
    kron(br_hat',pinv(B))-kron(pinv(B),br_hat')*p;
    kron(eye(2),q_hat')-kron(q_hat',eye(2))*p];
[U_,S_,V_] = svd(M'*M);
omega = V_(end,:);
omega = reshape(omega, n,n);
R_est = inv(pinv(B)*omega*br_hat)
Q_est = q_hat*inv(omega)