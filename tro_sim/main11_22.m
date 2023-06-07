%% 使用 MATLAB 连接 ODBC 远程数据库读写 demo
% connect to 192.168.139.18
% read "robot_positions.robot_pos_cam_all"
% write in "robot_commands.commands_all"
clear;clc;

%% Make connection to database
connA = database('DATABASE','ControlCommand','Erleng921010');   % ODBC 数据源名称，SQL Server 的用户名和密码

%% Initialization
% 提示：在控制指令中，theta 优先级高于 x,y
% 机器人总数及 ID 设定
robotNum = 3;       % 机器人总数
robotID_0 = 1;      % robotID 是 0，机器人的编号是 1
robotID_1 = 8; %9;
robotID_2 = 3; %11;

%%% dataWant 中填写需要机器人运动到的坐标（Pos_x, Pos_y, Theta)
% Pos_x \in [40,4700]
% Pos_y \in [285,2768]
% Theta \in [0,360]
% x, y 不要过于靠近边界否则摄像头可能没法读取数据
dataWant = zeros(1,45);
dataWant(1:6,3*robotID_0 + 1:3*robotID_0 + 3) = [2600,800,0; 3200,800,0; 2000,800,0; 2600,800,0;1800,1600,0; 2600,800,0];
% dataWant(1:6,3*robotID_1 + 1:3*robotID_1 + 3) = [450,2020,0; 450,2020,0; 450,2020,0; 450,2020,0; 450,2020,0; 450,2020,0];
% dataWant(1:6,3*robotID_2 + 1:3*robotID_2 + 3) = [376,2917,0; 376,2917,0; 376,2917,0; 376,2917,0; 376,2917,0; 376,2917,0];
dataWant(1:6,3*robotID_1 + 1:3*robotID_1 + 3) = [2600,1600,0; 2000,1600,0; 3200,1600,0; 2600,1600,0; 2600,1600,0; 2600,1600,0];
dataWant(1:6,3*robotID_2 + 1:3*robotID_2 + 3) = [2600,2400,0; 3200,2400,0; 2000,2400,0; 2600,2400,0; 3400,1600,0; 2600,2400,0];

%%% robotVelOmega 中填写机器人的控制指令（Vel_x, Vel_y, Omega）
% Vel_x, Vel_y, Omega \in [-1280, 1280]
% Vel_x, Vel_y 设成 150 就可以动起来，一般 300 或 400 就可以动得挺快了
robotVelOmega = zeros(1,45);

i = 1;
query = ('SELECT * FROM robot_positions.robot_pos_cam_all ORDER BY Time desc LIMIT 1');
dataCamera = fetch(connA,query);
dataReal = table2array(dataCamera(1,2:end));
datalast = dataReal;
dataReal_temp(i,:) = dataReal;      % 存储使用的原始摄像头数据
dataReal_temp1(i,:) = dataReal;     % 存储补偿后的摄像头数据
sqltmp(i,1) = "hello";

% 计算预期坐标相应参数
t0 = 0.05;      % 控制周期
delta = 80;     % 预计与实际偏差
factor = 0.65;	% 实际距离/理论距离
sum = [1,1,1];  % 累计偏差时间

% DeX 与 DeY 是预期的 x,y 坐标
DeX_0 = dataReal(1, 3*robotID_0 + 1);
DeX_1 = dataReal(1, 3*robotID_1 + 1);
DeX_2 = dataReal(1, 3*robotID_2 + 1);
DeY_0 = dataReal(1, 3*robotID_0 + 2);
DeY_1 = dataReal(1, 3*robotID_1 + 2);
DeY_2 = dataReal(1, 3*robotID_2 + 2);

%% 循环跑编队
while 1
    for ciuu = 1:6
        t = 1;
        while 1
            tic;    % 计时开始
            datalast = dataReal;
            
            % 读取摄像头数据
            query = ('SELECT * FROM robot_positions.robot_pos_cam_all ORDER BY Time desc LIMIT 1');
            dataCamera = fetch(connA,query);
            dataReal = table2array(dataCamera(1,2:end));
            dataReal_temp(i,:) = dataReal;
            
            % 几个机器人都基本到指定的位置了，就 break 去下一个位置
            if ifClose(dataWant(ciuu,:), dataReal, robotID_0) && ifClose(dataWant(ciuu,:), dataReal, robotID_1) && ifClose(dataWant(ciuu,:), dataReal, robotID_2)
                disp('mission completed');
                break
            else
                % 比较预期位置与实际
