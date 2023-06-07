%% 使用 MATLAB 连接 ODBC 远程数据库读写 demo
% connect to 192.168.139.18
% read "robot_positions.robot_pos_cam_all"
% write in "robot_commands.commands_all"
clear;clc;

%% Make connection to database
connA = database('DATABASE','ControlCommand','Erleng921010');   % ODBC数据源名称,SQL Server的用户名和密码

robotVelOmega = zeros(1,45);  % vwr中填写机器人的控制指令（Vel_x, Vel_y, Omega）

% %%% vwr 转换成 sql 语句并执行的模板
% insertSql = sqlGenerate(robotVelOmega);
% curs = exec(connA, insertSql);

%% demo:规定运行的速度 x,y,theta三维依次到达指定位置
% 提示：在控制指令中，theta优先级高于x,y
dataWant = zeros(1,45); % 需要机器人运动到的坐标（Pos_x, Pos_y, Theta)
robotID_0 = 8;    % robotID是0，机器人的编号是1
robotID_1 = 1;

% Pos_x \in [40,4700], Pos_y \in [285,2768], Theta \in [0,360]，xy不要过于靠近边界否则摄像头可能没法读取数据
dataWant(1:6,3*robotID_0 + 1:3*robotID_0 + 3) = [2600,800,0; 3200,800,0; 2000,800,0; 2600,800,0;1800,1600,0; 2600,800,0];
% dataWant(1:6,3*robotID_1 + 1:3*robotID_1 + 3) = [2600,1600,0; 2000,1600,0; 3200,1600,0; 2600,1600,0; 2600,1600,0; 2600,1600,0];

[N,~] = size(dataWant);

for ciuu = 1:6
    t = 1;
    while 1
        str=['机器人正在从',num2str(ciuu-1),'到',num2str(ciuu)];
        disp(str)
        % 读取摄像头数据并进行预处理
        dataCamera = sqlread(connA,"robot_positions.robot_pos_cam_all",'MaxRows',100);
        dataCameraProcessed = sortrows(dataCamera, 1, 'descend');
        dataReal = table2array(dataCameraProcessed(1,2:end));
        
        % 几个机器人都基本到指定的位置了，就 break 去下一个位置
        if ifClose(dataWant(ciuu,:),dataReal ,robotID_0) && ifClose(dataWant(ciuu,:), dataReal,robotID_1) && ifClose(dataWant(ciuu,:), dataReal,robotID_2)  
            disp('mission completed');
            break
        else
            [robotVelX_0, robotVelY_0, robotOmega_0] = compute_vel(dataReal, robotID_0, dataWant(ciuu,:));
%             [robotVelX_1, robotVelY_1, robotOmega_1] = compute_vel(dataReal, robotID_1, dataWant(ciuu,:));
            robotVelOmega(3*robotID_0 + 1:3*robotID_0 + 3) = [robotVelX_0, robotVelY_0, robotOmega_0];
%             robotVelOmega(3*robotID_1 + 1:3*robotID_1 + 3) = [robotVelX_1, robotVelY_1, robotOmega_1];
            insertSql_1 = sqlGenerate(robotVelOmega);
            curs1 = exec(connA, insertSql_1);
        end
    end
end

%% Close connection to database
close(connA);


