% 把控制数组转化成sql语句
% Input: vwr - 1 * 45维的控制数组（Vel_x, Vel_y, Omega）*15
% Output: insertsql - 准备写入的sql语句
function [insertsql1,insertsql2] = sqlGenerate(vwr)    
strvwr = num2str(vwr);
strvwrcomma = regexprep(strvwr,{'\s+'},',');  % '\s+'处理一个或多个空格分隔
insertsql1 = ['insert into robot_commands.commands_all value("',datestr(now,'yyyy-mm-dd HH:MM:SS.FFF'),'000",',strvwrcomma,')'];
insertsql2 = ['insert into robot_commands.commands_all_long value("',datestr(now,'yyyy-mm-dd HH:MM:SS.FFF'),'000",',strvwrcomma,')'];
end
