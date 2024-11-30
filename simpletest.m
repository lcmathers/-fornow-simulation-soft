clear all;

ber_ofdm=load('BER_ofdm_16qam.mat');
Ber_ofdm_16qam=ber_ofdm.Ber_ofdm_16qam;


%% simulation result

% 
% x1=[986783 470103 48364 2477 143 15 0]
% x2=[994021 511682 33326 631 0 0 0];
% x3=[2013904 1483340 165803 4379 170 69 13];
% x4=[1008628 881270 245552 25047 5134 2762 2440];
% 
% ber1=x1./(2028000);
% ber2=x2./(2028000);
% ber3=x3./(4056000);
% ber4=x4./(2028000)


x1=[1977886 905036 85229 4757 318 25 3]
x2=[1990909 986707 63561 1168 21 0 0];
x3=[2027942 1590523 361722 37183 7767 4634 3198];
x4=[2036162 1861018 1059668 425082 246412 195956 171507];

ber1=x1./(4088000);
ber2=x2./(4088000);
ber3=x3./(4088000);
ber4=x4./(4088000);

EbN01=[0:5:30];
% EbN02=[0:5:20];

figure;
semilogy(EbN01,Ber_ofdm_16qam(1,:),'LineWidth',1.5,'Marker','+');
hold on;
semilogy(EbN01,Ber_ofdm_16qam(2,:),'LineWidth',1.5,'Marker','o');
semilogy(EbN01,Ber_ofdm_16qam(3,:),'LineWidth',1.5,'Marker','*');
semilogy(EbN01,Ber_ofdm_16qam(4,:),'LineWidth',1.5,'Marker','x');
semilogy(EbN01,Ber_ofdm_16qam(5,:),'LineWidth',1.5,'Marker','^');

xlabel('EbN0'),ylabel('BER');
legend('16QAM 0Hz','16QAM 1000Hz','16QAM 2000Hz','16QAM 3000Hz','16QAM 4000Hz');
title('Take-off 16QAM OFDM')

%% Interleaver test   对于BPSK的交织有问题

% Ndata=1024;
% M_bit=2;
% % Ndata=1024;
% R_code=1/2;
% Nframe=5;
% inter_depth=M_bit*Ndata*Nframe;
% 
% x1=[1:1:inter_depth];
% 
% % x2=tx_interleaver(x1,Ndata,M_bit,Nframe);
% % y=rx_deinterleave(x2,Ndata,M_bit,Nframe)
% % 
% % 
% % idx1 = tx_gen_intlvr_patt(inter_depth, Ndata);
% % idx2=  rx_gen_deintlvr_patt(inter_depth, Ndata);
% 
% x2=matintrlv(x1,length(x1)/32,32); % matrix interleaver
% 
% y=matdeintrlv(x2,length(x1)/32,32);  % matrix deinterleaver


%% Test of delete pilot location when add VC
% pilot_loc=[1:2:2047];
% 
% pilot_loc(pilot_loc==1)=0;
% 
% pilot_loc(pilot_loc>=822 & pilot_loc<=1228)=0;
% 
% pilot_loc(pilot_loc==0)=[];

%% Test of channel code

%% 加VC
%% 改交织
% 
% t=poly2trellis(7,[171 133]); % Define trellis.
% x=randi([0 1],1,1000);
% 
% x_code=convenc(x,t);
% 
% tblen=32;
% 
% x_decode = vitdec(x_code,t,tblen,'trunc','hard');
% 
% hErrorCalc = comm.ErrorRate('ReceiveDelay', 48);
% ber = step(hErrorCalc, x', x_decode');

%% The continuous operation mode of vitdec causes a delay equal to the traceback length, so msg(1) corresponds to decoded(tblen+1) rather than to decoded(1).

%% Test of soft-deciscion decode
% clear; close all
% rng default
% M = 16;                 % Modulation order
% k = log2(M);            % Bits per symbol
% EbNoVec = (4:1:10);      % Eb/No values (dB)
% numSymPerFrame = 1000;  % Number of QAM symbols per frame
% 
% berEstSoft = zeros(size(EbNoVec)); 
% berEstHard = zeros(size(EbNoVec));
% 
% trellis = poly2trellis(7,[171 133]);
% tbl = 32;
% rate = 1/2;
% 
% SNR_dB= EbNoVec + 10*log10(k*rate);
% 
% for n=1:length(EbNoVec)
% 
%     noiseVar=10.^(-SNR_dB(n)/10);
%     [numErrsSoft,numErrsHard,numBits] = deal(0);
% 
%     while numErrsSoft<100 && numBits<1e7
% 
%         dataIn=randi([0 1],numSymPerFrame*k/2,1);
% 
%         % code
% 
%         dataEnc=convenc(dataIn,trellis);
% 
%         tx_Sig=qammod(dataEnc,M,'gray','InputType','bit','UnitAveragePower',true);
% 
%         tx_Sig_1=tx_Sig';
% 
%         re_sig_1=add_noise(tx_Sig_1,SNR_dB(n),0,0);
% 
%         rx_Sig=re_sig_1';
% 
%         rxDataHard = qamdemod(rx_Sig,M,'gray','OutputType','bit','UnitAveragePower',true);
% 
%         rxDataSoft = qamdemod(rx_Sig,M,'OutputType','llr', ...
%            'UnitAveragePower',true,'NoiseVariance',noiseVar);
% 
% 
%          % dataHard = vitdec(rxDataHard,trellis,tbl,'cont','hard');
% 
%          dataHard = vitdec(rxDataHard,trellis,tbl,'trunc','hard');
% 
%          dataSoft_1=channel_decode_soft(rxDataSoft,noiseVar,trellis);
% 
%         % Calculate the number of bit errors in the frame. Adjust for the
% 
%         numErrsInFrameHard= sum(dataIn~=dataHard);
%         numErrsInFrameSoft=  sum(dataIn(1:end-tbl)~=dataSoft_1(tbl+1:end));
%         
%         % Increment the error and bit counters
%         numErrsHard = numErrsHard + numErrsInFrameHard;
%         numErrsSoft = numErrsSoft + numErrsInFrameSoft;
%         numBits = numBits + numSymPerFrame*k/2;
% 
% 
%     end
% 
%    berEstSoft(n) = numErrsSoft/numBits;
%    berEstHard(n) = numErrsHard/numBits;
% 
% end
% 
% semilogy(EbNoVec,berEstSoft);
% hold on;
% semilogy(EbNoVec,berEstHard);
% legend('Soft','Hard')



