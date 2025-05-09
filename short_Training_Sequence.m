function [ outputShortPreamble ] = short_Training_Sequence(nFFTSize)

    inputFFTShortPreamble = sqrt(13/6)*[zeros(1,8) 1+j 0 0 0  -1-j 0 0 0 ... % [-32:-17]
     1+j 0 0 0  -1-j 0 0 0 -1-j 0 0 0   1+j 0 0 0 ...             % [-16:-1]
     0   0 0 0  -1-j 0 0 0 -1-j 0 0 0   1+j 0 0 0 ...             % [0:15]
     1+j 0 0 0   1+j 0 0 0  1+j 0 0 0   0   0 0 0 ];              % [16:31]
     
    
    % taking ifft
    outputiFFT = ifft(fftshift(inputFFTShortPreamble),nFFTSize); % generate 64 sample sequence
    
    % concatenating multiple symbols to form 10short preamble
    outputShortPreamble = [outputiFFT outputiFFT outputiFFT(1:32)];
    outputShortPreamble(1) = outputShortPreamble(1)*0.5;

end

