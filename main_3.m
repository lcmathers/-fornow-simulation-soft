% ------------------------------------------------------------------
% Projet      :                                
% Filename    : main.m                     
% Description : This communication system consists of transmitter                                
%               and receiver.                              
% Author      :                                     
% Data        : 
% ------------------------------------------------------------------


%% 导频加入
%% 同步加入 （理想同步）
%% 信道编码加入

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
% Ng=3;
Nvc=0;        % Vitural carrier
Nframe=5;

M_mod=16;  % Modulation order

channeltype=0; % 0 AWGN 1 Fading

R_code=1/2; % channel code rate

EbN0=[0:2:14];

% SNR_dB=[0:5:30];
ExtraNoise=500; % Extra noise sample
EndNoise=170;  % End noise sample
CFO=2.5;

max_iter=1e3; % number of iter

Nps=2; % the space of pilot symbol
[X_pilot,pilot_loc]=generate_pilot(Nfft,Nps);


[STS,LTS]=generate_train(Nfft,Ng);
Train_sym=[STS LTS];
% Train_sym=[STS];
%Train_sym=[];

total_biterrors=zeros(1,length(EbN0));
BER_ofdm=zeros(1,length(EbN0));



%% Parameters CalCulation

Nsym=Nfft+Ng;
Ndata=Nfft-Nvc;

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


%% Main Loop

for i=1:length(SNR_dB)
    for iter=1:max_iter

        %% Tx

        raw_data=randi([0,1],1,rawbit_perframe);

        code_data=channel_code(raw_data); % channel code (2,1,7)

        inter_data=tx_interleaver(code_data,Ndata/2,M_bit,Nframe); % interleaver
        % inter_data=code_data;

        data_reshape=reshape(inter_data,M_bit,sym_perframe);

        X_data=A*qammod(data_reshape,M_mod,'gray','InputType','bit');  

        x_tr=frame_generate(X_data,Nfft,Nsym,Ndata,Nvc,Nframe,Train_sym,X_pilot,Nps);  % generate a frame

        x_tr= [Train_sym x_tr];

        %% Channel

        [y,h]=channel(x_tr,channeltype);

        y_CFO=add_CFO(y,CFO,Nfft);

        y_re=add_noise(y_CFO,SNR_dB(i),ExtraNoise,EndNoise);

        %% Rx

%         % packet detection
%         % delay_result(i,iter)=detect_packet(y_re,STS,SNR_dB(i));
%         delay_result(i,iter)=ExtraNoise;
%         y_data=y_re(delay_result(i,iter)+1+length(STS):end);
% 
%         % CFO 
%         
%         CFO_est(i,iter)=CFO;
%         y_data=CFO_re(y_data,CFO_est(i,iter),Nfft);
% 
%         % fine time symbol

        % packet detection
        delay_result(i,iter)=detect_packet(y_re,STS,SNR_dB(i),Nfft);

        delay_result(i,iter)=ExtraNoise;
        % delay_result=ExtraNoise;
        y_data=y_re(delay_result(i,iter)+1:end);

        % CFO 
        % 用短训练序列估计频偏

        CFO_est(i,iter)=CFO;
        y_data_1=CFO_re(y_data,CFO_est(i,iter),Nfft);
        y_data_2=y_data_1(length(STS)+1:end);

        % Fine time symbol
        
        % 用长训练序列估计time symboling
        STO(i,iter)=0;
        % STO(i,iter)=STO_train(y_data_2,LTS_onesym);
        y_data_3=y_data_2(STO+1:end);

        % FFO

        % 用长训练序列进行精频偏估计
        FFO(i,iter)=0;
        y_data_4=CFO_re(y_data_3,FFO_est(i,iter),Nfft);
        y_data_5=y_data_4(length(LTS)+1:end);


        % 
        % y_data=y_data(length(Train_sym)+1:end);


        % 
        Y_est_data=frame_decompose(y_data_5,Nfft,Nsym,Ndata,Nvc,Nframe,channeltype,h,X_pilot,Nps,pilot_loc);

        X_est_data=qamdemod(Y_est_data/A,M_mod,'gray','OutputType','bit');

        X_est_reshape=reshape(X_est_data,1,bits_perframe);

        X_est_deinter=rx_deinterleave(X_est_reshape,Ndata/2,M_bit,Nframe); % deinterleaver
        % X_est_deinter=X_est_reshape;

        X_est_decode=channel_decode(X_est_deinter); % channel decode (2,1,7)

        % BER calculation
        total_biterrors(i)=total_biterrors(i)+sum(sum(X_est_decode~=raw_data));

    end

end

%% plot the SNR-BER curve

BER_ofdm=total_biterrors./(max_iter*rawbit_perframe);
%BER_ofdm_undecode=total_biterrors_undecode./(max_iter*bits_perframe);

% EbN0=SNR_dB-10*log10(M_bit);

% BER_ofdm(5)=398/(1e4*rawbit_perframe);
% BER_ofdm(6)=98/(1e4*rawbit_perframe);
% BER_ofdm(7)=37/(1e4*rawbit_perframe);
% SNR_dB=[0:5:30];

figure(2);
semilogy(EbN0,BER_ofdm,'LineWidth',1.5,'Marker','+');
xlabel('EbN0'),ylabel('BER')
legend('Decode OFDM Rayleigh');


