function [H_LS] = channel_interp(LS_est,pilot_loc,Nfft)
% 线性插值

% 保证导频位置从1开始，到Nfft结束 

if pilot_loc(1)>1
    slope=(LS_est(2)-LS_est(1))/(pilot_loc(2)-pilot_loc(1));
    LS_est=[LS_est(1)-slope*(pilot_loc(1)-1) LS_est];
    pilot_loc=[1 pilot_loc];
end

if pilot_loc(end)<Nfft
    slope=(LS_est(end)-LS_est(end-1))/(pilot_loc(end)-pilot_loc(end-1));
    LS_est=[LS_est LS_est(end)+slope*(Nfft-pilot_loc(end))];
    pilot_loc=[pilot_loc Nfft];
end

H_LS=interp1(pilot_loc,LS_est,[1:Nfft],"spline");

end