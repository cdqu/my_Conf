function vel = constrain_vel_2(velx,vely,robotVel_min,robotVel_max)
% @zxc 2021.11.12
% 控制速度
% 速度绝对值小于50的时候输出成0
% 绝对值大于有效值的时候限制上下限
% robotVel_max=500;
% robotVel_min=120;
vel = [velx,vely];
if norm(vel) < robotVel_min        %50
    vel = [0,0];
elseif norm(vel) > robotVel_max
    vel = (robotVel_max/norm(vel))*vel;
end
end

