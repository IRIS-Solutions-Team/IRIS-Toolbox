function gradient = repmatGradient(gradient)

%
% In gradients of measurement or transition equations where there is no
% x(...) or L(...), repeat the vector of derivatives numel(t) times to make
% sure it has the right size in 2nd dimension
%

gradient = string(gradient);
if ismissing(regexp(gradient, "\<[xL]\(\d", "match", "once"))
    gradient = "repmat(" + gradient + ",1,numel(t))";
end
gradient = char(gradient);

end%

