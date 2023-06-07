% 开环lqr控制
clear;clc;
connA = database('DATABASE','ControlCommand','Erleng921010');   % ODBC数据源名称,SQL Server的用户名和密码

robotVelOmega = zeros(1,45);  % vwr中填写机器人的控制指令（Vel_x, Vel_y, Omega）
dataWant = zeros(1,45); % 需要机器人运动到的坐标（Pos_x, Pos_y, Theta)
robotID_0 = 8;
dataWant(1:6,3*robotID_0 + 1:3*robotID_0 + 3) = [2600,800,0; 3200,800,0; 2000,800,0; 2600,800,0;1800,1600,0; 2600,800,0];
velwant = [];
[N,~] = size(velwant);

for ciuu = 1:N
    str=['机器人正在从',num2str(ciuu-1),'到',num2str(ciuu)];
    disp(str)
    for tnum = 1:10 %运行10*0.02s
        robotVelOmega(3*robotID_0 + 1:3*robotID_0 + 3) = velwant(:,ciuu);
        insertSql_1 = sqlGenerate(robotVelOmega);
        curs1 = exec(connA, insertSql_1);
        % 同时观测记录位置
        dataCamera = sqlread(connA,"robot_positions.robot_pos_cam_all",'MaxRows',100);
        dataCameraProcessed = sortrows(dataCamera, 1, 'descend');
        dataReal = table2array(dataCameraProcessed(1,2:end));
        pause(0.02);
    end
end

%% Close connection to database
close(connA);