function [answ, flag, retQuery] = implementGet(p, quantity, query, varargin)

answ = [ ];
retQuery = query;

flag = true;
switch query
    case {'autoexog'}
        answ = struct( 'Dynamic', [ ], 'Steady', [ ]);
        [~, ~, answ.Dynamic] = model.Pairing.getAutoexog(p.Autoexog.Dynamic, quantity);
        [~, ~, answ.Steady] = model.Pairing.getAutoexog(p.Autoexog.Steady, quantity);

    case {'autoexog:dynamic'}
        [~, ~, answ] = model.Pairing.getAutoexog(p.Autoexog.Dynamic, quantity);

    case {'autoexog:steady'}
        [~, ~, answ] = model.Pairing.getAutoexog(p.Autoexog.Steady, quantity);

    otherwise
        flag = false;
end

end
