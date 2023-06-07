function [robotVelX, robotVelY, robotOmega] = compute_vel_pid(dataCameraReal, datalast, robotID, dataWant)
% 比例系数
K = 0.7;
Kd = 0.1;
% 目标点在机器人坐标系上的 x,y 向量
thetaRobo = dataCameraReal(1, 3 * robotID + 3);
if dataCameraReal(1,3 * robotID + 2) == 0      % 没发现这个机器人，让它自转报警
    robotVelX = 0; robotVelY = 0; robotOmega = 500;
else
    vectorW = dataWant(1,3 * robotID + 1:3 * robotID + 2) - dataCameraReal(1,3 * robotID + 1:3 * robotID + 2);
    vectorWd = dataWant(1,3 * robotID + 1:3 * robotID + 2) - datalast(1,3 * robotID + 1:3 * robotID + 2);
    [robotX, robotY] = coordinateTrans(thetaRobo, vectorW);
    [robotXd, robotYd] = coordinateTrans(thetaRobo, vectorWd);
    robotOmega = 0;
    
%% 设置速度
    robotVelX = K * ((1-Kd)* robotX + Kd * robotXd);     % 距离远速度大，反之速度小
    robotVelY = K * ((1-Kd)* robotY + Kd * robotYd);
    robotVel = constrain_vel_2(robotVelX,robotVelY,80,300);
    robotVelX = robotVel(1);
    robotVelY = robotVel(2);
    %[robotVelX,robotVelY] = constrain_vel_2(robotVelX,robotVelY,0,400);
    %robotVelY = constrain_vel(robotVelY,0,300);
end
end