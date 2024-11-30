function [Xmod_r,H_final,H_DFT,sigema] = LS_vc(Y,X_pilot,Nfft,Nvc,channel_length,noise_var)

Ndata=Nfft-Nvc;

pilot_loc=[1:2:2047];

pilot_loc_outvc=pilot_loc;
pilot_loc_outvc(pilot_loc_outvc==1)=[];
pilot_loc_outvc((pilot_loc_outvc>=(Ndata/2+2)) & (pilot_loc_outvc<=(Ndata/2+Nvc)))=[];
pilot_loc_vc=[1 pilot_loc(find(pilot_loc>=(Ndata/2+2) & (pilot_loc<=(Ndata/2+Nvc))))];

loc_Data=[2:2:2048];
loc_Data_outvc=loc_Data;
loc_Data_outvc(loc_Data_outvc==1)=[];
loc_Data_outvc(loc_Data_outvc>=(Ndata/2+2) & loc_Data_outvc<=(Ndata/2+Nvc))=[];

loc_vc=[1 Ndata/2+2:1:Ndata/2+Nvc];



%% Channel estimation

H_LS_est_outvc= Y(pilot_loc_outvc)./[X_pilot(Ndata/4+1:end) X_pilot(1:Ndata/4)];

%
H_LS_est=zeros(1,Nfft);
H_LS_est(pilot_loc_outvc)=H_LS_est_outvc;
H_LS_est(pilot_loc_vc)=1e3;
H_LS_est(H_LS_est==0)=[];

index_vc=find(H_LS_est==1e3);
H_LS_est(H_LS_est==1e3)=0;

H_initial=H_LS_est;

%% 时域处理
for idk=1:20

    h_time=ifft(H_initial);

    channel_length_1=20;

    h_delete=[h_time(1:channel_length_1) zeros(1,length(h_time)-channel_length_1)];

    H_LS_revice=fft(h_delete);

    %%

    H_LS_est_modifed=H_initial;

    H_LS_est_modifed(index_vc)=H_LS_revice(index_vc);

    H_initial=H_LS_est_modifed;

end

H_final=channel_interp(H_LS_est_modifed,pilot_loc,Nfft);

H_DFT=LS_DFT(H_final,channel_length);

% Xmod_r=Y(loc_Data_outvc)./H_DFT(loc_Data_outvc);

MMSE_equalizer= conj(H_DFT(loc_Data_outvc))./(H_DFT(loc_Data_outvc).*conj(H_DFT(loc_Data_outvc))+noise_var);
Xmod_r= Y(loc_Data_outvc).*MMSE_equalizer;

Xmod_r=fftshift(Xmod_r);

% sigema=mean(abs(Y(loc_vc)./H_DFT(loc_vc))); % Vc 位置算 equal 后的噪声功率

% H_noise=H_DFT(loc_Data_outvc).^2;
H_noise=MMSE_equalizer.^2;

sigema=mean(abs(noise_var.*H_noise).^2);


end