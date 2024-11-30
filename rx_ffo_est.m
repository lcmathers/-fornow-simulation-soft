% Frequency error estimation and correction
function [out_signal, freq_est] = rx_ffo_est(sync_time_signal,rx_signal,fine_time_est,cfo_est, sim_options)

global sim_consts;

[n_tx_antennas, n_rx_antennas] = get_n_antennas(sim_options);

% Estimate the frequency error
if sim_options.FreqSync
   
   % allows for error in packet detection
   pkt_det_offset = fine_time_est - 16;
   
   % averaging length
   rlen = 128;
   
   % long training symbol periodicity
   D = 64; 
      
   phase = rx_signal(:,pkt_det_offset:pkt_det_offset+rlen-D).* ...
      conj(rx_signal(:,pkt_det_offset+D:pkt_det_offset+rlen));
   
   % add all estimates 
   phase = sum(phase, 2);   

   % with rx diversity combine antennas
   phase = sum(phase, 1);   
   
   freq_est = -angle(phase) / (2*D*pi/sim_consts.SampFreq);
   
   radians_per_sample = 2*pi*(freq_est+cfo_est)/sim_consts.SampFreq;
else
   % Magic number
   freq_est = -sim_options.FreqError;
   radians_per_sample = 2*pi*freq_est/sim_consts.SampFreq;
end

% Now create a signal that has the frequency offset in the other direction
siglen=length(sync_time_signal(1,:));
time_base=1:siglen;
correction_signal=repmat(exp(-j*(radians_per_sample)*time_base),n_rx_antennas,1);

% And finally apply correction on the signal
out_signal = round(sync_time_signal.*correction_signal);

if sim_options.LoadRtlData
load ./txt/freq_comp_cos.txt
load ./txt/freq_comp_sin.txt    
freq_comp_wave = freq_comp_cos + freq_comp_sin*1i;
 
freq_comp_wave_mat = round(32767*conj(correction_signal));
freq_comp_wave_mat = freq_comp_wave_mat(2:end);
  a = min(size(freq_comp_wave_mat,1),size(freq_comp_wave,1)); 
 plot(real(freq_comp_wave_mat),'b');
 hold on
  plot(real(freq_comp_wave),'r');

  

    
end    

