% Except 
%
% This section describes the `Except` wrapper class of objects.
%
%
% Description
% ------------
%
% `Except` objects are used to create lists of names (typically model
% variables) inversely in some specific contexts. This means that we resolvedNames
% the names that are be excluded specifying thus that the function or
% option will be applied to all the other names, except those entered
% through an `Except`.
%
% The contexts in which `Except` is currently supported are
%
% * `Fix=`, `FixLevel=`, and `FixChange=` in the `model/sstate(~)`
% function.
%
%

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2020 IRIS Solutions Team

classdef Except
    properties
        List = cell.empty(1, 0)
        CaseSensitive = true
    end


    properties (Constant, Hidden)
        ERROR_INVALID_LIST = { 'Except:InvalidInputList'
                               'Input list into an Except object must be char, cellstr or string' }
    end


    methods
        function this = Except(varargin)
            if isempty(varargin)
                return
            end
            this.List = varargin;
        end%


        function resolvedNames = resolve(this, allNames)
            convertToString = isa(this.List, 'string') || isa(allNames, 'string');
            if ~iscellstr(allNames)
                allNames = cellstr(allNames);
            end
            if isempty(this.List)
                resolvedNames = allNames;
            else
                if isequal(this.CaseSensitive, true)
                    resolvedNames = setdiff(allNames, this.List, 'stable');
                else
                    resolvedNames = setdiff(lower(allNames), lower(this.List), 'stable');
                end
            end
            if convertToString && ~isa(resolvedNames, 'string')
                resolvedNames = string(resolvedNames);
            end
        end%


        function this = set.List(this, value)
            if iscell(value) && numel(value)==1
                value = value{1};
            end
            try
                value = cellstr(value); 
                if iscellstr(value)
                    this.List = value;
                    return
                end
            catch
                throw( exception.Base(this.ERROR_INVALID_LIST, 'error') );
            end
        end%
    end
end