% clear; close all
% rng default
% M = 16;                 % Modulation order
% k = log2(M);            % Bits per symbol
% EbNoVec = (4:10)';      % Eb/No values (dB)
% numSymPerFrame = 1000;  % Number of QAM symbols per frame
% 
% % eng_sqrt = (M==2)+(M~=2)*sqrt((M-1)/6*(2^2)); % 调制信号平均功率
% % A=1/eng_sqrt;   % QAM归一化因子
% 
% berEstSoft = zeros(size(EbNoVec)); 
% berEstHard = zeros(size(EbNoVec));
% 
% trellis = poly2trellis(7,[171 133]);
% tbl = 32;
% rate = 1/2;
% 
% for n = 1:length(EbNoVec)
%     % Convert Eb/No to SNR
%     snrdB = EbNoVec(n) + 10*log10(k*rate);
%     % Noise variance calculation for unity average signal power.
%     noiseVar = 10.^(-snrdB/10);
%     % Reset the error and bit counters
%     [numErrsSoft,numErrsHard,numBits] = deal(0);
%     
%     while numErrsSoft < 100 && numBits < 1e7
%         % Generate binary data and convert to symbols
%         dataIn = randi([0 1],numSymPerFrame*k/2,1);
%         
%         % Convolutionally encode the data
%         dataEnc = convenc(dataIn,trellis);
%         
%         % QAM modulate
%         txSig = qammod(dataEnc,M,'InputType','bit','UnitAveragePower',true);
%         
%         % Pass through AWGN channel
% 
%         txSig_1=txSig';
% 
%         % rxSig = awgn(txSig_1,snrdB,'measured');
% 
%         noise=sqrt(noiseVar/2)*(randn(1,length(txSig_1))+1j*randn(1,length(txSig_1)));
%         rxSig_1=txSig_1+noise;
%         
%         rxSig=rxSig_1';
%         % Demodulate the noisy signal using hard decision (bit) and
%         % soft decision (approximate LLR) approaches.
%         rxDataHard = qamdemod(rxSig,M,'OutputType','bit','UnitAveragePower',true);
%        %  rxDataHard = qamdemod(rxSig/A,M,'OutputType','bit');
%         rxDataSoft = qamdemod(rxSig,M,'OutputType','llr', ...
%             'UnitAveragePower',true,'NoiseVariance',noiseVar);
% %         rxDataSoft = qamdemod(rxSig/A,M,'OutputType','approxllr', ...
% %             'NoiseVariance',noiseVar);
%         
%         % Viterbi decode the demodulated data
%         dataHard = vitdec(rxDataHard,trellis,tbl,'cont','hard');
%        %  dataSoft = vitdec(rxDataSoft,trellis,tbl,'cont','unquant');
% 
%         %% Soft decode
% %         partitionPoints = (-0.75:0.25:0.75)/noiseVar;
% %         codebook = [0 1 2 3 4 5 6 7];
% %         quantizedValue = quantiz(-rxDataSoft,partitionPoints);
% 
% %         decSoft = comm.ViterbiDecoder(trellis,'InputFormat','Soft', ...
% %     'SoftInputWordLength',3,'TracebackDepth',tbl);
% 
%         % dataSoft_1 = decSoft(double(quantizedValue));
% 
%         % dataSoft_1 = vitdec(double(quantizedValue),trellis,tbl,'cont','soft',3);
% 
%         dataSoft_1=channel_decode_soft(rxDataSoft,noiseVar,trellis);
% 
% 
%         
%         % Calculate the number of bit errors in the frame. Adjust for the
%         % decoding delay, which is equal to the traceback depth.
%         % numErrsInFrameHard = biterr(dataIn(1:end-tbl),dataHard(tbl+1:end));
%         numErrsInFrameHard= sum(dataIn(1:end-tbl)~=dataHard(tbl+1:end));
%         % numErrsInFrameSoft = biterr(dataIn(1:end-tbl),dataSoft_1(tbl+1:end));
%         numErrsInFrameSoft=  sum(dataIn(1:end-tbl)~=dataSoft_1(tbl+1:end));
%         
%         % Increment the error and bit counters
%         numErrsHard = numErrsHard + numErrsInFrameHard;
%         numErrsSoft = numErrsSoft + numErrsInFrameSoft;
%         numBits = numBits + numSymPerFrame*k/2;
% 
%     end
%     
%     % Estimate the BER for both methods
%     berEstSoft(n) = numErrsSoft/numBits;
%     berEstHard(n) = numErrsHard/numBits;
% end
% 
% semilogy(EbNoVec,[berEstSoft berEstHard],'-*')
% hold on
% semilogy(EbNoVec,berawgn(EbNoVec,'qam',M))
% legend('Soft','Hard','Uncoded','location','best')
% grid
% xlabel('Eb/No (dB)')
% ylabel('Bit Error Rate')
