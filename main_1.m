% ------------------------------------------------------------------
% Projet      :                                
% Filename    : main.m                     
% Description : This communication system consists of transmitter                                
%               and receiver.                              
% Author      :                                     
% Data        : 
% ------------------------------------------------------------------

%% 导频加入
%% 理想同步

%% 信道编码
%% 交织
%% 星座映射
%% 插入导频
%% IFFT变换，插入CP，成帧

%% 过信道 （AWGN or fading channel）
%% 加噪声

%% 同步（分组检测，CFO估计）
%% 提取数据，去CP，FFT变换
%% 信道估计，均衡
%% 星座映射
%% 解交织
%% 解码
%% 计算BER


clc;clear all; close all;

%% Parameters setting

Nfft=2048;      
Ng=Nfft/4;    % CP length
% Ng=8;
Nvc=0;        % Vitural carrier
Nframe=5;

M_mod=16;  % Modulation order

channeltype=1; % 0 AWGN 1 Fading


EbN0=[30];
% SNR_dB=[0:5:30];
ExtraNoise=1000; % Extra noise sample
EndNoise=170;  % End noise sample

max_iter=1e3; % number of iter

Nps=2; % the space of pilot symbol
[X_pilot,pilot_loc]=generate_pilot(Nfft,Nps);


[STS,LTS]=generate_train(Nfft,Ng);
Train_sym=[STS LTS];
%Train_sym=[];

total_biterrors=zeros(1,length(EbN0));
BER_ofdm=zeros(1,length(EbN0));



%% Parameters CalCulation

Nsym=Nfft+Ng;
Ndata=Nfft-Nvc;


M_bit=log2(M_mod);
R1=(Nfft/Nps)/(Nfft); % the ratio of pilot symbol and Nfft

SNR_dB=EbN0+10*log10(M_bit*(Ndata/Nfft));

sym_perframe=Ndata*Nframe*R1;
bits_perframe=M_bit*Ndata*Nframe*R1;

eng_sqrt = (M_mod==2)+(M_mod~=2)*sqrt((M_mod-1)/6*(2^2)); % 调制信号平均功率
A=1/eng_sqrt;   % QAM归一化因子


%% Main Loop

for i=1:length(SNR_dB)
    for iter=1:max_iter

        %% Tx

        raw_data=randi([0,1],1,bits_perframe);

        raw_reshape=reshape(raw_data,M_bit,sym_perframe);

        X_data=A*qammod(raw_reshape,M_mod,'gray','InputType','bit');  

        x_tr=frame_generate(X_data,Nfft,Nsym,Ndata,Nvc,Nframe,Train_sym,X_pilot,Nps);  % generate a frame

        %% Channel

        [y,h]=channel(x_tr,channeltype);
        y_re=add_noise(y,SNR_dB(i),ExtraNoise,EndNoise);

        %% Rx

        % packet detection
        detect_result=ExtraNoise;
        y_data=y_re(ExtraNoise+1:end);

        % 
        % y_data=y_data(length(Train_sym)+1:end);


        % 
        Y_est_data=frame_decompose(y_data,Nfft,Nsym,Ndata,Nvc,Nframe,channeltype,h,X_pilot,Nps,pilot_loc);

        X_est_data=qamdemod(Y_est_data/A,M_mod,'gray','OutputType','bit');

        % BER calculation
        total_biterrors(i)=total_biterrors(i)+sum(sum(X_est_data~=raw_reshape));

    end

end

%% plot the SNR-BER curve

BER_ofdm=total_biterrors./(max_iter*bits_perframe);

% EbN0=SNR_dB-10*log10(M_bit);

figure(2);
semilogy(EbN0,BER_ofdm,'LineWidth',1.5,'Marker','o');
hold on;

if channeltype==0
    Ber_theory=awgn_theory(EbN0,M_mod);
else 
    Ber_theory=rayleigh_theory(EbN0,M_mod);
end

% semilogy(EbN0,Ber_theory,'LineWidth',1.5,'Marker','+',LineStyle='--');
xlabel('EbN0'),ylabel('BER')
legend('Uncode OFDM');