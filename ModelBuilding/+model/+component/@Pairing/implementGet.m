function [answ, flag, retQuery] = implementGet(p, quantity, query, varargin)

answ = [ ];
retQuery = query;

flag = true;
switch query
    case {'autoexog'}
        answ = struct( 'Dynamic', [ ], 'Steady', [ ]);
        [~, ~, answ.Dynamic] = model.component.Pairing.getAutoexog(p.Autoexog.Dynamic, quantity);
        [~, ~, answ.Steady] = model.component.Pairing.getAutoexog(p.Autoexog.Steady, quantity);

    case {'autoexog:dynamic'}
        [~, ~, answ] = model.component.Pairing.getAutoexog(p.Autoexog.Dynamic, quantity);

    case {'autoexog:steady'}
        [~, ~, answ] = model.component.Pairing.getAutoexog(p.Autoexog.Steady, quantity);

    otherwise
        flag = false;
end

end
