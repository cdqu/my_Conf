%% 使用 MATLAB 连接 ODBC 远程数据库 long 表数据分析
% connect to 192.168.139.18
% read "robot_commands.commands_all_long"
clear;clc;
close all;

%% Make connection to database
connA = database('DATABASE','ControlCommand','Erleng921010');   % ODBC数据源名称,SQL Server的用户名和密码


%% 读取摄像头数据并进行预处理
query = ('SELECT * FROM robot_commands.co,mmands_all_long ORDER BY Time desc');
commands = fetch(connA,query);


%% 把 table 数据转换为 double 数据表
commandsT(:,1) = datenum(table2array(commands(:,1)));
commandsT(:,2:46) = table2array(commands(:,2:46));


%% 画折线图

figure;
plot(commandsT(:,1),commandsT(:,2), '.-','Color','#E58C50', 'MarkerSize',10);hold on
% plot(commandsT(:,1),commandsT(:,3), '.-','Color','#1DB964', 'MarkerSize',10);hold on
% plot(commandsT(:,1),commandsT(:,5), '.-','Color','#FFD453', 'MarkerSize',10);hold on
% plot(commandsT(:,1),commandsT(:,8), '.-','Color','#4976C6', 'MarkerSize',10);
% legend('1x', '1y', '2x', '2y');



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