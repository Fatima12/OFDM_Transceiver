function [ outputLONGPreamble ] = long_Training_Sequence( nFFTSize )

    LongPreamble = [zeros(1,6) 1 1 -1 -1 1 1 -1 1 -1 1 1 1 1 1 1 -1 -1 ...
      1 1 -1 1 -1 1 1 1 1 0 1 -1 -1 1 1 -1 1 -1 1 -1 -1 -1 -1 -1 1 1 -1 ...
      -1 1 -1 1 -1 1 1 1 1 zeros(1,5) ]; % [16:31]
    LongP = fftshift(LongPreamble);
    outputLONGiFFT = ifft(LongP,nFFTSize); % generate 64 sample sequence
    
    outputLONGiFFT = [outputLONGiFFT(33:64) outputLONGiFFT(1:32)];
    
    % concatenating multiple symbols to form 10short preamble
    outputLONGPreamble = [outputLONGiFFT outputLONGiFFT outputLONGiFFT(1:32)];
    outputLONGPreamble(1) = outputLONGPreamble(1)*0.5;
    outputLONGPreamble = [outputLONGPreamble outputLONGPreamble(1)]; 

end

