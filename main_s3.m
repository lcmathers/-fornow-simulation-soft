clc;clear all; close all;

%% Parameters setting

Nfft=2048;
Ng=Nfft/4;
% Ng=201;    % CP length
Nvc=400;
% Nvc=0;        % Vitural carrier
Nframe=5;

M_mod=4;  % Modulation order

channeltype=3; % 1 滑行 2 停泊 3 起飞/降落 4 巡航
fd=4000; % Doppler shift
fmin=100;  % enroute min Doppler
fmax=500; % enroute max Doppler

R_code=1/2; % channel code rate

EbN0=[0:5:30];

% SNR_dB=[0:5:30];
ExtraNoise=0; % Extra noise sample
EndNoise=0;  % End noise sample
CFO=2.5;

max_iter=10; % number of iter

Nps=2; % the space of pilot symbol


[STS,LTS]=generate_train(Nfft,Ng);
Train_sym=[STS LTS];
% Train_sym=[STS];
%Train_sym=[];

total_biterrors=zeros(1,length(EbN0));
BER_ofdm=zeros(1,length(EbN0));

total_biterrors_soft=zeros(1,length(EbN0));
BER_ofdm_soft=zeros(1,length(EbN0));



%% Parameters CalCulation

Nsym=Nfft+Ng;
Ndata=Nfft-Nvc;

[X_pilot,pilot_loc]=generate_pilot(Nfft,Nps,Nvc,Ndata);


%%
M_bit=log2(M_mod);
R1=(Nfft/Nps)/(Nfft); % the ratio of pilot symbol and Nfft

sym_perframe=Ndata*Nframe*R1;
bits_perframe=M_bit*Ndata*Nframe*R1;
rawbit_perframe=bits_perframe*R_code;

SNR_dB=EbN0+10*log10(R_code*M_bit*(Ndata/Nfft));

eng_sqrt = (M_mod==2)+(M_mod~=2)*sqrt((M_mod-1)/6*(2^2)); % 调制信号平均功率
A=1/eng_sqrt;   % QAM归一化因子

delay_result=zeros(length(SNR_dB),max_iter);
CFO_est=zeros(length(SNR_dB),max_iter);
FFO_est=zeros(length(SNR_dB),max_iter);
STO=zeros(length(SNR_dB),max_iter);


%% channel paremeters setting

fs=20e6; % 采样频率
Ts=1/fs;

max_delay=10e-6; % 最大时延
edge_time=1e-6;  % 边沿时间
N_delay=20;  % 时延抽头数目 

[delay_actual,delay_actual_dB]=delay_pdp1(N_delay,Ts,max_delay,edge_time);

K=length(delay_actual);

N=55; % num of sin

[F,C,th]= function_MMEA_SP_takeoff(N,K,fd,delay_actual_dB);


%% Main Loop

for i=1:length(SNR_dB)

    t_initial=0;

    for iter=1:max_iter

        %% Tx

        raw_data=randi([0,1],rawbit_perframe,1);

        trellis = poly2trellis(7,[171 133]);

        code_data=convenc(raw_data,trellis);

        inter_data=matintrlv(code_data,length(code_data)/40,40);

        X_data_1=qammod(inter_data,M_mod,'InputType','bit','UnitAveragePower',true);

        X_data=X_data_1';
           
        x_tr=frame_generate(X_data,Nfft,Nsym,Ndata,Nvc,Nframe,Train_sym,X_pilot,Nps);



        %% Channel

        % [y,h]=channel_project(x_tr,channeltype,fd,fmin,fmax);

        [y,h,t_final,mu_limited]=channel_SOS(x_tr,channeltype,t_initial,fd,delay_actual,delay_actual_dB,F,C);

        t_initial=t_final;

%         PowerdB=[0 -8 -17 ];
%         Delay=[0 3 5];
% 
%         Power=10.^(PowerdB/10);
%         Ntap=length(Delay);
% 
%         channel=sqrt(Power/2).*(randn(1,Ntap)+1j*randn(1,Ntap));
%         h=zeros(1,Ntap+1);
%         h(Delay+1)=channel;
% 
%         H=fft(h,2048);
%         H_power_dB=10*log10(abs(H.*conj(H)));
% 
%         y=conv(x_tr,h);


        channel_length=201;

        [y_re,noise_var]=add_noise(y,SNR_dB(i),ExtraNoise,EndNoise);


        %% Rx
       
        delay_result(i,iter)=ExtraNoise;
        % delay_result=ExtraNoise;
        y_data=y_re(delay_result(i,iter)+1:end);

        
        % decompose the frame

        % h=1;
        [Y_est_data,H_DFT,noise_mean]=frame_decompose(y_data,Nfft,Nsym,Ndata,Nvc,Nframe,channeltype,X_pilot,Nps,pilot_loc,noise_var);

        noise_var_eq=mean(noise_mean);

        H_DFT_dB=10*log10(abs(H_DFT.*conj(H_DFT)));

        Y_data_1=qamdemod(Y_est_data',M_mod,'OutputType','bit','UnitAveragePower',true);

        Y_data_llr=qamdemod(Y_est_data',M_mod,'OutputType','approxllr','NoiseVariance',noise_var_eq,'UnitAveragePower',true);

        Y_data_deinter=matdeintrlv(Y_data_1,length(Y_data_1)/40,40);

       % Y_llr_deinter= matdeintrlv(Y_data_llr,length(Y_data_llr)/40,40);

        tblen=32;
        decode_data = vitdec(Y_data_deinter,trellis,tblen,'cont','hard');
        % decode_data_soft = vitdec(Y_llr_deinter,trellis,tblen,'cont','unquant')

        total_biterrors(i)=total_biterrors(i)+sum(decode_data(tblen+1:end)~=raw_data(1:end-tblen));

       %  total_biterrors_soft(i)=total_biterrors_soft(i)+sum(decode_data_soft(tblen+1:end)~=raw_data(1:end-tblen));
        
        BER_ofdm(i)=total_biterrors(i)/(iter*(length(raw_data)-tblen));

        BER_ofdm_soft(i)=total_biterrors_soft(i)/(iter*(length(raw_data)-tblen));



    end
end

figure;

plot(H_DFT_dB);
hold on;
%plot(H_power_dB);
legend('Est','Real')


figure;
semilogy(EbN0,BER_ofdm);
hold on;
semilogy(EbN0,BER_ofdm_soft);
legend('Hard','Soft');