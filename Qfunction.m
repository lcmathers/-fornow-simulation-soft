function y=Qfunction(x)
%% Q function
% co-error function: 1/sqrt(2*pi) * int_x^inf exp(-t^2/2) dt. 
y=erfc(x/sqrt(2))/2;
end