function vel = constrain_vel(vel,robotVel_min,robotVel_max)
% @zxc 2021.11.12
% 控制速度
% 速度绝对值小于50的时候输出成0
% 绝对值大于有效值的时候限制上下限
% robotVel_max=500;
% robotVel_min=120;

if abs(vel) < 0        %50
    vel = 0;
elseif vel > 0
    vel = min(robotVel_max, vel);
    vel = max(robotVel_min, vel);
else
    vel = max(-robotVel_max, vel);
    vel = min(-robotVel_min, vel);
end
vel
end

