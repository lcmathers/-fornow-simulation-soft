%% 交织解码的过程使得fd增加性能反而变好
%% 交织的两步使得fd增加性能反而变好
%% 在另一个场景的信道下，fd的增加会导致性能变差 ()
%% 多普勒设置的问题，设置为半边Jakes谱，会有上述问题
%% 而且这个问题是发生在 （QPSK，BPSk）并且交织比较分散的情况下（交织列数比较多）

%% 可能是有信道估计的插值问题 （有虚拟子载波的情况下）
%% 在vc置0的情况下，也会出现这个问题
%% 交织的深度（列数）不够时，性能也是变差的



clc;clear all; close all;

BER_idk=zeros(5,7);
totalerrors_idk=zeros(5,7);
total_undecode=zeros(5,7);
total_decode=zeros(5,7);
total_decode_soft=zeros(5,7);

for fd=0:1000:4000
%% Parameters setting

Nfft=2048;
%Ng=Nfft/4;
Ng=201;    % CP length
% Nvc=400;
Nvc=0;        % Vitural carrier
Nframe=5;
sub_deltaf=10*1e3; %子载波间隔

M_mod=2;  % Modulation order

channeltype=3; % 1 滑行 2 停泊 3 起飞/降落 4 巡航
% fd=1000; % Doppler shift
fmin=100;  % enroute min Doppler
fmax=500; % enroute max Doppler

R_code=1/2; % channel code rate

EbN0=[0:5:30];

% SNR_dB=[0:5:30]
ExtraNoise=0; % Extra noise sample
EndNoise=0;  % End noise sample
CFO=2.5;

max_iter=1e4; % number of iter

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

%% Main Loop


for i=1:length(SNR_dB)
    for iter=1:max_iter

        %% Tx

        raw_data=randi([0,1],rawbit_perframe,1);

        trellis = poly2trellis(7,[171 133]);

        code_data=convenc(raw_data,trellis);

        % inter_data=matintrlv(code_data,length(code_data)/20,20);
        inter_data=tx_interleaver(code_data,256);

        X_data_1=qammod(inter_data,M_mod,'InputType','bit','UnitAveragePower',true);

        X_data=X_data_1.';
           
        x_tr=frame_generate(X_data,Nfft,Nsym,Ndata,Nvc,Nframe,X_pilot,Nps);



        %% Channel

        [y,h]=channel_project(x_tr,channeltype,fd,fmin,fmax);

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
        % y_re=y;
        % noise_var=0;
        

        %y_re=y;


        %% Rx
       
        delay_result(i,iter)=ExtraNoise;
        % delay_result=ExtraNoise;
        y_data=y_re(delay_result(i,iter)+1:end);

        
        % decompose the frame

        % h=1;
        [Y_est_data,H_DFT,H_frame]=frame_decompose(y_data,Nfft,Nsym,Ndata,Nvc,Nframe,channeltype,X_pilot,Nps,pilot_loc,noise_var);

        % noise_var_eq=mean(noise_mean);

        H_frame = reshape(H_frame.',1,[]);

        H_frame_signal = H_frame(2:2:end);

        noise_var_eq = noise_var./abs(H_frame_signal).^2;  % 计算每一个符号的噪声功率

        H_DFT_dB=10*log10(abs(H_DFT.*conj(H_DFT)));

        Y_data_1=qamdemod(Y_est_data.',M_mod,'OutputType','bit','UnitAveragePower',true);

        total_undecode(fd/1000+1,i)=total_undecode(fd/1000+1,i)+sum(Y_data_1~=inter_data);

        Y_data_llr=qamdemod(Y_est_data,M_mod,'OutputType','approxllr','NoiseVariance',noise_var_eq,'UnitAveragePower',true);  % 每一个符号的噪声功率是不一样的！！！

        Y_data_llr_1=reshape(Y_data_llr,[],1);

        Y_llr_deinter= rx_deinterleave(Y_data_llr_1,256);
        y_data_deinter=rx_deinterleave(Y_data_1,256);

        % Y_llr_deinter= matdeintrlv(Y_data_llr,length(Y_data_llr)/40,40);

        % Y_llr_deinter=double(Y_llr_deinter);

        tblen=32;
        % decode_data = vitdec(y_data_deinter,trellis,tblen,'trunc','hard');

        decode_data_soft = vitdec(Y_llr_deinter,poly2trellis(7,[171 133]),tblen,'trunc','unquant');

        % total_biterrors(i)=total_biterrors(i)+sum(decode_data~=raw_data);

        total_decode(fd/1000+1,i)=total_biterrors(i);

       % total_biterrors_soft(i)=total_biterrors_soft(i)+sum(decode_data_soft(tblen+1:end)~=raw_data(1:end-tblen));

        total_biterrors_soft(i)=total_biterrors_soft(i)+sum(decode_data_soft~=raw_data);

        total_decode_soft(fd/1000+1,i)=total_biterrors_soft(i);
        
        BER_ofdm(i)=total_biterrors(i)/(iter*(length(raw_data)-tblen));

        BER_ofdm_soft(i)=total_biterrors_soft(i)/(iter*(length(raw_data)));



    end
end

%totalerrors_idk(fd/1000+1,:)=total_biterrors;
%BER_idk(fd/1000+1,:)=BER_ofdm;

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
legend('hard','soft');

save('/home/lichenghao/code_ofdm/OFDM-simulation/test_result/bpsk_10kHz_softdecode.mat',"total_decode_soft");

