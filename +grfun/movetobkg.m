function movetobkg(Par,Bkg)
% movetobkg  Move graphics objects to the background.
%
% Syntax
% =======
%
%     grfun.movetobkg(Parent,ToBkg)
%
% Input arguments
% ================
%
% * `Parent` [ numeric ] - Graphics handle to a parent object.
%
% * `ToBkg` [ numeric ] - Graphics handle to children that will be moved
% to the background.
%
% Description
% ============
%
% Example
% ========
%

%--------------------------------------------------------------------------

ch = get(Par,'children');
for b = Bkg(:).'
    inx = ch == b;
    if any(inx)
        ch(inx) = [ ];
        ch = [ch;b]; %#ok<AGROW>
    end
end
set(Par,'children',ch);

end