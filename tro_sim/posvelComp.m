%% 使用 MATLAB 连接 ODBC 远程数据库 long 表数据分析
% connect to 192.168.139.18
% read "robot_positions.robot_pos_cam_all_long", "robot_commands.commands_all_long"
% clear;clc;
% close all;
% 
% %% Make connection to database
% connA = database('DATABASE','ControlCommand','Erleng921010');   % ODBC数据源名称,SQL Server的用户名和密码
% 
% %% 读取摄像头数据并进行预处理
% query = ('SELECT * FROM robot_commands.commands_all_long ORDER BY Time desc');
% commands = fetch(connA,query);
% 
% query_all = ('SELECT * FROM robot_positions.robot_pos_cam_all_long ORDER BY Time desc');
% dataCamera_all = fetch(connA,query_all);
% 
% %% 把 table 数据转换为 double 数据表，将单个摄像头的数据加偏置乘系数
% commandsT(:,1) = datenum(table2array(commands(:,1)));
% commandsT(:,2:46) = table2array(commands(:,2:46));
% 
% dataCamera_allT(:,1) = datenum(table2array(dataCamera_all(:,1)));
% dataCamera_allT(:,2:46) = table2array(dataCamera_all(:,2:46));

%% 画折线图
label = 5;  % robot1 x 轴数据
figure;
plot(commandsT(:,1),commandsT(:,label)*26/3+2600, '.-','Color','r', 'MarkerSize',10);hold on
plot(dataCamera_allT(:,1),dataCamera_allT(:,label), '.-','Color','#4976C6', 'MarkerSize',10); 
legend('vel', 'pos');

%% Close connection to database
close(connA);

