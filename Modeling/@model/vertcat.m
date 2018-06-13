function varargout = vertcat(varargin) %#ok<STOUT>
throw( exception.Base('Model:CANNOT_CAT_IN_OTHER_DIM', 'error') );
end