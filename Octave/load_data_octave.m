close all
clear
clc

%
% This function parse a string containing the timestamp in a Octave timestamp.
% usage: matrix = datenumWithMic(strtime, format)
%
% The function inherits from the function datenum native in Octave.
%
% input:
%   - strtime: the string to parse;
%   - format: the format of the date (@see datenum)
%			it's necessary add the character that separate the date from the number of microseconds
%
% output:
%	- timestamp: a native timestamp in Octave (float number)
%
% example:
%	timestamp = datenumWithMic('2010/11/02 00:00:00.318940','yyyy/mm/dd HH:MM:SS.')
%
% 
%
function timestamp = datenumWithMic(strtime, format)

	% check arguments
	if nargin < 1
		error('Error: parameter "strtime" undefined.');
	end

	if nargin < 2
		error('Error: parameter "format" undefined.');
	end

	if (length(strtime)>length(format))
	  % separate date and microseconds
	  date = substr(strtime, 1, length(format));
	  micSub = substr(strtime, length(format)+1);
	  
	  % parse the microseconds
	  mic = '000000';
	  mic(1:length(micSub)) = micSub;
	  mic = sscanf(mic,'%f');

	  % parse the date
	  timestamp = datenum(date, format);

	  % add date and microseconds
	  timestamp = timestamp + mic/(86400000000);
	else
	  timestamp = datenum(strtime, format);
	end

end

% frequency sweep
f0_vector = [0.05 0.1 0.2 0.4 1 2 4 10 20 40];
data_file_prefix= 'test_battery_readback_5ms_50ma_autoOFF_nplc_01_';


for idx_f0 = 1 : length(f0_vector)
    
    f0 = f0_vector(idx_f0)
    %
    % Foreach frequency  
    % Read current and voltage data from file
    %
    fid = fopen([ data_file_prefix num2str(f0) '.csv']);
    line=fgetl(fid); % discard header

    count = 1;
    %     tic
    while (1)
        line = fgetl(fid);
        if line == -1
            break
        end
        data = sscanf(line(31:end),'%f;%f');
        sig_i(count) = data(1);
        sig_v(count) = data(2);
        t(count) = datenumWithMic(line(12:25),'HH:MM:SS.');
        count = count + 1;
    end
    fclose(fid);
%     toc
    
    t = (t-t(1))*3600*24; % convert to seconds
    

    Fs = 1/mean(diff(t))
    
    % discard transient
    T_trans = 40;
    sig_i = sig_i(T_trans*Fs:end);
    sig_v = sig_v(T_trans*Fs:end);
    t = t(T_trans*Fs:end);
    
    N = length(sig_i);

    figure(1);
    plot(t, sig_i, '.-')
    hold on;
    grid on;
    xlabel('time [s]')
    ylabel('current [A]')

    figure(2);
    hold on;
    grid on;
    plot(t, sig_v,'.-')
    xlabel('time [s]')
    ylabel('voltage [V]')
    
    sig_i = sig_i - mean(sig_i);
    sig_v = sig_v - mean(sig_v);

    f_base = 0 : Fs/N : Fs - Fs/N;
    V = fft(sig_v(:)-mean(sig_v))/N; 
    I = fft(sig_i(:)-mean(sig_i))/N;

    figure(3);
    semilogx(f_base, 20*log10(abs(V)), 'b.')
    hold on;
    grid on;
    plot(f_base, 20*log10(abs(I)), 'r.')
    xlabel('frequency [Hz]')
    ylabel('magnitude [dB]')
    axis([0 Fs/2 0 1]); axis 'auto y';
    legend('voltage', 'current')
    hold off
    
    drawnow
    
    
    idx_freq_v = find(abs(V(1:N/2))==max(abs(V(1:N/2))));
    idx_freq_i = find(abs(I(1:N/2))==max(abs(I(1:N/2))));
        
    f_peak_v = f_base(idx_freq_v) % DEBUG
    f_peak_i = f_base(idx_freq_i) % DEBUG    
        
    Z_vector(idx_f0) = V(idx_freq_v)./I(idx_freq_i);
    
    Z_abs = 20*log10(abs(Z_vector(idx_f0)))   
        
end


%% plot
figure; 
subplot(211)
semilogx(f0_vector, 20*log10(abs(Z_vector)),'-b.');
hold on;
xlabel('frequency [Hz]')
ylabel('Magnitude [dB]')
grid on
subplot(212)
semilogx(f0_vector, rad2deg(angle((Z_vector))),'-b.');
hold on;
xlabel('frequency [Hz]')
ylabel('phase [deg]')
grid on

figure;
plot(real(Z_vector), -imag(Z_vector))
xlabel('Re(Z) [\Omega]')
ylabel('-Im(Z) [\Omega]')
grid on
hold on;

