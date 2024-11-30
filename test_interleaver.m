clear; close all
rng default
% M = 64;                 % Modulation order
% k = log2(M);            % Bits per symbol
% EbNoVec = (4:10)';      % Eb/No values (dB)
% numSymPerFrame = 1000;  % Number of QAM symbols per frame
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
%         dataIn = randi([0 1],numSymPerFrame*k,1);
%         
%         % Convolutionally encode the data
%         dataEnc = convenc(dataIn,trellis);
% 
%         data_inter=matintrlv(dataEnc,length(dataEnc)/20,20);
%         
%         % QAM modulate
%         txSig = qammod(data_inter,M,'InputType','bit','UnitAveragePower',true);
%         
%         % Pass through AWGN channel
%         rxSig = awgn(txSig,snrdB,'measured');
%         
%         % Demodulate the noisy signal using hard decision (bit) and
%         % soft decision (approximate LLR) approaches.
%         rxDataHard = qamdemod(rxSig,M,'OutputType','bit','UnitAveragePower',true);
%         rxDataSoft = qamdemod(rxSig,M,'OutputType','approxllr', ...
%             'UnitAveragePower',true,'NoiseVariance',noiseVar);
%         
%         % Viterbi decode the demodulated data
%         
%         rxDataHard_deinter=matdeintrlv(rxDataHard,length(rxDataHard)/20,20);
%         rxDataSoft_deinter= matdeintrlv(rxDataSoft,length(rxDataSoft)/20,20);
% 
%         dataHard = vitdec(rxDataHard_deinter,trellis,tbl,'cont','hard');
%         dataSoft = vitdec(rxDataSoft_deinter,trellis,tbl,'cont','unquant');
%         
%         % Calculate the number of bit errors in the frame. Adjust for the
%         % decoding delay, which is equal to the traceback depth.
%         numErrsInFrameHard = biterr(dataIn(1:end-tbl),dataHard(tbl+1:end));
%         numErrsInFrameSoft = biterr(dataIn(1:end-tbl),dataSoft(tbl+1:end));
%         
%         % Increment the error and bit counters
%         numErrsHard = numErrsHard + numErrsInFrameHard;
%         numErrsSoft = numErrsSoft + numErrsInFrameSoft;
%         numBits = numBits + numSymPerFrame*k;
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



trellis = poly2trellis(7,[171 133]);
tbl = 32;
rate = 1/2;
M_mod=16;

data=randi([0 1],100,1);
code_data=convenc(data,trellis);

data_inter=matintrlv(code_data,length(code_data)/20,20);

tx_data=qammod(data_inter,M_mod,'InputType','bit','UnitAveragePower',true);

tx_data=tx_data';

re_data=qamdemod(tx_data',M_mod,'OutputType','approxllr','UnitAveragePower',true);

data_deinter= matdeintrlv(re_data,length(data_inter)/20,20);

decode_data_soft = vitdec(data_deinter,trellis,tbl,'cont','unquant');

result=sum(decode_data_soft(tbl+1:end)~=data(1:end-tbl));
