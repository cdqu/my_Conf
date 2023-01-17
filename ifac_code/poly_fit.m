clear;
clc;
A = [1.2,0;0,1.2];
B = [1,0;0,1];  % 2*2 n*m
H = 1*eye(2);
Q = zeros(2,2);
R = 0.5*eye(2);
N = 14;
x0 = [-5;-7];
y = my_lqr(A,B,N,H,Q,R,x0);
y_tr = y(:,11:15);
curr = y(:,10);
curr = curr + 0.02 * randn(size(curr));
r_est = [0.5772, -0.0521; -0.0521, 0.5242];
x = my_lqr(A,B,5,H,Q,r_est,curr);
err = [];
for i = 1:5
    err = [err, norm(x(:,i+1)-y_tr(:,i))];
end
%%
ob = y(:,1:10);
ob = ob + 0.02 * randn(size(ob));
n = 1:10;
T =4;
ans1 = polyfit(n,ob(1,:),T);
ans2 = polyfit(n,ob(2,:),T);
pf_x = zeros(2,5);
for i = 1:5
    k = 10+i;
    K = [];
    for j = 1:T+1
        K = [K; k^(T+1-j)];
    end
    pf_x(1,i) = ans1 * K;
    pf_x(2,i) = ans2 * K;
end
err2 = [];
for i = 1:5
    err2 = [err2, norm(pf_x(:,i)-y_tr(:,i))];
end
%%
ex = 0;
ey = 0;
for i = 1:5
    x1 = my_lqr(A,B,N,H,Q,R,[-5;-7]);
    x1 = x1(:,1:8);
    x1 = x1 + 0.01 * randn(size(x1));
    x2 = my_lqr(A,B,N,H,Q,R,[-4;-5]);
    x2 = x2(:,1:8);
    x2 = x2 + 0.01 * randn(size(x2));
    ans1 = polyfit(x1(1,:),x1(2,:),1);
    ans2 = polyfit(x2(1,:),x2(2,:),1);
    [tar1,tar2] = linecross(ans1(1),ans1(2),ans2(1),ans2(2));
    ex = ex + tar1;
    ey = ey + tar2;
end
ex/5
ey/5

function [x,y]=linecross(k1,b1,k2,b2)
  if k1==k2 & b1==b2
      disp('chong he');
  elseif k1==k2 & b1~=b2
      disp('wu jiao dian');
  else
     x=(b2-b1)/(k1-k2);
     y=k1*x+b1;
  end
end