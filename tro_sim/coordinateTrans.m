% 平台坐标系目标向量转化为机器人坐标系上的位置向量
% Input: thetaRobo - 机器人朝向角度; vectorW - 平台坐标系目标向量; 
% Output: robotX, robotY - 机器人坐标系位置向量
function [robotX, robotY] = coordinateTrans(thetaRobo, vectorW)
thetaRoboX = thetaRobo;
thetaRoboY = thetaRoboX + 90;

% 机器人 x,y 轴的单位向量
vectorX = [cos(thetaRoboX / 180 * pi), sin(thetaRoboX / 180 * pi)];    
vectorY = [cos(thetaRoboY / 180 * pi), sin(thetaRoboY / 180 * pi)];

robotX = dot(vectorW, vectorX);	% dot(x,y)点乘
robotY = dot(vectorW, vectorY);

end