function [outdata] = channel_decode(indata)

%% (2,1,7) 卷积编码解码
trellis = poly2trellis(7,[171 133]); % (2,1,7) 卷积编码
constraint=7;
tblen=5*(constraint-1); % general setting
% outdata = vitdec(indata,trellis,tblen,'trunc','hard');

outdata = vitdec(indata,trellis,tblen,'trunc','hard');

end