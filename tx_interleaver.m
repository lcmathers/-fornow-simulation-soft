%% Interleaver

function [intrlvOut]=ofdm_interleaver(in,dataIntrlvLen)

lenIn = size(in,1);
numIntRows = ceil(lenIn/dataIntrlvLen);
numInPad = (dataIntrlvLen*numIntRows) - lenIn;  % number of padded entries needed to make the input data length factorable
numFullCols = dataIntrlvLen - numInPad;
inPad = [in ; zeros(numInPad,1)];               % pad the input data so it is factorable
temp = reshape(inPad,dataIntrlvLen,[]).';       % form interleave matrix  先形成20*256的矩阵，再取转置
temp1 = reshape(temp(:,1:numFullCols),[],1);    % extract out the full rows
if numInPad ~= 0
    temp2 = reshape(temp(1:numIntRows-1,numFullCols+1:end),[],1); % extract out the partially-filled rows
else
    temp2 = [];
end

intrlvOut = [temp1 ; temp2]; % concatenate the two rows

end