%                 disp(norm([DeX_0, DeY_0] - dataReal(1, 3*robotID_0 + 1:3*robotID_0 + 2)));
%                 disp(norm([DeX_1, DeY_1] - dataReal(1, 3*robotID_1 + 1:3*robotID_1 + 2)));
%                 disp(norm([DeX_2, DeY_2] - dataReal(1, 3*robotID_2 + 1:3*robotID_2 + 2)));
                
                if (norm([DeX_0, DeY_0] - dataReal(1, 3*robotID_0 + 1:3*robotID_0 + 2)) > delta*sqrt(sum(1)))
                    dataReal(1, 3*robotID_0 + 1:3*robotID_0 + 2) = [DeX_0, DeY_0];
                    sum(1) = sum(1) + 1;
                else
                    sum(1) = 1;
                end
                if (norm([DeX_1, DeY_1] - dataReal(1, 3*robotID_1 + 1:3*robotID_1 + 2)) > delta*sqrt(sum(2)))
                    dataReal(1, 3*robotID_1 + 1:3*robotID_1 + 2) = [DeX_1, DeY_1];
                    sum(2) = sum(2) + 1;
                else
                    sum(2) = 1;
                end
                if (norm([DeX_2, DeY_2] - dataReal(1, 3*robotID_2 + 1:3*robotID_2 + 2)) > delta*sqrt(sum(3)))
                    dataReal(1, 3*robotID_2 + 1:3*robotID_2 + 2) = [DeX_2, DeY_2];
                    sum(3) = sum(3) + 1;
                else
                    sum(3) = 1;
                end
                
                dataReal_temp1(i,:) = dataReal;
                
                [robotVelX_0, robotVelY_0, robotOmega_0] = compute_vel_pid(dataReal, datalast, robotID_0, dataWant(ciuu,:));
                [robotVelX_1, robotVelY_1, robotOmega_1] = compute_vel_pid(dataReal, datalast, robotID_1, dataWant(ciuu,:));
                [robotVelX_2, robotVelY_2, robotOmega_2] = compute_vel_pid(dataReal, datalast, robotID_2, dataWant(ciuu,:));
                
                robotVelOmega(3*robotID_0 + 1:3*robotID_0 + 3) = [robotVelX_0, robotVelY_0, robotOmega_0];
                robotVelOmega(3*robotID_1 + 1:3*robotID_1 + 3) = [robotVelX_1, robotVelY_1, robotOmega_1];
                robotVelOmega(3*robotID_2 + 1:3*robotID_2 + 3) = [robotVelX_2, robotVelY_2, robotOmega_2];
                
                [insertSql_1,insertSql_2] = sqlGenerate(robotVelOmega);
                sqltmp(i,1) = insertSql_1;
                curs1 = exec(connA, insertSql_1);
                curs2 = exec(connA, insertSql_2);
            end
            % 小车速度转到全局坐标，便于下一步计算预期位置；
            [rVelX_0, rVelY_0] = coordinateTrans(360-dataReal(1, 3*robotID_0 + 3),[robotVelX_0, robotVelY_0]);
            [rVelX_1, rVelY_1] = coordinateTrans(360-dataReal(1, 3*robotID_1 + 3),[robotVelX_1, robotVelY_1]);
            [rVelX_2, rVelY_2] = coordinateTrans(360-dataReal(1, 3*robotID_2 + 3),[robotVelX_2, robotVelY_2]);
            % 计算预期的位置
            DeX_0 = dataReal(1,3*robotID_0 + 1) + factor * t0 * rVelX_0;
            DeX_1 = dataReal(1,3*robotID_1 + 1) + factor * t0 * rVelX_1;
            DeX_2 = dataReal(1,3*robotID_2 + 1) + factor * t0 * rVelX_2;
            DeY_0 = dataReal(1,3*robotID_0 + 2) + factor * t0 * rVelY_0;
            DeY_1 = dataReal(1,3*robotID_1 + 2) + factor * t0 * rVelY_1;
            DeY_2 = dataReal(1,3*robotID_2 + 2) + factor * t0 * rVelY_2;
            i = i + 1;
            t = toc;        % 计时结束，t是发送命令的周期
            pause(t0 - t);  % 设置控制频率
            end
    end
end

%% Close connection to database
close(connA);


