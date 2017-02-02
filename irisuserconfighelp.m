% irisuserconfig  User configuration file called at the IRIS start-up.
%
% Syntax
% =======
%
%     function c = irisuserconfig(c)
%         c.option = value;
%         c.option = value;
%         ...
%      end
%
% Description
% ============
%
% You can create your own configuration file to modify the general IRIS
% options of your choosing at each IRIS start-up. The file must be saved as
% `irisuserconfig.m` on the Matlab search path.
%
% The `irisuserconfig.m` file must be an m-file function taking one input
% argument (a struct with the factory settings), and returning one output
% argument (a struct with the user-modified settings); see
% [`irisset`](config/irisset) for the list of options you can change. In
% addition, you can also add your own new options, which will be then also
% accessible through [`irisset`](config/irisset) and
% [`irisget`](config/irisget).
%
% Example
% ========
%
% If you want the names of months to be displayed in Finnish, create the
% following m-file and save it in a folder which is on the Matlab search
% path:
%
%     function c = irisuserconfig(c)
%         c.months = { ...
%             'Tammikuu','Helmikuu','Maaliskuu', ...
%             'Huhtikuu','Toukokuu','Kesakuu', ...
%             'Heinakuu','Elokuu','Syyskuu', ...
%             'Lokakuu','Marraskuu','Joulukuu'};
%     end
%
% This modification will take effect after you next run
% [`irisstartup`](config/irisstartup). Your graphs will be then fluent in
% Finnish:
%
%     x = tseries(mm(2009,1):mm(2009,6),@rand);
%     plot(x,'dateformat','MmmmYY');
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.