function [delay_actual,delay_actual_dB] = delay_pdp1(N,Ts,max_delay,edge_time)
%UNTITLED 此处提供此函数的摘要
%   此处提供详细说明


S = @(tau, tau_edge,tau_max) (1/(tau_edge*(1-exp(-tau_max/tau_edge))).*exp(-tau/tau_edge));
f_integral = @(tau, tau_edge,tau_max, C) integral(@(tau_prime) S(tau_prime, tau_edge,tau_max), 0, tau) - C;

tau_max=max_delay;
tau_edge=edge_time;

result=zeros(1,N-1);

for n=1:N-1
% C=(n-1/2)/(N-1);
C=n/(N-1);
root_func = @(tau) f_integral(tau,tau_edge,tau_max, C);
tau_initial=[0,tau_max];
root = fzero(root_func, tau_initial);
result(1,n)=root;
end



%result1=round(result./Ts);


% 实际抽头和衰减系数

delay_actual=[0,result];

delay_curve1=S(delay_actual,tau_edge,tau_max);
delay_actual_dB= 10*log10(delay_curve1./max(delay_curve1));



end