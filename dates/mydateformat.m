function Fmt = mydateformat(Fmt,Freq,K)
% mydateformat  [Not a public function] Choose appropriate date format.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

if ischar(Fmt)
    return
end

if iscell(Fmt)
    Fmt = Fmt{K};
    return
end

if ~isstruct(Fmt)
    utils.error('dates:mydateformat', ...
        'Invalid date format.');
end

switch Freq
    case 0
        Fmt = Fmt.unspecified;
    case 1
        Fmt = Fmt.yy;
    case 2
        Fmt = Fmt.hh;
    case 4
        Fmt = Fmt.qq;
    case 6
        Fmt = Fmt.bb;
    case 12
        Fmt = Fmt.mm;
    case 52
        Fmt = Fmt.ww;
    case 365
        Fmt = Fmt.dd;
    otherwise
        Fmt = '';
end

end
