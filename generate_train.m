
function [STS,LTS,LTS_one]=generate_train(fftlen,cplen)
%% Ieee 802.11a train symbol

%% Short train symbol

%short_tr_symbol_temp来源于8021.11a
short_tr_symbol_temp = sqrt(13/6)*[0, 0, 1+1j, 0, 0, 0, -1-1j, 0, 0, 0, 1+1j, 0, 0, 0, -1-1j, 0, 0, 0, -1-1j, 0, 0, 0, 1+1j, 0, 0, 0, 0,...
 0, 0, 0, -1-1j, 0, 0, 0, -1-1j, 0, 0, 0, 1+1j, 0, 0, 0, 1+1j, 0, 0, 0, 1+1j, 0, 0, 0, 1+1j, 0,0];
short_tr_symbol = [zeros(1,6) short_tr_symbol_temp zeros(1,5)];
short_tr_symbol_ifft = ifft(short_tr_symbol,fftlen);
short_tr_one_symbol = [short_tr_symbol_ifft(1,end-cplen+1:end) short_tr_symbol_ifft];
short_tr_two_symbol = [short_tr_one_symbol short_tr_one_symbol];

STS=short_tr_two_symbol;

% repeatlen = length(short_tr_two_symbol)/cplen;
% sum_len  = zeros(1,repeatlen);
% 
% for iii = 1:repeatlen
%     
%     temp_len1 = short_tr_two_symbol(1,1:cplen );
%     temp_len2 = short_tr_two_symbol(1,(iii-1)*cplen +1:iii*cplen );
%     sum_len(1,iii) = sum(temp_len1==temp_len2); 
% end

%% Long train symbol

%********************* 长训练序列
%% long_tr_symbol_temp来源于8021.11a
long_tr_symbol_temp = [1, 1, -1, -1, 1, 1, -1, 1, -1, 1, 1, 1, 1, 1, 1, -1, -1, 1, 1, -1, 1, -1, 1, 1, 1, 1, 0,... 
 1, -1, -1, 1, 1, -1, 1, -1, 1, -1, -1, -1, -1, -1, 1, 1, -1, -1, 1, -1, 1, -1, 1, 1, 1, 1];
long_tr_symbol = [zeros(1,6) long_tr_symbol_temp  zeros(1,5)];

long_tr_symbol_ifft = ifft(long_tr_symbol,fftlen);
% long_tr_one_symbol = [short_tr_symbol_ifft(1,end-cplen+1:end) short_tr_symbol_ifft];
long_tr_two_symbol = [long_tr_symbol_ifft(1,33:64) long_tr_symbol_ifft long_tr_symbol_ifft];

LTS=long_tr_two_symbol;
LTS_one=long_tr_symbol_ifft;
