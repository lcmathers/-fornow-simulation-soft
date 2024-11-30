function [outdata] = channel_decode_soft(indata,noiseVar,trellis)

% trellis = poly2trellis(7,[171 133]);
constraint=7;
tblen=5*(constraint-1); % general setting

tblen=32;

% decSoft = comm.ViterbiDecoder(trellis,'InputFormat','Soft', ...
%     'SoftInputWordLength',3,'TracebackDepth',tblen);


% partitionPoints = (-0.75:0.25:0.75)/noiseVar;

partitionPoints = (-1+0.125:0.125:1-0.125)/noiseVar;
% codebook = [0 1 2 3 4 5 6 7];
quantizedValue = quantiz(-indata,partitionPoints);

% outdata = decSoft(double(quantizedValue));

outdata = vitdec(double(quantizedValue),trellis,tblen,'cont','soft',4);

% outdata = vitdec(indata,trellis,tblen,'cont','unquant');

end