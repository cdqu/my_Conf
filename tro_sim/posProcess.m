%% 使用 MATLAB 连接 ODBC 远程数据库 long 表数据分析
% connect to 192.168.139.18
% read "robot_positions.robot_pos_cam_xxx_long"
clear;clc;
close all;

%% Make connection to database
connA = database('DATABASE','ControlCommand','Erleng921010');   % ODBC数据源名称,SQL Server的用户名和密码


%% 读取摄像头数据并进行预处理
query_158 = ('SELECT * FROM robot_positions.robot_pos_cam_158_long ORDER BY Time desc limit 1000');
dataCamera_158 = fetch(connA,query_158);
query_159 = ('SELECT * FROM robot_positions.robot_pos_cam_159_long ORDER BY Time desc limit 1000');
dataCamera_159 = fetch(connA,query_159);
query_160 = ('SELECT * FROM robot_positions.robot_pos_cam_160_long ORDER BY Time desc limit 1000');
dataCamera_160 = fetch(connA,query_160);
query_all = ('SELECT * FROM robot_positions.robot_pos_cam_all_long ORDER BY Time desc limit 3000');
dataCamera_all = fetch(connA,query_all);


%% 把 table 数据转换为 double 数据表，将单个摄像头的数据加偏置乘系数
dataCamera_158T(:,1) = datenum(table2array(dataCamera_158(:,1)));
dataCamera_158T(:,2:3:46) = table2array(dataCamera_158(:,2:3:46)) * 2.434;
dataCamera_158T(:,3:3:46) = table2array(dataCamera_158(:,3:3:46)) * 2.473;

dataCamera_159T(:,1) = datenum(table2array(dataCamera_159(:,1)));
dataCamera_159T(:,2:3:46) = (table2array(dataCamera_159(:,2:3:46)) + 663) * 2.434;
dataCamera_159T(:,3:3:46) = (table2array(dataCamera_159(:,3:3:46)) + 21.9) * 2.473;

dataCamera_160T(:,1) = datenum(table2array(dataCamera_160(:,1)));
dataCamera_160T(:,2:3:46) = (table2array(dataCamera_160(:,2:3:46)) + 1230.1 + 25 / 2.434) * 2.434;
dataCamera_160T(:,3:3:46) = (table2array(dataCamera_160(:,3:3:46)) + 21.9+3.67) * 2.473;

dataCamera_allT(:,1) = datenum(table2array(dataCamera_all(:,1)));
dataCamera_allT(:,2:46) = table2array(dataCamera_all(:,2:46));


%% 画折线图
% robot10 x 轴数据
figure;
plot(dataCamera_158T(:,1),dataCamera_158T(:,20), '.-','Color','#E58C50', 'MarkerSize',10);hold on
plot(dataCamera_159T(:,1),dataCamera_159T(:,20), '.-','Color','#1DB964', 'MarkerSize',10);hold on
plot(dataCamera_160T(:,1),dataCamera_160T(:,20), '.-','Color','#FFD453', 'MarkerSize',10);hold on
plot(dataCamera_allT(:,1),dataCamera_allT(:,20), '.-','Color','#4976C6', 'MarkerSize',10);
legend('158', '159', '160', 'all');

% robot6 y 轴数据
% figure;
% plot(dataCamera_158T(:,1),dataCamera_158T(:,21), '.-','Color','#E58C50', 'MarkerSize',10);hold on
% plot(dataCamera_159T(:,1),dataCamera_159T(:,21), '.-','Color','#1DB964', 'MarkerSize',10);hold on
% plot(dataCamera_160T(:,1),dataCamera_160T(:,21), '.-','Color','#FFD453', 'MarkerSize',10);hold on
% plot(dataCamera_allT(:,1),dataCamera_allT(:,21), '.-','Color','#4976C6', 'MarkerSize',10);
% legend('158', '159', '160', 'all');

% figure;
% plot(dataCamera_160T(:,1),dataCamera_160T(:,20),'Color','#FFD453','LineWidth',1.8);hold on

%% 截取某一段画折线图，也可以在上面的图里手动截取
% begin = 738489.4698;
% stop = 738489.4699;
% toDelete_158 = (dataCamera_158T(:,1) < begin) | (dataCamera_158T(:,1) > stop);
% dataCamera_158T(toDelete_158, :) = [];
% toDelete_159 = (dataCamera_159T(:,1) < begin) | (dataCamera_159T(:,1) > stop);
% dataCamera_159T(toDelete_159, :) = [];
% toDelete_160 = (dataCamera_160T(:,1) < begin) | (dataCamera_160T(:,1) > stop);
% dataCamera_160T(toDelete_160, :) = [];
% toDelete_all = (dataCamera_allT(:,1) < begin) | (dataCamera_allT(:,1) > stop);
% dataCamera_allT(toDelete_all, :) = [];
% 
% figure;
% plot(dataCamera_158T(:,1),dataCamera_158T(:,20),'Color','#E58C50','LineWidth',1.8);hold on
% plot(dataCamera_159T(:,1),dataCamera_159T(:,20),'Color','#1DB964','LineWidth',1.8);hold on
% plot(dataCamera_160T(:,1),dataCamera_160T(:,20),'Color','#FFD453','LineWidth',1.8);hold on
% plot(dataCamera_allT(:,1),dataCamera_allT(:,20),'Color','#4976C6','LineWidth',1.8);
% legend('158', '159', '160', 'all');

%% Close connection to database
close(connA);