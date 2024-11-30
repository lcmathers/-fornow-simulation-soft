function [delay_estimate2,hinterp] = delay_match(delay_actual,mu_k,Ts1)
%% 使用插值的方法 用两个相邻的信号采样时刻表示信道的时延

% mu_k 生成信道响应
% delay_actual 实际时延
% Ts1 实际信号抽样率


delay_estimate=floor(delay_actual./Ts1);
delay_estimate1=[delay_estimate delay_estimate+1];
delay_estimate2=unique(delay_estimate1);  % 实际的所有抽头


delay_real=delay_actual./Ts1;
tr=delay_real-delay_estimate;  % 相对距离

hinterp=zeros(length(delay_estimate2),length(mu_k));

for i=1:length(delay_actual)

hinterp(i,:)=hinterp(i,:)+sqrt(1-tr(i))*mu_k(i,:);
hinterp(i+1,:)=hinterp(i+1,:)+sqrt(tr(i))*mu_k(i,:);

end

end