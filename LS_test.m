function [H_LS]=LS_test(Y,pilot_loc,pilot,Nfft,Nvc)

Ndata=Nfft-Nvc;

k=1:length(pilot_loc);

Ls_est(k)=Y(pilot_loc(k))./pilot(k);


H_LS=channel_interp(Ls_est,pilot_loc,Ndata); % spline interpert

end