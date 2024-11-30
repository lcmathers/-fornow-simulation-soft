function [outdata] = channel_code(indata,trellis)

%% (2,1,7) 卷积编码

% trellis = poly2trellis(7,[171 133]); % (2,1,7) 卷积编码
outdata=convenc(indata,trellis);

end