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

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

classdef Except
    properties
        List (1, :) string = string.empty(1, 0)
        CaseSensitive = true
    end


    methods
        function this = Except(varargin)
            if isempty(varargin)
                return
            end
            if nargin==1
                this.List = string(varargin{1});
            else
                this.List = string(varargin);
            end
        end%


        function resolvedNames = resolve(this, allNames)
            convertToCell = ~isa(allNames, 'string');
            allNames = string(allNames);
            if isempty(this.List)
                resolvedNames = allNames;
            else
                if isequal(this.CaseSensitive, true)
                    resolvedNames = setdiff(allNames, this.List, 'stable');
                else
                    resolvedNames = setdiff(lower(allNames), lower(this.List), 'stable');
                end
            end
            if convertToCell
                resolvedNames = cellstr(resolvedNames);
            end
        end%


        function this = setdiff(this, listRemove)
            this.List = setdiff(this.List, listRemove);
        end%


        function this = set.List(this, value)
            try
                this.List = reshape(string(value), 1, [ ]);
            catch
                thisError = [
                    "Except:InvalidInput"
                    "Input into Except constructor must be a char, string, or cellstr."
                ];
                throw(exception.Base(thisError, 'error'));
            end
        end%
    end
end

