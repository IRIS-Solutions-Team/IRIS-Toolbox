% !substitutions  Define text substitutions.
%
% Syntax
% =======
%
%     !substitutions
%         SubsName := TextString;
%         SubsName := TextString;
%         ...
%
% Description
% ============
% 
% The `!substitutions` starts a block with substitution definitions. The
% definition of each substitution must begin with the name of the
% substitution, followed by a colon-equal sign, `:=`, and a text
% string ended with a semi-colon. The semi-colon is not part of the
% substitution.
% 
% The substitutions can be used in any of the model equations, i.e. in
% [transition equations](irislang/transitionequations),
% [measurement equations](irislang/measurementequations),
% [deterministic trend equations](irislang/dtrends), and
% [dynamic links](irislang/links). Each occurence of the name of a
% substitution enclosed in dollar signs, i.e. `$substitution_name$`, in
% model equations will be replaced with the text string from the
% substitution's definition.
%
% Substitutions can also refer to other substitutions; make sure, though,
% that they are not recursive. Also, remember to parenthesise the
% definitions of the substitutions (or the references to them) in the
% equations properly so that the resulting mathematical expressions are
% evaluated properly.
% 
% Example
% ========
% 
%     !substitution
%         a := ((omega1+omega2)/(omega1+omega2+omega3));
%    
%     !transition_equations
%         X = $a$^2*Y + (1-$a$^2)*Z;
% 
% In this example, we assume that `omega1`, `omega2`, and `omega3` are
% declared as parameters. The equation will expand to
%
%         X = ((omega1+omega2)/(omega1+omega2+omega3))^2*Y + ...
%           (1-((omega1+omega2)/(omega1+omega2+omega3))^2)*Z;
%
% Note that if had not used the outermost parentheses in the definition of
% the substitution, the resulting expression would not have given us what
% we meant: The square operator would have only applied to the
% denominator.
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2020 IRIS Solutions Team.
