clc;
clear;
Mmax = 2:2:16;
m_len = size(Mmax,2);
t = 5;
err_plot = zeros(1,m_len);
err = zeros(t,m_len);
for i = 2:2:16
    err_sum = 0;
    for j = 1:t
        res = q_est_2d(i);
        err_sum = err_sum + res;
        err(j,i) = res;
    end
    err_plot(i) = err_sum/t;
end
%%
figure();
plot(Mmax,err_plot(Mmax));
c = linspace(1,10,m_len);
hold on
for i = 2:2:16
    scatter(i,err(:,i),40,'filled','MarkerFaceColor',[0.93,0.69,0.13]);
    hold on
end
%%
clc;
clear;
tt = [];
for i = 2:2:10
    t0 = tic;
    q_est_2d(i);
    tt = [tt, toc(t0)];
end
%%
q_est_2d(8)