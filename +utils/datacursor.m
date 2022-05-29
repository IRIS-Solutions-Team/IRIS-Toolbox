% datacursor  Display data tips in graphs involving Serier objects
%
% Backend [IrisToolbox] function
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

function tt = datacursor(~, obj)

tt = { };
h = obj.Target;

% Try to retrieve date line from the underlying plot.
dates = getappdata(h, 'IRIS_DATELINE');
if ~isempty(dates)
    xdata = get(h, 'XData');
    index = xdata==obj.Position(1);
    if any(index)
        tt = [tt, { ...
            sprintf('Date: %s', dat2char(dates(index))), ...
        }];
    end
end

% This more or less reproduces standard behaviour.
tt = [tt, { ...
    sprintf('X: %g', obj.Position(1)), ...
    sprintf('Y: %g', obj.Position(2)), ...
}];

if numel(obj.Position)>2
    tt = [tt, { ...
        sprintf('Z: %g', obj.Position(3)), ...
    }];
end

end%

