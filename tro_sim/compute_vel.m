% 计算机器人在 x,y 轴上的速度
% Input: dataCameraProcessed - 摄像头捕捉的机器人位置; robotID - 机器人编号; dataWant - 目标位置
% Output: [robotVelX, robotVelY] - 机器人在 x,y 轴上的速度
function [robotVelX, robotVelY, robotOmega] = compute_vel(dataCameraReal, robotID, dataWant)
% 比例系数
K = 0.9;

% 目标点在机器人坐标系上的 x,y 向量
thetaRobo = dataCameraReal(1, 3 * robotID + 3);
if dataCameraReal(1,3 * robotID + 2) == 0      % 没发现这个机器人，让它自转报警
    robotVelX = 0; robotVelY = 0; robotOmega = 0;
else
    vectorW = dataWant(1,3 * robotID + 1:3 * robotID + 2) - dataCameraReal(1,3 * robotID + 1:3 * robotID + 2);
    [robotX, robotY] = coordinateTrans(thetaRobo, vectorW);
    robotOmega = 0;
    
%% 设置速度
    robotVelX = K * robotX;     % 距离远速度大，反之速度小
    robotVelY = K * robotY;
    
    robotVelX = constrain_vel(robotVelX,150,400);
    robotVelY = constrain_vel(robotVelY,150,400);
end
end

