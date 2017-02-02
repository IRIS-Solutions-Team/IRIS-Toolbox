function opt = prepareSolve(this, mode, opt)
% prepareSolve  Prepare model solution.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

if isequal(opt, false)
    return
end

if isequal(opt, true)
    opt = struct( );
end

opt = passvalopt('model.solve', opt);

if ~isempty( strfind(mode, 'silent') )
    opt.progress = false;
    opt.warning = false;
end

if ~isempty( strfind(mode, 'fast') )
    opt.fast = true;
end

if isequal(opt.linear, @auto)
    opt.linear = this.IsLinear;
elseif opt.linear~=this.IsLinear
    opt.select = false;
end

end
