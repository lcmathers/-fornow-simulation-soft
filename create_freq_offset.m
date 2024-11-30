

function offset_sig = create_freq_offset(input_signal, freq_offset,SampFreq);



n_signals = size(input_signal,1);

% create a timebase
time_base = (0:(length(input_signal)-1))/SampFreq;

% create phase_rotation vector
phase_rotation = repmat(exp(j*2*pi*freq_offset*time_base), n_signals, 1);

% and apply it to the signal;
offset_sig = floor(input_signal.*phase_rotation);



