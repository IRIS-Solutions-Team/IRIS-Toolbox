function [phase,lag] = xs2phase(xs)

warning('off','MATLAB:divideByZero');
  phase = atan2(-imag(xs{1}),real(xs{1}));
warning('on','MATLAB:divideByZero');

for i = 1 : size(xs{1},1)
  phase(i,i,:) = 0;
end

if nargout > 1
  realsmall = getrealsmall( );
  lag = phase;
  for i = 1 : length(xs{2})
    if abs(xs{2}(i)) < realsmall
      lag(:,:,i) = NaN;
    else
      lag(:,:,i) = lag(:,:,i) / xs{2}(i);
    end
  end
end

end