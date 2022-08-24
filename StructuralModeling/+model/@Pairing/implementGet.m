function [answ, flag, retQuery] = implementGet(p, quantity, query, varargin)

answ = [ ];
retQuery = query;

flag = true;
if any(strcmpi(query, {'Autoswap', 'Autoswap'}))
    answ = struct( 'Simulate', [ ], 'Steady', [ ]);
    [~, ~, answ.Simulate] = model.Pairing.getAutoswaps(p.Autoswaps.Simulate, quantity);
    [~, ~, answ.Steady] = model.Pairing.getAutoswaps(p.Autoswaps.Steady, quantity);

elseif any(strcmpi(query, {'Simulate-Autoswap', 'Simulate-Autoswaps', 'Autoexog:Simulate'}))
    [~, ~, answ] = model.Pairing.getAutoswaps(p.Autoswaps.Simulate, quantity);

elseif any(strcmpi(query, {'Steady-Autoswap', 'Steady-Autoswaps', 'Autoexog:Steady'}))
    [~, ~, answ] = model.Pairing.getAutoswaps(p.Autoswaps.Steady, quantity);

else
    flag = false;

end

end%

