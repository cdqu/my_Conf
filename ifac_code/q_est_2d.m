% 2d case
function [r_est] = q_est_2d(m)
    global N
    global x0
    global y
    global A
    global M
    N = 10;
    M = m;
    A = [1.2,0;0,1.2];  % 2*2 n* n
    B = [1,0;0,1];  % 2*2 n*m
%     B = [1;1];
    H = 1*eye(2);
    Q = zeros(2,2);
    R = 0.5*eye(2);
    x0 = randi(5,2,M);
    y = [];
    for j = 1:M
        y = [y, my_lqr(A,B,N,H,Q,R,x0(:,j))];
    end
    y = y + 0.02 * randn(size(y));
    % C = zeros((N-1)*2,2*N);
    % for i = 1:N-1
    %     C(i,2*i) = 1;
    % end

    fun = @obj;
    nonlcon = @cons;
    X0 = zeros(2*(N*M+1),2);
    % X0(1:2,:) = eye(2);
    lb = -ones(2*(N*M+1),2) * Inf;
    lb(1:2,:) = eye(2);
    ub = ones(2*(N*M+1),2) * Inf;
    % ub(1:2,:) = zeros(2);
%     option = optimoptions(@fmincon,'Algorithm','sqp');
    x = fmincon(fun,X0,[],[],[],[],lb,[],nonlcon);
    r_est = inv(x(1:2,:));
    err = norm(r_est - R)/norm(R);
end
% objective func
function J = obj(x)
    global y
    global N
    global M
    J = 0;
    for j = 1:M
        J = J + norm(x(3+2*N*(j-1):(2+2*N*j),1)-y(:,j));
    end
    J = J/(N*M);
end
% constraints
function [c_x,ceq_x] = cons(x)
    global x0
    global N
    global A
    global M
    q = x(1:2,:);
    E_td = [eye(2), q; zeros(2), zeros(2)];
    F_td = [zeros(2), zeros(2); -eye(2), eye(2)];
    E = [eye(2), q; zeros(2), A'];
    F = [A, zeros(2); zeros(2), eye(2)];
    FR = [E_td, zeros(4,4*N-8),F_td];
    FR = [FR; zeros(4*(N-1), 4*N)];
    for i = 2:N
        FR(4*(i-1)+1:4*i, 4*(i-2)+1:4*(i-1)) = -F;
        FR(4*(i-1)+1:4*i, 4*(i-1)+1:4*i) = E;
    end
    A_td = [A; zeros(4*N-2,2)];
    Z = [];
    for j = 1:M
        zz = [];
        for i = 1:N
            zz = [zz; 
                  x(2*(N*(j-1)+i)+1:2*(N*(j-1)+i)+2,1); 
                  x(2*(N*(j-1)+i)+1:2*(N*(j-1)+i)+2,2)];
        end
        Z = [Z, zz];
    end
    q_td = inv(q)-inv(q)';
%     c_x = -eig(inv(q));
    c_x = [];
%     ceq_x = [FR * Z - A_td * x0; q_td(:)];
    ceq_x = q_td(:);
    for j = 1:M
        ceq_x = [ceq_x; FR * Z(:,j) - A_td * x0(:,j)];
    end
end