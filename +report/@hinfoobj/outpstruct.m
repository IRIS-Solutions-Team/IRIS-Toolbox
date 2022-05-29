function S = outpstruct(This)
% outpstruct  [Not a public function] Copy output fields of hinfoobj to struct.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

%--------------------------------------------------------------------------

list = { ...
    'latexRun', ...
    'figureHandle', ...
    'tempDir', ...
    'tempFile', ...
    };

S = struct( );
for i = 1 : length(list)
    S.(list{i}) = This.(list{i});
end

end
