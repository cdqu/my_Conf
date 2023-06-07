% 判断机器人是否快到了目标点
% 
function res = ifClose(dataWant, dataCameraProcessed, robot_ID) 
want = dataWant(1, 3*robot_ID + 1 : 3*robot_ID + 2);
real = dataCameraProcessed(1, 3*robot_ID + 1 : 3*robot_ID + 2);
difference = abs(want(1) - real(1)) + abs(want(2) - real(2));   % 实际位置和目标位置的差值（x,y 方向差值绝对值之和）
str = ['机器人',num2str(robot_ID),'到目标点的距离',num2str(difference)];
disp(str);
if difference > 150      %50%120     % 这个参数可以调哦
    res = 0;            % 位置有点远，relocate
else
    res = 1;            % 很近了，当作已经到了目标位置
end