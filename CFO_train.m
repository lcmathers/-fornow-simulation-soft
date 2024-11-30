function [CFO_est] = CFO_train(yt,STS,Nfft)

% 用重复的短训练序列来估计CFO
% yt 分组检测后的信号
% STS 短训练符号
% 


D=10;
lSTS=length(STS)/D;

Est_CFO=zeros(1,D-1);

 for l=1:D-1

     nn=1:lSTS;
     y_tmp1=yt(nn+(l-1)*lSTS);
     y_tmp2=yt(nn+l*lSTS);
     Est_CFO(l)=D*angle(y_tmp2*y_tmp1')/(2*pi);
     
 end

 CFO_est=mean(Est_CFO);

end